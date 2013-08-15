package com.estudiotrilha.inevent.app;

import android.content.SharedPreferences;
import android.content.SharedPreferences.OnSharedPreferenceChangeListener;
import android.os.Bundle;
import android.preference.CheckBoxPreference;
import android.preference.PreferenceActivity;
import android.preference.PreferenceManager;

import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.R;
import com.google.analytics.tracking.android.EasyTracker;

@SuppressWarnings("deprecation")
public class PreferencesActivity extends PreferenceActivity implements OnSharedPreferenceChangeListener
{
    public static final String SLIDING_MENU_SHOWN      = InEvent.class.getPackage().getName() + ".preferences.SLIDING_MENU_SHOWN";
    public static final int    SLIDING_MENU_SHOWN_MAX  = 3;

    public static final String SPLASH_ENABLED          = InEvent.class.getPackage().getName() + ".preferences.SPLASH_ENABLED";

    public static final String USE_MOBILE_CONNECTION   = InEvent.class.getPackage().getName() + ".preferences.USE_MOBILE_CONNECTION";


    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        addPreferencesFromResource(R.xml.preferences);

        CheckBoxPreference pref = (CheckBoxPreference) findPreference(SPLASH_ENABLED);
        pref.setSummary(pref.isChecked() ? R.string.preference_summary_splashScreen_enabled : R.string.preference_summary_splashScreen_unabled);
    }

    @Override
    protected void onResume()
    {
        super.onResume();
        PreferenceManager.getDefaultSharedPreferences(this)
                .registerOnSharedPreferenceChangeListener(this);
    }
    @Override
    protected void onPause()
    {
        super.onPause();
        PreferenceManager.getDefaultSharedPreferences(this)
                .unregisterOnSharedPreferenceChangeListener(this);
    }

    @Override
    protected void onStart()
    {
        super.onStart();
        if (!InEvent.DEBUG)
        {
            EasyTracker.getInstance().activityStart(this);
        }
    }
    @Override
    protected void onStop()
    {
        super.onStop();
        if (!InEvent.DEBUG)
        {
            EasyTracker.getInstance().activityStop(this);
        }
    }

    @Override
    public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String key)
    {
        if (key.equals(SPLASH_ENABLED))
        {
            CheckBoxPreference pref = (CheckBoxPreference) findPreference(key);
            pref.setSummary(pref.isChecked() ? R.string.preference_summary_splashScreen_enabled : R.string.preference_summary_splashScreen_unabled);
        }
    }
}
