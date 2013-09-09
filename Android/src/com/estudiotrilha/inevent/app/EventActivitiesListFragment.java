package com.estudiotrilha.inevent.app;

import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.TimeZone;

import android.annotation.TargetApi;
import android.app.AlertDialog;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.support.v4.app.LoaderManager.LoaderCallbacks;
import android.support.v4.content.CursorLoader;
import android.support.v4.content.Loader;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.SectionIndexer;
import android.widget.TextView;

import com.estudiotrilha.android.utils.DateUtils;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.Utils;
import com.estudiotrilha.inevent.content.Activity;
import com.estudiotrilha.inevent.content.ActivityMember;
import com.estudiotrilha.inevent.content.Event;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.service.SyncService;


public class EventActivitiesListFragment extends ListFragment implements LoaderCallbacks<Cursor>, OnItemLongClickListener
{
    // Loader codes
    private static final int LOAD_ACTIVITY = 1;
    private static final int LOAD_SCHEDULE = 2;

    // Display Options
    enum DisplayOption
    {
        ACTIVITIES,
        SCHEDULE
    }

    // Instance State
    private static final String STATE_DISPLAY_OPTION   = "state.DISPLAY_OPTION";
    private static final String STATE_DOWNLOAD_ATTEMPT = "state.DOWNLOAD_ATTEMPT";

    // Arguments
    private static final String ARGS_EVENT_ID = "args.EVENT_ID";


    public static EventActivitiesListFragment instantiate(long eventID)
    {
        // Prepare the arguments
        Bundle args = new Bundle();
        args.putLong(ARGS_EVENT_ID, eventID);

        // Create the fragment
        EventActivitiesListFragment fragment = new EventActivitiesListFragment();
        fragment.setArguments(args);

        return fragment;
    }


    private EventActivitiesListAdapter mActivitiesAdapter;
    private EventActivitiesListAdapter mScheduleAdapter;


