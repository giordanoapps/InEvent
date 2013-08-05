<?php
// ----------------------------------------- GROUPS ----------------------------------------- //
		
	if ($method === "getNumberOfGroups") {

		echo $core->informationCountForEnterpriseID($core->tableGroup, $core->enterpriseID, '', $format);
		
	} else
	
	if ($method === "getGroups") {

		echo $core->informationForEnterpriseID($core->tableGroup, $core->enterpriseID, '', $format);
		
	} else 
	
	if ($method === "getSingleGroup") {
		if (isset ($_GET['groupID'])) {
			$groupID = trim(htmlentities(utf8_decode($_GET['groupID'])));
					
			echo $core->informationForEnterpriseIDForUniqueID($core->tableGroup, $core->enterpriseID, $groupID, '', $format);
		} else {
			http_status_code(400);
		}

	} else 
	
	if ($method === "createGroup") {
		if (isset ($_GET['seconds'])) {
			$delay = trim(htmlentities(utf8_decode($_GET['seconds'])));
			
			echo $core->notificationsForIDWithDelay($core->userID, $delay);
		} else {
			http_status_code(400);
		}
		
	} else 
	
	if ($method === "updateGroup") {
		
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