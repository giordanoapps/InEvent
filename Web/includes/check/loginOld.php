<?php
// Make sure that the attempt is valid
include_once(__DIR__ . "/../header.php");
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
		"SELECT
			`member`.`id`,
			`member`.`name`,
			`member`.`password`,
			`member`.`companyID`,
			`member`.`groupID`,
			`member`.`permission`,
			`member`.`sessionKey`,
			`member`.`sessionAmount`
		FROM
			`member`
		WHERE 1
			AND `member`.`name` = '$name'
	");
	
	if (mysql_num_rows ($result) > 0) {
		
		$hash = mysql_result($result, 0, "password");

		if (Bcrypt::check($password, $hash)) {

			$core->companyID = mysql_result($result, 0, "companyID");
			$core->memberID = mysql_result($result, 0, "id");
			$core->groupID = mysql_result($result, 0, "groupID");
			$core->name = mysql_result($result, 0, "name");
			$core->permission = mysql_result($result, 0, "permission");
			
			// Allow to log in on up to three places at the same time
			if (mysql_result($result, 0, "sessionAmount") < 2) {
				$sessionKey = mysql_result($result, 0, "sessionKey");

				$insert = resourceForQuery(
					"UPDATE
						`member`
					SET
						`member`.`sessionAmount` = `sessionAmount`+1
					WHERE 
						`member`.`id` = $core->memberID
				");

			} else {
				// Create a unique random id for the given session
				do {
					$sessionKey = Bcrypt::hash($hash);
					$resultSession = resourceForQuery(
						"SELECT
							`member`.`sessionKey`
						FROM
							`member`
						WHERE
							`member`.`sessionKey` = '$sessionKey'
					");

				} while (mysql_num_rows($resultSession) != 0);

				// When we find the id, we store it on our database
				$insert = resourceForQuery(
					"UPDATE
						`member`
					SET 
						`member`.`sessionKey` = '$sessionKey',
						`member`.`sessionAmount` = 0
					WHERE
						`member`.`id` = $core->memberID
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

	$hash = htmlentities($_COOKIE[$security->key]);
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
			`member`.`sessionKey` = '$hash'
	");

	if (mysql_num_rows($result) == 1) {
		$core->auth = true;

		$core->companyID = mysql_result($result, 0, "companyID");
		$core->memberID = mysql_result($result, 0, "id");
		$core->groupID = mysql_result($result, 0, "groupID");
		$core->name = mysql_result($result, 0, "name");
		$core->permission = mysql_result($result, 0, "permission");

		$insert = resourceForQuery(
			"UPDATE
				`loginAttempts`
			SET
				`loginAttempts`.`attempts` = 0,
				`loginAttempts`.`date` = NOW()
			WHERE
				`loginAttempts`.`remote` = INET_ATON('$security->remote')
		");
	}
}

?>