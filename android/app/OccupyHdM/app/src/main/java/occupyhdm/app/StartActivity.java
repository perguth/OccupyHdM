package occupyhdm.app;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;

public class StartActivity extends Activity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        SharedPreferences preferences = this.getSharedPreferences(getString(R.string.preferences_key), Context.MODE_PRIVATE);
        String username = preferences.getString("username", "");

        if (username.equals("")) {
            Intent intentStartLogin = new Intent(this, LoginActivity.class);
            startActivity(intentStartLogin);
        } else {
            Intent intentStartMain = new Intent(this, MainActivity.class);
            startActivity(intentStartMain);
        }
    }
}
