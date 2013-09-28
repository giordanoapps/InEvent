package com.estudiotrilha.inevent.app;


import java.io.IOException;
import java.net.HttpURLConnection;
import java.util.Arrays;
import java.util.List;

import org.apache.http.HttpStatus;
import org.json.JSONObject;

import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.estudiotrilha.android.app.ProgressDialogFragment;
import com.estudiotrilha.android.utils.FormUtils;
import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.Utils;
import com.estudiotrilha.inevent.content.ApiRequest;
import com.estudiotrilha.inevent.content.ApiRequestCode;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.content.Member;
import com.facebook.Session;
import com.facebook.SessionState;
import com.facebook.widget.LoginButton;
import com.google.analytics.tracking.android.EasyTracker;


public class LoginActivity extends ActionBarActivity implements ApiRequest.ResponseHandler, Session.StatusCallback
{
    // App State
    private static final String STATE_EMAIL = LoginActivity.class.getName()+".state.EMAIL";
    private static final String STATE_LOGIN = "state.LOGIN";

    // Permissions
    private static final List<String> FACEBOOK_PERMISSIONS = Arrays.asList("name", "email");


    private EditText    mEmail;
    private EditText    mPassword;
    private EditText    mConfirmPassword;
    private EditText    mName;
    private EditText    mUniversity;
    private EditText    mUniversityCourse;
    private LoginButton mFacebooButton;

    private ProgressDialogFragment mLoginProgressDialog;
    private int                    mScreenOrientation;


    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        // Saves the current orientation mode
        mScreenOrientation = getRequestedOrientation();

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


        mEmail = (EditText) findViewById(R.id.login_email);
        mPassword = (EditText) findViewById(R.id.login_password);
        mConfirmPassword = (EditText) findViewById(R.id.login_confirmPassword);
        mName = (EditText) findViewById(R.id.login_name);
        mUniversity = (EditText) findViewById(R.id.login_university);
        mUniversityCourse = (EditText) findViewById(R.id.login_university_course);
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

