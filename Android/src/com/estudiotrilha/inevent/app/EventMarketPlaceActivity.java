package com.estudiotrilha.inevent.app;

import com.estudiotrilha.inevent.R;

import android.os.Bundle;
import android.view.View;

public class EventMarketPlaceActivity extends SlidingMenuBaseActivity
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

    @Override protected void refreshLoginState() {}
}
