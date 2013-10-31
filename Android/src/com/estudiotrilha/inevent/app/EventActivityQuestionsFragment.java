package com.estudiotrilha.inevent.app;

import java.io.IOException;
import java.net.HttpURLConnection;

import org.apache.http.HttpStatus;
import org.json.JSONObject;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.LoaderManager.LoaderCallbacks;
import android.support.v4.content.CursorLoader;
import android.support.v4.content.Loader;
import android.support.v4.widget.CursorAdapter;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.ViewAnimator;

import com.estudiotrilha.inevent.InEvent;
import com.estudiotrilha.inevent.R;
import com.estudiotrilha.inevent.Utils;
import com.estudiotrilha.inevent.content.Activity;
import com.estudiotrilha.inevent.content.ActivityQuestion;
import com.estudiotrilha.inevent.content.ApiRequest;
import com.estudiotrilha.inevent.content.ApiRequestCode;
import com.estudiotrilha.inevent.content.LoginManager;
import com.estudiotrilha.inevent.content.Member;
import com.estudiotrilha.inevent.content.SyncBroadcastManager;
import com.estudiotrilha.inevent.service.DownloaderService;


public class EventActivityQuestionsFragment extends Fragment implements LoaderCallbacks<Cursor>, View.OnClickListener, ApiRequest.ResponseHandler
{
    // Arguments
    public static final String ARGS_ACTIVITY_ID       = "args.ACTIVITY_ID";
    public static final String ARGS_ACTIVITY_APPROVED = "args.ACTIVITY_APPROVED";

    public static EventActivityQuestionsFragment instantiate(long activityID, int approved)
    {
        Bundle args = new Bundle();
        args.putLong(ARGS_ACTIVITY_ID, activityID);
        args.putInt(ARGS_ACTIVITY_APPROVED, approved);

        EventActivityQuestionsFragment fragment = new EventActivityQuestionsFragment();
        fragment.setArguments(args);

        return fragment;
    }

    // Load code
    private static final int LOAD_QUESTIONS = 0;

    // Instance State
    private static final String STATE_DOWNLOAD_ATTEMPT = "state.DOWNLOAD_ATTEMPT";


    private EditText        mNewQuestion;
    private ImageButton     mSendQuestion;
    private QuestionAdapter mAdapter;
    private int             mDownloadAttempt;

