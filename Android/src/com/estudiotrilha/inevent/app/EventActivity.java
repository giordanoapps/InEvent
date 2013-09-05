package com.estudiotrilha.inevent.app;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.Menu;
import android.view.MenuItem;

import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.content.LoginManager;


public class EventActivity extends SlidingMenuBaseActivity
{
    // Extras
    private static final String EXTRA_EVENT_ID = "extra.EVENT_ID";


    public static Intent openEvent(Context c, long eventId)
    {
        Intent intent = new Intent(c, EventActivity.class);
        intent.putExtra(EXTRA_EVENT_ID, eventId);

        return intent;
    }


    private LoginManager mLoginManager;


    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_event);

        mLoginManager = LoginManager.getInstance(this);

        if (savedInstanceState == null)
        {
            // Event activities Fragment
            Fragment fragment = EventActivitiesListFragment.instantiate(getIntent().getLongExtra(EXTRA_EVENT_ID, -1));
            getSupportFragmentManager().beginTransaction()
                    .add(R.id.mainContent, fragment)
                    .commit();
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu)
    {
        getMenuInflater().inflate(R.menu.activity_event, menu);
        return true;
    }
    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        switch (item.getItemId())
        {
        case android.R.id.home:
            // Go home! Clear the back stack
            if (getSupportFragmentManager().getBackStackEntryCount() != 0)
            {
                while(getSupportFragmentManager().popBackStackImmediate());
                return true;
            }
            break;

        case R.id.menu_preferences:
            // Open the PreferencesActivity
            startActivity(new Intent(this, PreferencesActivity.class));
            return true;
        }

        return super.onOptionsItemSelected(item);
    }


    protected void refreshLoginState()
    {
        // Reload the option menu
        supportInvalidateOptionsMenu();
        if (!mLoginManager.isSignedIn())
        {
            // Open the Event Marketplace
            events(null);
        }
    }
}
