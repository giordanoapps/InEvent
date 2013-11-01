<?php
// -------------------------------------- PHOTO --------------------------------------- //
	
	if ($method === "post") {

		$eventID = getTokenForEvent();

		if (isset($_POST['url'])) {

			$url = getAttribute($_POST['url']);

			// Permission
			if (eventHasMember($core->eventID, $core->memberID)) {

				// Insert a new activity
				$insert = resourceForQuery(
					"INSERT INTO
						`photo`
						(`eventID`, `url`, `date`)
					VALUES
						($eventID, '$url', NOW())
				");

				$photoID = mysql_insert_id();

				// Send a push notification
				// if ($globalDev == 0) pushActivityCreation($eventID, $photoID);

				// Return its data
				
				if ($insert) {
					if ($format == "json") {
						$data["photoID"] = $photoID;
						echo json_encode($data);
					} else {
						http_status_code(405, "this format is not available");
					}
				} else {
					http_status_code(500, "insert inside photo has failed");
				}

			} else {
				http_status_code(401, "personID is not enrolled at the event");
			}
	    } else {
	    	http_status_code(404, "url is a required parameter");
	    }

	} else

	if ($method === "getPhotos") {

		$eventID = getTokenForEvent();

		$result = resourceForQuery(
            "SELECT
                `photo`.`id`,
                `photo`.`url`,
                UNIX_TIMESTAMP(`photo`.`date`) AS `date`
            FROM
                `photo`
            WHERE 1
                AND `photo`.`eventID` = $eventID
            ORDER BY
                `photo`.`date` ASC
        ");

		echo printInformation("photo", $result, true, 'json');

	} else

	if ($method === "getSingle") {

		$tokenID = getToken();

		if (isset($_GET['photoID'])) {

			$photoID = getAttribute($_GET['photoID']);

			$result = resourceForQuery(
	            "SELECT
	                `photo`.`id`,
	                `photo`.`url`,
	                UNIX_TIMESTAMP(`photo`.`date`) AS `date`
	            FROM
	                `photo`
	            WHERE 1
	                AND `photo`.`id` = $photoID
	        ");

			echo printInformation("photo", $result, true, 'json');

		} else {
			http_status_code(400, "photoID is a required parameter");
		}

	} else

// ------------------------------------------------------------------------------------------- //
			
	{ http_status_code(501); }
	
?>