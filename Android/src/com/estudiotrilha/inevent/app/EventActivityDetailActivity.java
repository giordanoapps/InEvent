package com.estudiotrilha.inevent.app;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.text.DateFormat;
import java.util.Date;

import org.apache.http.HttpStatus;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.BroadcastReceiver;
import android.content.ContentUris;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.LoaderManager.LoaderCallbacks;
import android.support.v4.content.CursorLoader;
import android.support.v4.content.Loader;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.widget.RatingBar;
import android.widget.TextView;
import android.widget.Toast;

import com.estudiotrilha.android.utils.DateUtils;
import com.estudiotrilha.android.utils.JsonUtils;
import com.estudiotrilha.android.widget.TriangleView;
import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.Utils;
import com.estudiotrilha.inevent.content.Activity;
import com.estudiotrilha.inevent.content.ActivityMember;
import com.estudiotrilha.inevent.content.ApiRequest;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.content.SyncBroadcastManager;


public class EventActivityDetailActivity extends ActionBarActivity implements LoaderCallbacks<Cursor>
{
    // Request codes
    private static final int REQUEST_SEND_OPINION = 0;
    private static final int REQUEST_GET_OPINION  = 1;

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
    private DateFormat mTimeFormat;
    private LoginManager mLoginManager;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        supportRequestWindowFeature(Window.FEATURE_INDETERMINATE_PROGRESS);
        setContentView(R.layout.activity_event_activity_detail);
        mLoginManager = LoginManager.getInstance(this);

        // Show the Up button in the action bar.
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        findViewById(R.id.activity_rating).setOnTouchListener(new View.OnTouchListener() {

            boolean mDown = false;

            @Override
            public boolean onTouch(View v, MotionEvent event)
            {
                switch (event.getAction())
                {
                case MotionEvent.ACTION_DOWN:
                    mDown = true;
                    break;
                case MotionEvent.ACTION_UP:
                    if (mDown)
                    {
                        DialogFragment dialog = ActivityRatingFragmentDialog.instantiate();
                        dialog.show(getSupportFragmentManager(), null);
                    }
                case MotionEvent.ACTION_CANCEL:
                    mDown = false;
                    break;
                }
                return true;
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
    }
    @Override
    protected void onStop()
    {
        super.onStop();
        // unregister listeners
        unregisterReceiver(mReceiver);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu)
    {
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


    private void updateRating()
    {
        SyncBroadcastManager.setSyncState(this, "Syncing rating");
        String tokenID = mLoginManager.getTokenId();

        long activityID = getIntent().getLongExtra(EXTRA_ACTIVITY_ID, -1);
        try
        {
            // Prepare the connection
            HttpURLConnection connection = Activity.Api.getOpinion(tokenID, activityID);

            ApiRequest.getJsonFromConnection(REQUEST_GET_OPINION, connection, new ApiRequest.ResponseHandler() {
                @Override
                public void handleResponse(int requestCode, JSONObject json, int responseCode)
                {
                    if (responseCode == HttpStatus.SC_OK && json != null)
                    {
                        try
                        {
                            // All done!
                            // update the display
                            json = json.getJSONArray(JsonUtils.DATA).getJSONObject(0);
                            int rating = json.getInt("rating");
                            ((RatingBar) findViewById(R.id.activity_rating)).setRating(rating);
                        }
                        catch (JSONException e)
                        {
                            // TODO
                        }
                    }

                    SyncBroadcastManager.setSyncState(EventActivityDetailActivity.this, false);
                }
            });
        }
        catch (IOException e)
        {
            // TODO
            SyncBroadcastManager.setSyncState(this, false);
        }
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

            if (mLoginManager.isSignedIn())
            {
                int approved = data.getInt(data.getColumnIndex(ActivityMember.Columns.APPROVED));
                View ratingBar = findViewById(R.id.activity_rating);
                int color = 0;
                switch (approved)
                {
                case -1:
                    color = getResources().getColor(R.color.light_gray);
                    ratingBar.setVisibility(View.GONE);
                    break;
                case 0:
                    color = getResources().getColor(R.color.holo_red_dark);
                    ratingBar.setVisibility(View.GONE);
                    break;
                case 1:
                    color = getResources().getColor(R.color.holo_green_dark);
                    // Load up the rating
                    updateRating();
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
                ApiRequest.getJsonFromConnection(REQUEST_SEND_OPINION, connection, new ApiRequest.ResponseHandler() {
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
