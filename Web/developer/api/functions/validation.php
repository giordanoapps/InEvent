<?php

    /**
     * Get and validate the token from the client
     * @return string the desired token, loaded and validated
     */
	function getToken($eventID = 0) {

		// Get the singleton
		$core = Core::singleton();

		// We make sure the user has provided it, otherwise we can already deny the request
		if (isset($_REQUEST['tokenID'])) {
			$hash = isset($_GET["tokenID"]) ? getAttribute($_GET["tokenID"]) : getAttribute($_REQUEST["tokenID"]);
			$remote = $_SERVER['REMOTE_ADDR'];

			$result = resourceForQuery(
				"SELECT
					`member`.`id`,
					`member`.`name`
				FROM
					`member`
				LEFT JOIN
					`memberSessions` ON `memberSessions`.`memberID` = `member`.`id`
				WHERE
					`memberSessions`.`sessionKey` = '$hash'
			");

			if (mysql_num_rows($result) > 0) {
				// Set the initial information of the member
				$core->auth = true;

				$core->name = mysql_result($result, 0, "name");
				$core->memberID = mysql_result($result, 0, "id");

				// Reset the login count
				$update = resourceForQuery(
					"UPDATE
						`loginAttempts`
					SET
						`loginAttempts`.`attempts` = 0,
						`loginAttempts`.`date` = NOW()
					WHERE
						`loginAttempts`.`remote` = INET_ATON('$remote')
				");

				if ($update) {
					
					// Validate the event
					validateEvent($eventID);

					// If everything went by smoothly, we can return the tokenID
					return $hash;
				} else {
					http_status_code(500);
				}

			} else {
				// If the tokenID hasn't been found, we just deny the request
				http_status_code(401);
			}
		} else {
			http_status_code(401);
		}
	}

	/**
     * Get activityID and suggest a company to be set
     * @return activityID  id of person
     */
	function getTokenForActivity() {

		if (isset ($_GET['activityID'])) {
			$activityID = getAttribute($_GET['activityID']);

			// Find the company where the the current member is sit (or standing up)
			$result = resourceForQuery(
				"SELECT
					`activity`.`eventID`
				FROM
					`activity`
				WHERE 1
					AND `activity`.`id` = $activityID
			");

			if (mysql_num_rows($result) > 0) {
				// Load the token using the company as reference
				getToken(mysql_result($result, 0, "eventID"));

				// Return the table
				return $activityID;

			} else {
				http_status_code(303);
			}
		} else {
			http_status_code(400);
		}
	}

	/**
	 * Process the log in using the $_GET and $_POST
	 * @param  [string] $email     email of the person
	 * @param  [string] $password password of the person
	 * @return object  json encoded object
	 */
	function processLogIn($email, $password) {

		// Get the singleton
		$core = Core::singleton();

		$remote = $_SERVER['REMOTE_ADDR'];

		// Run our query to get the previous attempts
		include_once(__DIR__ . "/../../../includes/check/security.php");

		$result = resourceForQuery(
		// echo (
			"SELECT
				`member`.`id`,
				`member`.`name`,
				`member`.`password`,
				COUNT(`memberSessions`.`id`) - SUM(`memberSessions`.`browser`) AS `sessionAmount`
			FROM
				`member`
			LEFT JOIN
				`memberSessions` ON `memberSessions`.`memberID` = `member`.`id`
			WHERE 1
				AND BINARY `member`.`email` = '$email'
			GROUP BY
				`memberSessions`.`memberID`
		");
	
		if (mysql_num_rows($result) == 1) {
			
			$hash = mysql_result($result, 0, "password");

			if (Bcrypt::check($password, $hash)) {

				$core->name = mysql_result($result, 0, "name");
				$core->memberID = mysql_result($result, 0, "id");

				// Create a unique random id for the given session
				do {
					$sessionKey = Bcrypt::hash($hash);
					$resultSession = resourceForQuery(
						"SELECT
							`memberSessions`.`id`
						FROM
							`memberSessions`
						WHERE
							`memberSessions`.`sessionKey` = '$sessionKey'
					");

				} while (mysql_num_rows($resultSession) != 0);

				// Store it on our database
				$insert = resourceForQuery(
					"INSERT INTO
						`memberSessions`
						(`memberID`, `browser`, `sessionKey`)
					VALUES
						($core->memberID, 0, '$sessionKey')
				");
				
				// Remove the last session if the member went above the limit
				if (mysql_result($result, 0, "sessionAmount") > 5) {
					// Remove the last sessionKey from the database
					$delete = resourceForQuery(
						"DELETE FROM
							`memberSessions`
						WHERE 1
							AND `memberSessions`.`memberID` = $core->memberID
						ORDER BY
							`memberSessions`.`id` ASC
						LIMIT 1
					");
				}

				// Only authenticate if the insertion was carried correctly
				if ($insert) {
					$core->auth = true;

					// Reset the login count
					$insert = resourceForQuery(
						"UPDATE
							`loginAttempts`
						SET
							`loginAttempts`.`attempts` = 0,
							`loginAttempts`.`date` = NOW()
						WHERE
							`loginAttempts`.`remote` = INET_ATON('$security->remote')
					");

					$events = getMemberEvents($core->memberID);

					// Return some information
					$data["name"] = $core->name;
					$data["memberID"] = $core->memberID;
					$data["events"] = $events["data"];
					$data["tokenID"] = $sessionKey;
					
					return $data;
				} else {
					http_status_code(500);
				}
			} else {
				resourceForQuery(
					"UPDATE
						`loginAttempts`
					SET
						`loginAttempts`.`attempts` = `attempts`+1,
						`loginAttempts`.`date` = NOW()
					WHERE
						`loginAttempts`.`remote` = INET_ATON('$remote')
				");

				http_status_code(401);
			}
		} else {
			resourceForQuery(
				"UPDATE
					`loginAttempts`
				SET
					`loginAttempts`.`attempts` = `attempts`+1,
					`loginAttempts`.`date` = NOW()
				WHERE
					`loginAttempts`.`remote` = INET_ATON('$remote')
			");

			http_status_code(401);
		}	
	}

?>