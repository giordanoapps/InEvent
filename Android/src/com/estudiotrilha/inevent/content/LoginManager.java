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

import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.util.Log;

import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.service.DownloaderService;


public class LoginManager
{
    // CONSTANTS
    private static final String DIRECTORY           = "loginManagerData";
    private static final String FILENAME_MEMBER     = "memberInfoFile.bin";

    // BROADCAST INTENTS
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

    private AttendanceHolder mAttendanceRequests;
    private File             mAttendanceFile;


    private Context mContext;

    private Member  mMember;
    private File    mMemberFile;


    private LoginManager(Context c)
    {
        this.mContext = c;

        mMemberFile = new File(mContext.getDir(DIRECTORY, Context.MODE_PRIVATE), FILENAME_MEMBER);
        mAttendanceFile = new File(mContext.getDir(DIRECTORY, Context.MODE_PRIVATE), FILENAME_ATTENDANCE);

        // Try to recover the member login information
        mMember = (Member) readInformationFromFile(mMemberFile);

        // and the attendance
        mAttendanceRequests = (AttendanceHolder) readInformationFromFile(mAttendanceFile);
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
    private static boolean saveInformationToFile(File file, Serializable info)
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

            // Download this member events
            DownloaderService.syncEvents(mContext);

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

    public void setPresence(long activityID, long personID, boolean present)
    {
        // Mark the member as present
        // Update the values
        final String selection = ActivityMember.Columns.MEMBER_ID_FULL+"="+personID+
                " AND "+ActivityMember.Columns.ACTIVITY_ID_FULL+"="+activityID;
        final ContentValues values = new ContentValues();
        values.put(ActivityMember.Columns.PRESENT, present ? 1 : 0);
        mContext.getContentResolver().update(ActivityMember.CONTENT_URI, values, selection, null);

        // Add the data to the request list
        if (mAttendanceRequests == null) mAttendanceRequests = new AttendanceHolder();
        mAttendanceRequests.newRequest(personID, activityID, present);

        // and send it
        mAttendanceRequests.sendRequests(mContext, mAttendanceFile);
    }


    static class AttendanceHolder implements Serializable
    {
        private static final long serialVersionUID = -6795878015775849060L;

        private final ArrayList<PresenceRequest> requests = new ArrayList<PresenceRequest>();


        static class PresenceRequest implements Serializable
        {
            private static final long serialVersionUID = -1880881591078217865L;

            final long memberID;
            final long activityID;
            boolean    present;

            public PresenceRequest(long memberID, long activityID, boolean present)
            {
                this.memberID = memberID;
                this.activityID = activityID;
                this.present = present;
            }
        }
        

        public void sendRequests(final Context c, final File file)
        {
            for (final PresenceRequest request : requests)
            {
                // Send the request
                try
                {
                    // Get some info
                    String tokenID = LoginManager.getInstance(c).getTokenId();
                    long activityID = request.activityID;
                    long personID = request.memberID;

                    // Prepare the connection
                    HttpURLConnection connection = 
                            request.present ? 
                                    Activity.Api.confirmEntrance(tokenID, activityID, personID) :
                                    Activity.Api.revokeEntrance(tokenID, activityID, personID);
                    ApiRequest.getJsonFromConnection(0, connection, new ApiRequest.ResponseHandler() {
                        @Override
                        public void handleResponse(int requestId, JSONObject json, int responseCode)
                        {
                            if (responseCode == HttpStatus.SC_OK && json != null)
                            {
                                // Remove it from the list!
                                requests.remove(request);
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
            if (!requests.isEmpty())
            {
                // There were errors, try again later
                new Handler().postDelayed(new Runnable() {
                    @Override
                    public void run()
                    {
                        sendRequests(c, file);
                    }
                }, INTERVAL_RETRY_SENDING_ATTENDANCE_LIST);
            }

            // Save the new state to the file
            saveInformationToFile(file, this);
        }


        protected void newRequest(long personID, long activityID, boolean present)
        {
            // Check if the request already exists
            for (PresenceRequest request : requests)
            {
                if (request.memberID == personID &&
                        request.activityID == activityID)
                {
                    // There is a request for that already, so let's just override it
                    if (request.present != present)
                    {
                        // remove the current request
                        requests.remove(request);
                        return;
                    }
                    else
                    {
                        // do nothing, there's a request for that already
                        return;
                    }
                }
            }

            // If it got here, it means this is a new request
            requests.add(new PresenceRequest(personID, activityID, present));
        }
    }
}
