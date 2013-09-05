package com.estudiotrilha.inevent.app;

import com.estudiotrilha.inevent.R;

import android.annotation.TargetApi;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewTreeObserver;


public class AboutActivity extends ActionBarActivity
{
    private View mProductView;
    private View mCompanyView;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_about);

        // Get the views
        mProductView = findViewById(R.id.about_product);
        mCompanyView = findViewById(R.id.about_company);

        // Setup the click listeners
        mProductView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v)
            {
                // Open the Facebook app Page
                Uri facebookPage = Uri.parse("https://www.facebook.com/pages/In-Event/150798025113523");
                startActivity(new Intent(Intent.ACTION_VIEW, facebookPage));
            }
        });
        mCompanyView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v)
            {
                // Open the Facebook app Page
                Uri facebookPage = Uri.parse("https://www.facebook.com/estudiotrilha");
                startActivity(new Intent(Intent.ACTION_VIEW, facebookPage));
            }
        });

        // And the animations
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.ICE_CREAM_SANDWICH
                && savedInstanceState == null)
        {
            mProductView.getViewTreeObserver().addOnPreDrawListener(new ViewTreeObserver.OnPreDrawListener() {
                @TargetApi(Build.VERSION_CODES.ICE_CREAM_SANDWICH)
                @Override
                public boolean onPreDraw()
                {
                    mProductView.getViewTreeObserver().removeOnPreDrawListener(this);
                    mProductView.setAlpha(0f);
                    mProductView.setTranslationX(mProductView.getWidth());
    
                    mProductView.animate()
                            .setDuration(getResources().getInteger(android.R.integer.config_mediumAnimTime))
                            .setStartDelay(getResources().getInteger(android.R.integer.config_mediumAnimTime))
                            .alpha(1)
                            .translationX(0);
        
                    return true;
                }
            });

            mCompanyView.getViewTreeObserver().addOnPreDrawListener(new ViewTreeObserver.OnPreDrawListener() {
                @TargetApi(Build.VERSION_CODES.ICE_CREAM_SANDWICH)
                @Override
                public boolean onPreDraw()
                {
                    mCompanyView.getViewTreeObserver().removeOnPreDrawListener(this);
                    mCompanyView.setAlpha(0f);
                    mCompanyView.setScaleX(.3f);
                    mCompanyView.setScaleY(.3f);
    
                    int duration = getResources().getInteger(android.R.integer.config_mediumAnimTime);
                    mCompanyView.animate()
                            .setDuration(duration)
                            .setStartDelay(2*duration)
                            .alpha(1)
                            .scaleX(1)
                            .scaleY(1);
        
                    return true;
                }
            });
        }

        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
    }
    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        if (item.getItemId() == android.R.id.home)
        {
            // Closes this activity
            finish();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
