package occupyhdm.app;

import android.app.Activity;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.Window;
import android.widget.EditText;
import android.widget.TextView;

public class LoginActivity extends Activity {
    EditText editTextUsername;
    TextView textViewUsernameWarning;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        this.requestWindowFeature(Window.FEATURE_NO_TITLE);

        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_login);

        editTextUsername = (EditText) findViewById(R.id.editTextUsername);
        textViewUsernameWarning = (TextView) findViewById(R.id.textViewUsernameWarning);

        editTextUsername.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View view, int keyCode, KeyEvent event) {
                if (event.getAction() == KeyEvent.ACTION_DOWN) {
                    if (keyCode == KeyEvent.KEYCODE_ENTER) {
                        startGame(view);
                    }
                }

                return false;
            }
        });
    }

    public void startGame (View view) {
        String username = editTextUsername.getText().toString();

        if (username.equals("")) {
            textViewUsernameWarning.setVisibility(View.VISIBLE);
        } else {
            textViewUsernameWarning.setVisibility(View.GONE);

            SharedPreferences preferences = this.getSharedPreferences(getString(R.string.preferences_key), Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = preferences.edit();
            editor.putString("username", username);
            editor.commit();

            Intent intentStartMain = new Intent(this, MainActivity.class);
            startActivity(intentStartMain);
        }
    }
}

