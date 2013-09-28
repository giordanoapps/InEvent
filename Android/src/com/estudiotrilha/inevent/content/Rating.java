package com.estudiotrilha.inevent.content;

import static com.estudiotrilha.inevent.content.Rating.Columns.ACTIVITY_ID;
import static com.estudiotrilha.inevent.content.Rating.Columns.EVENT_ID;
import static com.estudiotrilha.inevent.content.Rating.Columns.MESSAGE;
import static com.estudiotrilha.inevent.content.Rating.Columns.RATING;
import static com.estudiotrilha.inevent.content.Rating.Columns.SYNCHRONIZED;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.ContentValues;
import android.net.Uri;
import android.provider.BaseColumns;
import android.util.Log;

import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.provider.InEventProvider;


public class Rating
{
    // Database
    public static final String TABLE_NAME = "rating";
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
    }

    // Content Provider
    public static final String PATH     = "rating";
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
}
