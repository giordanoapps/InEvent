package com.estudiotrilha.inevent.app;

import java.lang.ref.WeakReference;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.TimeZone;

import android.annotation.TargetApi;
import android.content.ContentUris;
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
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.estudiotrilha.android.utils.DateUtils;
import com.estudiotrilha.android.utils.ViewUtils;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.Utils;
import com.estudiotrilha.inevent.app.EventActivitiesListFragment.EventActivityInfo;
import com.estudiotrilha.inevent.content.Activity;
import com.estudiotrilha.inevent.content.ActivityMember;
import com.estudiotrilha.inevent.content.Event;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.service.DownloaderService;


public class EventActivitiesPagesFragment extends Fragment implements LoaderCallbacks<Cursor>, OnNavigationListener
{
    // Loader codes
    private static final int LOAD_ACTIVITY = 1;

    // Display Options
    enum DisplayOption
    {
        ALL {
            @Override public int getTitle() { return R.string.title_displayOption_all; }
            @Override public int getActionTitle() { return R.string.action_displayOption_all; }
            @Override public String getQueryFilter() { return "1"; }
        },
        SCHEDULE_FULL {
            @Override public int getTitle() { return R.string.title_displayOption_schedule_full; }
            @Override public int getActionTitle() { return R.string.action_displayOption_schedule_full; }
            @Override public String getQueryFilter() { return ActivityMember.Columns.APPROVED_FULL+"!=-1"; }
        },
        SCHEDULE_APPROVED {
            @Override public int getTitle() { return R.string.title_displayOption_schedule_approved; }
            @Override public int getActionTitle() { return R.string.action_displayOption_schedule_approved; }
            @Override public String getQueryFilter() { return ActivityMember.Columns.APPROVED_FULL+"=1"; }
        },
        SCHEDULE_WAIT_LIST {
            @Override public int getTitle() { return R.string.title_displayOption_schedule_waitList; }
            @Override public int getActionTitle() { return R.string.action_displayOption_schedule_waitList; }
            @Override public String getQueryFilter() { return ActivityMember.Columns.APPROVED_FULL+"=0"; }
        };

        public abstract int getTitle();
        public abstract int getActionTitle();
        public abstract String getQueryFilter();
    }

    // Instance State
    private static final String STATE_DISPLAY_OPTION   = "state.DISPLAY_OPTION";
    private static final String STATE_CURRENT_PAGE     = "state.CURRENT_PAGE";
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
    private ViewPager     mViewPager;
    private int           mPagePosition = -1;


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
            mPagePosition = savedInstanceState.getInt(STATE_CURRENT_PAGE, -1);

