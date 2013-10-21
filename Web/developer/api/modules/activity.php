<?php
// -------------------------------------- ACTIVITY --------------------------------------- //
	
	if ($method === "create") {

		$eventID = getTokenForEvent();

		// Permission
		if ($core->workAtEvent) {

			// Insert a new activity
			$insert = resourceForQuery(
				"INSERT INTO
					`activity`
					(
						`eventID`,
						`groupID`,
						`name`,
						`description`,
						`latitude`,
						`longitude`,
						`location`,
						`dateBegin`,
						`dateEnd`,
						`capacity`,
						`general`,
						`highlight`
					)
				VALUES
					(
						$eventID,
						0,
						'',
						'',
						0,
						0,
						'',
						NOW(),
						NOW(),
						0,
						1,
						0
					)
			");

			$activityID = mysql_insert_id();

			// Send a push notification
			// if ($globalDev == 0) pushActivityCreation($eventID, $activityID);

			// Return its data
			if ($format == "json") {
				$data["activityID"] = $activityID;
				echo json_encode($data);
			} elseif ($format == "html") {
				$result = getActivitiesForMemberAtActivityQuery($activityID, $core->memberID);
				printAgendaItem(mysql_fetch_assoc($result), "member");
			} else {
				http_status_code(405, "this format is not available");
			}

		} else {
			http_status_code(401, "personID doesn't work at event");
		}

	} else

	if ($method === "edit") {

		$activityID = getTokenForActivity();

		if (isset($_GET['name']) && isset($_POST['value'])) {

			$name = getAttribute($_GET['name']);
			$value = getEmptyAttribute($_POST['value']);

			// Permission
			if ($core->workAtEvent) {
			
				// We list all the fields that can be edited by the activity platform
				$validFields = array("name", "description", "latitude", "longitude", "location", "dayBegin", "monthBegin", "hourBegin", "minuteBegin", "dayEnd", "monthEnd", "hourEnd", "minuteEnd", "capacity", "general", "highlight");

				if (in_array($name, $validFields) == TRUE) {

					// Month
					if ($name == "monthBegin" || $name == "monthEnd") {

						if ($value > 0 && $value <= 12) {

							$name = str_replace("month", "date", $name);

							$update = resourceForQuery(
								"UPDATE
									`activity` 
								SET
									`$name` = ((`$name` - INTERVAL MONTH(`$name`) MONTH) + INTERVAL $value MONTH)
								WHERE
									`activity`.`id` = $activityID
							");

						} else {
							http_status_code(406, "month must be valid");
						}

					// Day
					} elseif ($name == "dayBegin" || $name == "dayEnd") {

						if ($value > 0 && $value <= 31) {

							$name = str_replace("day", "date", $name);

							$update = resourceForQuery(
								"UPDATE
									`activity` 
								SET
									`$name` = ((`$name` - INTERVAL DAY(`$name`) DAY) + INTERVAL $value DAY)
								WHERE
									`activity`.`id` = $activityID
							");

						} else {
							http_status_code(406, "day must be valid");
						}

					// Hour
					} elseif ($name == "hourBegin" || $name == "hourEnd") {

						if ($value >= 0 && $value < 24) {

							$name = str_replace("hour", "date", $name);

							$update = resourceForQuery(
								"UPDATE
									`activity` 
								SET
									`$name` = CONVERT_TZ(((`$name` - INTERVAL HOUR(`$name`) HOUR) + INTERVAL $value HOUR), '-03:00','+00:00')
								WHERE
									`activity`.`id` = $activityID
							");

						} else {
							http_status_code(406, "hour must be valid");
						}

					// Minute
					} elseif ($name == "minuteBegin" || $name == "minuteEnd") {

						if ($value >= 0 && $value < 60) {

							$name = str_replace("minute", "date", $name);

							$update = resourceForQuery(
								"UPDATE
									`activity` 
								SET
									`$name` = ((`$name` - INTERVAL MINUTE(`$name`) MINUTE) + INTERVAL $value MINUTE)
								WHERE
									`activity`.`id` = $activityID
							");

						} else {
							http_status_code(406, "minute must be valid");
						}

					// Capacity
					} elseif ($name == "capacity") {

						// See the intentions of the person
						if ($value == 0) {

							// Approve everyone in the activity
							$update = resourceForQuery(
								"UPDATE
									`activityMember` 
								SET
									`activityMember`.`approved` = 1
								WHERE 1
									AND `activityMember`.`activityID` = $activityID
							");
							
						} else {

							// Get the event capacity
							$result = resourceForQuery(
								"SELECT
									`activity`.`capacity`
								FROM
									`activity`
								WHERE 1
									AND `activity`.`id` = $activityID
							");

							if (mysql_num_rows($result) > 0) {

								$capacity = mysql_result($result, 0, "capacity");

								$result = resourceForQuery(
									"SELECT
										`activityMember`.`id`
									FROM
										`activityMember`
									WHERE 1
										AND `activityMember`.`activityID` = $activityID
										AND `activityMember`.`approved` = 1
									LIMIT
										$capacity
								");

								$lastApproved = (mysql_num_rows($result) > 0) ? mysql_result($result, mysql_num_rows($result) - 1, "id") : 0;

								// Deny a bunch of folks that are beyond the limit
								$update = resourceForQuery(
									"UPDATE
										`activityMember` 
									SET
										`activityMember`.`approved` = 0
									WHERE 1
										AND `activityMember`.`activityID` = $activityID
										AND `activityMember`.`id` > $lastApproved
								");

							} else {
								http_status_code(404, "activityID capacity not found");
							}
						}

						// Update the number of seats
						$update = resourceForQuery(
							"UPDATE
								`activity`
							SET
								`$name` = '$value'
							WHERE
								`activity`.`id` = $activityID
						");

					} elseif ($name == "general" || $name == "highlight") {

						if ($value < 0 || $value > 1) $value = 0;

						$update = resourceForQuery(
							"UPDATE
								`activity`
							SET
								`$name` = $value
							WHERE
								`activity`.`id` = $activityID
						");

					// The rest
					} else {
						$update = resourceForQuery(
							"UPDATE
								`activity`
							SET
								`$name` = '$value'
							WHERE
								`activity`.`id` = $activityID
						");
					}

					// Send a push notification
					if ($globalDev == 0) {
						if ($name == "hourBegin") {
							pushActivityUpdate(getEventForActivity($activityID), $activityID);
						}
					}

					// Return its data
					if ($format == "json") {
						$data["activityID"] = $activityID;
						echo json_encode($data);
					} elseif ($format == "html") {
						$result = getActivitiesForMemberAtActivityQuery($activityID, $core->memberID);
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

	if ($method === "remove") {

		$activityID = getTokenForActivity();

		// Permission
		if ($core->workAtEvent) {

			// Remove the activity
			$delete = resourceForQuery(
				"DELETE FROM
					`activity`
				WHERE 1
					AND `activity`.`id` = $activityID
			");

			// Remove people from activity
			$delete = resourceForQuery(
				"DELETE FROM
					`activityMember`
				WHERE 1
					AND `activityMember`.`activityID` = $activityID
			");

			// Send a push notification
			if ($globalDev == 0) pushActivityRemove(getEventForActivity($activityID), $activityID);

			// Return its data
			if ($format == "json") {
				$data["activityID"] = $activityID;
				echo json_encode($data);
			} elseif ($format == "html") {
				$result = getActivitiesForMemberAtActivityQuery($activityID, $core->memberID);
				printAgendaItem(mysql_fetch_assoc($result), "member");
			} else {
				http_status_code(405, "this format is not available");
			}

		} else {
			http_status_code(401, "personID doesn't work at event");
		}

	} else

	if ($method === "requestEnrollment") {

		$activityID = getTokenForActivity();

		if (isset($_GET['name']) && $_GET['name'] != "null" && isset($_GET['email']) && $_GET['email'] != "null") {

			if ($core->workAtEvent) {

				$name = getAttribute($_GET['name']);
				$email = getAttribute($_GET['email']);

				// Get the person for the given email
				$personID = getPersonForEmail($email, $name);

				// Enroll the person at the event if necessary
				processEventEnrollmentWithActivity($activityID, $personID);

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
					`activityMember`.`id`
				FROM
					`activityMember`
				WHERE 1
					AND `activityMember`.`activityID` = $activityID
					AND `activityMember`.`memberID` = $personID
			");

			if (mysql_num_rows($result) == 0) {
				// Enroll people at the activity
				$success = processActivityEnrollment($activityID, $personID);
			} else {
				$success = true;
			}

			if ($success) {
				// Return its data
				if ($format == "json") {
					$result = getActivitiesForMemberAtActivityQuery($activityID, $personID);
					echo printInformation("activity", $result, true, 'json');
				} elseif ($format == "html") {
					$result = getActivitiesForMemberAtActivityQuery($activityID, $personID);
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

	if ($method === "requestMultipleEnrollment") {

		$activityID = getTokenForActivity();

		echo saveFromExcel(getAttribute($_GET['path']), "activity", $activityID);

	} else

	if ($method === "dismissEnrollment") {

		$activityID = getTokenForActivity();

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

			// Get some properties
			$groupID = getGroupForActivity($activityID);
				
			// Remove the current person
			$delete = resourceForQuery(
				"DELETE FROM
					`activityMember`
				WHERE 1
					AND `activityMember`.`activityID` = $activityID
					AND `activityMember`.`memberID` = $personID
			");

			// Check if the person is on the limit of activities for the given group
			// $result = resourceForQuery(
			// 	"SELECT
			// 		`activity`.`id`,
			// 		`activityMember`.`id`,
			// 		`activityMember`.`priori`,
			// 		`activityMember`.`approved`,
			// 		`activityGroup`.`limit`,
			// 	FROM
			// 		`activity`
			// 	LEFT JOIN
			// 		`activityMember` ON `activity`.`id` = `activityMember`.`activityID`
			// 	LEFT JOIN
			// 		`activityGroup` ON `activity`.`groupID` = `activityGroup`.`id` AND `activity`.`groupID` = $groupID
			// 	WHERE 1
					
			// 	GROUP BY
			// 		`activity`.`groupID`,
			// 		`activityMember`.`memberID`
			// 	HAVING 0
			// 		OR ((`activityMember`.`priori` = 1 AND `activity`.`id` = $activityID) AND COALESCE(`activityGroup`.`limit`, 99999) <= SUM(`activityMember`.`approved`))
			// 		OR ((`activityMember`.`priori` = 0 AND `activity`.`id` = $activityID) AND COALESCE(`activityGroup`.`limit`, 99999) > SUM(`activityMember`.`approved`))
			// 	ORDER BY
			// 		`activityMember`.`id` ASC
			// ");
			
			$result = resourceForQuery(
				"SELECT
					`activityMember`.`id`,
					`activityMember`.`priori`,
					`activityMember`.`memberID`
				FROM
					`activityMember`
				WHERE 1
					AND `activityMember`.`activityID` = $activityID
					AND `activityMember`.`approved` = 0
				ORDER BY
					`activityMember`.`id` ASC
			");

			for ($i = 0; $i < mysql_num_rows($result); $i++) {
				
				$requestID = mysql_result($result, $i, "id");
				$priori = mysql_result($result, $i, "priori");
				$memberID = mysql_result($result, $i, "memberID");

				$resultExtrapolated = resourceForQuery(
					"SELECT
						IF(COALESCE(`activityGroup`.`limit`, 99999) <= SUM(`activityMember`.`approved`), 1, 0) AS `extrapolated`
					FROM
						`activity`
					LEFT JOIN
						`activityMember` ON `activity`.`id` = `activityMember`.`activityID` AND `activityMember`.`memberID` = $memberID
		            LEFT JOIN
		                `activityGroup` ON `activity`.`groupID` = `activityGroup`.`id`
					WHERE 1
						AND `activity`.`groupID` = $groupID
					GROUP BY
						`activity`.`groupID`
				");

				$extrapolated = (mysql_num_rows($resultExtrapolated) > 0) ? mysql_result($resultExtrapolated, 0, "extrapolated") : 0;

				// If the person extrapolated, we can only overwrite it if the user explicity gave us permition to do so
				if ($extrapolated == 1 && $priori == 1) {
					// Get the next person on the line and grant a place on the activity
					$update = resourceForQuery(
						"UPDATE
							`activityMember`
						SET
							`activityMember`.`approved` = 1
						WHERE 1
							AND `activityMember`.`id` = $requestID
						ORDER BY
							`activityMember`.`id` ASC
						LIMIT 1
					");

					// If we didn't alter something (a person had his schedule modified), we must remove from other activities
					if (mysql_affected_rows() > 0) {
						// Assert that the granted person doesn't stay approved on other activities of the same group
						$resultOther = resourceForQuery(
						// echo (
							"SELECT
								`activityMember`.`id`
							FROM
								`activity`
							INNER JOIN
								`activityMember` ON `activityMember`.`activityID` = `activity`.`id`
				 			LEFT JOIN
								`activityGroup` ON `activity`.`groupID` = `activityGroup`.`id`
							WHERE 1
								AND `activityMember`.`memberID` = $memberID
								AND `activityMember`.`approved` = 1
								AND `activityMember`.`id` != $requestID
								AND `activityGroup`.`id` = $groupID
							ORDER BY
								`activityMember`.`id` ASC
							LIMIT 1
						");

						if (mysql_num_rows($resultOther) > 0) {
							$requestID = mysql_result($resultOther, 0, "id");

							$update = resourceForQuery(
								"UPDATE
									`activityMember`
					            SET
					            	`activityMember`.`approved` = 0
								WHERE 1
									AND `activityMember`.`id` = $requestID
							");
						}
					}

					break;

				// Otherwise we just get the next one
				} elseif ($extrapolated == 0) {
					$update = resourceForQuery(
						"UPDATE
							`activityMember`
						SET
							`activityMember`.`approved` = 1
						WHERE 1
							AND `activityMember`.`id` = $requestID
						ORDER BY
							`activityMember`.`id` ASC
						LIMIT 1
					");

					break;

				} else {
					http_status_code(400, "personID has chosen to not replace his activity");
				}
			}

			if ($delete) {
				// Return its data
				if ($format == "json") {
					$result = getActivitiesForMemberAtActivityQuery($activityID, $personID);
					echo printInformation("activity", $result, true, 'json');
				} elseif ($format == "html") {
					$result = getActivitiesForMemberAtActivityQuery($activityID, $core->memberID);
					printAgendaItem(mysql_fetch_assoc($result), "member");
				} else {
					http_status_code(405, "this format is not available");	
				}
			} else {
				http_status_code(500, "row deletion could not be completed");
			}
		} else {
			http_status_code(400, "activityID is a required parameter");
		}
		
	} else

	if (0
		|| $method === "confirmApproval"
		|| $method === "revokeApproval"
		|| $method === "confirmEntrance"
		|| $method === "revokeEntrance"
		|| $method === "confirmPayment"
		|| $method === "revokePayment"
		|| $method === "risePriority"
		|| $method === "decreasePriority") {

		$activityID = getTokenForActivity();

		if (isset($_GET["personID"])) {

			// Get some properties
			$personID = getAttribute($_GET['personID']);

			if ($core->workAtEvent) {

				// See which field we want to update
				if ($method === "confirmApproval") {
					$attribute = "`activityMember`.`approved` = 1";
				} elseif ($method === "revokeApproval") {
					$attribute = "`activityMember`.`approved` = 0";
				} elseif ($method === "confirmEntrance") {
					$attribute = "`activityMember`.`present` = 1";
				} elseif ($method === "revokeEntrance") {
					$attribute = "`activityMember`.`present` = 0";
				} elseif ($method === "confirmPayment") {
					$attribute = "`activityMember`.`paid` = 1";
				} elseif ($method === "revokePayment") {
					$attribute = "`activityMember`.`paid` = 0";
				} elseif ($method === "risePriority") {
					$attribute = "`activityMember`.`priori` = 1";
				} elseif ($method === "decreasePriority") {
					$attribute = "`activityMember`.`priori` = 0";
				}

				// Update based on the attribute
				$update = resourceForQuery(
					"UPDATE
						`activityMember`
					SET
						$attribute
					WHERE 1
						AND `activityMember`.`activityID` = $activityID
						AND `activityMember`.`memberID` = $personID
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
			http_status_code(400, "activityID and personID are required parameters");
		}
		
	} else

	if ($method === "getPeople") {

		$activityID = getTokenForActivity();

		if (isset($_GET["selection"])) {

			// Get some properties
			$selection = getAttribute($_GET['selection']);

			// Selection
			switch ($selection) {
				case 'approved':
					$complement = "AND `activityMember`.`approved` = 1";
					break;

				case 'denied':
					$complement = "AND `activityMember`.`approved` = 0";
					break;

				case 'unseen':
					$complement = "AND `activityMember`.`id` = 0"; // Don't need to implement it yet
					break;

				case 'paid':
					$complement = "AND `activityMember`.`paid` = 1";
					break;

				case 'present':
					$complement = "AND `activityMember`.`present` = 1";
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
			$result = getPeopleAtActivityQuery($activityID, $complement, $completeOrderFilter);

			// Return its data
			if ($format == "json") {
				echo printInformation("activityMember", $result, true, 'json');
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
			http_status_code(400, "activityID and selection are required parameters");
		}
		
	} else

	if ($method === "getQuestions") {

		$activityID = getTokenForActivity();

		$result = resourceForQuery(
		// echo (
			"SELECT
				`activityQuestion`.`id`,
				`member`.`name` AS `memberName`,
				`activityQuestion`.`memberID`,
				`activityQuestion`.`text`,
				COUNT(`activityQuestion`.`id`) AS `votes`
			FROM
				`activityQuestion`
			INNER JOIN
				`member` ON `member`.`id` = `activityQuestion`.`memberID`
			LEFT JOIN
				`activityQuestionMember` ON `activityQuestion`.`id` = `activityQuestionMember`.`questionID`
			WHERE 1
				AND `activityQuestion`.`activityID` = $activityID
			GROUP BY
				`activityQuestion`.`id` ASC
		");

		echo printInformation("activityQuestion", $result, true, 'json');
		
	} else

	if ($method === "sendQuestion") {

		$activityID = getTokenForActivity();

		if (isset($_POST["question"])) {

			// Get some properties
			$question = getAttribute($_POST['question']);

			$insert = resourceForQuery(
				"INSERT INTO
					`activityQuestion`
					(`activityID`, `memberID`, `text`)
				SELECT
					`activityMember`.`activityID`,
					`activityMember`.`memberID`,
					'$question'
				FROM
					`activityMember`
				LEFT JOIN
					`activityQuestion` ON `activityMember`.`activityID` = `activityQuestion`.`activityID`
				WHERE 1
					AND `activityMember`.`activityID` = $activityID
					AND `activityMember`.`memberID` = $core->memberID
					AND `activityMember`.`approved` = 1
					AND (ISNULL(`activityQuestion`.`text`) OR BINARY `activityQuestion`.`text` != '$question')
			");

			$questionID = mysql_insert_id();

			if ($insert) {
				$data["questionID"] = $questionID;
				echo json_encode($data);
			} else {
				http_status_code(500, "row insertion has failed");
			}

		} else {
			http_status_code(400, "activityID and question are required parameters");
		}
		
	} else

	if ($method === "removeQuestion") {

		$tokenID = getToken();

		if (isset($_GET["questionID"])) {

			// Get some properties
			$questionID = getAttribute($_GET['questionID']);

			$delete = resourceForQuery(
				"DELETE FROM
					`activityQuestion`
				WHERE 1
					AND `activityQuestion`.`id` = $questionID
					AND `activityQuestion`.`memberID` = $core->memberID
			");

			if ($delete) {
				$data["questionID"] = $questionID;
				echo json_encode($data);
			} else {
				http_status_code(500, "row deletion has failed");
			}

		} else {
			http_status_code(400, "questionID is a required parameter");
		}

	} else

	if ($method === "upvoteQuestion") {

		$tokenID = getToken();

		if (isset($_GET["questionID"])) {

			// Get some properties
			$questionID = getAttribute($_GET['questionID']);

			// Make sure that the person is not voting on the same question that he posted
			$insert = resourceForQuery(
			// echo (
				"INSERT INTO
					`activityQuestionMember`
					(`questionID`, `memberID`)
				SELECT
					`activityQuestion`.`id`,
					`activityMember`.`memberID`
				FROM
					`activityMember`
				INNER JOIN
					`activityQuestion` ON `activityMember`.`activityID` = `activityQuestion`.`activityID`
				LEFT JOIN
					`activityQuestionMember` ON `activityQuestion`.`id` = `activityQuestionMember`.`questionID`
				WHERE 1
					AND `activityMember`.`activityID` = (
						SELECT
							`activityMember`.`activityID`
						FROM
							`activityMember`
						INNER JOIN
							`activityQuestion` ON `activityMember`.`activityID` = `activityQuestion`.`activityID`
						WHERE 1
							AND `activityMember`.`memberID` = $core->memberID
							AND `activityMember`.`approved` = 1
							AND `activityQuestion`.`id` = $questionID
					)
					AND `activityMember`.`memberID` = $core->memberID
					AND (ISNULL(`activityQuestionMember`.`id`) OR `activityQuestionMember`.`memberID` != $core->memberID)
			");

			if ($insert) {
				$data["questionID"] = $questionID;
				echo json_encode($data);
			} else {
				http_status_code(500, "row insertion has failed");
			}

		} else {
			http_status_code(400, "questionID is a required parameter");
		}
		
	} else

	if ($method === "getOpinion") {

		$activityID = getTokenForActivity();

		$result = resourceForQuery(
		// echo (
			"SELECT
				`activityMember`.`rating`
			FROM
				`activityMember`
			WHERE 1
				AND `activityMember`.`activityID` = $activityID
				AND `activityMember`.`memberID` = $core->memberID
		");

		echo printInformation("activityMember", $result, true, 'json');
		
	} else

	if ($method === "sendOpinion") {

		$activityID = getTokenForActivity();

		if (isset($_GET['personID']) && $_GET['personID'] != "null") {
			if ($core->workAtEvent) {
				$personID = getAttribute($_GET['personID']);
			} else {
				http_status_code(401, "personID doesn't work at event");
			}
		} else {
			$personID = $core->memberID;
		}

		if (isset ($_POST['rating'])) {

			// Get some properties
			$rating = getAttribute($_POST['rating']);

			// Filter the rating
			$rating = ($rating > 5) ? 5 : $rating;
			$rating = ($rating < 0) ? 0 : $rating;

			// Update the activity
			$update = resourceForQuery(
				"UPDATE
					`activityMember`
				SET
					`activityMember`.`rating` = $rating
				WHERE 1
					AND `activityMember`.`activityID` = $activityID
					AND `activityMember`.`memberID` = $personID
			");

			if ($update) {
				$data["activityID"] = $activityID;
				echo json_encode($data);
			} else {
				http_status_code(500, "sql query error");
			}

		} else {
			http_status_code(400, "rating is required parameter");
		}
			
	} else

// ------------------------------------------------------------------------------------------- //
			
	{ http_status_code(501); }
	
?>