<?php include_once("includes/check/login.php"); ?>
<?php

// -------------------------------------- MEMBERS --------------------------------------- //

	/**
	 * Verify and insert a new company inside the platform
	 */
	if (isset ($_POST['registration'])) {

		// We receive ther data
		$data = $_POST['registration']; // We still gotta filter it
		
		// Here we have which properties are required to sucessfully register a company
		$requiredProperties = array("companyName", "latitude", "longitude", "address", "city", "state", "zipCode", "bossName", "bossEmail", "bossPassword");

		// We get all the keys
		$dataProperties = array_keys($data);

		// And check if the data has all the required properties
		for ($i = 0; $i < count($requiredProperties); $i++) {
			// We get the name
			$name = $requiredProperties[$i];
			// And see if it is on the given data
			if (array_search($name, $dataProperties) === FALSE) {
				// If not, we can kill the requisition
				http_status_code(411);
			}
		}

		// So past this point we can guarantee that all the required data has been provided
		// We now start to write data inside our database if the data is not a duplicate

		$result = resourceForQuery(
			"SELECT
				`member`.`email`
			FROM
				`member`
			WHERE 0
				OR `member`.`name` = '" . $data["bossName"] . "'
				OR `member`.`email` = '" . $data["bossEmail"] . "'
		");

		if (mysql_num_rows($result) == 0) {

			// Required properties (broken down into two queries)
			// First the COMPANY
			/**
			 * COMPANY
			 * @var string
			 */
			$insert = resourceForQuery(
				"INSERT INTO
					`company` 
					(
						`companyName`,
						`latitude`,
						`longitude`,
						`address`,
						`city`,
						`state`,
						`zipCode`,
						`valid`
					)
				VALUES 
					(
						'" . $data["companyName"] . "', 
						" . $data["latitude"] . ", 
						" . $data["longitude"] . ", 
						'" . $data["address"] . "', 
						'" . $data["city"] . "', 
						'" . $data["state"] . "', 
						'" . $data["zipCode"] . "', 
						0
					)
			");

			// We always check for sql mistakes
			if ($insert) {
				// The ID of the recently registered company
				$companyID = mysql_insert_id();

				// Then the company ADMIN
				/**
				 * Company ADMIN
				 * @var string
				 */
				$insert = resourceForQuery(
					"INSERT INTO
						`member`
						(
							`companyID`,
							`name`,
							`password`,
							`position`,
							`groupID`, 
							`calendarID`,
							`permission`, 
							`photo`, 
							`birthday`, 
							`telephone`, 
							`email`, 
							`active`
						)
					VALUES
						(
							'" . $companyID . "',
							'" . $data["bossName"] . "',
							'" . Bcrypt::hash($data["bossPassword"]) . "',
							'Sem Cargo',
							1,
							0,
							10,
							'128-man.png',
							FROM_UNIXTIME(0),
							'',
							'" . $data["bossEmail"] . "',
							1
						)
				");

				if ($insert) {
					// The ID of the recently registered member
					$memberID = mysql_insert_id();

					// Create a default calendar
					createCalendar("Plantão", $companyID, $memberID);

					// And we confirm the insertion
					printf("%06d", $companyID);
				} else {
					http_status_code(500);
				}
			} else {
				http_status_code(500);
			}
		} else {
			http_status_code(409);
		}

	} else
	
// ----------------------------------------------------------------------------------- //	

	{ http_status_code(501); }

?>