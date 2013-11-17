<?php
// ----------------------------------------- PERSON ----------------------------------------- //

	if ($method === "create") {

		$eventID = getTokenForEvent();

		if (isset($_POST["tickets"]) && isset($_POST["advertisements"])) {

			// Get some properties
			$tickets = getAttribute($_POST["tickets"]);
			$advertisements = getAttribute($_POST["advertisements"]);			

			if ($tickets > 0 || $advertisements > 0) {

				// Insert a new payment inside our module
				$insert = resourceForQuery(
					"INSERT INTO
						`payment`
						(`eventID`, `tickets`, `advertisements`, `paid`)
					VALUES
						($eventID, $tickets, $advertisements, 0)
				");

				$paymentID = mysqli_insert_id_new();

				// Get the preference
				$preference = paymentAddress($mercadoPago, $paymentID);

				if (!empty($preference['response']['init_point'])) {
					// Return the desired data
					$data["address"] = $preference['response']['init_point'];
					echo json_encode($data);
				} else {
					http_status_code(500, "Couldn't create your address");
				}
			} else {
				http_status_code(406, "tickets or advertisements cannot be null");
			}
		} else {
			http_status_code(400, "tickets and advertisements are required parameters");
		}

	} else

	if ($method === "getPayments") {

		$eventID = getTokenForEvent();

		$result = resourceForQuery(
			"SELECT
				`payment`.`id`,
				`payment`.`tickets`,
				`payment`.`advertisements`,
				`payment`.`preferenceID`
			FROM
				`payment`
			WHERE 1
				AND `payment`.`eventID` = $eventID
		");

		echo printInformation("payment", $result, true, 'json');

	} else

	if ($method === "requestAddress") {

		$eventID = getTokenForEvent();

		if (isset($_GET["paymentID"])) {

			// Define the preference and run the query
			$paymentID = getAttribute($_GET["paymentID"]);
			$preference = paymentAddress($mercadoPago, $paymentID);

			if (!empty($preference['response']['init_point'])) {
				// Return the desired data
				$data["address"] = $preference['response']['init_point'];
				echo json_encode($data);
			} else {
				http_status_code(500, "Couldn't create your address");
			}
		} else {
			http_status_code(400, "paymentID is a required parameter");
		}

	} else

	if ($method === "confirmPayment") {

		if (isset($_GET["collection_id"])) {

			// Get the provided data
			$notificationID = getAttribute($_GET["collection_id"]);

			// Confirm our payment
			$update = paymentConfirmation($mercadoPago, $notificationID, $eventID);	

			if ($update) {
				// Return the desired data
				$data["notificationID"] = $notificationID;
				echo json_encode($data);
			} else {
				http_status_code(500, "Couldn't update your payment");
			}

		} else {
			http_status_code(400, "id is a required parameter");
		}

	} else

	{ http_status_code(501); }

// ------------------------------------------------------------------------------------------- //
?>