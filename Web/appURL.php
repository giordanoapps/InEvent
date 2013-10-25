<?php

	$baseURL = "inevent://?";

	if (isset($_GET["eventID"])) $baseURL .= ("eventID=" . $_GET["eventID"] . "&");
	if (isset($_GET["tokenID"])) $baseURL .= ("tokenID=" . $_GET["tokenID"] . "&");
	if (isset($_GET["memberID"])) $baseURL .= ("memberID=" . $_GET["memberID"] . "&");
	if (isset($_GET["name"])) $baseURL .= ("name=" . $_GET["name"] . "&");

	$baseURL = substr($baseURL, 0, strlen($baseURL) - 1);

	header("Location: $baseURL");

?>