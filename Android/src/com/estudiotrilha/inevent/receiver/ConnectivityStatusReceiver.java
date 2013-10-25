package com.estudiotrilha.inevent.receiver;

import com.estudiotrilha.inevent.service.UploaderService;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;


public class ConnectivityStatusReceiver extends BroadcastReceiver
{
    @Override
    public void onReceive(Context context, Intent intent)
    {
        UploaderService.sync(context);
    }
}
