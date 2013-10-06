package com.estudiotrilha.inevent.service;

import java.io.IOException;
import java.net.HttpURLConnection;

import org.apache.http.HttpStatus;
import org.json.JSONObject;

import android.app.IntentService;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.util.Log;

import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.Utils;
import com.estudiotrilha.inevent.content.Activity;
import com.estudiotrilha.inevent.content.ApiRequest;
import com.estudiotrilha.inevent.content.ApiRequestCode;
import com.estudiotrilha.inevent.content.Event;
import com.estudiotrilha.inevent.content.Feedback;
import com.estudiotrilha.inevent.content.LoginManager;


public class UploaderService extends IntentService implements ApiRequest.ResponseHandler
{
    public static final String SERVICE_NAME = InEvent.NAME + "." + UploaderService.class.getSimpleName();


    public static void sync(Context context)
    {
        // Wake the Uploader
        final Intent intent = new Intent(context, UploaderService.class).setAction(Intent.ACTION_SYNC);
        context.startService(intent);
    }
    public static void sendOpinionForActivity(Context context, long activityID, int rating)
    {
        // Insert it in the database
        context.getContentResolver().insert(Feedback.CONTENT_URI, Feedback.newActivityOpinion(activityID, rating));
        sync(context);
    }
    public static void sendOpinionForEvent(Context context, long activityID, int rating, String message)
    {
        // Insert it in the database
        context.getContentResolver().insert(Feedback.CONTENT_URI, Feedback.newEventOpinion(activityID, rating, message));
        sync(context);
    }


    private Intent       mIntent;
    private long         mId;
    private LoginManager mLoginManager;


    public UploaderService()
    {
        super(SERVICE_NAME);
    }

    @Override
    public void onCreate()
    {
        super.onCreate();
        mLoginManager = LoginManager.getInstance(this);
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

        if (Intent.ACTION_SYNC.equals(mIntent.getAction()))
        {
            // Sync opinions

            // Login check
            if (!mLoginManager.isSignedIn()) return;

            // Get the token
            String tokenId = mLoginManager.getTokenId();

            // Query the unsynchronized opinions
            Cursor c = getContentResolver().query(Feedback.CONTENT_URI, Feedback.Columns.PROJECTION_SYNC, Feedback.Columns.SYNCHRONIZED_FULL+"=0", null, null);
            // Get the indexes
            int indexActivityID = c.getColumnIndex(Feedback.Columns.ACTIVITY_ID);
            int indexEventID = c.getColumnIndex(Feedback.Columns.EVENT_ID);
            int indexID = c.getColumnIndex(Feedback.Columns._ID);
            int indexRating = c.getColumnIndex(Feedback.Columns.RATING);
            int indexMessage = c.getColumnIndex(Feedback.Columns.MESSAGE);

            while(c.moveToNext())
            {
                // Get the rating
                int rating = c.getInt(indexRating);
                mId = c.getLong(indexID);
                String request = "";

                try
                {
                    HttpURLConnection connection = null;
                    String post = null;

                    // Check the type of opinion
                    if (c.isNull(indexEventID))
                    {
                        // This is an Activity opinion
                        long activityID = c.getLong(indexActivityID);

                        // Send the request
                        request = "activity.sendOpinion(tokenID, activityID="+activityID+", rating="+rating+")";
                        connection = Activity.Api.sendOpinion(tokenId, activityID);
                        post = Activity.Api.Post.sendOpinion(rating);
                        ApiRequest.getJsonFromConnection(ApiRequestCode.ACTIVITY_SEND_OPINION, connection, this, post, false);
                    }
                    else if (c.isNull(indexActivityID))
                    {
                        // This is an Event opinion
                        long eventID = c.getLong(indexEventID);
                        String message = c.getString(indexMessage);

                        // Send the request
                        request = "event.sendOpinion(tokenID, eventID="+eventID+", rating="+rating+", message=\""+message+"\")";
                        connection = Event.Api.sendOpinion(tokenId, eventID);
                        post = Event.Api.Post.sendOpinion(rating, message);
                        ApiRequest.getJsonFromConnection(ApiRequestCode.EVENT_SEND_OPINION, connection, this, post, false);
                    }
                }
                catch (IOException e)
                {
                    Log.e(InEvent.NAME, "Couldn't create connection for "+request, e);
                }
            }
            c.close();
        }
    }


    @Override
    public void handleResponse(int requestCode, JSONObject json, int responseCode)
    {
        if (responseCode == HttpStatus.SC_OK && json != null)
        {
            switch (requestCode)
            {
            case ApiRequestCode.ACTIVITY_SEND_OPINION:
            case ApiRequestCode.EVENT_SEND_OPINION:
                // Update the database table
                ContentValues values = new ContentValues();
                values.put(Feedback.Columns.SYNCHRONIZED, 1);
                getContentResolver().update(ContentUris.withAppendedId(Feedback.CONTENT_URI, mId), values, null, null);
                break;
            }
        }
        else
        {
            int responseMessage = Utils.getBadResponseMessage(requestCode, responseCode);
            sendBroadcast(new Intent(InEvent.ACTION_TOAST_NOTIFICATION).putExtra(InEvent.EXTRA_TOAST_MESSAGE, responseMessage));
        }
    }
}
