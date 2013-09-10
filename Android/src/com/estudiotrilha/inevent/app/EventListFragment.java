package com.estudiotrilha.inevent.app;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
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
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.ListView;
import android.widget.TextView;

import com.estudiotrilha.android.utils.DateUtils;
import com.estudiotrilha.android.widget.ExtensibleCursorAdapter;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.Utils;
import com.estudiotrilha.inevent.content.Event;
import com.estudiotrilha.inevent.content.EventMember;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.service.SyncService;


public class EventListFragment extends ListFragment implements LoaderCallbacks<Cursor>, ExtensibleCursorAdapter.AdapterExtension, OnItemLongClickListener
{
    // Loader codes
    private static final int LOAD_EVENT_LIST = 1;

    // Instance State
    private static final String STATE_DOWNLOAD_ATTEMPT = "state.DOWNLOAD_ATTEMPT";


    private ExtensibleCursorAdapter mListAdapter;
    private DateFormat              mTimeFormat;
    private int                     mDownloadAttempt;

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);

        if (savedInstanceState != null)
        {
            mDownloadAttempt = savedInstanceState.getInt(STATE_DOWNLOAD_ATTEMPT);
        }

        // Initialize the adapter
        int[] to = new int[] { R.id.event_name, R.id.event_description };
        String[] from = new String[] { Event.Columns.NAME, Event.Columns.DESCRIPTION };
        mListAdapter = new ExtensibleCursorAdapter(getActivity(), R.layout.cell_event_list_item, null, from, to, 0);
        mListAdapter.registerExtension(this);

        // Setup the time formatter
        char[] dateOrder = android.text.format.DateFormat.getDateFormatOrder(getActivity());
        String format;
        if (dateOrder[0] == 'd' || (dateOrder[0] != 'M' && dateOrder[1] == 'd'))
        {
            // Day, month
            format = "d, MMM";
        }
        else
        {
            // Month, day
            format = "MMM, d";
        }
        mTimeFormat = new SimpleDateFormat(format, Locale.getDefault());
    }
    @Override
    public void onViewCreated(View view, Bundle savedInstanceState)
    {
        super.onViewCreated(view, savedInstanceState);

        // Setup the list
        getListView().setDivider(null);
        getListView().setSelector(new ColorDrawable(Color.TRANSPARENT));
        getListView().setOnItemLongClickListener(this);

        // Setup the list adapter
        setListAdapter(mListAdapter);

        // Set the empty text message
        setEmptyText(getText(R.string.empty_eventList));
        // and loading status
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
    public void onSaveInstanceState(Bundle outState)
    {
        super.onSaveInstanceState(outState);
        outState.putInt(STATE_DOWNLOAD_ATTEMPT, mDownloadAttempt);
    }

    @Override
    public void onListItemClick(ListView l, View v, int position, long id)
    {
        // Open the event
        Intent event = EventActivity.openEvent(getActivity(), id);
        getActivity().startActivity(event);
    }
    @Override
    public boolean onItemLongClick(AdapterView<?> adapter, View v, int position, final long eventId)
    {
        // TODO make it possible to register through this interface
        return false;
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
        SyncService.syncEvents(getActivity());
    }


    // Loader callbacks
    @Override
    public Loader<Cursor> onCreateLoader(int code, Bundle args)
    {
        Uri uri = Event.CONTENT_URI;
        String[] projection = Event.Columns.PROJECTION_LIST;
        String selection = null;
        String[] selectionArgs = null;
        String sortOrder = Event.Columns.DATE_BEGIN_FULL+" DESC";

        return new CursorLoader(getActivity(), uri, projection, selection, selectionArgs, sortOrder);
    }
    @Override
    public void onLoadFinished(Loader<Cursor> loader, Cursor data)
    {
        mListAdapter.swapCursor(data);
        if (mListAdapter.isEmpty() && Utils.checkConnectivity(getActivity()) && mDownloadAttempt < Utils.MAX_DOWNLOAD_ATTEMPTS)
        {
            mDownloadAttempt++;
            refresh();
        }
        else
        {
            setListShown(true);
        }
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


        // Setup the starting and ending time

        // Parse the dates
        Calendar calendarBegin = DateUtils.calendarFromTimestampInGMT(c.getLong(c.getColumnIndex(Event.Columns.DATE_BEGIN)));
        Calendar calendarEnd = DateUtils.calendarFromTimestampInGMT(c.getLong(c.getColumnIndex(Event.Columns.DATE_END)));
        Date dateBegin = calendarBegin.getTime();
        Date dateEnd = calendarEnd.getTime();

        // Setup the views
        ((TextView) v.findViewById(R.id.event_dateBegin)).setText(mTimeFormat.format(dateBegin));
        TextView endDateView = (TextView) v.findViewById(R.id.event_dateEnd);
        endDateView.setText(mTimeFormat.format(dateEnd));

        // Adjust the time zone
        calendarBegin.setTimeZone(TimeZone.getDefault());
        calendarEnd.setTimeZone(TimeZone.getDefault());

        // Don't display the end day if it's a one day event
        boolean sameDay = calendarBegin.get(Calendar.DAY_OF_YEAR) == calendarEnd.get(Calendar.DAY_OF_YEAR)
                && calendarBegin.get(Calendar.YEAR) == calendarEnd.get(Calendar.YEAR);
        endDateView.setVisibility(sameDay ? View.INVISIBLE : View.VISIBLE);


        if (LoginManager.getInstance(context).isSignedIn())
        {
            // Setup whether the user is approved or not
            v.findViewById(R.id.event_approved).setVisibility(c.getInt(c.getColumnIndex(EventMember.Columns.APPROVED)) == 1 ? View.VISIBLE : View.INVISIBLE);
        }
    }
}
