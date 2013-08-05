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

    function companyHasMember($companyID, $memberID) {
		$result = resourceForQuery(
			"SELECT
				`member`.`name`
			FROM
				`member`
			WHERE 1
				AND `member`.`companyID` = $companyID
				AND `member`.`id` = $memberID
		");

		if (mysql_num_rows($result) > 0) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Return the username for the given unique id
	 * @param  integer $id unique id
	 * @return string     username
	 */
	function memberForID($memberID) {
		$result = resourceForQuery(
			"SELECT
				`member`.`name`
			FROM
				`member`
			WHERE
				`member`.`id` = $memberID
		");

		if (mysql_num_rows($result) > 0) {
			return mysql_result($result, 0, "name");
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

    function getMemberIDForPresenceID($presenceID) {
        $result = resourceForQuery(
            "SELECT
                `shiftMember`.`memberID`
            FROM
                `shiftMember`
            WHERE
                `shiftMember`.`id` = $presenceID
        ");

        if (mysql_num_rows($result) > 0) {
            return mysql_result($result, 0, "memberID");
        }
    }

    function getMemberCalendarID($memberID) {
    	$result = resourceForQuery(
            "SELECT
                `member`.`calendarID`
            FROM
                `member`
            INNER JOIN
            	`shiftCalendar` ON `member`.`calendarID` = `shiftCalendar`.`id`
            WHERE
                `member`.`id` = $memberID
        ");

        if (mysql_num_rows($result) > 0) {
            return mysql_result($result, 0, "calendarID");
        } else {
        	return 0;
        }
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

    function resizeAllImages() {

    	// Include the master class
    	include_once(__DIR__ . "/../../resize-class.php");

    	// Scan all files
    	$dir = (__DIR__ . "/../../uploads");
		$files = scandir($dir);

		// Loop and resize
		foreach ($files as $file) {

			// Full path
			$path = $dir . "/" . $file;

	        if (getimagesize($path) != FALSE) {
	            // No we are going to resize the image
	            // *** 1) Initialise / load image
	            $resizeObj = new resize($path);
	            // *** 2) Resize image (options: exact, portrait, landscape, auto, crop)
	            $resizeObj -> resizeImage(256, 256, "crop");
	            // *** 3) Save image
	            $resizeObj -> saveImage($path, 100);
	        }
	    }
    }


?>