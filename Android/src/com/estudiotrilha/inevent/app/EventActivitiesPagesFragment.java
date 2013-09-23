package com.estudiotrilha.inevent.app;

import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.TimeZone;

import android.annotation.TargetApi;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.app.LoaderManager.LoaderCallbacks;
import android.support.v4.content.CursorLoader;
import android.support.v4.content.Loader;
import android.support.v4.view.ViewPager;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBar.OnNavigationListener;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import com.estudiotrilha.android.utils.DateUtils;
import com.estudiotrilha.android.utils.ViewUtils;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.Utils;
import com.estudiotrilha.inevent.app.EventActivitiesListFragment.EventActivityInfo;
import com.estudiotrilha.inevent.content.Activity;
import com.estudiotrilha.inevent.content.ActivityMember;
import com.estudiotrilha.inevent.content.Event;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.service.SyncService;


public class EventActivitiesPagesFragment extends Fragment implements LoaderCallbacks<Cursor>, OnNavigationListener
{
    // Loader codes
    private static final int LOAD_ACTIVITY = 1;

    // Display Options
    enum DisplayOption
    {
        ALL {
            @Override public int getTitle() { return R.string.title_displayOption_all; }
        },
        SCHEDULE_FULL {
            @Override public int getTitle() { return R.string.title_displayOption_schedule_full; }
        },
        SCHEDULE_APPROVED {
            @Override public int getTitle() { return R.string.title_displayOption_schedule_approved; }
        },
        SCHEDULE_WAIT_LIST {
            @Override public int getTitle() { return R.string.title_displayOption_schedule_waitList; }
        };

        public abstract int getTitle();
    }

    // Instance State
    private static final String STATE_DISPLAY_OPTION   = "state.DISPLAY_OPTION";
    private static final String STATE_DOWNLOAD_ATTEMPT = "state.DOWNLOAD_ATTEMPT";

    // Arguments
    private static final String ARGS_EVENT_ID = "args.EVENT_ID";


    public static EventActivitiesPagesFragment instantiate(long eventID)
    {
        // Prepare the arguments
        Bundle args = new Bundle();
        args.putLong(ARGS_EVENT_ID, eventID);

        // Create the fragment
        EventActivitiesPagesFragment fragment = new EventActivitiesPagesFragment();
        fragment.setArguments(args);

        return fragment;
    }


    private EventActivityPagerAdapter mActivitiesAdapter;


    private DisplayOption mDisplayOption = DisplayOption.ALL;
    private LoginManager  mLoginManager;
    private EventActivity mEventActivity;
    private int           mDownloadAttempt;


    @Override
    public void onAttach(android.app.Activity activity)
    {
        super.onAttach(activity);
        mEventActivity = (EventActivity) activity;
    }
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        mLoginManager = LoginManager.getInstance(mEventActivity);
        setHasOptionsMenu(true);

        if (savedInstanceState != null)
        {
            // Display the correct set of data
            mDisplayOption = DisplayOption.values()[savedInstanceState.getInt(STATE_DISPLAY_OPTION)];

            mDownloadAttempt = savedInstanceState.getInt(STATE_DOWNLOAD_ATTEMPT);
        }
        else if (mLoginManager.isSignedIn())
        {
            boolean approved = mEventActivity.isApproved();
            mDisplayOption = approved ? DisplayOption.SCHEDULE_FULL : DisplayOption.ALL;
            ActionBar actionBar = mEventActivity.getSupportActionBar();
            actionBar.setNavigationMode(approved ? ActionBar.NAVIGATION_MODE_LIST : ActionBar.NAVIGATION_MODE_STANDARD);
            actionBar.setListNavigationCallbacks(null, this);
            refresh();
        }

