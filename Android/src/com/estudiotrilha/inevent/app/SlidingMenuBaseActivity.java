package com.estudiotrilha.inevent.app;

import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.app.ActionBarDrawerToggle;
import android.support.v4.app.FragmentManager;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;

import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.app.EventActivitiesPagesFragment.DisplayOption;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.content.Member;


public abstract class SlidingMenuBaseActivity extends BaseActivity
{
    private ActionBarDrawerToggle mDrawerToggle;
    private DrawerLayout          mDrawerLayout;
    private View                  mSlidingMenu;


    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        // prepare the content view
        super.onCreate(savedInstanceState);

        // Prepare the sliding menu
        originalSetContentView(R.layout.activity_sliding_menu);
        mDrawerLayout = (DrawerLayout) findViewById(R.id.drawerLayout);
        mDrawerLayout.setDrawerShadow(R.drawable.drawer_shadow, GravityCompat.START);
        // ActionBarDrawerToggle ties together the the proper interactions
        // between the sliding drawer and the action bar app icon
        mDrawerToggle = new ActionBarDrawerToggle(this, mDrawerLayout, R.drawable.ic_navigation_drawer,
                R.string.description_slidingMenu_open, R.string.description_slidingMenu_close) {
            @Override
            public void onDrawerOpened(View drawerView)
            {
                super.onDrawerOpened(drawerView);
                supportInvalidateOptionsMenu();
            }
            @Override
            public void onDrawerClosed(View drawerView)
            {
                super.onDrawerClosed(drawerView);
                supportInvalidateOptionsMenu();
            }
        };
        mDrawerLayout.setDrawerListener(mDrawerToggle);

        mSlidingMenu = findViewById(R.id.slidingMenu);

        // enable ActionBar app icon to behave as action to toggle the sliding menu
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setHomeButtonEnabled(true);

        // adds a listener to properly change the drawer icon, and set it
        mDrawerToggle.setDrawerIndicatorEnabled(getSupportFragmentManager().getBackStackEntryCount() == 0);
        getSupportFragmentManager().addOnBackStackChangedListener(new FragmentManager.OnBackStackChangedListener() {
                @Override
                public void onBackStackChanged()
                {
                    mDrawerToggle.setDrawerIndicatorEnabled(getSupportFragmentManager().getBackStackEntryCount() == 0);
                }
        });
    }
    @Override
    protected void onPostCreate(Bundle savedInstanceState)
    {
        super.onPostCreate(savedInstanceState);
        mDrawerToggle.syncState();
    }
    @Override
    protected void onStart()
    {
        super.onStart();
        setupLoginInfo();
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        if (item.getItemId() == android.R.id.home &&
                getSupportFragmentManager().getBackStackEntryCount() == 0)
        {
            if (isSlidingMenuOpen())
            {
                closeSlidingMenu();
            }
            else
            {
                openSlidingMenu();
            }
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig)
    {
        super.onConfigurationChanged(newConfig);
        mDrawerToggle.onConfigurationChanged(newConfig);
    }

    protected boolean isSlidingMenuOpen()
    {
        return mDrawerLayout.isDrawerOpen(mSlidingMenu);
    }
    protected void openSlidingMenu()
    {
        mDrawerLayout.openDrawer(mSlidingMenu);
    }
    protected void closeSlidingMenu()
    {
        mDrawerLayout.closeDrawer(mSlidingMenu);
    }


    private void setupLoginInfo()
    {
        LoginManager loginManager = LoginManager.getInstance(this);

        // Clear up the previous data
        if (loginManager.isSignedIn())
        {
            Member member = loginManager.getMember();
            ((TextView) findViewById(R.id.slidingMenu_user)).setText(member.name);
        }
        else
        {
            ((TextView) findViewById(R.id.slidingMenu_user)).setText(R.string.slidingMenu_login);
        }
    }


    // SlidingMenu options
    public void user(View v)
    {
        LoginManager loginManager = LoginManager.getInstance(this);

        // check the user login status
        if (loginManager.isSignedIn())
        {
            // The user is logged in
            // Open his prefs screens
            startActivity(new Intent(this, UserSettingsActivity.class));
        }
        else
        {
            // open the user login activity
            startActivity(new Intent(this, LoginActivity.class));
        }
    }
    public void events(View v)
    {
        closeSlidingMenu();

        // Closes the current Activity
        finish();
        overridePendingTransition(0, 0);

        // Unselect the event
        PreferenceManager.getDefaultSharedPreferences(this)
            .edit()
            .putLong(PreferencesActivity.EVENT_SELECTED, -1)
            .putInt(PreferencesActivity.DISPLAY_OPTION_ACTIVITIES, DisplayOption.ALL.ordinal())
            .commit();

        // Opens the Event Marketplace
        startActivity(new Intent(this, EventMarketplaceActivity.class));
    }


    @Override
    protected void refreshLoginState()
    {
        setupLoginInfo();
    }
}
