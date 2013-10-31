package com.estudiotrilha.inevent.app;

import java.util.Calendar;

import org.apache.http.HttpHost;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.util.Log;

import com.estudiotrilha.android.utils.JsonUtils;
import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.content.ApiRequest;
import com.estudiotrilha.inevent.content.Event;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.content.Member;
import com.estudiotrilha.inevent.service.DownloaderService;
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
    private boolean       mReady   = false;


    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);

        if (savedInstanceState == null)
        {
            ApiRequest.init(getApplicationContext());
            // Make sure the events are updated
            DownloaderService.downloadEvents(this);
            // Sync up!
            UploaderService.sync(this);

            // XXX
//            // Initialize parse
//            Parse.initialize(this, getString(R.string.parse_app_id), getString(R.string.parse_client_key));
//            // Setup the push notification configs
//            PushService.setDefaultPushCallback(this, SplashActivity.class, R.drawable.ic_stat_notification_general);
//            ParseInstallation.getCurrentInstallation().saveInBackground();

            // Parse intent information if necessary
            AsyncTask<Void,Void,Void> task = new AsyncTask<Void, Void, Void>() {
                @Override
                protected Void doInBackground(Void... params)
                {
                    analyzeIntent();
                    mReady = true;
                    return null;
                }
            };
            task.execute();
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
            run();
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

    @Override
    protected void onPause()
    {
        super.onPause();
    }

    private void onSplashFinish()
    {
        // finish the splash activity
        finish();

        // set the transition animation
        overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);

        // Obtain the sharedPreference
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);
        long selectedEvent = preferences.getLong(PreferencesActivity.EVENT_SELECTED, -1);

        if (selectedEvent != -1)
        {
            // Open the event
            Intent event = EventActivity.openEvent(this, selectedEvent);
            startActivity(event);
        }
        else
        {
            // Open the Event Marketplace
            startActivity(new Intent(this, EventMarketplaceActivity.class));            
        }
    }


    @Override
    public void run()
    {
        AsyncTask<Void,Void,Void> task = new AsyncTask<Void, Void, Void>() {
            @Override
            protected Void doInBackground(Void... params)
            {
                // Just wait!
                while (!mReady);
                return null;
            }
            @Override
            protected void onPostExecute(Void result)
            {
                super.onPostExecute(result);
                onSplashFinish();
            }
        };
        task.execute();
    }


    private void analyzeIntent()
    {
        Intent intent = getIntent();
        System.out.println(intent);
        if (Intent.ACTION_VIEW.equals(intent.getAction()) &&
                getIntent().getCategories().contains(Intent.CATEGORY_BROWSABLE))
        {
            // Obtain the sharedPreference
            SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);

            // Then we are treating a special link
            Uri uri = getIntent().getData();
            String scheme = uri.getScheme();
            if (InEvent.SCHEME_IN_EVENT.equals(scheme))
            {
                // TODO
                System.out.println("URI: "+uri);
            }
            else if (HttpHost.DEFAULT_SCHEME_NAME.equals(scheme))
            {
                // get the nickname
                String path = uri.getPathSegments().get(0);

                if (path.startsWith("appURL.php"))
                {
                    try
                    {
                        long eventID = Long.parseLong(uri.getQueryParameter("eventID"));
    
                        long memberId = Long.parseLong(uri.getQueryParameter("memberID"));
                        String name = uri.getQueryParameter("name");
                        String tokenId = uri.getQueryParameter("tokenID");

                        Member member = new Member(memberId, name, tokenId);
                        LoginManager.getInstance(this).signIn(member);

                        preferences.edit()
                                .putLong(PreferencesActivity.EVENT_SELECTED, eventID)
                                .commit();
                        
                        return;
                    }
                    catch (UnsupportedOperationException e)
                    {
                        Log.w(InEvent.NAME, "Could parse query parameters", e);
                    }
                }

                final String[] projection = new String[] { Event.Columns._ID_FULL };
                final String selection = Event.Columns.NICKNAME_FULL+"=?";
                final String[] selectionArgs = new String[1];
                selectionArgs[0] = path;

                Cursor c = getContentResolver().query(Event.CONTENT_URI, projection, selection, selectionArgs, null);
                if (c.getCount() == 1)
                {
                    long eventID = c.getLong(0);
                    preferences.edit()
                            .putLong(PreferencesActivity.EVENT_SELECTED, eventID)
                            .commit();
                }
            }
        }
    }
}