        // Setup the adapters
        mActivitiesAdapter = new EventActivityPagerAdapter(mEventActivity, false);
    }
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        return inflater.inflate(R.layout.fragment_event_activities_pages, container, false);
    }
    @Override
    public void onViewCreated(View view, Bundle savedInstanceState)
    {
        super.onViewCreated(view, savedInstanceState);

        ViewPager pager = (ViewPager) view.findViewById(R.id.eventActivity_viewPager);
        pager.setAdapter(mActivitiesAdapter);
        pager.setPageMargin((int) ViewUtils.dipToPixels(mEventActivity, 8));

        // Setup the displayed things on screen
        updateDisplayMode();
    }
    @Override
    public void onStart()
    {
        super.onStart();
        getLoaderManager().initLoader(LOAD_ACTIVITY, null, this);
    }
    @Override
    public void onSaveInstanceState(Bundle outState)
    {
        super.onSaveInstanceState(outState);
        outState.putInt(STATE_DISPLAY_OPTION, mDisplayOption.ordinal());
        outState.putInt(STATE_DOWNLOAD_ATTEMPT, mDownloadAttempt);
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater)
    {
        inflater.inflate(R.menu.fragment_event_activities_list, menu);
    }
    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        switch (item.getItemId())
        {
        case R.id.menu_refresh:
            refresh();
            break;
        }

        return super.onOptionsItemSelected(item);
    }


    @Override
    public boolean onNavigationItemSelected(int itemPosition, long itemId)
    {
        if (itemPosition == mDisplayOption.ordinal()) return false;

        // TODO
        updateDisplayMode();

        return false;
    }
    private void updateDisplayMode()
    {
        mEventActivity.getSupportActionBar().setTitle(mDisplayOption.getTitle());
    }

    private void refresh()
    {
        // Get the event ID
        long eventId = getArguments().getLong(ARGS_EVENT_ID);

        // Download the activities info
        SyncService.syncEventActivities(mEventActivity, eventId);

        if (mEventActivity.isApproved() && mEventActivity.getRoleId() != Event.ROLE_ATTENDEE)
        {
            // Download the attenders
            SyncService.syncEventAttenders(getActivity(), eventId);
        }
    }


    // Loader callbacks
    @Override
    public Loader<Cursor> onCreateLoader(int code, Bundle args)
    {
        Uri uri = null;
        String[] projection = null;
        String selection = null;
        String[] selectionArgs = null;
        String sortOrder = null;

        switch (code)
        {
        case LOAD_ACTIVITY:
            uri = Activity.ACTIVITY_CONTENT_URI;
            projection = Activity.Columns.PROJECTION_LIST;
            selection = Activity.Columns.EVENT_ID_FULL+"="+Long.toString(getArguments().getLong(ARGS_EVENT_ID));
            sortOrder = Activity.Columns.DATE_BEGIN_FULL + " ASC";
            break;
        }

        return new CursorLoader(getActivity(), uri, projection, selection, selectionArgs, sortOrder);
    }
    @Override
    public void onLoadFinished(Loader<Cursor> loader, Cursor data)
    {
        switch (loader.getId())
        {
        case LOAD_ACTIVITY:
            mActivitiesAdapter.swapCursor(data);
            
            if (mActivitiesAdapter.getCount() == 0)
            {
                if (Utils.checkConnectivity(getActivity()) && mDownloadAttempt < Utils.MAX_DOWNLOAD_ATTEMPTS)
                {
                    mDownloadAttempt++;
                    refresh();
                }
            }
            break;
        }

    }
    @Override
    public void onLoaderReset(Loader<Cursor> loader)
    {
        switch (loader.getId())
        {
        case LOAD_ACTIVITY:
            mActivitiesAdapter.swapCursor(null);
            break;
        }
    }


    class EventActivityPagerAdapter extends FragmentPagerAdapter
    {
        private class EventSectionHolder
        {
            final Calendar date;
            final int      startingPosition;

            public EventSectionHolder(Calendar date, int startingPosition)
            {
                this.date = date;
                this.startingPosition = startingPosition;
            }

            @TargetApi(Build.VERSION_CODES.GINGERBREAD)
            @Override
            public String toString()
            {
                return Integer.toString(date.get(Calendar.DAY_OF_MONTH));
            }
        }

        private ArrayList<EventSectionHolder> mSections;
        private Cursor                        mCursor;
        private DateFormat                    mDateFormat;
        // Indexes
        private int mIndexId;
        private int mIndexName;
        private int mIndexLocation;
        private int mIndexDateBegin;
        private int mIndexDateEnd;
        private int mIndexApproved;


        public EventActivityPagerAdapter(Context context, boolean isSchedule)
        {
            super(getFragmentManager());
            mSections = new ArrayList<EventSectionHolder>();
            // Get the user preferred date format
            mDateFormat = android.text.format.DateFormat.getLongDateFormat(mEventActivity);
        }

        public Cursor getCursor()
        {
            return mCursor;
        }

        public void swapCursor(Cursor c)
        {
            mSections.clear();
            mCursor = c;

            if (c != null)
            {
                // Build up indexes
                mIndexId = c.getColumnIndex(Activity.Columns._ID);
                mIndexName = c.getColumnIndex(Activity.Columns.NAME);
                mIndexLocation = c.getColumnIndex(Activity.Columns.LOCATION);
                mIndexDateBegin = c.getColumnIndex(Activity.Columns.DATE_BEGIN);
                mIndexDateEnd = c.getColumnIndex(Activity.Columns.DATE_END);
                mIndexApproved = c.getColumnIndex(ActivityMember.Columns.APPROVED);

                // Build the sections
                int currentDay = -1;

                c.moveToPosition(-1);
                while (c.moveToNext())
                {
                    Calendar date = DateUtils.calendarFromTimestampInGMT(c.getLong(mIndexDateBegin));
                    date.setTimeZone(TimeZone.getDefault());

                    int thisDay = date.get(Calendar.DAY_OF_YEAR);
                    if (thisDay != currentDay)
                    {
                        // Setup the new section info
                        int startingPosition = c.getPosition();
                        mSections.add(new EventSectionHolder(date, startingPosition));
                        currentDay = thisDay;
                    }
                }
            }

            notifyDataSetChanged();
        }


        @Override
        public Fragment getItem(int position)
        {
            // Build up the list info
            // Get the starting and end position
            int start = mSections.get(position).startingPosition;
            int end = getCount()-1;
            end = position < end ? mSections.get(position+1).startingPosition : mCursor.getCount();
            // Create the array list
            EventActivityInfo[] data = new EventActivityInfo[end - start]; 
            // Fill it up with info
            for (int i = 0; i < data.length; i++)
            {
                // Position the cursor
                mCursor.moveToPosition(start+i);
                // And get the info
                data[i] = new EventActivityInfo(
                        mCursor.getLong(mIndexId),
                        mCursor.getString(mIndexName),
                        mCursor.getString(mIndexLocation),
                        mCursor.getInt(mIndexApproved),
                        mCursor.getLong(mIndexDateBegin),
                        mCursor.getLong(mIndexDateEnd)
                );
            }


            long eventID = getArguments().getLong(ARGS_EVENT_ID);
            String header = getPageTitle(position).toString();
            EventActivitiesListFragment fragment = EventActivitiesListFragment.instantiate(eventID, data, header);
            return fragment;
        }

        @Override
        public int getCount()
        {
            return mSections.size();
        }

        @Override
        public CharSequence getPageTitle(int position)
        {
            return mDateFormat.format(mSections.get(position).date.getTime());
        }
    }
}
