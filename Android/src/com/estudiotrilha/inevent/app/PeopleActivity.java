package com.estudiotrilha.inevent.app;

import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.content.SyncBroadcastManager;
import com.estudiotrilha.inevent.service.DownloaderService;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.Window;


public class PeopleActivity extends ActionBarActivity
{
    // Extra
    private static final String EXTRA_ACTIVITY_ID = "extra.ACTIVITY_ID";
    private static final String EXTRA_EVENT_ID    = "extra.EVENT_ID";

    public static Intent newInstance(Context context, long eventID, long activityID)
    {
        Intent intent = new Intent(context, PeopleActivity.class);
        intent.putExtra(EXTRA_EVENT_ID, eventID);
        intent.putExtra(EXTRA_ACTIVITY_ID, activityID);

        return intent;
    }


    private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent)
        {
            if (SyncBroadcastManager.ACTION_SYNC.equals(intent.getAction()))
            {
                setSupportProgressBarIndeterminateVisibility(SyncBroadcastManager.isSyncing());
            }
        }
    };


    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        supportRequestWindowFeature(Window.FEATURE_INDETERMINATE_PROGRESS);
        setContentView(R.layout.activity_people);

        // Download new data
        refresh();

        if (savedInstanceState == null)
        {
            getSupportFragmentManager().beginTransaction()
                    .add(R.id.mainContent, AttendanceFragment.instantiate(getIntent().getLongExtra(EXTRA_ACTIVITY_ID, -1), getIntent().getLongExtra(EXTRA_EVENT_ID, -1)))
                    .commit();
        }

        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
    }
    @Override
    protected void onStart()
    {
        super.onStart();
        // register a broadcast
        registerReceiver(mReceiver, new IntentFilter(SyncBroadcastManager.ACTION_SYNC));
    }
    @Override
    protected void onStop()
    {
        super.onStop();
        // unregister listeners
        unregisterReceiver(mReceiver);
    }
    @Override
    protected void onResume()
    {
        super.onResume();
        // Setup the loading status
        setSupportProgressBarIndeterminateVisibility(SyncBroadcastManager.isSyncing());
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu)
    {
        super.onCreateOptionsMenu(menu);
        getMenuInflater().inflate(R.menu.activity_people, menu);
        return true;
    }
    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        switch (item.getItemId())
        {
        case android.R.id.home:
            finish();
            return true;

        case R.id.menu_addPerson:
            AddPersonDialogFragment.instantiate(getIntent().getLongExtra(EXTRA_ACTIVITY_ID, -1))
                    .show(getSupportFragmentManager(), null);
            return true;

        case R.id.menu_refresh:
            refresh();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }


    public void refresh()
    {
        // Download the attenders
        DownloaderService.downloadEventActivityAttenders(this, getIntent().getLongExtra(EXTRA_EVENT_ID, -1), getIntent().getLongExtra(EXTRA_ACTIVITY_ID, -1));
    }
}
