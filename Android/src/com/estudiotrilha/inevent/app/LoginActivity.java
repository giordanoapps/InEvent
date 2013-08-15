package com.estudiotrilha.inevent.app;


import java.io.IOException;
import java.net.HttpURLConnection;

import org.apache.http.HttpStatus;
import org.json.JSONObject;

import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.Toast;

import com.estudiotrilha.android.app.ProgressDialogFragment;
import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.content.ApiRequest;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.content.Person;


public class LoginActivity extends ActionBarActivity
{
    // App State
    private static final String STATE_USERNAME = LoginActivity.class.getName()+"state.USERNAME";

    // Api Request Code
    private static final int REQUEST_LOGIN = 1;


    private EditText mUsername;
    private EditText mPassword;


    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        // Don't show the action bar
        ActionBar actionBar = getSupportActionBar();
        actionBar.setDisplayShowTitleEnabled(false);
        actionBar.setDisplayHomeAsUpEnabled(true);

        // setup the button functions
        findViewById(R.id.login_confirmButton).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v)
            {
                setUserInteractionEnabled(false);
                loginAttempt();
            }
        });


        mUsername = (EditText) findViewById(R.id.login_username);
        mPassword = (EditText) findViewById(R.id.login_password);

        if (savedInstanceState == null)
        {
            // recover last logged in username
            String username = PreferenceManager.getDefaultSharedPreferences(this).getString(STATE_USERNAME, "");
            mUsername.setText(username);
        }
    }


    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        switch(item.getItemId())
        {
        case android.R.id.home:
            finish();
            break;
        }

        return super.onOptionsItemSelected(item);
    }


    private void loginAttempt()
    {
        // Shows a loading progress
        final ProgressDialogFragment progress = new ProgressDialogFragment();
        progress.show(getSupportFragmentManager(), null);
        progress.setMessage(R.string.message_loginIn);

        try
        {
            HttpURLConnection connection;

            final String memberName = mUsername.getText().toString();
            final String password   = mPassword.getText().toString();

            // Send the API request
            connection = Person.Api.signIn(memberName, password);
            ApiRequest.getJsonFromConnection(REQUEST_LOGIN, connection, new ApiRequest.ResponseHandler() {
                @Override
                public void handleResponse(int requestCode, JSONObject json, int responseCode)
                {
                    if (responseCode != HttpStatus.SC_OK || json == null)
                    {
                        // Treat a bad response code
                        int errorConnection = R.string.error_connection;

                        switch (responseCode)
                        {
                        // TODO treat other the responses
                        case HttpStatus.SC_UNAUTHORIZED:
                            // Bad credentials
                            errorConnection = R.string.error_login_badCredentials;
                            break;

                        case HttpStatus.SC_REQUEST_TIMEOUT:
                            // Time out
                            errorConnection = R.string.error_connection_timeout;
                            break;
                        }

                        Toast.makeText(LoginActivity.this, errorConnection, Toast.LENGTH_SHORT).show();
                    }
                    else if (LoginManager.getInstance(LoginActivity.this).signIn(Person.fromJson(json)))
                    {
                        // close the LoginActivity
                        finish();
                        // save the username
                        PreferenceManager.getDefaultSharedPreferences(LoginActivity.this).edit()
                                .putString(STATE_USERNAME, mUsername.getText().toString())
                                .commit();
                    }
                    else
                    {
                        // Notify the user about some internal error
                        Toast.makeText(LoginActivity.this, R.string.error_internal, Toast.LENGTH_SHORT).show();
                    }

                    progress.dismiss();
                    setUserInteractionEnabled(true);
                }
            });
        }
        catch (IOException e)
        {
            progress.dismiss();
            setUserInteractionEnabled(true);

            Log.e(InEvent.NAME, "Couldn't create a connection for login", e);
        }
    }


    private void setUserInteractionEnabled(boolean enabled)
    {
        // the text fields
        mUsername.setEnabled(enabled);
        mPassword.setEnabled(enabled);

        // the buttons
        findViewById(R.id.login_confirmButton).setEnabled(enabled);
    }
}
