<?php

    function eventExists($eventID) {

		$result = resourceForQuery(
			"SELECT
				`event`.`id`
			FROM
				`event`
			WHERE 1
				AND `event`.`id` = $eventID
		");

		if (mysqli_num_rows($result) > 0) {
			return true;
		} else {
			return false;
		}
	}

    function eventHasMember($eventID, $memberID) {

		$result = resourceForQuery(
			"SELECT
				`eventMember`.`id`
			FROM
				`eventMember`
			WHERE 1
				AND `eventMember`.`eventID` = $eventID
				AND `eventMember`.`memberID` = $memberID
		");

		if (mysqli_num_rows($result) > 0) {
			return true;
		} else {
			return false;
		}
	}

    function appHasMember($appID, $memberID) {

		$result = resourceForQuery(
			"SELECT
				`appMember`.`id`
			FROM
				`appMember`
			WHERE 1
				AND `appMember`.`appID` = $appID
				AND `appMember`.`memberID` = $memberID
		");

		if (mysqli_num_rows($result) > 0) {
			return true;
		} else {
			return false;
		}
	}

    function getEventForActivity($activityID) {

		$result = resourceForQuery(
			"SELECT
				`activity`.`eventID`
			FROM
				`activity`
			WHERE 1
				AND `activity`.`id` = $activityID
		");

		if (mysqli_num_rows($result) > 0) {
			return mysqli_result($result, 0, "eventID");
		} else {
			return 0;
		}
	}

    function getEventForGroup($groupID) {

		$result = resourceForQuery(
			"SELECT
				`group`.`eventID`
			FROM
				`group`
			WHERE 1
				AND `group`.`id` = $groupID
		");

		if (mysqli_num_rows($result) > 0) {
			return mysqli_result($result, 0, "eventID");
		} else {
			return 0;
		}
	}

    function getActivityName($activityID) {

		$result = resourceForQuery(
			"SELECT
				`activity`.`name`
			FROM
				`activity`
			WHERE 1
				AND `activity`.`id` = $activityID
		");

		if (mysqli_num_rows($result) > 0) {
			return html_entity_decode(mysqli_result($result, 0, "name"), ENT_COMPAT, "UTF-8");
		} else {
			return "";
		}
	}

    function getEventName($eventID) {

		$result = resourceForQuery(
			"SELECT
				`event`.`name`
			FROM
				`event`
			WHERE 1
				AND `event`.`id` = $eventID
		");

		if (mysqli_num_rows($result) > 0) {
			return html_entity_decode(mysqli_result($result, 0, "name"), ENT_COMPAT, "UTF-8");
		} else {
			return "";
		}
	}

    function getEventNick($eventID) {

		$result = resourceForQuery(
			"SELECT
				`event`.`nickname`
			FROM
				`event`
			WHERE 1
				AND `event`.`id` = $eventID
		");

		if (mysqli_num_rows($result) > 0) {
			return html_entity_decode(mysqli_result($result, 0, "nickname"), ENT_COMPAT, "UTF-8");
		} else {
			return "";
		}
	}
	
    function getEventForNickname($nickname) {

		$result = resourceForQuery(
			"SELECT
				`event`.`id`
			FROM
				`event`
			WHERE 1
				AND `event`.`nickname` = '$nickname'
		");

		if (mysqli_num_rows($result) > 0) {
			return mysqli_result($result, 0, "id");
		} else {
			return "";
		}
	}

    function getGroupForActivity($activityID) {

		$result = resourceForQuery(
			"SELECT
				`activity`.`groupID`
			FROM
				`activity`
			WHERE
				`activity`.`id` = $activityID
		");

		if (mysqli_num_rows($result) > 0) {
			return mysqli_result($result, 0, "groupID");
		} else {
			return 0;
		}
	}

	function getEmailForPerson($personID) {

		$result = resourceForQuery(
			"SELECT
				`member`.`email`
			FROM
				`member`
			WHERE
				`member`.`id` = $personID
		");

		if (mysqli_num_rows($result) > 0) {
			return mysqli_result($result, 0, "email");
		} else {
			return "";
		}
	}

	function getPersonForEmail($email) {

		$result = resourceForQuery(
			"SELECT
				`member`.`id`
			FROM
				`member`
			WHERE 1
				AND BINARY `member`.`email` = '$email'
		");

		if (mysqli_num_rows($result) > 0) {
			$personID = mysqli_result($result, 0, "id");
		} else {
			$personID = 0;
		}

		return $personID;
	}

	/**
	 * Truncate name of something if it is bigger than maxSize
	 * @param  [string] $name    	Name to truncate
	 * @param  [int] 	$maxSize 	Max size of the name
	 * @return [string] 			Truncated name
	 */
	function truncateName($name, $maxSize, $delimiter = " ") {
		// If the name is too big, we gotta truncate it
		if (strlen(html_entity_decode($name)) > $maxSize) {
			$truncatedName = "";
			$nomes = explode($delimiter, $name);
			// We will truncate everything that comes after the given name
			for ($i = 0; $i < count($nomes); $i++) {
				if ($i == 0) {
					$truncatedName .= $nomes[$i] . " ";
				} else {
					$truncatedName .= substr($nomes[$i], 0, 1) . ". "; 
				}
			}

			// We now check it again
			if (strlen(html_entity_decode($truncatedName)) > $maxSize) {
				// If not, we truncate it right at the max size
				return substr($truncatedName, 0, $maxSize - 1) . ".";
			} else {
				return $truncatedName;
			}

		} else {
			return $name;
		}
	}

	function getDayNameForDate($date) {

		$day = date('D', $date);

		$week = array(
			'Sun' => 'Domingo',
			'Mon' => 'Segunda-Feira',
			'Tue' => 'Terça-Feira',
			'Wed' => 'Quarta-Feira',
			'Thu' => 'Quinta-Feira',
			'Fri' => 'Sexta-Feira',
			'Sat' => 'Sábado'
	    );

	    return $week["$day"];
	}
 
 	function getMonthNameForDate($date) {

 		$month = date('M', $date);

		$year = array(
			'Jan' => 'Janeiro',
			'Feb' => 'Fevereiro',
			'Mar' => 'Março',
			'Apr' => 'Abril',
			'May' => 'Maio',
			'Jun' => 'Junho',
			'Jul' => 'Julho',
			'Aug' => 'Agosto',
			'Nov' => 'Novembro',
			'Sep' => 'Setembro',
			'Oct' => 'Outubro',
			'Dec' => 'Dezembro'
		);

		return $year["$month"];
	}

	/**
	 * Get the hash from the database
	 * @param  string $imageFile image path
	 * @return 
	 */
	function getImageUsingHash($imageFile) {

		// Generate the hash
		$hash = md5_file($imageFile);

		$result = resourceForQuery("SELECT `image` FROM `image` WHERE `hash`='$hash'");	

		if (mysqli_num_rows($result) > 0) {

			if (file_exists(mysqli_result($result, 0, "image"))) {
				
				// Delete the image
				unlink($imageFile);

				// Return the result
				return mysqli_result($result, 0, "image");
			} else {
				$update = resourceForQuery("UPDATE `image` SET `image`='$imageFile' WHERE `hash`='$hash'");

				if ($update) {
					return $imageFile;
				} else {
					die("Couldn't change this image!");
				}
			}

		} else {

			$insert = resourceForQuery("INSERT INTO `image` (`image`, `hash`) VALUES ('$imageFile', '$hash')");

			if ($insert) {
				return $imageFile;
			} else {
				die("Could write this image!");
			}
		}
	}

	function encodeEntities() {

		$result = resourceForQuery(
			"SELECT
				`activity`.`id`,
				`activity`.`name`,
				`activity`.`description`,
				`activity`.`location`
			FROM
				`activity`
			WHERE
				`activity`.`eventID` = 4
		");

		for ($i = 0; $i < mysqli_num_rows($result); $i++) {

			$id = mysqli_result($result, $i, "id");
			$name = htmlentities(mysqli_result($result, $i, "name"), ENT_COMPAT | ENT_HTML401, "ISO-8859-1");
			$description = htmlentities(mysqli_result($result, $i, "description"), ENT_COMPAT | ENT_HTML401, "ISO-8859-1");
			$location = htmlentities(mysqli_result($result, $i, "location"), ENT_COMPAT | ENT_HTML401, "ISO-8859-1");

			$insert = resourceForQuery(
				"UPDATE
					`activity`
				SET
					`activity`.`name` = '$name',
					`activity`.`description` = '$description',
					`activity`.`location` = '$location'
				WHERE 1
					AND `activity`.`id` = $id
			");
		}
	}

	function writePosition() {

		// Activity
		$result = resourceForQuery(
			"SELECT
				`activityMember`.`id`,
				`activityMember`.`activityID`
			FROM
				`activityMember`
			WHERE 1
				AND `activityMember`.`activityID` >= 80
				AND `activityMember`.`activityID` < 150
		");

		for ($i = 0; $i < mysqli_num_rows($result); $i++) {

			$id = mysqli_result($result, $i, "id");
			$activityID = mysqli_result($result, $i, "activityID");

			$resultCount = resourceForQuery(
				"SELECT
					COUNT(`activityMember`.`id`) AS `entries`
				FROM
					`activityMember`
				WHERE 1
					AND `activityMember`.`activityID` = $activityID
					AND `activityMember`.`id` <= $id
			");

			$entries = mysqli_result($resultCount, 0, "entries");

			$insert = resourceForQuery(
				"UPDATE
					`activityMember`
				SET
					`activityMember`.`position` = $entries
				WHERE 1
					AND `activityMember`.`id` = $id
			");
		}

		// Event
		// $result = resourceForQuery(
		// 	"SELECT
		// 		`eventMember`.`id`,
		// 		`eventMember`.`eventID`
		// 	FROM
		// 		`eventMember`
		// ");

		// for ($i = 0; $i < mysqli_num_rows($result); $i++) {

		// 	$id = mysqli_result($result, $i, "id");
		// 	$eventID = mysqli_result($result, $i, "eventID");

		// 	$resultCount = resourceForQuery(
		// 		"SELECT
		// 			COUNT(`eventMember`.`id`) AS `entries`
		// 		FROM
		// 			`eventMember`
		// 		WHERE 1
		// 			AND `eventMember`.`eventID` = $eventID
		// 			AND `eventMember`.`id` <= $id
		// 	");

		// 	$entries = mysqli_result($resultCount, 0, "entries");

		// 	$insert = resourceForQuery(
		// 		"UPDATE
		// 			`eventMember`
		// 		SET
		// 			`eventMember`.`position` = $entries
		// 		WHERE 1
		// 			AND `eventMember`.`id` = $id
		// 	");
		// }
	}

?>