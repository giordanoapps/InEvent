<?php

	/**
	 * Process the method that the user controller is using (empty by default)
	 */
	if (isset ($_GET['method'])) {
		$fullMethod = trim(htmlentities(utf8_decode($_GET['method'])));

		// Then we can split it right in the middle to get the namespace first
		$splitted = explode(".", $fullMethod);

		if (count($splitted) == 2) {
			$namespace = strtolower($splitted[0]);
			$method = $splitted[1];
		} else {
			// If we found an error (the user has provided a wrong method name), we return a bad request status code
			http_status_code(400);
		}
	} else {
		http_status_code(400);
	}

	/**
	 * If the namespace is not login, we can already set the tokenID (all operations will need them)
	 */
	if ($method !== "signIn") {
		// We make sure the user has provided it, otherwise we can already deny the request
		if (isset ($_GET['tokenID'])) {
			$tokenID = getAttribute($_GET['tokenID']);
			$remote = $_SERVER['REMOTE_ADDR'];

			$result = resourceForQuery(
				"SELECT
					`member`.`id`,
					`member`.`name`,
					`member`.`password`,
					`member`.`companyID`,
					`member`.`groupID`,
					`member`.`permission`
				FROM
					`member`
				WHERE
					`member`.`sessionKey` = '$tokenID'
			");

			if (mysql_num_rows($result) == 1) {
				$core->auth = true;

				$core->companyID = mysql_result($result, 0, "companyID");
				$core->memberID = mysql_result($result, 0, "id");
				$core->groupID = mysql_result($result, 0, "groupID");
				$core->name = mysql_result($result, 0, "name");
				$core->permission = mysql_result($result, 0, "permission");

				// Reset the login count
				$update = resourceForQuery(
					"UPDATE
						`loginAttempts`
					SET
						`loginAttempts`.`attempts` = 0,
						`loginAttempts`.`date` = NOW()
					WHERE
						`loginAttempts`.`remote` = INET_ATON('$remote')
				");

				// If everything went by smoothly, we can return the tokenID
				if (!$update) http_status_code(500);

			} else {
				// If the tokenID hasn't been found, we just deny the request
				http_status_code(401);
			}
		} else {
			http_status_code(400);
		}
	}

	/**
	 * Define the response format
	 */
	if (isset ($_GET['format'])) {
		$format = getAttribute($_GET['format']);
	} else {
		$format = "json";
	}
	

?>