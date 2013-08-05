<?php
// Include global header
include_once(__DIR__ . "/../header.php");
// Make sure that the attempt is valid
include_once(__DIR__ . "/security.php");

////////////////////////////////////////
// LOGIN
////////////////////////////////////////

if (isset($_POST["name"]) && isset($_POST["password"])) {

	$filename = basename($_SERVER['PHP_SELF']);
	$path = str_replace($filename, '', $_SERVER['PHP_SELF']);

	$name = getEmptyAttribute($_POST["name"]);
	$password = getEmptyAttribute($_POST["password"]);

	$result = resourceForQuery(
	// echo (
		"SELECT
			`member`.`id`,
			`member`.`name`,
			`member`.`password`,
			`member`.`companyID`,
			`member`.`groupID`,
			`member`.`permission`,
			SUM(`loginSessions`.`browser`) AS `sessionAmount`
		FROM
			`member`
		LEFT JOIN
			`loginSessions` ON `loginSessions`.`memberID` = `member`.`id`
		WHERE 1
			AND BINARY `member`.`name` = '$name'
		GROUP BY
			`loginSessions`.`memberID`
	");

	if (mysql_num_rows($result) == 1) {
		
		$hash = mysql_result($result, 0, "password");

		if (Bcrypt::check($password, $hash)) {

			$core->companyID = mysql_result($result, 0, "companyID");
			$core->memberID = mysql_result($result, 0, "id");
			$core->groupID = mysql_result($result, 0, "groupID");
			$core->name = mysql_result($result, 0, "name");
			$core->permission = mysql_result($result, 0, "permission");

			// Create a new unique random id for the given session
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
					($core->memberID, 1, '$sessionKey')
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
						`loginAttempts`.`remote` = INET_ATON('$security->remote')
				");

				setcookie($security->key, $sessionKey, time() + 60*60*24*30, $path);
				header("Location: $path");
				exit;
			}
		} else {
			$_POST["login_error"] = "Senha inválida!";
			$_POST["login_count"] = $security->attempts+1;
			$insert = resourceForQuery(
				"UPDATE
					`loginAttempts`
				SET
					`loginAttempts`.`attempts` = `attempts`+1,
					`loginAttempts`.`date` = NOW()
				WHERE
					`loginAttempts`.`remote` = INET_ATON('$security->remote')
			");
		}
	} else {
		$_POST["login_error"] = "Usuário não encontrado!";
		$_POST["login_count"] = $security->attempts+1;
		$insert = resourceForQuery(
			"UPDATE
				`loginAttempts`
			SET
				`loginAttempts`.`attempts` = `attempts`+1,
				`loginAttempts`.`date` = NOW()
			WHERE
				`loginAttempts`.`remote` = INET_ATON('$security->remote')
		");
	}

} elseif (isset($_COOKIE[$security->key])) {

	$hash = getAttribute($_COOKIE[$security->key]);
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
		LEFT JOIN
			`loginSessions` ON `loginSessions`.`memberID` = `member`.`id`
		WHERE
			`loginSessions`.`sessionKey` = '$hash'
	");

	if (mysql_num_rows($result) == 1) {
		$core->auth = true;

		$core->companyID = mysql_result($result, 0, "companyID");
		$core->memberID = mysql_result($result, 0, "id");
		$core->groupID = mysql_result($result, 0, "groupID");
		$core->name = mysql_result($result, 0, "name");
		$core->permission = mysql_result($result, 0, "permission");

		// Reset the login count
		$insert = resourceForQuery(
			"UPDATE
				`loginAttempts`
			SET
				`loginAttempts`.`attempts` = 0,
				`loginAttempts`.`date` = NOW()
			WHERE
				`loginAttempts`.`remote` = INET_ATON('$security->remote')
		");
	} else {
		$filename = basename($_SERVER['PHP_SELF']);
		$path = str_replace($filename, '', $_SERVER['PHP_SELF']);

		setcookie($security->key, '', 0, $path);
		header("Location: $path");	
		exit();
	}
}

?>