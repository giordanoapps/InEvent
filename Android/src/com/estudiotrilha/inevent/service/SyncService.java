package com.estudiotrilha.inevent.service;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.util.ArrayList;

import org.apache.http.HttpStatus;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.IntentService;
import android.content.ContentProviderOperation;
import android.content.ContentValues;
import android.content.Intent;
import android.content.OperationApplicationException;
import android.net.Uri;
import android.os.RemoteException;
import android.util.Log;

import com.estudiotrilha.android.utils.JsonUtils;
import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.Utils;
import com.estudiotrilha.inevent.content.Activity;
import com.estudiotrilha.inevent.content.ApiRequest;
import com.estudiotrilha.inevent.content.Event;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.content.Member;
import com.estudiotrilha.inevent.content.SyncBroadcastManager;
import com.estudiotrilha.inevent.provider.InEventProvider;


public class SyncService extends IntentService implements ApiRequest.ResponseHandler
{
    public static final String SERVICE_NAME = InEvent.NAME + "." + SyncService.class.getSimpleName();

    public static final String EXTRA_EVENT_ID = "extra.EVENT_ID";

    public SyncService()
    {
        super(SERVICE_NAME);
    }


    private Intent mIntent;

    @Override
    protected void onHandleIntent(Intent intent)
    {
        mIntent = intent;

        if (!Utils.checkConnectivity(this))
        {
            // send a broadcast telling that there is no connection
//            sendBroadcast(new Intent(InEvent.ACTION_TOAST_NOTIFICATION).putExtra(InEvent.EXTRA_TOAST_MESSAGE, R.string.message_noConnection)); XXX
            return;
        }

        Uri data = intent.getData();
        int code = InEventProvider.uriMatcher.match(data);

        Log.v(InEvent.NAME, "Downloading " + data);

        switch (code)
        {
        case InEventProvider.URI_EVENT:
        {
            SyncBroadcastManager.setSyncState(this, "Syncing Events");

            try
            {
                String tokenID = LoginManager.getInstance(this).getTokenId();
                HttpURLConnection connection = Member.Api.getEvents(tokenID);
                ApiRequest.getJsonFromConnection(code, connection, this, false);
            }
            catch (IOException e)
            {
                Log.e(InEvent.NAME, "Couldn't create connection for person.getEvents(tokenID)", e);
            }

            // stop the sync state
            SyncBroadcastManager.setSyncState(this, false);
            break;
        }

        case InEventProvider.URI_ACTIVITY:
        {
            SyncBroadcastManager.setSyncState(this, "Syncing Activities");

            try
            {
                long eventID = intent.getLongExtra(EXTRA_EVENT_ID, -1);
                HttpURLConnection connection = Event.Api.getActivities(eventID);
                ApiRequest.getJsonFromConnection(code, connection, this, false);
            }
            catch (IOException e)
            {
                Log.e(InEvent.NAME, "Couldn't create connection for event.getActivities(eventID)", e);
            }

            // stop the sync state
            SyncBroadcastManager.setSyncState(this, false);
            break;
        }

        case InEventProvider.URI_ACTIVITY_SCHEDULE:
        {
            SyncBroadcastManager.setSyncState(this, "Syncing Schedule");

            try
            {
                String tokenID = LoginManager.getInstance(this).getTokenId();
                long eventID = intent.getLongExtra(EXTRA_EVENT_ID, -1);
                HttpURLConnection connection = Event.Api.getSchedule(tokenID, eventID);
                ApiRequest.getJsonFromConnection(code, connection, this, false);
            }
            catch (IOException e)
            {
                Log.e(InEvent.NAME, "Couldn't create connection for event.getSchedule(tokenID, eventID)", e);
            }

            // stop the sync state
            SyncBroadcastManager.setSyncState(this, false);
            break;
        }
        default:
            break;
        }

        Log.v(InEvent.NAME, "Done with " + data);
    }


