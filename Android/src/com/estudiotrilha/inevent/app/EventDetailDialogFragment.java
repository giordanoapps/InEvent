package com.estudiotrilha.inevent.app;

import java.text.DateFormat;
import java.util.Date;

import android.content.ContentUris;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.LoaderManager.LoaderCallbacks;
import android.support.v4.content.CursorLoader;
import android.support.v4.content.Loader;
import android.support.v7.app.ActionBarActivity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.ViewAnimator;

import com.estudiotrilha.android.utils.DateUtils;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.Utils;
import com.estudiotrilha.inevent.content.Event;
import com.estudiotrilha.inevent.content.Image;
import com.nostra13.universalimageloader.core.ImageLoader;


public class EventDetailDialogFragment extends DialogFragment implements LoaderCallbacks<Cursor>
{
    // Loader codes
    private static final int LOAD_EVENT_DETAIL = 1;

    // Arguments
    private static final String ARGS_EVENT_ID = "args.EVENT_ID";

    public static EventDetailDialogFragment instantiate(long eventID)
    {
        // Prepare the arguments
        Bundle args = new Bundle();
        args.putLong(ARGS_EVENT_ID, eventID);

        // Create the fragment
        EventDetailDialogFragment fragment = new EventDetailDialogFragment();
        fragment.setArguments(args);

        return fragment;
    }


    private ViewAnimator mViewAnimator;
    private DateFormat   mDateFormat;
    private DateFormat   mTimeFormat;


    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
        mDateFormat = android.text.format.DateFormat.getDateFormat(getActivity());
        mTimeFormat = android.text.format.DateFormat.getTimeFormat(getActivity());
    }
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        View view = inflater.inflate(R.layout.fragment_event_detail, container, false);
//        if (!getResources().getBoolean(R.bool.useDialogs))
//        {
            view.setBackgroundResource(R.color.app_windownBackground);
//        }
        mViewAnimator = (ViewAnimator) view.findViewById(R.id.event_detail_container);
        return view;
    }
    @Override
    public void onStart()
    {
        super.onStart();
        getLoaderManager().initLoader(LOAD_EVENT_DETAIL, null, this);
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater)
    {
        super.onCreateOptionsMenu(menu, inflater);
        // XXX add the edit option
    }
    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        return super.onOptionsItemSelected(item);
    }


    // Loader callbacks
    @Override
    public Loader<Cursor> onCreateLoader(int code, Bundle args)
    {
        Uri uri = ContentUris.withAppendedId(Event.CONTENT_URI, getArguments().getLong(ARGS_EVENT_ID));
        String[] projection = Event.Columns.PROJECTION_DETAIL;
        String selection = null;
        String[] selectionArgs = null;
        String sortOrder = null;

        return new CursorLoader(getActivity(), uri, projection, selection, selectionArgs, sortOrder);
    }
    @Override
    public void onLoadFinished(Loader<Cursor> loader, final Cursor data)
    {
        // Populate the view
        data.moveToFirst();

        // Setup the title
        String title = data.getString(data.getColumnIndex(Event.Columns.NAME));
//        if (getResources().getBoolean(R.bool.useDialogs))
//        {
//            getDialog().setTitle(title);
//        }
//        else
//        {
            // There is no dialog
            ((ActionBarActivity) getActivity()).getSupportActionBar().setTitle(title);
//        }

        // Cover
        ImageLoader.getInstance().displayImage(
                Image.getImageLink(data.getString(data.getColumnIndex(Event.Columns.COVER))),
                ((ImageView) getView().findViewById(R.id.event_cover))
        );
        // Description
        ((TextView) getView().findViewById(R.id.event_description)).setText(data.getString(data.getColumnIndex(Event.Columns.DESCRIPTION)));
        // Address
        TextView address = (TextView) getView().findViewById(R.id.event_address);
        final String location = data.getString(data.getColumnIndex(Event.Columns.ADDRESS));
        address.setText(location);
        address.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v)
            {
                // Show the map
                LocationMapFragment fragment = LocationMapFragment.instantiate(location,
                        data.getDouble(data.getColumnIndex(Event.Columns.LATITUDE)),
                        data.getDouble(data.getColumnIndex(Event.Columns.LONGITUDE))
                );
                getFragmentManager().beginTransaction()
                        .add(R.id.mainContent, fragment)
                        .addToBackStack(null)
                        .commit();
            }
        });
        // Date
        Date dateBegin = DateUtils.calendarFromTimestampInGMT(data.getLong(data.getColumnIndex(Event.Columns.DATE_BEGIN))).getTime();
        ((TextView) getView().findViewById(R.id.event_dateBegin))
            .setText(mDateFormat.format(dateBegin)+" "+getText(R.string.raw_time_at)+" "+mTimeFormat.format(dateBegin));

        // Show the results
        mViewAnimator.setDisplayedChild(Utils.VIEW_ANIMATOR_CONTENT);
    }
    @Override public void onLoaderReset(Loader<Cursor> data) {}
}
