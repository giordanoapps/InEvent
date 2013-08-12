<?php

	/**
	 * Load all the items inside a specific level of the carte
	 * @param  int $parentID    id of the parent
	 * @param  string $table       name of the child table
	 * @param  string $tableParent name of the parent table
	 * @return object              a data object
	 */
	function loadCarteLevel($parentID, $table, $tableParent) {
		// Init variables
		$data = array();
		$data["data"] = array();

		// Get all the relations between the parent and its childs
		$result = resourceForQuery(
			"SELECT
				`$tableParent`.`childID`
			FROM
				`$tableParent`
			WHERE
				`$tableParent`.`parentID` = $parentID
		");

		// Acquire each identified parent
		for ($i = 0; $i < mysql_num_rows($result); $i++) {
			$fieldID = mysql_result($result, $i, "childID");

			// Load each child
			if ($table == "carteItem") {
				// This item needs to load extra properties
				$dataInternal = loadSingleItem($fieldID);
			} else {
				$resultInternal = resourceForQuery("SELECT * FROM `$table` WHERE `id` = $fieldID");
				$dataInternal = printInformation("$table", $resultInternal, true, 'object');				
			}

			// Append the object
			$data["data"][$i] = $dataInternal["data"][0];
		}

		// Update the count after adding all the categories
		$data["count"] = count($data["data"]);

		return $data;
	}

	/**
	 * * Create an object with all the necessary data form a single item
	 * @param  int $itemID    the single item id
	 * @return object         a data object
	 */
	function loadSingleItem($itemID) {

		// We cannot inner join all the tables because need to nest them

		// Load the item
		$resultInternal = resourceForQuery(
			"SELECT
				`carteItem`.`id`,
				`carteItem`.`title`,
				`carteItem`.`description`,
				`carteItem`.`code`,
				`carteItem`.`price`,
				`carteItem`.`available`
			FROM
				`carteItem`
			WHERE
				`carteItem`.`id` = $itemID
		");
		$dataInternal = printInformation("carteItem", $resultInternal, true, 'object');

		// The item needs to load his extra images
		$resultExtraImages = resourceForQuery(
			"SELECT
				`carteItemImages`.`image`
			FROM
				`carteItemImages`
			WHERE
				`carteItemImages`.`itemID` = $itemID
		");
		$dataExtraImages = printInformation("carteItemImages", $resultExtraImages, true, 'object');
		$dataInternal["data"][0]["images"] = $dataExtraImages["data"];
		// $dataInternal["data"][0]["extraImages"] = $dataExtraImages["data"]; // Compatibility

		// The item needs to load his options
		$resultOptions = resourceForQuery(
			"SELECT
				`carteItemOptions`.`id`,
				`carteItemOptions`.`title`,
				`carteItemOptions`.`minimumAmount`,
				`carteItemOptions`.`maximumAmount`,
				`carteItemOptions`.`defaultID`
			FROM
				`carteItemOptions`
			WHERE
				`carteItemOptions`.`itemID` = $itemID
		");
		$dataOptions = printInformation("carteItemOptions", $resultOptions, true, 'object');
		// Load each optionItem
		for ($i = 0; $i < mysql_num_rows($resultOptions); $i++) {
			$optionID = mysql_result($resultOptions, $i, "id");
			$resultOptionItem = resourceForQuery(
				"SELECT
					`carteItemOptionsItem`.`id`,
					`carteItemOptionsItem`.`title`,
					`carteItemOptionsItem`.`delta`
				FROM
					`carteItemOptionsItem`
				WHERE
					`carteItemOptionsItem`.`optionID` = $optionID
				ORDER BY
					`carteItemOptionsItem`.`id` ASC
			");
			$dataOptionItem = printInformation("carteItemOptionsItem", $resultOptionItem, true, 'object');
			$dataOptions["data"][$i]["optionsItems"] = $dataOptionItem["data"];
		}
		// Append the options to the items
		$dataInternal["data"][0]["options"] = $dataOptions["data"];

		return $dataInternal;
	}
?>