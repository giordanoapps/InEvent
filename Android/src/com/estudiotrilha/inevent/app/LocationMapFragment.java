package com.estudiotrilha.inevent.app;

import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.R;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.TextView;


public class LocationMapFragment extends Fragment
{
    // Tag
    private static final String TAG = "tag.LOCATION_MAP";

    // Arguments
    private static final String ARGS_TEXT      = "args.TEXT";
    private static final String ARGS_LATITUDE  = "args.LATITUDE";
    private static final String ARGS_LONGITUDE = "args.LONGITUDE";


    public static LocationMapFragment instantiate(String text, double latitude, double longitude)
    {
        // Prepare the arguments
        Bundle args = new Bundle();
        args.putString(ARGS_TEXT, text);
        args.putDouble(ARGS_LATITUDE, latitude);
        args.putDouble(ARGS_LONGITUDE, longitude);

        LocationMapFragment fragment = new LocationMapFragment();
        fragment.setArguments(args);
        return fragment ;
    }


    private GoogleMap mMap;

    private SupportMapFragment mMapFragment;

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        return inflater.inflate(R.layout.fragment_location_map, container, false);
    }
    @Override
    public void onViewCreated(View view, Bundle savedInstanceState)
    {
        super.onViewCreated(view, savedInstanceState);

        if (savedInstanceState == null)
        {
            mMapFragment = SupportMapFragment.newInstance();
            getChildFragmentManager().beginTransaction()
                .add(R.id.location_container, mMapFragment, TAG)
                .commit();
        }
        else
        {
            mMapFragment = (SupportMapFragment) getChildFragmentManager().findFragmentByTag(TAG);
        }

    }
    @Override
    public void onStart()
    {
        super.onStart();

        if (getView() == null) return;

        final TextView text = (TextView) getView().findViewById(R.id.location_text);
        text.setText(getArguments().getString(ARGS_TEXT));
        text.bringToFront();

        // setup map if needed
        if (mMap == null)
        {
            // Try to obtain the map from the SupportMapFragment.
            mMap = mMapFragment.getMap();

            // Check if we were successful in obtaining the map.
            if (mMap != null)
            {
                mMap.setMyLocationEnabled(true);
                text.getViewTreeObserver().addOnPreDrawListener(new ViewTreeObserver.OnPreDrawListener() {
                    @Override
                    public boolean onPreDraw()
                    {
                        text.getViewTreeObserver().removeOnPreDrawListener(this);
                        mMap.setPadding(0, text.getHeight(), 0, 0);
    
                        Marker marker = mMap.addMarker(getMarker());
                        mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(marker.getPosition(), 16));
                        return true;
                    }
                });
            }
            else
            {
                Log.e(InEvent.NAME, "Could not retrieve a map instance!!!");
            }
        }
    }
    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater)
    {
        super.onCreateOptionsMenu(menu, inflater);
        menu.clear();
        inflater.inflate(R.menu.fragment_location_map, menu);
    }
    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        switch (item.getItemId())
        {
        case android.R.id.home:
            getFragmentManager().popBackStackImmediate();
            break;

        case R.id.action_directions:
        {
            String destination = getArguments().getDouble(ARGS_LATITUDE)+","+getArguments().getDouble(ARGS_LONGITUDE);
            Intent directions = new Intent(Intent.ACTION_VIEW, Uri.parse("https://maps.google.com/maps?f=d&daddr="+destination));
            getActivity().startActivity(directions);
            break;
        }

        }
        return super.onOptionsItemSelected(item);
    }

    private MarkerOptions getMarker()
    {
        return new MarkerOptions()
            .position(new LatLng(
                    getArguments().getDouble(ARGS_LATITUDE),
                    getArguments().getDouble(ARGS_LONGITUDE))
            );
    }
}
