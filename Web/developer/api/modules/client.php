<?php
// -------------------------------------- CLIENTS --------------------------------------- //
	
	if ($method === "getNumberOfClients") {

		echo $core->informationCountForEnterpriseID($core->tableClient, $core->enterpriseID, '', $format);
		
	} else
	
	if ($method === "getClients") {

		echo $core->informationForEnterpriseID($core->tableClient, $core->enterpriseID, '', $format);
		
	} else 
	
	if ($method === "getSingleClient") {
		if (isset ($_GET['clientID'])) {
			$clientID = trim(htmlentities(utf8_decode($_GET['clientID'])));
					
			echo $core->informationForEnterpriseIDForUniqueID($core->tableClient, $core->enterpriseID, $clientID, '', $format);
		} else {
			http_status_code(400);
		}

	} else 
	
	if ($method === "createMember") {
		if (isset ($_GET['seconds'])) {
			$delay = trim(htmlentities(utf8_decode($_GET['seconds'])));
			
			echo $core->notificationsForIDWithDelay($core->userID, $delay);
		} else {
			http_status_code(400);
		}
		
	} else 
	
	if ($method === "updateMember") {
		
		if (isset ($_GET['seconds'])) {
			$delay = trim(htmlentities(utf8_decode($_GET['seconds'])));
		
			echo $core->newNotificationsForIDWithDelay($core->userID, $delay);
		} else {
			http_status_code(400);
		}
		
	} else
		
	{ http_status_code(501); }

// ------------------------------------------------------------------------------------------- //
?>