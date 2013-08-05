<?php
// -------------------------------------- MEMBER --------------------------------------- //

	if ($method === "signIn") {
	
		if (isset ($_GET['name']) && isset ($_GET['password'])) {
			$name = getAttribute($_GET['name']);
			$password = getAttribute($_GET['password']);

			$remote = $_SERVER['REMOTE_ADDR'];

			$result = resourceForQuery(
			// echo (
				"SELECT
					`member`.`id`,
					`member`.`name`,
					`memberDetail`.`password`,
					COUNT(`loginSessions`.`id`) - SUM(`loginSessions`.`browser`) AS `sessionAmount`
				FROM
					`member`
				INNER JOIN
					`memberDetail` ON `memberDetail`.`id` = `member`.`id`
				LEFT JOIN
					`loginSessions` ON `loginSessions`.`memberID` = `member`.`id`
				WHERE 1
					AND BINARY `member`.`name` = '$name'
					AND `member`.`anonymous` = 0
				GROUP BY
					`loginSessions`.`memberID`
			");

			if (mysql_num_rows($result) == 1) {

				$hash = mysql_result($result, 0, "password");

				if (Bcrypt::check($password, $hash)) {

					$core->name = mysql_result($result, 0, "name");
					$core->memberID = mysql_result($result, 0, "id");

					// Create a unique random id for the given session
					do {
						$sessionKey = Bcrypt::hash($hash);
						$resultSession = resourceForQuery(
							"SELECT
								`loginSessions`.`id`
							FROM
								`loginSessions`
							WHERE
								`loginSessions`.`sessionKey` = '$sessionKey'
						");

					} while (mysql_num_rows($resultSession) != 0);

					// Store it on our database
					$insert = resourceForQuery(
						"INSERT INTO
							`loginSessions`
							(`memberID`, `browser`, `sessionKey`)
						VALUES
							($core->memberID, 0, '$sessionKey')
					");
					
					// Remove the last session if the member went above the limit
					if (mysql_result($result, 0, "sessionAmount") > 5) {
						// Remove the last sessionKey from the database
						$delete = resourceForQuery(
							"DELETE FROM
								`loginSessions`
							WHERE 1
								AND `loginSessions`.`memberID` = $core->memberID
							ORDER BY
								`loginSessions`.`id` ASC
							LIMIT 1
						");
					}

					// Only authenticate if the insertion was carried correctly
					if ($insert) {
						$core->auth = true;
						
						// Reset the login count
						$insert = resourceForQuery(
							"UPDATE
								`loginAttempts`
							SET
								`loginAttempts`.`attempts` = 0,
								`loginAttempts`.`date` = NOW()
							WHERE
								`loginAttempts`.`remote` = INET_ATON('$remote')
						");

						// Return some information
						$data["name"] = $name;
						$data["tokenID"] = $sessionKey;
						
						echo json_encode($data);
					} else {
						http_status_code(500);
					}
				} else {
					resourceForQuery(
						"UPDATE
							`loginAttempts`
						SET
							`loginAttempts`.`attempts` = `attempts`+1,
							`loginAttempts`.`date` = NOW()
						WHERE
							`loginAttempts`.`remote` = INET_ATON('$remote')
					");

					http_status_code(401);
				}
			} else {
				resourceForQuery(
					"UPDATE
						`loginAttempts`
					SET
						`loginAttempts`.`attempts` = `attempts`+1,
						`loginAttempts`.`date` = NOW()
					WHERE
						`loginAttempts`.`remote` = INET_ATON('$remote')
				");

				http_status_code(401);
			}
		} else {
			http_status_code(400);
		}
	} else 

	if ($method === "getNumberOfMembers") {

		echo informationCountForEnterpriseID("member", $core->companyID, "&& `name` != '-'", $format);
		
	} else
	
	if ($method === "getMembers") {

		echo informationForEnterpriseID("member", $core->companyID, "&& `name` != '-'", $format);
		
	} else 
	
	if ($method === "getSingleMember") {

		if (isset ($_GET['memberID'])) {
			$memberID = getAttribute($_GET['memberID']);

			echo informationForEnterpriseIDForUniqueID("member", $core->companyID, $memberID, "&& `name` != '-'", $format);
		} else {
			http_status_code(400);
		}

	} else 
	
	if ($method === "createMember") {

		if (isset ($_GET['name']) && isset ($_GET['password'])) {
			$name = getAttribute($_GET['name']);
			$password = getAttribute($_GET['password']);

			if ($core->permission >= 10) {

			} else {
				http_status_code(401);	
			}
			
		} else {
			http_status_code(400);
		}
		
	} else 
	
	if ($method === "updateMember") {
		
		if (isset ($_GET['details'])) {
			$details = getAttribute($_GET['details']);
		
			if ($core->permission >= 10) {

			} else {
				http_status_code(401);	
			}

		} else {
			http_status_code(400);
		}
		
	} else
		
	{ http_status_code(501); }
	
// ------------------------------------------------------------------------------------------- //

?>