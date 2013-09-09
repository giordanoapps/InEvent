package com.estudiotrilha.inevent.app;


import java.util.Locale;

import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.BaseColumns;
import android.support.v4.app.ListFragment;
import android.support.v4.app.LoaderManager.LoaderCallbacks;
import android.support.v4.content.CursorLoader;
import android.support.v4.content.Loader;
import android.support.v4.view.MenuItemCompat;
import android.support.v7.app.ActionBarActivity;
import android.support.v7.widget.SearchView;
import android.text.InputType;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.animation.AnimationUtils;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.Filter;
import android.widget.ListView;
import android.widget.SectionIndexer;
import android.widget.TextView;

import com.estudiotrilha.android.widget.ExtensibleCursorAdapter;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.Utils;
import com.estudiotrilha.inevent.content.Activity;
import com.estudiotrilha.inevent.content.ActivityMember;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.content.Member;
import com.estudiotrilha.inevent.service.SyncService;
import com.fortysevendeg.swipelistview.BaseSwipeListViewListener;
import com.fortysevendeg.swipelistview.SwipeListView;


public class AttendanceFragment extends ListFragment implements LoaderCallbacks<Cursor>, OnItemLongClickListener
{
    // Loader coder
    private static final int LOAD_PEOPLE = 1;

    // Instance State
    private static final String STATE_DOWNLOAD_ATTEMPT = "state.DOWNLOAD_ATTEMPT";

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


    private PeopleAdapter mPeopleAdapter;
    private Filter        mPeopleFilter;
    private SearchView    mSearchView;
    private SwipeListView mListView;

    private int mIndexId;
    private int mIndexName;
    private int mIndexPresent;

