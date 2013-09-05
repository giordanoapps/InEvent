package com.estudiotrilha.inevent.content;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.ContentValues;
import android.util.Log;

import com.estudiotrilha.inevent.InEvent;


public class EventMember
{
    public static interface Columns
    {
        public static final String EVENT_ID  = "eventID";
        public static final String MEMBER_ID = "memberID";
        public static final String APPROVED  = "approved";
        public static final String ROLE_ID   = "roleID";
        // Full names
        public static final String EVENT_ID_FULL  = TABLE_NAME+"."+EVENT_ID;
        public static final String MEMBER_ID_FULL = TABLE_NAME+"."+MEMBER_ID;
        public static final String APPROVED_FULL  = TABLE_NAME+"."+APPROVED;
        public static final String ROLE_ID_FULL   = TABLE_NAME+"."+ROLE_ID;
    }

    public static final String REQUEST_ID = "requestID";

    // Database
    public static final String TABLE_NAME = "eventMember";

    public static ContentValues valuesFromJson(JSONObject json, long eventID)
    {
        ContentValues cv = new ContentValues();

        try
        {
            cv.put(Columns.EVENT_ID, eventID);
            cv.put(Columns.MEMBER_ID, json.getLong(Columns.MEMBER_ID));
            cv.put(Columns.APPROVED, json.getInt(Columns.APPROVED));
            cv.put(Columns.ROLE_ID, json.getInt(Columns.ROLE_ID));
        }
        catch (JSONException e)
        {
            Log.w(InEvent.NAME, "Error retrieving information for Event from json = "+json, e);
        }

        return cv;
    }
}
