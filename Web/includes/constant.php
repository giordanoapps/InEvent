<?php

	$constantTables = array("memberRole");

	$query = "";

	// Union of all the tables
	for ($i = 0; $i < count($constantTables); $i++) {

		$constantTable = $constantTables[$i];

		$query .= (
			"SELECT
				`$constantTable`.`id`,
				`$constantTable`.`constant`
			FROM
				`$constantTable`
		");

		if ($i + 1 != count($constantTables)) {
			$query .= (
				"UNION
			");
		}
	}

	$result = mysqli_query($mysqli, $query);

	// Create some constants as variables, because we want to use them inside strings without concatenating
	while ($data = $result->fetch_array()) {
		define($data["constant"], $data["id"]);
	}

?>