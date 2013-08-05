<?php
// -------------------------------------- NOTIFICATIONS --------------------------------------- //
	
	/**
	 * Number of notifications
	 * @var string
	 */	
	if ($method === "getNumberOfNotifications") {

		echo notificationCountForMemberID($core->memberID);
		
	} else

	if ($method === "getLastNotificationID") {

		echo notificationGetLastNotificationForMemberID($core->memberID);
		
	} else
	
	/**
	 * Get new notifications since notification
	 * @var string
	 */
	if ($method === "getNotificationsSinceNotification") {
		if (isset ($_GET['lastNotificationID'])) {
			$lastNotificationID = getAttribute($_GET['lastNotificationID']);
					
			echo notificationsForMemberIDSinceNotification($core->memberID, $lastNotificationID);
		} else {
			http_status_code(400);
		}

	} else
	
	/**
	 * Get notifications with offset
	 * @var string
	 */
	if ($method === "getNotificationsWithOffset") {
		if (isset ($_GET['offset'])) {
			$offset = getAttribute($_GET['offset']);
					
			echo notificationsForMemberIDWithOffset($core->memberID, $offset);
		} else {
			http_status_code(400);
		}

	} else
			
	/**
	 * Get single notification
	 * @var string
	 */
	if ($method === "getSingleNotification") {
		if (isset ($_GET['notificationID'])) {
			$notificationID = getAttribute($_GET['notificationID']);
					
			echo notificationForNotificationID($core->memberID, $notificationID);
		} else {
			http_status_code(400);
		}

	} else		

{ http_status_code(501); }
	
// ------------------------------------------------------------------------------------------- //
?>