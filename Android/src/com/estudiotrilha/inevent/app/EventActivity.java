package com.estudiotrilha.inevent.app;

import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.content.LoginManager;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuItem;


public class EventActivity extends ActionBarActivity
{
    private BroadcastReceiver mReceiver = new BroadcastReceiver() {
        public void onReceive(Context context, Intent intent)
        {
            String action = intent.getAction();
            if (LoginManager.ACTION_LOGIN_STATE_CHANGED.equals(action))
            {
                refreshLoginState();
            }
        }
    };

    private LoginManager mLoginManager;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_event);

        mLoginManager = LoginManager.getInstance(this);

        registerReceiver(mReceiver, new IntentFilter(LoginManager.ACTION_LOGIN_STATE_CHANGED));
    }
    @Override
    protected void onDestroy()
    {
        super.onDestroy();
        unregisterReceiver(mReceiver);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu)
    {
        getMenuInflater().inflate(R.menu.activity_event, menu);

        // Display the correct options in the menu
        boolean isSignedIn = mLoginManager.isSignedIn();
        menu.findItem(R.id.menu_signIn).setVisible(!isSignedIn);
        menu.findItem(R.id.menu_userAccount).setVisible(isSignedIn);

        return true;
    }
    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        switch (item.getItemId())
        {
        case R.id.menu_preferences:
            // Open the PreferencesActivity
            startActivity(new Intent(this, PreferencesActivity.class));
            return true;

        case R.id.menu_signIn:
            // Open the LoginActivity
            startActivity(new Intent(this, LoginActivity.class));
            return true;

        case R.id.menu_userAccount:
            // Open the UserSettingsActivity
            startActivity(new Intent(this, UserSettingsActivity.class));
            return true;
        }

        return super.onOptionsItemSelected(item);
    }


    private void refreshLoginState()
    {
        // Reload the option menu
        supportInvalidateOptionsMenu();
    }
}
