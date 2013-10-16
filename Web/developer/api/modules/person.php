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

	if ($method === "signInWithFacebook") {

		if (isset($_GET["facebookToken"])) {

			$facebookToken = getAttribute($_GET["facebookToken"]);

			$facebook->setAccessToken($facebookToken);
			$userID = $facebook->getUser();

			if ($userID) {
				// We have a user ID, so probably a logged in user.
				// If not, we'll get an exception, which we handle below.
				try {
					$userProfile = $facebook->api('/me?fields=email,name', 'GET');

					$name = $userProfile['name'];
					$email = $userProfile['email'];

					// We now see if the current member has a profile with us
					$result = resourceForQuery(
					// echo (
						"SELECT
							`member`.`id`,
							`member`.`name`,
							COALESCE(`memberSessions`.`sessionKey`, '') AS `sessionKey`
						FROM
							`member`
						LEFT JOIN
							`memberSessions` ON `memberSessions`.`memberID` = `member`.`id`
						WHERE 0
							OR BINARY `member`.`name` = '$name'
							OR BINARY `member`.`email` = '$email'
						ORDER BY
							`memberSessions`.`id` DESC
					");

					// Member already has a profile with us
					if (mysql_num_rows($result) > 0) {

						$name = mysql_result($result, 0, "name");
						$memberID = mysql_result($result, 0, "id");
						$tokenID = mysql_result($result, 0, "sessionKey");

						$events = getMemberEvents($memberID);

						// Return some information
						$data["name"] = $name;
						$data["memberID"] = $memberID;
						$data["events"] = $events["data"];
						$data["tokenID"] = $tokenID;

						echo json_encode($data);

					} else {

						// Create a random password for the newly created member
						$password = "123456";
						// Create the member
						$memberID = createMember($name, $password, $email);

						if ($memberID != 0) {
							// Return the desired data
							$data = processLogIn($email, $password);
							echo json_encode($data);
						} else {
							http_status_code(500);
						}
					}
				} catch(FacebookApiException $e) {
					// If the user is logged out, you can have a 
					// user ID even though the access token is invalid.
					// In this case, we'll get an exception, so we'll
					// just ask the user to login again here.
					http_status_code(503, "facebook error");
				}
			} else {
				// No user, return a non authenticated code
				http_status_code(401, "personID is not authenticated");
			}
		} else {
			http_status_code(400, "facebookToken is a required parameter");
		}
				
	} else

	if ($method === "edit" || $method === "enroll") {

		if (isset($_POST["name"]) && isset($_POST["email"])) {

			// Make sure that the user is not creating multiple accounts
			// include_once("../../includes/registrationCheck.php");

			// Get the provided data
			// Required
			$name = getAttribute($_POST["name"]);
			$password = ($method === "enroll") ? getAttribute($_POST["password"]) : "";
			$email = getAttribute($_POST["email"]);

			// Optional
			$cpf = (isset($_POST["cpf"])) ? getEmptyAttribute($_POST["cpf"]) : "";
			$rg = (isset($_POST["rg"])) ? getEmptyAttribute($_POST["rg"]) : "";
			$city = (isset($_POST["city"])) ? getEmptyAttribute($_POST["city"]) : "";
			$university = (isset($_POST["university"])) ? getEmptyAttribute($_POST["university"]) : "";
			$course = (isset($_POST["course"])) ? getEmptyAttribute($_POST["course"]) : "";
			$telephone = (isset($_POST["telephone"])) ? getEmptyAttribute($_POST["telephone"]) : "";
			$usp = (isset($_POST["usp"])) ? getEmptyAttribute($_POST["usp"]) : "";

			if ($method === "edit") {

				$tokenID = getToken();

				$update = resourceForQuery(
					"UPDATE
						`member`
					SET
						`name` = '$name',
						`cpf` = '$cpf',
						`rg` = '$rg',
						`usp` = '$usp',
						`telephone` = '$telephone',
						`city` = '$city',
						`email` = '$email',
						`university` = '$university',
						`course` = '$course'
					WHERE
						`member`.`id` = $core->memberID
				");

				if ($update) {
					$data["memberID"] = $core->memberID;
					echo json_encode($data);
				}

			} elseif ($method === "enroll") {

				// See if the person exists
				$result = resourceForQuery(
					"SELECT
						`member`.`name`
					FROM
						`member`
					WHERE 0
						OR BINARY `member`.`email` = '$email'
				");

				if (mysql_num_rows($result) == 0) {

					$memberID = createMember($name, $password, $email, $cpf, $rg, $usp, $telephone, $city, $university, $course);

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
				http_status_code(501);
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
			if (mysql_affected_rows() > 0) {
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
			if (mysql_affected_rows() > 0) {
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
			if (mysql_affected_rows() > 0) {
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

			if (mysql_num_rows($result) > 0) {

				$oldHash = mysql_result($result, 0, "password");
				$email = mysql_result($result, 0, "email");

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
					if (mysql_affected_rows() > 0) {
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