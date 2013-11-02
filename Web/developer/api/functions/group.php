<?php

	function processGroupEnrollment($groupID, $personID) {

		// See if the member has been approved on the event that has the desired group
		$result = resourceForQuery(
		// echo (
			"SELECT
				`eventMember`.`id`
			FROM
				`eventMember`
			INNER JOIN
				`group` ON `group`.`eventID` = `eventMember`.`eventID`
			WHERE 1
				AND `group`.`id` = $groupID
				AND `eventMember`.`memberID` = $personID
				AND `eventMember`.`approved` = 1
		");

		if (mysql_num_rows($result) > 0) {
			
			// Insert a new row seing if there are vacancies
			$insert = resourceForQuery(
			// echo (
				"INSERT INTO
					`groupMember`
					(`groupID`, `memberID`, `approved`, `present`)
				SELECT
					$groupID,
					$personID,
					0,
					0
				FROM
					`group`
				LEFT JOIN
					`groupMember` ON `group`.`id` = `groupMember`.`groupID`
				WHERE 1
					AND `group`.`id` = $groupID
				GROUP BY
					`group`.`id`
				HAVING 1
					AND SUM(IF(`groupMember`.`memberID` = $personID, 1, 0)) = 0
			");

			// Send an email if any row was inserted
			if (mysql_affected_rows() > 0) {

				// Select some details about the group
				$result = resourceForQuery(
					"SELECT
						`group`.`name`,
						`group`.`highlight`
					FROM
						`group`
					WHERE 1
						AND `group`.`id` = $groupID
					LIMIT 1
				");

				if (mysql_num_rows($result) > 0) {

					// Get some properties
					$groupName = mysql_result($result, 0, "name");
					$groupHighlight = mysql_result($result, 0, "highlight");

					// Only send an email if the group is important
					if ($groupHighlight) sendActivityEnrollmentEmail($groupName, getEmailForPerson($personID));

					return $insert;

				} else {
					http_status_code(404, "groupID does not exist!");
				}
			} else {
				http_status_code(406, "not a single row was inserted");
			}
		} else {
			http_status_code(406, "personID has not been approved on the event");
		}

	}

?>