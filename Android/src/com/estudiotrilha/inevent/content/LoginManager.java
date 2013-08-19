package com.estudiotrilha.inevent.content;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.net.HttpURLConnection;
import java.util.ArrayList;

import org.apache.http.HttpStatus;
import org.json.JSONObject;

import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.util.Log;
import android.util.Pair;

import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.service.SyncService;


public class LoginManager
{
    // CONSTANTS
    private static final String DIRECTORY           = "loginManagerData";
    private static final String FILENAME_MEMBER     = "memberInfoFile.bin";

    // BROADCAST INTENTS
    public static final String ACTION_REVOKE_ACCESS       = InEvent.class.getPackage().getName()+".action.REVOKE_ACCESS";
    public static final String ACTION_LOGIN_STATE_CHANGED = InEvent.class.getPackage().getName()+".action.CHECK_STATE_CHANGED";


    private static LoginManager sInstance;
    public static LoginManager getInstance(Context c)
    {
        if (sInstance == null) sInstance = new LoginManager(c);
        if (c != null) sInstance.mContext = c;
        return sInstance;
    }

    // Attendance things
    private static final int    INTERVAL_RETRY_SENDING_ATTENDANCE_LIST = 15 * 60 * 1000; // every 15 minutes
    private static final String FILENAME_ATTENDANCE = "attendanceFile.bin";
    private AttendanceConfirmationHolder mAttendanceRequests;

    private Context mContext;

    private Member  mMember;
    private File    mMemberFile;


    private LoginManager(Context c)
    {
        this.mContext = c;

        mMemberFile = new File(mContext.getDir(DIRECTORY, Context.MODE_PRIVATE), FILENAME_MEMBER);

        // Try to recover the member login information
        mMember = (Member) readInformationFromFile(mMemberFile);

        // and the attendance
        mAttendanceRequests = (AttendanceConfirmationHolder) readInformationFromFile(new File(FILENAME_ATTENDANCE));
    }

    private Object readInformationFromFile(File file)
    {
        Object obj = null;
        
        if (file.exists())
        {
            ObjectInputStream stream = null;
            try
            {
                stream = new ObjectInputStream(new FileInputStream(file));

                // read from the file
                obj = stream.readObject();

                stream.close();
            }
            catch (Exception e)
            {
                Log.w(InEvent.NAME, "Couldn't recover saved login state from file "+file, e);
            }
        }

        return obj;
    }
    /**
     * @return <b>true</b> if the operation was successful
     */
    private boolean saveInformationToFile(File file, Serializable info)
    {
        if (info == null) return false;

        try
        {
            // erase previous data
            file.delete();

            // save the info to the file
            file.createNewFile();
            ObjectOutputStream stream = new ObjectOutputStream(new FileOutputStream(file));
            stream.writeObject(info);
            stream.close();
        }
        catch (Exception e)
        {
            Log.w(InEvent.NAME, "Couldn't save the login state to file "+file, e);
            return false;
        }

        return true;
    }

    /**
     * @return <b>true</b> if the operation was successful
     */
    public boolean signIn(Member m)
    {
        if (saveInformationToFile(mMemberFile, m))
        {
            // register the attributes
            mMember = m;

            // broadcasts that the user has logged in
            mContext.sendBroadcast(new Intent(ACTION_LOGIN_STATE_CHANGED));

            // Download the content

            // Prepare the intent
            Intent intent = new Intent(mContext, SyncService.class);
            intent.putExtra(SyncService.EXTRA_EVENT_ID, 1); // XXX

            // Download the activities
            mContext.startService(intent.setData(Activity.ACTIVITY_CONTENT_URI));
            // the schedule
            mContext.startService(intent.setData(Activity.SCHEDULE_CONTENT_URI));
            // and the attenders
            mContext.startService(intent.setData(Event.ATTENDERS_CONTENT_URI));

            return true;
        }

        return false;
    }
    public void signOut()
    {
        mMemberFile.delete();
        mMember = null;

        // broadcasts that the user has logged in
        mContext.sendBroadcast(new Intent(ACTION_LOGIN_STATE_CHANGED));
    }


    // Getters
    public boolean isSignedIn()
    {
        return mMember != null;
    }


    public Member getMember()
    {
        return mMember;
    }
    public String getTokenId()
    {
        if (isSignedIn()) return mMember.tokenId;
        else return null;
    }

    public void confirmPresence(long activityID, long personID)
    {
        // Save the new state to the file
        saveInformationToFile(new File(FILENAME_ATTENDANCE), mAttendanceRequests);

        // Add the data to the request list
        mAttendanceRequests.info.add(new Pair<Long, Long>(personID, activityID));
        // and send it
        mAttendanceRequests.sendRequests();
    }


    class AttendanceConfirmationHolder implements Serializable
    {
        private static final long serialVersionUID = -6795878015775849060L;

        final ArrayList<Pair<Long, Long>> info = new ArrayList<Pair<Long,Long>>();


        public void sendRequests()
        {
            for (final Pair<Long, Long> element : info)
            {
                // Send the request
                try
                {
                    // Get some info
                    String tokenID = LoginManager.getInstance(mContext).getTokenId();
                    long activityID = element.second;

                    // Prepare the connection
                    HttpURLConnection connection = Activity.Api.confirmEntrance(tokenID, activityID, element.first);
                    ApiRequest.getJsonFromConnection(0, connection, new ApiRequest.ResponseHandler() {
                        @Override
                        public void handleResponse(int requestId, JSONObject json, int responseCode)
                        {
                            if (responseCode == HttpStatus.SC_OK && json != null)
                            {
                                // Remove it from the list!
                                info.remove(element);

                                // Save the new state to the file
                                saveInformationToFile(new File(FILENAME_ATTENDANCE), mAttendanceRequests);
                            }
                        }
                    });
                }
                catch (IOException e)
                {
                    Log.e(InEvent.NAME, "Couldn't create connection for activity.confirmEntrance(tokenID, activityID, personID)", e);
                }
            }

            // Check if everything were sent properly
            if (!info.isEmpty())
            {
                // There were errors, try again later
                new Handler().postDelayed(new Runnable() {
                    @Override
                    public void run()
                    {
                        sendRequests();
                    }
                }, INTERVAL_RETRY_SENDING_ATTENDANCE_LIST);
            }
        }
    }
}
