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
			// Insert the person on the event
			$insert = resourceForQuery(
				"INSERT INTO
					`eventMember`
					(`eventID`, `memberID`, `roleID`, `approved`)
				VALUES
					($eventID, $personID, @(ROLE_ATTENDEE), 1)
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

					return $insert;

				} else {
					http_status_code(404, "eventID does not exist!");
				}
			} else {
				http_status_code(406, "not a single row was inserted");
			}
		} else {
			http_status_code(303, "The personID is already enrolled on this event");
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