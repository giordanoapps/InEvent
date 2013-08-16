package com.estudiotrilha.inevent.app;

import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.ListFragment;
import android.support.v4.app.LoaderManager.LoaderCallbacks;
import android.support.v4.content.CursorLoader;
import android.support.v4.content.Loader;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ListView;
import android.widget.TextView;

import com.estudiotrilha.android.widget.ExtensibleCursorAdapter;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.content.Event;
import com.estudiotrilha.inevent.service.SyncService;


public class EventListFragment extends ListFragment implements LoaderCallbacks<Cursor>, ExtensibleCursorAdapter.AdapterExtension
{
    // Loader codes
    private static final int LOAD_EVENT_LIST = 1;


    private ExtensibleCursorAdapter mListAdapter;

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);

        // Initialize the adapter
        int[] to = new int[] { R.id.event_name, R.id.event_description };
        String[] from = new String[] { Event.Columns.NAME, Event.Columns.DESCRIPTION };
        mListAdapter = new ExtensibleCursorAdapter(getActivity(), R.layout.cell_event_list_item, null, from, to, 0);
        mListAdapter.registerExtension(this);
    }
    @Override
    public void onViewCreated(View view, Bundle savedInstanceState)
    {
        super.onViewCreated(view, savedInstanceState);

        // Setup the list adapter
        setListAdapter(mListAdapter);
        
        setListShown(false);
    }
    @Override
    public void onStart()
    {
        super.onStart();
        getLoaderManager().initLoader(LOAD_EVENT_LIST, null, this);
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater)
    {
        inflater.inflate(R.menu.fragment_event_list, menu);
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
        // Open the event and show its activities
        Fragment fragment = EventActivitiesListFragment.instantiate(id);
        getFragmentManager().beginTransaction()
                .replace(R.id.mainContent, fragment)
                .addToBackStack(null)
                .commit();
    }
    private OnClickListener mInfoClickListener = new OnClickListener() {
        @Override
        public void onClick(View v)
        {
            // Get the view position
            int position = (Integer) v.getTag();
            // Get the event id
            long id = getListAdapter().getItemId(position);

            // Open up a dialog to show extra info about the event
            EventDetailDialogFragment fragment = EventDetailDialogFragment.instantiate(id);
            if (getResources().getBoolean(R.bool.useDialogs))
            {
                fragment.show(getFragmentManager(), null);
            }
            else
            {
                getFragmentManager().beginTransaction()
                        .replace(R.id.mainContent, fragment)
                        .addToBackStack(null)
                        .commit();
            }
        }
    };

    private void refresh()
    {
        // Download the event list
        getActivity().startService(new Intent(getActivity(), SyncService.class).setData(Event.CONTENT_URI));
    }


    // Loader callbacks
    @Override
    public Loader<Cursor> onCreateLoader(int code, Bundle args)
    {
        Uri uri = Event.CONTENT_URI;
        String[] projection = Event.Columns.PROJECTION_LIST;
        String selection = null;
        String[] selectionArgs = null;
        String sortOrder = null;

        return new CursorLoader(getActivity(), uri, projection, selection, selectionArgs, sortOrder);
    }
    @Override
    public void onLoadFinished(Loader<Cursor> loader, Cursor data)
    {
        // TODO Treat alternative cases (empty, no connection, etc)
        mListAdapter.swapCursor(data);

        setListShown(true);
    }
    @Override
    public void onLoaderReset(Loader<Cursor> loader)
    {
        mListAdapter.swapCursor(null);
    }


    @Override public void doBeforeBinding(View v, Context context, Cursor c) {}
    @Override
    public void doAfterBinding(View v, Context context, Cursor c)
    {
        // Set up the city and state
        TextView textView = (TextView) v.findViewById(R.id.event_city);
        String cityState = 
                c.getString(c.getColumnIndex(Event.Columns.CITY)) +
                " - " +
                c.getString(c.getColumnIndex(Event.Columns.STATE));

        if (cityState.length() > 7)
        {
            // Set the text only if there is a State and City defined
            textView.setText(cityState);
            textView.setVisibility(View.VISIBLE);
        }
        else
        {
            textView.setVisibility(View.GONE);
        }

        // Check the description
        textView = (TextView) v.findViewById(R.id.event_description);
        if (textView.getText().length() > 3)
        {
            textView.setVisibility(View.VISIBLE);
        }
        else
        {
            textView.setVisibility(View.GONE);
        }

        // Setup the info button
        View infoView = v.findViewById(R.id.event_info);
        infoView.setTag(c.getPosition());
        infoView.setOnClickListener(mInfoClickListener);
    }
}
