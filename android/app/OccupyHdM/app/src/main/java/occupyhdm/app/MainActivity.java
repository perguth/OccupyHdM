package occupyhdm.app;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Handler;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import com.google.android.gms.maps.*;
import com.google.android.gms.maps.model.*;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.concurrent.Callable;

public class MainActivity extends AppCompatActivity implements OnMapReadyCallback {
    private static GoogleMap map;
    private MainActivity context;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        context = this;
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Log.d("View", "MainActivity");
        MapFragment mapFragment = (MapFragment) getFragmentManager().findFragmentById(R.id.mapView);
        mapFragment.getMapAsync(this);
    }

    @Override
    public void onMapReady(GoogleMap map) {
        this.map = map;
        Log.d("onMapRead", "Callback received");
        addMarkersToMap();
        LatLng sydney = new LatLng(48.74207, 9.102263);

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            // TODO: Consider calling
            //    ActivityCompat#requestPermissions
            // here to request the missing permissions, and then overriding
            //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
            //                                          int[] grantResults)
            // to handle the case where the user grants the permission. See the documentation
            // for ActivityCompat#requestPermissions for more details.
            return;
        }
        map.setMyLocationEnabled(true);
        map.setMapType(map.MAP_TYPE_SATELLITE);
        map.moveCamera(CameraUpdateFactory.newLatLngZoom(sydney, 16.85f));
        // hide the zoom control as our design is covering it
        map.getUiSettings().setZoomControlsEnabled(false);
    }

    private void addMarkersToMap() {
        class JsonReceived extends Callback {
            @Override
            public Void call() {
                Log.d("JSON", "The result is: " + result);
                addMarker((String) result);
                return null;
            }
        }

        Log.d("JSON", "test started---");
        RestTask rest = new RestTask(new JsonReceived());
        rest.execute("https://pma.perguth.de/goals");
    }

    public void addMarker(String jsonString) {
        try {
            final JSONArray jsonArray = new JSONObject(jsonString).getJSONArray("locations");
            Handler mainHandler = new Handler(context.getMainLooper());
            Runnable myRunnable = new Runnable() {
                @Override
                public void run() {
                    for (int i = 0; i < jsonArray.length(); i++) {
                        JSONObject entry = null;
                        LatLng marker = null;
                        String owner = null;
                        String name = null;

                        try {
                            entry = jsonArray.getJSONObject(i);
                            marker = new LatLng(entry.getDouble("lat"), entry.getDouble("lon"));
                            owner = entry.getString("owner");
                            name = entry.getString("name");

                            Log.d("JSON", name + owner + marker.toString());
                            // Get a handler that can be used to post to the main thread
                            MainActivity.map.addMarker(new MarkerOptions()
                                    .position(marker)
                                    .title(name)
                                    .snippet("Owned by " + owner)
                                    .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_AZURE)));
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }
                }
            };
            mainHandler.post(myRunnable);
        } catch (JSONException e) {
            e.printStackTrace();
        } ;
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
