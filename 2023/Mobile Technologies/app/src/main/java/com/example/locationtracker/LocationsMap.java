package com.example.locationtracker;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentContainerView;

import android.annotation.SuppressLint;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.Volley;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.OnStreetViewPanoramaReadyCallback;
import com.google.android.gms.maps.StreetViewPanorama;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.SupportStreetViewPanoramaFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.example.locationtracker.databinding.ActivityLocationsMapBinding;
import com.google.android.gms.maps.model.PolylineOptions;
import com.google.maps.android.PolyUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.w3c.dom.Text;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class LocationsMap extends AppCompatActivity implements OnMapReadyCallback, GoogleMap.OnInfoWindowClickListener {

    private GoogleMap mMap;
    private ActivityLocationsMapBinding binding;
    FragmentContainerView mView;
    FragmentContainerView sView;
    SupportStreetViewPanoramaFragment streetViewPanoramaFragment;
    Marker currentMarker, userMarker;
    boolean isMarkerClicked = false;
    LatLngBounds.Builder builder;
    final int PADDING = 200;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        binding = ActivityLocationsMapBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        // Obtain the SupportMapFragment and get notified when the map is ready to be used.
        SupportMapFragment mapFragment = (SupportMapFragment) getSupportFragmentManager()
                .findFragmentById(R.id.locationsMap);
        mapFragment.getMapAsync(this);

        streetViewPanoramaFragment = (SupportStreetViewPanoramaFragment) getSupportFragmentManager()
                .findFragmentById(R.id.locationsStreetView);

        builder = new LatLngBounds.Builder();
    }
    @Override
    protected void onSaveInstanceState(Bundle outState) {
        // Save the current state
        outState.putBoolean("marker_clicked", isMarkerClicked);
        super.onSaveInstanceState(outState);
    }
    @Override
    protected void onRestoreInstanceState(@NonNull Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);
        isMarkerClicked = savedInstanceState.getBoolean("marker_clicked");
    }


    @SuppressLint("PotentialBehaviorOverride")
    @Override
    public void onMapReady(GoogleMap googleMap) {
        mMap = googleMap;
        mMap.setOnInfoWindowClickListener(this);

        mView = findViewById(R.id.locationsMap);
        sView = findViewById(R.id.locationsStreetView);

        mMap.setOnMapLoadedCallback(new GoogleMap.OnMapLoadedCallback() {
            @Override
            public void onMapLoaded() {
                setCurrentUserMarkers();
                setUserMarkers();
                LatLng origin = getOrigin();
                LatLng destination = getDestination();
                drawRoute(origin, destination);

                LatLngBounds bounds = builder.build();

                mMap.moveCamera(CameraUpdateFactory.newLatLngBounds(bounds, PADDING));

                if(isMarkerClicked){
                    mView.setVisibility(View.INVISIBLE);
                    sView.setVisibility(View.VISIBLE);
                }
            }
        });

        mMap.setInfoWindowAdapter(new GoogleMap.InfoWindowAdapter() {
            @NonNull
            @SuppressLint("UseCompatLoadingForDrawables")
            @Override
            public View getInfoContents(@NonNull Marker marker) {
                View infoWindow = getLayoutInflater().inflate(R.layout.locations_info_window, null);

                TextView title = infoWindow.findViewById(R.id.locationsViewTitle);
                TextView snippet = infoWindow.findViewById(R.id.locationsViewSnippet);
                ImageView image = infoWindow.findViewById(R.id.locationsImageView);

                title.setText(marker.getTitle());
                snippet.setText(marker.getSnippet());
                image.setImageDrawable(getResources().getDrawable(R.mipmap.ic_blue_marker, getTheme()));
                return infoWindow;
            }

            @Nullable
            @Override
            public View getInfoWindow(@NonNull Marker marker) {return null;}
        });

        textViewListeners();
    }

    @Override
    public void onInfoWindowClick(@NonNull Marker marker) {
        isMarkerClicked = true;
        showStreetView(marker);
    }

    private void setCurrentUserMarkers(){
        ArrayList<FirebaseObj> currentUserData = (ArrayList<FirebaseObj>) getIntent().getSerializableExtra("currentUserData");

        for(FirebaseObj obj: currentUserData){
            String address = obj.getAddress();
            String date = obj.getDate();
            String name = obj.getName();
            double latitude = obj.getLatitude();
            double longitude = obj.getLongitude();

            LatLng coord = new LatLng(latitude, longitude);

            currentMarker = mMap.addMarker(new MarkerOptions()
                    .position(coord)
                    .title(name)
                    .snippet(date + "\n" + address)
                    .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_BLUE))
            );
            builder.include(coord);
        }
    }

    private void setUserMarkers(){
        ArrayList<FirebaseObj> userData = (ArrayList<FirebaseObj>) getIntent().getSerializableExtra("userData");

        for(FirebaseObj obj: userData){
            String address = obj.getAddress();
            String date = obj.getDate();
            String name = obj.getName();
            double latitude = obj.getLatitude();
            double longitude = obj.getLongitude();

            LatLng coord = new LatLng(latitude, longitude);

            userMarker = mMap.addMarker(new MarkerOptions()
                    .position(coord)
                    .title(name)
                    .snippet(date + "\n" + address)
            );
            builder.include(coord);
        }
    }
    private void showStreetView(@NonNull Marker marker){
        double latitude;
        double longitude;

        mView.setVisibility(View.INVISIBLE);
        sView.setVisibility(View.VISIBLE);

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

    private void textViewListeners(){
        TextView duration  = findViewById(R.id.txtDuration);
        TextView distance = findViewById(R.id.txtDistance);

        duration.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(sView.getVisibility() == View.VISIBLE){
                    sView.setVisibility(View.INVISIBLE);
                    mView.setVisibility(View.VISIBLE);
                }
            }
        });

        distance.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(sView.getVisibility() == View.VISIBLE){
                    sView.setVisibility(View.INVISIBLE);
                    mView.setVisibility(View.VISIBLE);
                }
            }
        });
    }

    private LatLng getOrigin(){
        ArrayList<FirebaseObj> currentUserData = (ArrayList<FirebaseObj>) getIntent().getSerializableExtra("currentUserData");

        FirebaseObj mostRecentObj = currentUserData.get(currentUserData.size()-1);

        double latitude = mostRecentObj.getLatitude();
        double longitude = mostRecentObj.getLongitude();

        return new LatLng(latitude, longitude);
    }

    private LatLng getDestination(){
        ArrayList<FirebaseObj> userData = (ArrayList<FirebaseObj>) getIntent().getSerializableExtra("userData");

        FirebaseObj mostRecentObj = userData.get(userData.size()-1);

        double latitude = mostRecentObj.getLatitude();
        double longitude = mostRecentObj.getLongitude();

        return new LatLng(latitude, longitude);
    }

    public void drawRoute(LatLng origin, LatLng destination) {
        TextView txtViewDistance = findViewById(R.id.txtDistance);
        TextView txtViewDuration = findViewById(R.id.txtDuration);

        String url = "https://maps.googleapis.com/maps/api/directions/json?origin="
                + origin.latitude + "," + origin.longitude + "&destination="
                + destination.latitude + "," + destination.longitude
                + "&mode=driving&key=AIzaSyB6yj-N7PQjXX7MVAfXHSZuIGF5p7SmZkE";

        JsonObjectRequest jsonObjectRequest = new JsonObjectRequest(Request.Method.
                GET, url,
                null,
                new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject response) {
                        // Parse the JSON response and draw the route on the map
                        PolylineOptions polylineOptions = new PolylineOptions();

                        polylineOptions.color(Color.RED);
                        polylineOptions.width(10);
                        JSONArray routes = null;

                        try {
                            routes = response.getJSONArray("routes");
                        } catch (JSONException e) {
                            throw new RuntimeException(e);
                        }

                        for (int i = 0; i < routes.length(); i++) {
                            try {
                                JSONObject route = routes.getJSONObject(i);
                                JSONObject overviewPolyline = route.getJSONObject("overview_polyline");
                                String points = overviewPolyline.getString("points");

                                List<LatLng> path = PolyUtil.decode(points);
                                polylineOptions.addAll(path);

                                String distance = route.getJSONArray("legs")
                                        .getJSONObject(0)
                                        .getJSONObject("distance")
                                        .getString("text");

                                String duration = route.getJSONArray("legs")
                                        .getJSONObject(0)
                                        .getJSONObject("duration")
                                        .getString("text");

                                txtViewDistance.setText(String.format("Distance: %s", distance));
                                txtViewDuration.setText(String.format("Distance: %s", duration));

                            } catch (JSONException e) {
                                throw new RuntimeException(e);
                            }
                        }
                        mMap.addPolyline(polylineOptions);
                    }
                },
                new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        // Handle the error
                    }
                });
        RequestQueue requestQueue = Volley.newRequestQueue(getApplicationContext());
        requestQueue.add(jsonObjectRequest);

        builder.include(origin);
        builder.include(destination);
    }

}