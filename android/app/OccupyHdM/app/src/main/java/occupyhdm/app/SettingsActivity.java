package occupyhdm.app;

import android.content.Context;
import android.content.SharedPreferences;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.SeekBar;
import android.widget.TextView;

public class SettingsActivity extends AppCompatActivity implements SeekBar.OnSeekBarChangeListener {
    private SeekBar seekBarAccuracy;
    private SeekBar seekBarDistance;
    private SeekBar seekBarRefreshRate;

    private TextView textViewAccuracyValue;
    private TextView textViewDistanceValue;
    private TextView textViewRefreshRateValue;

    private static int minAccuracy = 25;
    private static int minDistance = 5;
    private static int minRefreshRate = 1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);

        seekBarAccuracy = (SeekBar) findViewById(R.id.seekBarAccuracy);
        seekBarDistance = (SeekBar) findViewById(R.id.seekBarDistance);
        seekBarRefreshRate = (SeekBar) findViewById(R.id.seekBarRefreshRate);

        seekBarAccuracy.setOnSeekBarChangeListener(this);
        seekBarDistance.setOnSeekBarChangeListener(this);
        seekBarRefreshRate.setOnSeekBarChangeListener(this);

        textViewAccuracyValue = (TextView) findViewById(R.id.textViewAccuracyValue);
        textViewDistanceValue = (TextView) findViewById(R.id.textViewDistanceValue);
        textViewRefreshRateValue = (TextView) findViewById(R.id.textViewRefreshRateValue);

        SharedPreferences sharedPreferences = this.getSharedPreferences(getString(R.string.preferences_key), Context.MODE_PRIVATE);
        int accuracy = sharedPreferences.getInt(getString(R.string.preferences_accuracy), 38);
        int distance = sharedPreferences.getInt(getString(R.string.preferences_distance), 23);
        int refreshRate = sharedPreferences.getInt(getString(R.string.preferences_refreshRate), 15);

        seekBarAccuracy.setProgress(accuracy - minAccuracy);
        seekBarDistance.setProgress(distance - minDistance);
        seekBarRefreshRate.setProgress(refreshRate - minRefreshRate);

        textViewAccuracyValue.setText(String.valueOf(accuracy));
        textViewDistanceValue.setText(String.valueOf(distance));
        textViewRefreshRateValue.setText(String.valueOf(refreshRate));
    }

    @Override
    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
        int value = progress;
        SharedPreferences sharedPreferences = this.getSharedPreferences(getString(R.string.preferences_key), Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();

        if (seekBar.equals(seekBarAccuracy)) {
            value += minAccuracy;
            textViewAccuracyValue.setText(String.valueOf(value));
            editor.putInt(getString(R.string.preferences_accuracy), value);
        } else if (seekBar.equals(seekBarDistance)) {
            value += minDistance;
            textViewDistanceValue.setText(String.valueOf(value));
            editor.putInt(getString(R.string.preferences_distance), value);
        } else if (seekBar.equals(seekBarRefreshRate)) {
            value += minRefreshRate;
            textViewRefreshRateValue.setText(String.valueOf(value));
            editor.putInt(getString(R.string.preferences_refreshRate), value);
        }

        editor.commit();
    }

    @Override
    public void onStartTrackingTouch(SeekBar seekBar) {

    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {

    }
}
