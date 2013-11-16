<?php

	/**
	 * Create a new event inside the platform
	 * @param  array $details    information
	 * @return integer           eventID
	 */
	function createEvent($details) {

		if (isset($details["name"]) && isset($details["nickname"])) {

			// Required
			$name = $details["name"];
			$nickname = $details["nickname"];

			// Insert the event 
			$insert = resourceForQuery(
				"INSERT INTO
					`event`
					(
						`name`,
						`nickname`,
						`description`,
						`cover`,
						`dateBegin`,
						`dateEnd`,
						`enrollmentBegin`,
						`enrollmentEnd`,
						`latitude`,
						`longitude`,
						`address`,
						`city`,
						`state`,
						`fugleman`
					)
				VALUES 
					(
						'$name',
						'$nickname',
						'Descri&ccedil;&atilde;o do evento',
						'images/logo@512.png',
						NOW(),
						DATE_ADD(NOW(), INTERVAL 1 MONTH),
						NOW(),
						DATE_ADD(NOW(), INTERVAL 1 MONTH),
						0,
						0,
						'Seu endere&ccedil;o',
						'Sua cidade',
						'Seu estado',
						'Organizador'
					)
			");

			$eventID = mysqli_insert_id_new();

			return $eventID;

		} else {
			http_status_code(400, "name and nickname are required parameters");
		}
	}

	/**
	 * Get the event for a given activity and pass the message along
	 * @param  int $activityID id of activity
	 * @param  int $personID   id of person
	 * @return object
	 */
	function processEventEnrollmentWithActivity($activityID, $personID) {

		// Get the eventID
		$eventID = getEventForActivity($activityID);

		// Enroll the person at the event
		return processEventEnrollmentWithEvent($eventID, $personID);
	}

	/**
	 * Get the event for a given group and pass the message along
	 * @param  int $groupID 	id of group
	 * @param  int $personID   	id of person
	 * @return object
	 */
	function processEventEnrollmentWithGroup($groupID, $personID) {

		// Get the eventID
		$eventID = getEventForGroup($groupID);

		// Enroll the person at the event
		return processEventEnrollmentWithEvent($eventID, $personID);
	}

	/**
	 * Enroll a person inside an event
	 * @param  int $eventID 	id of event
	 * @param  int $personID   	id of person
	 * @return object
	 */
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

		if (mysqli_num_rows($result) == 0) {

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

			$position = (mysqli_num_rows($result) > 0) ? mysqli_result($result, 0, "position") + 1 : 1;

			// Insert the person on the event
			$insert = resourceForQuery(
				"INSERT INTO
					`eventMember`
					(`eventID`, `memberID`, `position`, `roleID`, `approved`)
				VALUES
					($eventID, $personID, $position, @(ROLE_ATTENDEE), 1)
			");

			if (mysqli_affected_rows_new() > 0) {

				// Get some properties and send an email
				sendEventEnrollmentEmail($eventID, $personID);

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

				for ($i = 0; $i < mysqli_num_rows($result); $i++) {

					// Get some properties
					$activityID = mysqli_result($result, $i, "id");

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

					$position = (mysqli_num_rows($resultPosition) > 0) ? mysqli_result($resultPosition, 0, "position") + 1 : 1;

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
				http_status_code(406, "not a single row was inserted");
			}
		} else {
			return 303;
			// http_status_code(303, "The personID is already enrolled on this event");
		}

	}

	/**
	 * Group all activities in days
	 * @param  object $data activities
	 * @return object
	 */
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