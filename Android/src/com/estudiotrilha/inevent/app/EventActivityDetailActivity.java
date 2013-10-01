package com.estudiotrilha.inevent.app;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.text.DateFormat;
import java.util.Date;

import org.apache.http.HttpStatus;
import org.json.JSONObject;

import android.content.BroadcastReceiver;
import android.content.ContentUris;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.database.ContentObserver;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.LoaderManager.LoaderCallbacks;
import android.support.v4.content.CursorLoader;
import android.support.v4.content.Loader;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.widget.RatingBar;
import android.widget.TextView;
import android.widget.Toast;

import com.estudiotrilha.android.utils.DateUtils;
import com.estudiotrilha.android.widget.TriangleView;
import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.Utils;
import com.estudiotrilha.inevent.content.Activity;
import com.estudiotrilha.inevent.content.ActivityMember;
import com.estudiotrilha.inevent.content.ApiRequest;
import com.estudiotrilha.inevent.content.ApiRequestCode;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.content.Feedback;
import com.estudiotrilha.inevent.content.SyncBroadcastManager;
import com.estudiotrilha.inevent.service.DownloaderService;


public class EventActivityDetailActivity extends ActionBarActivity implements LoaderCallbacks<Cursor>
{
    private static final int APPROVED_OK        =  1;
    private static final int APPROVED_WAIT_LIST =  0;
    private static final int APPROVED_NOT       = -1;


    // Extras
    private static final String EXTRA_ACTIVITY_ID = "extra.ACTIVITY_ID";

    public static Intent newInstance(Context context, long activityID)
    {
        Intent intent = new Intent(context, EventActivityDetailActivity.class);
        intent.putExtra(EXTRA_ACTIVITY_ID, activityID);

        return intent;
    }

    // Loader codes
    private static final int LOAD_ACTIVITY = 0;


