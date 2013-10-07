package com.estudiotrilha.inevent.app;

import java.util.Calendar;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.preference.PreferenceManager;

import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.content.ApiRequest;
import com.estudiotrilha.inevent.service.UploaderService;
import com.google.analytics.tracking.android.EasyTracker;
import com.parse.Parse;
import com.parse.ParseInstallation;
import com.parse.PushService;


public class SplashActivity extends Activity implements Runnable
{
    private static int SPLASH_DURATION           = 800; // in milliseconds
    private static int SPLASH_REDISPLAY_INTERVAL = 7; // in days

    private final Handler mHandler = new Handler();

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);

        if (savedInstanceState == null)
        {
            ApiRequest.init(getApplicationContext());
            // Sync up!
            UploaderService.sync(this);

            // XXX
//            // Initialize parse
//            Parse.initialize(this, getString(R.string.parse_app_id), getString(R.string.parse_client_key));
//            // Setup the push notification configs
//            PushService.setDefaultPushCallback(this, SplashActivity.class, R.drawable.ic_stat_notification_general);
//            ParseInstallation.getCurrentInstallation().saveInBackground();
        }
    }

    @Override
    protected void onStart()
    {
        super.onStart();
        if (!InEvent.DEBUG)
        {
            EasyTracker.getInstance().activityStart(this);
        }

        // set the transition animation
        overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);

        // Obtain the sharedPreference
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);

        // Check if the splash screen should be shown
        Calendar lastShownTime = Calendar.getInstance();
        lastShownTime.setTimeInMillis(preferences.getLong(PreferencesActivity.SPLASH_LAST_SHOWN, 0));
        lastShownTime.add(Calendar.DAY_OF_YEAR, SPLASH_REDISPLAY_INTERVAL);

        Calendar currentTime = Calendar.getInstance();

        // Only shown the splash screen if the user hasn't
        // opened the app in a while
        if (lastShownTime.before(currentTime))
        {
            // XXX Start the animation
            mHandler.postDelayed(this, SPLASH_DURATION);
        }
        else
        {
            onSplashFinish();
        }

        // Update the splash last shown time
        preferences.edit()
            .putLong(PreferencesActivity.SPLASH_LAST_SHOWN, currentTime.getTimeInMillis())
            .commit();
    }
    @Override
    protected void onStop()
    {
        super.onStop();
        if (!InEvent.DEBUG)
        {
            EasyTracker.getInstance().activityStop(this);
        }

        // if stopped by the user, it won't open the other activity
        mHandler.removeCallbacks(this);
    }


    private void onSplashFinish()
    {
        // finish the splash activity
        finish();

        // set the transition animation
        overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);

        // Open the Event Marketplace
        startActivity(new Intent(this, EventMarketplaceActivity.class));
    }


    @Override
    public void run()
    {
        onSplashFinish();
    }
}
