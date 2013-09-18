<?php
// -------------------------------------- EVENT --------------------------------------- //
	
	if ($method === "getEvents") {

		if (isset($_GET['tokenID'])) {
			$tokenID = getToken();
			$result = getEventsForMemberQuery($core->memberID, false);
		} else {
			$result = getEventsForMemberQuery(0, false);
		}

		echo printInformation("event", $result, true, 'json');

	} else

	if ($method === "requestEnrollment") {

		$eventID = getTokenForEvent();

		if (isset($_GET['name']) && $_GET['name'] != "null" && isset($_GET['email']) && $_GET['email'] != "null") {

			if ($core->workAtEvent) {

				$name = getAttribute($_GET['name']);
				$email = getAttribute($_GET['email']);

				$result = resourceForQuery(
					"SELECT
						`member`.`id`
					FROM
						`member`
					WHERE 1
						AND BINARY `member`.`email` = '$email'
				");

				if (mysql_num_rows($result) > 0) {
					$personID = mysql_result($result, 0, "id");
				} else {
					$personID = createMember($name, md5((string)rand()), $email);
				}

			} else {
				http_status_code(401, "Person doesn't work at event");
			}
		} else {
			$personID = $core->memberID;
		}

		if ($personID != 0 && eventExists($eventID)) {

			$result = resourceForQuery(
				"SELECT
					`eventMember`.`id`
				FROM
					`eventMember`
				WHERE 1
					AND `eventMember`.`eventID` = $eventID
					AND `eventMember`.`memberID` = $personID
			");

			if (mysql_num_rows($result) == 0) {
				// Insert the person on the event
				$insert = resourceForQuery(
					"INSERT INTO
						`eventMember`
						(`eventID`, `memberID`, `roleID`, `approved`)
					VALUES
						($eventID, $personID, @(ROLE_ATTENDEE), 1)
				");

				// Insert all the activities that are general
				$insert = resourceForQuery(
				// echo (
					"INSERT INTO
						`activityMember`
						(`activityID`, `memberID`, `approved`, `present`)
					SELECT
						`activity`.`id`,
						$personID,
						1,
						0
					FROM
						`activity`
					WHERE 1
						AND `activity`.`general` = 1
						AND `activity`.`eventID` = $eventID
				");

				if ($insert) {
					// Return its data
					if ($format == "json") {
						$data["eventID"] = $eventID;
						echo json_encode($data);
					} elseif ($format == "html") {

					} else {
						http_status_code(405, "this format is not available");
					}
				} else {
					http_status_code(500, "row insertion has failed");
				}
			} else {
				http_status_code(303, "The personID is already enrolled on this event");
			}
		} else {
			http_status_code(400, "The asserted personID is null or the eventID doesn't exist");
		}
		
	} else

	if ($method === "dismissEnrollment") {

		$eventID = getTokenForEvent();

		if (isset($_GET['personID']) && $_GET['personID'] != "null") {

			if ($core->workAtEvent) {
				$personID = getAttribute($_GET['personID']);
			} else {
				http_status_code(401, "Person doesn't work at event");
			}

		} else {
			$personID = $core->memberID;
		}

		if ($personID != 0) {

			// Remove from event
			$delete = resourceForQuery(
				"DELETE FROM
					`eventMember`
				WHERE 1
					AND `eventMember`.`eventID` = $eventID
					AND `eventMember`.`memberID` = $personID
			");

			// Remove from activities
			$delete = resourceForQuery(
				"DELETE
					`activityMember`.*
				FROM
					`activityMember`
				INNER JOIN
					`activity` ON `activity`.`id` = `activityMember`.`activityID`
				WHERE 1
					AND `activity`.`eventID` = $eventID
					AND `activityMember`.`memberID` = $personID
			");
			
			if ($delete) {
				// Return its data
				if ($format == "json") {
					$data["activityID"] = $activityID;
					echo json_encode($data);
				} elseif ($format == "html") {

				} else {
					http_status_code(405, "this format is not available");
				}
			} else {
				http_status_code(500, "row deletion has failed");
			}
		} else {
			http_status_code(400, "personID cannot be null");
		}
		
	} else

	if ($method === "grantPermission" || $method === "revokePermission") {

		$eventID = getTokenForEvent();

		if (isset($_GET["personID"])) {

			// Get some properties
			$personID = getAttribute($_GET['personID']);

			if ($core->workAtEvent) {

				// See which field we want to update
				$attribute = ($method === "grantPermission") ? ROLE_COORDINATOR : ROLE_ATTENDEE;

				// Update based on the attribute
				$update = resourceForQuery(
					"UPDATE
						`eventMember`
					SET
						`eventMember`.`roleID` = $attribute
					WHERE 1
						AND `eventMember`.`eventID` = $eventID
						AND `eventMember`.`memberID` = $personID
				");

				if (mysql_affected_rows() > 0) {
					// Return its data
					if ($format == "json") {
						$data["eventID"] = $eventID;
						echo json_encode($data);
					} elseif ($format == "html") {
						$data["eventID"] = $eventID;
						echo json_encode($data);
					} else {
						http_status_code(405, "this format is not available");
					}
				} else {
					http_status_code(500, "row insertion has failed");
				}
			} else {
				http_status_code(401, "Person doesn't work at event");
			}
		} else {
			http_status_code(400, "personID is a required parameter");
		}
		
	} else

	if ($method === "getPeople") {

		$eventID = getTokenForEvent();

		if (isset($_GET["selection"])) {

			// Get some properties
			$selection = getAttribute($_GET['selection']);

			switch ($selection) {
				case 'approved':
					$complement = "AND `eventMember`.`approved` = 1";
					break;

				case 'denied':
					$complement = "AND `eventMember`.`approved` = 0";
					break;

				case 'unseen':
					$complement = "AND `eventMember`.`id` = 0"; // Don't need to implement it yet
					break;

				case 'all':
					$complement = "";
					break;

				default:
					http_status_code(405);
					break;
			}

			// Order
			if (isset($_GET["order"]) && $_GET["order"] != "null") {

				$order = getAttribute($_GET['order']);

				// Set all the fields that can be ordered
				$validOrder = array("roleID", "memberID", "requestID", "name", "email", "city", "university");

				if (in_array($order, $validOrder) === FALSE) http_status_code(409);

			} else {
				$order = "name";
			}

			// The query
			$result = getPeopleAtEventQuery($eventID, $complement, "`$order`");

			// Return its data
			if ($format == "json") {
				echo printInformation("eventMember", $result, true, 'json');
			} elseif ($format == "html") {
				printPeopleAtEvent($result, $order);
			} elseif ($format == "excel") {
				resourceToExcel($result);
			} else {
				http_status_code(405, "this format is not available");
			}

		} else {
			http_status_code(400, "selection is a required parameter");
		}
		
	} else

	if ($method === "getActivities") {

		if (isset($_GET["eventID"])) {

			// Get some properties
			$eventID = getAttribute($_GET['eventID']);

			$result = resourceForQuery(
				"SELECT
					`activity`.`id`,
					`activity`.`groupID`,
					`activity`.`name`,
					`activity`.`description`,
					`activity`.`location`,
					-- UNIX_TIMESTAMP(MAKEDATE(YEAR(`activity`.`dateBegin`), DAYOFYEAR(`activity`.`dateBegin`))) AS `day`,
					UNIX_TIMESTAMP(`activity`.`dateBegin`) AS `dateBegin`,
	                UNIX_TIMESTAMP(`activity`.`dateEnd`) AS `dateEnd`,
					`activity`.`capacity`,
					`activity`.`general`,
					`activity`.`highlight`
				FROM
					`activity`
				WHERE
					`activity`.`eventID` = $eventID
	            ORDER BY
	                `activity`.`dateBegin` ASC,
	                `activity`.`dateEnd` ASC
			");

			$data = printInformation("eventMember", $result, true, 'object');
			echo json_encode(groupActivitiesInDays($data));

		} else {
			http_status_code(400, "eventID is a required parameter");
		}
		
	} else

	if ($method === "getSchedule") {

		$eventID = getTokenForEvent();

		$result = resourceForQuery(
            "SELECT
                `activity`.`id`,
                `activity`.`name`,
                `activity`.`description`,
                `activity`.`location`,
                `activity`.`highlight`,
                UNIX_TIMESTAMP(`activity`.`dateBegin`) AS `dateBegin`,
                UNIX_TIMESTAMP(`activity`.`dateEnd`) AS `dateEnd`,
                IF(`activityMember`.`memberID` = $core->memberID, `activityMember`.`approved`, 0) AS `approved`
            FROM
                `activity`
            LEFT JOIN
                `activityMember` ON `activity`.`id` = `activityMember`.`activityID`
            WHERE 1
                AND `activity`.`eventID` = $eventID
                AND `activityMember`.`memberID` = $core->memberID
            GROUP BY
                `activity`.`id`
            ORDER BY
                `activity`.`dateBegin` ASC,
                `activity`.`dateEnd` ASC
        ");

		$data = printInformation("eventMember", $result, true, 'object');
		echo json_encode(groupActivitiesInDays($data));
		
	} else

	if ($method === "sendOpinion") {

		$eventID = getTokenForEvent();

		if (isset ($_POST['rating']) && isset ($_POST['message'])) {

			// Get some properties
			$rating = getAttribute($_POST['rating']);
			$message = getAttribute($_POST['message']);

			// Filter the rating
			$rating = ($rating > 5) ? 5 : $rating;
			$rating = ($rating < 0) ? 0 : $rating;

			// Filter the message
			$message = ($message == "null") ? "" : $message;

			// Update the activity
			$update = resourceForQuery(
				"UPDATE
					`eventMember`
				SET
					`eventMember`.`rating` = $rating,
					`eventMember`.`message` = '$message'
				WHERE 1
					AND `eventMember`.`eventID` = $eventID
					AND `eventMember`.`memberID` = $core->memberID
			");

			if (mysql_affected_rows() > 0) {
				$data["eventID"] = $eventID;
				echo json_encode($data);
			} else {
				http_status_code(500, "not a single row was affected");
			}

		} else {
			http_status_code(400, "rating and message are required parameters");
		}
			
	} else

// ------------------------------------------------------------------------------------------- //
			
	{ http_status_code(501); }
	
?>