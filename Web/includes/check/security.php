<?php
	
	// Get the singleton
	$security = Security::singleton();

	// Let's run a security check
	$security->remote = long2ip((float)$_SERVER['REMOTE_ADDR']);
	$result = resourceForQuery(
		"SELECT 
			`loginAttempts`.`remote`,
			`loginAttempts`.`attempts`,
			`loginAttempts`.`date`
		FROM
			`loginAttempts`
		WHERE 
			`remote` = INET_ATON('$security->remote')
	");

	// Create an entry if the current ip never tried to log in inside our system
	if (mysql_num_rows($result) == 0) {
		$insert = resourceForQuery("INSERT INTO `loginAttempts` (`remote`, `attempts`) VALUES (INET_ATON('$security->remote'), 0)");

		$security->attempts = 0;
		$timestamp = time();
	} else {
		$security->attempts = mysql_result($result, 0, "attempts");
		$timestamp = strtotime(mysql_result($result, 0, "date"));
	}

	// Verify if the current timestamp allows the ip to attemp another login
	if ($timestamp + 10*60 < time()) {
		$update = resourceForQuery(
			"UPDATE
				`loginAttempts`
			SET
				`loginAttempts`.`attempts` = 0
			WHERE
				`loginAttempts`.`remote` = INET_ATON('$security->remote')
		");
		$security->attempts = 0;
	}

	// If the number of attempts is not exorbitant, we can proceeed with our login call
	if ($security->attempts >= 2) {
		$_POST["login_error"] = "Conta Bloqueada";
		$insert = resourceForQuery(
			"UPDATE
				`loginAttempts`
			SET
				`loginAttempts`.`date` = NOW()
			WHERE
				`loginAttempts`.`remote` = INET_ATON('$security->remote')
		");

		if (strpos($_SERVER['PHP_SELF'], "developer/api")) {
			http_status_code(403);
		} else {
			return;
		}
	}

?>