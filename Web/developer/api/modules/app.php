<?php
// -------------------------------------- APP --------------------------------------- //
	
	if ($method === "signIn") {

		if (isset($_GET["appID"]) && isset($_GET["cryptMessage"])) {

			// Get some properties
			$appID = getAttribute($_GET['appID']);
			$cryptMessage = getAttribute($_GET['cryptMessage']);

			// See if we have a app profile
			$result = resourceForQuery(
				"SELECT
					`app`.`id`,
					`app`.`secret`
				FROM
					`app`
				WHERE 1
					AND `app`.`id` = $appID
			");

			if (mysqli_num_rows($result) > 0) {

				// Get the app secret
				$appSecret = mysqli_result($result, 0, "secret");

				// Decode the message
				$params = json_decode(rtrim(mcrypt_decrypt(MCRYPT_RIJNDAEL_128, $appSecret, base64_decode($cryptMessage), MCRYPT_MODE_ECB), "\0"), true);

				if (isset($params["personID"])) {

					// Get our personID
					$personID = getAttribute($params["personID"]);

					$result = resourceForQuery(
						"SELECT
							COALESCE(`memberSessions`.`sessionKey`, '') AS `sessionKey`
						FROM
							`appMember`
						LEFT JOIN
							`memberSessions` ON `memberSessions`.`memberID` = `appMember`.`memberID`
						WHERE 1
							AND `appMember`.`memberID` = $personID
						ORDER BY
							`memberSessions`.`id` DESC
					");

					if (mysqli_num_rows($result) > 0) {

						$data["tokenID"] = mysqli_result($result, 0, "sessionKey");
						echo json_encode($data);

					} else {
						http_status_code(406, "personID does not have permission to appID");
					}
				} else {
					http_status_code(411, "personID was not correcly encripted");
				}
			} else {
				http_status_code(404, "appID was not found");
			}
		} else {
			http_status_code(400, "appID and cryptMessage are required parameters");
		}

	} else

	if ($method === "getDetails") {

		$tokenID = getToken();

		// Permission
		if (isset($_GET["appID"])) {

			// Get some properties
			$appID = getAttribute($_GET['appID']);

			if (appHasMember($appID, $core->memberID)) {

		        // Get details about the app
		        $result = getAppDetails($appID);

				if ($format == "json") {
					echo printInformation("app", $result, true, 'json');
				} elseif ($format == "html") {
					printApplication(mysqli_fetch_assoc($result), "memberID");
				} else {
					http_status_code(405, "this format is not available");
				}

			} else {
				http_status_code(401, "personID cannot access app");
			}
		} else {
			http_status_code(400, "appID is a required parameters");
		}

	} else

	if ($method === "create") {

		$tokenID = getToken();

		// Some properties
		$name = (isset($_POST['name']) && $_POST['name'] != "null") ? getAttribute($_POST['name']) : getAttribute("Nome da aplicação");

		// Create a random secret
		$secret = md5(str_shuffle("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"));

		// Insert a new app
		$insert = resourceForQuery(
			"INSERT INTO
				`app`
				(`name`, `secret`)
			VALUES
				('$name', '$secret')
		");

		$appID = mysqli_insert_id_new();

		// Insert ourselves inside the app
		$insert = resourceForQuery(
			"INSERT INTO
				`appMember`
				(`appID`, `memberID`)
			VALUES
				($appID, $core->memberID)
		");

		// Return its data
		if ($insert) {
			// Get details about the app
	        $result = getAppDetails($appID);

			if ($format == "json") {
				echo printInformation("app", $result, true, 'json');
			} elseif ($format == "html") {
				printApplication(mysqli_fetch_assoc($result), "memberID");
			} else {
				http_status_code(405, "this format is not available");
			}
		} else {
			http_status_code(500, "insert inside app has failed");
		}

	} else

	if ($method === "edit") {

		$tokenID = getToken();

		if (isset($_GET["appID"]) && isset($_GET['name']) && isset($_POST['value'])) {

			$name = getAttribute($_GET['name']);
			$value = getEmptyAttribute($_POST['value']);
			$appID = getAttribute($_GET['appID']);

			// Permission
			if (appHasMember($appID, $core->memberID)) {
			
				// We list all the fields that can be edited by the app platform
				$validFields = array("name");

				if (in_array($name, $validFields) == TRUE) {

					$update = resourceForQuery(
						"UPDATE
							`app`
						SET
							`$name` = '$value'
						WHERE
							`app`.`id` = $appID
					");

					// Get details about the app
			        $result = getAppDetails($appID);

					if ($format == "json") {
						echo printInformation("app", $result, true, 'json');
					} elseif ($format == "html") {
						printApplication(mysqli_fetch_assoc($result), "memberID");
					} else {
						http_status_code(405, "this format is not available");
					}

				} else {
					http_status_code(406, "name field doesn't exist");
				}
			} else {
				http_status_code(401, "personID doesn't work at event");
			}
	    } else {
	    	http_status_code(404, "appID, name and value are required parameters");
	    }

	} else

	if ($method === "remove") {

		$tokenID = getToken();

		if (isset($_GET["appID"])) {

			// Get some properties
			$appID = getAttribute($_GET['appID']);

			// Permission
			if (appHasMember($appID, $core->memberID)) {

				// Remove the app
				$delete = resourceForQuery(
					"DELETE FROM
						`app`
					WHERE 1
						AND `app`.`id` = $appID
				");

				// Remove people from app
				$delete = resourceForQuery(
					"DELETE FROM
						`appMember`
					WHERE 1
						AND `appMember`.`appID` = $appID
				");

		        // Get details about the app
		        $result = getAppDetails($appID);

				if ($format == "json") {
					echo printInformation("app", $result, true, 'json');
				} elseif ($format == "html") {
					printApplication(mysqli_fetch_assoc($result), "memberID");
				} else {
					http_status_code(405, "this format is not available");
				}

			} else {
				http_status_code(401, "personID cannot access app");
			}
		} else {
			http_status_code(400, "appID is a required parameters");
		}

	} else

// ------------------------------------------------------------------------------------------- //
			
	{ http_status_code(501); }
	
?>