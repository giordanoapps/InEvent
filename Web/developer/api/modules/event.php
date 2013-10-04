<?php
// -------------------------------------- EVENT --------------------------------------- //
	
	if ($method === "edit") {

		$eventID = getTokenForEvent();

		if (isset($_GET['name']) && isset($_POST['value'])) {

			$name = getAttribute($_GET['name']);
			$value = getEmptyAttribute($_POST['value']);

			// Permission
			if ($core->workAtEvent) {
			
				// We list all the fields that can be edited by the event platform
				$validFields = array("name", "nickname", "description", "latitude", "longitude", "address", "city", "state", "dayBegin", "monthBegin", "hourBegin", "minuteBegin", "dayEnd", "monthEnd", "hourEnd", "minuteEnd", "fugleman");

				if (in_array($name, $validFields) == TRUE) {

					// Month
					if ($name == "monthBegin" || $name == "monthEnd") {

						$name = str_replace("month", "date", $name);

						$update = resourceForQuery(
							"UPDATE
								`event` 
							SET
								`$name` = ((`$name` - INTERVAL MONTH(`$name`) MONTH) + INTERVAL $value MONTH)
							WHERE
								`event`.`id` = $eventID
						");

					// Day
					} elseif ($name == "dayBegin" || $name == "dayEnd") {

						$name = str_replace("day", "date", $name);

						$update = resourceForQuery(
							"UPDATE
								`event` 
							SET
								`$name` = ((`$name` - INTERVAL DAY(`$name`) DAY) + INTERVAL $value DAY)
							WHERE
								`event`.`id` = $eventID
						");

					// Hour
					} elseif ($name == "hourBegin" || $name == "hourEnd") {

						$name = str_replace("hour", "date", $name);

						$update = resourceForQuery(
							"UPDATE
								`event` 
							SET
								`$name` = CONVERT_TZ(((`$name` - INTERVAL HOUR(`$name`) HOUR) + INTERVAL $value HOUR), '-03:00','+00:00')
							WHERE
								`event`.`id` = $eventID
						");

					// Minute
					} elseif ($name == "minuteBegin" || $name == "minuteEnd") {

						$name = str_replace("minute", "date", $name);

						$update = resourceForQuery(
							"UPDATE
								`event` 
							SET
								`$name` = ((`$name` - INTERVAL MINUTE(`$name`) MINUTE) + INTERVAL $value MINUTE)
							WHERE
								`event`.`id` = $eventID
						");

					// The rest
					} else {
						$update = resourceForQuery(
							"UPDATE
								`event`
							SET
								`$name` = '$value'
							WHERE
								`event`.`id` = $eventID
						");
					}

					// Return its data
					if ($format == "json") {
						$data["eventID"] = $eventID;
						echo json_encode($data);
					} elseif ($format == "html") {
						$result = getActivitiesForMemberAtActivityQuery($eventID, $core->memberID);
						printAgendaItem(mysql_fetch_assoc($result), "member");
					} else {
						http_status_code(405, "this format is not available");
					}

				} else {
					http_status_code(406, "name field doesn't exist");
				}
			} else {
				http_status_code(401, "personID doesn't work at event");
			}
	    } else {
	    	http_status_code(404, "name and value are required parameters");
	    }

	} else

	if ($method === "getEvents") {

		if (isset($_GET['tokenID']) && $_GET['tokenID'] != "null") {
			$tokenID = getToken();
			$result = getEventsForMemberQuery($core->memberID, false);
		} else {
			$result = getEventsForMemberQuery(0, false);
		}

		echo printInformation("event", $result, true, 'json');

	} else

	if ($method === "getSingle") {

		if (isset($_GET['eventID'])) {

			$eventID = getAttribute($_GET['eventID']);

			if (isset($_GET['tokenID']) && $_GET['tokenID'] != "null") {
				$tokenID = getToken();
				$result = getEventForMemberQuery($eventID, $core->memberID);
			} else {
				$result = getEventForEventQuery($eventID);
			}
			echo printInformation("event", $result, true, 'json');
		} else {
			http_status_code(400, "eventID is a required parameter");
		}

	} else

	if ($method === "requestEnrollment") {

		$eventID = getTokenForEvent();

		if (isset($_GET['name']) && $_GET['name'] != "null" && isset($_GET['email']) && $_GET['email'] != "null") {

			if ($core->workAtEvent) {

				$name = getAttribute($_GET['name']);
				$email = getAttribute($_GET['email']);

				$result = resourceForQuery(
					"SELECT
						`member`.`id`
					FROM
						`member`
					WHERE 1
						AND BINARY `member`.`email` = '$email'
				");

				if (mysql_num_rows($result) > 0) {
					$personID = mysql_result($result, 0, "id");
				} else {
					$personID = createMember($name, "123456", $email);
				}

			} else {
				http_status_code(401, "Person doesn't work at event");
			}
		} else {
			$personID = $core->memberID;
		}

		if ($personID != 0 && eventExists($eventID)) {

			// Enroll a person inside an event
			$sucess = processEventEnrollmentWithEvent($eventID, $personID);

			if ($sucess) {
				// Return its data
				if ($format == "json") {
					$data["eventID"] = $eventID;
					echo json_encode($data);
				} elseif ($format == "html") {

				} else {
					http_status_code(405, "this format is not available");
				}
			} else {
				http_status_code(404, "personID is not enrolled at this event");
			}
		} else {
			http_status_code(400, "personID is null or the eventID doesn't exist");
		}
		
	} else

	if ($method === "requestMultipleEnrollment") {

		$eventID = getTokenForEvent();

		echo saveFromExcel(getAttribute($_GET['path']), "event", $eventID);

	} else

	if ($method === "dismissEnrollment") {

		$eventID = getTokenForEvent();

		if (isset($_GET['personID']) && $_GET['personID'] != "null") {

			if ($core->workAtEvent) {
				$personID = getAttribute($_GET['personID']);
			} else {
				http_status_code(401, "Person doesn't work at event");
			}

		} else {
			$personID = $core->memberID;
		}

		if ($personID != 0) {

			// Remove from event
			$delete = resourceForQuery(
				"DELETE FROM
					`eventMember`
				WHERE 1
					AND `eventMember`.`eventID` = $eventID
					AND `eventMember`.`memberID` = $personID
			");

			// Remove from activities
			$delete = resourceForQuery(
				"DELETE
					`activityMember`.*
				FROM
					`activityMember`
				INNER JOIN
					`activity` ON `activity`.`id` = `activityMember`.`activityID`
				WHERE 1
					AND `activity`.`eventID` = $eventID
					AND `activityMember`.`memberID` = $personID
			");
			
			if ($delete) {
				// Return its data
				if ($format == "json") {
					$data["activityID"] = $activityID;
					echo json_encode($data);
				} elseif ($format == "html") {

				} else {
					http_status_code(405, "this format is not available");
				}
			} else {
				http_status_code(500, "row deletion has failed");
			}
		} else {
			http_status_code(400, "personID cannot be null");
		}
		
	} else

	if ($method === "grantPermission" || $method === "revokePermission") {

		$eventID = getTokenForEvent();

		if (isset($_GET["personID"])) {

			// Get some properties
			$personID = getAttribute($_GET['personID']);

			if ($core->workAtEvent) {

				// See which field we want to update
				$attribute = ($method === "grantPermission") ? ROLE_COORDINATOR : ROLE_ATTENDEE;

				// Update based on the attribute
				$update = resourceForQuery(
					"UPDATE
						`eventMember`
					SET
						`eventMember`.`roleID` = $attribute
					WHERE 1
						AND `eventMember`.`eventID` = $eventID
						AND `eventMember`.`memberID` = $personID
				");

				if (mysql_affected_rows() > 0) {
					// Return its data
					if ($format == "json") {
						$data["eventID"] = $eventID;
						echo json_encode($data);
					} elseif ($format == "html") {
						$data["eventID"] = $eventID;
						echo json_encode($data);
					} else {
						http_status_code(405, "this format is not available");
					}
				} else {
					http_status_code(500, "row insertion has failed");
				}
			} else {
				http_status_code(401, "Person doesn't work at event");
			}
		} else {
			http_status_code(400, "personID is a required parameter");
		}
		
	} else

	if ($method === "getPeople" || $method === "sendMail") {

		$eventID = getTokenForEvent();

		if (isset($_GET["selection"])) {

			// Get some properties
			$selection = getAttribute($_GET['selection']);

			switch ($selection) {
				case 'approved':
					$complement = "AND `eventMember`.`approved` = 1";
					break;

				case 'denied':
					$complement = "AND `eventMember`.`approved` = 0";
					break;

				case 'unseen':
					$complement = "AND `eventMember`.`id` = 0"; // Don't need to implement it yet
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
					"roleID" => "DESC",
					"memberID" => "ASC",
					"enrollmentID" => "ASC",
					"position" => "ASC",
					"name" => "ASC",
					"rg" => "DESC",
					"cpf" => "DESC",
					"email" => "ASC",
					"present" => "DESC",
					"city" => "ASC",
					"university" => "ASC"
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
			$result = getPeopleAtEventQuery($eventID, $complement, $completeOrderFilter);

			if ($method === "getPeople") {
				// Return its data
				if ($format == "json") {
					echo printInformation("eventMember", $result, true, 'json');
				} elseif ($format == "html") {
					printPeopleAtEvent($result, $order);
				} elseif ($format == "excel") {
					resourceToExcel($result);
				} elseif ($format == "gmail") {
					for ($i = 0; $i < mysql_num_rows($result); $i++) {
						echo ($i != 0 ? " , " : "") . mysql_result($result, $i, "name") . " <" . mysql_result($result, $i, "email") . ">";
					}
				} else {
					http_status_code(405, "this format is not available");
				}

			} elseif ($method === "sendMail") {
				for ($i = 0; $i < mysql_num_rows($result); $i++) {
					sendAppInformation(mysql_result($result, $i, "email"));
				}
			}

		} else {
			http_status_code(400, "selection is a required parameter");
		}
		
	} else

	if ($method === "getActivities") {

		if (isset($_GET["eventID"])) {

			if (isset($_GET['tokenID']) && $_GET['tokenID'] != "null") {
				// Get some properties
				$eventID = getTokenForEvent();
				$result = getActivitiesForMemberAtEventQuery($eventID, $core->memberID);

			} else {
				// Get some properties
				$eventID = getAttribute($_GET['eventID']);
				$result = getActivitiesForMemberAtEventQuery($eventID, 0);
			}

			$data = printInformation("event", $result, true, 'object');
			echo json_encode(groupActivitiesInDays($data));

		} else {
			http_status_code(400, "eventID is a required parameter");
		}
		
	} else

	if ($method === "getSchedule") {

		$eventID = getTokenForEvent();

		$result = getActivitiesForMemberAtEventQuery($eventID, $core->memberID);

		$data = printInformation("event", $result, true, 'object');
		echo json_encode(groupActivitiesInDays($data));
		
	} else

	if ($method === "getOpinion") {

		$eventID = getTokenForEvent();

		$result = resourceForQuery(
			"SELECT
				`eventMember`.`rating`,
				`eventMember`.`message`
			FROM
				`eventMember`
			WHERE 1
				AND `eventMember`.`eventID` = $eventID
				AND `eventMember`.`memberID` = $core->memberID
		");

		echo printInformation("eventMember", $result, true, 'json');
		
	} else

	if ($method === "sendOpinion") {

		$eventID = getTokenForEvent();

		if (isset ($_POST['rating']) && isset ($_POST['message'])) {

			// Get some properties
			$rating = getAttribute($_POST['rating']);
			$message = getAttribute($_POST['message']);

			// Filter the rating
			$rating = ($rating > 5) ? 5 : $rating;
			$rating = ($rating < 0) ? 0 : $rating;

			// Filter the message
			$message = ($message == "null") ? "" : $message;

			// Update the activity
			$update = resourceForQuery(
				"UPDATE
					`eventMember`
				SET
					`eventMember`.`rating` = $rating,
					`eventMember`.`message` = '$message'
				WHERE 1
					AND `eventMember`.`eventID` = $eventID
					AND `eventMember`.`memberID` = $core->memberID
			");

			if ($update) {
				$data["eventID"] = $eventID;
				echo json_encode($data);
			} else {
				http_status_code(500, "sql query error");
			}

		} else {
			http_status_code(400, "rating and message are required parameters");
		}
			
	} else

// ------------------------------------------------------------------------------------------- //
			
	{ http_status_code(501); }
	
?>