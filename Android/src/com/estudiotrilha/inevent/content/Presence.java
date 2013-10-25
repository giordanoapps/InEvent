package com.estudiotrilha.inevent.content;

import static com.estudiotrilha.inevent.content.Presence.Columns.ACTIVITY_ID;
import static com.estudiotrilha.inevent.content.Presence.Columns.PERSON_ID;
import static com.estudiotrilha.inevent.content.Presence.Columns.PRESENT;
import android.content.ContentValues;
import android.net.Uri;
import android.provider.BaseColumns;

import com.estudiotrilha.inevent.provider.InEventProvider;


public class Presence
{
    // Database
    public static final String TABLE_NAME = "presence";
    public static interface Columns extends BaseColumns
    {
        public static final String ACTIVITY_ID = "activityID";
        public static final String PERSON_ID   = "personID";
        public static final String PRESENT     = "present";
        // Full names
        public static final String _ID_FULL         = TABLE_NAME+"."+_ID;
        public static final String ACTIVITY_ID_FULL = TABLE_NAME+"."+ACTIVITY_ID;
        public static final String PERSON_ID_FULL   = TABLE_NAME+"."+PERSON_ID;
        public static final String PRESENT_FULL     = TABLE_NAME+"."+PRESENT;


        public static final String[] PROJECTION_SYNC = {
            Presence.Columns._ID_FULL,
            Presence.Columns.ACTIVITY_ID_FULL,
            Presence.Columns.PERSON_ID_FULL,
            Presence.Columns.PRESENT_FULL
        };
    }

    // Content Provider
    public static final String PATH     = "presence";
    public static final Uri CONTENT_URI = Uri.withAppendedPath(InEventProvider.CONTENT_URI, PATH);


    public static ContentValues newActivityPresence(long activityID, long personID, boolean present)
    {
        ContentValues cv = new ContentValues();
        cv.put(ACTIVITY_ID, activityID);
        cv.put(PERSON_ID, personID);
        cv.put(PRESENT, present);

        return cv;
    }
}
