package com.estudiotrilha.inevent.provider;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import android.content.ContentProvider;
import android.content.ContentProviderOperation;
import android.content.ContentProviderResult;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.content.OperationApplicationException;
import android.content.UriMatcher;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.net.Uri;
import android.util.Log;

import com.estudiotrilha.android.utils.SQLiteUtils;
import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.content.Activity;
import com.estudiotrilha.inevent.content.ActivityMember;
import com.estudiotrilha.inevent.content.Event;
import com.estudiotrilha.inevent.content.EventMember;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.content.Member;
import com.estudiotrilha.inevent.content.Feedback;
import com.estudiotrilha.inevent.content.Presence;


public class InEventProvider extends ContentProvider
{
    private static final int DATABASE_VERSION = 5;

    public final static UriMatcher uriMatcher;

    public static final String AUTHORITY   = InEventProvider.class.getPackage().getName();
    public static final Uri    CONTENT_URI = Uri.parse("content://" + AUTHORITY);

    // URI CODES //
    public static final int URI_EVENT              = 101;
    public static final int URI_EVENT_SINGLE       = 102;
    public static final int URI_EVENT_ATTENDERS    = 103;
    public static final int URI_ACTIVITY           = 201;
    public static final int URI_ACTIVITY_SINGLE    = 202;
    public static final int URI_ACTIVITY_ATTENDERS = 204;
    public static final int URI_MEMBER             = 301;
    public static final int URI_RATING             = 401;
    public static final int URI_RATING_SINGLE      = 402;
    public static final int URI_PRESENCE           = 501;
    public static final int URI_PRESENCE_SINGLE    = 502;

    static
    {
        uriMatcher = new UriMatcher(UriMatcher.NO_MATCH);

        // The possible URIs
        uriMatcher.addURI(AUTHORITY, Event.PATH,                    URI_EVENT);
        uriMatcher.addURI(AUTHORITY, Event.PATH + "/#",             URI_EVENT_SINGLE);
        uriMatcher.addURI(AUTHORITY, EventMember.PATH,              URI_EVENT_ATTENDERS);
        uriMatcher.addURI(AUTHORITY, Activity.PATH,                 URI_ACTIVITY);
        uriMatcher.addURI(AUTHORITY, Activity.PATH + "/#",          URI_ACTIVITY_SINGLE);
        uriMatcher.addURI(AUTHORITY, ActivityMember.PATH,           URI_ACTIVITY_ATTENDERS);
        uriMatcher.addURI(AUTHORITY, Member.PATH,                   URI_MEMBER);
        uriMatcher.addURI(AUTHORITY, Feedback.PATH,                 URI_RATING);
        uriMatcher.addURI(AUTHORITY, Feedback.PATH + "/#",          URI_RATING_SINGLE);
        uriMatcher.addURI(AUTHORITY, Presence.PATH,                 URI_PRESENCE);
        uriMatcher.addURI(AUTHORITY, Presence.PATH + "/#",          URI_PRESENCE_SINGLE);
    }

    private DatabaseOpenHelper mDatabaseOpenHelper;
    private SQLiteDatabase     mDatabase;
    private boolean            mOnBatchMode = false;
    private Set<Uri>           mBatchUri;


    @Override
    public boolean onCreate()
    {
        mDatabaseOpenHelper = new DatabaseOpenHelper(getContext());
        mDatabase = mDatabaseOpenHelper.getWritableDatabase();
        mBatchUri = new HashSet<Uri>();

        return true;
    }