    @Override
    public void handleResponse(int requestCode, JSONObject json, int responseCode)
    {
        if (responseCode != HttpStatus.SC_OK || json == null)
        {
            // Error!

            // TODO treat the errors

            return;
        }

        switch (requestCode)
        {
        case InEventProvider.URI_EVENT:
        {
            ArrayList<ContentProviderOperation> operations = new ArrayList<ContentProviderOperation>();
            
            try
            {
                // Delete the previous events
                operations.add(
                        ContentProviderOperation
                            .newDelete(Event.CONTENT_URI)
                            .build()
                );

                // Get the new ones
                JSONArray eventArray = json.getJSONArray(JsonUtils.DATA);
                for (int i = 0; i < eventArray.length(); i++)
                {
                    // Parse the json
                    ContentValues values = Event.valuesFromJson(eventArray.getJSONObject(i));

                    // Add the insert operation
                    operations.add(
                            ContentProviderOperation
                                .newInsert(Event.CONTENT_URI)
                                .withValues(values)
                                .build()
                    );
                }

                getContentResolver().applyBatch(InEventProvider.AUTHORITY, operations);
            }
            catch (JSONException e)
            {
                Log.w(InEvent.NAME, "Couldn't properly get the Events from the json = "+json, e);
            }
            catch (RemoteException e)
            {
                Log.e(InEvent.NAME, "...", e);
            }
            catch (OperationApplicationException e)
            {
                Log.e(InEvent.NAME, "Failed while adding Events to the database", e);
            }
            break;
        }

        case InEventProvider.URI_ACTIVITY:
        {
            ArrayList<ContentProviderOperation> operations = new ArrayList<ContentProviderOperation>();

            try
            {
                // Get some info
                long eventID = mIntent.getLongExtra(EXTRA_EVENT_ID, -1);

                // Delete the previous stored activities
                operations.add(
                        ContentProviderOperation
                            .newDelete(Activity.ACTIVITY_CONTENT_URI)
                            .withSelection(Activity.Columns.EVENT_ID+"="+mIntent.getLongExtra(EXTRA_EVENT_ID, -1), null)
                            .build()
                );

                // Get the new ones
                JSONArray dayArray = json.getJSONArray(JsonUtils.DATA);
                for (int i = 0; i < dayArray.length(); i++)
                {
                    JSONArray activityArray = dayArray.getJSONArray(i);
                    for (int j = 0; j < activityArray.length(); j++)
                    {
                        // Parse the json
                        ContentValues values = Activity.valuesFromJson(activityArray.getJSONObject(j), eventID);

                        // Add the insert operation
                        operations.add(
                                ContentProviderOperation
                                    .newInsert(Activity.ACTIVITY_CONTENT_URI)
                                    .withValues(values)
                                    .build()
                        );
                    }
                }

                getContentResolver().applyBatch(InEventProvider.AUTHORITY, operations);
            }
            catch (JSONException e)
            {
                Log.w(InEvent.NAME, "Couldn't properly get the Activities from the json = "+json, e);
            }
            catch (RemoteException e)
            {
                Log.e(InEvent.NAME, "", e);
            }
            catch (OperationApplicationException e)
            {
                Log.e(InEvent.NAME, "Failed while adding Activities to the database", e);
            }
            break;
        }

        case InEventProvider.URI_ACTIVITY_SCHEDULE:
        {
            ArrayList<ContentProviderOperation> operations = new ArrayList<ContentProviderOperation>();

            try
            {
                // Get some info
                long eventID = mIntent.getLongExtra(EXTRA_EVENT_ID, -1);
                long memberID = LoginManager.getInstance(this).getMember().memberId;

                // Delete the previous stored activities
                operations.add(
                        ContentProviderOperation
                            .newDelete(Activity.SCHEDULE_CONTENT_URI)
                            .withSelection(
                                    Activity.Member.TABLE_NAME+"."+Activity.Member.Columns.EVENT_ID  +"="+ eventID + " AND " +
                                    Activity.Member.TABLE_NAME+"."+Activity.Member.Columns.MEMBER_ID +"="+ memberID 
                                    , null)
                            .build()
                );

                // Get the new ones
                JSONArray dayArray = json.getJSONArray(JsonUtils.DATA);
                for (int i = 0; i < dayArray.length(); i++)
                {
                    JSONArray activityArray = dayArray.getJSONArray(i);
                    for (int j = 0; j < activityArray.length(); j++)
                    {
                        // Parse the json
                        JSONObject jobj = activityArray.getJSONObject(j);

                        long activityID = jobj.getLong(JsonUtils.ID);
                        boolean approved = jobj.getInt(Activity.Member.Columns.APPROVED) == 1;

                        // Gather the values
                        ContentValues values = Activity.Member.newActivtyMember(eventID, activityID, memberID, approved);

                        // Add the insert operation
                        operations.add(
                                ContentProviderOperation
                                    .newInsert(Activity.SCHEDULE_CONTENT_URI)
                                    .withValues(values)
                                    .build()
                        );
                    }
                }

                getContentResolver().applyBatch(InEventProvider.AUTHORITY, operations);
            }
            catch (JSONException e)
            {
                Log.w(InEvent.NAME, "Couldn't properly get the Activities Schedule from the json = "+json, e);
            }
            catch (RemoteException e)
            {
                Log.e(InEvent.NAME, "", e);
            }
            catch (OperationApplicationException e)
            {
                Log.e(InEvent.NAME, "Failed while adding Activities Schedule to the database", e);
            }
            break;
        }

        default:
            break;
        }
    }
}
