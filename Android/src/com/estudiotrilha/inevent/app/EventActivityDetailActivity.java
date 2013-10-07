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
import android.content.ContentValues;
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
import android.widget.ViewAnimator;

import com.estudiotrilha.android.content.ApiRequest.ResponseHandler;
import com.estudiotrilha.android.utils.DateUtils;
import com.estudiotrilha.android.utils.JsonUtils;
import com.estudiotrilha.android.widget.TriangleView;
import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.Utils;
import com.estudiotrilha.inevent.content.Activity;
import com.estudiotrilha.inevent.content.ActivityMember;
import com.estudiotrilha.inevent.content.ApiRequest;
import com.estudiotrilha.inevent.content.ApiRequestCode;
import com.estudiotrilha.inevent.content.Event;
import com.estudiotrilha.inevent.content.Feedback;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.content.SyncBroadcastManager;
import com.estudiotrilha.inevent.service.DownloaderService;
import com.estudiotrilha.inevent.service.UploaderService;
import com.google.analytics.tracking.android.EasyTracker;


public class EventActivityDetailActivity extends ActionBarActivity implements LoaderCallbacks<Cursor>, ResponseHandler
{
    private static final int APPROVED_OK        =  1;
    private static final int APPROVED_WAIT_LIST =  0;
    private static final int APPROVED_NOT       = -1;


    // Extras
    private static final String EXTRA_EVENT_ID       = "extra.EVENT_ID";
    private static final String EXTRA_ACTIVITY_ID    = "extra.ACTIVITY_ID";
    private static final String EXTRA_EVENT_APPROVED = "extra.EVENT_APPROVED";
    private static final String EXTRA_EVENT_ROLE_ID  = "extra.EVENT_ROLE_ID";

    public static Intent newInstance(Context context, long activityID, long eventID, boolean eventApproved, int eventRoleId)
    {
        Intent intent = new Intent(context, EventActivityDetailActivity.class);
        intent.putExtra(EXTRA_ACTIVITY_ID, activityID);
        intent.putExtra(EXTRA_EVENT_ID, eventID);
        intent.putExtra(EXTRA_EVENT_APPROVED, eventApproved);
        intent.putExtra(EXTRA_EVENT_ROLE_ID, eventRoleId);

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

    private DateFormat         mTimeFormat;
    private LoginManager       mLoginManager;
    private ActivityInfoHolder mInfo = new ActivityInfoHolder();


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
        getContentResolver().registerContentObserver(ActivityMember.CONTENT_URI, true, mContentObserver);
        // Analytics stuff
        if (!InEvent.DEBUG)
        {
            EasyTracker.getInstance().activityStart(this);
        }
    }
    @Override
    protected void onStop()
    {
        super.onStop();
        // unregister listeners
        unregisterReceiver(mReceiver);
        // and the observer
        getContentResolver().unregisterContentObserver(mContentObserver);
        // Analytics stuff
        if (!InEvent.DEBUG)
        {
            EasyTracker.getInstance().activityStop(this);
        }
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
        getMenuInflater().inflate(R.menu.activity_event_activity_detail, menu);
        if (mLoginManager.isSignedIn())
        {
            boolean eventApproval = getIntent().getBooleanExtra(EXTRA_EVENT_APPROVED, false);
            switch (mInfo.approved)
            {
            case APPROVED_OK:
                menu.findItem(R.id.action_eventActivity_unenroll).setVisible(eventApproval);            
                break;

            case APPROVED_NOT:
                menu.findItem(R.id.action_eventActivity_enroll).setVisible(eventApproval);
                break;
            }

            if (eventApproval && getIntent().getIntExtra(EXTRA_EVENT_ROLE_ID, Event.ROLE_ATTENDEE) != Event.ROLE_ATTENDEE)
            {
                menu.findItem(R.id.action_eventActivity_managePeople).setVisible(true);
            }
        }
        return true;
    }
    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        long activityID = getIntent().getLongExtra(EXTRA_ACTIVITY_ID, -1);
        switch (item.getItemId())
        {
        case android.R.id.home:
            // Navigate up one level in the application structure
            finish();
            return true;

        case R.id.action_location:
            // Show the map
            LocationMapFragment fragment = LocationMapFragment.instantiate(mInfo.location, mInfo.latitude, mInfo.longitude);
            getSupportFragmentManager().beginTransaction()
                .add(R.id.mainContent, fragment)
                .addToBackStack(null)
                .commit();
            return true;

        case R.id.action_eventActivity_enroll:
            item.setVisible(false);
            try
            {
                HttpURLConnection connection = Activity.Api.requestEnrollment(mLoginManager.getTokenId(), activityID);
                ApiRequest.getJsonFromConnection(ApiRequestCode.ACTIVITY_REQUEST_ENROLLMENT, connection, this);
                SyncBroadcastManager.setSyncState(this, "Enrolling...");
            }
            catch (IOException e)
            {
                Log.e(InEvent.NAME, "Could not create connection for activity.requestEnrollment(tokenId, activityID="+activityID+")", e);
            }
            return true;

        case R.id.action_eventActivity_unenroll:
            item.setVisible(false);
            try
            {
                HttpURLConnection connection = Activity.Api.dismissEnrollment(mLoginManager.getTokenId(), activityID);
                ApiRequest.getJsonFromConnection(ApiRequestCode.ACTIVITY_DISMISS_ENROLLMENT, connection, this);
                SyncBroadcastManager.setSyncState(this, "Unenrolling...");
            }
            catch (IOException e)
            {
                Log.e(InEvent.NAME, "Could not create connection for activity.dismissEnrollment(tokenId, activityID="+activityID+")", e);
            }
            return true;

        case R.id.action_eventActivity_managePeople:
            // Open up the attendance control
            getSupportFragmentManager().beginTransaction()
                    .add(R.id.mainContent, AttendanceFragment.instantiate(getIntent().getLongExtra(EXTRA_ACTIVITY_ID, -1), getIntent().getLongExtra(EXTRA_EVENT_ID, -1)))
                    .addToBackStack(null)
                    .commit();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }


    private void refresh()
    {
        if (mLoginManager.isSignedIn())
        {
            DownloaderService.downloadEventActivityRating(this, getIntent().getLongExtra(EXTRA_ACTIVITY_ID, -1));
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
        ViewAnimator container = (ViewAnimator) findViewById(R.id.viewAnimator);
        data.moveToFirst();

        // Retrieve the activity info
        mInfo.name = data.getString(data.getColumnIndex(Activity.Columns.NAME));
        mInfo.description = data.getString(data.getColumnIndex(Activity.Columns.DESCRIPTION));
        mInfo.location = data.getString(data.getColumnIndex(Activity.Columns.LOCATION));
        mInfo.latitude = data.getDouble(data.getColumnIndex(Activity.Columns.LATITUDE));
        mInfo.longitude = data.getDouble(data.getColumnIndex(Activity.Columns.LONGITUDE));
        mInfo.approved = data.getInt(data.getColumnIndex(ActivityMember.Columns.APPROVED));
        mInfo.rating = data.getInt(data.getColumnIndex(Feedback.Columns.RATING));
        mInfo.dateBegin = DateUtils.calendarFromTimestampInGMT(data.getLong(data.getColumnIndex(Activity.Columns.DATE_BEGIN))).getTime();
        mInfo.dateEnd = DateUtils.calendarFromTimestampInGMT(data.getLong(data.getColumnIndex(Activity.Columns.DATE_END))).getTime();

        setupViewInfo();
        supportInvalidateOptionsMenu();

        container.setDisplayedChild(Utils.VIEW_ANIMATOR_CONTENT);
    }
    private void setupViewInfo()
    {
        ((TextView) findViewById(R.id.activity_name)).setText(mInfo.name);
        ((TextView) findViewById(R.id.activity_description)).setText(mInfo.description);

        String dateLocation = mTimeFormat.format(mInfo.dateBegin)+" - "+mTimeFormat.format(mInfo.dateEnd)+" "+mInfo.location;

        ((TextView) findViewById(R.id.activity_location)).setText(dateLocation);

        ((RatingBar) findViewById(R.id.activity_rating)).setRating(mInfo.rating);
        View ratingContainer = findViewById(R.id.activity_ratingContainer);
        ratingContainer.setVisibility(View.GONE);

        int color = 0;
        switch (mInfo.approved)
        {
        case APPROVED_NOT:
            color = getResources().getColor(R.color.light_gray);
            break;

        case APPROVED_WAIT_LIST:
            color = getResources().getColor(R.color.holo_red_dark);
            break;

        case APPROVED_OK:
            color = getResources().getColor(R.color.holo_green_dark);
            ratingContainer.setVisibility(View.VISIBLE);
            break;
        }
        ((TriangleView) findViewById(R.id.activity_approved)).setFillColor(color);
    }
    @Override public void onLoaderReset(Loader<Cursor> loader) {}


    @Override
    public void handleResponse(int requestCode, JSONObject json, int responseCode)
    {
        if (responseCode == HttpStatus.SC_OK && json != null)
        {
            try
            {
                long activityID = getIntent().getLongExtra(EXTRA_ACTIVITY_ID, -1);
                long eventID = getIntent().getLongExtra(EXTRA_EVENT_ID, -1);

                json = json.getJSONArray(JsonUtils.DATA).getJSONObject(0);

                long memberID = mLoginManager.getMember().memberId;
                int approved = json.getInt(ActivityMember.Columns.APPROVED);

                // Parse the member
                // Parse the link member-activity
                String selection =
                        ActivityMember.Columns.EVENT_ID_FULL+"="+eventID+" AND "+
                        ActivityMember.Columns.ACTIVITY_ID_FULL+"="+activityID+" AND "+
                        ActivityMember.Columns.MEMBER_ID_FULL+"="+memberID;
                ContentValues values = new ContentValues();
                values.put(ActivityMember.Columns.APPROVED, approved);
                getContentResolver().update(ActivityMember.CONTENT_URI, values, selection, null);
            }
            catch (JSONException e)
            {
                Log.w(InEvent.NAME, "Error parsing json="+json);
            }

            getSupportLoaderManager().restartLoader(LOAD_ACTIVITY, null, this);
        }
        else
        {
            Toast.makeText(this, Utils.getBadResponseMessage(requestCode, responseCode), Toast.LENGTH_SHORT).show();
        }

        SyncBroadcastManager.setSyncState(this, false);
    }


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
            int rating = (int) getRatingBar().getRating();
            UploaderService.sendOpinionForActivity(getActivity(), getActivity().getIntent().getLongExtra(EXTRA_ACTIVITY_ID, -1), rating);
        }
    }

    private class ActivityInfoHolder
    {
        public String name;
        public String description;
        public String location;
        public double latitude;
        public double longitude;
        public int    approved = -1;
        public Date   dateBegin;
        public Date   dateEnd;
        public int    rating;
    }
}