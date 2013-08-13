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

	$result = mysql_query($query);

	// Create some constants as variables, because we want to use them inside strings without concatenating
	for ($i = 0; $i < mysql_num_rows($result); $i++) {
		define(mysql_result($result, $i, "constant"), mysql_result($result, $i, "id"));
	}

?>