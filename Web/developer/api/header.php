<?php

	// Wrappers
	include_once("functions/activity.php");
	include_once("functions/event.php");
	include_once("functions/excel.php");
	include_once("functions/group.php");
	include_once("functions/person.php");
	include_once("functions/validation.php");

	/**
	 * Process the method that the user controller is using (empty by default)
	 */
	if (isset ($_GET['method'])) {
		$fullMethod = getAttribute($_GET['method']);

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
	 * Define the response format
	 */
	if (isset ($_GET['format'])) {
		$format = getAttribute($_GET['format']);
	} else {
		$format = "json";
	}

?>