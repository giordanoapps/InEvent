package com.estudiotrilha.inevent.app;


import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.support.v4.app.LoaderManager.LoaderCallbacks;
import android.support.v4.content.CursorLoader;
import android.support.v4.content.Loader;
import android.support.v4.view.MenuItemCompat;
import android.support.v7.widget.SearchView;
import android.text.InputType;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.FilterQueryProvider;
import android.widget.ListView;
import android.widget.TextView;

import com.estudiotrilha.android.widget.ExtensibleCursorAdapter;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.content.Activity;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.content.Member;
import com.estudiotrilha.inevent.service.SyncService;


public class AttendanceFragment extends ListFragment implements LoaderCallbacks<Cursor>, OnItemLongClickListener
{
    private static final int INTERVAL_CLICK = 600; // in milliseconds

    // Loader coder
    private static final int LOAD_PEOPLE = 1;

    // Arguments
    private static final String ARGS_ACTIVITY_ID = "args.ACTIVITY_ID";
    private static final String ARGS_EVENT_ID    = "args.EVENT_ID";


    public static final AttendanceFragment instantiate(long activityID, long eventID)
    {
        // Prepare the arguments
        Bundle args = new Bundle();
        args.putLong(ARGS_ACTIVITY_ID, activityID);
        args.putLong(ARGS_EVENT_ID, eventID);

        // Create the fragment
        AttendanceFragment fragment = new AttendanceFragment();
        fragment.setArguments(args);

        return fragment;
    }


    private ExtensibleCursorAdapter mPeopleAdapter;

    private int mIndexId;
    private int mIndexPresent;

