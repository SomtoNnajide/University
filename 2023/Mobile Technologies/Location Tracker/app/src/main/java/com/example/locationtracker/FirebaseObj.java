package com.example.locationtracker;

import java.io.Serializable;

public class FirebaseObj implements Serializable {
    private String address, date, name;
    private double latitude, longitude;

    public FirebaseObj(String name, String address, String date, double latitude, double longitude) {
        this.name = name;
        this.address = address;
        this.date = date;
        this.latitude = latitude;
        this.longitude = longitude;
    }

    public String getAddress() {return address;}

    public void setAddress(String address) {this.address = address;}

    public String getDate() {return date;}

    public void setDate(String date) {this.date = date;}

    public String getName() {return name;}

    public void setName(String name) {this.name = name;}

    public double getLatitude() {return latitude;}

    public void setLatitude(double latitude) {this.latitude = latitude;}

    public double getLongitude() {return longitude;}

    public void setLongitude(double longitude) {this.longitude = longitude;}
}
