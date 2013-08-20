package com.estudiotrilha.inevent.app;

import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;

import android.annotation.TargetApi;
import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.support.v4.app.LoaderManager.LoaderCallbacks;
import android.support.v4.content.CursorLoader;
import android.support.v4.content.Loader;
import android.util.SparseIntArray;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewStub;
import android.widget.ListView;
import android.widget.SectionIndexer;
import android.widget.TextView;

import com.estudiotrilha.android.utils.DateUtils;
import com.estudiotrilha.android.widget.ExtensibleCursorAdapter;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.content.Activity;
import com.estudiotrilha.inevent.content.Event;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.service.SyncService;


public class EventActivitiesListFragment extends ListFragment implements LoaderCallbacks<Cursor>
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
    private static final String STATE_DISPLAY_OPTION = "state.DISPLAY_OPTION";

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


    private ExtensibleCursorAdapter mActivitiesAdapter;
    private ExtensibleCursorAdapter mScheduleAdapter;

    private int mIndexName;
    private int mIndexDescription;
    private int mIndexDateBegin;
    private int mIndexDateEnd;
    private int mIndexApproved;

    private DisplayOption mDisplayOption = DisplayOption.SCHEDULE;
    private DateFormat    mTimeFormat;
    private long          mRoleId;

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);

        // Setup the adapters
        mActivitiesAdapter = new EventActivitiesListAdapter(getActivity());
        mScheduleAdapter = new EventActivitiesListAdapter(getActivity());
        mScheduleAdapter.registerExtension(new ExtensibleCursorAdapter.AdapterExtension() {
            @Override public void doBeforeBinding(View v, Context context, Cursor c) {}
            @Override
            public void doAfterBinding(View v, Context context, Cursor c)
            {
                // Set the color according to the approved state
                boolean approved = c.getInt(mIndexApproved) == 1;
                int color = getResources().getColor(approved ? R.color.holo_green_dark : R.color.holo_red_dark);
                v.findViewById(R.id.activity_approved).setBackgroundColor(color);
            }
        });

        // Get the user preferred date format
        mTimeFormat = android.text.format.DateFormat.getTimeFormat(getActivity());
        long id = getArguments().getLong(ARGS_EVENT_ID);

        // Check the user role for this event

        // Get the info
        String selection = Event.Member.Columns.EVENT_ID+"="+id+" AND "+Event.Member.Columns.MEMBER_ID+"="+LoginManager.getInstance(getActivity()).getMember().memberId;
        Cursor c = getActivity().getContentResolver().query(Event.ATTENDERS_CONTENT_URI, new String[] { Event.Member.Columns.ROLE_ID }, selection, null, null);
        if (c.moveToFirst())
        {
            mRoleId = c.getLong(c.getColumnIndex(Event.Member.Columns.ROLE_ID));
        }
        else
        {
            mRoleId = Event.ROLE_ATTENDEE;
        }

        if (mRoleId != Event.ROLE_ATTENDEE)
        {
            // Show all the activities case the user is staff
            mDisplayOption = DisplayOption.ACTIVITIES;
        }
    }
    @Override
    public void onViewCreated(View view, Bundle savedInstanceState)
    {
        super.onViewCreated(view, savedInstanceState);

        if (savedInstanceState != null)
        {
            mDisplayOption = DisplayOption.values()[savedInstanceState.getInt(STATE_DISPLAY_OPTION)];
        }

        // Setup the displayed things on screen
        updateDisplayMode();
        setListShown(false);

        // Set the empty message
        setEmptyText(getText(R.string.empty_eventActivities));

        // Add fastscrolling function
        getListView().setFastScrollEnabled(true);
    }
    @Override
    public void onStart()
    {
        super.onStart();
        getLoaderManager().initLoader(LOAD_ACTIVITY, null, this);
        getLoaderManager().initLoader(LOAD_SCHEDULE, null, this);
    }
    @Override
    public void onSaveInstanceState(Bundle outState)
    {
        super.onSaveInstanceState(outState);
        outState.putInt(STATE_DISPLAY_OPTION, mDisplayOption.ordinal());
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater)
    {
        inflater.inflate(R.menu.fragment_event_activities_list, menu);

        if (mRoleId != Event.ROLE_ATTENDEE)
        {
            switch (mDisplayOption)
            {
            case ACTIVITIES:
                menu.findItem(R.id.menu_display_schedule).setVisible(true);
                break;
    
            case SCHEDULE:
                menu.findItem(R.id.menu_display_activities).setVisible(true);
                break;
            }
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
        if (mDisplayOption == DisplayOption.ACTIVITIES)
        {
            // Open up the attendance control
            getFragmentManager().beginTransaction()
                    .replace(R.id.mainContent, AttendanceFragment.instantiate(id, getArguments().getLong(ARGS_EVENT_ID)))
                    .addToBackStack(null)
                    .commit();
        }
        else
        {
            // Show the Activity details
            Cursor c = mScheduleAdapter.getCursor();
            c.moveToPosition(position);
            new AlertDialog.Builder(getActivity())
                    .setTitle(c.getString(mIndexName))
                    .setMessage(c.getString(mIndexDescription))
                    .setPositiveButton(android.R.string.ok, null)
                    .show();
        }
    }


    private void updateDisplayMode()
    {
        switch (mDisplayOption)
        {
        case ACTIVITIES:
            setListAdapter(mActivitiesAdapter);
            break;

        case SCHEDULE:
            setListAdapter(mScheduleAdapter);
            break;
        }

        getActivity().supportInvalidateOptionsMenu();
    }

    private void refresh()
    {
        // Prepare the intent
        Intent intent = new Intent(getActivity(), SyncService.class);
        intent.putExtra(SyncService.EXTRA_EVENT_ID, getArguments().getLong(ARGS_EVENT_ID));

        // Download the activities
        getActivity().startService(intent.setData(Activity.ACTIVITY_CONTENT_URI));
        // the schedule
        getActivity().startService(intent.setData(Activity.SCHEDULE_CONTENT_URI));
        // and the attenders
        getActivity().startService(intent.setData(Event.ATTENDERS_CONTENT_URI));
    }


    // Loader callbacks
    @Override
    public Loader<Cursor> onCreateLoader(int code, Bundle args)
    {
        Uri uri = null;
        String[] projection = null;
        String selection = null;
        String[] selectionArgs = null;
        String sortOrder = Activity.TABLE_NAME+"."+Activity.Columns.DATE_BEGIN + " ASC";

        switch (code)
        {
        case LOAD_ACTIVITY:
            uri = Activity.ACTIVITY_CONTENT_URI;
            projection = Activity.Columns.PROJECTION_LIST;
            selection = Activity.TABLE_NAME+"."+Activity.Columns.EVENT_ID +"= ?";
            selectionArgs = new String[1];

            // Get the event id
            selectionArgs[0] = Long.toString(getArguments().getLong(ARGS_EVENT_ID));
            break;

        case LOAD_SCHEDULE:
            uri = Activity.SCHEDULE_CONTENT_URI;
            projection = Activity.Member.Columns.PROJECTION_SCHEDULE_LIST;
            selection = Activity.Member.TABLE_NAME+"."+Activity.Member.Columns.MEMBER_ID +"= ?";
            selectionArgs = new String[1];

            // Get the user id
            selectionArgs[0] = Long.toString(LoginManager.getInstance(getActivity()).getMember().memberId);
            break;
        }

        return new CursorLoader(getActivity(), uri, projection, selection, selectionArgs, sortOrder);
    }
    @Override
    public void onLoadFinished(Loader<Cursor> loader, Cursor data)
    {
        if (data.getCount() == 0)
        {
            refresh();
        }

        mIndexDateBegin = data.getColumnIndex(Activity.Columns.DATE_BEGIN);
        mIndexDateEnd = data.getColumnIndex(Activity.Columns.DATE_END);

        switch (loader.getId())
        {
        case LOAD_ACTIVITY:
            mActivitiesAdapter.swapCursor(data);
            break;

        case LOAD_SCHEDULE:
            mIndexName = data.getColumnIndex(Activity.Columns.NAME);
            mIndexDescription = data.getColumnIndex(Activity.Columns.DESCRIPTION);
            mIndexApproved = data.getColumnIndex(Activity.Member.Columns.APPROVED);
            mScheduleAdapter.swapCursor(data);
            break;
        }

        setListShown(true);
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


    class EventActivitiesListAdapter extends ExtensibleCursorAdapter implements SectionIndexer, ExtensibleCursorAdapter.AdapterExtension
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
//                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.GINGERBREAD)
//                {
//                    return date.getDisplayName(Calendar.DAY_OF_WEEK, Calendar.SHORT, Locale.getDefault());
//                }
//                else
//                {
                    return Integer.toString(date.get(Calendar.DAY_OF_MONTH));
//                }
            }
        }

        private ArrayList<EventSectionHolder> mSections;
        private SparseIntArray                mSectionMap; 

        public EventActivitiesListAdapter(Context context)
        {
            super(context, R.layout.cell_event_activity_item, null,
                    new String[] { Activity.Columns.NAME, Activity.Columns.LOCATION },
                    new int[] { R.id.activity_name, R.id.activity_location },
                    0);
            registerExtension(this);

            mSections = new ArrayList<EventSectionHolder>();
            mSectionMap = new SparseIntArray();
        }

        @Override
        public Cursor swapCursor(Cursor c)
        {
            mSections.clear();
            mSectionMap.clear();

            if (c != null)
            {
                // Build the sections

                int currentDay = -1;

                c.moveToPosition(-1);
                while (c.moveToNext())
                {
                    Calendar date = DateUtils.calendarFromTimestampInGMT(c.getLong(mIndexDateBegin));

                    int thisDay = date.get(Calendar.DAY_OF_MONTH);
                    if (thisDay != currentDay)
                    {
                        // Setup the new section info
                        mSections.add(new EventSectionHolder(date, c.getPosition()));
                        currentDay = thisDay;
                    }

                    // Map the data position to the section
                    mSectionMap.put(c.getPosition(), mSections.size()-1);
                }
            }

            return super.swapCursor(c);
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
            if (position == mSections.get(mSectionMap.get(position)).startingPosition)
            {
                return LIST_TITLE;
            }
            else
            {
                return LIST_ITEM;
            }
        }

        @Override
        public int getPositionForSection(int section)
        {
            return mSections.get(section).startingPosition;
        }
        @Override
        public int getSectionForPosition(int position)
        {
            return mSectionMap.get(position);
        }
        @Override
        public Object[] getSections()
        {
            return mSections.toArray();
        }

        @Override
        public void doBeforeBinding(View v, Context context, Cursor c)
        {
            int position = c.getPosition();
            if (getItemViewType(position) == LIST_TITLE)
            {
                // Inflate the header
                ViewStub viewStub = (ViewStub) v.findViewById(R.id.activity_section);
                if (viewStub != null) v = viewStub.inflate();

                // Prepare the title
                EventSectionHolder section = mSections.get(mSectionMap.get(position));
                String title = android.text.format.DateFormat.getLongDateFormat(context).format(section.date.getTime());
                // and set it
                ((TextView) v.findViewById(R.id.activity_sectionHeader)).setText(title);
            }
        }
        @Override
        public void doAfterBinding(View v, Context context, Cursor c)
        {
            // Setup the starting and ending time

            // Parse the dates
            Date dateBegin = DateUtils.calendarFromTimestampInGMT(c.getLong(mIndexDateBegin)).getTime();
            Date dateEnd = DateUtils.calendarFromTimestampInGMT(c.getLong(mIndexDateEnd)).getTime();

            // Setup the views
            ((TextView) v.findViewById(R.id.activity_dateBegin)).setText(mTimeFormat.format(dateBegin));
            ((TextView) v.findViewById(R.id.activity_dateEnd)).setText(mTimeFormat.format(dateEnd));
        }
    }
}
