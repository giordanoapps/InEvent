package com.estudiotrilha.inevent.content;

import static com.estudiotrilha.inevent.content.ActivityQuestion.Columns.MEMBER_ID;
import static com.estudiotrilha.inevent.content.ActivityQuestion.Columns._ID;
import static com.estudiotrilha.inevent.content.ActivityQuestion.Columns.ACTIVITY_ID;
import static com.estudiotrilha.inevent.content.ActivityQuestion.Columns.TEXT;
import static com.estudiotrilha.inevent.content.ActivityQuestion.Columns.UPVOTED;
import static com.estudiotrilha.inevent.content.ActivityQuestion.Columns.VOTES;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.ContentValues;
import android.net.Uri;
import android.provider.BaseColumns;
import android.text.Html;
import android.util.Log;

import com.estudiotrilha.android.utils.JsonUtils;
import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.provider.InEventProvider;


public class ActivityQuestion
{
    // Database
    public static final String TABLE_NAME = "activityQuestion";
    public static interface Columns extends BaseColumns
    {
        public static final String ACTIVITY_ID = "activityID";
        public static final String MEMBER_ID   = "memberID";
        public static final String TEXT        = "text";
        public static final String VOTES       = "votes";
        public static final String UPVOTED     = "upvoted";

        public static final String _ID_FULL         = TABLE_NAME+"."+_ID;
        public static final String ACTIVITY_ID_FULL = TABLE_NAME+"."+ACTIVITY_ID;
        public static final String MEMBER_ID_FULL   = TABLE_NAME+"."+MEMBER_ID;
        public static final String TEXT_FULL        = TABLE_NAME+"."+TEXT;
        public static final String VOTES_FULL       = TABLE_NAME+"."+VOTES;
        public static final String UPVOTED_FULL     = TABLE_NAME+"."+UPVOTED;


        public static final String[] PROJECTION_LIST = {
            ActivityQuestion.Columns._ID_FULL,
            ActivityQuestion.Columns.TEXT_FULL,
            ActivityQuestion.Columns.VOTES_FULL,
            ActivityQuestion.Columns.UPVOTED_FULL,
            ActivityQuestion.Columns.MEMBER_ID_FULL,
            Member.Columns.NAME_FULL
        };
    }

    // Content Provider
    public static final String PATH        = "activity/question";
    public static final Uri    CONTENT_URI = Uri.withAppendedPath(InEventProvider.CONTENT_URI, PATH);


    public static ContentValues valuesFromJson(JSONObject json, long activityID)
    {
        ContentValues cv = new ContentValues();

        try
        {
            cv.put(_ID, json.getLong(JsonUtils.ID));
            cv.put(ACTIVITY_ID, activityID);
            cv.put(MEMBER_ID, json.getLong(MEMBER_ID));
            cv.put(TEXT, Html.fromHtml(json.getString(TEXT)).toString());
            cv.put(VOTES, json.getInt(VOTES));
            cv.put(UPVOTED, json.getInt(UPVOTED) == 1);
        }
        catch (JSONException e)
        {
            Log.w(InEvent.NAME, "Error retrieving information for ActivityQuestion from json = "+json, e);
            cv = null;
        }
        
        return cv;
    }
}