    @Override
    public String getType(Uri uri)
    {
        final String IN_EVENT = "/vnd.estudiotrilha.inevent.";

        int matchCode = uriMatcher.match(uri);
        switch (matchCode)
        {
        case URI_EVENT:
            return ContentResolver.CURSOR_DIR_BASE_TYPE + IN_EVENT + Event.PATH;

        case URI_EVENT_SINGLE:
            return ContentResolver.CURSOR_ITEM_BASE_TYPE + IN_EVENT + Event.PATH;

        case URI_EVENT_ATTENDERS:
            return ContentResolver.CURSOR_DIR_BASE_TYPE + IN_EVENT + EventMember.PATH;

        case URI_ACTIVITY:
            return ContentResolver.CURSOR_DIR_BASE_TYPE + IN_EVENT + Activity.PATH;

        case URI_ACTIVITY_ATTENDERS:
            return ContentResolver.CURSOR_DIR_BASE_TYPE + IN_EVENT + ActivityMember.PATH;

        case URI_ACTIVITY_SINGLE:
            return ContentResolver.CURSOR_ITEM_BASE_TYPE + IN_EVENT + Activity.PATH;

        case URI_MEMBER:
            return ContentResolver.CURSOR_DIR_BASE_TYPE + IN_EVENT + Member.PATH;

        case URI_RATING:
            return ContentResolver.CURSOR_DIR_BASE_TYPE + IN_EVENT + Feedback.PATH;

        case URI_RATING_SINGLE:
            return ContentResolver.CURSOR_ITEM_BASE_TYPE+ IN_EVENT + Feedback.PATH;

        case URI_PRESENCE:
            return ContentResolver.CURSOR_DIR_BASE_TYPE + IN_EVENT + Presence.PATH;

        case URI_PRESENCE_SINGLE:
            return ContentResolver.CURSOR_ITEM_BASE_TYPE+ IN_EVENT + Presence.PATH;
        }

        return null;
    }

    @Override
    public Cursor query(Uri uri, String[] projection, String selection, String[] selectionArgs, String sortOrder)
    {
        Cursor c = null;

        int matchCode = uriMatcher.match(uri);
        switch (matchCode)
        {
        case URI_EVENT_SINGLE:
        {
            // obtain the id
            String id = Long.toString(ContentUris.parseId(uri));
            selection = Event.Columns._ID_FULL+"=?";
            selectionArgs = new String[] { id };
        }
        case URI_EVENT:
        {
            String project = "*";
            if (projection != null)
            {
                // remove the brackets
                project = Arrays.toString(projection);
                project = project.substring(1,project.length()-1);
            }
            if (selection == null) selection = "1";

            LoginManager loginManager = LoginManager.getInstance(getContext());
            final String query = "SELECT "+ project +
                    " FROM " + Event.TABLE_NAME +
                    " LEFT JOIN " + EventMember.TABLE_NAME +
                    (loginManager.isSignedIn() ?
                                " ON " + Event.Columns._ID_FULL +"="+ EventMember.Columns.EVENT_ID_FULL+
                                " AND "+EventMember.Columns.MEMBER_ID_FULL+"="+loginManager.getMember().memberId : "") +
                    " LEFT JOIN " + Feedback.TABLE_NAME +
                    " ON " + EventMember.Columns.EVENT_ID_FULL +"="+ Feedback.Columns.EVENT_ID_FULL +
                    " WHERE " + selection +
                    " GROUP BY " + Event.Columns._ID_FULL +
                    " ORDER BY " + sortOrder;

            c = mDatabase.rawQuery(query, selectionArgs);
            break;
        }

        case URI_EVENT_ATTENDERS:
            c = mDatabase.query(EventMember.TABLE_NAME, projection, selection, selectionArgs, null, null, sortOrder);
            break;

        case URI_ACTIVITY_SINGLE:
        {
            // obtain the id
            String id = Long.toString(ContentUris.parseId(uri));
            selection = Activity.Columns._ID_FULL+"=?";
            selectionArgs = new String[] { id };
        }
        case URI_ACTIVITY:
        {
            String project = "*";
            if (projection != null)
            {
                // remove the brackets
                project = Arrays.toString(projection);
                project = project.substring(1,project.length()-1);
            }
            if (selection == null) selection = "1";

            LoginManager loginManager = LoginManager.getInstance(getContext());
            final String query = "SELECT "+ project +
                    " FROM " + Activity.TABLE_NAME +
                    " LEFT JOIN " + ActivityMember.TABLE_NAME +
                    " ON " + ActivityMember.Columns.ACTIVITY_ID_FULL +"="+ Activity.Columns._ID_FULL +
                        (loginManager.isSignedIn() ? " AND "+ActivityMember.Columns.MEMBER_ID_FULL+"="+loginManager.getMember().memberId: "") +
                    " LEFT JOIN " + Feedback.TABLE_NAME +
                    " ON " + ActivityMember.Columns.ACTIVITY_ID_FULL +"="+ Feedback.Columns.ACTIVITY_ID_FULL +
                    " WHERE " + selection +
                    " GROUP BY " + Activity.Columns._ID_FULL +
                    " ORDER BY " + sortOrder;

            c = mDatabase.rawQuery(query, selectionArgs);
            break;
        }

        case URI_ACTIVITY_ATTENDERS:
        {
            String project = "*";
            if (projection != null)
            {
                // remove the brackets
                project = Arrays.toString(projection);
                project = project.substring(1,project.length()-1);
            }
            if (selection == null) selection = "1";

            final String query = "SELECT "+ project +
                    " FROM " + ActivityMember.TABLE_NAME +
                    " INNER JOIN " + Member.TABLE_NAME +
                    " ON " + ActivityMember.Columns.MEMBER_ID_FULL +"="+ Member.Columns._ID_FULL +
                    " WHERE " + selection +
                    " GROUP BY " + Member.Columns._ID_FULL +
                    " ORDER BY " + sortOrder;

            c = mDatabase.rawQuery(query, selectionArgs);
            break;
        }

        case URI_RATING_SINGLE:
        {
            // obtain the id
            Long id = ContentUris.parseId(uri);

            // set the selection
            selection = Feedback.Columns._ID+"=?";
            selectionArgs = new String[] {id.toString()};
        }
        case URI_RATING:
            c = mDatabase.query(Feedback.TABLE_NAME, projection, selection, selectionArgs, null, null, sortOrder);
            break;

        case URI_PRESENCE_SINGLE:
        {
            // obtain the id
            Long id = ContentUris.parseId(uri);
    
            // set the selection
            selection = Presence.Columns._ID+"=?";
            selectionArgs = new String[] {id.toString()};
        }
        case URI_PRESENCE:
            c = mDatabase.query(Presence.TABLE_NAME, projection, selection, selectionArgs, null, null, sortOrder);
        break;

        default:
            throw new IllegalArgumentException("Unsupported uri: "+uri);
        }

        // set this cursor to receive notifications
        if (c != null) c.setNotificationUri(getContext().getContentResolver(), uri);

        return c;
    }

