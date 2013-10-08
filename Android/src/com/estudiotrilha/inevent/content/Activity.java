package com.estudiotrilha.inevent.content;

import static android.provider.BaseColumns._ID;
import static com.estudiotrilha.inevent.content.Activity.Columns.DATE_BEGIN;
import static com.estudiotrilha.inevent.content.Activity.Columns.DATE_END;
import static com.estudiotrilha.inevent.content.Activity.Columns.DESCRIPTION;
import static com.estudiotrilha.inevent.content.Activity.Columns.EVENT_ID;
import static com.estudiotrilha.inevent.content.Activity.Columns.LATITUDE;
import static com.estudiotrilha.inevent.content.Activity.Columns.LOCATION;
import static com.estudiotrilha.inevent.content.Activity.Columns.LONGITUDE;
import static com.estudiotrilha.inevent.content.Activity.Columns.NAME;

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


public class Activity
{
    public static final class Api
    {
        public static final class Post
        {
            private static final String SEND_OPINION = "rating=%d";

            public static String sendOpinion(int rating)
            {
                return String.format(Locale.ENGLISH, SEND_OPINION, rating);
            }
        }

        public static final String  NAMESPACE = "activity";

        private static final String REQUEST_ENROLLMENT = ApiRequest.BASE_URL + NAMESPACE + ".requestEnrollment&tokenID=%s&activityID=%d";
        private static final String DISMISS_ENROLLMENT = ApiRequest.BASE_URL + NAMESPACE + ".dismissEnrollment&tokenID=%s&activityID=%d";
        private static final String CONFIRM_ENTRANCE   = ApiRequest.BASE_URL + NAMESPACE + ".confirmEntrance&tokenID=%s&activityID=%d&personID=%d";
        private static final String REVOKE_ENTRANCE    = ApiRequest.BASE_URL + NAMESPACE + ".revokeEntrance&tokenID=%s&activityID=%d&personID=%d";
        private static final String CONFIRM_PAYMENT    = ApiRequest.BASE_URL + NAMESPACE + ".confirmPayment&tokenID=%s&activityID=%d&personID=%d";
        private static final String REVOKE_PAYMENT     = ApiRequest.BASE_URL + NAMESPACE + ".revokePayment&tokenID=%s&activityID=%d&personID=%d";
        private static final String GET_PEOPLE         = ApiRequest.BASE_URL + NAMESPACE + ".getPeople&tokenID=%s&activityID=%d&selection=%s";
        private static final String GET_OPINION        = ApiRequest.BASE_URL + NAMESPACE + ".getOpinion&tokenID=%s&activityID=%d";
        private static final String SEND_OPINION       = ApiRequest.BASE_URL + NAMESPACE + ".sendOpinion&tokenID=%s&activityID=%d";

        public static HttpURLConnection requestEnrollment(String tokenID, long activityID) throws IOException
        {
            return requestEnrollment(tokenID, activityID, null, null);
        }
        public static HttpURLConnection requestEnrollment(String tokenID, long activityID, String name, String email) throws IOException
        {
            tokenID = URLEncoder.encode(tokenID, ApiRequest.ENCODING);
            String formatString = String.format(Locale.ENGLISH, REQUEST_ENROLLMENT, tokenID, activityID);
            if (name != null && email != null)
            {
                formatString += "&name="+URLEncoder.encode(name, ApiRequest.ENCODING)
                             +  "&email="+URLEncoder.encode(email, ApiRequest.ENCODING);
            }
            URL url = new URL(formatString);

            return ConnectionHelper.getURLGetConnection(url);
        }

