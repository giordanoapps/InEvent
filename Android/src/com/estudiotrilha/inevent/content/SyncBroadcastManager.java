package com.estudiotrilha.inevent.content;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.estudiotrilha.inevent.InEvent;

public class SyncBroadcastManager
{
    // Broadcast
    public static final String ACTION_SYNC = InEvent.class.getPackage().getName()+".action.SYNC";


    private static final Intent sIntent    = new Intent(ACTION_SYNC);
    private static       short  sSyncCount = 0;


    public static void setSyncState(Context c, boolean syncing)
    {
        setSyncState(c, syncing, null);
    }
    public static void setSyncState(Context c, String message)
    {
        setSyncState(c, true, message);
    }
    public synchronized static void setSyncState(Context c, boolean syncing, String message)
    {
        if (syncing)
        {
            sSyncCount++;
            message = (message == null) ? "Syncing…" : message;
        }
        else
        {
            sSyncCount--;
            message = (message == null) ? "Done" : message;
        }

        Log.v(InEvent.NAME, message);

        // send the broadcast
        c.sendBroadcast(sIntent);
    }

    public static boolean isSyncing()
    {
        return sSyncCount > 0;
    }
}
