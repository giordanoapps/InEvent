<?php
// -------------------------------------- ACTIVITY --------------------------------------- //
	
	if ($method === "requestEnrollment") {

		$tokenID = getToken();

		if (isset($_GET['personID']) && $_GET['personID'] != "null") {

			if ($core->workAtEvent) {
				$personID = getAttribute($_GET['personID']);

				// If the personID is 0, we must create an anonymous member named "Pessoa"
				if ($personID == 0) $personID = createMember("Pessoa", "", "", "", "", 1);
			} else {
				http_status_code(401);
			}
		} else {
			$personID = $core->memberID;
		}

		if (isset($_GET["activityID"])) {

			// Get some properties
			$activityID = getAttribute($_GET['activityID']);

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
					"SELECT
						IF(COALESCE(`activityGroup`.`limit`, 99999) > SUM(`activityMember`.`approved`), 1, 0) AS `valid`
					FROM
						`activity`
					LEFT JOIN
						`activityMember` ON `activity`.`id` = `activityMember`.`activityID` AND `activityMember`.`memberID` = $personID
		            LEFT JOIN
		                `activityGroup` ON `activity`.`groupID` = `activityGroup`.`id`
					WHERE 1
						AND `activity`.`groupID` = (
							SELECT
								`activity`.`groupID`
							FROM
								`activity`
							WHERE
								`activity`.`id` = $activityID
						)
					GROUP BY
						`activity`.`groupID`
				");

				$valid = (mysql_num_rows($result) > 0) ? mysql_result($result, 0, "valid") : 0;
				
				// Insert a new row seing if there are vacancies
				$insert = resourceForQuery(
				// echo (
					"INSERT INTO
						`activityMember`
						(`activityID`, `memberID`, `approved`, `present`)
					SELECT
						$activityID,
						$personID,
						IF((`activity`.`capacity` = 0 OR `activity`.`capacity` > SUM(`activityMember`.`approved`)) AND $valid, 1, 0),
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
						http_status_code(405);	
					}
				} else {
					http_status_code(500);
				}

			} else {
				http_status_code(406);
			}

		} else {
			http_status_code(400);
		}
		
	} else

	if ($method === "dismissEnrollment") {

		$tokenID = getToken();

		if (isset($_GET['personID']) && $_GET['personID'] != "null") {

			if ($core->workAtEvent) {
				$personID = getAttribute($_GET['personID']);

				// If the personID is 0, we must create an anonymous member named "Pessoa"
				if ($personID == 0) $personID = createMember("Pessoa", "", "", "", "", 1);
			} else {
				http_status_code(401);
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

			// // Get the next person on the line and grant a place on the activity
			// $update = resourceForQuery(
			// 	"UPDATE
			// 		`activityMember`
			// 	SET
			// 		`activityMember`.`approved` = 1
			// 	WHERE 1
			// 		AND `activityMember`.`approved` = 0
			// 		AND `activityMember`.`priori` = 1
			// 		AND `activityMember`.`memberID` = $personID
			// 		AND `activityMember`.`activityID` = $activityID
			// 	ORDER BY
			// 		`activityMember`.`id` ASC
			// 	LIMIT 1
			// ");

			// // Assert that the granted person doesn't stay approved on other activities of the same group
			// $result = resourceForQuery(
			// 	"SELECT
			// 		`activityMember`.`id` AS `id`,
			// 		`activityGroup`.`limit`,
			// 		`activityMember`.`approved`
			// 	FROM
			// 		`activity`
			// 	INNER JOIN
			// 		`activityMember` ON `activityMember`.`activityID` = `activity`.`id`
	  //           LEFT JOIN
	  //               `activityGroup` ON `activity`.`groupID` = `activityGroup`.`id`
	  //           WHERE 1
	  //           	AND `activityMember`.`memberID` = $personID
	  //           	AND `activityGroup`.`id` = $groupID
			// 	GROUP BY
			// 		`activityGroup`.`id`
			// 	HAVING 1
			// 		AND COALESCE(`activityGroup`.`limit`, 99999) > SUM(`activityMember`.`approved`)
			// 	ORDER BY
			// 		`activityMember`.`id` ASC
			// 	LIMIT 1
			// ");

			// if (mysql_num_rows($result) > 0) {
			// 	$requestID = mysql_result($result, 0, "id");
			// 	$update = resourceForQuery(
			// 		"UPDATE
			// 			`activityMember`
		 //            SET
		 //            	`activityMember`.`approved` = 0
			// 		WHERE 1
			// 			AND `activityMember`.`id` = $requestID
			// 	");
			// }

			if ($delete) {
				// Return its data
				if ($format == "json") {
					$data["activityID"] = $activityID;
					echo json_encode($data);
				} elseif ($format == "html") {
					$data["activityID"] = $activityID;
					echo json_encode($data);
				} else {
					http_status_code(405);	
				}
			} else {
				http_status_code(500);
			}

		} else {
			http_status_code(400);
		}
		
	} else

	if ($method === "confirmEntrance" || $method === "confirmPayment") {

		$activityID = getTokenForActivity();

		if (isset($_GET["personID"])) {

			// Get some properties
			$personID = getAttribute($_GET['personID']);

			if ($core->workAtEvent) {

				// See which field we want to update
				if ($method === "confirmEntrance") {
					$attribute = "present";
				} elseif ($method === "confirmPayment") {
					$attribute = "paid";
				}

				// Update based on the attribute
				$update = resourceForQuery(
					"UPDATE
						`activityMember`
					SET
						`activityMember`.`$attribute` = 1
					WHERE 1
						AND `activityMember`.`activityID` = $activityID
						AND `activityMember`.`memberID` = $personID
						AND `activityMember`.`approved` = 1
				");

				if (mysql_affected_rows() > 0) {
					// Return its data
					if ($format == "json") {
						$data["personID"] = $personID;
						echo json_encode($data);
					} elseif ($format == "html") {
						$data["personID"] = $personID;
						echo json_encode($data);
					} else {
						http_status_code(405);	
					}
				} else {
					http_status_code(500);
				}
			} else {
				http_status_code(401);
			}
		} else {
			http_status_code(400);
		}
		
	} else

	if ($method === "risePriority" || $method === "decreasePriority") {

		$tokenID = getToken();

		if (isset($_GET["activityID"])) {

			// Get some properties
			$activityID = getAttribute($_GET['activityID']);

			// See which field we want to update
			if ($method === "risePriority") {
				$attribute = "1";
			} elseif ($method === "decreasePriority") {
				$attribute = "0";
			}

			// Update based on the attribute
			$update = resourceForQuery(
				"UPDATE
					`activityMember`
				SET
					`activityMember`.`priori` = $attribute
				WHERE 1
					AND `activityMember`.`activityID` = $activityID
					AND `activityMember`.`memberID` = $core->memberID
			");

			if (mysql_affected_rows() > 0) {
				// Return its data
				if ($format == "json") {
					$data["activityID"] = $activityID;
					echo json_encode($data);
				} elseif ($format == "html") {
					$data["activityID"] = $activityID;
					echo json_encode($data);
				} else {
					http_status_code(405);	
				}
			} else {
				http_status_code(500);
			}
		} else {
			http_status_code(400);
		}
		
	} else

	if ($method === "getPeople") {

		$tokenID = getToken();

		if (isset($_GET["activityID"]) && isset($_GET["selection"])) {

			// Get some properties
			$activityID = getAttribute($_GET['activityID']);
			$selection = getAttribute($_GET['selection']);

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
					http_status_code(405);
					break;
			}

			// The query
			$result = getPeopleAtActivityQuery($activityID, $complement);

			// Return its data
			if ($format == "json") {
				echo printInformation("activityMember", $result, true, 'json');
			} elseif ($format == "html") {
				printPeopleAtActivity($result);
			} else {
				http_status_code(405);	
			}

		} else {
			http_status_code(400);
		}
		
	} else

	if ($method === "getQuestions") {

		$tokenID = getToken();

		if (isset($_GET["activityID"])) {

			// Get some properties
			$activityID = getAttribute($_GET['activityID']);

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
			http_status_code(400);
		}
		
	} else

	if ($method === "sendQuestion") {

		$tokenID = getToken();

		if (isset($_GET["activityID"]) && isset($_POST["question"])) {

			// Get some properties
			$activityID = getAttribute($_GET['activityID']);
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
				http_status_code(500);
			}

		} else {
			http_status_code(400);
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
				http_status_code(500);
			}

		} else {
			http_status_code(400);
		}
		
	} else
// ------------------------------------------------------------------------------------------- //
			
	{ http_status_code(501); }
	
?>