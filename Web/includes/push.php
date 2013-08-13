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
        "X-Parse-Application-Id: 7ivHXgEjQsWGz9fiZ9PcvMsCXgq2KdK6a3oyUbuV",
        "X-Parse-REST-API-Key: JnankyhpAsnyWt9AoIn3j5Vn38cRbfOwGXFiB6zC",
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
    if ($channel != "company") pushURI($uri, "company", $core->companyID, $value);

    $data = array(
        "channels" => array($channel . "/" . $channelID),
        "data" => array(
            "alert" => array(
                "body" => null
            ),
            "action" => "com.estudiotrilha.garca.PUSH_NOTIFICATION",
            // "sound" => null,
            "uri" => "$uri",
            "value" => "$value"
        )
    );

    // Push the notification
    pushNotification($data);
}

// Pages
include_once("push/carte.php");
include_once("push/order.php");
include_once("push/table.php");

?>