package com.estudiotrilha.inevent.app;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.view.View;
import android.widget.RatingBar;

import com.estudiotrilha.inevent.R;


public abstract class RatingDialogFragment extends DialogFragment implements DialogInterface.OnClickListener
{
    private RatingBar mRatingBar;


    public Dialog onCreateDialog(Bundle savedInstanceState)
    {
        View view = getActivity().getLayoutInflater().inflate(R.layout.fragment_rating_dialog, null);
        mRatingBar = (RatingBar) view.findViewById(R.id.activity_rating);
        Dialog dialog = new AlertDialog.Builder(getActivity())
                .setTitle(getTitle())
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
            onSendOpinion();
            break;
        }
    }

    public RatingBar getRatingBar()
    {
        return mRatingBar;
    }

    protected abstract void onSendOpinion();

    protected abstract int getTitle();
}