    private DisplayOption mDisplayOption = DisplayOption.ACTIVITIES;
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
            mDisplayOption = mEventActivity.isApproved() ? DisplayOption.SCHEDULE : DisplayOption.ACTIVITIES;                
        }

        // Setup the adapters
        mActivitiesAdapter = new EventActivitiesListAdapter(mEventActivity, false);
        mScheduleAdapter = new EventActivitiesListAdapter(mEventActivity, true);
    }
    @Override
    public void onViewCreated(View view, Bundle savedInstanceState)
    {
        super.onViewCreated(view, savedInstanceState);

        // Setup the displayed things on screen
        updateDisplayMode();
        setListShown(false);

        // Set the empty message
        setEmptyText(getText(R.string.empty_eventActivities));

        // Add fastscrolling function
        getListView().setFastScrollEnabled(true);
        getListView().setOnItemLongClickListener(this);
    }
    @Override
    public void onStart()
    {
        super.onStart();
        getLoaderManager().initLoader(LOAD_ACTIVITY, null, this);
        if (mEventActivity.isApproved())
        {
            getLoaderManager().initLoader(LOAD_SCHEDULE, null, this);
        }
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

        switch (mDisplayOption)
        {
        case ACTIVITIES:
            menu.findItem(R.id.menu_display_schedule).setVisible(mEventActivity.isApproved());
            break;

        case SCHEDULE:
            menu.findItem(R.id.menu_display_activities).setVisible(true);
            if (!mEventActivity.isApproved())
            {
                // Abort, the user is no longer logged in
                mDisplayOption = DisplayOption.ACTIVITIES;
                updateDisplayMode();
            }
            break;
        }
    }
    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        switch (item.getItemId())
        {
        case R.id.menu_display_activities:
            mDisplayOption = DisplayOption.ACTIVITIES;
            updateDisplayMode();
            return true;

        case R.id.menu_display_schedule:
            mDisplayOption = DisplayOption.SCHEDULE;
            updateDisplayMode();
            return true;

        case R.id.menu_refresh:
            refresh();
            break;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onListItemClick(ListView l, View v, int position, long id)
    {
        // Get the proper adapter
        EventActivitiesListAdapter adapter = (mDisplayOption == DisplayOption.ACTIVITIES) ? mActivitiesAdapter : mScheduleAdapter;

        // Show the Activity details
        Cursor c = adapter.getCursor();
        c.moveToPosition(adapter.getCursorPosition(position));
        new AlertDialog.Builder(mEventActivity) // TODO change this to a decent dialog fragment
                .setTitle(c.getString(c.getColumnIndex(Activity.Columns.NAME)))
                .setMessage(c.getString(c.getColumnIndex(Activity.Columns.DESCRIPTION)))
                .setPositiveButton(android.R.string.ok, null)
                .show();
    }


    private void updateDisplayMode()
    {
        switch (mDisplayOption)
        {
        case ACTIVITIES:
            setListAdapter(mActivitiesAdapter);
            mEventActivity.getSupportActionBar().setTitle(R.string.title_displayOption_activities);
            break;

        case SCHEDULE:
            setListAdapter(mScheduleAdapter);
            mEventActivity.getSupportActionBar().setTitle(R.string.title_displayOption_schedule);
            break;
        }

        mEventActivity.supportInvalidateOptionsMenu();
    }

    private void refresh()
    {
        // Get the event ID
        long eventId = getArguments().getLong(ARGS_EVENT_ID);

        // Download the activities info
        SyncService.syncEventActivities(mEventActivity, eventId);

        if (mEventActivity.isApproved())
        {
            // Download the schedule
            SyncService.syncEventSchedule(mEventActivity, eventId);

            if (mEventActivity.getRoleId() != Event.ROLE_ATTENDEE)
            {
                // Download the attenders
                SyncService.syncEventAttenders(getActivity(), eventId);
            }
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
        String sortOrder = Activity.Columns.DATE_BEGIN_FULL + " ASC";

        String eventID = Long.toString(getArguments().getLong(ARGS_EVENT_ID));

        switch (code)
        {
        case LOAD_ACTIVITY:
            uri = Activity.ACTIVITY_CONTENT_URI;
            projection = Activity.Columns.PROJECTION_LIST;
            selection = Activity.Columns.EVENT_ID_FULL +"= ?";
            selectionArgs = new String[1];

            // Get the event id
            selectionArgs[0] = eventID;
            break;

        case LOAD_SCHEDULE:
            uri = Activity.SCHEDULE_CONTENT_URI;
            projection = ActivityMember.Columns.PROJECTION_SCHEDULE_LIST;
            selection = ActivityMember.Columns.MEMBER_ID_FULL +"= ? AND "+Event.Columns._ID_FULL+"="+eventID;
            selectionArgs = new String[1];

            // Get the user id
            selectionArgs[0] = Long.toString(mLoginManager.getMember().memberId);
            break;
        }

        return new CursorLoader(getActivity(), uri, projection, selection, selectionArgs, sortOrder);
    }
    @Override
    public void onLoadFinished(Loader<Cursor> loader, Cursor data)
    {
        EventActivitiesListAdapter adapter;

        switch (loader.getId())
        {
        case LOAD_ACTIVITY:
            adapter = mActivitiesAdapter;
            break;

        case LOAD_SCHEDULE:
            adapter = mScheduleAdapter;
            break;
            
        default:
            return;
        }

        adapter.swapCursor(data);

        if (adapter.isEmpty())
        {
            if (Utils.checkConnectivity(getActivity()) && mDownloadAttempt < Utils.MAX_DOWNLOAD_ATTEMPTS)
            {
                mDownloadAttempt++;
                refresh();
            }
            else
            {
                setListShown(true);
            }
        }
        else
        {
            setListShown(true);
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

        case LOAD_SCHEDULE:
            mScheduleAdapter.swapCursor(null);
            break;
        }
    }


    class EventActivitiesListAdapter extends BaseAdapter implements SectionIndexer
    {
        private static final int LIST_TITLE = 0;
        private static final int LIST_ITEM  = 1;

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


        final boolean isSchedule;

        private ArrayList<EventSectionHolder> mSections;
        private Context                       mContext;
        private Cursor                        mCursor;
        private LayoutInflater                mInflater;
        private DateFormat                    mTimeFormat;
        // Indexes
        private int mIndexId;
        private int mIndexName;
        private int mIndexLocation;
        private int mIndexDateBegin;
        private int mIndexDateEnd;
        private int mIndexApproved;



        public EventActivitiesListAdapter(Context context, boolean isSchedule)
        {
            this.mContext = context;
            this.isSchedule = isSchedule;
            this.mInflater = LayoutInflater.from(context);

            // Get the user preferred date format
            mTimeFormat = android.text.format.DateFormat.getTimeFormat(context);

            mSections = new ArrayList<EventSectionHolder>();
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
                        int startingPosition = c.getPosition()+mSections.size();
                        mSections.add(new EventSectionHolder(date, startingPosition));
                        currentDay = thisDay;
                    }
                }
            }

            notifyDataSetChanged();
        }

        @Override
        public int getViewTypeCount()
        {
            // There are the ones with the titles
            return 2;
        }
        @Override
        public int getItemViewType(int position)
        {
            for (int i = 0; i < mSections.size(); i++)
            {
                if (mSections.get(i).startingPosition == position)
                {
                    return LIST_TITLE;
                }
            }

            return LIST_ITEM;
        }

        @Override
        public int getPositionForSection(int section)
        {
            return mSections.get(section).startingPosition;
        }
        @Override
        public int getSectionForPosition(int position)
        {
            for (int i = 1; i < mSections.size(); i++)
            {
                if (mSections.get(i).startingPosition > position)
                {
                    return i-1;
                }
            }
            // Last section
            return mSections.size()-1;
        }
        @Override
        public Object[] getSections()
        {
            return mSections.toArray();
        }

        @Override
        public int getCount()
        {
            if (mCursor == null || mCursor.getCount() == 0)
            {
                return 0;
            }
            else
            {
                return mCursor.getCount() + mSections.size();
            }
        }

        @Override
        public Object getItem(int position)
        {
            return position;
        }

        @Override
        public long getItemId(int position)
        {
            switch (getItemViewType(position))
            {
            case LIST_ITEM:
                mCursor.moveToPosition(getCursorPosition(position));
                return mCursor.getLong(mIndexId);

            case LIST_TITLE:
                return mSections.get(getSectionForPosition(position)).date.getTimeInMillis();

            default:
                return -1;
            }
        }
        @Override
        public boolean hasStableIds()
        {
            return true;
        }
        @Override
        public boolean isEnabled(int position)
        {
            return getItemViewType(position) == LIST_ITEM;
        }

        public int getCursorPosition(int listPosition)
        {
            return listPosition - (getSectionForPosition(listPosition) + 1);
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent)
        {
            Integer viewType = getItemViewType(position);
            if (convertView == null || !viewType.equals(convertView.getTag()))
            {
                // Inflate the view
                switch (viewType)
                {
                case LIST_ITEM:
                    convertView = mInflater.inflate(R.layout.cell_event_activity_item, parent, false);
                    break;

                case LIST_TITLE:
                    convertView = mInflater.inflate(R.layout.header_event_activity_section, parent, false);
                    break;
                }
            }
            convertView.setTag(viewType);

            switch (viewType)
            {
            case LIST_ITEM:
            {
                // Position the cursor
                mCursor.moveToPosition(getCursorPosition(position));

                // Layout the information
                // Activity name
                ((TextView) convertView.findViewById(R.id.activity_name)).setText(mCursor.getString(mIndexName));
                ((TextView) convertView.findViewById(R.id.activity_location)).setText(mCursor.getString(mIndexLocation));
                // Approved state
                if (isSchedule)
                {
                    // Set the color according to the approved state
                    boolean approved = mCursor.getInt(mIndexApproved) == 1;
                    int color = getResources().getColor(approved ? R.color.holo_green_dark : R.color.holo_red_dark);
                    convertView.findViewById(R.id.activity_approved).setBackgroundColor(color);
                }
                // Setup the starting and ending time
                // Parse the dates
                Date dateBegin = DateUtils.calendarFromTimestampInGMT(mCursor.getLong(mIndexDateBegin)).getTime();
                Date dateEnd = DateUtils.calendarFromTimestampInGMT(mCursor.getLong(mIndexDateEnd)).getTime();
                // Setup the views
                ((TextView) convertView.findViewById(R.id.activity_dateBegin)).setText(mTimeFormat.format(dateBegin));
                ((TextView) convertView.findViewById(R.id.activity_dateEnd)).setText(mTimeFormat.format(dateEnd));
                break;
            }

            case LIST_TITLE:
            {
                // Prepare the title
                EventSectionHolder section = mSections.get(getSectionForPosition(position));
                String title = android.text.format.DateFormat.getLongDateFormat(mContext).format(section.date.getTime());
                // and set it
                ((TextView) convertView.findViewById(R.id.activity_sectionHeader)).setText(title);
                break;
            }

            }

            return convertView;
        }
    }


    @Override
    public boolean onItemLongClick(AdapterView<?> adapter, View v, int position, long id)
    {
        if (mEventActivity.getRoleId() != Event.ROLE_ATTENDEE)
        {
            // Open up the attendance control
            getFragmentManager().beginTransaction()
                    .replace(R.id.mainContent, AttendanceFragment.instantiate(id, getArguments().getLong(ARGS_EVENT_ID)))
                    .addToBackStack(null)
                    .commit();

            return true;
        }

        return false;
    }
}
