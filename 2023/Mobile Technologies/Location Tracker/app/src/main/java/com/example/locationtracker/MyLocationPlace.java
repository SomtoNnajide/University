package com.example.locationtracker;

import com.google.android.gms.maps.model.LatLng;

public class MyLocationPlace {
    private double latitude;
    private double longitude;

    private LatLng latLng;
    private String address = "";

    private String name = "";

    public MyLocationPlace(double latitude, double longitude, String address) {
        this.setLatitude(latitude);
        this.setLongitude(longitude);
        this.setAddress(address);
    }

    public MyLocationPlace(LatLng latLng, String address) {
        this.setLatLng(latLng);
        this.setAddress(address);
    }

    public MyLocationPlace(LatLng latLng, String address, String name) {
        this.setLatLng(latLng);
        this.setAddress(address);
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public LatLng getLatLng() {
        latLng = new LatLng(latitude, longitude);
        return latLng;
    }

    public void setLatLng(LatLng latLng) {
        this.latLng = latLng;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}


