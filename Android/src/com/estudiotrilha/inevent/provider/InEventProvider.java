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
import com.estudiotrilha.inevent.content.Event;
import com.estudiotrilha.inevent.content.Member;


public class InEventProvider extends ContentProvider
{
    private static final int DATABASE_VERSION = 1;

    public final static UriMatcher uriMatcher;

    public static final String AUTHORITY   = InEventProvider.class.getPackage().getName();
    public static final Uri    CONTENT_URI = Uri.parse("content://" + AUTHORITY);

    // URI CODES //
    public static final int URI_EVENT                = 101;
    public static final int URI_EVENT_SINGLE         = 102;
    public static final int URI_EVENT_ATTENDERS      = 103;
    public static final int URI_ACTIVITY             = 201;
    public static final int URI_ACTIVITY_SINGLE      = 202;
    public static final int URI_ACTIVITY_SCHEDULE    = 203;
    public static final int URI_ACTIVITY_ATTENDERS   = 204;
    public static final int URI_MEMBER               = 301;

    static
    {
        uriMatcher = new UriMatcher(UriMatcher.NO_MATCH);

        // The possible URIs
        uriMatcher.addURI(AUTHORITY, Event.EVENT_PATH,              URI_EVENT);
        uriMatcher.addURI(AUTHORITY, Event.EVENT_PATH + "/#",       URI_EVENT_SINGLE);
        uriMatcher.addURI(AUTHORITY, Event.ATTENDERS_PATH,          URI_EVENT_ATTENDERS);
        uriMatcher.addURI(AUTHORITY, Activity.ACTIVITY_PATH,        URI_ACTIVITY);
        uriMatcher.addURI(AUTHORITY, Activity.ACTIVITY_PATH + "/#", URI_ACTIVITY_SINGLE);
        uriMatcher.addURI(AUTHORITY, Activity.SCHEDULE_PATH,        URI_ACTIVITY_SCHEDULE);
        uriMatcher.addURI(AUTHORITY, Activity.ATTENDERS_PATH,       URI_ACTIVITY_ATTENDERS);
        uriMatcher.addURI(AUTHORITY, Member.PATH,                   URI_MEMBER);
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
            return ContentResolver.CURSOR_DIR_BASE_TYPE + IN_EVENT + Event.EVENT_PATH;

        case URI_EVENT_SINGLE:
            return ContentResolver.CURSOR_ITEM_BASE_TYPE + IN_EVENT + Event.EVENT_PATH;

        case URI_EVENT_ATTENDERS:
            return ContentResolver.CURSOR_DIR_BASE_TYPE + IN_EVENT + Event.ATTENDERS_PATH;

        case URI_ACTIVITY:
            return ContentResolver.CURSOR_DIR_BASE_TYPE + IN_EVENT + Activity.ACTIVITY_PATH;

        case URI_ACTIVITY_SCHEDULE:
            return ContentResolver.CURSOR_DIR_BASE_TYPE + IN_EVENT + Activity.SCHEDULE_PATH;

        case URI_ACTIVITY_ATTENDERS:
            return ContentResolver.CURSOR_DIR_BASE_TYPE + IN_EVENT + Activity.ATTENDERS_PATH;

        case URI_ACTIVITY_SINGLE:
            return ContentResolver.CURSOR_ITEM_BASE_TYPE + IN_EVENT + Activity.ACTIVITY_PATH;

        case URI_MEMBER:
            return ContentResolver.CURSOR_DIR_BASE_TYPE + IN_EVENT + Member.PATH;
        }

