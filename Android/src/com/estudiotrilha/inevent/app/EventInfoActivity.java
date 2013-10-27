package com.estudiotrilha.inevent.app;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.view.MenuItem;

import com.estudiotrilha.inevent.R;


public class EventInfoActivity extends BaseActivity
{
    // Extras
    private static final String EXTRA_EVENT_ID       = "extra.EVENT_ID";
    private static final String EXTRA_EVENT_APPROVED = "extra.EVENT_APPROVED";
    private static final String EXTRA_EVENT_ROLE_ID  = "extra.EVENT_ROLE_ID";

    public static Intent newInstance(Context context, long eventID, boolean eventApproved, int eventRoleId)
    {
        Intent intent = new Intent(context, EventInfoActivity.class);
        intent.putExtra(EXTRA_EVENT_ID, eventID);
        intent.putExtra(EXTRA_EVENT_APPROVED, eventApproved);
        intent.putExtra(EXTRA_EVENT_ROLE_ID, eventRoleId);

        return intent;
    }


    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_event_info);

        if (savedInstanceState == null)
        {
            long eventID = getIntent().getLongExtra(EXTRA_EVENT_ID, -1);

            // Open up a dialog to show extra info about the event
            EventDetailDialogFragment fragment = EventDetailDialogFragment.instantiate(eventID);
            getSupportFragmentManager().beginTransaction()
                    .add(R.id.mainContent, fragment)
                    .commit();
        }
        
        ActionBar actionBar = getSupportActionBar();
        actionBar.setDisplayHomeAsUpEnabled(true);
        actionBar.setHomeButtonEnabled(true);
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        switch (item.getItemId())
        {
        case android.R.id.home:
            // Navigate up
            finish();
            // set the transition animation
            overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
            return true;
        }

        return super.onOptionsItemSelected(item);
    }


    @Override protected void refreshLoginState() {}
}
