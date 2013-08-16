package com.estudiotrilha.inevent.app;

import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.Utils;
import com.estudiotrilha.inevent.content.Event;

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
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.ViewAnimator;


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


    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        View view = inflater.inflate(R.layout.fragment_event_detail, container, false);
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
        // Clean the action bar
        menu.clear();
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
    public void onLoadFinished(Loader<Cursor> loader, Cursor data) // TODO finish this
    {
        if (!data.moveToFirst())
        {
            // TODO something is wrong!!
            return;
        }

        // Populate the view

        // Setup the title
        String title = data.getString(data.getColumnIndex(Event.Columns.NAME));
        if (getResources().getBoolean(R.bool.useDialogs))
        {
            getDialog().setTitle(title);
        }
        else
        {
            // There is no dialog
            ((ActionBarActivity) getActivity()).getSupportActionBar().setTitle(title);
        }

        ((TextView) getView().findViewById(R.id.event_description)).setText(data.getString(data.getColumnIndex(Event.Columns.DESCRIPTION)));
        ((TextView) getView().findViewById(R.id.event_address)).setText(data.getString(data.getColumnIndex(Event.Columns.ADDRESS)));

        // Show the results
        mViewAnimator.setDisplayedChild(Utils.VIEW_ANIMATOR_CONTENT);
    }
    @Override public void onLoaderReset(Loader<Cursor> data) {}
}
