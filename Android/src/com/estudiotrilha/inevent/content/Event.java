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
import java.util.Locale;

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

        private static final String GET_EVENTS         = ApiRequest.BASE_URL + NAMESPACE + ".getEvents";
        private static final String REQUEST_ENROLLMENT = ApiRequest.BASE_URL + NAMESPACE + ".requestEnrollment&tokenID=%s&activityID=%d";
        private static final String DISMISS_ENROLLMENT = ApiRequest.BASE_URL + NAMESPACE + ".dismissEnrollment&tokenID=%s&activityID=%d";
        private static final String GET_PEOPLE         = ApiRequest.BASE_URL + NAMESPACE + ".getPeople&tokenID=%s&eventID=%d&selection=%s";
        private static final String GET_ACTIVITIES     = ApiRequest.BASE_URL + NAMESPACE + ".getActivities&eventID=%s";
        private static final String GET_SCHEDULE       = ApiRequest.BASE_URL + NAMESPACE + ".getSchedule&tokenID=%s&eventID=%d";


        public static HttpURLConnection getEvents() throws IOException
        {
            return getEvents(null);
        }
        public static HttpURLConnection getEvents(String tokenID) throws IOException
        {
            String string = GET_EVENTS;

            if (tokenID != null)
            {
                tokenID = URLEncoder.encode(tokenID, ApiRequest.ENCODING);
                string += "&tokenID="+tokenID;
            }
            URL url = new URL(string);

            return ConnectionHelper.getURLGetConnection(url);
        }

        public static HttpURLConnection requestEnrollment(String tokenID, long activityID) throws IOException
        {
            return requestEnrollment(tokenID, activityID, -1);
        }
        public static HttpURLConnection requestEnrollment(String tokenID, long activityID, long personID) throws IOException
        {
            tokenID = URLEncoder.encode(tokenID, ApiRequest.ENCODING);
            String formatString = String.format(Locale.ENGLISH, REQUEST_ENROLLMENT, tokenID, activityID);
            if (personID != -1)
            {
                formatString += "&personID="+personID;
            }
            URL url = new URL(formatString);

            return ConnectionHelper.getURLGetConnection(url);
        }

        public static HttpURLConnection dismissEnrollment(String tokenID, long activityID) throws IOException
        {
            return requestEnrollment(tokenID, activityID, -1);
        }
        public static HttpURLConnection dismissEnrollment(String tokenID, long activityID, long personID) throws IOException
        {
            tokenID = URLEncoder.encode(tokenID, ApiRequest.ENCODING);
            String formatString = String.format(Locale.ENGLISH, DISMISS_ENROLLMENT, tokenID, activityID);
            if (personID != -1)
            {
                formatString += "&personID="+personID;
            }
            URL url = new URL(formatString);

            return ConnectionHelper.getURLGetConnection(url);
        }

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
        // Full names
        public static final String _ID_FULL         = TABLE_NAME+"."+_ID;
        public static final String NAME_FULL        = TABLE_NAME+"."+NAME;
        public static final String DESCRIPTION_FULL = TABLE_NAME+"."+DESCRIPTION;
        public static final String DATE_BEGIN_FULL  = TABLE_NAME+"."+DATE_BEGIN;
        public static final String DATE_END_FULL    = TABLE_NAME+"."+DATE_END;
        public static final String LATITUDE_FULL    = TABLE_NAME+"."+LATITUDE;
        public static final String LONGITUDE_FULL   = TABLE_NAME+"."+LONGITUDE;
        public static final String ADDRESS_FULL     = TABLE_NAME+"."+ADDRESS;
        public static final String CITY_FULL        = TABLE_NAME+"."+CITY;
        public static final String STATE_FULL       = TABLE_NAME+"."+STATE;


        public static final String[] PROJECTION_LIST = {
            Event.Columns._ID_FULL,
            Event.Columns.NAME_FULL,
            Event.Columns.DESCRIPTION_FULL,
            Event.Columns.DATE_BEGIN_FULL,
            Event.Columns.DATE_END_FULL,
            Event.Columns.CITY_FULL,
            Event.Columns.STATE_FULL,
            EventMember.Columns.APPROVED_FULL
        };

        public static final String[] PROJECTION_DETAIL = {
            Event.Columns.NAME_FULL,
            Event.Columns.DESCRIPTION_FULL,
            Event.Columns.DATE_BEGIN_FULL,
            Event.Columns.DATE_END_FULL,
            Event.Columns.LATITUDE_FULL,
            Event.Columns.LONGITUDE_FULL,
            Event.Columns.ADDRESS_FULL
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
}
