<?php

	/**
	 * Create a new member inside the platform
	 * @param  string $name      name of the person
	 * @param  string $password  password of the person
	 * @param  string $cpf       cpf of the person
	 * @param  string $telephone telephone of the person
	 * @param  string $email     email of the person
	 * @param  string $anonymous anonymous or not?
	 * @return integer           memberID
	 */
	function createMember($name, $password, $cpf, $telephone, $email, $anonymous) {

		// Insert the name 
		$insert = resourceForQuery(
			"INSERT INTO
				`member`
				(`name`, `anonymous`)
			VALUES 
				('$name', $anonymous)
		");

		$memberID = mysql_insert_id();

		if ($anonymous == 0) {
			$insert = resourceForQuery(
				"INSERT INTO
					`memberDetail`
					(`id`, `password`, `cpf`, `telephone`, `email`)
				VALUES
					($memberID, '$password', '$cpf', '$telephone', '$email')
			");
		}

		return $memberID;
	}

	/**
	 * Get all the companies inside as an array
	 * @param  int  	$memberID 	id of the member
	 * @return array           		companies
	 */
	function getMemberCompanies($memberID) {

		$result = resourceForQuery(
			"SELECT
				`company`.`id`,
				`company`.`tradeName`,
				`company`.`description`,
				`company`.`image`,
				`company`.`imageTop`,
				`company`.`latitude`,
				`company`.`longitude`,
				`company`.`address`,
				`company`.`city`,
				`company`.`state`,
				`company`.`zipCode`,
				`company`.`telephone`,
				`company`.`email`,
				`company`.`workingTimes`,
				`company`.`waiterAvailable`,
				`company`.`orderAvailable`,
				`company`.`deliveryAvailable`,
				`company`.`reservationAvailable`,
				`company`.`chatAvailable`
			FROM
				`memberCompany`
			INNER JOIN
				`company` ON `company`.`id` = `memberCompany`.`companyID`
			WHERE
				`memberCompany`.`memberID` = $memberID
		");

		return printInformation("memberCompany", $result, true, 'object');
	}

?>