            mDownloadAttempt = savedInstanceState.getInt(STATE_DOWNLOAD_ATTEMPT);
        }
        else
        {
            mDisplayOption = DisplayOption.ALL;
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

        if (mLoginManager.isSignedIn())
        {
            ActionBar actionBar = mEventActivity.getSupportActionBar();
            if (mEventActivity.isApproved())
            {
                // Get the event name
                long eventID = getArguments().getLong(ARGS_EVENT_ID);
                Cursor c = getActivity().getContentResolver().query(
                        ContentUris.withAppendedId(Event.CONTENT_URI, eventID),
                        new String[]{ Event.Columns.NAME_FULL }, null, null, null);
                String title = "";
                if (c.moveToFirst())
                {
                    title = c.getString(0);
                }
                c.close();

                actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_LIST);
                actionBar.setListNavigationCallbacks(new EventActivityFilterSpinnerAdapter(title), this);
                actionBar.setSelectedNavigationItem(mDisplayOption.ordinal());
                actionBar.setDisplayShowTitleEnabled(false);
            }
            else
            {
                actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_STANDARD);
                mEventActivity.getSupportActionBar().setTitle(mDisplayOption.getTitle());
            }
        }

        mViewPager = (ViewPager) view.findViewById(R.id.eventActivity_viewPager);
        mViewPager.setAdapter(mActivitiesAdapter);
        mViewPager.setPageMargin((int) ViewUtils.dipToPixels(mEventActivity, 16));
    }
    @Override
    public void onStart()
    {
        super.onStart();
        getLoaderManager().initLoader(LOAD_ACTIVITY, null, this);
    }
    @Override
    public void onPause()
    {
        super.onPause();
        if (mViewPager != null) mPagePosition = mViewPager.getCurrentItem();
    }
    @Override
    public void onSaveInstanceState(Bundle outState)
    {
        super.onSaveInstanceState(outState);
        outState.putInt(STATE_DISPLAY_OPTION, mDisplayOption.ordinal());
        outState.putInt(STATE_DOWNLOAD_ATTEMPT, mDownloadAttempt);
        outState.putInt(STATE_CURRENT_PAGE, mPagePosition);
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
        
        mDisplayOption = DisplayOption.values()[itemPosition];
        getLoaderManager().restartLoader(LOAD_ACTIVITY, null, this);

        return true;
    }

    private void refresh()
    {
        // Get the event ID
        long eventId = getArguments().getLong(ARGS_EVENT_ID);

        // Download the activities info
        DownloaderService.downloadEventActivities(mEventActivity, eventId);

        if (mEventActivity.isApproved() && mEventActivity.getRoleId() != Event.ROLE_ATTENDEE)
        {
            // Download the attenders
            DownloaderService.downloadEventAttenders(getActivity(), eventId);
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
            uri = Activity.CONTENT_URI;
            projection = Activity.Columns.PROJECTION_LIST;
            selection = Activity.Columns.EVENT_ID_FULL+"="+Long.toString(getArguments().getLong(ARGS_EVENT_ID))+" AND "+mDisplayOption.getQueryFilter();
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
            else if (mPagePosition != -1)
            {
                // Move to the selected page
                mViewPager.setCurrentItem(mPagePosition);
            }
            else
            {
                // Move to the preferred page, which may be today's activities list
                mPagePosition = mActivitiesAdapter.getPreferredPage();
                mViewPager.setCurrentItem(mPagePosition);
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

        private WeakReference
                <EventActivitiesListFragment>[] mFragments;
        private ArrayList<EventSectionHolder>   mSections;
        private Cursor                          mCursor;
        private DateFormat                      mDateFormat;
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

        public int getPreferredPage()
        {
            int page = 0;
            if (mSections.isEmpty()) return page;

            Calendar today = Calendar.getInstance();

            // Get the limits of the event
            Calendar begin = (Calendar) mSections.get(0).date.clone();
            begin.set(Calendar.HOUR_OF_DAY, 0);
            begin.set(Calendar.MINUTE, 0);
            begin.set(Calendar.SECOND, 0);
            Calendar end = (Calendar) mSections.get(mSections.size()-1).date.clone();
            end.set(Calendar.HOUR_OF_DAY, 23);
            end.set(Calendar.MINUTE, 59);
            end.set(Calendar.SECOND, 59);

            // Check if today is in the middle of the event
            if (today.after(begin) && today.before(end))
            {
                // It is!

                // Move to the current page containing the today's activities
                for (int i = 1; i < mSections.size(); i++, page++)
                {
                    if (!today.after(mSections.get(i).date))
                    {
                        break;
                    }
                }
            }

            
            return page;
        }

        public Cursor getCursor()
        {
            return mCursor;
        }

        @SuppressWarnings("unchecked")
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

            // Update the pages content
            mFragments = new WeakReference[mSections.size()];
            for (int i = 0; i < mFragments.length; i++)
            {
                // Null check one
                WeakReference<EventActivitiesListFragment> reference = mFragments[i];
                if (reference == null) continue;

                // Second null check
                EventActivitiesListFragment fragment = reference.get();
                if (fragment != null)
                {
                    fragment.updateContent(getItemData(i));
                }
            }

            // Rebuild the pages if necessary
            notifyDataSetChanged();
        }

        

        @Override
        public Fragment getItem(int position)
        {
            EventActivityInfo[] data = getItemData(position);

            long eventID = getArguments().getLong(ARGS_EVENT_ID);
            String header = getPageTitle(position).toString();
            EventActivitiesListFragment fragment = EventActivitiesListFragment.instantiate(eventID, data, header);
            mFragments[position] = new WeakReference<EventActivitiesListFragment>(fragment);

            return fragment;
        }

        private EventActivityInfo[] getItemData(int position)
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
            return data;
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

    class EventActivityFilterSpinnerAdapter extends BaseAdapter
    {
        private LayoutInflater mInflater;
        private CharSequence   mActivityTitle;


        public EventActivityFilterSpinnerAdapter(CharSequence title)
        {
            mActivityTitle = title;
            mInflater = getActivity().getLayoutInflater();
        }

        @Override
        public int getCount()
        {
            return DisplayOption.values().length;
        }
        @Override
        public Object getItem(int position)
        {
            return DisplayOption.values()[position].getActionTitle();
        }
        @Override
        public long getItemId(int position)
        {
            return position;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent)
        {
            if (convertView == null)
            {
                convertView = mInflater.inflate(R.layout.cell_event_activity_filter_spinner_view, parent, false);
            }

            ((TextView) convertView.findViewById(R.id.spinner_title)).setText(DisplayOption.values()[position].getTitle());
            ((TextView) convertView.findViewById(R.id.spinner_subtitle)).setText(mActivityTitle);

            return convertView;
        }
        
        @Override
        public View getDropDownView(int position, View convertView, ViewGroup parent)
        {
            if (convertView == null)
            {
                convertView = mInflater.inflate(R.layout.support_simple_spinner_dropdown_item, parent, false);
            }

            ((TextView) convertView.findViewById(android.R.id.text1)).setText((Integer) getItem(position));

            return convertView;
        }
    }
}