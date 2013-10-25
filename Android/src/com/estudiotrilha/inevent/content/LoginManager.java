package com.estudiotrilha.inevent.content;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

import android.content.Context;
import android.content.Intent;
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


    private Context mContext;

    private Member  mMember;
    private File    mMemberFile;


    private LoginManager(Context c)
    {
        this.mContext = c;

        mMemberFile = new File(mContext.getDir(DIRECTORY, Context.MODE_PRIVATE), FILENAME_MEMBER);

        // Try to recover the member login information
        mMember = (Member) readInformationFromFile(mMemberFile);
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
            DownloaderService.downloadEvents(mContext);

            return true;
        }

        return false;
    }
    public void signOut()
    {
        // Erase the references
        mContext.getContentResolver().delete(ActivityMember.CONTENT_URI, ActivityMember.Columns.MEMBER_ID_FULL+"="+mMember.memberId, null);

        mMemberFile.delete();
        mMember = null;

        // broadcasts that the user has logged in
        mContext.sendBroadcast(new Intent(ACTION_LOGIN_STATE_CHANGED));

        // Download this member events
        DownloaderService.downloadEvents(mContext);
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
}
