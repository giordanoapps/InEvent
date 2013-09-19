<?php

	function processActivityEnrollment($activityID, $personID) {

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
					IF($valid AND (`activity`.`capacity` = 0 OR `activity`.`capacity` > COALESCE(SUM(`activityMember`.`approved`), 1)), 1, 0),
					0
				FROM
					`activity`
				LEFT JOIN
					`activityMember` ON `activity`.`id` = `activityMember`.`activityID`
				WHERE 1
					AND `activity`.`id` = $activityID
				GROUP BY
					`activity`.`id`
				HAVING 1
					AND SUM(IF(`activityMember`.`memberID` = $personID, 1, 0)) = 0
			");

			// Send an email if any row was inserted
			if (mysql_affected_rows() > 0) {

				// Select some details about the activity
				$result = resourceForQuery(
					"SELECT
						`activity`.`name`,
						`activity`.`highlight`
					FROM
						`activity`
					WHERE 1
						AND `activity`.`id` = $activityID
					LIMIT 1
				");

				if (mysql_num_rows($result) > 0) {

					// Get some properties
					$activityName = mysql_result($result, 0, "name");
					$activityHighlight = mysql_result($result, 0, "highlight");

					// Only send an email if the activity is important
					if ($activityHighlight) sendActivityEnrollmentEmail($activityName, getEmailForPerson($personID));

					return $insert;

				} else {
					http_status_code(404, "activityID does not exist!");
				}
			} else {
				http_status_code(406, "not a single row was inserted");
			}
		} else {
			http_status_code(406, "personID has not been approved on the event");
		}

	}

?>