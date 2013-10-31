package com.estudiotrilha.inevent.service;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.util.ArrayList;
import java.util.Locale;

import org.apache.http.HttpStatus;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.IntentService;
import android.content.ContentProviderOperation;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.OperationApplicationException;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.RemoteException;
import android.preference.PreferenceManager;
import android.util.Log;

import com.estudiotrilha.android.utils.JsonUtils;
import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.Utils;
import com.estudiotrilha.inevent.content.Activity;
import com.estudiotrilha.inevent.content.ActivityMember;
import com.estudiotrilha.inevent.content.ActivityQuestion;
import com.estudiotrilha.inevent.content.ApiRequest;
import com.estudiotrilha.inevent.content.Event;
import com.estudiotrilha.inevent.content.EventMember;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.content.Member;
import com.estudiotrilha.inevent.content.Feedback;
import com.estudiotrilha.inevent.content.SyncBroadcastManager;
import com.estudiotrilha.inevent.provider.InEventProvider;


public class DownloaderService extends IntentService implements ApiRequest.ResponseHandler
{
    public static final String SERVICE_NAME = InEvent.NAME + "." + DownloaderService.class.getSimpleName();

    // JSON hashes
    public static final String HASH_JSON = "Hash for UriCode=%d, Arguments=%s";

    // Extras
    private static final String EXTRA_EVENT_ID    = "extra.EVENT_ID";
    private static final String EXTRA_ACTIVITY_ID = "extra.ACTIVITY_ID";

    public static void downloadEvents(Context c)
    {
        Intent service = new Intent(c, DownloaderService.class);
        service.setData(Event.CONTENT_URI);
        c.startService(service);
    }
    public static void downloadEventAttenders(Context c, long eventId)
    {
        Intent service = new Intent(c, DownloaderService.class);
        service.setData(EventMember.CONTENT_URI);
        service.putExtra(EXTRA_EVENT_ID, eventId);
        c.startService(service);
    }
    public static void downloadEventActivities(Context c, long eventId)
    {
        Intent service = new Intent(c, DownloaderService.class);
        service.setData(Activity.CONTENT_URI);
        service.putExtra(EXTRA_EVENT_ID, eventId);
        c.startService(service);
    }
    public static void downloadEventActivityRating(Context c, long activityId)
    {
        Intent service = new Intent(c, DownloaderService.class);
        service.setData(Feedback.CONTENT_URI);
        service.putExtra(EXTRA_ACTIVITY_ID, activityId);
        c.startService(service);
    }
    public static void downloadEventRating(Context c, long eventId)
    {
        Intent service = new Intent(c, DownloaderService.class);
        service.setData(Feedback.CONTENT_URI);
        service.putExtra(EXTRA_EVENT_ID, eventId);
        c.startService(service);
    }
    public static void downloadEventActivityQuestions(Context c, long activityId)
    {
        Intent service = new Intent(c, DownloaderService.class);
        service.setData(ActivityQuestion.CONTENT_URI);
        service.putExtra(EXTRA_ACTIVITY_ID, activityId);
        c.startService(service);
    }
    public static void downloadEventActivityAttenders(Context c, long eventId, long activityId)
    {
        Intent service = new Intent(c, DownloaderService.class);
        service.setData(ActivityMember.CONTENT_URI);
        service.putExtra(EXTRA_EVENT_ID, eventId);
        service.putExtra(EXTRA_ACTIVITY_ID, activityId);
        c.startService(service);
    }


    private Intent            mIntent;
    private LoginManager      mLoginManager;
    private SharedPreferences mPreferences;


    public DownloaderService()
    {
        super(SERVICE_NAME);
    }
    @Override
    public void onCreate()
    {
        super.onCreate();
        mLoginManager = LoginManager.getInstance(this);
        mPreferences = PreferenceManager.getDefaultSharedPreferences(this);
    }

