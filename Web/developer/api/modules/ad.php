<?php
// -------------------------------------- AD --------------------------------------- //

	if ($method === "getAds") {

		if (isset($_GET['eventID'])) {

			$eventID = getAttribute($_GET['eventID']);

			$result = resourceForQuery(
				"SELECT
					`ad`.`id`,
					`ad`.`image`
				FROM
					`ad`
				WHERE 1
					AND `ad`.`eventID` = $eventID
			");

			echo printInformation("ad", $result, true, 'json');

		} else {
			http_status_code(400, "eventID is a required parameter");
		}

	} else

	if ($method === "seenAd") {

		if (isset($_GET['adID'])) {

			$adID = getAttribute($_GET['adID']);

			$result = resourceForQuery(
				"INSERT INTO
					`adMember`
					(`adID`, `memberID`, `date`)
				VALUES
					($adID, $core->memberID, NOW())
			");

			if ($format == "json") {
				$data["adID"] = $adID;
				echo json_encode($data);
			}

		} else {
			http_status_code(400, "adID is a required parameter");
		}

	} else

// ------------------------------------------------------------------------------------------- //
			
	{ http_status_code(501); }
	
?>