        return null;
    }

    @Override
    public Cursor query(Uri uri, String[] projection, String selection, String[] selectionArgs, String sortOrder) // TODO
    {
        Cursor c = null;

        int matchCode = uriMatcher.match(uri);
        switch (matchCode)
        {
        case URI_EVENT_SINGLE:
        {
            // obtain the id
            String id = Long.toString(ContentUris.parseId(uri));
            selection = Event.Columns._ID+"=?";
            selectionArgs = new String[] { id };
        }
        case URI_EVENT:
            c = mDatabase.query(Event.TABLE_NAME, projection, selection, selectionArgs, null, null, sortOrder);
            break;

        case URI_ACTIVITY:
            c = mDatabase.query(Activity.TABLE_NAME, projection, selection, selectionArgs, null, null, sortOrder);
            break;

        case URI_ACTIVITY_SCHEDULE:
        {
            String project = "*";
            if (projection != null)
            {
                // remove the brackets
                project = Arrays.toString(projection);
                project = project.substring(1,project.length()-1);
            }

            final String query = "SELECT "+ project +
                    " FROM " + Event.TABLE_NAME +
                    " INNER JOIN " + Activity.TABLE_NAME +
                    " ON " + Event.TABLE_NAME+"."+Event.Columns._ID +"="+ Activity.TABLE_NAME+"."+Activity.Columns.EVENT_ID +
                    " INNER JOIN " + Activity.Member.TABLE_NAME +
                    " ON " + Activity.Member.TABLE_NAME+"."+Activity.Member.Columns.ACTIVITY_ID +"="+ Activity.TABLE_NAME+"."+Activity.Columns._ID +
                    " WHERE " + selection +
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

            final String query = "SELECT "+ project +
                    " FROM " + Activity.Member.TABLE_NAME +
                    " INNER JOIN " + Member.TABLE_NAME +
                    " ON " + Activity.Member.TABLE_NAME+"."+Activity.Member.Columns.MEMBER_ID +"="+ Member.TABLE_NAME+"."+Member.Columns._ID +
                    " WHERE " + selection +
                    " ORDER BY " + sortOrder;

            c = mDatabase.rawQuery(query, selectionArgs);
            break;
        }

//        case URI_CARTE_ITEM:
//        {
//            String project = "*";
//            if (projection != null)
//            {
//                // remove the brackets
//                project = Arrays.toString(projection);
//                project = project.substring(1,project.length()-1);
//            }
//
//            final String query = "SELECT "+ project +
//                    " FROM " + Carte.Item.TABLE_NAME +
//                    " LEFT JOIN " + Carte.Item.Images.TABLE_NAME +
//                    " ON " + Carte.Item.TABLE_NAME+"."+Carte.Item._ID +"="+ Carte.Item.Images.TABLE_NAME+"."+Carte.Item.Images.CARTE_ITEM_ID +
//                    " WHERE " + selection +
//                    " GROUP BY " + Carte.Item.TABLE_NAME+"."+Carte.Item._ID +
//                    " ORDER BY " + sortOrder;
//
//            c = mDatabase.rawQuery(query, selectionArgs);
//            break;
//        }
//
//        case URI_CARTE_ITEM_SINGLE:
//        {
//            String project = "*";
//            if (projection != null)
//            {
//                // remove the brackets
//                project = Arrays.toString(projection);
//                project = project.substring(1,project.length()-1);
//            }
//
//            // obtain the id
//            String id = Long.toString(ContentUris.parseId(uri));
//            // setup the query
//            final String query = "SELECT "+ project +
//                    " FROM " + Carte.Item.TABLE_NAME +
//                    " LEFT JOIN " + Carte.Item.Images.TABLE_NAME +
//                    " ON " + Carte.Item.TABLE_NAME+"."+Carte.Item._ID +"="+ Carte.Item.Images.TABLE_NAME+"."+Carte.Item.Images.CARTE_ITEM_ID +
//                    " WHERE " + Carte.Item.TABLE_NAME+"."+Carte.Item._ID +"=?"+
//                    " ORDER BY " + sortOrder +
//                    " LIMIT 0, 1";
//            selectionArgs = new String[] { id };
//
//            c = mDatabase.rawQuery(query, selectionArgs);
//            break;
//        }
//
//        case URI_CARTE_ITEM_OPTIONS:
//        {
//            String project = "*";
//            if (projection != null)
//            {
//                // remove the brackets
//                project = Arrays.toString(projection);
//                project = project.substring(1,project.length()-1);
//            }
//
//            final String query =
//                    "SELECT "+ project +
//                    		", (SELECT count(DISTINCT " + Carte.Item.Options.TABLE_NAME+"." + Carte.Item.Options._ID+")" +
//                            " FROM " + Carte.Item.Options.TABLE_NAME+
//                            " WHERE " + Carte.Item.Options.TABLE_NAME+"."+Carte.Item.Options.CARTE_ITEM_ID + "=?) AS " + Carte.Item.Options.SECTION_COUNT +
//                    " FROM "+ Carte.Item.Options.TABLE_NAME +
//                    " INNER JOIN " + Carte.Item.OptionItem.TABLE_NAME +
//                    " ON "+ Carte.Item.Options.TABLE_NAME+"."+Carte.Item.Options._ID +"="+ Carte.Item.OptionItem.TABLE_NAME+"."+Carte.Item.OptionItem.OPTION_ID +
//                    " WHERE " + Carte.Item.Options.TABLE_NAME+"."+Carte.Item.Options.CARTE_ITEM_ID + "=?" +
//                    " ORDER BY " + sortOrder;
//
//            c = mDatabase.rawQuery(query, selectionArgs);
//            break;
//        }
//
//        case URI_CARTE_ITEM_IMAGES:
//        {
//            // prepare the arguments
//            projection = new String[] { Carte.Item.Images.IMAGE };
//            selection = Carte.Item.Images.CARTE_ITEM_ID + "=?";
//            // query the image links
//            c = mDatabase.query(Carte.Item.Images.TABLE_NAME, projection, selection, selectionArgs, null, null, sortOrder);
//            break;
//        }
//
//        case URI_ORDER:
//        {
//            String project = "*";
//            if (projection != null)
//            {
//                // remove the brackets
//                project = Arrays.toString(projection);
//                project = project.substring(1,project.length()-1);
//            }
//
//            final String query = "SELECT " + project +
//                " FROM " + Order.TABLE_NAME +
//                " LEFT JOIN " + Carte.Item.TABLE_NAME +
//                " ON " + Carte.Item.TABLE_NAME+"."+Carte.Item._ID +"="+ Order.TABLE_NAME+"."+Order.ITEM_ID +
//                " LEFT JOIN " + Carte.Item.Images.TABLE_NAME +
//                " ON " + Carte.Item.TABLE_NAME+"."+Carte.Item._ID +"="+ Carte.Item.Images.TABLE_NAME+"."+Carte.Item.Images.CARTE_ITEM_ID +
//                " GROUP BY " + Order.TABLE_NAME+"."+Order._ID +
//                " ORDER BY " + sortOrder;
//
//            c = mDatabase.rawQuery(query, null);
//            break;
//        }
//
//        case URI_ORDER_OPTION:
//        {
//            String project = "*";
//            if (projection != null)
//            {
//                // remove the brackets
//                project = Arrays.toString(projection);
//                project = project.substring(1,project.length()-1);
//            }
//
//            final String query = "SELECT " + project +
//                " FROM " + Order.TABLE_NAME +
//                " INNER JOIN " + Order.Option.TABLE_NAME +
//                " ON (("+ Order.TABLE_NAME+"."+Order._ID +"="+ Order.Option.TABLE_NAME+"."+Order.Option.ORDER_ID +
//                ") or ("+ Order.TABLE_NAME+"."+Order.WEB_ID+ "!= -1 AND "+ Order.TABLE_NAME+"."+Order.WEB_ID +"="+ Order.Option.TABLE_NAME+"."+Order.Option.ORDER_WEB_ID + "))" +
//                " LEFT JOIN " + Carte.Item.OptionItem.TABLE_NAME +
//                " ON " + Carte.Item.OptionItem.TABLE_NAME+"."+Carte.Item.OptionItem._ID +"="+ Order.Option.TABLE_NAME+"."+Order.Option.OPTION_ID +
//                " LEFT JOIN " + Carte.Item.Options.TABLE_NAME +
//                " ON "+ Carte.Item.Options.TABLE_NAME+"."+Carte.Item.Options._ID +"="+ Carte.Item.OptionItem.TABLE_NAME+"."+Carte.Item.OptionItem.OPTION_ID +
//                " WHERE (" + Order.TABLE_NAME+"."+Order._ID+"=? OR ("+ Order.TABLE_NAME+"."+Order.WEB_ID+"!=-1 AND "+ Order.TABLE_NAME+"."+Order.WEB_ID+"=?))" +
//                " GROUP BY " + Carte.Item.OptionItem.TABLE_NAME+"."+Carte.Item.OptionItem._ID +
//                " ORDER BY " + sortOrder;
//
//            c = mDatabase.rawQuery(query, selectionArgs);
//            break;
//        }
//
//        case URI_CHAT:
//        {
//            c = mDatabase.query(Chat.TABLE_NAME, projection, selection, selectionArgs, null, null, sortOrder);
//            break;
//        }
//
//        case URI_CHAT_CONVERSATION:
//        {
//            String project = "*";
//            if (projection != null)
//            {
//                // remove the brackets
//                project = Arrays.toString(projection);
//                project = project.substring(1,project.length()-1);
//            }
//            selection = (selection == null) ? "" : " AND "+selection;
//
//            final String query = "SELECT "+ project +
//                    " FROM "+ Chat.Conversation.TABLE_NAME +
//                    " LEFT JOIN "+ Chat.TABLE_NAME +
//                    " ON ("+Chat.SENDER_ID+"="+Chat.Conversation.WITH_TABLE_ID+" OR "+Chat.RECEIVER_ID+"="+Chat.Conversation.WITH_TABLE_ID+")" +
//                    " WHERE " + Chat.MESSAGE + " IS NOT NULL" + selection +
//                    " GROUP BY "+ Chat.Conversation.TABLE_NAME+"."+Chat.Conversation.WITH_TABLE_ID +
//                    " ORDER BY " + sortOrder;
//
//            c = mDatabase.rawQuery(query, null);
//            break;
//        }

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
            answer = mDatabase.insert(Event.TABLE_NAME, null, values);
            break;

        case URI_EVENT_ATTENDERS:
            answer = mDatabase.insert(Event.Member.TABLE_NAME, null, values);
            break;

        case URI_ACTIVITY:
            answer = mDatabase.insert(Activity.TABLE_NAME, null, values);
            break;

        case URI_ACTIVITY_SCHEDULE:
        case URI_ACTIVITY_ATTENDERS:
            answer = mDatabase.insert(Activity.Member.TABLE_NAME, null, values);
            break;

        case URI_MEMBER:
            answer = mDatabase.insert(Member.TABLE_NAME, null, values);
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
            result = mDatabase.delete(Event.Member.TABLE_NAME, selection, selectionArgs);
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

        case URI_ACTIVITY_SCHEDULE:
        case URI_ACTIVITY_ATTENDERS:
            result = mDatabase.delete(Activity.Member.TABLE_NAME, selection, selectionArgs);
            break;

        case URI_MEMBER:
            result = mDatabase.delete(Member.TABLE_NAME, selection, selectionArgs);
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
                // do the updates for the version 2
                // XXX
                Log.i(InEvent.NAME, "Updated database to version 2");
            }
        }

        private void createEventTable(SQLiteDatabase db)
        {
            Log.i(InEvent.NAME, "Creating " + Event.TABLE_NAME + " table");

            db.execSQL("CREATE TABLE " + Event.TABLE_NAME + "(" +
                    Event.Columns._ID + " INTEGER NOT NULL UNIQUE, " +
                    Event.Columns.NAME + " TEXT NOT NULL, " +
                    Event.Columns.DESCRIPTION + " TEXT, " +
                    Event.Columns.DATE_BEGIN + " INTEGER, " +
                    Event.Columns.DATE_END + " INTEGER, " +
                    Event.Columns.LATITUDE + " REAL, " +
                    Event.Columns.LONGITUDE + " REAL, " +
                    Event.Columns.ADDRESS + " TEXT, " +
                    Event.Columns.CITY + " TEXT, " +
                    Event.Columns.STATE + " TEXT)"
            );

            Log.i(InEvent.NAME, "Creating " + Event.Member.TABLE_NAME + " table");

            db.execSQL("CREATE TABLE " + Event.Member.TABLE_NAME + "(" +
                    Event.Member.Columns._ID + " INTEGER NOT NULL UNIQUE, " +
                    Event.Member.Columns.EVENT_ID + SQLiteUtils.FOREIGN_KEY + ", " +
                    Event.Member.Columns.MEMBER_ID + SQLiteUtils.FOREIGN_KEY + ", " +
                    Event.Member.Columns.APPROVED + SQLiteUtils.BOOLEAN + ", " +
                    Event.Member.Columns.ROLE_ID + " INTEGER)"
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
                    Activity.Columns.DATE_BEGIN + " INTEGER, " +
                    Activity.Columns.DATE_END + " INTEGER)"
            );

            Log.i(InEvent.NAME, "Creating " + Activity.Member.TABLE_NAME + " table");

            db.execSQL("CREATE TABLE " + Activity.Member.TABLE_NAME + "(" +
                    Activity.Member.Columns.EVENT_ID + SQLiteUtils.FOREIGN_KEY + ", " +
                    Activity.Member.Columns.ACTIVITY_ID + SQLiteUtils.FOREIGN_KEY + ", " +
                    Activity.Member.Columns.MEMBER_ID + SQLiteUtils.FOREIGN_KEY + ", " +
                    Activity.Member.Columns.APPROVED + SQLiteUtils.BOOLEAN + ", " +
                    Activity.Member.Columns.PRESENT + SQLiteUtils.BOOLEAN + ")"
            );
        }

        private void createMemberTable(SQLiteDatabase db)
        {
            Log.i(InEvent.NAME, "Creating " + Member.TABLE_NAME + " table");

            db.execSQL("CREATE TABLE " + Member.TABLE_NAME + "(" +
                    Member.Columns._ID + " INTEGER NOT NULL UNIQUE, " +
                    Member.Columns.NAME + " TEXT NOT NULL, " +
                    Member.Columns.EMAIL + " TEXT, " +
                    Member.Columns.TELEPHONE + " TEXT)"
            );
        }
    }
}
