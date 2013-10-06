<?php

/**
 * Fetch data from the database and wrap them with html
 */

function pushNotification($data) {

    $ch = curl_init();

    // set URL and other appropriate options
    curl_setopt($ch, CURLOPT_URL, "https://api.parse.com/1/push");
    curl_setopt($ch, CURLOPT_POST, 1);
    // curl_setopt($ch, CURLOPT_HEADER, 1);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array(
        "X-Parse-Application-Id: GVhc1mnm0Zi2b7RxOZ8jFNbqhYQIE59sYxfKSlyE",
        "X-Parse-REST-API-Key: majWJZdGB0t1EFVrRU8PR1t5w57nlB8AKtmiUMun",
        "Content-Type: application/json"
    ));
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));

    // grab URL and pass it to the browser
    curl_exec($ch);

    // close cURL resource, and free up system resources
    curl_close($ch); 
}

function pushURI($uri, $channel, $channelID, $value) {

    // Get the singleton
    $core = Core::singleton();

    // Extract the channel from the uri
    if ($channel == null) $channel = substr($uri, 0, strpos($uri, "/"));

    // Send a update to our global channel, company
    if ($channel != "event") pushURI($uri, "event", $core->eventID, $value);

    $data = array(
        "channels" => array($channel . "_" . $channelID),
        "data" => array(
            "alert" => array(
                "body" => null
            ),
            "action" => "com.estudiotrilha.inevent.PUSH_NOTIFICATION",
            // "sound" => null,
            "uri" => "$uri",
            "value" => "$value"
        )
    );

    // Push the notification
    pushNotification($data);
}

// Pages
include_once("push/activity.php");
include_once("push/event.php");

?>