package com.estudiotrilha.inevent;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.preference.PreferenceManager;

import com.estudiotrilha.inevent.app.PreferencesActivity;


public class Utils
{
    public static final short VIEW_ANIMATOR_LOADING = 0;
    public static final short VIEW_ANIMATOR_CONTENT = 1;
    public static final short VIEW_ANIMATOR_MESSAGE = 2;
    public static final short VIEW_ANIMATOR_ERROR   = 3;

    public static final int MAX_DOWNLOAD_ATTEMPTS = 5;


    public static boolean checkConnectivity(Context c)
    {
        ConnectivityManager connectivityManager = (ConnectivityManager) c.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo info = connectivityManager.getActiveNetworkInfo();

        if (info != null && info.isConnected() && info.isAvailable())
        {
            boolean useMobile = PreferenceManager.getDefaultSharedPreferences(c).getBoolean(PreferencesActivity.USE_MOBILE_CONNECTION, true);
            if (useMobile || (info.getType() == ConnectivityManager.TYPE_WIFI))
            {
                return true;
            }
        }

        return false;
    }
}
