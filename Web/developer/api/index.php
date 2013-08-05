<?php

	// Our global wrapper
	include_once("../../includes/header.php");
	
	// Header
	include_once("header.php");

	// Modules
	switch ($namespace) {
		case 'client':
			include_once("modules/client.php");
			break;

		case 'consultant':
			include_once("modules/consultant.php");
			break;

		case 'group':
			include_once("modules/group.php");
			break;

		case 'home':
			include_once("modules/home.php");
			break;

		case 'member':
			include_once("modules/member.php");
			break;

		case 'notification':
			include_once("modules/notification.php");
			break;

		case 'presence':
			include_once("modules/presence.php");
			break;

		case 'project':
			include_once("modules/project.php");
			break;

		default:
			http_status_code(501);
			break;
	}
	
?>