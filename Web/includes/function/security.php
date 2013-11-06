<?php

	/**
	 * Wrappers, functions and code for database needs
	 */

	function logout() {
		// Domain to current path
		$path = substr($_SERVER['REQUEST_URI'], 0, strrpos($_SERVER['REQUEST_URI'], "/") + 1);

		$security = Security::singleton();

		setcookie($security->key, '', 0, "/");
		header("Location: $path");	
		exit("Monkeys are on the way to solve whatever you need!");
	}

	/**
	 * Validate event
	 * @param  integer $eventID [description]
	 * @return [type]           [description]
	 */
	function validateEvent($eventID = 0) {

		// Get the singleton
		$core = Core::singleton();

		if ($eventID == 0 && (isset($_GET["eventID"]) || isset($_GET["eventNick"]) || isset($_COOKIE["eventID"]))) {
			// See if a event has been selected
			if (isset($_GET["eventID"])) {
				$eventID = getAttribute($_GET["eventID"]);
			} elseif (isset($_GET["eventNick"])) {

				// Select the nickname
				$eventNick = getAttribute($_GET["eventNick"]);

				// Select the nickname from the database
				$result = resourceForQuery(
					"SELECT
						`event`.`id`
					FROM
						`event`
					WHERE 1
						AND `event`.`nickname` = '$eventNick'
				");

				$eventID = (mysqli_num_rows($result) > 0) ? mysqli_result($result, 0, "id") : 0;

			} elseif (isset($_COOKIE["eventID"])) {
				$eventID = getAttribute($_COOKIE["eventID"]);
			}
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
				AND `eventMember`.`memberID` = $core->memberID
		");

		// Append some information if the member has given it
		if ($core->eventID != 0) $query .= "AND `eventMember`.`eventID` = $core->eventID";

		$result = resourceForQuery($query);

		if (mysqli_num_rows($result) > 0) {
			$core->eventID = mysqli_result($result, 0, "eventID");
			$core->workAtEvent = (mysqli_result($result, 0, "roleID") != ROLE_ATTENDEE) ? true : false;
			$core->roleID = mysqli_result($result, 0, "roleID");
		} else {
			// Since permission is needed to be inside an event, we must reset the $core->eventID
			// $core->eventID = 0;
			$core->workAtEvent = false;
			$core->roleID = ROLE_ATTENDEE;
		}

		// Domain to current path
		$path = substr($_SERVER['REQUEST_URI'], 0, strrpos($_SERVER['REQUEST_URI'], "/") + 1);

		// Rewrite cookie
		setcookie("eventID", $core->eventID, time() + 60*60*24*30, "/");
	}

?>