<?php
// -------------------------------------- GROUP --------------------------------------- //
	
	if ($method === "create") {

		$eventID = getTokenForEvent();

		// Permission
		if (eventHasMember($core->eventID, $core->memberID)) {

			// Some properties
			$name = (isset($_POST['name']) && $_POST['name'] != "null") ? getAttribute($_POST['name']) : "Grupo";

			// Insert a new activity
			$insert = resourceForQuery(
				"INSERT INTO
					`group`
					(
						`eventID`,
						`name`,
						`description`,
						`location`,
						`dateBegin`,
						`dateEnd`,
						`highlight`
					)
				VALUES
					(
						$eventID,
						'$name',
						'Descri&ccedil;&atilde;o do grupo',
						'Sua localidade',
						NOW(),
						DATE_ADD(NOW(), INTERVAL 2 HOUR),
						0
					)
			");

			$groupID = mysql_insert_id();

			// Send a push notification
			// if ($globalDev == 0) pushActivityCreation($eventID, $groupID);

			// Return its data
			if ($format == "json") {
				$data["groupID"] = $groupID;
				echo json_encode($data);
			} elseif ($format == "html") {
				$result = getGroupsForMemberAtGroupQuery($activityID, $core->memberID);
				printAgendaItem(mysql_fetch_assoc($result), "member");
			} else {
				http_status_code(405, "this format is not available");
			}

		} else {
			http_status_code(401, "personID is not enrolled at the event");
		}

	} else

	if ($method === "edit") {

		$groupID = getTokenForGroup();

		if (isset($_GET['name']) && isset($_POST['value'])) {

			$name = getAttribute($_GET['name']);
			$value = getEmptyAttribute($_POST['value']);

			// Permission
			if (eventHasMember($core->eventID, $core->memberID)) {
			
				// We list all the fields that can be edited by the activity platform
				$validFields = array("name", "description", "location", "dateBegin", "dateEnd", "highlight");

				if (in_array($name, $validFields) == TRUE) {

					// Date
					if ($name == "dateBegin" || $name == "dateEnd") {

						$timezone = date("P");

						$update = resourceForQuery(
							"UPDATE
								`group` 
							SET
								`$name` = CONVERT_TZ(STR_TO_DATE('$value', '%d/%m/%y %k:%i'), '$timezone', '+00:00')
							WHERE
								`group`.`id` = $groupID
						");

					// Highlight
					} elseif ($name == "highlight") {

						if ($value < 0 || $value > 1) $value = 0;

						$update = resourceForQuery(
							"UPDATE
								`group`
							SET
								`$name` = $value
							WHERE
								`group`.`id` = $groupID
						");

					// The rest
					} else {
						$update = resourceForQuery(
							"UPDATE
								`group`
							SET
								`$name` = '$value'
							WHERE
								`group`.`id` = $groupID
						");
					}

					// Send a push notification
					// if ($globalDev == 0) pushActivityUpdate(getEventForActivity($groupID), $groupID);

					// Return its data
					if ($format == "json") {
						$data["groupID"] = $groupID;
						echo json_encode($data);
					} elseif ($format == "html") {
						$result = getGroupsForMemberAtGroupQuery($activityID, $core->memberID);
						printAgendaItem(mysql_fetch_assoc($result), "member");
					} else {
						http_status_code(405, "this format is not available");
					}

				} else {
					http_status_code(406, "name field doesn't exist");
				}
			} else {
				http_status_code(401, "personID is not enrolled at the event");
			}
	    } else {
	    	http_status_code(404, "name and value are required parameters");
	    }

	} else

	if ($method === "remove") {

		$groupID = getTokenForGroup();

		// Permission
		if ($core->workAtEvent) {

			// Remove the group
			$delete = resourceForQuery(
				"DELETE FROM
					`group`
				WHERE 1
					AND `group`.`id` = $groupID
			");

			// Remove people from group
			$delete = resourceForQuery(
				"DELETE FROM
					`groupMember`
				WHERE 1
					AND `groupMember`.`groupID` = $groupID
			");

			// Send a push notification
			// if ($globalDev == 0) pushActivityRemove(getEventForActivity($groupID), $groupID);

			// Return its data
			if ($format == "json") {
				$data["groupID"] = $groupID;
				echo json_encode($data);
			} elseif ($format == "html") {
				$result = getGroupsForMemberAtGroupQuery($groupID, $core->memberID);
				printAgendaItem(mysql_fetch_assoc($result), "member");
			} else {
				http_status_code(405, "this format is not available");
			}

		} else {
			http_status_code(401, "personID doesn't work at event");
		}

	} else

	if ($method === "requestEnrollment") {

		$groupID = getTokenForGroup();

		if (isset($_GET['name']) && $_GET['name'] != "null" && isset($_GET['email']) && $_GET['email'] != "null") {

			if ($core->workAtEvent) {

				$name = getAttribute($_GET['name']);
				$email = getAttribute($_GET['email']);

				// Get the person for the given email
				$personID = getPersonForEmail($email);
				if ($personID == 0) $personID = createMember(array("name" => $name, "password" => "123456", "email" => $email));

				// Enroll the person at the event if necessary
				processEventEnrollmentWithGroup($groupID, $personID);

			} else {
				http_status_code(401, "personID doesn't work at event");
			}
		} else {
			$personID = $core->memberID;
		}

		if ($personID != 0) {

			// See if the member is enrolled at this activity
			$result = resourceForQuery(
				"SELECT
					`groupMember`.`id`
				FROM
					`groupMember`
				WHERE 1
					AND `groupMember`.`groupID` = $groupID
					AND `groupMember`.`memberID` = $personID
			");

			if (mysql_num_rows($result) == 0) {
				// Enroll people at the activity
				$success = processGroupEnrollment($groupID, $personID);
			} else {
				$success = true;
			}

			if ($success) {
				// Return its data
				if ($format == "json") {
					$result = getGroupsForMemberAtGroupQuery($groupID, $personID);
					echo printInformation("activity", $result, true, 'json');
				} elseif ($format == "html") {
					$result = getGroupsForMemberAtGroupQuery($groupID, $personID);
					printAgendaItem(mysql_fetch_assoc($result), "member");
				} else {
					http_status_code(405, "this format is not available");
				}
			} else {
				http_status_code(500, "insert inside activity has failed");
			}
		} else {
			http_status_code(400, "personID cannot be null");
		}
		
	} else

	if ($method === "dismissEnrollment") {

		$groupID = getTokenForGroup();

		if (isset($_GET['personID']) && $_GET['personID'] != "null") {

			if ($core->workAtEvent) {
				$personID = getAttribute($_GET['personID']);
			} else {
				http_status_code(401, "personID doesn't work at event");
			}
		} else {
			$personID = $core->memberID;
		}

		if ($personID != 0) {
				
			// Remove the current person
			$delete = resourceForQuery(
				"DELETE FROM
					`groupMember`
				WHERE 1
					AND `groupMember`.`groupID` = $groupID
					AND `groupMember`.`memberID` = $personID
			");

			$result = resourceForQuery(
				"SELECT
					`groupMember`.`id`,
					`groupMember`.`priori`,
					`groupMember`.`memberID`
				FROM
					`groupMember`
				WHERE 1
					AND `groupMember`.`groupID` = $groupID
					AND `groupMember`.`approved` = 0
				ORDER BY
					`groupMember`.`id` ASC
			");

			if ($delete) {
				// Return its data
				if ($format == "json") {
					$result = getGroupsForMemberAtGroupQuery($groupID, $personID);
					echo printInformation("activity", $result, true, 'json');
				} elseif ($format == "html") {
					$result = getGroupsForMemberAtGroupQuery($groupID, $core->memberID);
					printAgendaItem(mysql_fetch_assoc($result), "member");
				} else {
					http_status_code(405, "this format is not available");	
				}
			} else {
				http_status_code(500, "row deletion could not be completed");
			}
		} else {
			http_status_code(400, "groupID is a required parameter");
		}
		
	} else

	if (0
		|| $method === "confirmApproval"
		|| $method === "revokeApproval"
		|| $method === "confirmEntrance"
		|| $method === "revokeEntrance") {

		$groupID = getTokenForGroup();

		if (isset($_GET["personID"])) {

			// Get some properties
			$personID = getAttribute($_GET['personID']);

			if ($core->workAtEvent) {

				// See which field we want to update
				if ($method === "confirmApproval") {
					$attribute = "`groupMember`.`approved` = 1";
				} elseif ($method === "revokeApproval") {
					$attribute = "`groupMember`.`approved` = 0";
				} elseif ($method === "confirmEntrance") {
					$attribute = "`groupMember`.`present` = 1";
				} elseif ($method === "revokeEntrance") {
					$attribute = "`groupMember`.`present` = 0";
				}

				// Update based on the attribute
				$update = resourceForQuery(
					"UPDATE
						`groupMember`
					SET
						$attribute
					WHERE 1
						AND `groupMember`.`groupID` = $groupID
						AND `groupMember`.`memberID` = $personID
				");

				if ($update) {
					// Return its data
					if ($format == "json") {
						$data["personID"] = $personID;
						echo json_encode($data);
					} elseif ($format == "html") {
						$data["personID"] = $personID;
						echo json_encode($data);
					} else {
						http_status_code(405, "this format is not available");	
					}
				} else {
					http_status_code(500, "row update has failed");
				}
			} else {
				http_status_code(401, "personID doesn't work at event");
			}
		} else {
			http_status_code(400, "groupID and personID are required parameters");
		}
		
	} else

	if ($method === "getPeople") {

		$groupID = getTokenForGroup();

		if (isset($_GET["selection"])) {

			// Get some properties
			$selection = getAttribute($_GET['selection']);

			// Selection
			switch ($selection) {
				case 'approved':
					$complement = "AND `groupMember`.`approved` = 1";
					break;

				case 'denied':
					$complement = "AND `groupMember`.`approved` = 0";
					break;

				case 'unseen':
					$complement = "AND `groupMember`.`id` = 0"; // Don't need to implement it yet
					break;

				case 'paid':
					$complement = "AND `groupMember`.`paid` = 1";
					break;

				case 'present':
					$complement = "AND `groupMember`.`present` = 1";
					break;

				case 'all':
					$complement = "";
					break;

				default:
					$complement = "";
					// http_status_code(405, "this format is not available");
					break;
			}

			// Order
			if (isset($_GET["order"]) && $_GET["order"] != "null") {

				$order = getAttribute($_GET['order']);

				// Set all the fields that can be ordered
				$orderFilter = array(
					"memberID" => "ASC",
					"enrollmentID" => "ASC",
					"position" => "ASC",
					"name" => "ASC",
					"telephone" => "ASC",
					"email" => "ASC",
					"approved" => "DESC",
					"paid" => "DESC",
					"present" => "DESC",
					"priori" => "DESC",
					"rating" => "DESC"
				);

				if (array_key_exists($order, $orderFilter) === TRUE) {
					$completeOrderFilter = "`" . $order . "`" . $orderFilter[$order];
				} else {
					$order = "name";
					$completeOrderFilter = "`member`.`name` ASC";
				}

			} else {
				$order = "name";
				$completeOrderFilter = "`member`.`name` ASC";
			}

			// The query
			$result = getPeopleAtGroupQuery($groupID, $complement, $completeOrderFilter);

			// Return its data
			if ($format == "json") {
				echo printInformation("groupMember", $result, true, 'json');
			} elseif ($format == "html") {
				printPeopleAtActivity($result, $order);
			} elseif ($format == "excel") {
				resourceToExcel($result);
			} elseif ($format == "gmail") {
				for ($i = 0; $i < mysql_num_rows($result); $i++) {
					echo ($i != 0 ? " , " : "") . mysql_result($result, $i, "name") . " <" . mysql_result($result, $i, "email") . ">";
				}
			} else {
				http_status_code(405, "this format is not available");	
			}

		} else {
			http_status_code(400, "groupID and selection are required parameters");
		}
		
	} else

// ------------------------------------------------------------------------------------------- //
			
	{ http_status_code(501); }
	
?>