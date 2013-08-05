<?php
// ----------------------------------------- CONSULTANTS ----------------------------------------- //
		
	if ($method === "getNumberOfConsultants") {

		echo $core->informationCountForEnterpriseID($core->tableConsultant, $core->enterpriseID, "&& `user`!='-'", $format);
		
	} else
	
	if ($method === "getConsultants") {

		echo $core->informationForEnterpriseID($core->tableConsultant, $core->enterpriseID, "&& `user`!='-'", $format);
		
	} else 
	
	if ($method === "getSingleConsultant") {
		if (isset ($_GET['consultantID'])) {
			$consultantID = trim(htmlentities(utf8_decode($_GET['consultantID'])));
					
			echo $core->informationForEnterpriseIDForUniqueID($core->tableConsultant, $core->enterpriseID, $consultantID, "&& `user`!='-'", $format);
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