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

		$appID = getTokenForApp();

		if ($core->workAtApp) {

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
				(`appID`, `memberID`, `roleID`)
			VALUES
				($appID, $core->memberID, @(ROLE_COORDINATOR))
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

		$appID = getTokenForApp();

		if (isset($_GET['name']) && isset($_POST['value'])) {

			$name = getAttribute($_GET['name']);
			$value = getEmptyAttribute($_POST['value']);

			// Permission
			if ($core->workAtApp) {
			
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
				http_status_code(401, "personID doesn't work at app");
			}
	    } else {
	    	http_status_code(404, "name and value are required parameters");
	    }

	} else

	if ($method === "remove") {

		$appID = getTokenForApp();

		// Permission
		if ($core->workAtApp) {

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

	} else

	if ($method === "renew") {

		$appID = getTokenForApp();

		// Permission
		if ($core->workAtApp) {

			// Create a new app secret
			$secret = md5(str_shuffle("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"));

			// Update the app secret
			$update = resourceForQuery(
				"UPDATE
					`app`
				SET
					`app`.`secret` = '$secret'
				WHERE 1
					AND `app`.`id` = $appID
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

	} else

	if ($method === "addPerson") {

		$appID = getTokenForApp();

		if (isset($_POST['name']) && $_POST['name'] != "null" && isset($_POST['email']) && $_POST['email'] != "null") {

			if ($core->workAtApp) {

				// Get some properties
				$name = getAttribute($_POST['name']);
				$email = getAttribute($_POST['email']);
				$password = "123456";

				// Get the person for the given email
				$personID = getPersonForEmail($email);
				if ($personID == 0) $personID = createMember(array("name" => $name, "password" => $password, "email" => $email));

			} else {
				http_status_code(401, "personID cannot access app");
			}
		} else {
			$personID = $core->memberID;
		}

		if ($personID != 0) {

			// Enroll a person inside an app
			$insert = resourceForQuery(
				"INSERT INTO
					`appMember`
					(`appID`, `memberID`, `roleID`)
				VALUES
					($appID, $personID, @(ROLE_COORDINATOR))
			");

			if ($insert) {
				// Return its data
				if ($format == "json") {
					$data["appID"] = $appID;
					echo json_encode($data);
				} elseif ($format == "html") {
					$result = getAppDetails($appID);
					printApplication(mysqli_fetch_assoc($result), "memberID");
				} else {
					http_status_code(405, "this format is not available");
				}
			} else {
				http_status_code(404, "personID insertion has failed");
			}
		} else {
			http_status_code(400, "personID cannot be null");
		}
		
	} else

	if ($method === "dismissPerson") {

		$appID = getTokenForApp();

		if (isset($_GET['personID']) && $_GET['personID'] != "null") {

			if ($core->workAtApp) {
				$personID = getAttribute($_GET['personID']);
			} else {
				http_status_code(401, "personID cannot access app");
			}

		} else {
			$personID = $core->memberID;
		}

		if ($personID != 0) {

			// Remove from app
			$delete = resourceForQuery(
				"DELETE FROM
					`appMember`
				WHERE 1
					AND `appMember`.`appID` = $appID
					AND `appMember`.`memberID` = $personID
			");
			
			if ($delete) {
				// Return its data
				if ($format == "json") {
					$data["activityID"] = $activityID;
					echo json_encode($data);
				} else {
					http_status_code(405, "this format is not available");
				}
			} else {
				http_status_code(500, "row deletion has failed");
			}
		} else {
			http_status_code(400, "personID cannot be null");
		}
		
	} else

	if ($method === "addEvent") {

		$appID = getTokenForApp();

		if (isset($_POST['name']) && $_POST['name'] != "null" && isset($_POST['nickname']) && $_POST['nickname'] != "null") {

			// Get some properties
			$name = getAttribute($_POST['name']);
			$nickname = getAttribute($_POST['nickname']);

			if ($core->workAtApp) {
				
				// Get the event for the given nickname
				$eventID = getEventForNickname($nickname);

				if ($eventID == 0) {

					// Create event
					$eventID = createEvent(array("name" => $name, "nickname" => $nickname));

					// Attach it to our app
					$insert = resourceForQuery(
						"INSERT INTO
							`appEvent`
							(`appID`, `eventID`)
						VALUES 
							($appID, $eventID)
					");

					if ($insert) {
						// Return its data
						if ($format == "json") {
							$data["appID"] = $appID;
							echo json_encode($data);
						} elseif ($format == "html") {
							$result = getAppDetails($appID);
							printApplication(mysqli_fetch_assoc($result), "memberID");
						} else {
							http_status_code(405, "this format is not available");
						}
					} else {
						http_status_code(500, "app attachment failed");
					}
				} else {
					http_status_code(406, "nickname is not available");
				}
			} else {
				http_status_code(401, "personID cannot access app");
			}
		} else {
			http_status_code(400, "personID cannot be null");
		}
		
	} else

// ------------------------------------------------------------------------------------------- //
			
	{ http_status_code(501); }
	
?>