package com.estudiotrilha.inevent.app;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;

import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.service.DownloaderService;


public class PeopleActivity extends BaseActivity
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


    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
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
    @Override
    protected void refreshLoginState()
    {
        finish();
    }
}
