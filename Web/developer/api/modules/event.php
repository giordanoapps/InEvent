<?php
// -------------------------------------- PRESENCE --------------------------------------- //
	
	if ($method === "getCalendars") {

		$result = getCalendarsQuery($core->memberID);
		echo printInformation("shiftCalendar", $result, true, $format);
		
	} else

	if ($method === "getPeriod") {
		
		if (isset ($_GET['calendarID']) && isset ($_GET['timestamp'])) {
			$calendarID = intval(getAttribute($_GET['calendarID']));
			$timestamp = intval(getAttribute($_GET['timestamp']));
		
			$result = getPeriodForTimestampQuery($calendarID, $timestamp);
			echo printInformation("shiffMember", $result, true, $format);

		} else {
			http_status_code(400);
		}
		
	} else

	if ($method === "confirmPresence") {
		
		if (isset ($_GET['presenceID']) && isset ($_GET['location'])) {
			$presenceID = intval(getAttribute($_GET['presenceID']));
			$location = intval(getAttribute($_GET['location']));

			if ($location) {
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
		                AND `shiftMember`.`statusID` < 2
		                AND (0
		                	OR (1
		                		AND `shiftMember`.`dateBegin` >= NOW() - INTERVAL `shiftMember`.`tolerance` MINUTE
	                    		AND `shiftMember`.`dateBegin` <= NOW() + INTERVAL `shiftMember`.`tolerance` MINUTE
	                    	)
							OR (1
		                    	AND `shiftMember`.`dateEnd` >= NOW() - INTERVAL `shiftMember`.`tolerance` MINUTE
		                    	AND `shiftMember`.`dateEnd` <= NOW() + INTERVAL `shiftMember`.`tolerance` MINUTE
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
					http_status_code(404);
				}
			} else {
				http_status_code(411);	
			}
		} else {
			http_status_code(400);
		}
		
	} else
		
	{ http_status_code(501); }
	
// ------------------------------------------------------------------------------------------- //
?>