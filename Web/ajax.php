<?php include_once("includes/check/login.php"); ?>
<?php

		if (!$core->auth) logout();
	
	// Lembre-se de fazer decode do array recebido pelo jquery

// -------------------------------------- NOTIFICATION --------------------------------------- //

	/**
	 * Check for notifications
	 */
	if (isset ($_POST['checkNotifications'])) {

		$lastNotificationID = getAttribute($_POST['checkNotifications']);

		$count = notificationCountForMemberID($core->memberID);
		
		// See if we have any notification
		if ($count > 0) {
			// Get the last notificationID
			if ($lastNotificationID == 0) {
				// Without a reference, we load the last 10 notifications
				echo notificationsForMemberIDWithOffset($core->memberID, 10);
			} else {
				// Load all the notification since the one provided by the client
				echo notificationsForMemberIDSinceNotification($core->memberID, $notificationID);
			}

		} else {
			// This code is doubled, and that is because we have to run it really fast
			echo json_encode(array("data" => array()));
		}

	} else 
	
	/**
	 * Get notification data
	 */
	if (isset ($_POST['userNotifications'])) {
				
		echo notificationsForMemberIDWithOffset($core->memberID, 10);
		
	} else 
	
	/**
	 * Get extra notification data with increments
	 */
	if (isset ($_POST['notificationLoadExtra']) && isset ($_POST['value'])) {
	
		$offset = getAttribute($_POST['value']);
				
		echo notificationsForMemberIDWithOffset($core->memberID, $offset);

	} else 
	
	/**
	 * Set notifications (single or group) as seen
	 * If $clean is true, we will set everything up to the given notification as seen
	 * If $clean is false, only the given notification will be set as seen
	 */
	if (isset ($_POST['updateNotificationStatus']) && isset ($_POST['value']) && isset ($_POST['clean'])) {
				
		$notificationID = getAttribute($_POST['value']);
		$clean = boolval(getAttribute($_POST['clean']));

		if ($clean) {
			echo notificationUpdateStatusSinceID($notificationID);	
		} else {
			echo notificationUpdateStatusForID($notificationID);
		}

	} else 
	
// ------------------------------------------------------------------------------------------- //

// -------------------------------------- COLLECTION ----------------------------------------- //

	/**
	 * Search for elements inside the given collection
	 */
	if (isset ($_POST['searchQuery'])) {
				
		$searchType = getAttribute($_POST['searchQuery']);
		$searchText = getAttribute($_POST['searchText']);

		$public = array("event", "activity");

		// Gotta see if the table can be accessed
		if (in_array($searchType, $public) == TRUE) {
			printCollectionForSearch($core->eventID, $searchText, $searchType);
		}

	} else

// ----------------------------------------------------------------------------------- //	

	{ http_status_code(501); }

?>