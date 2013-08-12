<?php

	/**
	 * Append all the necessary data inside the given orderID
	 * @param  object $data Array with all the orders
	 * @return object       An incremented $data object
	 */
	function formatDelivery(&$data) {

		// Get the singleton
		$core = Core::singleton();

		for ($i = 0; $i < $data["count"]; $i++) {

			//////////////////////
			// DELIVERY ID
			//////////////////////
			$result = resourceForQuery(
				"SELECT
					`deliveryItem`.`id`,
					`deliveryItem`.`itemID`,
					`deliveryItem`.`amount`
				FROM
					`deliveryItem`
				WHERE 
					`deliveryItem`.`deliveryID`=" . $data["data"][$i]["deliveryID"] . "
			");
			$data["data"][$i]["items"] = array();

			for ($j = 0; $j < mysql_num_rows($result); $j++) {
				//////////////////////
				// DELIVERY ITEM
				//////////////////////
				$data["data"][$i]["items"][$j] = array();
				$data["data"][$i]["items"][$j]["deliveryItemID"] = mysql_result($result, $j, "id");
				$data["data"][$i]["items"][$j]["itemID"] = mysql_result($result, $j, "itemID");
				$data["data"][$i]["items"][$j]["amount"] = mysql_result($result, $j, "amount");

				// We get all the options that have been selected on this order
				$resultOption = resourceForQuery(
					"SELECT 
						`deliveryOptionsItem`.`optionItemID`,
						`deliveryOptionsItem`.`parentTitle`,
						`deliveryOptionsItem`.`title`,
						`deliveryOptionsItem`.`delta`
					FROM
						`deliveryOptionsItem`
					WHERE 
						`deliveryOptionsItem`.`deliveryItemID`=" . $data["data"][$i]["items"][$j]["deliveryItemID"] . "
					");
				$data["data"][$i]["items"][$j]["options"] = array();

				for ($k = 0; $k < mysql_num_rows($resultOption); $k++) {
					//////////////////////
					// DELIVERY OPTION ITEM
					//////////////////////
					$data["data"][$i]["items"][$j]["options"][] = array();
					$data["data"][$i]["items"][$j]["options"][$k]["optionItemID"] = mysql_result($resultOption, $k, "optionItemID");
					$data["data"][$i]["items"][$j]["options"][$k]["parentTitle"] = mysql_result($resultOption, $k, "parentTitle");
					$data["data"][$i]["items"][$j]["options"][$k]["title"] = mysql_result($resultOption, $k, "title");
					$data["data"][$i]["items"][$j]["options"][$k]["delta"] = mysql_result($resultOption, $k, "delta");
				}

				// Replace the itemID with its item
				$itemID = $data["data"][$i]["items"][$j]["itemID"];
				$dataItem = loadSingleItem($itemID);
				$data["data"][$i]["items"][$j]["itemID"] = $dataItem["data"][0];
			}
		}
	}

	/**
	 * Receive a order, process it and save on the database
	 * @param  array $items All items
	 * @return object       Json Object
	 */
	function processDelivery($items) {

		// Get the singleton
		$core = Core::singleton();

		// Insert the order and get its id
		$insert = resourceForQuery("INSERT INTO `delivery` (`memberID`, `companyID`, `price`, `date`) VALUES ($core->memberID, $core->companyID, 0.0, NOW())");
		$deliveryID = mysql_insert_id();

		// The total increment in price
		$totalPrice = 0.0;

		// Process each optionItem
		for ($i = 0; $i < count($items); $i++) {
			$itemID = $items[$i]["itemID"];
			$amount = $items[$i]["amount"];
			$options = $items[$i]["options"];

			if (checkPermission($core->companyID, $itemID, "carteItem")) {
				// We don't need to check for num of rows because the permission thing already did this for us
				$result = resourceForQuery("SELECT `price` FROM `carteItem` WHERE `id`=$itemID LIMIT 1");
				$price = mysql_result($result, 0, "price");

				// Increment with the difference (can be positive or negative)
				$totalPrice += $price;

				// Insert the option on the database
				resourceForQuery("INSERT INTO `deliveryItem` (`deliveryID`, `itemID`, `amount`) VALUES ($deliveryID, $itemID, $amount)");
				$deliveryItemID = mysql_insert_id();

				// Process each optionItem
				for ($j = 0; $j < count($options); $j++) {
					$optionItemID = $options[$j];

					if (checkPermission($core->companyID, $optionItemID, "carteItemOptionItem")) {
						// We don't need to check for num of rows because the permission thing already did this for us
						$result = resourceForQuery(
							"SELECT
								`carteItemOptions`.`title` AS `parentTitle`,
								`carteItemOptionsItem`.`title` AS `title`,
								`carteItemOptionsItem`.`delta` AS `delta`
							FROM
								`carteItemOptionsItem`
							INNER JOIN
								`carteItemOptions` ON `carteItemOptions`.`optionID`=`carteItemOptionsItem`.`optionID`
							WHERE 
								`carteItemOptionsItem`.`id`=$optionItemID
							LIMIT 1
						");

						$parentTitle = mysql_result($result, 0, "title");
						$title = mysql_result($result, 0, "title");
						$delta = mysql_result($result, 0, "delta");

						// Increment with the difference (can be positive or negative)
						$totalPrice += $delta;

						// Insert the option on the database
						resourceForQuery("INSERT INTO `deliveryOptionsItem` (`deliveryItemID`, `optionItemID`, `parentTitle`, `title`, `delta`) VALUES ($deliveryItemID, $optionItemID, '$parentTitle', '$title', $delta)");
					}
				}
			}
		}

		if ($insert) {

			// See if we need to update the price on the database
			if ($totalPrice != 0.0) {
				resourceForQuery("UPDATE `delivery` SET `price`=$totalPrice WHERE `id`=$deliveryID");
			}

			// Get the new order from the database
			$result = resourceForQuery(
				"SELECT
					`delivery`.`id` AS `deliveryID`,
					`delivery`.`price`,
					`delivery`.`date`,
					`delivery`.`statusID`,
					`deliveryStatus`.`title`,
					`deliveryStatus`.`hint`,
					`deliveryStatus`.`color`
				FROM
					`delivery`
				INNER JOIN
					`deliveryStatus` ON `deliveryStatus`.`id`=`delivery`.`statusID`
				WHERE
					`delivery`.`id`=$deliveryID
			");

			$data = printInformation("delivery", $result, true, 'object');

			formatDelivery($data);

			echo json_encode($data);

		} else {
			http_status_code(500);
		}
	}
?>