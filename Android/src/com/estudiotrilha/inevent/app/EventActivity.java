package com.estudiotrilha.inevent.app;

import android.content.ContentUris;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.Menu;
import android.view.MenuItem;

import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.content.Event;
import com.estudiotrilha.inevent.content.EventMember;
import com.estudiotrilha.inevent.content.LoginManager;


public class EventActivity extends SlidingMenuBaseActivity
{
    // Tags
    public static final String TAG_ACTIVITY_PAGER = "tag.ACTIVITY_PAGER";

    // Extras
    private static final String EXTRA_EVENT_ID = "extra.EVENT_ID";


    public static Intent openEvent(Context c, long eventId)
    {
        Intent intent = new Intent(c, EventActivity.class);
        intent.putExtra(EXTRA_EVENT_ID, eventId);

        return intent;
    }


    private boolean mApproved = false;
    private int     mRoleId   = Event.ROLE_ATTENDEE;

    private LoginManager mLoginManager;


    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_event);

        mLoginManager = LoginManager.getInstance(this);

        long eventID = getIntent().getLongExtra(EXTRA_EVENT_ID, -1);
        if (savedInstanceState == null)
        {
            // Event activities Fragment
            Fragment fragment = EventActivitiesPagesFragment.instantiate(eventID);
            getSupportFragmentManager().beginTransaction()
                    .add(R.id.mainContent, fragment, TAG_ACTIVITY_PAGER)
                    .commit();
        }

        // Setup the title
        // Query the event name
        Cursor c = getContentResolver().query(ContentUris.withAppendedId(Event.CONTENT_URI, eventID), new String[] { Event.Columns.NAME_FULL }, null, null, null);
        if (c.moveToFirst())
        {
            getSupportActionBar().setSubtitle(c.getString(0));
        }
        c.close();
        // Add it to the action bar title

        if (mLoginManager.isSignedIn())
        {
            // Check the user role for this event

            // Get the info
            String selection = EventMember.Columns.EVENT_ID_FULL+"="+eventID+" AND "+EventMember.Columns.MEMBER_ID_FULL+"="+mLoginManager.getMember().memberId;
            c = getContentResolver().query(EventMember.CONTENT_URI, new String[] { EventMember.Columns.ROLE_ID }, selection, null, null);
            if (c.moveToFirst())
            {
                mRoleId = c.getInt(0);
            }
            else
            {
                mRoleId = Event.ROLE_ATTENDEE;
            }
            c.close();

             // Check if the user is approved for this event
            c = getContentResolver().query(ContentUris.withAppendedId(Event.CONTENT_URI, eventID), new String[]{ EventMember.Columns.APPROVED_FULL }, null, null, null);
            if (c.moveToFirst())
            {
                mApproved = (c.getInt(0) == 1);
            }
            c.close();
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu)
    {
        getMenuInflater().inflate(R.menu.activity_events, menu);
        return true;
    }
    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        switch (item.getItemId())
        {
        case android.R.id.home:
            // Go home! Clear the back stack
            if (getSupportFragmentManager().getBackStackEntryCount() != 0)
            {
                while(getSupportFragmentManager().popBackStackImmediate());
                return true;
            }
            break;

        case R.id.menu_eventDetails:
            // Open the details of the event
            startActivity(
                EventInfoActivity.newInstance(this,
                        getIntent().getLongExtra(EXTRA_EVENT_ID, -1),
                        mApproved,
                        mRoleId
                )
            );
            // set the transition animation
            overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
            return true;

        case R.id.menu_preferences:
            // Open the PreferencesActivity
            startActivity(new Intent(this, PreferencesActivity.class));
            return true;

        case R.id.menu_about:
            startActivity(new Intent(this, AboutActivity.class));
            return true;
        }

        return super.onOptionsItemSelected(item);
    }


    protected void refreshLoginState()
    {
        // Go back to the marketplace
        finish();
    }

    public int getRoleId()
    {
        return mRoleId;
    }
    public boolean isApproved()
    {
        return mApproved;
    }
}
