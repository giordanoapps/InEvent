package com.estudiotrilha.inevent.app;

import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.content.Event;

import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;


public class EventMarketplaceActivity extends SlidingMenuBaseActivity
{
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_event_marketplace);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu)
    {
        getMenuInflater().inflate(R.menu.activity_event_marketplace, menu);
        return true;
    }
    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        switch (item.getItemId())
        {
        case R.id.menu_about:
            startActivity(new Intent(this, AboutActivity.class));
            return true;

        case R.id.menu_preferences:
            // Open the PreferencesActivity
            startActivity(new Intent(this, PreferencesActivity.class));
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void events(View v)
    {
        closeSlidingMenu();
    }

    @Override
    protected void refreshLoginState()
    {
        // Tell the events to be refreshed
        getContentResolver().notifyChange(Event.CONTENT_URI, null);
    }
}
