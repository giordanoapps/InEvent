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


public class LoginManager
{
    // CONSTANTS
    private static final String DIRECTORY               = "loginManagerData";
    private static final String FILENAME_MEMBER         = "memberInfoFile.bin";

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


    private Context mContext;

    private Person  mPerson;
    private File    mPersonFile;


    private LoginManager(Context c)
    {
        this.mContext = c;

        mPersonFile = new File(mContext.getDir(DIRECTORY, Context.MODE_PRIVATE), FILENAME_MEMBER);

        // Try to recover the member login information
        mPerson = (Person) readInformationFromFile(mPersonFile);
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
    public boolean signIn(Person p)
    {
        if (saveInformationToFile(mPersonFile, p))
        {
            // register the attributes
            mPerson = p;

            // broadcasts that the user has logged in
            mContext.sendBroadcast(new Intent(ACTION_LOGIN_STATE_CHANGED));

            return true;
        }

        return false;
    }
    public void signOut()
    {
        mPersonFile.delete();
        mPerson = null;

        // broadcasts that the user has logged in
        mContext.sendBroadcast(new Intent(ACTION_LOGIN_STATE_CHANGED));
    }


    // Getters
    public boolean isSignedIn()
    {
        return mPerson != null;
    }


    public Person getPerson()
    {
        return mPerson;
    }
    public String getTokenId()
    {
        if (isSignedIn()) return mPerson.tokenId;
        else return null;
    }
}
