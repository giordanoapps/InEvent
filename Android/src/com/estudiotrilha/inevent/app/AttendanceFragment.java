package com.estudiotrilha.inevent.app;


import java.util.Locale;

import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.BaseColumns;
import android.support.v4.app.Fragment;
import android.support.v4.app.LoaderManager.LoaderCallbacks;
import android.support.v4.content.CursorLoader;
import android.support.v4.content.Loader;
import android.support.v7.app.ActionBarActivity;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.EditText;
import android.widget.Filter;
import android.widget.ListView;
import android.widget.SectionIndexer;
import android.widget.TextView;
import android.widget.ViewAnimator;

import com.estudiotrilha.android.widget.ExtensibleCursorAdapter;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.Utils;
import com.estudiotrilha.inevent.content.Activity;
import com.estudiotrilha.inevent.content.ActivityMember;
import com.estudiotrilha.inevent.content.Member;
import com.estudiotrilha.inevent.service.UploaderService;


public class AttendanceFragment extends Fragment implements LoaderCallbacks<Cursor>, OnClickListener, OnItemClickListener, OnItemLongClickListener
{
    private static final int DOUBLE_CLICK_INTERVAL = 600; // in milliseconds

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
    private EditText      mSearchView;
    private ListView      mListView;

    private int mIndexId;
    private int mIndexName;
    private int mIndexPresent;

    private int  mDownloadAttempt;

    private int  mQueyItemPosition;
    private long mLastClickId;
    private long mLastClickTime;


    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

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

                if (c.moveToFirst() && mListView != null)
                {
                    long id = c.getLong(c.getColumnIndex(BaseColumns._ID));
                    mQueyItemPosition = mPeopleAdapter.getPositionForId(id);

                    mListView.setSelection(mQueyItemPosition);
                }
                else
                {
                    mQueyItemPosition = -1;
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
        view.setBackgroundResource(R.color.app_windownBackground);
        mListView = (ListView) view.findViewById(android.R.id.list);

        // Add the adapter to the list
        mListView.setAdapter(mPeopleAdapter);

        // Setup the click listener
        mListView.setOnItemLongClickListener(this);

        // Set the title
        Cursor c = getActivity().getContentResolver()
                .query(ContentUris.withAppendedId(Activity.CONTENT_URI, getArguments().getLong(ARGS_ACTIVITY_ID)), new String[] { Activity.Columns.NAME_FULL }, null, null, null);
        if (c.moveToFirst())
        {
            ((ActionBarActivity) getActivity()).setTitle(c.getString(0));
        }
        c.close();

        // Setup the search
        mSearchView = (EditText) view.findViewById(R.id.attendance_searchBox);
        mSearchView.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event)
            {
                if (actionId == EditorInfo.IME_ACTION_GO)
                {
                    // Behave as if the confirm presence button was pressed
                    onClick(v);
                    return true;
                }
                return false;
            }
        });
        mSearchView.addTextChangedListener(new TextWatcher() {
            @Override
            public void afterTextChanged(Editable s)
            {
                mPeopleFilter.filter(s);
            }
            @Override public void onTextChanged(CharSequence s, int start, int before, int count) {}
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
        });
        view.findViewById(R.id.attendance_confirmPresence).setOnClickListener(this);
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
    public void onClick(View v)
    {
        if (mListView != null && mQueyItemPosition > 0)
        {
            setPresence(mPeopleAdapter.getItemId(mQueyItemPosition), !mPeopleAdapter.isPresent(mQueyItemPosition));
        }
    }
    @Override
    public void onItemClick(AdapterView<?> adapter, View v, int position, long id)
    {
        long currentTime = System.currentTimeMillis();
        if (id == mLastClickId && mLastClickTime + DOUBLE_CLICK_INTERVAL > currentTime)
        {
            setPresence(id, !mPeopleAdapter.isPresent(position));
            id = -1;
        }

        mLastClickId = id;
        mLastClickTime = currentTime;
    }
    @Override
    public boolean onItemLongClick(AdapterView<?> adapter, View v, int position, long id)
    {
        setPresence(id, !mPeopleAdapter.isPresent(position));
        return true;
    }

    private void setPresence(final long memberID, boolean present)
    {
        // Clear the query text
        mSearchView.setText("");
        mQueyItemPosition = -1;

        // Mark the presence
        UploaderService.markPresenceForActivity(getActivity(), getArguments().getLong(ARGS_ACTIVITY_ID), memberID, present);

        // Update the list
        mPeopleAdapter.notifyDataSetChanged();
    }

    private void setListShown(boolean shown)
    {
        View view = getView();
        if (view != null)
        {
            ((ViewAnimator) view.findViewById(R.id.viewAnimator)).setDisplayedChild(shown ? Utils.VIEW_ANIMATOR_CONTENT : Utils.VIEW_ANIMATOR_LOADING);
        }
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
            ((PeopleActivity) getActivity()).refresh();
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
                    char firstLetter = c.getString(mIndexName)
                            .toUpperCase(Locale.getDefault())
                            .charAt(0);

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

        protected boolean isPresent(int position)
        {
            mCursor.moveToPosition(position);
            return mCursor.getInt(mIndexPresent) == 1;
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
            // Null check
            if (c == null) return -1;

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
