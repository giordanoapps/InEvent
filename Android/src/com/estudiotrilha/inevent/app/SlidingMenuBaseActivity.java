package com.estudiotrilha.inevent.app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Configuration;
import android.os.Bundle;
import android.support.v4.app.ActionBarDrawerToggle;
import android.support.v4.app.FragmentManager;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarActivity;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewStub;
import android.view.Window;
import android.widget.ImageView;
import android.widget.TextView;

import com.estudiotrilha.android.widget.ViewToastManager;
import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.Utils;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.content.Member;
import com.estudiotrilha.inevent.content.SyncBroadcastManager;
import com.google.analytics.tracking.android.EasyTracker;


public abstract class SlidingMenuBaseActivity extends ActionBarActivity
{
    private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent)
        {
            String action = intent.getAction();
            if (action.equals(SyncBroadcastManager.ACTION_SYNC))
            {
                setSupportProgressBarIndeterminateVisibility(SyncBroadcastManager.isSyncing());
            }
            else if (action.equals(LoginManager.ACTION_LOGIN_STATE_CHANGED))
            {
                setupLoginInfo();
                refreshLoginState();
            }
            else if (action.equals(InEvent.ACTION_TOAST_NOTIFICATION))
            {
                // get the message
                int message = intent.getIntExtra(InEvent.EXTRA_TOAST_MESSAGE, 0);
                if (message <= 0) return;

                // display the notification toast
                showToast(message);
            }
        }
    };

    private ActionBarDrawerToggle mDrawerToggle;
    private DrawerLayout          mDrawerLayout;
    private View                  mSlidingMenu;

    private ViewToastManager mToastManager;


    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        // prepare the content view
        super.onCreate(savedInstanceState);
        supportRequestWindowFeature(Window.FEATURE_INDETERMINATE_PROGRESS);

        // start ImageLoader
        Utils.initImageLoader(this);

        // Prepare the sliding menu
        super.setContentView(R.layout.activity_sliding_menu);
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

        // set the sync status
        setSupportProgressBarIndeterminateVisibility(SyncBroadcastManager.isSyncing());

        // creates and setups the toast manager
        mToastManager = new ViewToastManager(this, (ViewGroup) findViewById(R.id.main_toastMessage));
        // Set the enter and leave animations for the custom toast
        mToastManager.setEnterAnimationResource(R.anim.toast_enter);
        mToastManager.setLeaveAnimationResource(R.anim.toast_leave);
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
        if (!InEvent.DEBUG)
        {
            EasyTracker.getInstance().activityStart(this);
        }

        setupLoginInfo();
    }
    @Override
    protected void onResume()
    {
        super.onResume();
        // register a broadcast
        IntentFilter filter = new IntentFilter(SyncBroadcastManager.ACTION_SYNC);
        filter.addAction(LoginManager.ACTION_LOGIN_STATE_CHANGED);
        filter.addAction(InEvent.ACTION_TOAST_NOTIFICATION);
        registerReceiver(mReceiver, filter);
    }
    @Override
    protected void onPause()
    {
        super.onPause();
        // unregister listeners
        unregisterReceiver(mReceiver);
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
    public boolean onOptionsItemSelected(MenuItem item)
    {
        if (item.getItemId() == android.R.id.home)
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

    @Override
    public void setContentView(int layoutResId)
    {
        ViewStub viewStub = (ViewStub) findViewById(R.id.contentStub);
        viewStub.setLayoutResource(layoutResId);
        viewStub.inflate();
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


    // Custom toast
    public void showToast(CharSequence text, int duration)
    {
        showToast(text, -1, duration);
    }
    public void showToast(int text, int duration)
    {
        showToast(getText(text), duration);
    }
    public void showToast(int text)
    {
        showToast(text, ViewToastManager.LENGHT_SHORT);
    }
    public void showToast(CharSequence text, int image, int duration)
    {
        View v = getLayoutInflater().inflate(R.layout.toast_notification, null);
        ((TextView) v.findViewById(R.id.notificatoin_text)).setText(text);
        if (image > 0) ((ImageView) v.findViewById(R.id.notificatoin_image)).setImageResource(image);

        mToastManager.newMessage(v, duration);
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

        // Opens the Event Marketplace
        startActivity(new Intent(this, EventMarketplaceActivity.class));
    }
    public void about(View v)
    {
        Intent intent = new Intent(this, AboutActivity.class);
        startActivity(intent);
    }


    /** Refresh the activity state according to a new login state */
    protected abstract void refreshLoginState();
}
