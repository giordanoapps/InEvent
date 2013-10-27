package com.estudiotrilha.inevent.app;

import com.estudiotrilha.android.widget.ViewToastManager;
import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.Utils;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.content.SyncBroadcastManager;
import com.google.analytics.tracking.android.EasyTracker;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewStub;
import android.view.Window;
import android.widget.ImageView;
import android.widget.TextView;

public abstract class BaseActivity extends ActionBarActivity
{
    private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent)
        {
            String action = intent.getAction();
            if (action.equals(SyncBroadcastManager.ACTION_SYNC))
            {
                setSupportProgressBarIndeterminateVisibility(SyncBroadcastManager.isSyncing());
            }
            else if (action.equals(LoginManager.ACTION_LOGIN_STATE_CHANGED))
            {
                refreshLoginState();
            }
            else if (action.equals(InEvent.ACTION_TOAST_NOTIFICATION))
            {
                // get the message
                int message = intent.getIntExtra(InEvent.EXTRA_TOAST_MESSAGE, 0);
                if (message <= 0) return;

                // display the notification toast
                showToast(message);
            }
        }
    };

    private ViewToastManager mToastManager;
    
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        originalSetContentView(R.layout.activity_base);
        supportRequestWindowFeature(Window.FEATURE_INDETERMINATE_PROGRESS);

        // start ImageLoader
        Utils.initImageLoader(this);

        // creates and setups the toast manager
        mToastManager = new ViewToastManager(this, (ViewGroup) findViewById(R.id.main_toastMessage));
        // Set the enter and leave animations for the custom toast
        mToastManager.setEnterAnimationResource(R.anim.toast_enter);
        mToastManager.setLeaveAnimationResource(R.anim.toast_leave);
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
    protected void onResume()
    {
        super.onResume();
        // register a broadcast
        IntentFilter filter = new IntentFilter(SyncBroadcastManager.ACTION_SYNC);
        filter.addAction(LoginManager.ACTION_LOGIN_STATE_CHANGED);
        filter.addAction(InEvent.ACTION_TOAST_NOTIFICATION);
        registerReceiver(mReceiver, filter);

        // set the sync status
        setSupportProgressBarIndeterminateVisibility(SyncBroadcastManager.isSyncing());
    }
    @Override
    protected void onPause()
    {
        super.onPause();
        // unregister listeners
        unregisterReceiver(mReceiver);
    }

    @Override
    public void setContentView(int layoutResId)
    {
        ViewStub viewStub = (ViewStub) findViewById(R.id.contentStub);
        viewStub.setLayoutResource(layoutResId);
        viewStub.inflate();
    }
    protected void originalSetContentView(int layoutRes)
    {
        super.setContentView(layoutRes);
    }


    // Custom toast
    public void showToast(CharSequence text, int duration)
    {
        showToast(text, -1, duration);
    }
    public void showToast(int text, int duration)
    {
        showToast(getText(text), duration);
    }
    public void showToast(int text)
    {
        showToast(text, ViewToastManager.LENGHT_SHORT);
    }
    public void showToast(CharSequence text, int image, int duration)
    {
        View v = getLayoutInflater().inflate(R.layout.toast_notification, null);
        ((TextView) v.findViewById(R.id.notificatoin_text)).setText(text);
        if (image > 0) ((ImageView) v.findViewById(R.id.notificatoin_image)).setImageResource(image);

        mToastManager.newMessage(v, duration);
    }


    /** Refresh the activity state according to a new login state */
    protected abstract void refreshLoginState();
}
