<?php
// -------------------------------------- PROJECT --------------------------------------- //
	
	if ($method === "getNumberOfProjects") {

		echo $core->informationCountForEnterpriseID($core->tableProject, $core->enterpriseID, '', $format);
		
	} else
	
	if ($method === "getProjects") {

		$projects = $core->informationForEnterpriseID($core->tableProject, $core->enterpriseID, '', 'object');
		// ProjectsData by reference
		$projectData = &$projects["data"];

		// We define the tables that must be searched for trying to find the selected project
		$tableProjects = array($core->tableProjectMembers, $core->tableProjectClients, $core->tableProjectConsultants, $core->tableProjectHistory);

		for ($i = 0; $i < count($projectData); $i++) { 

			// The current project id from the retrieved project data
			$projectID = $projectData[$i]["id"];

			// Project People (Members, Clients and Consultants) and Project History
			for ($j = 0; $j < count($tableProjects); $j++) {
				$query = "SELECT * FROM $tableProjects[$j] WHERE `projectID`=$projectID";
				$result = mysql_query($query) or die ("Error in query: $query. " . mysql_error());

				// Get the project object, add a new property with the table name and inform that it is an array (so we can add the people)
				$projectData[$i][$tableProjects[$j]] = array();

				// If the table is history, we gotta serialize everything inside one array
				if ($tableProjects[$j] == $core->tableProjectHistory) {
					// We fetch the information as an object
					$projectHistory = $core->printInformation($core->tableProjectHistory, $result, true, 'object');
					// And append the data to the table property on our project object
					$projectData[$i][$tableProjects[$j]] = $projectHistory["data"];
				} else {
					// Loop through all the rows and get each person
					for ($k = 0; $k < mysql_num_rows($result); $k++) {
						// Get the project person table and append a new person
						$projectData[$i][$tableProjects[$j]][$k] = mysql_result($result, $k, "personID");
					}
				}
				
			}

		}

		echo json_encode($projects);
		
	} else 
	
	if ($method === "getSingleProject") {
		if (isset ($_GET['projectID'])) {
			$projectID = trim(htmlentities(utf8_decode($_GET['projectID'])));
					
			echo $core->informationForEnterpriseIDForUniqueID($core->tableProject, $core->enterpriseID, $projectID,  '', $format);
		} else {
			http_status_code(400);
		}

	} else 

	if ($method === "getStates") {

		echo $core->informationForTable($core->tableProjectStatus,  '', $format);

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