package com.estudiotrilha.inevent.content;


public interface ApiRequestCode
{
    public static final int MEMBER_SIGN_IN               =  0;
    public static final int MEMBER_SIGN_IN_WITH_FACEBOOK =  1;
    public static final int MEMBER_SIGN_UP               =  2;
    public static final int MEMBER_GET_EVENTS            =  3;

    public static final int EVENT_REQUEST_ENROLLMENT     = 10;
    public static final int EVENT_GET_OPINION            = 11;
    public static final int EVENT_SEND_OPINION           = 12;

    public static final int ACTIVITY_REQUEST_ENROLLMENT  = 20;
    public static final int ACTIVITY_DISMISS_ENROLLMENT  = 21;
    public static final int ACTIVITY_CONFIRM_ENTRANCE    = 22;
    public static final int ACTIVITY_REVOKE_ENTRANCE     = 23;
    public static final int ACTIVITY_SEND_OPINION        = 24;
    public static final int ACTIVITY_GET_OPINION         = 25;
    public static final int ACTIVITY_SEND_QUESTION       = 26;
    public static final int ACTIVITY_GET_QUESTIONS       = 27;
    public static final int ACTIVITY_UPVOTE_QUESTION     = 28;
}
