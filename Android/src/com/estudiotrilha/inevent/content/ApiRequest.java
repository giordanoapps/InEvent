package com.estudiotrilha.inevent.content;

import java.net.HttpURLConnection;

import org.apache.http.protocol.HTTP;
import org.json.JSONObject;

import com.estudiotrilha.android.net.ConnectionHelper;
import com.estudiotrilha.inevent.Utils;

import android.content.Context;


public class ApiRequest extends com.estudiotrilha.android.content.ApiRequest
{
    public static final String BASE_URL =
//            InEvent.DEBUG ?
//                "http://pedrogoes.info/InEvent-dev/Web/developer/api/?method=" :
                "http://inevent.us/developer/api/?method=";

    public static final String ENCODING = HTTP.UTF_8;

    public ApiRequest(final int requestCode, final String post, final HttpURLConnection connection, final ResponseHandler handler, final boolean async)
    {
        super(requestCode, post, connection, handler, async);
    }

    public static void init(final Context c)
    {
        setEncoding(ENCODING);
        setOnRequestListener(new com.estudiotrilha.android.content.ApiRequest.OnRequestListener() {
            @Override
            public boolean OnPreExceute(int requestCode, String post, HttpURLConnection connection, ResponseHandler handler, boolean async)
            {
                boolean hasConnection = Utils.checkConnectivity(c);
                if (!hasConnection)
                {
                    handler.handleResponse(requestCode, null, ConnectionHelper.INTERNET_DISCONNECTED);
                }

                return hasConnection;
            }

            @Override public void OnPostExceute(int requestCode, int responseCode, ResponseHandler handler, JSONObject json) {}            
        });
    }


    public interface RequestCodes
    {
        public interface Member
        {
            public static final int SIGN_IN               = 0;
            public static final int SIGN_IN_WITH_FACEBOOK = 1;
            public static final int GET_EVENTS            = 2;
        }
    }
}
