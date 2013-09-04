<?php

	function getMac(){

        $ipAddress = $_SERVER['REMOTE_ADDR'];
        $macAddress = "33";
        
        if ($ipAddress == "::1") { // This is the localhost
        	return true;
        }
        
        #run the external command, break output into lines
        $arp = exec("arp $ipAddress");
        $lines = explode("\n", $arp);
        
        #look for the output line describing our IP address
        foreach($lines as $line) {
           $cols = preg_split('/\s+/', trim($line));
           $macAddress = $cols[3];	           
        }
        
     	return (in_array($macAddress, $core->allowedMAC));
    }

    function eventExists($eventID) {

		$result = resourceForQuery(
			"SELECT
				`event`.`id`
			FROM
				`event`
			WHERE 1
				AND `event`.`id` = $eventID
		");

		if (mysql_num_rows($result) > 0) {
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
				AND `member`.`id` = $memberID
		");

		if (mysql_num_rows($result) > 0) {
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

		if (mysql_num_rows($result) > 0) {
			return mysql_result($result, 0, "eventID");
		} else {
			return 0;
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

		if (mysql_num_rows($result) > 0) {
			return mysql_result($result, 0, "groupID");
		} else {
			return 0;
		}
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

		if (mysql_num_rows($result) > 0) {

			if (file_exists(mysql_result($result, 0, "image"))) {
				
				// Delete the image
				unlink($imageFile);

				// Return the result
				return mysql_result($result, 0, "image");
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
				`activity`.`description`
			FROM
				`activity`
		");

		for ($i = 0; $i < mysql_num_rows($result); $i++) {

			$id = mysql_result($result, $i, "id");
			$name = htmlentities(mysql_result($result, $i, "name"), ENT_COMPAT | ENT_HTML401, "ISO-8859-1");
			$description = htmlentities(mysql_result($result, $i, "description"), ENT_COMPAT | ENT_HTML401, "ISO-8859-1");

			$insert = resourceForQuery(
				"UPDATE
					`activity`
				SET
					`activity`.`name` = '$name',
					`activity`.`description` = '$description'
				WHERE 1
					AND `activity`.`id` = $id
			");
		}

	}

?>