package occupyhdm.app;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
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

public class MainActivity extends AppCompatActivity implements OnMapReadyCallback {
    private GoogleMap map;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        MapFragment mapFragment = (MapFragment) getFragmentManager().findFragmentById(R.id.mapView);
        mapFragment.getMapAsync(this);
    }

    @Override
    public void onMapReady(GoogleMap map) {
        this.map = map;
        LatLng initialPosition = new LatLng(48.74207, 9.102263);

        if (
            ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED &&
            ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED
        ) { return; }

        addMarkersToMap();

        map.setMyLocationEnabled(true);
        map.setMapType(map.MAP_TYPE_SATELLITE);
        map.moveCamera(CameraUpdateFactory.newLatLngZoom(initialPosition, 16.85f));
        // hide the zoom control as our design is covering it
        map.getUiSettings().setZoomControlsEnabled(false);
    }

    private void addMarkersToMap() {
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
    }

    public void addMarkers(String jsonString) throws JSONException {
        JSONArray jsonArray = new JSONObject(jsonString).getJSONArray("locations");

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
                    BitmapDescriptorFactory.defaultMarker(
                        BitmapDescriptorFactory.HUE_AZURE
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
