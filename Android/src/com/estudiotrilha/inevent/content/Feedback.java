package com.estudiotrilha.inevent.content;

import static com.estudiotrilha.inevent.content.Feedback.Columns.ACTIVITY_ID;
import static com.estudiotrilha.inevent.content.Feedback.Columns.EVENT_ID;
import static com.estudiotrilha.inevent.content.Feedback.Columns.MESSAGE;
import static com.estudiotrilha.inevent.content.Feedback.Columns.RATING;
import static com.estudiotrilha.inevent.content.Feedback.Columns.SYNCHRONIZED;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.ContentValues;
import android.net.Uri;
import android.provider.BaseColumns;
import android.util.Log;

import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.provider.InEventProvider;


public class Feedback
{
    // Database
    public static final String TABLE_NAME = "feedback";
    public static interface Columns extends BaseColumns
    {
        public static final String ACTIVITY_ID  = "activityID";
        public static final String EVENT_ID     = "eventID";
        public static final String RATING       = "rating";
        public static final String MESSAGE      = "message";
        public static final String SYNCHRONIZED = "synchronized";
        // Full names
        public static final String _ID_FULL          = TABLE_NAME+"."+_ID;
        public static final String ACTIVITY_ID_FULL  = TABLE_NAME+"."+ACTIVITY_ID;
        public static final String EVENT_ID_FULL     = TABLE_NAME+"."+EVENT_ID;
        public static final String RATING_FULL       = TABLE_NAME+"."+RATING;
        public static final String MESSAGE_FULL      = TABLE_NAME+"."+MESSAGE;
        public static final String SYNCHRONIZED_FULL = TABLE_NAME+"."+SYNCHRONIZED;


        public static final String[] PROJECTION_SYNC = {
            Feedback.Columns._ID_FULL,
            Feedback.Columns.ACTIVITY_ID_FULL,
            Feedback.Columns.EVENT_ID_FULL,
            Feedback.Columns.RATING_FULL,
            Feedback.Columns.MESSAGE_FULL
        };
    }

    // Content Provider
    public static final String PATH     = "feedback";
    public static final Uri CONTENT_URI = Uri.withAppendedPath(InEventProvider.CONTENT_URI, PATH);


    public static ContentValues valuesFromJson(JSONObject json, long eventID, long activityID)
    {
        ContentValues cv = new ContentValues();

        try
        {
            cv.put(RATING, json.getInt(RATING));
            cv.put(MESSAGE, json.optString(MESSAGE, null));
            cv.put(EVENT_ID, eventID);
            cv.put(ACTIVITY_ID, activityID);
            cv.put(SYNCHRONIZED, 1);
        }
        catch (JSONException e)
        {
            Log.w(InEvent.NAME, "Error retrieving information of Rating from json = "+json, e);
        }

        return cv;
    }

    public static ContentValues newActivityOpinion(long activityID, int rating)
    {
        ContentValues cv = new ContentValues();
        cv.put(ACTIVITY_ID, activityID);
        cv.put(RATING, rating);
        cv.put(SYNCHRONIZED, 0);

        return cv;
    }

    public static ContentValues newEventOpinion(long eventID, int rating, String message)
    {
        ContentValues cv = new ContentValues();
        cv.put(EVENT_ID, eventID);
        cv.put(MESSAGE, message);
        cv.put(RATING, rating);
        cv.put(SYNCHRONIZED, 0);

        return cv;
    }
}
