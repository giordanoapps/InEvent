<?php
header('Content-Type:text/html; charset=UTF-8');

// Connection
include_once("connection.php");

// Social
include_once("social.php");

// Singletons
include_once("singleton/core.php");
include_once("singleton/security.php");

// Functions
include_once("function/bcrypt.php");
include_once("function/format.php");
include_once("function/generic.php");
include_once("function/notification.php");
include_once("function/security.php");
include_once("function/utils.php");

// Extra
include_once("wrap.php");
include_once("queries.php");

// Set the default time zone
mysql_query("SET time_zone = '0:00'");
date_default_timezone_set('America/Sao_Paulo');

// Disable error reporting
if ($globalDev == 0) {
	error_reporting(0);
} else {
	error_reporting(E_ALL);
}

?>