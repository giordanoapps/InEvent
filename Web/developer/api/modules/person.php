<?php
// ----------------------------------------- PERSON ----------------------------------------- //

	if ($method === "signIn") {

		if (isset($_GET["email"]) && isset($_GET["password"])) {

			// Get some properties
			$email = getAttribute($_GET['email']);
			$password = getAttribute($_GET['password']);

			// Return the desired data
			$data = processLogIn($email, $password);
			echo json_encode($data);

		} else {
			http_status_code(400, "email and password are required parameters");
		}
				
	} else

    if ($method === "signInWithLinkedIn") {

		if (isset($_GET["linkedInToken"])) {

			$linkedInToken = getAttribute($_GET["linkedInToken"]);

			// Create a cURL request
		    $ch = curl_init();
		    $baseURL = "https://api.linkedin.com/v1/people/~:(id,first-name,last-name,email-address,picture-url)?oauth2_access_token=" . $linkedInToken . "&format=json";
		    curl_setopt($ch, CURLOPT_URL, $baseURL);
		    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		    $userProfile = json_decode(curl_exec($ch), true);

			if (count($userProfile) > 0) {
				$linkedInID = $userProfile['id'];
				$name = $userProfile['firstName'] . $userProfile['lastName'];
				$email = $userProfile['emailAddress'];
				$image = $userProfile['pictureUrl'];

				if (!empty($linkedInID) && !empty($name) && !empty($email) && !empty($image)) {
					// We now see if the current member has a profile with us
					$result = resourceForQuery(
						"SELECT
							`member`.`id`,
							`member`.`name`,
							`member`.`linkedInID`,
							COALESCE(`memberSessions`.`sessionKey`, '') AS `sessionKey`
						FROM
							`member`
						LEFT JOIN
							`memberSessions` ON `memberSessions`.`memberID` = `member`.`id`
						WHERE 0
							OR `member`.`linkedInID` = '$linkedInID'
							OR BINARY `member`.`email` = '$email'
						ORDER BY
							`memberSessions`.`id` DESC
					");

					// Member already has a profile with us
					if (mysqli_num_rows($result) > 0) {

						$memberID = mysqli_result($result, 0, "id");
						$name = mysqli_result($result, 0, "name");
						$tokenID = mysqli_result($result, 0, "sessionKey");
						$savedSocialID = mysqli_result($result, 0, "linkedInID");

						// Update the facebook token if necessary
						if (empty($savedSocialID)) {
							$update = resourceForQuery(
								"UPDATE
									`member`
								SET
									`member`.`image` = '$image',
									`member`.`linkedInID` = '$linkedInID'
								WHERE 1
									AND `member`.`id` = $memberID
							");
						}

						// Get the member details and events
						$details = getMemberDetails($memberID);
						$events = getMemberEvents($memberID);

						// Return some information
						$details["data"][0]["events"] = $events["data"];
						$details["data"][0]["tokenID"] = $tokenID;

						echo json_encode($details["data"][0]);

					} else {

						// Create a random password for the newly created member
						$password = "123456";
						// Create the member
						$memberID = createMember(array("name" => $name, "password" => $password, "email" => $email, "linkedInID" => $linkedInID));

						if ($memberID != 0) {
							// Return the desired data
							$data = processLogIn($email, $password);
							echo json_encode($data);
						} else {
							http_status_code(500);
						}
					}
				} else {
					// No user, return a non authenticated code
					http_status_code(400, "linkedInID, name, email and image are required parameters");
				}
			} else {
				// No user, return a non authenticated code
				http_status_code(401, "personID is not authenticated");
			}
		} else {
			http_status_code(400, "linkedInToken is a required parameter");
		}
				
	} else

	if ($method === "signInWithFacebook") {

		if (isset($_GET["facebookToken"])) {

			$facebookToken = getAttribute($_GET["facebookToken"]);
			$facebook->setAccessToken($facebookToken);

			try {
				$userProfile = $facebook->api('/me', 'GET');
				$facebookID = (isset($userProfile['id'])) ? $userProfile['id'] : 0;
				$name = (isset($userProfile['name'])) ? $userProfile['name'] : "";
				$email = (isset($userProfile['email'])) ? $userProfile['email'] : "";

				if (!empty($facebookID) && !empty($name) && !empty($email)) {
					// We now see if the current member has a profile with us
					$result = resourceForQuery(
						"SELECT
							`member`.`id`,
							`member`.`name`,
							`member`.`facebookID`,
							COALESCE(`memberSessions`.`sessionKey`, '') AS `sessionKey`
						FROM
							`member`
						LEFT JOIN
							`memberSessions` ON `memberSessions`.`memberID` = `member`.`id`
						WHERE 0
							OR `member`.`facebookID` = $facebookID
							OR BINARY `member`.`email` = '$email'
						ORDER BY
							`memberSessions`.`id` DESC
					");

					// Member already has a profile with us
					if (mysqli_num_rows($result) > 0) {

						$memberID = mysqli_result($result, 0, "id");
						$name = mysqli_result($result, 0, "name");
						$tokenID = mysqli_result($result, 0, "sessionKey");
						$savedSocialID = mysqli_result($result, 0, "facebookID");

						// Update the facebook token if necessary
						if (empty($savedSocialID)) {
							$update = resourceForQuery(
								"UPDATE
									`member`
								SET
									`member`.`facebookID` = $facebookID
								WHERE 1
									AND `member`.`id` = $memberID
							");
						}

						// Get the member details and events
						$details = getMemberDetails($memberID);
						$events = getMemberEvents($memberID);

						// Return some information
						$details["data"][0]["events"] = $events["data"];
						$details["data"][0]["tokenID"] = $tokenID;

						echo json_encode($details["data"][0]);

					} else {

						// Create a random password for the newly created member
						$password = "123456";
						// Create the member
						$memberID = createMember(array("name" => $name, "password" => $password, "email" => $email, "facebookID" => $facebookID));

						if ($memberID != 0) {
							// Return the desired data
							$data = processLogIn($email, $password);
							echo json_encode($data);
						} else {
							http_status_code(500);
						}
					}
				} else {
					// No user, return a non authenticated code
					http_status_code(400, "facebookID, name and email are required parameters");
				}
			} catch(FacebookApiException $e) {
				// If the user is logged out, you can have a 
				// user ID even though the access token is invalid.
				// In this case, we'll get an exception, so we'll
				// just ask the user to login again here.
				http_status_code(503, "facebook error");
			}
		} else {
			http_status_code(400, "facebookToken is a required parameter");
		}
				
	} else

	if ($method === "getDetails") {

		$tokenID = getToken();

		// Get the member details and events
		$details = getMemberDetails($core->memberID);
		$events = getMemberEvents($core->memberID);

		// Return some information
		$details["data"][0]["events"] = $events["data"];

		echo json_encode($details["data"][0]);

	} else

	if ($method === "edit") {

		$tokenID = getToken();

		if (isset($_GET['name']) && isset($_POST['value'])) {

			$name = getAttribute($_GET['name']);
			$value = getEmptyAttribute($_POST['value']);
			
			// We list all the fields that can be edited by the activity platform
			$validFields = array("name", "role", "company", "cpf", "rg", "usp", "telephone", "city", "email", "university", "course", "facebookID", "linkedInID");

			if (in_array($name, $validFields) == TRUE) {

				$update = resourceForQuery(
					"UPDATE
						`member`
					SET
						`$name` = '$value'
					WHERE
						`member`.`id` = $core->memberID
				");

				// Return its data
				if ($format == "json") {
					$data["memberID"] = $core->memberID;
					echo json_encode($data);
				} else {
					http_status_code(405, "this format is not available");
				}

			} else {
				http_status_code(406, "name field doesn't exist");
			}
	    } else {
	    	http_status_code(404, "name and value are required parameters");
	    }

	} else

	if ($method === "enroll") {

		if (isset($_REQUEST["name"]) && isset($_REQUEST["email"])) {

			// Make sure that the user is not creating multiple accounts
			// include_once("../../includes/registrationCheck.php");

			// Get the provided data
			$email = getAttribute($_REQUEST["email"]);

			// See if the person exists
			$result = resourceForQuery(
				"SELECT
					`member`.`name`
				FROM
					`member`
				WHERE 0
					OR BINARY `member`.`email` = '$email'
			");

			if (mysqli_num_rows($result) == 0) {

				// Save the password for later
				$password = (isset($_REQUEST["password"])) ? getAttribute($_REQUEST["password"]) : "123456";
				
				// Create the member
				$memberID = createMember(array_map("getEmptyAttribute", $_REQUEST));

				if ($memberID != 0) {
					// Return the desired data
					$data = processLogIn($email, $password);
					echo json_encode($data);
				} else {
					http_status_code(500, "Couldn't create memberID");
				}
			} else {
				http_status_code(303, "Email already exists");
			}
		} else {
			http_status_code(400, "name, password and email are required parameters");
		}

	} else

	if ($method === "sendRecovery") {

		if (isset($_GET["email"])) {

			// Get some properties
			$email = getAttribute($_GET["email"]);

			// Create a new random password
			$password = "123456";
			$hash = Bcrypt::hash($password);

			$update = resourceForQuery(
				"UPDATE
					`member`
				SET
					`member`.`password` = '$hash'
				WHERE 1
					AND BINARY `member`.`email` = '$email'
			");

			// Send an email if everything went alright
			if (mysqli_affected_rows_new() > 0) {
				sendRecoveryEmail($password, $email);
			} else {
				http_status_code(500, "Not a single email was found");
			}
		} else {
			http_status_code(400, "email is a required parameter");
		}

	} else

	if ($method === "subscribe") {

		if (isset($_GET["email"])) {

			// Get some properties
			$email = getAttribute($_GET["email"]);

			$update = resourceForQuery(
				"DELETE FROM
					`emailBlacklist`
				WHERE 1
					AND `emailBlacklist`.`email` = '$email'
			");

			// Send an email if everything went alright
			if (mysqli_affected_rows_new() > 0) {
				sendSubscribedEmail($email);
			} else {
				http_status_code(500, "Not a single email was found");
			}
		} else {
			http_status_code(400, "email is a required parameter");
		}

	} else

	if ($method === "unsubscribe") {

		if (isset($_GET["email"])) {

			// Get some properties
			$email = getAttribute($_GET["email"]);

			$update = resourceForQuery(
				"INSERT IGNORE INTO
					`emailBlacklist`
					(`email`, `date`)
				VALUES
					('$email', NOW())
			");

			// Send an email if everything went alright
			if (mysqli_affected_rows_new() > 0) {
				sendUnsubscribedEmail($email);
			} else {
				http_status_code(500, "Not a single email was found");
			}
		} else {
			http_status_code(400, "email is a required parameter");
		}

	} else

	if ($method === "changePassword") {

		$tokenID = getToken();

		if (isset($_GET["oldPassword"]) && isset($_GET["newPassword"])) {

			// Get some properties
			$oldPassword = getAttribute($_GET["oldPassword"]);
			$newPassword = getAttribute($_GET["newPassword"]);

			$result = resourceForQuery(
				"SELECT
					`member`.`password`,
					`member`.`email`
				FROM
					`member`
				WHERE 1
					AND `member`.`id` = $core->memberID
			");

			if (mysqli_num_rows($result) > 0) {

				$oldHash = mysqli_result($result, 0, "password");
				$email = mysqli_result($result, 0, "email");

				if (Bcrypt::check($oldPassword, $oldHash)) {

					$newHash = Bcrypt::hash($newPassword);

					$update = resourceForQuery(
						"UPDATE
							`member`
						SET
							`member`.`password` = '$newHash'
						WHERE 1
							AND `member`.`id` = $core->memberID
					");

					// Send an email if everything went alright
					if (mysqli_affected_rows_new() > 0) {
						sendPasswordChangeEmail($email);
					} else {
						http_status_code(500, "Not a single email was rewritten");
					}
				} else {
					http_status_code(406, "oldPassword is wrong");
				}
			} else {
				http_status_code(404, "memberID was not found");
			}
		} else {
			http_status_code(400, "oldPassword and newPassword are required parameters");
		}

	} else

	if ($method === "getWorkingEvents") {

		$tokenID = getToken();

		echo json_encode(getMemberEvents($core->memberID));

	} else

	{ http_status_code(501); }

// ------------------------------------------------------------------------------------------- //
?>