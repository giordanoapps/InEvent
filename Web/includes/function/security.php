<?php

	/**
	 * Wrappers, functions and code for database needs
	 */

	function logout() {
		$filename = basename($_SERVER['PHP_SELF']);
		$path = str_replace($filename, '', $_SERVER['PHP_SELF']);

		$security = Security::singleton();

		setcookie($security->key, '', 0, $path);
		header("Location: $path");	
		exit("Monkeys are on the way to solve whatever you need!");
	}

	function validateEvent($eventID = 0) {

		// Get the singleton
		$core = Core::singleton();

		if ($eventID == 0 && isset($_REQUEST["eventID"]) && ctype_digit($_REQUEST["eventID"])) {
			// See if the user provided a company
			$eventID = isset($_GET["eventID"]) ? getAttribute($_GET["eventID"]) : getAttribute($_REQUEST["eventID"]);
		}
		
		// Assign the variable to the property
		$core->eventID = $eventID;

		$query = (
			"SELECT
				`eventMember`.`eventID`,
				`eventMember`.`roleID`
			FROM
				`eventMember`
			WHERE 1
				AND `eventMember`.`roleID` != @(ROLE_ATTENDEE)
				AND `eventMember`.`memberID` = $core->memberID
		");

		// Append some information if the member has given it
		if ($core->eventID != 0) $query .= "AND `eventMember`.`eventID` = $core->eventID";

		$result = resourceForQuery($query);

		if (mysql_num_rows($result) > 0) {
			$core->eventID = mysql_result($result, 0, "eventID");
			$core->workAtEvent = true;
			$core->roleID = mysql_result($result, 0, "roleID");
		} else {
			$core->eventID = 0;
			$core->workAtEvent = false;
			$core->roleID = ROLE_ATTENDEE;
		}

		// Domain current path
		$filename = basename($_SERVER['PHP_SELF']);
		$path = str_replace($filename, '', $_SERVER['PHP_SELF']);

		// Create company cookie if not present
		if (!isset($_COOKIE["eventID"])) setcookie("eventID", $core->eventID, time() + 60*60*24*30, $path);
	}

?>