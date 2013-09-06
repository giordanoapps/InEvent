package com.estudiotrilha.inevent.app;

import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.content.Event;

import android.os.Bundle;
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
