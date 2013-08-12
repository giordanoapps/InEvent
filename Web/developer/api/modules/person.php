<?php
// ----------------------------------------- PERSON ----------------------------------------- //

	if ($method === "signIn") {

		if (isset($_GET["member"]) && isset($_GET["password"])) {

			// Get some properties
			$member = getAttribute($_GET['member']);
			$password = getAttribute($_GET['password']);

			// Return the desired data
			$data = processLogIn($member, $password);
			echo json_encode($data);
		} else {
			http_status_code(400);
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
							`memberSessions`.`sessionKey`
						FROM
							`member`
						INNER JOIN
							`memberDetail` ON `memberDetail`.`id` = `member`.`id`
						INNER JOIN
							`memberSessions` ON `memberSessions`.`memberID` = `member`.`id`
						WHERE 0
							OR BINARY `member`.`name` = '$name'
							OR BINARY `memberDetail`.`email` = '$email'
						ORDER BY
							`memberSessions`.`id` DESC
					");

					// Member already has a profile with us
					if (mysql_num_rows($result) > 0) {

						$memberID = mysql_result($result, 0, "id");

						$companies = getMemberCompanies($memberID);

						// Return some information
						$data["name"] = mysql_result($result, 0, "name");
						$data["memberID"] = $memberID;
						$data["companies"] = $companies["data"];
						$data["tokenID"] = mysql_result($result, 0, "sessionKey");

						echo json_encode($data);

					} else {

						// Create a random password for the newly created member
						$password = md5((string)rand());
						// Create the member
						$memberID = createMember($name, $password, "", "", $email, 0);

						if ($memberID != 0) {
							// Return the desired data
							$data = processLogIn($name, $password);
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
					http_status_code(503);
				}
			} else {
				// No user, return a non authenticated code
				http_status_code(401);
			}
		} else {
			http_status_code(400);
		}
				
	} else

	if ($method === "enroll") {

		if (isset($_POST["member"]) && isset($_POST["password"]) && isset($_POST["email"])) {

			// Make sure that the user is not creating multiple accounts
			// include_once("../../includes/registrationCheck.php");

			// Get the provided data
			// Required
			$name = getAttribute($_POST["member"]);
			$password = getAttribute($_POST["password"]);
			$email = getAttribute($_POST["email"]);

			// Optional
			$cpf = getEmptyAttribute($_POST["cpf"]);
			$rg = getEmptyAttribute($_POST["rg"]);
			$telephone = getEmptyAttribute($_POST["telephone"]);

			$result = resourceForQuery(
				"SELECT
					`member`.`name`
				FROM
					`member`
				WHERE 0
					OR `member`.`name` = '$member'
					OR `member`.`email` = '$email'
			");

			if (mysql_num_rows($result) == 0) {

				// Insert the name 
				$insert = resourceForQuery(
					"INSERT INTO
						`member`
						(`name`, `password`, `cpf`, `rg`, `telephone`, `email`, `university`, `course`)
					VALUES 
						($name, '$password', '$cpf', '$rg', '$telephone', '$email', '$university', '$course')
				");

				$memberID = mysql_insert_id();

				if ($memberID != 0) {
					// Return the desired data
					$data = array("memberID", $memberID);
					echo json_encode($data);
				} else {
					http_status_code(500);
				}
			} else {
				http_status_code(303);
			}
		} else {
			http_status_code(400);
		}

	} else

	if ($method === "getEvents") {

		$tokenID = getToken();

		echo getMemberCompanies($core->memberID);

	} else

	{ http_status_code(501); }

// ------------------------------------------------------------------------------------------- //
?>