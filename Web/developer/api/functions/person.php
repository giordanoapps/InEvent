<?php

	/**
	 * Create a new member inside the platform
	 * @param  string $name      name of the person
	 * @param  string $password  password of the person
	 * @param  string $email     email of the person
	 * @return integer           memberID
	 */
	function createMember($details) {

		// Required
		$name = getAttribute($details["name"]);
		$email = getAttribute($details["email"]);

		// Optional
		$password = (isset($details["password"])) ? getAttribute($details["password"]) : "123456";
		$hash = Bcrypt::hash($password);
		$cpf = (isset($details["cpf"])) ? getEmptyAttribute($details["cpf"]) : "";
		$rg = (isset($details["rg"])) ? getEmptyAttribute($details["rg"]) : "";
		$city = (isset($details["city"])) ? getEmptyAttribute($details["city"]) : "";
		$university = (isset($details["university"])) ? getEmptyAttribute($details["university"]) : "";
		$course = (isset($details["course"])) ? getEmptyAttribute($details["course"]) : "";
		$telephone = (isset($details["telephone"])) ? getEmptyAttribute($details["telephone"]) : "";
		$usp = (isset($details["usp"])) ? getEmptyAttribute($details["usp"]) : "";
		$linkedInID = (isset($details["linkedInID"])) ? getEmptyAttribute($details["linkedInID"]) : "";
		$facebookID = (isset($details["facebookID"])) ? getEmptyAttribute($details["facebookID"]) : 0;

		// Insert the person 
		$insert = resourceForQuery(
			"INSERT INTO
				`member`
				(
					`name`,
					`password`,
					`cpf`,
					`rg`,
					`usp`,
					`telephone`,
					`city`,
					`email`,
					`university`,
					`course`,
					`facebookID`,
					`linkedInID`
				)
			VALUES 
				(
					'$name',
					'$hash',
					'$cpf',
					'$rg',
					'$usp',
					'$telephone',
					'$city',
					'$email',
					'$university',
					'$course',
					$facebookID,
					'$linkedInID'
				)
		");

		$memberID = mysql_insert_id();

		// Send an email
		sendEnrollmentEmail($name, $password, $email);

		return $memberID;
	}

	/**
	 * Get all the details about a member
	 * @param  int  	$memberID 	id of the member
	 * @return array           		companies
	 */
	function getMemberDetails($memberID) {

		$result = resourceForQuery(
			"SELECT
				`member`.`id`,
				`member`.`name`,
				`member`.`role`,
				`member`.`company`,
				`member`.`image`,
				`member`.`cpf`,
				`member`.`rg`,
				`member`.`usp`,
				`member`.`telephone`,
				`member`.`city`,
				`member`.`email`,
				`member`.`university`,
				`member`.`course`,
				`member`.`facebookID`,
				`member`.`linkedInID`
			FROM
				`member`
			WHERE 1
				AND `member`.`id` = $memberID
		");

		return printInformation("member", $result, true, 'object');
	}

	/**
	 * Get all the events inside as an array
	 * @param  int  	$memberID 	id of the member
	 * @return array           		companies
	 */
	function getMemberEvents($memberID) {

		$result = resourceForQuery(
			"SELECT
				`event`.`id`,
				`event`.`name`,
				`event`.`description`,
				UNIX_TIMESTAMP(`event`.`dateBegin`) AS `dateBegin`,
				UNIX_TIMESTAMP(`event`.`dateEnd`) AS `dateEnd`,
				`event`.`latitude`,
				`event`.`longitude`,
				`event`.`address`,
				`event`.`city`,
				`event`.`state`,
				`eventMember`.`roleID`,
				`memberRole`.`constant`,
				`memberRole`.`title`,
				`eventMember`.`approved`
			FROM
				`event`
			INNER JOIN
				`eventMember` ON `event`.`id` = `eventMember`.`eventID`
			INNER JOIN
				`memberRole` ON `eventMember`.`roleID` = `memberRole`.`id`
			WHERE 1
				AND `eventMember`.`memberID` = $memberID
				AND (`eventMember`.`roleID` = " . @(ROLE_STAFF) . " OR `eventMember`.`roleID` = @(ROLE_COORDINATOR))
		");

		return printInformation("eventMember", $result, true, 'object');
	}

?>