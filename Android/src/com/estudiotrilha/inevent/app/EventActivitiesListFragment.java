package com.estudiotrilha.inevent.app;

import java.text.DateFormat;
import java.util.Date;

import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.support.v4.app.LoaderManager.LoaderCallbacks;
import android.support.v4.content.CursorLoader;
import android.support.v4.content.Loader;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.ListView;
import android.widget.TextView;

import com.estudiotrilha.android.widget.ExtensibleCursorAdapter;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.content.Activity;
import com.estudiotrilha.inevent.content.Event;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.service.SyncService;


public class EventActivitiesListFragment extends ListFragment implements LoaderCallbacks<Cursor>, ExtensibleCursorAdapter.AdapterExtension
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
        String[] from = new String[] { Activity.Columns.NAME, Activity.Columns.LOCATION };
        int[] to = new int[] { R.id.activity_name, R.id.activity_location };
        int layout = R.layout.cell_event_activity_item;
        mActivitiesAdapter = new ExtensibleCursorAdapter(getActivity(), layout, null, from, to, 0);
        mActivitiesAdapter.registerExtension(this);
        mScheduleAdapter = new ExtensibleCursorAdapter(getActivity(), layout, null, from, to, 0);
        mScheduleAdapter.registerExtension(this);
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
//        Cursor c = getActivity().getContentResolver().query(ContentUris.withAppendedId(Event.EVENT_CONTENT_URI, id), new String[] { Event.Columns.ROLE_ID }, null, null, null);
//        if (!c.moveToFirst()) throw new IllegalStateException("Can't find the Event where _id="+id);
//        mRoleId = c.getLong(c.getColumnIndex(Event.Columns.ROLE_ID));
    }
    @Override
    public void onViewCreated(View view, Bundle savedInstanceState)
    {
        super.onViewCreated(view, savedInstanceState);

        if (savedInstanceState != null)
        {
            mDisplayOption = DisplayOption.values()[savedInstanceState.getInt(STATE_DISPLAY_OPTION)];
        }

        updateDisplayMode();

        setListShown(false);

//        getListView().setClickable(mRoleId == Event.ROLE_COORDINATOR || mRoleId == Event.ROLE_STAFF); // TODO
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
        // TODO temporary code
        // XXX
        getFragmentManager().beginTransaction()
                .replace(R.id.mainContent, AttendanceFragment.instantiate(id, getArguments().getLong(ARGS_EVENT_ID)))
                .addToBackStack(null)
                .commit();
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
        mIndexDateBegin = data.getColumnIndex(Activity.Columns.DATE_BEGIN);
        mIndexDateEnd = data.getColumnIndex(Activity.Columns.DATE_END);

        switch (loader.getId())
        {
        case LOAD_ACTIVITY:
            mActivitiesAdapter.swapCursor(data);
            break;

        case LOAD_SCHEDULE:
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


    @Override public void doBeforeBinding(View v, Context context, Cursor c) {}
    @Override
    public void doAfterBinding(View v, Context context, Cursor c)
    {
        // Parse the dates
        Date dateBegin = new Date(c.getLong(mIndexDateBegin)*1000L);
        Date dateEnd = new Date(c.getLong(mIndexDateEnd)*1000L);

        // Setup the views
        ((TextView) v.findViewById(R.id.activity_dateBegin)).setText(mTimeFormat.format(dateBegin));
        ((TextView) v.findViewById(R.id.activity_dateEnd)).setText(mTimeFormat.format(dateEnd));
    }
}
