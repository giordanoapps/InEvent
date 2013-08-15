package com.estudiotrilha.inevent.content;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.ContentValues;
import android.text.Html;
import android.util.Log;

import com.estudiotrilha.android.net.ConnectionHelper;
import com.estudiotrilha.inevent.InEvent;


public class Event
{
    public static class Api
    {
        public static final String  NAMESPACE      = "event";

        private static final String GET_PEOPLE     = ApiRequest.BASE_URL + NAMESPACE + ".getPeople&tokenID=%s&eventID=%d&selection=%s";
        private static final String GET_ACTIVITIES = ApiRequest.BASE_URL + NAMESPACE + ".getActivities&eventID=%s";
        private static final String GET_SCHEDULE   = ApiRequest.BASE_URL + NAMESPACE + ".getSchedule&tokeID=%s&eventID=%d";


        public static HttpURLConnection getPeople(String tokenID, long eventID, GetPeopleSelection selection) throws IOException
        {
            tokenID = URLEncoder.encode(tokenID, ApiRequest.ENCODING);
            URL url = new URL(String.format(GET_PEOPLE, tokenID, eventID, selection.toString()));

            return ConnectionHelper.getURLGetConnection(url);
        }

        public static HttpURLConnection getActivities(long eventID) throws IOException
        {
            URL url = new URL(String.format(GET_ACTIVITIES, eventID));

            return ConnectionHelper.getURLPostConnection(url);
        }

        public static HttpURLConnection getSchedule(String tokenID, long eventID) throws IOException
        {
            tokenID = URLEncoder.encode(tokenID, ApiRequest.ENCODING);
            URL url = new URL(String.format(GET_SCHEDULE, tokenID, eventID));

            return ConnectionHelper.getURLPostConnection(url);
        }

        public enum GetPeopleSelection
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


    public static final String NAME        = "name";
    public static final String DESCRIPTION = "description";
    public static final String LATITUDE    = "latitude";
    public static final String LONGITUDE   = "longitude";
    public static final String ADDRESS     = "address";
    public static final String CITY        = "city";
    public static final String STATE       = "state";
    public static final String APPROVED    = "approved";


    public static ContentValues valuesFromJson(JSONObject json)
    {
        ContentValues cv = new ContentValues();

        try
        {
            cv.put(NAME, Html.fromHtml(json.getString(NAME)).toString());
            cv.put(DESCRIPTION, Html.fromHtml(json.getString(DESCRIPTION)).toString());
            cv.put(LATITUDE, json.getDouble(LATITUDE));
            cv.put(LONGITUDE, json.getDouble(LONGITUDE));
            cv.put(ADDRESS, Html.fromHtml(json.getString(ADDRESS)).toString());
            cv.put(CITY, Html.fromHtml(json.getString(CITY)).toString());
            cv.put(STATE, Html.fromHtml(json.getString(STATE)).toString());
            cv.put(APPROVED, json.getInt(APPROVED));
        }
        catch (JSONException e)
        {
            Log.w(InEvent.NAME, "Error retrieving information for Event from json = "+json, e);
        }

        return cv;
    }
}
