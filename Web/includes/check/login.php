<?php
// Include global header
include_once(__DIR__ . "/../header.php");
// Make sure that the attempt is valid
include_once(__DIR__ . "/security.php");

////////////////////////////////////////
// LOGIN
////////////////////////////////////////

if (isset($_POST["email"]) && isset($_POST["password"])) {

	$email = getEmptyAttribute($_POST["email"]);
	$password = getEmptyAttribute($_POST["password"]);

	$result = resourceForQuery(
		"SELECT
			`member`.`id`,
			`member`.`name`,
			`member`.`password`,
			SUM(`memberSessions`.`browser`) AS `sessionAmount`
		FROM
			`member`
		LEFT JOIN
			`memberSessions` ON `memberSessions`.`memberID` = `member`.`id`
		WHERE 1
			AND BINARY `member`.`email` = '$email'
		GROUP BY
			`memberSessions`.`memberID`
	");

	if (mysql_num_rows($result) == 1) {
		
		$hash = mysql_result($result, 0, "password");

		if (Bcrypt::check($password, $hash)) {

			$core->memberID = mysql_result($result, 0, "id");
			$core->name = mysql_result($result, 0, "name");

			// Create a new unique random id for the given session
			do {
				$sessionKey = Bcrypt::hash($hash);
				$resultSession = resourceForQuery(
					"SELECT
						`memberSessions`.`id`
					FROM
						`memberSessions`
					WHERE
						`memberSessions`.`sessionKey` = '$sessionKey'
				");

			} while (mysql_num_rows($resultSession) != 0);

			// Store it on our database
			$insert = resourceForQuery(
				"INSERT INTO
					`memberSessions`
					(`memberID`, `browser`, `sessionKey`)
				VALUES
					($core->memberID, 1, '$sessionKey')
			");

			// Remove the last session if the member went above the limit
			if (mysql_result($result, 0, "sessionAmount") > 5) {
				// Remove the last sessionKey from the database
				$delete = resourceForQuery(
					"DELETE FROM
						`memberSessions`
					WHERE 1
						AND `memberSessions`.`memberID` = $core->memberID
					ORDER BY
						`memberSessions`.`id` ASC
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

				$path = substr($_SERVER['REQUEST_URI'], 0, strrpos($_SERVER['REQUEST_URI'], "/") + 1);
				setcookie($security->key, $sessionKey, time() + 60*60*24*30, "/");
				header("Location: $path");
				exit;
			}
		} else {
			$_POST["login_error"] = "Senha inválida";
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
		$_POST["login_error"] = "Pessoa não encontrada";
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
			`member`.`password`
		FROM
			`member`
		LEFT JOIN
			`memberSessions` ON `memberSessions`.`memberID` = `member`.`id`
		WHERE
			`memberSessions`.`sessionKey` = '$hash'
	");

	if (mysql_num_rows($result) == 1) {
		$core->auth = true;

		$core->memberID = mysql_result($result, 0, "id");
		$core->name = mysql_result($result, 0, "name");

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
		$path = substr($_SERVER['REQUEST_URI'], 0, strrpos($_SERVER['REQUEST_URI'], "/") + 1);
		setcookie($security->key, '', 0, "/");
		header("Location: $path");	
		exit();
	}
}

////////////////////////////////////////
// EVENT
////////////////////////////////////////

	validateEvent();

?>