    private int  mDownloadAttempt;


    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);

        // Download new data
        refresh();

        if (savedInstanceState != null)
        {
            mDownloadAttempt = savedInstanceState.getInt(STATE_DOWNLOAD_ATTEMPT);
        }

        // Setup the adapter
        mPeopleAdapter = new PeopleAdapter(getActivity());
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

        // Setup the filter
        mPeopleFilter = new Filter() {
            // The query basic info
            final Uri      uri           = ActivityMember.CONTENT_URI;
            final String[] projection    = ActivityMember.Columns.PROJECTION_ATTENDANCE_LIST;
            final String   selection     = ActivityMember.Columns.ACTIVITY_ID_FULL+" = "+ getArguments().getLong(ARGS_ACTIVITY_ID)+
                    " AND "+ActivityMember.Columns.APPROVED_FULL +" = 1"+
                    " AND "+Member.Columns._ID_FULL+" LIKE ?";
            final String[] selectionArgs = new String[1];
            final String   sortOrder     = Member.TABLE_NAME+"."+Member.Columns.NAME + " ASC";


            @Override
            protected void publishResults(CharSequence constraint, FilterResults results)
            {
                Cursor c = (Cursor) results.values;

                ListView list = getListView();
                if (c.moveToFirst() && list != null)
                {
                    long id = c.getLong(c.getColumnIndex(BaseColumns._ID));
                    int position = mPeopleAdapter.getPositionForId(id);

                    list.setSelection(position);
                }
            }
            @Override
            protected FilterResults performFiltering(CharSequence constraint)
            {
                selectionArgs[0] = constraint.toString();
                Cursor cursor = getActivity().getContentResolver().query(uri, projection, selection, selectionArgs, sortOrder);

                FilterResults results = new FilterResults();

                results.count = cursor.getCount();
                results.values = cursor;

                return results;
            }
        };
    }
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        return inflater.inflate(R.layout.fragment_attendance, container, false);
    }
    @Override
    public void onViewCreated(View view, Bundle savedInstanceState)
    {
        super.onViewCreated(view, savedInstanceState);
        // Add the adapter to the list
        setListAdapter(mPeopleAdapter);
        mListView = (SwipeListView) getListView();
        mListView.getViewTreeObserver().addOnPreDrawListener(new ViewTreeObserver.OnPreDrawListener() {
            @Override
            public boolean onPreDraw()
            {
                // Calculate the left and right offset
                int width = mListView.getWidth();
                if (width > 0)
                {
                    // Do this once for every time the view is created
                    mListView.getViewTreeObserver().removeOnPreDrawListener(this);

                    float offset = width - getResources().getDimension(R.dimen.attender_backView_text_width);
                    mListView.setOffsetLeft(offset);
                    mListView.setOffsetRight(offset);
                }

                return true;
            }
        });
        mListView.setSwipeListViewListener(new BaseSwipeListViewListener() {
            @Override
            public void onOpened(int position, boolean toRight)
            {
                setPresence(mPeopleAdapter.getItemId(position), toRight);
            }

            public void onListChanged()
            {
                mListView.closeOpenedItems();
            }
        });

        // Setup the click listener
        getListView().setOnItemLongClickListener(this);

        // Set the title
        Cursor c = getActivity().getContentResolver()
                .query(ContentUris.withAppendedId(Activity.ACTIVITY_CONTENT_URI, getArguments().getLong(ARGS_ACTIVITY_ID)), new String[] { Activity.Columns.NAME_FULL }, null, null, null);
        if (c.moveToFirst())
        {
            ((ActionBarActivity) getActivity()).setTitle(c.getString(0));
        }
        c.close();
    }
    @Override
    public void onStart()
    {
        super.onStart();
        // Start loading the content
        setListShown(false);
        getLoaderManager().initLoader(LOAD_PEOPLE, null, this);
    }

    @Override
    public void onSaveInstanceState(Bundle outState)
    {
        super.onSaveInstanceState(outState);
        outState.putInt(STATE_DOWNLOAD_ATTEMPT, mDownloadAttempt);
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater)
    {
        inflater.inflate(R.menu.fragment_attendance, menu);

        // Setup the search text entry
        MenuItem searchItem = menu.findItem(R.id.menu_search);
        mSearchView = (SearchView) MenuItemCompat.getActionView(searchItem);
        mSearchView.setInputType(InputType.TYPE_CLASS_NUMBER);
        mSearchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override public boolean onQueryTextSubmit(String query) { return false; }
            @Override
            public boolean onQueryTextChange(String newText)
            {
                mPeopleFilter.filter(newText);
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
    public boolean onItemLongClick(AdapterView<?> adapter, View v, int position, long id)
    {
        setPresence(id, true);
        return true;
    }

    private void setPresence(final long memberID, boolean present)
    {
        // Clear the query text
        mSearchView.setQuery("", false);

        // And add this to the queue to be sent to the server
        LoginManager.getInstance(getActivity())
                .setPresence(getArguments().getLong(ARGS_ACTIVITY_ID), memberID, present);

        // Notify the change content
        mPeopleAdapter.notifyDataSetChanged();
    }

    @Override
    public void setListShown(boolean shown)
    {
        View rootView = getView();

        // null check
        if (rootView == null) return;

        View progress = rootView.findViewById(android.R.id.progress);

        int progressAnimation;
        int listAnimation;
        int progressVisibility;
        int listVisibility;
        if (shown)
        {
            progressAnimation = android.R.anim.fade_out;
            listAnimation = android.R.anim.fade_in;

            progressVisibility = View.GONE;
            listVisibility = View.VISIBLE;
        }
        else
        {
            progressAnimation = android.R.anim.fade_in;
            listAnimation = android.R.anim.fade_out;

            progressVisibility = View.VISIBLE;
            listVisibility = View.GONE;
        }

        // Skip unnecessary work
        if (mListView.getVisibility() == listVisibility) return;

        // Animate the change
        progress.startAnimation(AnimationUtils.loadAnimation(getActivity(), progressAnimation));
        mListView.startAnimation(AnimationUtils.loadAnimation(getActivity(), listAnimation));
        // Set the proper display parameters
        progress.setVisibility(progressVisibility);
        mListView.setVisibility(listVisibility);
    }

    private void refresh()
    {
        // Download the attenders
        SyncService.syncEventActivityAttenders(getActivity(), getArguments().getLong(ARGS_EVENT_ID), getArguments().getLong(ARGS_ACTIVITY_ID));
    }


    // Loader callbacks
    @Override
    public Loader<Cursor> onCreateLoader(int code, Bundle args)
    {
        Uri uri = ActivityMember.CONTENT_URI;
        String[] projection = ActivityMember.Columns.PROJECTION_ATTENDANCE_LIST;
        String selection = ActivityMember.Columns.ACTIVITY_ID_FULL+" = "+getArguments().getLong(ARGS_ACTIVITY_ID) +
                " AND "+ ActivityMember.Columns.APPROVED_FULL +" = 1";
        String[] selectionArgs = null;
        String sortOrder = Member.TABLE_NAME+"."+Member.Columns.NAME + " COLLATE NOCASE ASC";

        return new CursorLoader(getActivity(), uri, projection, selection, selectionArgs, sortOrder);
    }
    @Override
    public void onLoadFinished(Loader<Cursor> loader, Cursor data)
    {
        // Update the indexes
        mIndexId = data.getColumnIndex(ActivityMember.Columns._ID);
        mIndexName = data.getColumnIndex(Member.Columns.NAME);
        mIndexPresent = data.getColumnIndex(ActivityMember.Columns.PRESENT);

        mPeopleAdapter.swapCursor(data);
        
        if (mPeopleAdapter.getCount() < 3 && Utils.checkConnectivity(getActivity()) && mDownloadAttempt < Utils.MAX_DOWNLOAD_ATTEMPTS)
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
        mPeopleAdapter.swapCursor(null);
    }


    class PeopleAdapter extends ExtensibleCursorAdapter implements SectionIndexer
    {
        private int[]       mSectionPosition = new int[26];
        private Character[] mSections        = new Character[26];

        public PeopleAdapter(Context context)
        {
            super(context, R.layout.cell_attender_item, null, new String[] { Member.Columns.NAME }, new int[] { R.id.member_name }, 0);

            for (int i = 0; i < mSections.length; i++)
            {
                mSections[i] = (char) ('A' + i);
                mSectionPosition[i] = 0;
            }
        }

        @Override
        public Cursor swapCursor(Cursor c)
        {
            if (c != null)
            {
                // Build up the sections
                int position = 0;

                c.moveToPosition(-1);
                while(c.moveToNext())
                {
                    char firstLetter = c.getString(mIndexName).toUpperCase(Locale.getDefault()).charAt(0);

                    if (firstLetter < mSections[position])
                    {
                        continue;
                    }

                    mSectionPosition[position] = c.getPosition();
                    position++;
                }

                // Fill up the reaming section positions
                while (position < mSectionPosition.length)
                {
                    mSectionPosition[position] = c.getPosition();
                    position++; 
                }
            }

            return super.swapCursor(c);
        }

        @Override
        public int getPositionForSection(int section)
        {
            return mSectionPosition[section];
        }

        @Override
        public int getSectionForPosition(int position)
        {
            Cursor c = getCursor();
            c.moveToPosition(position);
            char firstLetter = c.getString(mIndexName).toUpperCase(Locale.getDefault()).charAt(0);

            return firstLetter - 'A';
        }

        @Override
        public Object[] getSections()
        {
            return mSections;
        }

        public int getPositionForId(long id)
        {
            Cursor c = getCursor();
            c.moveToPosition(-1);
            while (c.moveToNext())
            {
                if (c.getLong(mIndexId) == id)
                {
                    break;
                }
            }

            return c.getPosition();
        }
    }
}
