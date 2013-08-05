<?php

	/**
	 * Notification getters, wrappers and loaders
	 */
	
	/**
	 * Generic method for generating all notifications as JSON objects
	 * @param  [object] $result resource
	 * @return [object] JSON
	 */
	function printNotifications($result) {
		$notificationText["count"] = 0;
		$notificationText["data"] = array();
		
		$statusCount = 0;
		
		for ($i = 0; $i < mysql_num_rows($result); $i++) {
			$notificationText["data"][$i] = array(
				"id" => mysql_result($result, $i, "id"), 
				"action" => mysql_result($result, $i, "action"),
				"url" => mysql_result($result, $i, "url"),
				"status" => mysql_result($result, $i, "status")
			);
			
			// And we count how many notifications have not been seen yet
			if (mysql_result($result, $i, "status") == 0) {
				$statusCount++;
			}
		}
		
		$notificationText["count"] = $statusCount;
		
		return json_encode($notificationText);
	}

	/**
	 * Number of notifications
	 * @param  [int] $memberID 	memberID
	 * @return [int] number of notifications
	 */
	function notificationCountForMemberID($memberID) {

		$result = resourceForQuery(
			"SELECT
				COUNT(`notificationMember`.`id`) AS `count`
			FROM
				`notificationMember`
			WHERE
				`notificationMember`.`memberID` = $memberID
		");

	 	// We just return the result
		return mysql_result($result, 0, "count");
	}
	
	/**
	 * Get notifications with delay
	 * @param  [int] 	$memberID 		memberID
	 * @param  [int] 	$seconds 		seconds since delay
	 * @return [object] JSON
	 */
	function notificationGetLastNotificationForMemberID($memberID) {
		
		$notificationDate = date(DATE_ATOM);
		
		// So we gotta search for any notifications the user had in the last specified time and still hasn't seen them
		$result = resourceForQuery(
			"SELECT
				`notificationMember`.`id`,
				`notificationMember`.`action`,
				`notificationMember`.`url`,
				`notificationMember`.`status`
			FROM
				`notificationMember`
			WHERE 1
				AND `notificationMember`.`memberID` = '$memberID'
				AND `notificationMember`.`date` >= DATE_ADD('$notificationDate', INTERVAL -'".($seconds)."' SECOND)
		");

		return printNotifications($result);
	}
	
	/**
	 * Get notifications since another notification
	 * @param  [int] 	$memberID 				memberID
	 * @param  [int] 	$notificationID 		another notification id
	 * @return [object] JSON
	 */
	function notificationsForMemberIDSinceNotification($memberID, $notificationID) {
		// Secondly we get the last 10 results from the database and append to the tail
		$result = resourceForQuery(
			"SELECT
				`notificationMember`.`id`,
				`notificationMember`.`action`,
				`notificationMember`.`url`,
				`notificationMember`.`status`
			FROM
				`notificationMember`
			WHERE 1
				AND `notificationMember`.`id` >= $notificationID
				AND `notificationMember`.`memberID` = $memberID
			ORDER BY
				`notificationMember`.`id` DESC
			LIMIT 0, 100
		");

		return printNotifications($result);
	}
	
	/**
	 * Get notifications with offset
	 * @param  [int] 	$memberID 		memberID
	 * @param  [int] 	$offset 		number of notifications to limit
	 * @return [object] JSON
	 */
	function notificationsForMemberIDWithOffset($memberID, $offset = 0) {
		// Secondly we get the last 10 results from the database and append to the tail
		$result = resourceForQuery(
			"SELECT
				`notificationMember`.`id`,
				`notificationMember`.`action`,
				`notificationMember`.`url`,
				`notificationMember`.`status`
			FROM
				`notificationMember`
			WHERE 1
				AND `notificationMember`.`memberID` = $memberID
			ORDER BY
				`notificationMember`.`id` DESC
			LIMIT " .$offset. "," .($offset + 9). "
		");

		return printNotifications($result);
	}
	
	/**
	 * Get single notification
	 * @param  [int] 	$memberID 				memberID
	 * @param  [int] 	$notificationID 		single notification
	 * @return [object] JSON
	 */
	function notificationForNotificationID($memberID, $notificationID) {
		$result = resourceForQuery(
			"SELECT
				`notificationMember`.`id`,
				`notificationMember`.`action`,
				`notificationMember`.`url`,
				`notificationMember`.`status`
			FROM
				`notificationMember`
			WHERE 1
				AND `notificationMember`.`memberID` = $memberID
				AND `notificationMember`.`id` = $notificationID
		");

		return printNotifications($result);
	}
	
	/**
	 * Save a brand new notification
	 * @param  [int, array, string] $notifyMember        	Members that will be notified
	 * @param  [string] 			$notificationMessage 	Notification message
	 * @param  [string] 			$notificationUrl     	Notification url, destiny
	 * @return [null]                     
	 */
	function notificationSave($notifyMember, $notificationMessage, $notificationUrl) {
		// We get the date
		$notificationDate = date(DATE_ATOM);

		// Core singleton
		$core = Core::singleton();
		
		// See if the notification has a destination (user or group) or if it is a general one (must be sent to everyone)
		
		// For groups
		if (is_int($notifyMember)) {
		
			// Get the user information from the database
			$result = resourceForQuery(
				"SELECT
					`member`.`id`
				FROM
					`member`
				WHERE
					AND `member`.`companyID` = $core->companyID
					AND `member`.`groupID` = $notifyMember
				ORDER BY
					`member`.`name`
			");
			
			for ($i = 0; $i < mysql_num_rows($result); $i++) {
				$memberID = mysql_result($result, $i, "id");
				
				// Add the notification
				$insert = resourceForQuery(
					"INSERT INTO
						`notificationMember`
						(`memberID`, `action`, `url`, `date`, `status`)
					SELECT
						`member`.`id`,
						'$notificationMessage',
						'$notificationUrl',
						'$notificationDate',
						0
					FROM
						`member`
					WHERE
						AND `member`.`companyID` = $core->companyID
						AND `member`.`groupID` = $notifyMember
					ORDER BY
						`member`.`name`
				");
				
				// And update the count
				// resourceForQuery(
				// 	"UPDATE
				// 		`notificationCount`
				// 	SET
				// 		`notificationCount`.`count` = `notificationCount`.`count` + 1
				// 	WHERE
				// 		`notificationCount`.`memberID` = $memberID
				// ");
			}
			
		// For member
		} elseif (count($notifyMember) > 0) {
			// And just write the data into the database
			for ($i = 0; $i < count($notifyMember); $i++) {

				// Add the notification
				$insert = resourceForQuery(
					"INSERT INTO
						`notificationMember`
						(`memberID`, `action`, `url`, `date`, `status`)
					VALUES 
						($notifyMember[$i], '$notificationMessage', '$notificationUrl', '$notificationDate', 0)
				");
				
				// And update the count
				// resourceForQuery(
				// 	"UPDATE
				// 		`notificationCount`
				// 	SET
				// 		`notificationCount`.`count` = `notificationCount`.`count` + 1
				// 	WHERE
				// 		`notificationCount`.`memberID` = $notifyMember[$i]
				// ");
			}
		// For everyone else
		} else {
			
			// Add the notification
			$insert = resourceForQuery(
				"INSERT INTO
					`notificationMember`
					(`memberID`, `action`, `url`, `date`, `status`)
				SELECT
					`member`.`id`,
					'$notificationMessage',
					'$notificationUrl',
					'$notificationDate',
					0
				FROM
					`member`
				WHERE
					`member`.`companyID` = $core->companyID
				ORDER BY
					`member`.`name`
			");

		}
	}

	/**
	 * Update notification status (seen or unseen) on the given notification id
	 * @param  [int] $notificationID 	notificationID
	 * @return [null] 
	 */
	function notificationUpdateStatusForID($notificationID) {
		$update = resourceForQuery(
			"UPDATE
				`notificationMember`
			SET
				`notificationMember`.`status` = 1
			WHERE
				`notificationMember`.`id` = $notificationID
		");

		return $update;
	}

	/**
	 * Update notification status (seen or unseen) since the given notification id
	 * @param  [int] $notificationID 	notificationID
	 * @return [null] 
	 */
	function notificationUpdateStatusSinceID($notificationID) {
		$update = resourceForQuery(
			"UPDATE
				`notificationMember`
			SET
				`notificationMember`.`status` = 1
			WHERE
				`notificationMember`.`id` <= $notificationID
		");

		return $update;
	}
?>