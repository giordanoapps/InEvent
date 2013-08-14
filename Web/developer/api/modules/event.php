<?php
// -------------------------------------- EVENT --------------------------------------- //
	
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

			$result = resourceForQuery(
				"SELECT
					`eventMember`.`id`
				FROM
					`eventMember`
				INNER JOIN
					`activity` ON `activity`.`eventID` = `eventMember`.`eventID`
				WHERE 1
					AND `activity`.`id` = $activityID
					AND `member`.`id` = $personID
			");

			if (mysql_num_rows($result) > 0) {
				
				$insert = resourceForQuery(
					"INSERT INTO
						`activityMember`
						(`activityID`, `memberID`, `approved`, `present`)
					VALUES
						($activityID, $personID, 1, 0)
				");

				if ($update) {
					// Return its data
					if ($format == "json") {
						$data["activityID"] = $activityID;
						echo json_encode($data);
					} elseif ($format == "html") {

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

	if ($method === "requestEnrollment") {

		$result = getCalendarsQuery($core->memberID);
		echo printInformation("shiftCalendar", $result, true, $format);
		
	} else

// ------------------------------------------------------------------------------------------- //
			
	{ http_status_code(501); }
	
?>