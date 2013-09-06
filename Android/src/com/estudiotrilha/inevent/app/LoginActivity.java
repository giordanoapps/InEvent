package com.estudiotrilha.inevent.app;


import java.io.IOException;
import java.net.HttpURLConnection;
import java.util.Arrays;
import java.util.List;

import org.apache.http.HttpStatus;
import org.json.JSONObject;

import android.content.Intent;
import android.content.pm.ActivityInfo;
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
import com.estudiotrilha.android.utils.FormUtils;
import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.Utils;
import com.estudiotrilha.inevent.content.ApiRequest;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.content.Member;
import com.facebook.Session;
import com.facebook.SessionState;
import com.facebook.widget.LoginButton;
import com.google.analytics.tracking.android.EasyTracker;


// TODO check for empty password
public class LoginActivity extends ActionBarActivity implements ApiRequest.ResponseHandler, Session.StatusCallback
{
    // App State
    private static final String STATE_USERNAME = LoginActivity.class.getName()+"state.USERNAME";

    // Permissions
    private static final List<String> FACEBOOK_PERMISSIONS = Arrays.asList("name", "email");


    private EditText    mEmail;
    private EditText    mPassword;
    private LoginButton mFacebooButton;

    private ProgressDialogFragment mLoginProgressDialog;


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
                if (FormUtils.isEmailValid(mEmail.getText().toString()))
                {
                    setUserInteractionEnabled(false);
                    loginAttempt();
                }
                else
                {
                    mEmail.setError(getText(R.string.error_invalidEmail));
                }
            }
        });


        mEmail = (EditText) findViewById(R.id.login_email);
        mPassword = (EditText) findViewById(R.id.login_password);

        if (savedInstanceState == null)
        {
            // recover last logged in username
            String username = PreferenceManager.getDefaultSharedPreferences(this).getString(STATE_USERNAME, "");
            mEmail.setText(username);
        }

        mFacebooButton = (LoginButton) findViewById(R.id.login_facebook);
        mFacebooButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v)
            {
                setUserInteractionEnabled(false);
                // Open the session
                Session.openActiveSession(LoginActivity.this, true, LoginActivity.this);
            }
        });
        mFacebooButton.setReadPermissions(FACEBOOK_PERMISSIONS);
    }
    @Override
    protected void onStart()
    {
        super.onStart();
        if (!InEvent.DEBUG)
        {
            EasyTracker.getInstance().activityStart(this);
        }
    }
    @Override
    protected void onStop()
    {
        super.onStop();
        if (!InEvent.DEBUG)
        {
            EasyTracker.getInstance().activityStop(this);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        super.onActivityResult(requestCode, resultCode, data);
        Session.getActiveSession().onActivityResult(this, requestCode, resultCode, data);
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
        try
        {
            HttpURLConnection connection;

            final String email = mEmail.getText().toString();
            final String password = mPassword.getText().toString();

            // Send the API request
            connection = Member.Api.signIn(email, password);
            ApiRequest.getJsonFromConnection(ApiRequest.RequestCodes.Member.SIGN_IN, connection, this);
        }
        catch (IOException e)
        {
            setUserInteractionEnabled(true);

            Log.e(InEvent.NAME, "Couldn't create a connection for login", e);

            // Notify the user about some internal error
            Toast.makeText(LoginActivity.this, R.string.error_internal, Toast.LENGTH_SHORT).show();
        }
    }


    private void setUserInteractionEnabled(boolean enabled)
    {
        // the text fields
        mEmail.setEnabled(enabled);
        mPassword.setEnabled(enabled);
        mFacebooButton.setEnabled(enabled);

        // the buttons
        findViewById(R.id.login_confirmButton).setEnabled(enabled);

        if (enabled)
        {
            // Unlock orientation change
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR);

            mLoginProgressDialog.dismiss();
        }
        else
        {
            // Lock orientation change
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_NOSENSOR);

            // Setup the loading status
            mLoginProgressDialog = ProgressDialogFragment.instantiate(-1, R.string.loading_loggingIn);
            mLoginProgressDialog.show(getSupportFragmentManager(), null);
        }
    }


    @Override
    public void handleResponse(int requestCode, JSONObject json, int responseCode)
    {
        if (responseCode != HttpStatus.SC_OK || json == null)
        {
            // Show the proper error message
            int errorMessage = Utils.getBadResponseMessage(requestCode, responseCode);
            Toast.makeText(LoginActivity.this, errorMessage, Toast.LENGTH_SHORT).show();
        }
        else if (LoginManager.getInstance(LoginActivity.this).signIn(Member.fromJson(json)))
        {
            switch (requestCode)
            {
            case ApiRequest.RequestCodes.Member.SIGN_IN:
            case ApiRequest.RequestCodes.Member.SIGN_IN_WITH_FACEBOOK:
                // save the username
                PreferenceManager.getDefaultSharedPreferences(LoginActivity.this).edit()
                        .putString(STATE_USERNAME, mEmail.getText().toString())
                        .commit();

                // close the LoginActivity
                finish();
                break;
            }
        }
        else
        {
            // Notify the user about some internal error
            Toast.makeText(LoginActivity.this, R.string.error_internal, Toast.LENGTH_SHORT).show();
        }

        setUserInteractionEnabled(true);
    }
    
    // Facebook callback when session changes state
    @Override
    public void call(Session session, SessionState state, Exception exception)
    {
        if (session.isOpened())
        {
            // Get the token
            String token = session.getAccessToken();

            // Close the connection to Facebook
            // this is done since the only information needed is the Facebook token
            session.closeAndClearTokenInformation();

            try
            {
                // Pass it on to our API
                HttpURLConnection connection = Member.Api.signInWithFacebook(token);
                ApiRequest.getJsonFromConnection(ApiRequest.RequestCodes.Member.SIGN_IN_WITH_FACEBOOK, connection, LoginActivity.this);
            }
            catch (IOException e)
            {
                setUserInteractionEnabled(true);
                Log.e(InEvent.NAME, "Couldn't create a connection for loginWithFacebook", e);

                // Notify the user about some internal error
                Toast.makeText(LoginActivity.this, R.string.error_internal, Toast.LENGTH_SHORT).show();
            }
        }
        else if (exception != null)
        {
            Log.e(InEvent.NAME, "Failed to connect with Facebook", exception);

            setUserInteractionEnabled(true);
        }
    }
}
