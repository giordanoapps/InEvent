package com.estudiotrilha.inevent.receiver;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.text.Html;
import android.util.Log;

import com.estudiotrilha.inevent.InEvent;


public class PushNotificationReceiver extends BroadcastReceiver
{
    public static final String PUSH_NOTIFICATION = InEvent.class.getPackage().getName() + ".PUSH_NOTIFICATION";

    private static final String PARSE_CHANNEL = "com.parse.Channel";
    private static final String PARSE_DATA    = "com.parse.Data";

    public static final char PARSE_CHANNEL_SEPARATOR = '_';
    public static final char PARSE_URI_SEPARATOR     = '/';

    public static final String PARSE_URI   = "uri";
    public static final String PARSE_VALUE = "value";


    @Override
    public void onReceive(Context context, Intent intent)
    {
        // null check
        if (intent == null || !PUSH_NOTIFICATION.equals(intent.getAction())) return;

        // Parse the JSON
        JSONObject json = null;
        try
        {
            json = new JSONObject(intent.getExtras().getString(PARSE_DATA));
            String uri = Html.fromHtml(json.getString("uri")).toString();

            handleUri(context, uri);
        }
        catch (JSONException e)
        {
            Log.e(InEvent.NAME, "Error parsing json="+json, e);
        }
        catch (NullPointerException e)
        {
            Log.e(InEvent.NAME, "Error parsing uri! json="+json, e);
        }
        catch (Exception e)
        {
            Log.e(InEvent.NAME, "Something weird happened!", e);
        }
    }


    private void handleUri(Context context, String uri)
    {
        // TODO Auto-generated method stub
        
    }
}
