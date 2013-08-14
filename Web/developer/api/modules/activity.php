<?php
// -------------------------------------- ACTIVITY --------------------------------------- //
	
	if ($method === "requestEnrollment") {

		$tokenID = getToken();

		if (isset($_GET['personID']) && $_GET['personID'] != "null") {

			if ($core->workAtCompany) {
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
						IF(COALESCE(`activityGroup`.`limit`, 99999) > COUNT(`activityMember`.`id`), 1, 0) AS `valid`
					FROM
						`activity`
					LEFT JOIN
						`activityMember` ON `activity`.`id` = `activityMember`.`activityID`
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
						IF((`activity`.`capacity` = 0 OR `activity`.`capacity` > COUNT(`activityMember`.`id`)) AND $valid, 1, 0),
						0
					FROM
						`activity`
					LEFT JOIN
						`activityMember` ON `activityMember`.`activityID` = `activity`.`id`
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
						$result = getActivityForMemberQuery($activityID, $personID);
						printTimelineItem(mysql_fetch_assoc($result));
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

			if ($core->workAtCompany) {
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
				
			$delete = resourceForQuery(
				"DELETE FROM
					`activityMember`
				WHERE 1
					AND `activityMember`.`activityID` = $activityID
					AND `activityMember`.`memberID`= $core->memberID
			");

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

			$result = resourceForQuery(
				"SELECT
					`member`.`id`,
					`member`.`name`
				FROM
					`activityMember`
				INNER JOIN
					`member` ON `member`.`id` = `activityMember`.`memberID`
				WHERE 1
					AND `activityMember`.`activityID` = $activityID
					$complement
			");

			echo printInformation("activityMember", $result, true, 'json');

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