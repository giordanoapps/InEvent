package com.estudiotrilha.inevent.app;

import java.io.Serializable;
import java.text.DateFormat;
import java.util.Calendar;
import java.util.Date;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.SectionIndexer;
import android.widget.TextView;

import com.estudiotrilha.android.utils.DateUtils;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.content.Event;
import com.estudiotrilha.inevent.content.LoginManager;


public class EventActivitiesListFragment extends Fragment implements OnItemClickListener, OnItemLongClickListener
{
    // Arguments
    private static final String ARGS_EVENT_ID    = "args.EVENT_ID";
    private static final String ARGS_LIST_HEADER = "args.LIST_HEADER";
    private static final String ARGS_LIST_DATA   = "args.LIST_DATA";


    public static EventActivitiesListFragment instantiate(long eventID, EventActivityInfo[] data, String header)
    {
        // Prepare the arguments
        Bundle args = new Bundle();
        args.putLong(ARGS_EVENT_ID, eventID);
        args.putString(ARGS_LIST_HEADER, header);
        args.putSerializable(ARGS_LIST_DATA, data);

        // Create the fragment
        EventActivitiesListFragment fragment = new EventActivitiesListFragment();
        fragment.setArguments(args);

        return fragment;
    }


    private EventActivitiesListAdapter mActivitiesAdapter;


    private EventActivity mEventActivity;


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

        // Setup the adapters
        mActivitiesAdapter = new EventActivitiesListAdapter();
        Serializable object = getArguments().getSerializable(ARGS_LIST_DATA);
        if (object != null && object instanceof EventActivityInfo[]) mActivitiesAdapter.setData((EventActivityInfo[]) object);
    }
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        return inflater.inflate(R.layout.fragment_event_activities_list, container, false);
    }
    @Override
    public void onViewCreated(View view, Bundle savedInstanceState)
    {
        super.onViewCreated(view, savedInstanceState);

        ListView list = (ListView) view.findViewById(android.R.id.list);

        // Setup callbacks
        list.setOnItemClickListener(this);
        list.setOnItemLongClickListener(this);
        

        // Add the list content
        list.setAdapter(mActivitiesAdapter);
        view.findViewById(mActivitiesAdapter.isEmpty() ? android.R.id.content : android.R.id.empty)
                .setVisibility(View.GONE);
        // Setup the list header
        String header = getArguments().getString(ARGS_LIST_HEADER);
        ((TextView) view.findViewById(R.id.activity_sectionHeader)).setText(header);
    }

    @Override
    public void onItemClick(AdapterView<?> adapter, View v, int position, long id)
    {
        // Show the Activity details
        mEventActivity.startActivity(EventActivityDetailActivity.newInstance(mEventActivity, id));
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

    public void updateContent(EventActivityInfo[] data)
    {
        // null check
        if (data == null) return;

        mActivitiesAdapter.setData(data);
        getArguments().putSerializable(ARGS_LIST_DATA, data);
    }


    class EventActivitiesListAdapter extends BaseAdapter implements SectionIndexer
    {
        private LayoutInflater      mInflater;
        private DateFormat          mTimeFormat;
        private EventActivityInfo[] mData;


        public EventActivitiesListAdapter()
        {
            this.mInflater = LayoutInflater.from(mEventActivity);

            // Get the user preferred date format
            mTimeFormat = android.text.format.DateFormat.getTimeFormat(mEventActivity);
        }

        public EventActivityInfo[] getData()
        {
            return mData;
        }
        public void setData(EventActivityInfo[] data)
        {
            mData = data;
            notifyDataSetChanged();
        }

        @Override
        public int getPositionForSection(int section)
        {
            return section;
        }
        @Override
        public int getSectionForPosition(int position)
        {
            return position;
        }
        @Override
        public Object[] getSections()
        {
            return mData;
        }

        @Override
        public int getCount()
        {
            return mData == null ? 0 : mData.length;
        }

        @Override
        public Object getItem(int position)
        {
            return position;
        }

        @Override
        public long getItemId(int position)
        {
            return mData[position].id;
        }
        @Override
        public boolean hasStableIds()
        {
            return true;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent)
        {
            if (convertView == null)
            {
                // Inflate the view
                convertView = mInflater.inflate(R.layout.cell_event_activity_item, parent, false);
            }

            // Layout the information
            // Activity name
            ((TextView) convertView.findViewById(R.id.activity_name)).setText(mData[position].name);
            ((TextView) convertView.findViewById(R.id.activity_location)).setText(mData[position].location);
            // Approved state
            if (LoginManager.getInstance(mEventActivity).isSignedIn())
            {
                // Set the color according to the approved state
                int color = 0;
                switch (mData[position].approved)
                {
                case -1:
                    color = getResources().getColor(R.color.light_gray);
                    break;
                case 0:
                    color = getResources().getColor(R.color.holo_red_dark);
                    break;
                case 1:
                    color = getResources().getColor(R.color.holo_green_dark);
                    break;
                }
                convertView.findViewById(R.id.activity_approved).setBackgroundColor(color);
            }
            // Setup the starting and ending time
            // Parse the dates
            Date dateBegin = DateUtils.calendarFromTimestampInGMT(mData[position].dateBegin).getTime();
            Date dateEnd = DateUtils.calendarFromTimestampInGMT(mData[position].dateEnd).getTime();
            // Setup the views
            ((TextView) convertView.findViewById(R.id.activity_dateBegin)).setText(mTimeFormat.format(dateBegin));
            ((TextView) convertView.findViewById(R.id.activity_dateEnd)).setText(mTimeFormat.format(dateEnd));

            return convertView;
        }
    }

    public static class EventActivityInfo implements Serializable
    {
        private static final long serialVersionUID = -8161997387511878223L;

        public final long   id;
        public final String name;
        public final String location;
        public final int    approved;
        public final long   dateBegin;
        public final long   dateEnd;

        public EventActivityInfo(long id, String name, String location, int approved, long dateBegin, long dateEnd)
        {
            this.id = id;
            this.name = name;
            this.location = location;
            this.approved = approved;
            this.dateBegin = dateBegin;
            this.dateEnd = dateEnd;
        }

        @Override
        public String toString()
        {
            Calendar date = DateUtils.calendarFromTimestampInGMT(dateBegin);
            return Integer.toString(date.get(Calendar.HOUR_OF_DAY));
        }
    }
}
