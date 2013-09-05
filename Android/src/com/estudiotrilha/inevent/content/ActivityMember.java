package com.estudiotrilha.inevent.content;

import android.content.ContentValues;
import android.provider.BaseColumns;


public class ActivityMember
{
    public static interface Columns extends BaseColumns
    {
        public static final String EVENT_ID    = "eventID";
        public static final String ACTIVITY_ID = "activityID";
        public static final String MEMBER_ID   = "memberID";
        public static final String APPROVED    = "approved";
        public static final String PRESENT     = "present";

        public static final String _ID_FULL         = TABLE_NAME+"."+_ID;
        public static final String EVENT_ID_FULL    = TABLE_NAME+"."+EVENT_ID;
        public static final String ACTIVITY_ID_FULL = TABLE_NAME+"."+ACTIVITY_ID;
        public static final String MEMBER_ID_FULL   = TABLE_NAME+"."+MEMBER_ID;
        public static final String APPROVED_FULL    = TABLE_NAME+"."+APPROVED;
        public static final String PRESENT_FULL     = TABLE_NAME+"."+PRESENT;


        public static final String[] PROJECTION_SCHEDULE_LIST = {
            Activity.Columns._ID_FULL,
            Activity.Columns.DATE_BEGIN_FULL,
            Activity.Columns.DATE_END_FULL,
            Activity.Columns.NAME_FULL,
            Activity.Columns.DESCRIPTION_FULL,
            Activity.Columns.LOCATION_FULL,
            ActivityMember.Columns.APPROVED_FULL
        };

        public static final String[] PROJECTION_ATTENDANCE_LIST = {
            com.estudiotrilha.inevent.content.Member.TABLE_NAME+"."+com.estudiotrilha.inevent.content.Member.Columns._ID,
            com.estudiotrilha.inevent.content.Member.TABLE_NAME+"."+com.estudiotrilha.inevent.content.Member.Columns.NAME,
            TABLE_NAME+"."+PRESENT
        };
    }

    // Database
    public static final String TABLE_NAME = "activityMember";

    public static ContentValues newActivtyMember(long eventID, long activityID, long memberID, boolean approved, boolean present)
    {
        ContentValues cv = new ContentValues();

        cv.put(Columns.EVENT_ID, eventID);
        cv.put(Columns.ACTIVITY_ID, activityID);
        cv.put(Columns.MEMBER_ID, memberID);
        cv.put(Columns.APPROVED, approved ? 1 : 0);
        cv.put(Columns.PRESENT, present ? 1 : 0);

        return cv;
    }
    public static ContentValues newActivtyMember(long eventID, long activityID, long memberID, boolean approved)
    {
        return newActivtyMember(eventID, activityID, memberID, approved, false);
    }
}