        public static HttpURLConnection dismissEnrollment(String tokenID, long activityID) throws IOException
        {
            return dismissEnrollment(tokenID, activityID, -1);
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

        public static HttpURLConnection confirmEntrance(String tokenID, long activityID, long personID) throws IOException
        {
            tokenID = URLEncoder.encode(tokenID, ApiRequest.ENCODING);
            URL url = new URL(String.format(CONFIRM_ENTRANCE, tokenID, activityID, personID));

            return ConnectionHelper.getURLGetConnection(url);
        }

        public static HttpURLConnection revokeEntrance(String tokenID, long activityID, long personID) throws IOException
        {
            tokenID = URLEncoder.encode(tokenID, ApiRequest.ENCODING);
            URL url = new URL(String.format(REVOKE_ENTRANCE, tokenID, activityID, personID));

            return ConnectionHelper.getURLGetConnection(url);
        }

        public static HttpURLConnection confirmPayment(String tokenID, long activityID, long personID) throws IOException
        {
            tokenID = URLEncoder.encode(tokenID, ApiRequest.ENCODING);
            URL url = new URL(String.format(CONFIRM_PAYMENT, tokenID, activityID, personID));

            return ConnectionHelper.getURLGetConnection(url);
        }

        public static HttpURLConnection revokePayment(String tokenID, long activityID, long personID) throws IOException
        {
            tokenID = URLEncoder.encode(tokenID, ApiRequest.ENCODING);
            URL url = new URL(String.format(REVOKE_PAYMENT, tokenID, activityID, personID));

            return ConnectionHelper.getURLGetConnection(url);
        }

        public static HttpURLConnection getPeople(String tokenID, long activityID, PeopleSelection selection) throws IOException
        {
            tokenID = URLEncoder.encode(tokenID, ApiRequest.ENCODING);
            URL url = new URL(String.format(GET_PEOPLE, tokenID, activityID, selection.toString()));

            return ConnectionHelper.getURLGetConnection(url);
        }

        public static HttpURLConnection getOpinion(String tokenID, long activityID) throws IOException
        {
            tokenID = URLEncoder.encode(tokenID, ApiRequest.ENCODING);
            URL url = new URL(String.format(GET_OPINION, tokenID, activityID));

            return ConnectionHelper.getURLGetConnection(url);
        }

        public static HttpURLConnection sendOpinion(String tokenID, long activityID) throws IOException
        {
            tokenID = URLEncoder.encode(tokenID, ApiRequest.ENCODING);
            URL url = new URL(String.format(SEND_OPINION, tokenID, activityID));

            return ConnectionHelper.getURLPostConnection(url);
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

    // Database
    public static final String TABLE_NAME = "activity";
    public static interface Columns extends BaseColumns
    {
        public static final String EVENT_ID    = "eventID";
        public static final String NAME        = "name";
        public static final String DESCRIPTION = "description";
        public static final String LOCATION    = "location";
        public static final String LATITUDE    = "latitude";
        public static final String LONGITUDE   = "longitude";
        public static final String DATE_BEGIN  = "dateBegin";
        public static final String DATE_END    = "dateEnd";
        // Full names
        public static final String _ID_FULL         = TABLE_NAME+"."+_ID;
        public static final String EVENT_ID_FULL    = TABLE_NAME+"."+EVENT_ID;
        public static final String NAME_FULL        = TABLE_NAME+"."+NAME;
        public static final String DESCRIPTION_FULL = TABLE_NAME+"."+DESCRIPTION;
        public static final String LOCATION_FULL    = TABLE_NAME+"."+LOCATION;
        public static final String LATITUDE_FULL    = TABLE_NAME+"."+LATITUDE;
        public static final String LONGITUDE_FULL   = TABLE_NAME+"."+LONGITUDE;
        public static final String DATE_BEGIN_FULL  = TABLE_NAME+"."+DATE_BEGIN;
        public static final String DATE_END_FULL    = TABLE_NAME+"."+DATE_END;

        // Projections
        public static final String[] PROJECTION_LIST = {
            Activity.Columns._ID_FULL,
            Activity.Columns.DATE_BEGIN_FULL,
            Activity.Columns.DATE_END_FULL,
            Activity.Columns.NAME_FULL,
            Activity.Columns.LOCATION_FULL,
            "IFNULL("+ActivityMember.Columns.APPROVED_FULL+",-1) AS "+ActivityMember.Columns.APPROVED
        };
        public static final String[] PROJECTION_DETAIL = {
            Activity.Columns.NAME_FULL,
            Activity.Columns.DESCRIPTION_FULL,
            Activity.Columns.DATE_BEGIN_FULL,
            Activity.Columns.DATE_END_FULL,
            Activity.Columns.LOCATION_FULL,
            Activity.Columns.LATITUDE_FULL,
            Activity.Columns.LONGITUDE_FULL,
            "IFNULL("+ActivityMember.Columns.APPROVED_FULL+",-1) AS "+ActivityMember.Columns.APPROVED,
            "IFNULL("+Feedback.Columns.RATING_FULL+", 0) AS "+Feedback.Columns.RATING
        };
    }


    // Content Provider
    public static final String PATH     = "activity";
    public static final Uri CONTENT_URI = Uri.withAppendedPath(InEventProvider.CONTENT_URI, PATH);


    public static ContentValues valuesFromJson(JSONObject json, long eventID)
    {
        ContentValues cv = new ContentValues();

        try
        {
            cv.put(_ID, json.getLong(JsonUtils.ID));
            cv.put(EVENT_ID, eventID);
            cv.put(NAME, Html.fromHtml(json.getString(NAME)).toString());
            cv.put(DESCRIPTION, Html.fromHtml(json.getString(DESCRIPTION)).toString());
            cv.put(LOCATION, Html.fromHtml(json.getString(LOCATION)).toString());
            cv.put(LATITUDE, json.getDouble(LATITUDE));
            cv.put(LONGITUDE, json.getDouble(LONGITUDE));
            cv.put(DATE_BEGIN, json.getLong(DATE_BEGIN));
            cv.put(DATE_END, json.getLong(DATE_END));
        }
        catch (JSONException e)
        {
            Log.w(InEvent.NAME, "Error retrieving information for Event from json = "+json, e);
        }

        return cv;
    }
}
