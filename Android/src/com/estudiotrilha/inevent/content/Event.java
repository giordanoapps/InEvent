package com.estudiotrilha.inevent.content;

import static android.provider.BaseColumns._ID;
import static com.estudiotrilha.inevent.content.Activity.Columns.DATE_BEGIN;
import static com.estudiotrilha.inevent.content.Activity.Columns.DATE_END;
import static com.estudiotrilha.inevent.content.Event.Columns.ADDRESS;
import static com.estudiotrilha.inevent.content.Event.Columns.CITY;
import static com.estudiotrilha.inevent.content.Event.Columns.DESCRIPTION;
import static com.estudiotrilha.inevent.content.Event.Columns.LATITUDE;
import static com.estudiotrilha.inevent.content.Event.Columns.LONGITUDE;
import static com.estudiotrilha.inevent.content.Event.Columns.NAME;
import static com.estudiotrilha.inevent.content.Event.Columns.STATE;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.ContentValues;
import android.net.Uri;
import android.provider.BaseColumns;
import android.text.Html;
import android.util.Log;

import com.estudiotrilha.android.net.ConnectionHelper;
import com.estudiotrilha.android.utils.JsonUtils;
import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.provider.InEventProvider;


public class Event
{
    public static class Api
    {
        public static final String  NAMESPACE      = "event";

        private static final String GET_PEOPLE     = ApiRequest.BASE_URL + NAMESPACE + ".getPeople&tokenID=%s&eventID=%d&selection=%s";
        private static final String GET_ACTIVITIES = ApiRequest.BASE_URL + NAMESPACE + ".getActivities&eventID=%s";
        private static final String GET_SCHEDULE   = ApiRequest.BASE_URL + NAMESPACE + ".getSchedule&tokenID=%s&eventID=%d";


        public static HttpURLConnection getPeople(String tokenID, long eventID, PeopleSelection selection) throws IOException
        {
            tokenID = URLEncoder.encode(tokenID, ApiRequest.ENCODING);
            URL url = new URL(String.format(GET_PEOPLE, tokenID, eventID, selection.toString()));

            return ConnectionHelper.getURLGetConnection(url);
        }

        public static HttpURLConnection getActivities(long eventID) throws IOException
        {
            URL url = new URL(String.format(GET_ACTIVITIES, eventID));

            return ConnectionHelper.getURLGetConnection(url);
        }

        public static HttpURLConnection getSchedule(String tokenID, long eventID) throws IOException
        {
            tokenID = URLEncoder.encode(tokenID, ApiRequest.ENCODING);
            URL url = new URL(String.format(GET_SCHEDULE, tokenID, eventID));

            return ConnectionHelper.getURLGetConnection(url);
        }

        public static enum PeopleSelection
        {
            ALL {
                @Override
                public String toString()
                {
                    return "all";
                }
            },
            DENIED {
                @Override
                public String toString()
                {
                    return "denied";
                }
            },
            UNSEEN {
                @Override
                public String toString()
                {
                    return "unseen";
                }
            }
        }
    }


    public static interface Columns extends BaseColumns
    {
        public static final String NAME        = "name";
        public static final String DESCRIPTION = "description";
        public static final String DATE_BEGIN  = "dateBegin";
        public static final String DATE_END    = "dateEnd";
        public static final String LATITUDE    = "latitude";
        public static final String LONGITUDE   = "longitude";
        public static final String ADDRESS     = "address";
        public static final String CITY        = "city";
        public static final String STATE       = "state";


        public static final String[] PROJECTION_LIST = {
            TABLE_NAME+"."+_ID,
            TABLE_NAME+"."+NAME,
            TABLE_NAME+"."+DESCRIPTION,
            TABLE_NAME+"."+DATE_BEGIN,
            TABLE_NAME+"."+DATE_END,
            TABLE_NAME+"."+CITY,
            TABLE_NAME+"."+STATE
        };

        public static final String[] PROJECTION_DETAIL = {
            TABLE_NAME+"."+NAME,
            TABLE_NAME+"."+DESCRIPTION,
            TABLE_NAME+"."+DATE_BEGIN,
            TABLE_NAME+"."+DATE_END,
            TABLE_NAME+"."+LATITUDE,
            TABLE_NAME+"."+LONGITUDE,
            TABLE_NAME+"."+ADDRESS
        };
    }

    // Database
    public static final String TABLE_NAME = "event";

    // Content Provider
    public static final String EVENT_PATH            = "event";
    public static final Uri    EVENT_CONTENT_URI     = Uri.withAppendedPath(InEventProvider.CONTENT_URI, EVENT_PATH);
    public static final String ATTENDERS_PATH        = "event/attenders";
    public static final Uri    ATTENDERS_CONTENT_URI = Uri.withAppendedPath(InEventProvider.CONTENT_URI, ATTENDERS_PATH);


    // Role IDs
    public static final short ROLE_ATTENDEE    = 1;
    public static final short ROLE_STAFF       = 2;
    public static final short ROLE_COORDINATOR = 4;

    public static ContentValues valuesFromJson(JSONObject json)
    {
        ContentValues cv = new ContentValues();

        try
        {
            cv.put(_ID, json.getLong(JsonUtils.ID));
            cv.put(NAME, Html.fromHtml(json.getString(NAME)).toString());
            cv.put(DESCRIPTION, Html.fromHtml(json.getString(DESCRIPTION)).toString());
            cv.put(DATE_BEGIN, json.getLong(DATE_BEGIN));
            cv.put(DATE_END, json.getLong(DATE_END));
            cv.put(LATITUDE, json.getDouble(LATITUDE));
            cv.put(LONGITUDE, json.getDouble(LONGITUDE));
            cv.put(ADDRESS, Html.fromHtml(json.getString(ADDRESS)).toString());
            cv.put(CITY, Html.fromHtml(json.getString(CITY)).toString());
            cv.put(STATE, Html.fromHtml(json.getString(STATE)).toString());
        }
        catch (JSONException e)
        {
            Log.w(InEvent.NAME, "Error retrieving information for Event from json = "+json, e);
        }

        return cv;
    }


    public static class Member
    {
        public static interface Columns extends BaseColumns
        {
            public static final String EVENT_ID  = "eventID";
            public static final String MEMBER_ID = "memberID";
            public static final String APPROVED  = "approved";
            public static final String ROLE_ID   = "roleID";
        }

        public static final String REQUEST_ID = "requestID";

        // Database
        public static final String TABLE_NAME = "eventMember";

        public static ContentValues valuesFromJson(JSONObject json, long eventID)
        {
            ContentValues cv = new ContentValues();

            try
            {
                cv.put(Columns._ID, json.getLong(REQUEST_ID));
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
}
