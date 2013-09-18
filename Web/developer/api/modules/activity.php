<?php
// -------------------------------------- ACTIVITY --------------------------------------- //
	
	if ($method === "requestEnrollment") {

		$activityID = getTokenForActivity();

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

				// See if the person is already inside the event
				$result = resourceForQuery(
					"SELECT
						`eventMember`.`eventID`
					FROM
						`eventMember`
					INNER JOIN
						`activity` ON `activity`.`eventID` = `eventMember`.`eventID`
					WHERE 1
						AND `activity`.`id` = $activityID
						AND `eventMember`.`memberID` = $personID
				");

				// Insert the person on the event
				if (mysql_num_rows($result) == 0) {

					$result = resourceForQuery(
						"SELECT
							`event`.`id`,
							`event`.`name`,
							`activity`.`highlight`
						FROM
							`activity`
						INNER JOIN
							`event` ON `event`.`id` = `activity`.`eventID`
						WHERE 1
							AND `activity`.`id` = $activityID
						LIMIT 1
					");

					if (mysql_num_rows($result) > 0) {

						// Get some properties
						$eventID = mysql_result($result, 0, "id");
						$eventName = mysql_result($result, 0, "name");
						$activityHighlight = mysql_result($result, 0, "highlight");

						$insert = resourceForQuery(
							"INSERT INTO
								`eventMember`
								(`eventID`, `memberID`, `roleID`, `approved`)
							VALUES
								($eventID, $personID, @(ROLE_ATTENDEE), 1)
						");

						// Only send an email if the activity is important
						if ($activityHighlight) sendEventEnrollmentEmail($eventName, $email);

					} else {
						http_status_code(404, "eventID does not exist!");
					}
				} else {
					http_status_code(404, "personID is not enrolled at this event");
				}
			} else {
				http_status_code(401, "personID doesn't work at event");
			}
		} else {
			$personID = $core->memberID;
		}

		if ($personID != 0) {

			// Get some properties
			$groupID = getGroupForActivity($activityID);

			// See if the member has been approved on the event that has the desired activity
			$result = resourceForQuery(
			// echo (
				"SELECT
					`eventMember`.`id`
				FROM
					`eventMember`
				INNER JOIN
					`activity` ON `activity`.`eventID` = `eventMember`.`eventID`
				WHERE 1
					AND `activity`.`id` = $activityID
					AND `eventMember`.`memberID` = $personID
					AND `eventMember`.`approved` = 1
			");

			if (mysql_num_rows($result) > 0) {

				// Find if the member is over his limit on different groups
				$result = resourceForQuery(
				// echo (
					"SELECT
						IF(COALESCE(`activityGroup`.`limit`, 99999) > COALESCE(SUM(`activityMember`.`approved`), 0), 1, 0) AS `valid`
					FROM
						`activity`
					LEFT JOIN
						`activityMember` ON `activity`.`id` = `activityMember`.`activityID` AND `activityMember`.`memberID` = $personID
		            LEFT JOIN
		                `activityGroup` ON `activity`.`groupID` = `activityGroup`.`id`
					WHERE 1
						AND `activity`.`groupID` = $groupID
					GROUP BY
						`activity`.`groupID`
				");

				$valid = (mysql_num_rows($result) > 0) ? mysql_result($result, 0, "valid") : 1;
				
				// Insert a new row seing if there are vacancies
				$insert = resourceForQuery(
				// echo (
					"INSERT INTO
						`activityMember`
						(`activityID`, `memberID`, `approved`, `present`)
					SELECT
						$activityID,
						$personID,
						IF($valid AND (`activity`.`capacity` = 0 OR `activity`.`capacity` > SUM(`activityMember`.`approved`)), 1, 0),
						0
					FROM
						`activity`
					LEFT JOIN
						`activityMember` ON `activity`.`id` = `activityMember`.`activityID`
					WHERE 1
						AND `activity`.`id` = $activityID
					GROUP BY
						`activity`.`id`
				");

				if ($insert) {
					// Return its data
					if ($format == "json") {
						$data["activityID"] = $activityID;
						echo json_encode($data);
					} elseif ($format == "html") {
						$result = getActivitiesForMemberAtActivityQuery($activityID, $personID);
						printScheduleItem(mysql_fetch_assoc($result), "member");
					} else {
						http_status_code(405, "this format is not available");
					}
				} else {
					http_status_code(500, "insert inside activity has failed");
				}
			} else {
				http_status_code(406, "personID has not been approved on the event");
			}
		} else {
			http_status_code(400, "personID cannot be null");
		}
		
	} else

	if ($method === "dismissEnrollment") {

		$tokenID = getToken();

		if (isset($_GET['personID']) && $_GET['personID'] != "null") {

			if ($core->workAtEvent) {
				$personID = getAttribute($_GET['personID']);
			} else {
				http_status_code(401, "personID doesn't work at event");
			}
		} else {
			$personID = $core->memberID;
		}

		if (isset($_GET["activityID"])) {

			// Get some properties
			$activityID = getAttribute($_GET['activityID']);
			$groupID = getGroupForActivity($activityID);
				
			// Remove the current person
			$delete = resourceForQuery(
				"DELETE FROM
					`activityMember`
				WHERE 1
					AND `activityMember`.`activityID` = $activityID
					AND `activityMember`.`memberID` = $personID
			");

			// Check if the person is on the limit of activities for the given group
			// $result = resourceForQuery(
			// 	"SELECT
			// 		`activity`.`id`,
			// 		`activityMember`.`id`,
			// 		`activityMember`.`priori`,
			// 		`activityMember`.`approved`,
			// 		`activityGroup`.`limit`,
			// 	FROM
			// 		`activity`
			// 	LEFT JOIN
			// 		`activityMember` ON `activity`.`id` = `activityMember`.`activityID`
			// 	LEFT JOIN
			// 		`activityGroup` ON `activity`.`groupID` = `activityGroup`.`id` AND `activity`.`groupID` = $groupID
			// 	WHERE 1
					
			// 	GROUP BY
			// 		`activity`.`groupID`,
			// 		`activityMember`.`memberID`
			// 	HAVING 0
			// 		OR ((`activityMember`.`priori` = 1 AND `activity`.`id` = $activityID) AND COALESCE(`activityGroup`.`limit`, 99999) <= SUM(`activityMember`.`approved`))
			// 		OR ((`activityMember`.`priori` = 0 AND `activity`.`id` = $activityID) AND COALESCE(`activityGroup`.`limit`, 99999) > SUM(`activityMember`.`approved`))
			// 	ORDER BY
			// 		`activityMember`.`id` ASC
			// ");
			
			$result = resourceForQuery(
				"SELECT
					`activityMember`.`id`,
					`activityMember`.`priori`,
					`activityMember`.`memberID`
				FROM
					`activityMember`
				WHERE 1
					AND `activityMember`.`activityID` = $activityID
					AND `activityMember`.`approved` = 0
				ORDER BY
					`activityMember`.`id` ASC
			");

			for ($i = 0; $i < mysql_num_rows($result); $i++) {
				
				$requestID = mysql_result($result, $i, "id");
				$priori = mysql_result($result, $i, "priori");
				$memberID = mysql_result($result, $i, "memberID");

				$resultExtrapolated = resourceForQuery(
					"SELECT
						IF(COALESCE(`activityGroup`.`limit`, 99999) <= SUM(`activityMember`.`approved`), 1, 0) AS `extrapolated`
					FROM
						`activity`
					LEFT JOIN
						`activityMember` ON `activity`.`id` = `activityMember`.`activityID` AND `activityMember`.`memberID` = $memberID
		            LEFT JOIN
		                `activityGroup` ON `activity`.`groupID` = `activityGroup`.`id`
					WHERE 1
						AND `activity`.`groupID` = $groupID
					GROUP BY
						`activity`.`groupID`
				");

				$extrapolated = (mysql_num_rows($resultExtrapolated) > 0) ? mysql_result($resultExtrapolated, 0, "extrapolated") : 0;

				// If the person extrapolated, we can only overwrite it if the user explicity gave us permition to do so
				if ($extrapolated == 1 && $priori == 1) {
					// Get the next person on the line and grant a place on the activity
					$update = resourceForQuery(
						"UPDATE
							`activityMember`
						SET
							`activityMember`.`approved` = 1
						WHERE 1
							AND `activityMember`.`id` = $requestID
						ORDER BY
							`activityMember`.`id` ASC
						LIMIT 1
					");

					// If we didn't alter something (a person had his schedule modified), we must remove from other activities
					if (mysql_affected_rows() > 0) {
						// Assert that the granted person doesn't stay approved on other activities of the same group
						$resultOther = resourceForQuery(
						// echo (
							"SELECT
								`activityMember`.`id`
							FROM
								`activity`
							INNER JOIN
								`activityMember` ON `activityMember`.`activityID` = `activity`.`id`
				 			LEFT JOIN
								`activityGroup` ON `activity`.`groupID` = `activityGroup`.`id`
							WHERE 1
								AND `activityMember`.`memberID` = $memberID
								AND `activityMember`.`approved` = 1
								AND `activityMember`.`id` != $requestID
								AND `activityGroup`.`id` = $groupID
							ORDER BY
								`activityMember`.`id` ASC
							LIMIT 1
						");

						if (mysql_num_rows($resultOther) > 0) {
							$requestID = mysql_result($resultOther, 0, "id");
							echo "$requestID";
							$update = resourceForQuery(
								"UPDATE
									`activityMember`
					            SET
					            	`activityMember`.`approved` = 0
								WHERE 1
									AND `activityMember`.`id` = $requestID
							");
						}
					}

					break;

				// Otherwise we just get the next one
				} elseif ($extrapolated == 0) {
					$update = resourceForQuery(
						"UPDATE
							`activityMember`
						SET
							`activityMember`.`approved` = 1
						WHERE 1
							AND `activityMember`.`id` = $requestID
						ORDER BY
							`activityMember`.`id` ASC
						LIMIT 1
					");

					break;

				} else {
					http_status_code(400, "personID has chosen to not replace his activity");
				}
			}

			if ($delete) {
				// Return its data
				if ($format == "json") {
					$data["activityID"] = $activityID;
					echo json_encode($data);
				} elseif ($format == "html") {
					$data["activityID"] = $activityID;
					echo json_encode($data);
				} else {
					http_status_code(405, "this format is not available");	
				}
			} else {
				http_status_code(500, "row deletion could not be completed");
			}
		} else {
			http_status_code(400, "activityID is a required parameter");
		}
		
	} else

	if (0
		|| $method === "confirmEntrance"
		|| $method === "revokeEntrance"
		|| $method === "confirmPayment"
		|| $method === "revokePayment"
		|| $method === "risePriority"
		|| $method === "decreasePriority") {

		$activityID = getTokenForActivity();

		if (isset($_GET["personID"])) {

			// Get some properties
			$personID = getAttribute($_GET['personID']);

			if ($core->workAtEvent) {

				// See which field we want to update
				if ($method === "confirmEntrance") {
					$attribute = "`activityMember`.`present` = 1";
				} elseif ($method === "revokeEntrance") {
					$attribute = "`activityMember`.`present` = 0";
				} elseif ($method === "confirmPayment") {
					$attribute = "`activityMember`.`paid` = 1";
				} elseif ($method === "revokePayment") {
					$attribute = "`activityMember`.`paid` = 0";
				} elseif ($method === "risePriority") {
					$attribute = "`activityMember`.`priori` = 1";
				} elseif ($method === "decreasePriority") {
					$attribute = "`activityMember`.`priori` = 0";
				}

				// Update based on the attribute
				$update = resourceForQuery(
					"UPDATE
						`activityMember`
					SET
						$attribute
					WHERE 1
						AND `activityMember`.`activityID` = $activityID
						AND `activityMember`.`memberID` = $personID
						AND `activityMember`.`approved` = 1
				");

				if ($update) {
					// Return its data
					if ($format == "json") {
						$data["personID"] = $personID;
						echo json_encode($data);
					} elseif ($format == "html") {
						$data["personID"] = $personID;
						echo json_encode($data);
					} else {
						http_status_code(405, "this format is not available");	
					}
				} else {
					http_status_code(500, "row update has failed");
				}
			} else {
				http_status_code(401, "personID doesn't work at event");
			}
		} else {
			http_status_code(400, "activityID and personID are required parameters");
		}
		
	} else

	if ($method === "getPeople") {

		$activityID = getTokenForActivity();

		if (isset($_GET["selection"])) {

			// Get some properties
			$selection = getAttribute($_GET['selection']);

			// Selection
			switch ($selection) {
				case 'approved':
					$complement = "AND `activityMember`.`approved` = 1";
					break;

				case 'denied':
					$complement = "AND `activityMember`.`approved` = 0";
					break;

				case 'unseen':
					$complement = "AND `activityMember`.`id` = 0"; // Don't need to implement it yet
					break;

				case 'all':
					$complement = "";
					break;

				default:
					http_status_code(405, "this format is not available");
					break;
			}

			// Order
			if (isset($_GET["order"]) && $_GET["order"] != "null") {

				$order = getAttribute($_GET['order']);

				// Set all the fields that can be ordered
				$validOrder = array("memberID", "name", "telephone", "requestID", "approved", "paid", "present", "priori");

				if (in_array($order, $validOrder) === FALSE) http_status_code(409);

			} else {
				$order = "name";
			}

			// The query
			$result = getPeopleAtActivityQuery($activityID, $complement, "`$order`");

			// Return its data
			if ($format == "json") {
				echo printInformation("activityMember", $result, true, 'json');
			} elseif ($format == "html") {
				printPeopleAtActivity($result, $order);
			} elseif ($format == "excel") {
				resourceToExcel($result);
			} elseif ($format == "gmail") {
				for ($i = 0; $i < mysql_num_rows($result); $i++) {
					echo ($i != 0 ? " , " : "") . mysql_result($result, $i, "name") . " <" . mysql_result($result, $i, "email") . ">";
				}
			} else {
				http_status_code(405, "this format is not available");	
			}

		} else {
			http_status_code(400, "activityID and selection are required parameters");
		}
		
	} else

	if ($method === "getQuestions") {

		$activityID = getTokenForActivity();

		if (isset($_GET["activityID"])) {

			$result = resourceForQuery(
			// echo (
				"SELECT
					`activityQuestion`.`id`,
					`member`.`name` AS `memberName`,
					`activityQuestion`.`memberID`,
					`activityQuestion`.`text`,
					COUNT(`activityQuestion`.`id`) AS `votes`
				FROM
					`activityQuestion`
				INNER JOIN
					`member` ON `member`.`id` = `activityQuestion`.`memberID`
				LEFT JOIN
					`activityQuestionMember` ON `activityQuestion`.`id` = `activityQuestionMember`.`questionID`
				WHERE 1
					AND `activityQuestion`.`activityID` = $activityID
				GROUP BY
					`activityQuestion`.`id` ASC
			");

			echo printInformation("activityQuestion", $result, true, 'json');

		} else {
			http_status_code(400, "activityID is a required parameter");
		}
		
	} else

	if ($method === "sendQuestion") {

		$activityID = getTokenForActivity();

		if (isset($_POST["question"])) {

			// Get some properties
			$question = getAttribute($_POST['question']);

			$insert = resourceForQuery(
			// echo (
				"INSERT INTO
					`activityQuestion`
					(`activityID`, `memberID`, `text`)
				SELECT
					`activityMember`.`activityID`,
					`activityMember`.`memberID`,
					'$question'
				FROM
					`activityMember`
				LEFT JOIN
					`activityQuestion` ON `activityMember`.`activityID` = `activityQuestion`.`activityID`
				WHERE 1
					AND `activityMember`.`activityID` = $activityID
					AND `activityMember`.`memberID` = $core->memberID
					AND `activityMember`.`approved` = 1
					AND (ISNULL(`activityQuestion`.`text`) OR BINARY `activityQuestion`.`text` != '$question')
			");

			$questionID = mysql_insert_id();

			if ($insert) {
				$data["questionID"] = $questionID;
				echo json_encode($data);
			} else {
				http_status_code(500, "row insertion has failed");
			}

		} else {
			http_status_code(400, "activityID and question are required parameters");
		}
		
	} else

	if ($method === "upvoteQuestion") {

		$tokenID = getToken();

		if (isset($_GET["questionID"])) {

			// Get some properties
			$questionID = getAttribute($_GET['questionID']);

			$insert = resourceForQuery(
			// echo (
				"INSERT INTO
					`activityQuestionMember`
					(`questionID`, `memberID`)
				SELECT
					`activityQuestion`.`id`,
					`activityMember`.`memberID`
				FROM
					`activityMember`
				INNER JOIN
					`activityQuestion` ON `activityMember`.`activityID` = `activityQuestion`.`activityID`
				LEFT JOIN
					`activityQuestionMember` ON `activityQuestion`.`id` = `activityQuestionMember`.`questionID`
				WHERE 1
					AND `activityMember`.`activityID` = (
						SELECT
							`activityMember`.`activityID`
						FROM
							`activityMember`
						INNER JOIN
							`activityQuestion` ON `activityMember`.`activityID` = `activityQuestion`.`activityID`
						WHERE 1
							AND `activityMember`.`memberID` = $core->memberID
							AND `activityMember`.`approved` = 1
							AND `activityQuestion`.`id` = $questionID
					)
					AND `activityMember`.`memberID` = $core->memberID
					AND (ISNULL(`activityQuestionMember`.`id`) OR `activityQuestionMember`.`memberID` != $core->memberID)
			");

			if ($insert) {
				$data["questionID"] = $questionID;
				echo json_encode($data);
			} else {
				http_status_code(500, "row insertion has failed");
			}

		} else {
			http_status_code(400, "questionID is a required parameter");
		}
		
	} else

	if ($method === "sendOpinion") {

		$activityID = getTokenForActivity();

		if (isset ($_POST['rating'])) {

			// Get some properties
			$rating = getAttribute($_POST['rating']);
			$message = getAttribute($_POST['message']);

			// Filter the rating
			$rating = ($rating > 5) ? 5 : $rating;
			$rating = ($rating < 0) ? 0 : $rating;

			// Update the activity
			$update = resourceForQuery(
				"UPDATE
					`activityMember`
				SET
					`activityMember`.`rating` = $rating
				WHERE 1
					AND `activityMember`.`activityID` = $activityID
					AND `activityMember`.`memberID` = $core->memberID
			");

			if (mysql_affected_rows() > 0) {
				$data["activityID"] = $activityID;
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