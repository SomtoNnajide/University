package com.example.locationtracker;

import android.annotation.SuppressLint;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import java.util.ArrayList;

public class SqlDatabase extends SQLiteOpenHelper {
    public static final String TABLE_NAME = "LocationTracker";
    public static final String COLUMN_ID = "id";
    public static final String COLUMN_USER = "username";
    public static final String COLUMN_CURRENTUSER = "isCurrent";

    public SqlDatabase(Context context, String name,
                      SQLiteDatabase.CursorFactory factory, int version) {
        super(context, name, factory, version);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL(
                "create table " + TABLE_NAME +
                        "(" +
                        COLUMN_ID + " integer primary key, " +
                        COLUMN_USER + " text, " +
                        COLUMN_CURRENTUSER + " text" +
                        ")"
        );
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("drop table if exists " + TABLE_NAME);
        onCreate(db);
    }

    public long insertUsername(String username, String isCurrent) {
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues contentValues = new ContentValues();
        contentValues.put(COLUMN_USER, username);
        contentValues.put(COLUMN_CURRENTUSER, isCurrent);

        long id = db.insert(TABLE_NAME, null, contentValues);

        return id;
    }

    public ArrayList<String> getAllUsernames() {
        ArrayList<String> allUsernames = new ArrayList<>();
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor cursor = db.rawQuery("select * from " + TABLE_NAME, null);

        cursor.moveToFirst();
        while (!cursor.isAfterLast()) {
            @SuppressLint("Range") String username = cursor.getString(cursor.getColumnIndex(COLUMN_USER));
            allUsernames.add(username);
            cursor.moveToNext();
        }
        return allUsernames;
    }

    @SuppressLint("Range")
    public String getSelectedUser() {
        String selectedUser = null;
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor cursor = db.rawQuery("select * from " + TABLE_NAME, null);

        cursor.moveToFirst();
        while (!cursor.isAfterLast()){
            selectedUser = cursor.getString(cursor.getColumnIndex(COLUMN_CURRENTUSER));
            cursor.moveToNext();
        }
        return selectedUser;
    }

    public void deleteAllUsernames() {
        SQLiteDatabase db = this.getWritableDatabase();
        db.execSQL("delete from " + TABLE_NAME);
    }


}