    private long mLastClickedItemId  = -1;
    private long mLastClickTime;


    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);

        // Setup the adapter
        final int layout = R.layout.cell_attender_item;
        final String[] from = new String[] { Member.Columns.NAME };
        final int[] to = new int[] { R.id.member_name };
        mPeopleAdapter = new ExtensibleCursorAdapter(getActivity(), layout, null, from, to, 0);
        mPeopleAdapter.registerExtension(new ExtensibleCursorAdapter.AdapterExtension() {
            @Override public void doBeforeBinding(View v, Context context, Cursor c) {}
            @Override
            public void doAfterBinding(View v, Context context, Cursor c)
            {
                // Setup the ID
                ((TextView) v.findViewById(R.id.member_id)).setText(String.format("%04d", c.getLong(mIndexId)));

                // And the presence state
                View present = v.findViewById(R.id.member_present);
                present.setVisibility(c.getInt(mIndexPresent) == 1 ? View.VISIBLE : View.GONE);
            }
        });

        // Setup the results filter
        mPeopleAdapter.setFilterQueryProvider(new FilterQueryProvider() {
            // The query basic info
            final Uri      uri           = Activity.ATTENDERS_CONTENT_URI;
            final String[] projection    = Activity.Member.Columns.PROJECTION_ATTENDANCE_LIST;
            final String   selection     = Activity.Member.TABLE_NAME+"."+Activity.Member.Columns.ACTIVITY_ID+" = "+ getArguments().getLong(ARGS_ACTIVITY_ID)+
                    " AND "+Activity.Member.Columns.APPROVED +" = 1"+
                    " AND "+Member.TABLE_NAME+"."+Member.Columns._ID+" LIKE ?";
            final String[] selectionArgs = new String[1];
            final String   sortOrder     = Member.TABLE_NAME+"."+Member.Columns.NAME + " ASC";


            @Override
            public Cursor runQuery(CharSequence constraint)
            {
                selectionArgs[0] = constraint.toString() + "%";
                return getActivity().getContentResolver().query(uri, projection, selection, selectionArgs, sortOrder);
            }
        });

        // Set the empty text message
        setEmptyText(getText(R.string.empty_eventActivityAttenders));
    }
    @Override
    public void onViewCreated(View view, Bundle savedInstanceState)
    {
        super.onViewCreated(view, savedInstanceState);
        // Add the adapter to the list
        setListAdapter(mPeopleAdapter);

        // Add fastscrolling function
        getListView().setFastScrollEnabled(true);

        // Setup the click listener
        getListView().setOnItemLongClickListener(this);
    }
    @Override
    public void onStart()
    {
        super.onStart();
        // Start loading the content
        getLoaderManager().initLoader(LOAD_PEOPLE, null, this);
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater)
    {
        inflater.inflate(R.menu.fragment_attendance, menu);

        // Setup the search text entry
        MenuItem searchItem = menu.findItem(R.id.menu_search);
        SearchView searchView = (SearchView) MenuItemCompat.getActionView(searchItem);
        searchView.setInputType(InputType.TYPE_CLASS_NUMBER);
        searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override public boolean onQueryTextSubmit(String query) { return false; }
            @Override
            public boolean onQueryTextChange(String newText)
            {
                mPeopleAdapter.getFilter().filter(newText);
                System.out.println("Filtering for "+newText);
                return false;
            }
        });
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
    public void onListItemClick(ListView l, View v, int position, long id)
    {
        // If double clicked, the attendee will have its presence confirmed
        if (mLastClickedItemId == id && System.currentTimeMillis() - mLastClickTime < INTERVAL_CLICK)
        {
            confirmPresence(id);
        }
        else
        {
            mLastClickedItemId = id;
            mLastClickTime = System.currentTimeMillis();
        }
    }
    @Override
    public boolean onItemLongClick(AdapterView<?> adapter, View v, int position, long id)
    {
        confirmPresence(id);
        return false;
    }

    private void confirmPresence(final long id)
    {
        // Mark the member as present
        setPresence(id, 1);

        // And add this to the queue to be sent to the server
        LoginManager.getInstance(getActivity()).confirmPresence(getArguments().getLong(ARGS_ACTIVITY_ID), id);
    }

    private void setPresence(long memberID, int present)
    {
        final String selection = Activity.Member.Columns.MEMBER_ID+"="+memberID+
                " AND "+Activity.Member.Columns.ACTIVITY_ID+"="+getArguments().getLong(ARGS_ACTIVITY_ID);
        final ContentValues values = new ContentValues();
        values.put(Activity.Member.Columns.PRESENT, present);
        getActivity().getContentResolver().update(Activity.ATTENDERS_CONTENT_URI, values, selection, null);
    }



    private void refresh()
    {
        // Prepare the intent
        Intent intent = new Intent(getActivity(), SyncService.class);
        intent.putExtra(SyncService.EXTRA_ACTIVITY_ID, getArguments().getLong(ARGS_ACTIVITY_ID));
        intent.putExtra(SyncService.EXTRA_EVENT_ID, getArguments().getLong(ARGS_EVENT_ID));

        // Download the attenders
        getActivity().startService(intent.setData(Activity.ATTENDERS_CONTENT_URI));
    }


    // Loader callbacks
    @Override
    public Loader<Cursor> onCreateLoader(int code, Bundle args)
    {
        Uri uri = Activity.ATTENDERS_CONTENT_URI;
        String[] projection = Activity.Member.Columns.PROJECTION_ATTENDANCE_LIST;
        String selection = Activity.Member.TABLE_NAME+"."+Activity.Member.Columns.ACTIVITY_ID+" = "+getArguments().getLong(ARGS_ACTIVITY_ID) +
                " AND "+ Activity.Member.Columns.APPROVED +" = 1";
        String[] selectionArgs = null;
        String sortOrder = Member.TABLE_NAME+"."+Member.Columns.NAME + " ASC";

        return new CursorLoader(getActivity(), uri, projection, selection, selectionArgs, sortOrder);
    }
    @Override
    public void onLoadFinished(Loader<Cursor> loader, Cursor data)
    {
        // Treat the special (empty) cases
        if (data.getCount() < 3)
        {
            // Download new data
            refresh();
        }

        // Update the indexes
        mIndexId = data.getColumnIndex(Activity.Member.Columns._ID);
        mIndexPresent = data.getColumnIndex(Activity.Member.Columns.PRESENT);

        mPeopleAdapter.swapCursor(data);
    }
    @Override
    public void onLoaderReset(Loader<Cursor> loader)
    {
        mPeopleAdapter.swapCursor(null);
    }
}
