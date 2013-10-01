package com.estudiotrilha.inevent;

import org.apache.http.HttpStatus;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.preference.PreferenceManager;

import com.estudiotrilha.android.net.ConnectionHelper;
import com.estudiotrilha.inevent.app.PreferencesActivity;
import com.estudiotrilha.inevent.content.ApiRequestCode;
import com.nostra13.universalimageloader.cache.memory.impl.LRULimitedMemoryCache;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.ImageLoaderConfiguration;
import com.nostra13.universalimageloader.core.assist.QueueProcessingType;


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

    public static void initImageLoader(Context c)
    {
        // TODO configure image loader
        if (!ImageLoader.getInstance().isInited())
        {
            // Create default options which will be used for every displayImage(...) call
            DisplayImageOptions defaultOptions = new DisplayImageOptions.Builder()
                .cacheInMemory(true)
                .cacheOnDisc(true)
                .resetViewBeforeLoading(true)
                .showImageOnLoading(R.drawable.ic_logo_estudio_trilha)
                .showImageOnFail(R.drawable.ic_logo_in_event)
                .showImageForEmptyUri(R.drawable.ic_logo_in_event)
                .build();
            ImageLoaderConfiguration config = new ImageLoaderConfiguration.Builder(c.getApplicationContext())
                .tasksProcessingOrder(QueueProcessingType.LIFO)
                .defaultDisplayImageOptions(defaultOptions)
                .memoryCache(new LRULimitedMemoryCache(2 * 1024 * 1024 /* 2 MiB */))
                .build();
            ImageLoader.getInstance().init(config);
        }
    }


    public static int getBadResponseMessage(int requestCode, int responseCode)
    {
        int message = R.string.error_connection;

        // TODO treat other the responses
        switch (responseCode)
        {
        case ConnectionHelper.INTERNET_DISCONNECTED:
            message = R.string.error_connection_internetless;
            break;

        case HttpStatus.SC_UNAUTHORIZED:
            switch (requestCode)
            {
            case ApiRequestCode.MEMBER_SIGN_IN:
                // Bad credentials
                message = R.string.error_login_badCredentials;
                break;

            default:
                message = R.string.error_unauthorized;
                break;
            }
            break;

        case HttpStatus.SC_REQUEST_TIMEOUT:
            // Time out
            message = R.string.error_connection_timeout;
            break;
        }

        return message;
    }    
}
