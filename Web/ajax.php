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

		$public = array("member", "presence");

		// Gotta see if the table can be accessed
		if (in_array($searchType, $public) == TRUE) {
			printCollectionForSearch($core->companyID, $searchText, $searchType);
		}

	} else 
	
// ------------------------------------------------------------------------------------------- //

// -------------------------------------- POWER USERS ----------------------------------------- //

	/**
	 * Print all the power users
	 */
	if (isset ($_POST['powerUsers'])) {
					
		printPowerMembers($core->companyID);

	} else 
	
	/**
	 * Add a new power user
	 */
	if (isset ($_POST['addPowerUser'])) {
					
		$memberID = getAttribute($_POST['memberID']);
		
		// A feature only available to power users
		if ($core->permission >= 10) {
			// Update the database with the new super user
			$update = resourceForQuery(
				"UPDATE
					`member`
				SET
					`member`.`permission` = 10
				WHERE 1
					AND `member`.`id` = $memberID
					AND `member`.`companyID` = $core->companyID
			");
			
			// And get his name
			$result = resourceForQuery(
				"SELECT
					`member`.`name`
				FROM
					`member`
				WHERE 1
					AND `member`.`id` = $memberID
					AND `member`.`companyID` = $core->companyID
			");
			$name = mysql_result($result, 0, "name");
			
			// So we can notify the rest of the company
			notificationSave(array(), "<b>$core->name</b> adicionou <b>$name</b> como super usuário.", "members.php");	
			
			// And we confirm the insertion
			if (!$update) http_status_code(500);
		}
		
	} else 
	
	/**
	 * Remove a power user
	 */
	if (isset ($_POST['removePowerUser'])) {
					
		$memberID = getAttribute($_POST['memberID']);
		
		// A feature only available to power users
		if ($core->permission >= 10) {
			// Update the database with the new super user
			$update = resourceForQuery(
				"UPDATE
					`member`
				SET
					`member`.`permission` = 1
				WHERE 1
					AND `member`.`id` = $memberID
					AND `member`.`companyID` = $core->companyID
			");
			
			// And we confirm the insertion
			if (!$update) http_status_code(500);

		} else {
			http_status_code(406);
		}

	} else 
	
	/**
	 * Search for power users
	 */
	if (isset ($_POST['searchPowerUsers'])) {
		
		$searchText = getAttribute($_POST["searchPowerUsers"]);

		printPowerUsersForSearch($searchText);

	} else 

// ------------------------------------------------------------------------------------------- //

// -------------------------------------- USER SETTINGS ----------------------------------------- //
	
	/**
	 * Change a user password
	 */
	if (isset ($_POST['changePassword'])) {
	
		$oldPassword = getAttribute($_POST["oldPassword"]);
		$newPassword = getAttribute($_POST["newPassword"]);
	
		// Select the user from the database
		$result = resourceForQuery(
			"SELECT
				`member`.`id`,
				`member`.`password`
			FROM
				`member`
			WHERE 1
				AND `member`.`id` = $core->memberID
				AND `member`.`companyID` = $core->companyID
		");
		
		// See if he exists
		if (mysql_num_rows ($result) != 0) {
			// Get the hash
			$hash = mysql_result($result, 0, "password");
			// Incrypt it and see if the user has sent the right old password
			if (Bcrypt::check($oldPassword, $hash)) {

				$newHash = Bcrypt::hash($newPassword);

				// If he has, we can update the database with the new password
				$update = resourceForQuery(
					"UPDATE
						`member`
					SET
						`member`.`password` = '$newHash' 
					WHERE 1
						AND `member`.`id` = $core->memberID
						AND `member`.`companyID` = $core->companyID
				");

				if (!$update) http_status_code(500);

			} else {
				http_status_code(406);	
			}
		} else {
			http_status_code(404);
		}

	} else 

// ----------------------------------------------------------------------------------- //	

	{ http_status_code(501); }

?>