    @Override
    protected void onHandleIntent(Intent intent)
    {
        mIntent = intent;

        if (!Utils.checkConnectivity(this))
        {
            // send a broadcast telling that there is no connection
            sendBroadcast(new Intent(InEvent.ACTION_TOAST_NOTIFICATION).putExtra(InEvent.EXTRA_TOAST_MESSAGE, R.string.error_connection_internetless));
            return;
        }

        Uri data = intent.getData();
        int code = InEventProvider.uriMatcher.match(data);

        Log.v(InEvent.NAME, "Downloading " + data);

        HttpURLConnection connection = null;
        String syncMessage = "Syncing...";
        String apiMethodName = null;

        try
        {
            switch (code)
            {
            case InEventProvider.URI_EVENT:
            {
                // Download the events
                syncMessage = "Syncing Events";
                apiMethodName = "person.getEvents(tokenID)";
    
                // Prepare the connection
                String tokenID = mLoginManager.getTokenId();
                connection = Event.Api.getEvents(tokenID);
                break;
            }
    
            case InEventProvider.URI_EVENT_ATTENDERS:
            {
                // Download the event attenders
                syncMessage = "Syncing Event Attenders";
                apiMethodName = "event.getPeople(tokenID, eventID, selection)";
    
                // Prepare the connection
                String tokenID = mLoginManager.getTokenId();
                long eventID = intent.getLongExtra(EXTRA_EVENT_ID, -1);
                connection = Event.Api.getPeople(tokenID, eventID, Event.Api.PeopleSelection.ALL);
                break;
            }
    
            case InEventProvider.URI_ACTIVITY:
            {
                // Download the event activities
                syncMessage = "Syncing Activities";
                apiMethodName = "event.getActivities(eventID)";
    
                // Prepare the connection
                long eventID = intent.getLongExtra(EXTRA_EVENT_ID, -1);
                connection = Event.Api.getActivities(eventID, mLoginManager.getTokenId());
                break;
            }
    
            case InEventProvider.URI_ACTIVITY_ATTENDERS:
            {
                // Download the event activity attenders list
                syncMessage = "Syncing Attenders";
                apiMethodName = "activity.getPeople(tokenID, activityID, selection)";
    
                // Prepare the connection
                String tokenID = mLoginManager.getTokenId();
                long activityID = intent.getLongExtra(EXTRA_ACTIVITY_ID, -1);
                connection = Activity.Api.getPeople(tokenID, activityID, Activity.Api.PeopleSelection.ALL);
                break;
            }
    
            case InEventProvider.URI_RATING:
            {
                // Download the user rating
                syncMessage = "Syncing Rating";
                long id = intent.getLongExtra(EXTRA_EVENT_ID, -1);
                String tokenID = mLoginManager.getTokenId();
                if (id == -1)
                {
                    id = intent.getLongExtra(EXTRA_ACTIVITY_ID, -1);
                    apiMethodName = "activity.getOpinion(tokenID, activityID)";

                    // Prepare the connection
                    connection = Activity.Api.getOpinion(tokenID, id);
                }
                else
                {
                    apiMethodName = "event.getOpinion(tokenID, eventID)";                    
                    // Prepare the connection
                    connection = Event.Api.getOpinion(tokenID, id);
                }
    
                break;
            }

            case InEventProvider.URI_QUESTION:
            {
                // Download the event activity attenders list
                syncMessage = "Syncing Questions";
                apiMethodName = "activity.getQuestions(tokenID, activityID)";
    
                // Prepare the connection
                String tokenID = mLoginManager.getTokenId();
                long activityID = intent.getLongExtra(EXTRA_ACTIVITY_ID, -1);
                connection = Activity.Api.getQuestions(tokenID, activityID);
                break;
            }

            default:
                return;
            }
        }
        catch (IOException e)
        {
            Log.w(InEvent.NAME, "Couldn't create connection for "+apiMethodName, e);
            return;
        }

        // Start the sync state
        SyncBroadcastManager.setSyncState(this, syncMessage);

        // Send the request synchronously
        ApiRequest.getJsonFromConnection(code, connection, this, false);

        // Stop the sync state
        SyncBroadcastManager.setSyncState(this, false);

        Log.v(InEvent.NAME, "Done with " + data);
    }


