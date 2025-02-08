package com.example.locationtracker;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentContainerView;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.OnStreetViewPanoramaReadyCallback;
import com.google.android.gms.maps.StreetViewPanorama;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.SupportStreetViewPanoramaFragment;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.example.locationtracker.databinding.ActivityMapsBinding;

public class MapsActivity extends AppCompatActivity implements GoogleMap.OnInfoWindowClickListener, OnMapReadyCallback {
    GoogleMap mMap;
    ActivityMapsBinding binding;
    MyLocationPlaceMap myLocationPlaces;
    FragmentContainerView mView;
    FragmentContainerView sView;
    SupportStreetViewPanoramaFragment streetViewPanoramaFragment;
    Button btnchangeView;
    Marker currentMarker, nearbyMarker;
    String btnText;
    double nearbyMarkerLatitude, nearbyMarkerLongitude;
    boolean isNearbyClicked, isRedMarkerClicked, isInfoWindowClicked, isChangeViewClicked, mapWasVisible, streetViewWasVisible = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        binding = ActivityMapsBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        // Obtain the SupportMapFragment and get notified when the map is ready to be used.
        SupportMapFragment mapFragment = (SupportMapFragment) getSupportFragmentManager()
                .findFragmentById(R.id.map);

        assert mapFragment != null;
        mapFragment.getMapAsync(this);

        //obtain the StreetViewPanorama fragment
        streetViewPanoramaFragment = (SupportStreetViewPanoramaFragment) getSupportFragmentManager()
                        .findFragmentById(R.id.streetView);

        myLocationPlaces = new MyLocationPlaceMap(getApplicationContext(), MapsActivity.this);