    private BroadcastReceiver mReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent)
        {
            if (intent.getAction().equals(SyncBroadcastManager.ACTION_SYNC) && !SyncBroadcastManager.isSyncing())
            {
                getLoaderManager().restartLoader(LOAD_QUESTIONS, null, EventActivityQuestionsFragment.this);
            }
        }
    };

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);

        // Init the adapter
        mAdapter = new QuestionAdapter();

        if (savedInstanceState != null)
        {
            mDownloadAttempt = savedInstanceState.getInt(STATE_DOWNLOAD_ATTEMPT);
        }
        else
        {
            refresh();
        }
    }
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        return inflater.inflate(R.layout.fragment_event_activity_questions, container, false);
    }
    @Override
    public void onViewCreated(View view, Bundle savedInstanceState)
    {
        super.onViewCreated(view, savedInstanceState);

        ListView listView = (ListView) view.findViewById(android.R.id.list);
        listView.setAdapter(mAdapter);
        setListShown(false);

        // Setup the 'send new question' things
        mSendQuestion = (ImageButton) view.findViewById(R.id.question_sendQuestion);
        mNewQuestion = (EditText) view.findViewById(R.id.question_newQuestion);
        mNewQuestion.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count)
            {
                mSendQuestion.setEnabled(s.length() > 0);
            }
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            @Override public void afterTextChanged(Editable s) {}
        });
        mNewQuestion.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event)
            {
                if (actionId == EditorInfo.IME_ACTION_SEND && mNewQuestion.getText().length() > 0)
                {
                    String tokenID = LoginManager.getInstance(getActivity()).getTokenId();
                    long activityID = getArguments().getLong(ARGS_ACTIVITY_ID);

                    sendQuestion(tokenID, activityID);
                }
                return false;
            }
        });
        mSendQuestion.setEnabled(mNewQuestion.getText().length() > 0);
        mSendQuestion.setOnClickListener(this);

        // Should display the option to send new questions?
        int approved =
                getArguments().getInt(ARGS_ACTIVITY_APPROVED) == Activity.APPROVED_OK ? 
                        View.VISIBLE : 
                        View.GONE;
        view.findViewById(R.id.question_sendContainer).setVisibility(approved);
    }
    @Override
    public void onStart()
    {
        super.onStart();
        getLoaderManager().initLoader(LOAD_QUESTIONS, null, this);
    }
    @Override
    public void onResume()
    {
        super.onResume();
        getActivity().registerReceiver(mReceiver, new IntentFilter(SyncBroadcastManager.ACTION_SYNC));
    }
    @Override
    public void onPause()
    {
        super.onPause();
        getActivity().unregisterReceiver(mReceiver);
    }

    @Override
    public void onSaveInstanceState(Bundle outState)
    {
        super.onSaveInstanceState(outState);
        outState.putInt(STATE_DOWNLOAD_ATTEMPT, mDownloadAttempt);
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater)
    {
        super.onCreateOptionsMenu(menu, inflater);
        menu.clear();
    }

    private void setListShown(boolean shown)
    {
        View view = getView();
        // Null check
        if (view != null)
        {
            ((ViewAnimator) view.findViewById(R.id.viewAnimator))
                .setDisplayedChild(
                    shown ?
                        (mAdapter.isEmpty() ?
                            Utils.VIEW_ANIMATOR_MESSAGE :
                            Utils.VIEW_ANIMATOR_CONTENT) :
                        Utils.VIEW_ANIMATOR_LOADING
                );
        }
    }


    private void refresh()
    {
        DownloaderService.downloadEventActivityQuestions(getActivity(), getArguments().getLong(ARGS_ACTIVITY_ID));
    }


    @Override
    public void onClick(View v)
    {
        String tokenID = LoginManager.getInstance(getActivity()).getTokenId();
        long activityID = getArguments().getLong(ARGS_ACTIVITY_ID);

        switch (v.getId())
        {
        case R.id.question_sendQuestion:
            sendQuestion(tokenID, activityID);
            break;

        case R.id.question_votes:
            try
            {
                long questionID = (Long) v.getTag();

                // Create the connection
                HttpURLConnection connection = Activity.Api.upvoteQuestion(tokenID, questionID);

                // Send the api request
                ApiRequest.getJsonFromConnection(ApiRequestCode.ACTIVITY_UPVOTE_QUESTION, connection, this);
            }
            catch (IOException e)
            {
                Log.e(InEvent.NAME, "Error creating connection for " +
                        "activity.upvoteQuestion(tokenID, questionID="+v.getTag()+")", e);
            }
            break;
        }
    }

    private void sendQuestion(String tokenID, long activityID)
    {
        try
        {
            // Create the connection
            HttpURLConnection connection = Activity.Api.sendQuestion(tokenID, activityID);
            String post = Activity.Api.Post.sendQuestion(mNewQuestion.getText().toString().trim());

            // Send the api request
            ApiRequest.getJsonFromConnection(ApiRequestCode.ACTIVITY_SEND_QUESTION, connection, this, post);
        }
        catch (IOException e)
        {
            Log.e(InEvent.NAME, "Error creating connection for " +
                    "activity.sendQuestion(tokenID, activityID="+activityID+", question="+mNewQuestion.getText()+")", e);
        }
    }


    @Override
    public void handleResponse(int requestCode, JSONObject json, int responseCode)
    {
        if (responseCode == HttpStatus.SC_OK && json != null)
        {
            switch (requestCode)
            {
            case ApiRequestCode.ACTIVITY_SEND_QUESTION:
                // Clear the text field
                mNewQuestion.setText("");
            case ApiRequestCode.ACTIVITY_UPVOTE_QUESTION:
                // refresh the question list
                refresh();
                break;
            }
        }
        else
        {
            ((BaseActivity) getActivity()).showToast(Utils.getBadResponseMessage(requestCode, responseCode));
        }
    }


    @Override
    public Loader<Cursor> onCreateLoader(int code, Bundle args)
    {
        Uri uri = ActivityQuestion.CONTENT_URI;
        String[] projection = ActivityQuestion.Columns.PROJECTION_LIST;
        String selection = ActivityQuestion.Columns.ACTIVITY_ID_FULL+"="+getArguments().getLong(ARGS_ACTIVITY_ID);
        String[] selectionArgs = null;
        String sortOrder = ActivityQuestion.Columns.VOTES_FULL + " DESC";

        return new CursorLoader(getActivity(), uri, projection, selection, selectionArgs, sortOrder);
    }
    @Override
    public void onLoadFinished(Loader<Cursor> loader, Cursor data)
    {
        mAdapter.swapCursor(data);

        if (mAdapter.isEmpty() && Utils.checkConnectivity(getActivity()) && mDownloadAttempt < 1)
        {
            mDownloadAttempt++;
            refresh();
        }
        else
        {
            setListShown(true);
        }
    }
    @Override
    public void onLoaderReset(Loader<Cursor> loader)
    {
        mAdapter.swapCursor(null);
    }


    class QuestionAdapter extends CursorAdapter
    {
        private LayoutInflater mInflater;

        private int mIndexText;
        private int mIndexVotes;
        private int mIndexUpvoted;
        private int mIndexMemberId;
        private int mIndexMemberName;


        public QuestionAdapter()
        {
            super(getActivity(), null, 0);
            mInflater = getActivity().getLayoutInflater();
        }

        @Override
        public int getCount()
        {
            int i = super.getCount();
            System.out.println("Size = "+i);
            return i;
        }
        @Override
        public Cursor swapCursor(Cursor newCursor)
        {
            Cursor cursor = super.swapCursor(newCursor);
            if (newCursor != null)
            {
                mIndexText = newCursor.getColumnIndex(ActivityQuestion.Columns.TEXT);
                mIndexVotes = newCursor.getColumnIndex(ActivityQuestion.Columns.VOTES);
                mIndexUpvoted = newCursor.getColumnIndex(ActivityQuestion.Columns.UPVOTED);
                mIndexMemberId = newCursor.getColumnIndex(ActivityQuestion.Columns.MEMBER_ID);
                mIndexMemberName = newCursor.getColumnIndex(Member.Columns.NAME);
            }

            return cursor;
        }

        @Override
        public void bindView(View v, Context context, Cursor c)
        {
            // Setup the view
            // Question text
            ((TextView) v.findViewById(R.id.question_text)).setText(c.getString(mIndexText));

            // Question owner
            ((TextView) v.findViewById(R.id.question_owner)).setText(c.getString(mIndexMemberName));

            // Vote count
            TextView voteView = (TextView) v.findViewById(R.id.question_votes);
            int voteAmount = c.getInt(mIndexVotes);
            voteView.setText(voteAmount > 0 ? Integer.toString(voteAmount) : "");

            if (LoginManager.getInstance(context).isSignedIn())
            {
                boolean voted = c.getInt(mIndexUpvoted) == 1;
    
                // Vote image
                int image = (voted ? R.drawable.ic_question_upvote_voted : R.drawable.ic_question_upvote_normal);
                voteView.setCompoundDrawablesWithIntrinsicBounds(0, image, 0, 0);

                // Add the id to it
                voteView.setTag(getItemId(c.getPosition()));
                // and the upvote callback
                voteView.setOnClickListener(EventActivityQuestionsFragment.this);
            }
            else
            {
                voteView.setOnClickListener(null);
            }
        }

        @Override
        public View newView(Context context, Cursor c, ViewGroup container)
        {
            return mInflater.inflate(R.layout.cell_question, container, false);
        }

        public boolean isUserQuestion(int position)
        {
            LoginManager loginManager = LoginManager.getInstance(getActivity());
            if (mCursor.moveToPosition(position) && loginManager.isSignedIn())
            {
                long userID = loginManager.getMember().memberId;

                return mCursor.getLong(mIndexMemberId) == userID;
            }
            return false;
        }
    }
}
