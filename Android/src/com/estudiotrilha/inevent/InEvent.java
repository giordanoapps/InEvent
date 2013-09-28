package com.estudiotrilha.inevent;


public class InEvent
{
    public static final boolean DEBUG = true;

    public static final String NAME = InEvent.class.getSimpleName();

    public static final String ACTION_TOAST_NOTIFICATION = InEvent.class.getPackage().getName()+".action.TOAST_NOTIFICATION";
    public static final String EXTRA_TOAST_MESSAGE       = InEvent.class.getPackage().getName()+".extra.TOAST_MESSAGE";
}