        //display current location
        displayCurrentLocation();
    }
    @Override
    protected void onSaveInstanceState(Bundle outState) {
        // Save the current state
        outState.putBoolean("nearby_clicked", isNearbyClicked);
        outState.putBoolean("red_marker_clicked", isRedMarkerClicked);
        outState.putBoolean("info_window_clicked", isInfoWindowClicked);
        outState.putBoolean("change_view_clicked", isChangeViewClicked);
        outState.putBoolean("street_view_visible", mapWasVisible);
        outState.putBoolean("map_view_visible", streetViewWasVisible);
        outState.putDouble("nearby_marker_latitude", nearbyMarkerLatitude);
        outState.putDouble("nearby_marker_longitude", nearbyMarkerLongitude);
        super.onSaveInstanceState(outState);
    }
    @Override
    protected void onRestoreInstanceState(@NonNull Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);
        isNearbyClicked = savedInstanceState.getBoolean("nearby_clicked");
        isRedMarkerClicked = savedInstanceState.getBoolean("red_marker_clicked");
        isInfoWindowClicked = savedInstanceState.getBoolean("info_window_clicked");
        isChangeViewClicked = savedInstanceState.getBoolean("change_view_clicked");
        mapWasVisible = savedInstanceState.getBoolean("street_view_visible");
        streetViewWasVisible = savedInstanceState.getBoolean("map_view_visible");
        nearbyMarkerLatitude = savedInstanceState.getDouble("nearby_marker_latitude");
        nearbyMarkerLongitude = savedInstanceState.getDouble("nearby_marker_longitude");
    }

    @SuppressLint("PotentialBehaviorOverride")
    @Override
    public void onMapReady(@NonNull GoogleMap googleMap) {
        mMap = googleMap;
        mMap.setOnInfoWindowClickListener(this);

        mView = findViewById(R.id.map);
        sView = findViewById(R.id.streetView);
        btnchangeView = findViewById(R.id.btnChangeView);

        mMap.setOnMapLoadedCallback(new GoogleMap.OnMapLoadedCallback() {
            @Override
            public void onMapLoaded() {
                setMarkerAtCurrentLocation();

                if(isNearbyClicked){
                    showNearbyPlaces(null);
                }

                if(isNearbyClicked && isRedMarkerClicked){
                    showStreetView(currentMarker);
                }

                if(isNearbyClicked && isInfoWindowClicked){
                    LatLng position = new LatLng(nearbyMarkerLatitude, nearbyMarkerLongitude);
                    Marker marker = mMap.addMarker(new MarkerOptions()
                            .position(position));

                    assert marker != null;
                    onInfoWindowClick(marker);
                }

                if(isChangeViewClicked && mapWasVisible){
                    showStreetView(currentMarker);
                }

                if(isChangeViewClicked && streetViewWasVisible){
                    changeView(null);
                }
            }
        });

        //customise info window
        mMap.setInfoWindowAdapter(new GoogleMap.InfoWindowAdapter() {
            @SuppressLint("UseCompatLoadingForDrawables")
            @NonNull
            @Override
            public View getInfoContents(@NonNull Marker marker) {
                View infoWindow = getLayoutInflater().inflate(R.layout.custom_info_window, null);

                TextView title = infoWindow.findViewById(R.id.textViewTitle);
                TextView snippet = infoWindow.findViewById(R.id.textViewSnippet);
                ImageView image = infoWindow.findViewById(R.id.imageView);

                title.setText(marker.getTitle());
                snippet.setText(marker.getSnippet());
                image.setImageDrawable(getResources().getDrawable(R.mipmap.ic_blue_marker, getTheme()));
                return infoWindow;
            }

            @Nullable
            @Override
            public View getInfoWindow(@NonNull Marker marker) {
                return null;
            }
        });

        //on marker click
        //changes to street view of current location
        //else show info window of nearby places marker
        mMap.setOnMarkerClickListener(new GoogleMap.OnMarkerClickListener() {
            @Override
            public boolean onMarkerClick(@NonNull Marker marker) {
                if(marker.getId().equals(currentMarker.getId())){
                    isRedMarkerClicked = true;
                    showStreetView(marker);
                    return true;
                }
                else{
                    nearbyMarker = marker;
                    nearbyMarkerLatitude = nearbyMarker.getPosition().latitude;
                    nearbyMarkerLongitude = nearbyMarker.getPosition().longitude;
                    nearbyMarker.showInfoWindow();
                }
                return false;
            }
        });
    }

    @Override   //show street view of info window
    public void onInfoWindowClick(@NonNull Marker marker) {
        isInfoWindowClicked = true;
        showStreetView(marker);
    }

    public void displayCurrentLocation(){
        Bundle extras = getIntent().getExtras();

        if(extras != null){
            double latitude = extras.getDouble("lat");
            double longitude = extras.getDouble("lng");
            String address = extras.getString("addr");

            TextView text_view_lat = findViewById(R.id.textViewLatitude);
            TextView text_view_lng = findViewById(R.id.textViewLongitude);
            TextView text_view_addr = findViewById(R.id.textViewAddress);

            text_view_lat.setText(String.format("Latitude: %s", latitude));
            text_view_lng.setText(String.format("Longitude: %s", longitude));
            text_view_addr.setText(String.format("Address: %s", address));
        }
    }

    public void setMarkerAtCurrentLocation(){
        Bundle extras = getIntent().getExtras();

        if(extras != null) {
            double latitude = extras.getDouble("lat");
            double longitude = extras.getDouble("lng");
            String address = extras.getString("addr");

            LatLng current = new LatLng(latitude, longitude);
            LatLngBounds.Builder builder = new LatLngBounds.Builder();

            currentMarker = mMap.addMarker(new MarkerOptions()
                    .position(current)
                    .title(address)
                    .snippet(address)
            );

            //set camera at greatest possible zoom level
            builder.include(current);
            LatLngBounds bounds = builder.build();
            int padding = 100;

            mMap.moveCamera(CameraUpdateFactory.newLatLngBounds(bounds, padding));
        }
    }

    public void changeView(View view){
        isChangeViewClicked = true;

        btnText = btnchangeView.getText().toString();

        if(btnText.equals("Show Map")){
            btnchangeView.setText(R.string.show_street_view);
            mView.setVisibility(View.VISIBLE);
            sView.setVisibility(View.INVISIBLE);
            streetViewWasVisible = true;
        }
        else if(btnText.equals("Show Street View")){
            showStreetView(currentMarker);
            mapWasVisible = true;
        }
    }

    public void showNearbyPlaces(View view){
        isNearbyClicked = true;
        myLocationPlaces.getNearbyPlaces(mMap, "AIzaSyB6yj-N7PQjXX7MVAfXHSZuIGF5p7SmZkE");
    }

    private void showStreetView(@NonNull Marker marker){
        double latitude;
        double longitude;

        mView.setVisibility(View.INVISIBLE);
        sView.setVisibility(View.VISIBLE);

        if(marker.getId().equals(currentMarker.getId())){
            btnchangeView.setText(R.string.show_map);
        }
        else{
            btnchangeView.setText(R.string.show_street_view);
        }

        latitude = marker.getPosition().latitude;
        longitude = marker.getPosition().longitude;

        streetViewPanoramaFragment.getStreetViewPanoramaAsync(new OnStreetViewPanoramaReadyCallback() {
            @Override
            public void onStreetViewPanoramaReady(@NonNull StreetViewPanorama streetViewPanorama) {
                LatLng current = new LatLng(latitude, longitude);
                streetViewPanorama.setPosition(current);
            }
        });
    }
}