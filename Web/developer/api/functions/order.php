<?php

	/**
	 * Append all the necessary data inside the given orderID
	 * @param  object $data Array with all the orders
	 * @return object       An incremented $data object
	 */
	function formatOrder($data) {

		for ($i = 0; $i < $data["count"]; $i++) {

			$orders = $data["data"][$i]["orders"];
			
			// Details
			$result = resourceForQuery(
			// echo (
				"SELECT
					`order`.`id`,
					`order`.`price`,
					`order`.`amount`,
					`order`.`dateSent`,
					`order`.`statusID`,
					`orderStatus`.`title`,
					`orderStatus`.`hint`,
					`orderStatus`.`color`,
					(`order`.`amount` * `order`.`price`) AS `total`
				FROM
					`order`
				INNER JOIN
					`orderStatus` ON `orderStatus`.`id` = `order`.`statusID`
				WHERE 1
					AND `order`.`id` IN ($orders)
			");

			$dataOrder = printInformation("order", $result, true, 'object');

			for ($j = 0; $j < $dataOrder["count"]; $j++) {

				$orderID = $dataOrder["data"][$j]["id"];

				// Options
				$result = resourceForQuery(
					"SELECT
						`orderOptionsItem`.`optionItemID`
					FROM
						`orderOptionsItem`
					WHERE
						`orderOptionsItem`.`orderID` = $orderID
				");
				$dataOrder["data"][$i]["options"] = array();
				for ($k = 0; $k < mysql_num_rows($result); $k++) {
					array_push($dataOrder["data"][$j]["options"], mysql_result($result, $k, "optionItemID"));
				}
			}

			$data["data"][$i]["orders"] = $dataOrder["data"];

			// Item
			$itemID = $data["data"][$i]["item"];
			$dataItem = loadSingleItem($itemID);
			// $dataItem["data"][0]["price"] = $data["data"][$i]["price"];
			$data["data"][$i]["item"] = $dataItem["data"][0];
		}
		
		return $data;
	}

	/**
	 * Receive a order, process it and save on the database
	 * @param  int $itemID  id of the sent item
	 * @param  int $amount  Amount of items
	 * @param  array $options All itemOptionsItem id's
	 * @return object       Json Object
	 */
	function processOrder($personID, $tableUniqueID, $itemID, $amount, $options) {

		// Get the singleton
		$core = Core::singleton();

		if (checkPermission($core->companyID, $itemID, "carteItem")) {
			// Insert the order and get its id
			// Get the item price so we can log it if any changes are applied after
			$insert = resourceForQuery(
				"INSERT INTO
					`order`
					(`memberID`, `tableUniqueID`, `itemID`, `price`, `amount`, `dateSent`)
				SELECT
					$personID,
					$tableUniqueID,
					$itemID,
					`carteItem`.`price`,
					$amount,
					NOW()
				FROM
					`carteItem`
				WHERE
					`carteItem`.`id` = $itemID
			");
			$orderID = mysql_insert_id();

			// The total increment in price
			$totalDelta = 0.0;

			// Process each optionItem
			for ($j = 0; $j < count($options); $j++) {
				$optionItemID = $options[$j];

				if (checkPermission($core->companyID, $optionItemID, "carteItemOptionItem")) {
					// We don't need to check for num of rows because the permission thing already did this for us
					// Increment with the difference (can be positive or negative)
					$totalDelta += $delta;

					// Insert the option on the database
					resourceForQuery(
						"INSERT INTO
							`orderOptionsItem`
							(`orderID`, `optionItemID`, `parentTitle`, `title`, `delta`)
						SELECT
							$orderID,
							$optionItemID,
							`carteItemOptions`.`title` AS `parentTitle`,
							`carteItemOptionsItem`.`title`,
							`carteItemOptionsItem`.`delta`
						FROM
							`carteItemOptionsItem`
						INNER JOIN
							`carteItemOptions` ON `carteItemOptions`.`optionID` = `carteItemOptionsItem`.`optionID`
						WHERE 
							`carteItemOptionsItem`.`id` = $optionItemID
						LIMIT 1
					");
				} else {
					http_status_code(409);
				}
			}

			if ($insert) {

				// Create a new entry on the table division saying that the person who ordered it owns 100% of it
				$insert = resourceForQuery(
					"INSERT INTO
						`tableDivision`
						(`orderID`, `memberID`, `percentage`)
					VALUES
						($orderID, $personID, 1.00)
				");

				// See if we need to update the price on the database if it has changeds
				if ($totalDelta != 0.0) {
					$price += $totalDelta;
					$update = resourceForQuery("UPDATE `order` SET `price` = $price WHERE `id` = $orderID");
				}

				// Insert the notification
				$insert = notificationSave($tableUniqueID, "order/new", "Novo pedido enviado!", $orderID);

				// Return the newly created id
				return $orderID;

			} else {
				http_status_code(500);
			}
		} else {
			http_status_code(409);
		}
	}
?>