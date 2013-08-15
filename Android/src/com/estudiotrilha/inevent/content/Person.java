package com.estudiotrilha.inevent.content;

import java.io.IOException;
import java.io.Serializable;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

import org.json.JSONException;
import org.json.JSONObject;

import android.text.Html;
import android.util.Log;

import com.estudiotrilha.android.net.ConnectionHelper;
import com.estudiotrilha.inevent.InEvent;


public class Person implements Serializable
{
    private static final long serialVersionUID = 5341927475443621774L;


    public static class Api
    {
        public static final String  NAMESPACE             = "person";
        private static final String SIGN_IN               = ApiRequest.BASE_URL + NAMESPACE + ".signIn&name=%s&password=%s";
        private static final String SIGN_IN_WITH_FACEBOOK = ApiRequest.BASE_URL + NAMESPACE + ".signInWithFacebook&facebookToken=%s";
        private static final String GET_EVENTS            = ApiRequest.BASE_URL + NAMESPACE + ".getEvents&tokenID=%s";


        public static HttpURLConnection signIn(String member, String password) throws IOException
        {
            member = URLEncoder.encode(member, ApiRequest.ENCODING);
            password = URLEncoder.encode(password, ApiRequest.ENCODING);
            URL url = new URL(String.format(SIGN_IN, member, password));

            return ConnectionHelper.getURLGetConnection(url);
        }

        public static HttpURLConnection signInWithFacebook(String facebookToken) throws IOException
        {
            facebookToken = URLEncoder.encode(facebookToken, ApiRequest.ENCODING);
            URL url = new URL(String.format(SIGN_IN_WITH_FACEBOOK, facebookToken));

            return ConnectionHelper.getURLPostConnection(url);
        }

        public static HttpURLConnection getEvents(String tokenID) throws IOException
        {
            tokenID = URLEncoder.encode(tokenID, ApiRequest.ENCODING);
            URL url = new URL(String.format(GET_EVENTS, tokenID));

            return ConnectionHelper.getURLPostConnection(url);
        }
    }


    public static final String MEMBER_ID = "memberID";
    public static final String NAME      = "name";
    public static final String TOKEN_ID  = "tokenID";


    // Person as an object that contains information
    public final long   memberId;
    public final String tokenId;
    public final String name;

    public Person(long memberId, String name, String tokenId) // TODO finish this
    {
        this.memberId = memberId;
        this.name = name;
        this.tokenId = tokenId;
    }


    public static Person fromJson(JSONObject json) // TODO
    {
        Person p = null;

        try
        {
            p = new Person(
                    json.getLong(MEMBER_ID),
                    Html.fromHtml(json.getString(NAME)).toString(),
                    json.getString(TOKEN_ID)
            );
        }
        catch (JSONException e)
        {
            Log.w(InEvent.NAME, "Couldn't properly retrieve Person from json = "+json, e);
        }

        return p;
    }
}
