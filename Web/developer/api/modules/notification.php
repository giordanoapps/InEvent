<?php
// -------------------------------------- NOTIFICAÇÃO --------------------------------------- //

	/**
	 * Number of notifications
	 * @var string
	 */	
	if ($method === "getNumberOfNotifications") {

		$tokenID = getToken();

		echo notificationCountForID($core->mapID);
		
	} else

	/**
	 * Get notifications
	 * @var string
	 */
	if ($method === "getNotifications") {

		$tokenID = getToken();

		echo json_encode(notificationsForID($core->mapID));
		
	} else 

	/**
	 * Get notifications since notification
	 * @var string
	 */
	if ($method === "getNotificationsSinceNotification") {

		$tokenID = getToken();

		if (isset ($_GET['lastNotificationID'])) {
			$lastNotificationID = getAttribute($_GET['lastNotificationID']);
					
			echo json_encode(notificationsForIDSinceNotification($core->mapID, $lastNotificationID));
		} else {
			http_status_code(400);
		}

	} else 

	/**
	 * Get the id of the last notification
	 * @var string
	 */
	if ($method === "getLastNotificationID") {

		$tokenID = getToken();

		$query = " LIMIT 1 ";

        $result = resourceForQuery(getNotificationsForMapQueryText($core->mapID, '', $query));

		echo printInformation("notification", $result, true, "json");

	} else 

	/**
	 * Get notifications within time
	 * @var string
	 */
	if ($method === "getNotificationsWithinTime") {

		$tokenID = getToken();

		if (isset ($_GET['seconds'])) {
			$seconds = getAttribute($_GET['seconds']);
					
			echo notificationsForIDWithDelay($core->mapID, $seconds);
		} else {
			http_status_code(400);
		}

	} else

	/**
	 * Get single notification
	 * @var string
	 */
	if ($method === "getSingleNotification") {

		$tokenID = getToken();

		if (isset ($_GET['notificationID'])) {
			$notificationID = getAttribute($_GET['notificationID']);
					
			echo notificationsForNotificationID($core->mapID, $notificationID);
		} else {
			http_status_code(400);
		}

	} else
	
	{ http_status_code(501); }


// ------------------------------------------------------------------------------------------- //
?>