    @Override
    public Uri insert(Uri uri, ContentValues values)
    {
        // check if the values are any good
        if (values == null) return null;

        long answer = -1;

        int matchCode = uriMatcher.match(uri);
        switch (matchCode)
        {
        case URI_EVENT:
            answer = mDatabase.insertWithOnConflict(Event.TABLE_NAME, null, values, SQLiteDatabase.CONFLICT_REPLACE);
            break;

        case URI_EVENT_ATTENDERS:
            answer = mDatabase.insertWithOnConflict(EventMember.TABLE_NAME, null, values, SQLiteDatabase.CONFLICT_REPLACE);
            break;

        case URI_ACTIVITY:
            answer = mDatabase.insertWithOnConflict(Activity.TABLE_NAME, null, values, SQLiteDatabase.CONFLICT_REPLACE);
            break;

        case URI_ACTIVITY_ATTENDERS:
            answer = mDatabase.insertWithOnConflict(ActivityMember.TABLE_NAME, null, values, SQLiteDatabase.CONFLICT_REPLACE);
            break;

        case URI_MEMBER:
            answer = mDatabase.insertWithOnConflict(Member.TABLE_NAME, null, values, SQLiteDatabase.CONFLICT_REPLACE);
            break;

        case URI_RATING:
            answer = mDatabase.insertWithOnConflict(Feedback.TABLE_NAME, null, values, SQLiteDatabase.CONFLICT_REPLACE);
            break;

        case URI_PRESENCE:
            answer = mDatabase.insertWithOnConflict(Presence.TABLE_NAME, null, values, SQLiteDatabase.CONFLICT_REPLACE);
            break;
            
        default:
            throw new IllegalArgumentException("Unsupported uri: " + uri);
        }

        // check if the insertion was successful
        if (answer == -1)
        {
            Log.e(InEvent.NAME, "Could not insert " + values + " into " + uri);
            return null;
        }
        else
        {
            // update the uri
            uri = ContentUris.withAppendedId(uri, answer);
        }

        if (mOnBatchMode)
        {
            mBatchUri.add(uri);
        }
        else
        {
            // notify the change
            getContext().getContentResolver().notifyChange(uri, null);
        }

        return uri;
    }
    @Override
    public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs)
    {
        int result = -1;

        // check if the values are any good
        if (values == null) return result;

        int matchCode = uriMatcher.match(uri);
        switch (matchCode)
        {
        case URI_EVENT_SINGLE:
        {
            // obtain the id
            Long id = ContentUris.parseId(uri);

            // set the selection
            selection = Event.Columns._ID+"=?";
            selectionArgs = new String[] {id.toString()};
        }
        case URI_EVENT:
            result = mDatabase.update(Event.TABLE_NAME, values, selection, selectionArgs);
            break;

        case URI_ACTIVITY_ATTENDERS:
            result = mDatabase.update(ActivityMember.TABLE_NAME, values, selection, selectionArgs);
            break;

        case URI_RATING_SINGLE:
        {
            // obtain the id
            Long id = ContentUris.parseId(uri);

            // set the selection
            selection = Feedback.Columns._ID+"=?";
            selectionArgs = new String[] {id.toString()};
        }
        case URI_RATING:
            result = mDatabase.update(Feedback.TABLE_NAME, values, selection, selectionArgs);
            break;

        default:
            throw new IllegalArgumentException("Unsupported uri: " + uri);
        }

        if (mOnBatchMode)
        {
            mBatchUri.add(uri);
        }
        else
        {
            // notify the change
            getContext().getContentResolver().notifyChange(uri, null);
        }

        return result;
    }
    @Override
    public int delete(Uri uri, String selection, String[] selectionArgs)
    {
        int result = 0;

        int matchCode = uriMatcher.match(uri);
        switch (matchCode)
        {
        case URI_EVENT_SINGLE:
        {
            // obtain the id
            Long id = ContentUris.parseId(uri);

            // set the selection
            selection = Event.Columns._ID+"=?";
            selectionArgs = new String[] {id.toString()};
        }
        case URI_EVENT:
            result = mDatabase.delete(Event.TABLE_NAME, selection, selectionArgs);
            break;

        case URI_EVENT_ATTENDERS:
            result = mDatabase.delete(EventMember.TABLE_NAME, selection, selectionArgs);
            break;

        case URI_ACTIVITY_SINGLE:
        {
            // obtain the id
            Long id = ContentUris.parseId(uri);

            // set the selection
            selection = Activity.Columns._ID+"=?";
            selectionArgs = new String[] {id.toString()};
        }
        case URI_ACTIVITY:
            result = mDatabase.delete(Activity.TABLE_NAME, selection, selectionArgs);
            break;

        case URI_ACTIVITY_ATTENDERS:
            result = mDatabase.delete(ActivityMember.TABLE_NAME, selection, selectionArgs);
            break;

        case URI_MEMBER:
            result = mDatabase.delete(Member.TABLE_NAME, selection, selectionArgs);
            break;

        case URI_PRESENCE_SINGLE:
        {
            // obtain the id
            Long id = ContentUris.parseId(uri);
    
            // set the selection
            selection = Presence.Columns._ID+"=?";
            selectionArgs = new String[] {id.toString()};
        }
        case URI_PRESENCE:
            result = mDatabase.delete(Presence.TABLE_NAME, selection, selectionArgs);
        break;

        default:
            throw new IllegalArgumentException("Unsupported uri: " + uri);
        }

        if (mOnBatchMode)
        {
            mBatchUri.add(uri);
        }
        else
        {
            // notify the change
            getContext().getContentResolver().notifyChange(uri, null);
        }
        return result;
    }

    @Override
    public ContentProviderResult[] applyBatch(ArrayList<ContentProviderOperation> operations)
            throws OperationApplicationException
    {
        // setup the batch mode
        mOnBatchMode = true;
        mBatchUri.clear();
        mDatabase.beginTransaction();
        ContentProviderResult[] results = null;
        try
        {
            results = super.applyBatch(operations);
            mDatabase.setTransactionSuccessful();
        }
        finally
        {
            mDatabase.endTransaction();
        }

        // notify the set of cheanges 
        mOnBatchMode = false;
        ContentResolver resolver = getContext().getContentResolver();
        for (Uri uri : mBatchUri)
        {
            resolver.notifyChange(uri, null);
        }

        return results;
    }

    public static class DatabaseOpenHelper extends SQLiteOpenHelper
    {
        public DatabaseOpenHelper(Context context)
        {
            super(context, InEvent.NAME+".db", null, DATABASE_VERSION);
        }

        @Override
        public void onCreate(SQLiteDatabase db)
        {
            db.beginTransaction();

            try
            {
                createEventTable(db);
                createActivityTable(db);
                createMemberTable(db);
                createRatingTable(db);
                createPresenceTable(db);

                db.setTransactionSuccessful();
                Log.i(InEvent.NAME, "Database created successfully!");
            }
            finally
            {
                db.endTransaction();
            }
        }

        @Override
        public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion)
        {
            Log.i(InEvent.NAME, "Updating database from version " + oldVersion + " to version " + newVersion);

            switch (oldVersion)
            {
            case 1:
                // Updates for the version 2
                db.execSQL("ALTER TABLE "+Member.TABLE_NAME+
                        " ADD "+Member.Columns.IMAGE+" TEXT");

                db.execSQL("DROP TABLE IF EXISTS "+EventMember.TABLE_NAME);
                db.execSQL("CREATE TABLE " + EventMember.TABLE_NAME + "(" +
                        EventMember.Columns.EVENT_ID + SQLiteUtils.FOREIGN_KEY + ", " +
                        EventMember.Columns.MEMBER_ID + SQLiteUtils.FOREIGN_KEY + ", " +
                        EventMember.Columns.APPROVED + SQLiteUtils.BOOLEAN + ", " +
                        EventMember.Columns.ROLE_ID + " INTEGER)"
                );

                Log.i(InEvent.NAME, "Updated database to version 2");

            case 2:
                // do the updates for the version 3
                db.execSQL("ALTER TABLE "+Event.TABLE_NAME+
                        " ADD "+Event.Columns.COVER + " TEXT");

                db.execSQL("ALTER TABLE "+Activity.TABLE_NAME+
                        " ADD "+Activity.Columns.LATITUDE + " REAL");
                db.execSQL("ALTER TABLE "+Activity.TABLE_NAME+
                        " ADD "+Activity.Columns.LONGITUDE + " REAL");

                Log.i(InEvent.NAME, "Updated database to version 3");

            case 3:
                // do the updates for the version 4
                createRatingTable(db);
                Log.i(InEvent.NAME, "Updated database to version 4");

            case 4:
                // do the updates for the version 5
                createPresenceTable(db);
                Log.i(InEvent.NAME, "Updated database to version 5");
            }
        }

        private void createEventTable(SQLiteDatabase db)
        {
            Log.i(InEvent.NAME, "Creating " + Event.TABLE_NAME + " table");

            db.execSQL("CREATE TABLE " + Event.TABLE_NAME + "(" +
                    Event.Columns._ID + " INTEGER NOT NULL UNIQUE, " +
                    Event.Columns.NAME + " TEXT NOT NULL, " +
                    Event.Columns.COVER + " TEXT, " +
                    Event.Columns.DESCRIPTION + " TEXT, " +
                    Event.Columns.DATE_BEGIN + " INTEGER, " +
                    Event.Columns.DATE_END + " INTEGER, " +
                    Event.Columns.LATITUDE + " REAL, " +
                    Event.Columns.LONGITUDE + " REAL, " +
                    Event.Columns.ADDRESS + " TEXT, " +
                    Event.Columns.CITY + " TEXT, " +
                    Event.Columns.STATE + " TEXT)"
            );

            Log.i(InEvent.NAME, "Creating " + EventMember.TABLE_NAME + " table");

            db.execSQL("CREATE TABLE " + EventMember.TABLE_NAME + "(" +
                    EventMember.Columns.EVENT_ID + SQLiteUtils.FOREIGN_KEY + ", " +
                    EventMember.Columns.MEMBER_ID + SQLiteUtils.FOREIGN_KEY + ", " +
                    EventMember.Columns.APPROVED + SQLiteUtils.BOOLEAN + ", " +
                    EventMember.Columns.ROLE_ID + " INTEGER)"
            );
        }

        private void createActivityTable(SQLiteDatabase db)
        {
            Log.i(InEvent.NAME, "Creating " + Activity.TABLE_NAME + " table");

            db.execSQL("CREATE TABLE " + Activity.TABLE_NAME + "(" +
                    Activity.Columns._ID + " INTEGER NOT NULL UNIQUE, " +
                    Activity.Columns.EVENT_ID + " INTEGER NOT NULL, " +
                    Activity.Columns.NAME + " TEXT NOT NULL, " +
                    Activity.Columns.DESCRIPTION + " TEXT, " +
                    Activity.Columns.LOCATION + " TEXT, " +
                    Activity.Columns.LATITUDE + " REAL, " +
                    Activity.Columns.LONGITUDE + " REAL, " +
                    Activity.Columns.DATE_BEGIN + " INTEGER, " +
                    Activity.Columns.DATE_END + " INTEGER)"
            );

            Log.i(InEvent.NAME, "Creating " + ActivityMember.TABLE_NAME + " table");

            db.execSQL("CREATE TABLE " + ActivityMember.TABLE_NAME + "(" +
                    ActivityMember.Columns.EVENT_ID + SQLiteUtils.FOREIGN_KEY + ", " +
                    ActivityMember.Columns.ACTIVITY_ID + SQLiteUtils.FOREIGN_KEY + ", " +
                    ActivityMember.Columns.MEMBER_ID + SQLiteUtils.FOREIGN_KEY + ", " +
                    ActivityMember.Columns.APPROVED + SQLiteUtils.BOOLEAN + ", " +
                    ActivityMember.Columns.PRESENT + SQLiteUtils.BOOLEAN + ")"
            );
        }

        private void createMemberTable(SQLiteDatabase db)
        {
            Log.i(InEvent.NAME, "Creating " + Member.TABLE_NAME + " table");

            db.execSQL("CREATE TABLE " + Member.TABLE_NAME + "(" +
                    Member.Columns._ID + " INTEGER NOT NULL UNIQUE, " +
                    Member.Columns.NAME + " TEXT NOT NULL, " +
                    Member.Columns.EMAIL + " TEXT, " +
                    Member.Columns.TELEPHONE + " TEXT" +
                    Member.Columns.IMAGE + " TEXT)"
            );
        }

        private void createRatingTable(SQLiteDatabase db)
        {
            Log.i(InEvent.NAME, "Creating " + Feedback.TABLE_NAME + " table");

            db.execSQL("CREATE TABLE " + Feedback.TABLE_NAME + "(" +
                    Feedback.Columns._ID + SQLiteUtils.PRIMARY_KEY+", "+
                    Feedback.Columns.ACTIVITY_ID + " INTEGER UNIQUE DEFAULT NULL, " +
                    Feedback.Columns.EVENT_ID + " INTEGER UNIQUE DEFAULT NULL, " +
                    Feedback.Columns.RATING + " INTEGER NOT NULL, " +
                    Feedback.Columns.MESSAGE + " TEXT, " +
                    Feedback.Columns.SYNCHRONIZED + SQLiteUtils.BOOLEAN +")"
            );
            db.execSQL("CREATE UNIQUE INDEX " + Feedback.TABLE_NAME+"_index" +
            		" ON "+Feedback.TABLE_NAME+
            		    " ("+Feedback.Columns.EVENT_ID+
            		    ", "+Feedback.Columns.ACTIVITY_ID+")"
    		);
        }

        private void createPresenceTable(SQLiteDatabase db)
        {
            Log.i(InEvent.NAME, "Creating " + Presence.TABLE_NAME + " table");

            db.execSQL("CREATE TABLE " + Presence.TABLE_NAME + "(" +
                    Presence.Columns._ID + SQLiteUtils.PRIMARY_KEY+", "+
                    Presence.Columns.ACTIVITY_ID + " INTEGER NOT NULL, " +
                    Presence.Columns.PERSON_ID + " INTEGER NOT NULL, " +
                    Presence.Columns.PRESENT + SQLiteUtils.BOOLEAN +")"
            );
            db.execSQL("CREATE UNIQUE INDEX " + Presence.TABLE_NAME+"_index" +
                    " ON "+Presence.TABLE_NAME+
                        " ("+Presence.Columns.PERSON_ID+
                        ", "+Presence.Columns.ACTIVITY_ID+")"
            );
        }
    }
}