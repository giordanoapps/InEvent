<?php
header('Content-Type:text/html; charset=UTF-8');

// Connection
include_once("connection.php");

// Constant
include_once("constant.php");

// Essential functions
include_once("function/bcrypt.php");
include_once("function/generic.php");

// Social
include_once("social.php");

// Singletons
include_once("singleton/core.php");
include_once("singleton/security.php");

// Other functions
include_once("function/format.php");
include_once("function/notification.php");
include_once("function/security.php");
include_once("function/utils.php");

// Extra
include_once("email.php");
include_once("push.php");
include_once("queries.php");
include_once("wrap.php");

// Set the default time zone
mysql_query("SET time_zone = '+00:00'");
date_default_timezone_set('Etc/GMT+3');
setlocale(LC_ALL, "pt_BR", "pt_BR.iso-8859-1", "pt_BR.utf-8", "portuguese");

if ($globalDev == 0) {
	// Disable error reporting
	error_reporting(0);
	ini_set('display_errors', 'Off');
} else {
	// Disable error reporting
	error_reporting(E_ALL);
	ini_set('display_errors', 'On');
}

?>