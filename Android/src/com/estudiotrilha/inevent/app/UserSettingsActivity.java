package com.estudiotrilha.inevent.app;

import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.TextView;

import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.content.LoginManager;
import com.google.analytics.tracking.android.EasyTracker;


public class UserSettingsActivity extends ActionBarActivity
{
    private LoginManager mLoginManager;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user_settings);
        mLoginManager = LoginManager.getInstance(this);

        // close this activity if we're not logged in
        if (!mLoginManager.isSignedIn()) finish();

        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        // fill up the user info
        ((TextView) findViewById(R.id.member_name)).setText(mLoginManager.getMember().name);
//        ((ImageView) view.findViewById(R.id.member_profilePicture)).setImageBitmap(null); TODO get the user photo
    }
    @Override
    protected void onStart()
    {
        super.onStart();
        if (!InEvent.DEBUG)
        {
            EasyTracker.getInstance().activityStart(this);
        }
    }
    @Override
    protected void onStop()
    {
        super.onStop();
        if (!InEvent.DEBUG)
        {
            EasyTracker.getInstance().activityStop(this);
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu)
    {
        getMenuInflater().inflate(R.menu.activity_user_settings, menu);
        return true;
    }
    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        super.onOptionsItemSelected(item);

        switch (item.getItemId())
        {
        case android.R.id.home:
            finish();
            break;

        case R.id.menu_signOut:
            // TODO confirmation dialog

            mLoginManager.signOut();
            finish();
            break;
        }

        return false;
    }
}
