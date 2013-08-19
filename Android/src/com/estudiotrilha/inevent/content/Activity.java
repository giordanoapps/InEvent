package com.estudiotrilha.inevent.content;

import static com.estudiotrilha.inevent.content.Activity.Columns.*;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

import org.json.JSONException;
import org.json.JSONObject;

import com.estudiotrilha.android.net.ConnectionHelper;
import com.estudiotrilha.android.utils.JsonUtils;
import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.provider.InEventProvider;

import android.content.ContentValues;
import android.net.Uri;
import android.provider.BaseColumns;
import android.text.Html;
import android.util.Log;

public class Activity
{
    public static final class Api
    {
        public static final String  NAMESPACE = "activity";

        private static final String CONFIRM_ENTRANCE = ApiRequest.BASE_URL + NAMESPACE + ".confirmEntrance&tokenID=%s&activityID=%d&personID=%d";
        private static final String GET_PEOPLE       = ApiRequest.BASE_URL + NAMESPACE + ".getPeople&tokenID=%s&activityID=%d&selection=%s";

        public static HttpURLConnection confirmEntrance(String tokenID, long activityID, long personID) throws IOException
        {
            tokenID = URLEncoder.encode(tokenID, ApiRequest.ENCODING);
            URL url = new URL(String.format(CONFIRM_ENTRANCE, tokenID, activityID, personID));

            return ConnectionHelper.getURLGetConnection(url);
        }
        public static HttpURLConnection getPeople(String tokenID, long activityID, PeopleSelection selection) throws IOException
        {
            tokenID = URLEncoder.encode(tokenID, ApiRequest.ENCODING);
            URL url = new URL(String.format(GET_PEOPLE, tokenID, activityID, selection.toString()));

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
            APPROVED {
                @Override
                public String toString()
                {
                    return "approved";
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
        public static final String EVENT_ID    = "eventID";
        public static final String NAME        = "name";
        public static final String DESCRIPTION = "description";
        public static final String LOCATION    = "location";
        public static final String DATE_BEGIN  = "dateBegin";
        public static final String DATE_END    = "dateEnd";


        public static final String[] PROJECTION_LIST = {
            TABLE_NAME+"."+_ID,
            TABLE_NAME+"."+NAME,
            TABLE_NAME+"."+LOCATION,
            TABLE_NAME+"."+DATE_BEGIN,
            TABLE_NAME+"."+DATE_END
        };
    }

    // Database
    public static final String TABLE_NAME = "activity";

    // Content Provider
    public static final String ACTIVITY_PATH      = "activity";
    public static final Uri ACTIVITY_CONTENT_URI  = Uri.withAppendedPath(InEventProvider.CONTENT_URI, ACTIVITY_PATH);
    public static final String SCHEDULE_PATH      = "activity/schedule";
    public static final Uri SCHEDULE_CONTENT_URI  = Uri.withAppendedPath(InEventProvider.CONTENT_URI, SCHEDULE_PATH);
    public static final String ATTENDERS_PATH     = "activity/attenders";
    public static final Uri ATTENDERS_CONTENT_URI = Uri.withAppendedPath(InEventProvider.CONTENT_URI, ATTENDERS_PATH);


    public static ContentValues valuesFromJson(JSONObject json, long eventID)
    {
        ContentValues cv = new ContentValues();

        try
        {
            cv.put(_ID, json.getLong(JsonUtils.ID));
            cv.put(EVENT_ID, eventID);
            cv.put(NAME, Html.fromHtml(json.getString(NAME)).toString());
            cv.put(DESCRIPTION, Html.fromHtml(json.getString(DESCRIPTION)).toString());
            cv.put(DATE_BEGIN, json.getLong(DATE_BEGIN));
            cv.put(DATE_END, json.getLong(DATE_END));
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
            public static final String EVENT_ID    = "eventID";
            public static final String ACTIVITY_ID = "activityID";
            public static final String MEMBER_ID   = "memberID";
            public static final String APPROVED    = "approved";
            public static final String PRESENT     = "present";

            public static final String[] PROJECTION_SCHEDULE_LIST = {
                Activity.TABLE_NAME+"."+Activity.Columns._ID,
                Activity.TABLE_NAME+"."+Activity.Columns.NAME,
                Activity.TABLE_NAME+"."+Activity.Columns.LOCATION,
                Activity.TABLE_NAME+"."+Activity.Columns.DATE_BEGIN,
                Activity.TABLE_NAME+"."+Activity.Columns.DATE_END,
                TABLE_NAME+"."+APPROVED
            };

            public static final String[] PROJECTION_ATTENDANCE_LIST = {
                com.estudiotrilha.inevent.content.Member.TABLE_NAME+"."+com.estudiotrilha.inevent.content.Member.Columns._ID,
                com.estudiotrilha.inevent.content.Member.TABLE_NAME+"."+com.estudiotrilha.inevent.content.Member.Columns.NAME,
                TABLE_NAME+"."+PRESENT
            };
        }

        // Database
        public static final String TABLE_NAME = "activityMember";

        public static ContentValues newActivtyMember(long eventID, long activityID, long memberID, boolean approved, boolean present)
        {
            ContentValues cv = new ContentValues();

            cv.put(Columns.EVENT_ID, eventID);
            cv.put(Columns.ACTIVITY_ID, activityID);
            cv.put(Columns.MEMBER_ID, memberID);
            cv.put(Columns.APPROVED, approved ? 1 : 0);
            cv.put(Columns.PRESENT, present ? 1 : 0);

            return cv;
        }
        public static ContentValues newActivtyMember(long eventID, long activityID, long memberID, boolean approved)
        {
            return newActivtyMember(eventID, activityID, memberID, approved, false);
        }
    }
}