    private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent)
        {
            if (SyncBroadcastManager.ACTION_SYNC.equals(intent.getAction()))
            {
                setSupportProgressBarIndeterminateVisibility(SyncBroadcastManager.isSyncing());
            }
        }
    };
    private final ContentObserver   mContentObserver = new ContentObserver(new Handler()) {
        @Override
        public void onChange(boolean selfChange)
        {
            super.onChange(selfChange);
            getSupportLoaderManager().restartLoader(LOAD_ACTIVITY, null, EventActivityDetailActivity.this);
        }
    };

    private DateFormat   mTimeFormat;
    private LoginManager mLoginManager;


    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        supportRequestWindowFeature(Window.FEATURE_INDETERMINATE_PROGRESS);
        setContentView(R.layout.activity_event_activity_detail);
        mLoginManager = LoginManager.getInstance(this);
        if (savedInstanceState == null)
        {
            refresh();
        }

        // Show the Up button in the action bar.
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        findViewById(R.id.activity_ratingContainer).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v)
            {
                DialogFragment dialog = ActivityRatingFragmentDialog.instantiate();
                dialog.show(getSupportFragmentManager(), null);
            }
        });

        mTimeFormat = android.text.format.DateFormat.getTimeFormat(this);
    }
    @Override
    protected void onStart()
    {
        super.onStart();
        getSupportLoaderManager().initLoader(LOAD_ACTIVITY, null, this);
        // register a broadcast
        registerReceiver(mReceiver, new IntentFilter(SyncBroadcastManager.ACTION_SYNC));
        // and an observer
        getContentResolver().registerContentObserver(Feedback.CONTENT_URI, true, mContentObserver);
    }
    @Override
    protected void onStop()
    {
        super.onStop();
        // unregister listeners
        unregisterReceiver(mReceiver);
        // and the observer
        getContentResolver().unregisterContentObserver(mContentObserver);
    }
    @Override
    protected void onResume()
    {
        super.onResume();
        // Setup the loading status
        setSupportProgressBarIndeterminateVisibility(SyncBroadcastManager.isSyncing());
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu)
    {
        // TODO add more options here
        getMenuInflater().inflate(R.menu.event_activity_detail, menu);
        return true;
    }
    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        switch (item.getItemId())
        {
        case android.R.id.home:
            // Navigate up one level in the application structure
            finish();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }


    private void refresh()
    {
        DownloaderService.downloadEventActivityRating(this, getIntent().getLongExtra(EXTRA_ACTIVITY_ID, -1));
    }


    @Override
    public Loader<Cursor> onCreateLoader(int code, Bundle args)
    {
        Uri uri = ContentUris.withAppendedId(Activity.CONTENT_URI, getIntent().getLongExtra(EXTRA_ACTIVITY_ID, -1));
        String[] projection = Activity.Columns.PROJECTION_DETAIL;
        String selection = null;
        String[] selectionArgs = null;
        String sortOrder = null;

        return new CursorLoader(this, uri, projection, selection, selectionArgs, sortOrder);
    }
    @Override
    public void onLoadFinished(Loader<Cursor> loader, Cursor data)
    {
        if (data.moveToFirst())
        {
            ((TextView) findViewById(R.id.activity_name)).setText(data.getString(data.getColumnIndex(Activity.Columns.NAME)));
            ((TextView) findViewById(R.id.activity_description)).setText(data.getString(data.getColumnIndex(Activity.Columns.DESCRIPTION)));

            Date dateBegin = DateUtils.calendarFromTimestampInGMT(data.getLong(data.getColumnIndex(Activity.Columns.DATE_BEGIN))).getTime();
            Date dateEnd = DateUtils.calendarFromTimestampInGMT(data.getLong(data.getColumnIndex(Activity.Columns.DATE_END))).getTime();
            String location = data.getString(data.getColumnIndex(Activity.Columns.LOCATION));
            String dateLocation = mTimeFormat.format(dateBegin)+" - "+mTimeFormat.format(dateEnd)+" "+location;

            ((TextView) findViewById(R.id.activity_location)).setText(dateLocation);

            RatingBar ratingBar = (RatingBar) findViewById(R.id.activity_rating);
            ratingBar.setRating(data.getInt(data.getColumnIndex(ActivityMember.Columns.APPROVED)));
            ratingBar.setVisibility(View.GONE);

            if (mLoginManager.isSignedIn())
            {
                int approved = data.getInt(data.getColumnIndex(ActivityMember.Columns.APPROVED));
                int color = 0;
                switch (approved)
                {
                // Not enrolled
                case APPROVED_NOT:
                    color = getResources().getColor(R.color.light_gray);
                    break;
                // Waiting list
                case APPROVED_WAIT_LIST:
                    color = getResources().getColor(R.color.holo_red_dark);
                    break;
                // enrolled
                case APPROVED_OK:
                    color = getResources().getColor(R.color.holo_green_dark);
                    ratingBar.setVisibility(View.VISIBLE);
                    break;
                }

                ((TriangleView) findViewById(R.id.activity_approved)).setFillColor(color);
            }
        }
        else
        {
            // Empty!
            // TODO
        }
    }
    @Override public void onLoaderReset(Loader<Cursor> loader) {}


    public static class ActivityRatingFragmentDialog extends RatingDialogFragment
    {
        public static ActivityRatingFragmentDialog instantiate()
        {
            ActivityRatingFragmentDialog fragment = new ActivityRatingFragmentDialog();

            return fragment;
        }


        protected int getTitle()
        {
            return R.string.title_rate_activity;
        }
        protected void onSendOpinion()
        {
            // Prepare the parameters
            final EventActivityDetailActivity activity = (EventActivityDetailActivity) getActivity();
            String tokenID = LoginManager.getInstance(activity).getTokenId();
            long activityID = activity.getIntent().getLongExtra(EXTRA_ACTIVITY_ID, -1);
            final int rating = (int) getRatingBar().getRating();
            try
            {
                // TODO Show loading stats
                SyncBroadcastManager.setSyncState(activity, "Sending opinion");

                // Create the connection
                HttpURLConnection connection = Activity.Api.sendOpinion(tokenID, activityID);
                String post = Activity.Api.Post.sendOpinion(rating);

                // Send the API request
                ApiRequest.getJsonFromConnection(ApiRequestCode.ACTIVITY_SEND_OPINION, connection, new ApiRequest.ResponseHandler() {
                    @Override
                    public void handleResponse(int requestCode, JSONObject json, int responseCode)
                    {
                        if (responseCode == HttpStatus.SC_OK && json != null)
                        {
                            // All done!
                            // update the display
                            ((RatingBar) activity.findViewById(R.id.activity_rating)).setRating(rating);
                        }
                        else
                        {
                            // TODO
                            Toast.makeText(activity, Utils.getBadResponseMessage(-1, responseCode), Toast.LENGTH_SHORT).show();
                        }

                        SyncBroadcastManager.setSyncState(activity, false);
                    }
                }, post);
            }
            catch (IOException e)
            {
                // TODO
                Log.e(InEvent.NAME, "Error creating connection for activity.sendOpinion(tokenID, activityID="+activityID+", rating="+rating+")");

                SyncBroadcastManager.setSyncState(activity, false);
            }
        }
    }
}
