package com.estudiotrilha.inevent.app;

import java.io.IOException;
import java.net.HttpURLConnection;

import org.apache.http.HttpStatus;
import org.json.JSONObject;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.util.Log;
import android.view.View;
import android.widget.TextView;

import com.estudiotrilha.android.content.ApiRequest;
import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.Utils;
import com.estudiotrilha.inevent.content.Activity;
import com.estudiotrilha.inevent.content.ApiRequestCode;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.content.SyncBroadcastManager;


public class AddPersonDialogFragment extends DialogFragment implements DialogInterface.OnClickListener
{
    // Arguments
    private static final String ARGS_ACTIVITY_ID = "args.ACTIVITY_ID";

    public static final AddPersonDialogFragment instantiate(long activityID)
    {
        // Prepare the arguments
        Bundle args = new Bundle();
        args.putLong(ARGS_ACTIVITY_ID, activityID);

        // Create the fragment
        AddPersonDialogFragment fragment = new AddPersonDialogFragment();
        fragment.setArguments(args);

        return fragment;
    }


    private TextView mEmail;
    private TextView mName;


    public Dialog onCreateDialog(Bundle savedInstanceState)
    {
        View view = getActivity().getLayoutInflater().inflate(R.layout.fragment_add_person_dialog, null);
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.HONEYCOMB)
        {
            // Work out the display bug in devices who have black background
            view.setBackgroundColor(Color.WHITE);
        }

        mEmail = (TextView) view.findViewById(R.id.addPerson_email);
        mName = (TextView) view.findViewById(R.id.addPerson_name);

        Dialog dialog = new AlertDialog.Builder(getActivity())
                .setTitle(R.string.title_addPerson)
                .setView(view)
                .setPositiveButton(android.R.string.ok, this)
                .setNegativeButton(android.R.string.cancel, null)
                .create();
        return dialog;
    }

    @Override
    public void onClick(DialogInterface dialogInterface, int button)
    {
        switch (button)
        {
        case Dialog.BUTTON_POSITIVE:
            try
            {
                SyncBroadcastManager.setSyncState(getActivity(), "Adding person...");
                final PeopleActivity activity = (PeopleActivity) getActivity();

                String tokenId = LoginManager.getInstance(getActivity()).getTokenId();
                HttpURLConnection connection = Activity.Api.requestEnrollment(tokenId, getArguments().getLong(ARGS_ACTIVITY_ID), mName.getText().toString(), mEmail.getText().toString());

                ApiRequest.getJsonFromConnection(ApiRequestCode.ACTIVITY_REQUEST_ENROLLMENT, connection, new ApiRequest.ResponseHandler() {
                    @Override
                    public void handleResponse(int requestCode, JSONObject json, int responseCode)
                    {
                        if (responseCode == HttpStatus.SC_OK && json != null)
                        {
                            // Reload the content
                            activity.refresh();
                        }
                        else
                        {
                            activity.showToast(Utils.getBadResponseMessage(requestCode, responseCode));
                        }

                        SyncBroadcastManager.setSyncState(activity, false);
                    }
                });
            }
            catch (IOException e)
            {
                SyncBroadcastManager.setSyncState(getActivity(), false);

                Log.e(InEvent.NAME, "Couldn't create connection for activity.requestEnrollment(tokenID, activityID="+getArguments().getLong(ARGS_ACTIVITY_ID)
                		+", name="+mName.getText()+", email="+mEmail.getText()+")", e);
            }
            break;
        }
    }
}