    @Override
    public void handleResponse(int requestCode, JSONObject json, int responseCode)
    {
        if (json != null && responseCode == HttpStatus.SC_OK)
        {
            // Check if there are differences from the last downloaded JSON

            String jsonHash = String.format(Locale.ENGLISH, HASH_JSON, requestCode, ""+mIntent.getExtras());
            String oldHash = mPreferences.getString(jsonHash, "Hash");
            String newHash = JsonUtils.generateHash(json);

            Log.v(InEvent.NAME, "Old Hash="+oldHash);
            Log.v(InEvent.NAME, "New Hash="+newHash);

            if (oldHash.equals(newHash))
            {
                // There are no changes here, so the database is left untouched
                Log.v(InEvent.NAME, "Same hashes! Saving processing time!");
                return;
            }

            try
            {
                ArrayList<ContentProviderOperation> operations = new ArrayList<ContentProviderOperation>();
                ArrayList<ContentProviderOperation> inserts = new ArrayList<ContentProviderOperation>();
                ArrayList<ContentProviderOperation> deletes = new ArrayList<ContentProviderOperation>();

                String allDoneLogMessage = "All done with "+mIntent.getDataString();

                switch (requestCode)
                {
                case InEventProvider.URI_EVENT:
                {
                    // Delete all events
                    deletes.add(
                            ContentProviderOperation
                                .newDelete(Event.CONTENT_URI)
                                .build()
                    );

                    boolean signedIn = mLoginManager.isSignedIn();

                    // and eventMembers
                    deletes.add(
                        ContentProviderOperation
                            .newDelete(EventMember.CONTENT_URI)
                            .build()
                    );

                    // Get the new ones
                    JSONArray eventArray = json.getJSONArray(JsonUtils.DATA);
                    for (int i = 0; i < eventArray.length(); i++)
                    {
                        // Parse the json
                        JSONObject jobj = eventArray.getJSONObject(i);
                        ContentValues values = Event.valuesFromJson(jobj);

                        // Add the insert operation
                        inserts.add(
                            ContentProviderOperation
                                .newInsert(Event.CONTENT_URI)
                                .withValues(values)
                                .build()
                        );

                        if (signedIn && jobj.getInt(EventMember.Columns.APPROVED) == 1)
                        {
                            // If the user is signed in, get his eventMember stats
                            values = EventMember.valuesFromJson(jobj, jobj.getLong(JsonUtils.ID), mLoginManager.getMember().memberId);
                            inserts.add(
                                ContentProviderOperation
                                    .newInsert(EventMember.CONTENT_URI)
                                    .withValues(values)
                                    .build()
                            );
                        }
                    }

                    allDoneLogMessage = "All events were downloaded successfully!";
                    break;
                }

                case InEventProvider.URI_EVENT_ATTENDERS:
                {
                    // Get some info
                    long eventID = mIntent.getLongExtra(EXTRA_EVENT_ID, -1);
                    
                    // Delete the previous stored event members
                    // The attenders
                    deletes.add(
                        ContentProviderOperation
                            .newDelete(Member.CONTENT_URI)
                            .withSelection(Member.Columns._ID_FULL+" IN (" +
                                "SELECT "+EventMember.Columns.MEMBER_ID_FULL+
                                " FROM "+EventMember.TABLE_NAME+
                                " WHERE "+EventMember.Columns.EVENT_ID_FULL+"="+eventID+")", null)
                            .build()
                    );
                    // The connections
                    deletes.add(
                        ContentProviderOperation
                            .newDelete(EventMember.CONTENT_URI)
                            .withSelection(EventMember.Columns.EVENT_ID_FULL+"="+eventID, null)
                            .build()
                    );
                    
                    // Get the new ones
                    JSONArray peopleArray = json.getJSONArray(JsonUtils.DATA);
                    for (int i = 0; i < peopleArray.length(); i++)
                    {
                        // Parse the json
                        JSONObject jobj = peopleArray.getJSONObject(i);
                        ContentValues values = EventMember.valuesFromJson(jobj, eventID);
                        
                        // Add the insert operation
                        inserts.add(
                            ContentProviderOperation
                                .newInsert(EventMember.CONTENT_URI)
                                .withValues(values)
                                .build()
                        );
                        
                        // Parse the Member info
                        values = Member.valuesFromJson(jobj);
                        
                        inserts.add(
                            ContentProviderOperation
                                .newInsert(Member.CONTENT_URI)
                                .withValues(values)
                                .build()
                        );
                    }

                    allDoneLogMessage = "Events attenders for event id = "+eventID+" updated";
                    break;
                }
                
                case InEventProvider.URI_ACTIVITY:
                {
                    // Get some info
                    long eventID = mIntent.getLongExtra(EXTRA_EVENT_ID, -1);
                    long memberID = mLoginManager.isSignedIn() ? mLoginManager.getMember().memberId : -1;

                    // Delete the previous stored activities
                    deletes.add(
                        ContentProviderOperation
                            .newDelete(Activity.CONTENT_URI)
                            .withSelection(Activity.Columns.EVENT_ID_FULL+"="+eventID, null)
                            .build()
                    );
                    // And the activity member link
                    deletes.add(
                            ContentProviderOperation
                                .newDelete(ActivityMember.CONTENT_URI)
                                .withSelection(ActivityMember.Columns.EVENT_ID_FULL+"="+eventID+" AND "
                                        +ActivityMember.Columns.MEMBER_ID_FULL+"="+memberID, null)
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
                            ContentValues values = Activity.valuesFromJson(jobj, eventID);
                            
                            // Add the insert operation for the activity
                            inserts.add(
                                ContentProviderOperation
                                    .newInsert(Activity.CONTENT_URI)
                                    .withValues(values)
                                    .build()
                            );

                            int approved = jobj.getInt(ActivityMember.Columns.APPROVED);

                            // And the connection if necessary
                            if (approved != -1 && memberID != -1)
                            {
                                // Gather the values
                                long activityID = jobj.getLong(JsonUtils.ID);
                                values = ActivityMember.newActivtyMember(eventID, activityID, memberID, approved);

                                // Add the insert operation for the connection
                                inserts.add(
                                    ContentProviderOperation
                                        .newInsert(ActivityMember.CONTENT_URI)
                                        .withValues(values)
                                        .build()
                                );
                            }
                        }
                    }

                    allDoneLogMessage = "All activities from event id="+eventID+" were downloaded successfully!";
                    break;
                }
                
                case InEventProvider.URI_ACTIVITY_ATTENDERS:
                {
                    // Get some info
                    long activityID = mIntent.getLongExtra(EXTRA_ACTIVITY_ID, -1);
                    long eventID = mIntent.getLongExtra(EXTRA_EVENT_ID, -1);
                    
                    // Delete the previous stored activity members
                    deletes.add(
                        ContentProviderOperation
                            .newDelete(ActivityMember.CONTENT_URI)
                            .withSelection(ActivityMember.Columns.ACTIVITY_ID_FULL+"="+activityID, null)
                            .build()
                    );

                    // Get the new ones
                    JSONArray peopleArray = json.getJSONArray(JsonUtils.DATA);
                    for (int i = 0; i < peopleArray.length(); i++)
                    {
                        // Parse the json
                        JSONObject jobj = peopleArray.getJSONObject(i);
                        
                        long memberID = jobj.getLong(Member.MEMBER_ID);
                        int approved = jobj.getInt(ActivityMember.Columns.APPROVED);
                        boolean present = jobj.getInt(ActivityMember.Columns.PRESENT) == 1;
                        
                        // Parse the member
                        // Parse the link member-activity
                        ContentValues values = ActivityMember.newActivtyMember(eventID, activityID, memberID, approved, present);

                        // Add the insert operation
                        inserts.add(
                            ContentProviderOperation
                                .newInsert(ActivityMember.CONTENT_URI)
                                .withValues(values)
                                .build()
                        );
                    }

                    allDoneLogMessage = "All activitiy attenders from activity id="+activityID+" were downloaded successfully!";
                    break;
                }

                case InEventProvider.URI_RATING:
                {
                    // Get some info
                    long activityID = mIntent.getLongExtra(EXTRA_ACTIVITY_ID, -1);
                    long eventID = mIntent.getLongExtra(EXTRA_EVENT_ID, -1);

                    // Parse the info
                    JSONObject jobj = json.getJSONArray(JsonUtils.DATA).getJSONObject(0);
                    ContentValues values = Feedback.valuesFromJson(jobj, eventID, activityID);

                    // Add to the database
                    inserts.add(
                            ContentProviderOperation
                                .newInsert(Feedback.CONTENT_URI)
                                .withValues(values)
                                .build()
                    );

                    break;
                }

                case InEventProvider.URI_QUESTION:
                {
                    // Get some info
                    long activityID = mIntent.getLongExtra(EXTRA_ACTIVITY_ID, -1);

                    // Delete the previous stored activity questions
                    deletes.add(
                        ContentProviderOperation
                            .newDelete(ActivityQuestion.CONTENT_URI)
                            .withSelection(ActivityQuestion.Columns.ACTIVITY_ID_FULL+"="+activityID, null)
                            .build()
                    );

                    // Get the new ones
                    JSONArray questionsArray = json.getJSONArray(JsonUtils.DATA);
                    for (int i = 0; i < questionsArray.length(); i++)
                    {
                        // Parse the json
                        JSONObject jobj = questionsArray.getJSONObject(i);
                        ContentValues values = ActivityQuestion.valuesFromJson(jobj, activityID);

                        // Add the insert operation
                        inserts.add(
                            ContentProviderOperation
                                .newInsert(ActivityQuestion.CONTENT_URI)
                                .withValues(values)
                                .build()
                        );
                    }

                    allDoneLogMessage = "All questions from activity id="+activityID+" were downloaded successfully!";
                    break;
                }

                default:
                    break;
                }

                // Perform the operations in the database
                operations.addAll(deletes);
                operations.addAll(inserts);

                getContentResolver().applyBatch(InEventProvider.AUTHORITY, operations);

                // All operations were performed
                Log.v(InEvent.NAME, allDoneLogMessage);

                // Save the hash of the new downloaded JSON
                mPreferences.edit()
                        .putString(jsonHash, newHash)
                        .commit();
            }
            catch (JSONException e)
            {
                Log.w(InEvent.NAME, "Couldn't properly parse the json = "+ json, e);
            }
            catch (RemoteException e)
            {
                Log.e(InEvent.NAME, "Batch operation failed!", e);
            }
            catch (OperationApplicationException e)
            {
                Log.e(InEvent.NAME, "Batch operation failed!", e);
            }
        }
        else
        {
            // Error!
            Log.w(InEvent.NAME, "Couldn't download data requested for "+mIntent.getDataString()+". Response Code = "+responseCode);
            int message = Utils.getBadResponseMessage(requestCode, responseCode);
            
            // Send the message to the user
            sendBroadcast(new Intent(InEvent.ACTION_TOAST_NOTIFICATION).putExtra(InEvent.EXTRA_TOAST_MESSAGE, message));
        }
    }
}
