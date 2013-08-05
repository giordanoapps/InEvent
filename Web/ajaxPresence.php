<?php include_once("includes/check/login.php"); ?>
<?php

	if (!$core->auth) logout();

// -------------------------------------- COMPUTER -------------------------------------- //

	// See if the current computer is validated
	if (isset ($_POST['computerState'])) {
		
		$tokenID = getAttribute($_POST['computerState']);

		// Verify if the given string is valid
		if (strlen($tokenID) == 60) {
			$result = resourceForQuery(
				"SELECT
					`shiftToken`.`tokenID`
				FROM
					`shiftToken`
				WHERE 1
					AND `shiftToken`.`companyID` = $core->companyID
					AND `shiftToken`.`tokenID` = '$tokenID'
			");

			if (mysql_num_rows($result) != 1) http_status_code(204);

		} else {
			http_status_code(204);
		}
	
	} else 

// -------------------------------------- CALENDAR --------------------------------------- //

	// Obtain a period of time
	if ((isset($_POST['showCalendars']))) {

		printCalendars($core->memberID, $core->permission);

	} else 

	// Obtain a period of time
	if ((isset($_POST['updateCalendar'])) && (isset($_POST['calendarName']))) {

		if ($core->permission >= 10) {

			$calendarID = getAttribute($_POST['updateCalendar']);
			$calendarName = getAttribute($_POST['calendarName']);

			if ($calendarID == 0) {
				createCalendar($calendarName, $core->companyID, $core->memberID);
			} else {
				$update = resourceForQuery(
					"UPDATE
						`shiftCalendar`
					INNER JOIN
						`company` ON `company`.`id` = `shiftCalendar`.`companyID`
					SET
						`shiftCalendar`.`name` = '$calendarName'
					WHERE
						`shiftCalendar`.`id` = $calendarID;
				");

				if (!$update) http_status_code(500);
			}

		} else {
			http_status_code(401);
		}

	} else

	if ((isset($_POST['showMonth']))) {

		$timestamp = intval(getAttribute($_POST['showMonth']));

		// Get the current moment if we didn't provide one
		if ($timestamp == 0) $timestamp = time();

		// Update only  if the calendarID was given to us
		if (isset($_POST['calendarID'])) {
			$calendarID = intval(getAttribute($_POST['calendarID']));

			// Create a single entry on the calendar
			$update = resourceForQuery(
				"UPDATE
					`member`
				SET
					`member`.`calendarID` = $calendarID
				WHERE 
					`member`.`id` = $core->memberID
			");

			if (!$update) http_status_code(500);
		} else {
			$calendarID = getMemberCalendarID($core->memberID);
		}

		// Print months
		printMonths($timestamp, $calendarID);

	} else

// -------------------------------------- PERIOD --------------------------------------- //

	// Obtain a period of time
	if ((isset($_POST['getPeriod']))) {

		$timestamp = intval(getAttribute($_POST['getPeriod']));
		$calendarID = getMemberCalendarID($core->memberID);

		if ($calendarID == 0) {
			printCalendarHelp();
		} else {
			printContent($timestamp, $calendarID);
		}

	} else 

	// Create a period of time
	if ((isset($_POST['createPeriod']))) {

		$data = organizeArray(getAttribute($_POST['createPeriod']));
		$calendarID = getMemberCalendarID($core->memberID);

		if ($calendarID == 0) {
			printCalendarHelp();
		} else {

			// Rewrite rule, not to lose wanted data
			$force = ($core->permission >= 10) ? true : false;

			// Write the table
			writeTable($calendarID, $data["timestamp"], $data["dayBegin"], $data["dayEnd"], $data["hourBegin"], $data["hourEnd"], $data["duration"], $data["interval"], $data["tolerance"], $force);

			// Print it
			printContent($calendarID, $data["timestamp"]);
		}

	} else 

// -------------------------------------- CREATE --------------------------------------- //

	// Obtain a period of time
	if ((isset($_POST['showCreateTool']))) {

		$timestamp = intval(getAttribute($_POST['showCreateTool']));

		printStartMenu($timestamp, true);

	} else 

// -------------------------------------- COPY --------------------------------------- //

	//	COPYING A TABLE ---- CONFIRM	//
	if (isset ($_POST['copyPeriod']) && isset ($_POST['shiftWeeks'])) {

		$timestamp = intval(getAttribute($_POST['copyPeriod']));
		$shiftWeeks = intval(getAttribute($_POST['shiftWeeks']));

		$calendarID = getMemberCalendarID($core->memberID);

        // We need to check both for security and for reliability
        if ($core->groupID == 3 || $core->permission >= 10) {
			copyTable($calendarID, $timestamp - $shiftWeeks * 7 * 86400, $timestamp);
        } else {
        	http_status_code(406);
        }

	} else  
	
// -------------------------------------- TOKEN -------------------------------------- //

	//	TOOGLE THE TOKENID	//
	if (isset ($_POST['toggleToken'])) {
		
		$tokenID = getAttribute($_POST['toggleToken']);

		if ($core->permission >= 10) {

			if (strlen($tokenID) != 60) {
				// We need to generate a new tokenID
				do {
					$sessionKey = Bcrypt::hash(mt_rand(1, mt_getrandmax()));
					$resultSession = resourceForQuery(
						"SELECT
							`shiftToken`.`id`
						FROM
							`shiftToken`
						WHERE
							`shiftToken`.`tokenID` = '$sessionKey'
					");
				} while (mysql_num_rows($resultSession) != 0);

				// When we find the id, we store it on our database
				$insert = resourceForQuery(
					"INSERT INTO
						`shiftToken`
						(`companyID`, `tokenID`)
					VALUES
						($core->companyID, '$sessionKey')
				");

				if ($insert) {
					echo $sessionKey;
				} else {
					http_status_code(500);					
				}

			} else {
				// Just delete if from our database
				$remove = resourceForQuery(
					"DELETE FROM
						`shiftToken`
					WHERE 1
						AND `shiftToken`.`companyID` = $core->companyID
						AND `shiftToken`.`tokenID` = '$tokenID'
				");

				if (!$remove) http_status_code(500);
			}
		}

	} else 

// -------------------------------------- TABLE -------------------------------------- //
	
	//  START AND FINISH SHIFT //
	if (isset ($_POST['confirm']) && isset ($_POST['tokenID'])) {
	
		$presenceID = getAttribute($_POST['confirm']);
		$tokenID = getAttribute($_POST['tokenID']);

		// Verify if the given string is valid
		if (strlen($tokenID) == 60) {
			$result = resourceForQuery(
				"SELECT
					`shiftToken`.`tokenID`
				FROM
					`shiftToken`
				WHERE 1
					AND `shiftToken`.`companyID` = $core->companyID
					AND `shiftToken`.`tokenID` = '$tokenID'
			");

			if (mysql_num_rows($result) == 1) {

				// We look for all the shifts inside a
				$result = resourceForQuery(
					"SELECT
						`shiftMember`.`id`
					FROM
						`shiftMember`
					INNER JOIN
		                `shiftCalendar` ON `shiftCalendar`.`id` = `shiftMember`.`calendarID`
		            WHERE 1
		                AND `shiftMember`.`id` = $presenceID
		                AND `shiftCalendar`.`companyID` = $core->companyID
		                AND (0
		                	OR (1
		                		AND `shiftMember`.`dateBegin` >= NOW() - INTERVAL `shiftMember`.`tolerance` MINUTE
	                    		AND `shiftMember`.`dateBegin` <= NOW() + INTERVAL `shiftMember`.`tolerance` MINUTE
	                    		AND `shiftMember`.`statusID` = 0
	                    	)
							OR (1
		                    	AND `shiftMember`.`dateEnd` >= NOW() - INTERVAL `shiftMember`.`tolerance` MINUTE
		                    	AND `shiftMember`.`dateEnd` <= NOW() + INTERVAL `shiftMember`.`tolerance` MINUTE
		                    	AND `shiftMember`.`statusID` = 1
		                    )
	                    )
				");

				if (mysql_num_rows($result) == 1) {
					$update = resourceForQuery(
						"UPDATE
							`shiftMember`
						SET 
							`shiftMember`.`statusID` = `shiftMember`.`statusID` + 1
						WHERE 1
			                AND `shiftMember`.`id` = $presenceID
					");

					if (!$update) http_status_code(500);

				} else {
					http_status_code(408);
				}
			} else {
				http_status_code(404);
			}
		} else {
			http_status_code(411);
		}

		// Print it
		printTextForPresenceID($presenceID);
		
	} else
	
// -------------------------------------- SHIFT -------------------------------------- //

	// CHANGING AN USER SHIFT ---- REQUEST	//
	if (isset ($_POST['membersList']) && isset ($_POST['presenceID'])) {
	
		// Get the data
		$type = getAttribute($_POST['membersList']);
		$presenceID = getAttribute($_POST['presenceID']);

		// Select the given data on the database
		$result = getPresenceQuery($core->companyID, $presenceID);
		
		// Get the entry
		if (mysql_num_rows($result) == 1) {
			$memberID = mysql_result($result, 0, "memberID");
			$dateBegin = mysql_result($result, 0, "dateBegin");
			$dateEnd = mysql_result($result, 0, "dateEnd");

			?><select id="confirmSelect" data-value="<?php echo $presenceID ?>" data-type="<?php echo $type ?>"><?php
	

			if ($type == "add") {
				// Select all the users from the enterprise
				$result = resourceForQuery(
					"SELECT
						`member`.`id`,
						`member`.`name`
					FROM
						`member`
					WHERE 1
						AND `member`.`companyID` = $core->companyID
						AND `member`.`id` NOT IN (
							SELECT
				                `shiftMember`.`memberID`
				            FROM
				                `shiftMember`
				            WHERE 1
				                AND `shiftMember`.`dateBegin` = '$dateBegin'
				                AND `shiftMember`.`dateEnd` = '$dateEnd'
		                )
					ORDER BY
						`member`.`name`
				");
			} else {
				$result = resourceForQuery(
					"SELECT
						`member`.`id`,
						`member`.`name`
					FROM
						`member`
					WHERE 1
						AND `member`.`companyID` = $core->companyID
					ORDER BY
						`member`.`name`
				");
			}
			
			// Loop through them and append to the select element
			for ($i = 0; $i < mysql_num_rows($result); $i++) {
				$id = mysql_result($result, $i, "id");
				$name = mysql_result($result, $i, "name");

				?><option <?php if ($type == "edit" && $id == $memberID) { ?> selected <?php } ?> value="<?php echo $id ?>"><?php echo $name ?></option><?php
			}
			
			// Wrap the select
			?></select><?php	

		} else {
			http_status_code(412);
		}

	} else 
		
	//	CHANGING AN USER SHIFT ---- CONFIRM	//
	if ((isset ($_POST['changeShift'])) && (isset ($_POST['memberID'])) && (isset ($_POST['presenceID']))) {
	
		if ($core->groupID == 3 || $core->permission >= 10) {
			
			$type = getAttribute($_POST['changeShift']);
			$memberID = getAttribute($_POST['memberID']);
			$presenceID = getAttribute($_POST['presenceID']);
			
			// See if the member belongs to the same company of the current member
			$result = resourceForQuery(
				"SELECT
					`member`.`id`
				FROM
					`member`
				WHERE 1
					AND `member`.`id` = $memberID
					AND `member`.`companyID` = $core->companyID
			");
			
			if (mysql_num_rows($result) == 1) {

				if ($type == "edit") {
					// Notify the member that he/she will be removed
					$oldMemberID = getMemberIDForPresenceID($presenceID);
					notificationSave(array($oldMemberID), "<b>$core->name</b> lhe removeu do plantão.", "presence.php");
				
					// Make the update
					$insert = resourceForQuery(
						"UPDATE
							`shiftMember`
						INNER JOIN
			                `shiftCalendar` ON `shiftCalendar`.`id` = `shiftMember`.`calendarID`
						SET
							`shiftMember`.`memberID` = $memberID
						WHERE 1
							AND `shiftMember`.`id` = $presenceID 
							AND `shiftCalendar`.`companyID` = $core->companyID
					");
					
					// And notify the member that he/she was added
					notificationSave(array($memberID), "<b>$core->name</b> lhe adicionou no plantão.", "presence.php");
				} elseif ($type == "add") {
					resourceForQuery(
					// echo (
						"INSERT INTO
							`shiftMember`
							(`calendarID`, `memberID`, `dateBegin`, `dateEnd`, `tolerance`) 
						SELECT
							`shiftMember`.`calendarID`,
			                $memberID,
			                `shiftMember`.`dateBegin`,
			                `shiftMember`.`dateEnd`,
			                `shiftMember`.`tolerance`
			            FROM
			                `shiftMember`
			            INNER JOIN
			                `shiftCalendar` ON `shiftCalendar`.`id` = `shiftMember`.`calendarID`
			            WHERE 1
			                AND `shiftMember`.`id` = $presenceID
			                AND `shiftCalendar`.`companyID` = $core->companyID
					");

					// Hold the new id
					$presenceID = mysql_insert_id();
				}
			} else {
				http_status_code(412);
			}
	
			// Print it
			printTextForPresenceID($presenceID);

		} else {
			http_status_code(406);
		}
		
	} else 
	
	//	ADDING AND REMOVING USER FROM SHIFT	//
	if (isset ($_POST['removeShift'])) {
	
		if ($core->groupID == 3 || $core->permission >= 10) {
	
			$presenceID = getAttribute($_POST['removeShift']);

			$result = getPresenceQuery($core->companyID, $presenceID);

			if (mysql_num_rows($result) > 0) {
				$memberID = mysql_result($result, 0, "memberID");
				$dateBegin = mysql_result($result, 0, "dateBegin");
				$dateEnd = mysql_result($result, 0, "dateEnd");	

				// We already make a query that will not select the deletable element, so we can recover any of its siblings really easy
				$quantity = getNumberOfMembersQuery($core->companyID, $dateBegin, $dateEnd);
				
				// At least two members must be available, so we can remove one from this shift
				if ($quantity >= 2) {
					// Notify the member about the fact
					notificationSave(array($memberID), "<b>$core->name</b> lhe removeu do plantão.", "presence.php");
					
					// We delete the selected element
					$delete = resourceForQuery(
						"DELETE
							`shiftMember`
						FROM
							`shiftMember`
						INNER JOIN
			                `shiftCalendar` ON `shiftCalendar`.`id` = `shiftMember`.`calendarID`
						WHERE 1
							AND `shiftMember`.`id` = $presenceID
							AND `shiftCalendar`.`companyID` = $core->companyID
					");
	
					if (!$delete) http_status_code(500);

				} else {
					http_status_code(412);
				}
			} else {
				http_status_code(404);
			}
		} else {
			http_status_code(406);
		}
		
	} else

// -------------------------------------- EXPLANATION -------------------------------------- //
	
	//	ADD EXPLANATION ---- REQUEST	//
	if (isset ($_POST['paperAirplane'])) {
		
		$presenceID = getAttribute($_POST['paperAirplane']);
		
		?>
		
		<div id="justificationBox">
			No dia selecionado, não pude cumprir meu horário de plantão pois<br />
			<div id="justificationInnerBox">
				<select id="justificationID">
					<?php
					$result = resourceForQuery(
						"SELECT
							`explanationOptions`.`explanationText`
						FROM
							`explanationOptions`
						ORDER BY
							`explanationOptions`.`id`
					");

					for ($i = 0; $i < mysql_num_rows($result); $i++) {
						$explanationText = mysql_result($result, $i, "explanationText");
						// We need because the data was written directly in the database (which is in Portuguese), so we need to encode it to UFT8
						echo utf8_encode("<option value='".($i+1)."'>$explanationText</option>");
					}					
					?>
					<option value="0">Outros</option>
				</select>
				<div id="justificationTextBox">
					<input type="text" id="justificationText" placeholder="Escreva aqui sua justificativa!" />
				</div>
			</div>
			<input type="button" id="addExplanation" value="Confirmar!" />
		</div><?php

	} else 
	
	//	ADD EXPLANATION ---- CONFIRM	//
	if (isset ($_POST['addExplanation']) && isset ($_POST['justificationID'])) {
		
		$presenceID = getAttribute($_POST['addExplanation']);
		$justificationID = getAttribute($_POST['justificationID']);
		
		if ($justificationID == 0) {
			$justificationText = getAttribute($_POST['justificationText']);
		} else {
			$justificationText = "";
		}
		
		$insert = resourceForQuery(
			"INSERT INTO
				`explanationMembers`
				(`presenceID`, `justificationID`, `justificationText`, `statusID`, `penaltyID`)
			VALUES
				($presenceID, $justificationID, '$justificationText', 0, 0)
		");
		
		
		if (!$insert) http_status_code(500);

	} else

// -------------------------------------- REVIEW --------------------------------------- //
	
	//	REVIEW EXPLANATIONS ---- REQUEST	//
	if (isset ($_POST['requestReview'])) {
		
		// We select all entries that still haven't been evaluated
		$result = resourceForQuery(
			"SELECT
				`explanationMembers`.`id`,
				`explanationMembers`.`presenceID`,
				`explanationMembers`.`justificationID`,
				`explanationMembers`.`justificationText`,
				`explanationMembers`.`statusID`,
				`explanationMembers`.`penaltyID`,
				`explanationOptions`.`explanationText`
			FROM
				`explanationMembers`
			INNER JOIN
				`explanationOptions` ON `explanationOptions`.`id` = `explanationMembers`.`justificationID`
			ORDER BY
				`explanationMembers`.`id` DESC
		");
		
		for ($i = 0; $i < mysql_num_rows($result); $i++) {
			$id = mysql_result($result, $i, "id");
			$presenceID = mysql_result($result, $i, "presenceID");
			$justificationID = mysql_result($result, $i, "justificationID");
			$penaltyID = mysql_result($result, $i, "penaltyID");
			
			if ($justificationID == 0) {
				$justificationText = mysql_result($result, $i, "justificationText");
			} else {
				$justificationText = utf8_encode(mysql_result($result, $i, "explanationText"));
			}
			
			$result = resourceForQuery(
			// echo (
				"SELECT
					`member`.`name`,
					`shiftMember`.`dateBegin`
				FROM
					`shiftMember`
				INNER JOIN
					`member` ON `member`.`id` = `shiftMember`.`memberID`
				INNER JOIN
	                `shiftCalendar` ON `shiftCalendar`.`id` = `shiftMember`.`calendarID`
				WHERE 1
					AND `shiftMember`.`id` = $presenceID
					AND `shiftCalendar`.`companyID` = $core->companyID
			");
			
			// Date gotta still be present there and must belong to the right enterprise
			if (mysql_num_rows($result) != 0) {
				$dateBegin = mysql_result($result, 0, "dateBegin");
				$name = mysql_result($result, 0, "name");
				
				?><div id="reviewBox" attr-value="<?php echo $id ?>">
					<div id="handBox" class="floatRight pointer">
						<img src="images/48-hand-contra.png" <?php if ($penalty == 2) echo "class='handSelected'" ?> alt="Contra" id="handContraButton"/>
						<img src="images/48-hand-pro.png" <?php if ($penalty == 1) echo "class='handSelected'" ?> alt="Pro" id="handProButton"/>
					</div>
					<?php echo $name ?> enviou a seguinte justificativa<br />
					<span id="justificationTextPresentation"><?php echo $justificationText ?></span><br />
					por não estar presente em <?php echo date("j/n/y G:i", strtotime($dateBegin)) ?>.
				</div><?php
			}
			
		}

	} else 
	
	//	REVIEW EXPLANATIONS ---- CONFIRM	//
	if ((isset ($_POST['confirmReview'])) && (isset ($_POST['decision']))) {
		
		if ($core->groupID == 3 || $core->permission >= 10) {
			$presenceID = getAttribute($_POST['confirmReview']);
			$decision = getAttribute($_POST['decision']);
			
			// Security purpose
			$decision = ($decision == 1) ? 1 : 2;
			
			$insert = resourceForQuery(
				"UPDATE
					`explanationMembers`
				SET
					`explanationMembers`.`status` = 1,
					`explanationMembers`.`penaltyID` = $decision,
					`explanationMembers`.`reviewedDate` = NOW()
				WHERE
					`explanationMembers`.`presenceID` = $presenceID
			");
	
			if ($insert) {
			
				$newUserID = $core->getUserIDForDateID($presenceID);
				notificationSave(array($newUserID), "<b>$core->name</b> avaliou sua justificativa.", "presence.php");
				
				?><img src="images/48-hand-contra.png" <?php if ($decision == 2) { ?> class="handSelected" <?php } ?> alt="Contra" id="handContraButton"/>
				<img src="images/48-hand-pro.png" <?php if ($decision == 1) { ?> class="handSelected" <?php } ?> alt="Pro" id="handProButton"/><?php
			} else {
				http_status_code(500);
			}
		} else {
			http_status_code(406);
		}

	} else
	
// ----------------------------------------------------------------------------------- //	

	{ http_status_code(501); }

?>