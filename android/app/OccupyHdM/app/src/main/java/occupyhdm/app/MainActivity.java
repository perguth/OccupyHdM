package occupyhdm.app;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.StrictMode;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;


import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapFragment;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.text.DateFormat;
import java.util.Date;

public class MainActivity extends AppCompatActivity
        implements OnMapReadyCallback {
    protected final Long REST_CALL_CYCLE = 1000 * 10L;
    protected Location currentLocation;
    private GoogleMap map;
    private LatLng initialPosition = new LatLng(48.74207, 9.102263);
    private View curtain;
    private TextView textViewScore;
    private String username;
    private int accuracy;
    private int distance;
    private int refreshRate;
    private int score;
    private LocationManager locationManager;
    private LocationListener networkLocationListener;
    private LocationListener gpsLocationListener;
    private JSONArray jsonArray;
    private Long lastRestQueryTime = 0L;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        getPrefernces();

        curtain = findViewById(R.id.curtain);
        TextView textViewScore = (TextView)findViewById(R.id.textViewScore);
        assert textViewScore != null;
        textViewScore.setText(String.valueOf(score));
        TextView textViewUsername = (TextView)findViewById(R.id.textViewUsername);
        assert textViewUsername != null;
        textViewUsername.setText(username);

        MapFragment mapFragment = (MapFragment) getFragmentManager().findFragmentById(R.id.mapView);
        mapFragment.getMapAsync(this);

        getLocationUpdates();
    }

    private void getPrefernces () {
        SharedPreferences preferences = this.getSharedPreferences(getString(R.string.preferences_key), Context.MODE_PRIVATE);
        username = preferences.getString("username", "");
        accuracy = preferences.getInt(getString(R.string.preferences_accuracy), 38);
        distance = preferences.getInt(getString(R.string.preferences_distance), 23);
        refreshRate = preferences.getInt(getString(R.string.preferences_refreshRate), 15);
        score = preferences.getInt("score", 0);
    }

    public void getLocationUpdates() {
        // Acquire a reference to the system Location Manager
        locationManager = (android.location.LocationManager) this.getSystemService(Context.LOCATION_SERVICE);

        // Define a listener that responds to location updates
        networkLocationListener = new LocationListener() {
            public void onLocationChanged(Location location) {
                Log.i("location", "onLocationChanged() -> " + location.toString());
                currentLocation = location;
                handleOwnage(location);
            }

            public void onStatusChanged(String provider, int status, Bundle extras) {}
            public void onProviderEnabled(String provider) {}
            public void onProviderDisabled(String provider) {}
        };
        gpsLocationListener = new LocationListener() {
            public void onLocationChanged(Location location) {
                // unregister network location listener as soon as GPS is more accurate
                int accuracyDelta = (int) (location.getAccuracy() - currentLocation.getAccuracy());
                boolean isFromSameProvider = location.getProvider().equals(currentLocation.getProvider());
                if (accuracyDelta < 0 && !isFromSameProvider) {
                    Log.i("location", "***** removeNetworkListener() -> " + location.toString());
                    removeNetworkListener();
                    curtain.setVisibility(View.GONE);
                }

                currentLocation = location;
                handleOwnage(location);
            }

            public void onStatusChanged(String provider, int status, Bundle extras) {}
            public void onProviderEnabled(String provider) {}
            public void onProviderDisabled(String provider) {}
        };

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return;
        }
        // Register the listener with the Location Manager to receive location updates
        locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, refreshRate, 0, networkLocationListener);
        locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, refreshRate, 0, gpsLocationListener);

        currentLocation = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);

        Log.i("location", "getLastKnownLocation() -> " + currentLocation.toString());
    }

    private void handleOwnage(Location location) {
        if (location.getAccuracy() > accuracy) {
            // too inaccurate position, we're not interested
            return;
        }
        if (jsonArray == null) {
            // if the REST call takes longer than GPS fix then jsonArray will still be null
            return;
        }

        for (int i = 0; i < jsonArray.length(); i++) {
            try {
                JSONObject entry = jsonArray.getJSONObject(i);
                String owner = entry.getString("owner");
                String name = entry.getString("name");

                if (owner == username) {
                    // we already own it, no need to claim
                    continue;
                }

                double lat = entry.getDouble("lat");
                double lon = entry.getDouble("lon");

                Location targetLocation = new Location("");
                targetLocation.setLatitude(lat);
                targetLocation.setLongitude(lon);

                float distanceInMeters =  targetLocation.distanceTo(location);

                if (distanceInMeters <= distance) {
                    Log.i("ownage", "claiming location: " + name);

                    // update locale score
                    score += 50;
                    SharedPreferences preferences = this.getSharedPreferences("preferences", Context.MODE_PRIVATE);
                    SharedPreferences.Editor editor = preferences.edit();
                    editor.putInt("score", score);
                    editor.commit();
                    textViewScore.setText(String.valueOf(score));

                    // call REST
                    String urlString = "https://pma.perguth.de/own/" + name + "/" + username;
                    URL url = new URL(urlString);
                    HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
                    StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
                    StrictMode.setThreadPolicy(policy);

                    try {
                        // we're not interested in the response
                        // but the call fires only after...
                        urlConnection.getHeaderFields();
                    } finally {
                        urlConnection.disconnect();
                    }

                    entry.put("name", username);
                    jsonArray.put(i, entry);
                }
                getJsonAndAddMarkers();
            } catch (JSONException e) {
                e.printStackTrace();
            } catch (MalformedURLException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private void removeNetworkListener() {
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return;
        }
        Log.i("location", "removeNetworkListener() for networkLocationListener");
        locationManager.removeUpdates(networkLocationListener);
    }

    @Override
    public void onMapReady(GoogleMap map) {
        this.map = map;

        getJsonAndAddMarkers();

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return;
        }
        map.setMyLocationEnabled(false);
        map.setMapType(map.MAP_TYPE_SATELLITE);
        map.moveCamera(CameraUpdateFactory.newLatLngZoom(initialPosition, 16.85f));
        // hide the zoom control as our design is covering it
        map.getUiSettings().setZoomControlsEnabled(false);
    }

    private void centerCamera() {
        map.moveCamera(CameraUpdateFactory.newLatLngZoom(initialPosition, 16.85f));
    }

    private void getJsonAndAddMarkers() {
        Long now = System.currentTimeMillis() / 1000L;
        if (REST_CALL_CYCLE > (lastRestQueryTime - now) && lastRestQueryTime != 0L) {
            return;
        }
        Log.i("rest", "requesting new data");

        class JsonReceived extends Callback {
            @Override
            public Void call() {
                try {
                    addMarkers((String) result);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                return null;
            }
        }

        RestTask rest = new RestTask(new JsonReceived());
        rest.execute("https://pma.perguth.de/goals");

        lastRestQueryTime = now;
    }

    public void addMarkers(String jsonString) throws JSONException {
        jsonArray = new JSONObject(jsonString).getJSONArray("locations");

        map.clear(); // remove all old markers
        for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject entry = jsonArray.getJSONObject(i);
            LatLng marker = new LatLng(entry.getDouble("lat"), entry.getDouble("lon"));
            String owner = entry.getString("owner");
            String name = entry.getString("name");

            map.addMarker(new MarkerOptions()
                    .position(marker)
                    .title(name)
                    .snippet("Owned by " + owner)
                    .icon(
                            BitmapDescriptorFactory.fromResource(
                                    username.equals(owner) ?
                                            R.drawable.pin_green :
                                            R.drawable.pin_red
                            )
                    )
            );
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.menu_main, menu);
        super.onCreateOptionsMenu(menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == R.id.settings) {
            Intent intentStartSettings = new Intent(this, SettingsActivity.class);
            startActivity(intentStartSettings);
        }

        return true;
    }
}