        if (savedInstanceState == null)
        {
            // recover last logged in username
            String username = PreferenceManager.getDefaultSharedPreferences(this).getString(STATE_EMAIL, "");
            mEmail.setText(username);
            
            switchMode(true, false);
        }
        else
        {
            switchMode(savedInstanceState.getBoolean(STATE_LOGIN), false);
        }
    }
    @Override
    public void onSaveInstanceState(Bundle outState)
    {
        super.onSaveInstanceState(outState);
        outState.putBoolean(STATE_LOGIN, !mConfirmPassword.isShown());
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
    public boolean onCreateOptionsMenu(Menu menu)
    {
        getMenuInflater().inflate(R.menu.activity_login, menu);

        // Set the proper action title
        int title = (mConfirmPassword.isShown() ? R.string.action_signIn : R.string.action_signUp);
        menu.findItem(R.id.menu_switchLoginMode).setTitle(title);

        return true;
    }
    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        switch(item.getItemId())
        {
        case android.R.id.home:
            finish();
            break;

        case R.id.menu_switchLoginMode:
            setUserInteractionEnabled(false);
            switchMode(mConfirmPassword.isShown());
            break;
        }

        return super.onOptionsItemSelected(item);
    }


    private void switchMode(boolean isLogin)
    {
        switchMode(isLogin, false);
    }
    private void switchMode(boolean isLogin, boolean animated)
    {
        int visibility;
        int title;
        int imeAction;

        if (isLogin)
        {
            title = R.string.title_login;
            visibility = View.GONE;

            imeAction = EditorInfo.IME_ACTION_DONE;
        }
        else
        {
            title = R.string.title_signUp;
            visibility = View.VISIBLE;

            imeAction = EditorInfo.IME_ACTION_NEXT;
        }

        mName.setVisibility(visibility);
        mUniversity.setVisibility(visibility);
        mUniversityCourse.setVisibility(visibility);
        mConfirmPassword.setVisibility(visibility);
        ((TextView) findViewById(R.id.login_title)).setText(title);
        ((Button) findViewById(R.id.login_confirmButton)).setText(title);

        mPassword.setImeOptions(imeAction);

        mPassword.setError(null);
        mPassword.setText(null);
        mConfirmPassword.setText(null);

        // give the user interaction back
        setUserInteractionEnabled(true);

        // Update the action bar menu
        supportInvalidateOptionsMenu();
    }

    private void loginAttempt()
    {
        if (mConfirmPassword.isShown())
        {
            // The user is creating a new register

            boolean cancel = false;

            // email validity check
            if (!FormUtils.isEmailValid(mEmail.getText().toString()))
            {
                mEmail.setError(getText(R.string.error_invalidEmail)); 
                cancel = true;
            }

            if (mName.getText().length() < 1)
            {
                mName.setError(getText(R.string.error_login_emptyField));
                cancel = true;
            }

            // password confirmation check
            if (!mPassword.getText().toString().equals(mConfirmPassword.getText().toString()))
            {
                mConfirmPassword.setError(getText(R.string.error_login_unmatchingPasswords));
                cancel = true;
            }

            if (cancel)
            {
                setUserInteractionEnabled(true);
                return;
            }
        }

        if (mPassword.getText().length() < 1)
        {
            mPassword.setError(getText(R.string.error_login_emptyField));
            return;
        }

        try
        {
            HttpURLConnection connection;

            final String email = mEmail.getText().toString();
            final String password = mPassword.getText().toString();

            
            // Send the API request
            if (mConfirmPassword.isShown())
            {
                connection = Member.Api.enroll();
                String post = Member.Api.Post.enroll(mName.getText().toString(), password, email, null, null, mUniversity.getText().toString(), mUniversityCourse.getText().toString());
                ApiRequest.getJsonFromConnection(ApiRequestCode.MEMBER_SIGN_UP, connection, LoginActivity.this, post);
            }
            else
            {
                connection = Member.Api.signIn(email, password);
                ApiRequest.getJsonFromConnection(ApiRequestCode.MEMBER_SIGN_IN, connection, this);
            }
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
        mConfirmPassword.setEnabled(enabled);
        mName.setEnabled(enabled);
        mUniversity.setEnabled(enabled);
        mUniversityCourse.setEnabled(enabled);
        mFacebooButton.setEnabled(enabled);

        // the buttons
        findViewById(R.id.login_confirmButton).setEnabled(enabled);

        if (enabled)
        {
            if (mLoginProgressDialog != null) mLoginProgressDialog.dismiss();
            unlockScreenOrientationChange();
        }
        else
        {
            lockScreenOrientationChange();
            // Setup the loading status
            mLoginProgressDialog = ProgressDialogFragment.instantiate(-1, R.string.loading_loggingIn);
            mLoginProgressDialog.show(getSupportFragmentManager(), null);
        }
    }

    private void lockScreenOrientationChange()
    {
        // Saves the current orientation mode
        mScreenOrientation = getRequestedOrientation();

        // Find out which orientation is going to be locked
        int orientation;
        switch(getResources().getConfiguration().orientation)
        {
        case Configuration.ORIENTATION_LANDSCAPE:
            orientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
            break;

        case Configuration.ORIENTATION_PORTRAIT:
            orientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT;
            break;

        default:
            orientation = mScreenOrientation;
        }
        // Locks the screen orientation
        setRequestedOrientation(orientation);
    }
    private void unlockScreenOrientationChange()
    {
        // Unlocks the screen orientation
        setRequestedOrientation(mScreenOrientation);
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
            case ApiRequestCode.MEMBER_SIGN_IN:
            case ApiRequestCode.MEMBER_SIGN_IN_WITH_FACEBOOK:
            case ApiRequestCode.MEMBER_SIGN_UP:
                // save the username
                PreferenceManager.getDefaultSharedPreferences(LoginActivity.this).edit()
                        .putString(STATE_EMAIL, mEmail.getText().toString())
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
                ApiRequest.getJsonFromConnection(ApiRequestCode.MEMBER_SIGN_IN_WITH_FACEBOOK, connection, LoginActivity.this);
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
