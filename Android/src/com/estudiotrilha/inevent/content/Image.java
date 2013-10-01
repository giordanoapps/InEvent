package com.estudiotrilha.inevent.content;

public class Image
{
    private static final String BASE_URL = "http://inevent.us/";

    public static String getImageLink(final String name)
    {
        if (name == null || name.trim().length() == 0) return null;
        return Image.BASE_URL + name;
    }
}
