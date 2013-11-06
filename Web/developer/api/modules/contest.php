<?php
// ----------------------------------------- PERSON ----------------------------------------- //

	if ($method === "requestAddress") {

		$eventID = getTokenForEvent();

		// Get some enrollment details
		$result = resourceForQuery(
			"SELECT
				`contestMember`.`url`
			FROM
				`contest`
			INNER JOIN
				`contestMember` ON `contestMember`.`contestID` = `contest`.`id`
			WHERE 1
				AND `contest`.`eventID` = $core->eventID
				AND `contestMember`.`memberID` = $core->memberID
		");

		echo printInformation("contestMember", $result, true, 'json');

	} else

	if ($method === "informAddress") {

		$eventID = getTokenForEvent();

		if (isset($_POST["url"])) {

			// Get the provided data
			$url = getAttribute($_POST["url"]);

			// Get some enrollment details
			$result = resourceForQuery(
				"SELECT
					`contestMember`.`url`
				FROM
					`contest`
				INNER JOIN
					`contestMember` ON `contestMember`.`contestID` = `contest`.`id`
				WHERE 1
					AND `contest`.`eventID` = $core->eventID
					AND `contestMember`.`memberID` = $core->memberID
			");

			if (mysqli_num_rows($result) > 0) {

				$update = resourceForQuery(
					"UPDATE
						`contest`
					INNER JOIN
						`contestMember` ON `contestMember`.`contestID` = `contest`.`id`
					SET
						`contestMember`.`url` = '$url',
						`contestMember`.`date` = NOW()
					WHERE 1
						AND `contest`.`eventID` = $core->eventID
						AND `contest`.`dateEnd` > NOW()
						AND `contestMember`.`memberID` = $core->memberID
				");

				if ($update) {
					// Return the desired data
					$data["memberID"] = $core->memberID;
					echo json_encode($data);
				} else {
					http_status_code(500, "update row failed");
				}

			} elseif (eventHasMember($core->eventID, $core->memberID)) {

				$result = resourceForQuery(
					"SELECT
						`contest`.`id`
					FROM
						`contest`
					WHERE 1
						AND `contest`.`eventID` = $core->eventID
						AND `contest`.`dateEnd` > NOW()
				");

				if (mysqli_num_rows($result) > 0)  {

					// Get one property
					$contestID = mysqli_result($result, 0, "id");

					$insert = resourceForQuery(
						"INSERT INTO
							`contestMember`
							(`contestID`, `memberID`, `url`, `date`)
						VALUES
							($contestID, $core->memberID, '$url', NOW())
					");

					if ($insert) {
						// Return the desired data
						$data["memberID"] = $core->memberID;
						echo json_encode($data);
					} else {
						http_status_code(500, "insert row failed");
					}

				} else {
					http_status_code(400, "contestID not found");
				}

			} else {
				http_status_code(406, "personID is not enrolled at this event");
			}
		} else {
			http_status_code(400, "url is a required parameter");
		}

	} else

	{ http_status_code(501); }

// ------------------------------------------------------------------------------------------- //
?>