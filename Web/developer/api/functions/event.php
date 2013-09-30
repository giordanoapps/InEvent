<?php

	function processEventEnrollmentWithActivity($activityID, $personID) {

		// Get the eventID
		$eventID = getEventForActivity($activityID);

		// Enroll the person at the event
		return processEventEnrollmentWithEvent($eventID, $personID);
	}

	function processEventEnrollmentWithEvent($eventID, $personID) {

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

			// Find how many people are already enrolled at this activity
			$result = resourceForQuery(
				"SELECT
					`eventMember`.`position`
				FROM
					`eventMember`
				WHERE 1
					AND `eventMember`.`eventID` = $eventID
				ORDER BY
					`eventMember`.`id` DESC
				LIMIT 1
			");

			$position = (mysql_num_rows($result) > 0) ? mysql_result($result, 0, "position") + 1 : 1;

			// Insert the person on the event
			$insert = resourceForQuery(
				"INSERT INTO
					`eventMember`
					(`eventID`, `memberID`, `position`, `roleID`, `approved`)
				VALUES
					($eventID, $personID, $position, @(ROLE_ATTENDEE), 1)
			");

			if (mysql_affected_rows() > 0) {

				$result = resourceForQuery(
					"SELECT
						`event`.`name`
					FROM
						`event`
					WHERE 1
						AND `event`.`id` = $eventID
					LIMIT 1
				");

				if (mysql_num_rows($result) > 0) {

					// Get some properties and send an email
					sendEventEnrollmentEmail(mysql_result($result, 0, "name"), getEmailForPerson($personID));

					// Get all the activities
					$result = resourceForQuery(
						"SELECT
							`activity`.`id`
						FROM
							`activity`
						WHERE 1
							AND `activity`.`general` = 1
							AND `activity`.`eventID` = $eventID
					");

					for ($i = 0; $i < mysql_num_rows($result); $i++) {

						// Get some properties
						$activityID = mysql_result($result, $i, "id");

						// Find how many people are already enrolled at this activity
						$resultPosition = resourceForQuery(
							"SELECT
								`activityMember`.`position`
							FROM
								`activityMember`
							WHERE 1
								AND `activityMember`.`activityID` = $activityID
							ORDER BY
								`activityMember`.`id` DESC
							LIMIT 1
						");

						$position = (mysql_num_rows($resultPosition) > 0) ? mysql_result($resultPosition, 0, "position") + 1 : 1;

						// Insert all the activities that are general
						$insert = resourceForQuery(
							"INSERT INTO
								`activityMember`
								(`activityID`, `memberID`, `position`, `approved`, `present`)
							VALUES
								($activityID, $personID, $position, 1, 0)
						");
					}

					return $insert;

				} else {
					http_status_code(404, "eventID does not exist!");
				}
			} else {
				http_status_code(406, "not a single row was inserted");
			}
		} else {
			return 303;
			// http_status_code(303, "The personID is already enrolled on this event");
		}

	}

	function groupActivitiesInDays($data) {

		$dayTimestamp = 0;
		$days = -1;

		$convertedData = array();
		$convertedData["count"] = 0;
		$convertedData["data"] = array();

		for ($i = 0; $i < $data["count"]; $i++) {
			
			$activityData = $data["data"][$i];

            if ($dayTimestamp != date("z", $activityData['dateBegin'])) {
                $dayTimestamp = date("z", $activityData['dateBegin']);

                $days++;

                $convertedData["data"][] = array();
            }

            $convertedData["data"][$days][] = $data["data"][$i];
        }

        $convertedData["count"] = count($convertedData["data"]);

        return $convertedData;
	}


?>