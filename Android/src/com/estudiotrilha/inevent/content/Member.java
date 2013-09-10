package com.estudiotrilha.inevent.content;

import static android.provider.BaseColumns._ID;
import static com.estudiotrilha.inevent.content.Member.Columns.EMAIL;
import static com.estudiotrilha.inevent.content.Member.Columns.NAME;
import static com.estudiotrilha.inevent.content.Member.Columns.TELEPHONE;

import java.io.IOException;
import java.io.Serializable;
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
import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.provider.InEventProvider;


public class Member implements Serializable
{
    private static final long serialVersionUID = 5341927475443621774L;


    // API
    public static class Api
    {
        public static final class Post
        {
            private static final String ENROLL = "name=%s&password=%s&email=%s&cpf=%s&telephone=%s&university=%s&course=%s";

            /**
             * @param cpf - The person CPF. This can be null
             * @param telephone - Some telephone. This can be null
             * @return the prepared post String to send along with the {@link HttpURLConnection} from {@link Person#enroll()}
             */
            public static String enroll(String name, String password, String email, String cpf, String telephone)
            {
                return enroll(name, password, email, cpf, telephone, null, null);
            }

            public static String enroll(String name, String password, String email, String cpf, String telephone, String university, String course)
            {
                return String.format(Locale.ENGLISH, ENROLL, name, password, email, cpf, telephone, university, course);
            }
        }

        public static final String  NAMESPACE             = "person";
        private static final String SIGN_IN               = ApiRequest.BASE_URL + NAMESPACE + ".signIn&email=%s&password=%s";
        private static final String SIGN_IN_WITH_FACEBOOK = ApiRequest.BASE_URL + NAMESPACE + ".signInWithFacebook&facebookToken=%s";
        private static final String ENROLL                = ApiRequest.BASE_URL + NAMESPACE + ".enroll";
        private static final String GET_EVENTS            = ApiRequest.BASE_URL + NAMESPACE + ".getEvents&tokenID=%s";


        public static HttpURLConnection signIn(String email, String password) throws IOException
        {
            email = URLEncoder.encode(email, ApiRequest.ENCODING);
            password = URLEncoder.encode(password, ApiRequest.ENCODING);
            URL url = new URL(String.format(SIGN_IN, email, password));

            return ConnectionHelper.getURLGetConnection(url);
        }

        public static HttpURLConnection signInWithFacebook(String facebookToken) throws IOException
        {
            facebookToken = URLEncoder.encode(facebookToken, ApiRequest.ENCODING);
            URL url = new URL(String.format(SIGN_IN_WITH_FACEBOOK, facebookToken));

            return ConnectionHelper.getURLGetConnection(url);
        }

        public static HttpURLConnection enroll() throws IOException
        {
            URL url = new URL(ENROLL);

            return ConnectionHelper.getURLPostConnection(url);
        }

        public static HttpURLConnection getEvents(String tokenID) throws IOException
        {
            tokenID = URLEncoder.encode(tokenID, ApiRequest.ENCODING);
            URL url = new URL(String.format(GET_EVENTS, tokenID));

            return ConnectionHelper.getURLGetConnection(url);
        }
    }

    // Database
    public static final String TABLE_NAME = "person";
    public static interface Columns extends BaseColumns
    {
        public static final String NAME        = "name";
        public static final String TELEPHONE   = "telephone";
        public static final String EMAIL       = "email";
        public static final String IMAGE       = "image";
        // Full names
        public static final String _ID_FULL       = TABLE_NAME+"."+_ID;
        public static final String NAME_FULL      = TABLE_NAME+"."+NAME;
        public static final String TELEPHONE_FULL = TABLE_NAME+"."+TELEPHONE;
        public static final String EMAIL_FULL     = TABLE_NAME+"."+EMAIL;
        public static final String IMAGE_FULL     = TABLE_NAME+"."+IMAGE;
    }

    // Content Provider
    public static final String PATH     = "person";
    public static final Uri CONTENT_URI = Uri.withAppendedPath(InEventProvider.CONTENT_URI, PATH);


    // Json Strings
    public static final String MEMBER_ID = "memberID";
    public static final String TOKEN_ID  = "tokenID";


    // Person as an object that contains information
    public final long   memberId;
    public final String tokenId;
    public final String name;

    public Member(long memberId, String name, String tokenId)
    {
        this.memberId = memberId;
        this.name = name;
        this.tokenId = tokenId;
    }
    public static Member fromJson(JSONObject json)
    {
        Member m = null;

        try
        {
            m = new Member(
                    json.getLong(MEMBER_ID),
                    Html.fromHtml(json.getString(NAME)).toString(),
                    json.getString(TOKEN_ID)
            );
        }
        catch (JSONException e)
        {
            Log.w(InEvent.NAME, "Couldn't properly retrieve Person from json = "+json, e);
        }

        return m;
    }


    public static ContentValues valuesFromJson(JSONObject json)
    {
        ContentValues cv = new ContentValues();

        try
        {
            cv.put(_ID, json.getLong(MEMBER_ID));
            cv.put(NAME, Html.fromHtml(json.getString(NAME)).toString());
            cv.put(TELEPHONE, json.getString(TELEPHONE));
            cv.put(EMAIL, Html.fromHtml(json.getString(EMAIL)).toString());
        }
        catch (JSONException e)
        {
            Log.w(InEvent.NAME, "Error retrieving information for Event from json = "+json, e);
        }

        return cv;
    }
}
