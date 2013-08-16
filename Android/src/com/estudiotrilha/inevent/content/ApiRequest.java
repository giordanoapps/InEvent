package com.estudiotrilha.inevent.content;

import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;

import org.apache.http.protocol.HTTP;
import org.json.JSONObject;

import android.os.Handler;
import android.util.Log;

import com.estudiotrilha.android.utils.ConnectionUtils;
import com.estudiotrilha.android.utils.JsonUtils;
import com.estudiotrilha.inevent.InEvent;


public class ApiRequest
{
    public static final String BASE_URL =
//            InEvent.DEBUG ?
//                "http://pedrogoes.info/InEvent-dev/Web/developer/api/?method=" :
                "http://inevent.us/developer/api/?method=";

    public static final String ENCODING = HTTP.UTF_8;



    public interface ResponseHandler
    {
        public void handleResponse(int requestCode, JSONObject json, int responseCode);
    }

    public static void getJsonFromConnection(int requestCode, HttpURLConnection connection, ResponseHandler handler)
    {
        getJsonFromConnection(requestCode, connection, handler, null, true);
    }
    public static void getJsonFromConnection(int requestCode, HttpURLConnection connection, ResponseHandler handler, boolean async)
    {
        getJsonFromConnection(requestCode, connection, handler, null, async);
    }
    public static void getJsonFromConnection(int requestCode, HttpURLConnection connection, ResponseHandler handler, String post)
    {
        getJsonFromConnection(requestCode, connection, handler, null, true);
    }
    public static void getJsonFromConnection(int requestCode, HttpURLConnection connection, ResponseHandler handler, String post, boolean async)
    {
        new ApiRequest(requestCode, post, connection, handler, async);
    }


    private ApiRequest(final int requestCode, final String post, final HttpURLConnection connection, final ResponseHandler handler, final boolean async)
    {
        final Handler userHandler = new Handler();

        Runnable runnable = new Runnable() {

            private int        mResponseCode;
            private JSONObject mJson;

            @Override
            public void run()
            {
                mJson = null;
                mResponseCode = -1;

                try
                {
                    if (post != null)
                    {
                        // send the post
                        OutputStream outputStream = connection.getOutputStream();
                        byte[] buffer = post.getBytes(ENCODING);
                        outputStream.write(buffer);
                        outputStream.flush();
                        outputStream.close();
                    }

                    // creates the connection
                    connection.connect();
                    mResponseCode = connection.getResponseCode();

                    // get the data input stream
                    InputStream in = connection.getInputStream();
                    // parse to json
                    mJson = JsonUtils.inputStreamToJSON(in, ENCODING);
                }
                catch (Exception e)
                {
                    mResponseCode = ConnectionUtils.checkConnectionException(e, mResponseCode);
                    Log.w(InEvent.NAME, "Couldn't properly process " + connection + " response = "+mResponseCode, e);
                }
                finally
                {
                    if (connection != null) connection.disconnect();
                }

                // callback
                if (async)
                {
                    userHandler.post(new Runnable() {
                        public void run()
                        {
                            if (handler != null) handler.handleResponse(requestCode, mJson, mResponseCode);
                        }
                    });
                }
                else
                {
                    if (handler != null) handler.handleResponse(requestCode, mJson, mResponseCode);
                }
            }
        };

        if (async)
        {
            new Thread(runnable).start();
        }
        else
        {
            runnable.run();
        }
    }
}
