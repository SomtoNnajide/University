package com.example.locationtracker;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;
import android.widget.Toast;

import java.util.ArrayList;

public class SqlActivity extends AppCompatActivity {
    String selectedUser, currentUser, first_user, second_user, third_user, unselectedUser1, unselectedUser2;
    Button startbtn;
    RadioGroup radioGroup;
    private boolean isClicked = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sql);

        saveUsernames();
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        // Save the current state
        outState.putBoolean("button_clicked", isClicked);
        outState.putString("user1", first_user);
        outState.putString("user2", second_user);
        outState.putString("user3", third_user);
        outState.putString("selectedUser", selectedUser);
        outState.putString("unselectedUser1", unselectedUser1);
        outState.putString("unselectedUser2", unselectedUser2);
        super.onSaveInstanceState(outState);
    }
    @Override
    protected void onRestoreInstanceState(@NonNull Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);

        isClicked = savedInstanceState.getBoolean("button_clicked");
        first_user = savedInstanceState.getString("user1");
        second_user = savedInstanceState.getString("user2");
        third_user= savedInstanceState.getString("user3");
        selectedUser = savedInstanceState.getString("selectedUser");
        unselectedUser1 = savedInstanceState.getString("unselectedUser1");
        unselectedUser2 = savedInstanceState.getString("unselectedUser2");

        if(isClicked){
            viewsVisibleOnClick(radioGroup, startbtn, first_user, second_user, third_user);
            loadSelectedUser(currentUser, radioGroup);
        }
    }

    private void saveUsernames(){
        SqlDatabase db = new SqlDatabase(this, "Location Tracker", null, 1);

        Button savebtn = findViewById(R.id.btnSaveAllUsernames);
        startbtn  = findViewById(R.id.btnStart);
        radioGroup = findViewById(R.id.radioGroup);

        EditText edt1 = findViewById(R.id.edtFirstUser);
        EditText edt2 = findViewById(R.id.edtSecondUser);
        EditText edt3 = findViewById(R.id.edtThirdUser);

        ArrayList<String> usernames = db.getAllUsernames();
        currentUser = db.getSelectedUser();

        //load usernames if data exists
        loadData(usernames, edt1, edt2,edt3);

        //on savebtn click
        //reset db => upload usernames and selected user (null)
        //make views visible
        //load selected user if data exists
        savebtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isClicked = true;

                first_user = edt1.getText().toString();
                second_user = edt2.getText().toString();
                third_user = edt3.getText().toString();

                //check if any input field is blank
                //=> warning thrown
                if(edt1.getText().toString().equals("") || edt2.getText().toString().equals("") || edt3.getText().toString().equals("")){
                    Toast.makeText(getApplicationContext(), "Please Enter 3 Usernames", Toast.LENGTH_LONG).show();
                }
                else{
                    db.deleteAllUsernames();

                    db.insertUsername(first_user, null);
                    db.insertUsername(second_user, null);
                    db.insertUsername(third_user, null);

                    //make views visible
                    viewsVisibleOnClick(radioGroup, startbtn, first_user, second_user, third_user);

                    //laod selected user
                    loadSelectedUser(currentUser, radioGroup);
                }
            }
        });

        radioGroup.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                RadioButton selectedRadioButton = findViewById(checkedId);
                selectedUser = selectedRadioButton.getText().toString();
            }
        });

        startbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //check if any input field is blank
                //=> warning thrown
                if(edt1.getText().toString().equals("") || edt2.getText().toString().equals("") || edt3.getText().toString().equals("")){
                    Toast.makeText(getApplicationContext(), "Please Enter 3 Usernames", Toast.LENGTH_LONG).show();
                }
                else{
                    db.deleteAllUsernames();

                    db.insertUsername(first_user, selectedUser);
                    db.insertUsername(second_user, selectedUser);
                    db.insertUsername(third_user, selectedUser);

                    String[] unselectedUsers = getUnselectedUsers(selectedUser, radioGroup);
                    unselectedUser1 = unselectedUsers[0];
                    unselectedUser2 = unselectedUsers[1];

                    Intent intent = new Intent(getApplicationContext(), MainActivity.class);
                    intent.putExtra("current", selectedUser);
                    intent.putExtra("user1", unselectedUser1);
                    intent.putExtra("user2", unselectedUser2);
                    startActivity(intent);
                }
            }
        });

    }

    private void viewsVisibleOnClick(RadioGroup rg, Button start, String fu, String su, String tu){
        TextView txtSelectCurrentUser = findViewById(R.id.txtSelectCurrentUser);

        txtSelectCurrentUser.setVisibility(View.VISIBLE);
        rg.setVisibility(View.VISIBLE);
        start.setVisibility(View.VISIBLE);

        RadioButton rb1 = findViewById(R.id.rbFirstUser);
        RadioButton rb2 = findViewById(R.id.rbSecondUser);
        RadioButton rb3 = findViewById(R.id.rbThirdUser);

        rb1.setText(fu);
        rb2.setText(su);
        rb3.setText(tu);
    }

    private void loadData(ArrayList<String> usernames, EditText edt1, EditText edt2, EditText edt3){
        if(usernames.size() > 0){
            edt1.setText(usernames.get(0));
            edt2.setText(usernames.get(1));
            edt3.setText(usernames.get(2));
        }
    }

    private void loadSelectedUser(String currentUser, RadioGroup rg){
        if(currentUser != null){
            for(int i = 0; i < rg.getChildCount(); i++){
                RadioButton rb = (RadioButton) rg.getChildAt(i);

                if(rb.getText().toString().equals(currentUser)){
                    rg.check(rb.getId());
                }
            }
        }
    }

    private String[] getUnselectedUsers(String currentUser, RadioGroup rg){
        String[] unselectedUsers = new String[2];

        if(currentUser != null){
            for(int i = 0; i < rg.getChildCount(); i++){
                RadioButton rb = (RadioButton) rg.getChildAt(i);

                if(rb.getText().toString().equals(currentUser)){
                    if (i == 0){
                        RadioButton rb1 = (RadioButton) rg.getChildAt(1);
                        RadioButton rb2 = (RadioButton) rg.getChildAt(2);

                        unselectedUsers[0] = rb1.getText().toString();
                        unselectedUsers[1] = rb2.getText().toString();
                    }

                    if (i == 1){
                        RadioButton rb1 = (RadioButton) rg.getChildAt(0);
                        RadioButton rb2 = (RadioButton) rg.getChildAt(2);

                        unselectedUsers[0] = rb1.getText().toString();
                        unselectedUsers[1] = rb2.getText().toString();
                    }

                    if (i == 2){
                        RadioButton rb1 = (RadioButton) rg.getChildAt(0);
                        RadioButton rb2 = (RadioButton) rg.getChildAt(1);

                        unselectedUsers[0] = rb1.getText().toString();
                        unselectedUsers[1] = rb2.getText().toString();
                    }
                }
            }
        }

        return unselectedUsers;
    }
}