package occupyhdm.app;

import android.app.Activity;

import android.os.Bundle;
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
    }

    public void startGame (View view) {
        String username = editTextUsername.getText().toString();

        if (username.equals("")) {
            textViewUsernameWarning.setVisibility(View.VISIBLE);
        } else {
            textViewUsernameWarning.setVisibility(View.GONE);
        }
    }
}

