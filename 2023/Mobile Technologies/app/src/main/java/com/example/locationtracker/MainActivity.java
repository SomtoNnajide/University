package com.example.locationtracker;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.Toast;

import com.google.firebase.database.ChildEventListener;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Objects;

public class MainActivity extends AppCompatActivity {
    MyLocationPlaceMap myLocationPlaceMap;
    ArrayList<MyLocationPlace> myLocations = new ArrayList<>();
    MyLocationPlace myLocation;
    double latitude;
    double longitude;
    String address, currentUser, user1, user2;
    Button btnCurrentUser, btnUser1, btnUser2;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        ImageView imgView = findViewById(R.id.imageView);
        imgView.setImageResource(R.drawable.mapsimg);

        //prepare configs
        myLocationPlaceMap = new MyLocationPlaceMap(getApplicationContext(), MainActivity.this);
        myLocationPlaceMap.requestPermissions();
        myLocationPlaceMap.getLatLngAddress(myLocations);

        receiveUsernames();
    }

    public void myLocationDetails(View view) {
        Intent intent = new Intent(this, MapsActivity.class);

        @SuppressLint("SimpleDateFormat") SimpleDateFormat formatter = new SimpleDateFormat("dd/MM/yyyy 'at' hh:mm:ss a");

        String date = formatter.format(new Date());

        if (myLocations.size() > 0) {
            myLocationPlaceMap.getLatLngAddress(myLocations);
            myLocation = myLocations.get(0);
            myLocations.clear();

            latitude = myLocation.getLatitude();
            longitude = myLocation.getLongitude();
            address = myLocation.getAddress();
        }

        checkDuplicateData(currentUser, address, date, latitude, longitude);

        intent.putExtra("lat", latitude);
        intent.putExtra("lng", longitude);
        intent.putExtra("addr", address);

        startActivity(intent);
    }

    private void receiveUsernames() {
        Bundle extras = getIntent().getExtras();

        btnCurrentUser = findViewById(R.id.btnCurrentUser);
        btnUser1 = findViewById(R.id.btnUser1);
        btnUser2 = findViewById(R.id.btnUser2);

        if (extras != null) {
            currentUser = extras.getString("current");
            user1 = extras.getString("user1");
            user2 = extras.getString("user2");

            btnCurrentUser.setText(String.format("Where am I (%s)?", currentUser));
            btnUser1.setText(String.format("Where is %s?", user1));
            btnUser2.setText(String.format("Where is %s?", user2));
        }
    }

    private void checkDuplicateData(String user, String address, String date, double latitude, double longitude) {
        DatabaseReference dbref = FirebaseDatabase.getInstance().getReference(user);

        dbref.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                boolean found = false;

                if (snapshot.exists()) {
                    for(DataSnapshot key: snapshot.getChildren()){
                        if(key.child("address").getValue().toString().equals(address))
                        {
                            found = true;
                        }
                    }

                    if(!found){
                        uploadDataToRealtimeDB(user, address, date, latitude, longitude);
                    }

                } else {
                    uploadDataToRealtimeDB(user, address, date, latitude, longitude);
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {

            }
        });
    }

    private void uploadDataToRealtimeDB(String user, String address, String date, double latitude, double longitude) {
        DatabaseReference dbref = FirebaseDatabase.getInstance().getReference(user);

        String randomkey = dbref.push().getKey();

        assert randomkey != null;
        dbref.child(randomkey).child("address").setValue(address);
        dbref.child(randomkey).child("date").setValue(date);
        dbref.child(randomkey).child("latitude").setValue(latitude);
        dbref.child(randomkey).child("longitude").setValue(longitude);
    }

    public void trackUser1(View view){
        downloadDataFromRealtimeDB(currentUser, user1);
    }

    public void trackUser2(View view){downloadDataFromRealtimeDB(currentUser, user2);}

    private void downloadDataFromRealtimeDB(String current, String user){
        DatabaseReference dbrefCurrent = FirebaseDatabase.getInstance().getReference(current);
        DatabaseReference dbrefUser = FirebaseDatabase.getInstance().getReference(user);

        ArrayList<FirebaseObj> downloadedCurrentObjs = new ArrayList<>();
        ArrayList<FirebaseObj> downloadedUserObjs = new ArrayList<>();

        Intent intent = new Intent(getApplicationContext(), LocationsMap.class);

        dbrefCurrent.addChildEventListener(new ChildEventListener() {
            @Override
            public void onChildAdded(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {
                for(DataSnapshot key: snapshot.getChildren()){
                   String address = Objects.requireNonNull(snapshot.child("address").getValue()).toString();
                    String date = Objects.requireNonNull(snapshot.child("date").getValue()).toString();
                    double latitude = Double.parseDouble(Objects.requireNonNull(snapshot.child("latitude").getValue()).toString());
                    double longitude = Double.parseDouble(Objects.requireNonNull(snapshot.child("longitude").getValue()).toString());

                    FirebaseObj currentObj = new FirebaseObj(current, address, date, latitude, longitude);
                    downloadedCurrentObjs.add(currentObj);
                }
                intent.putExtra("currentUserData", downloadedCurrentObjs);

                dbrefUser.addChildEventListener(new ChildEventListener() {
                    @Override
                    public void onChildAdded(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {
                        for(DataSnapshot key: snapshot.getChildren()){
                            String address = Objects.requireNonNull(snapshot.child("address").getValue()).toString();
                            String date = Objects.requireNonNull(snapshot.child("date").getValue()).toString();
                            double latitude = Double.parseDouble(Objects.requireNonNull(snapshot.child("latitude").getValue()).toString());
                            double longitude = Double.parseDouble(Objects.requireNonNull(snapshot.child("longitude").getValue()).toString());

                            FirebaseObj userObj = new FirebaseObj(user, address, date, latitude, longitude);
                            downloadedUserObjs.add(userObj);
                        }
                        intent.putExtra("userData", downloadedUserObjs);
                        startActivity(intent);
                    }

                    @Override
                    public void onChildChanged(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {}

                    @Override
                    public void onChildRemoved(@NonNull DataSnapshot snapshot) {}

                    @Override
                    public void onChildMoved(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {}

                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {}
                });
            }

            @Override
            public void onChildChanged(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {}

            @Override
            public void onChildRemoved(@NonNull DataSnapshot snapshot) {}

            @Override
            public void onChildMoved(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {}

            @Override
            public void onCancelled(@NonNull DatabaseError error) {}

        });
    }
}
