<?php

	// Our global wrapper
	include_once("../../includes/header.php");
	
	// Header
	include_once("header.php");

	// Modules
	switch ($namespace) {
		case "ad":
			include_once("modules/ad.php");
			break;

		case "activity":
			include_once("modules/activity.php");
			break;

		case "contest":
			include_once("modules/contest.php");
			break;

		case "event":
			include_once("modules/event.php");
			break;

		case "group":
			include_once("modules/group.php");
			break;

		case "notification":
			include_once("modules/notification.php");
			break;

		case "person":
			include_once("modules/person.php");
			break;

		case "photo":
			include_once("modules/photo.php");
			break;

		default:
			http_status_code(501);
			break;
	}
	
?>