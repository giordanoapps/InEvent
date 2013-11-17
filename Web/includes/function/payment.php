<?php

	/**
	 * Generate MP unique address to process the ticket's payment
	 * @param  string $eventID   id of event
	 * @return integer           memberID
	 */
	function paymentAddress($mercadoPago, $paymentID) {

		// See if the order is open already
		$result = resourceForQuery(
			"SELECT
				`payment`.`eventID`,
				`payment`.`tickets`,
				`payment`.`advertisements`,
				`payment`.`preferenceID`
			FROM
				`payment`
			WHERE 1
				AND `payment`.`id` = $paymentID
		");

		$preferenceID = (mysqli_num_rows($result) > 0) ? mysqli_result($result, 0, "preferenceID") : 0;

		// And process states accordingly
		if (!empty($preferenceID)) {
		
			$preference = $mercadoPago->get_preference($preferenceID);

		} else {

			// Get some properties
			$nick = getEventNick(mysqli_result($result, 0, "eventID"));
			$tickets = mysqli_result($result, 0, "tickets");
			$advertisements = mysqli_result($result, 0, "advertisements");

			// Set some items
			$preference_data = array(
			    "items" => array(
			       array(
			           "title" => "Pagamento do evento",
			           "description" => "$tickets tickets e $advertisements ads",
			           "quantity" => 1,
			           "currency_id" => "BRL",
			           "unit_price" => ($tickets * 2.3 + $advertisements * 1.5)
			       )
			    ),
			    "external_reference" => $paymentID,
			    "back_urls" => array(
			    	"success" => "http://inevent.us/$nick/receive-ipn.php"
		    	)
			);

			// Define the preference and run the query
			$preference = $mercadoPago->create_preference($preference_data);

			// Update the current paymentID
			if (count($preference['response']) > 0) {

				$preferenceID = $preference['response']['id'];

				// Update
				$update = resourceForQuery(
					"UPDATE
						`payment`
					SET
						`payment`.`preferenceID` = '$preferenceID'
					WHERE 1
						AND `payment`.`id` = $paymentID
				");
			}
		}

		return $preference;

	}

	/**
	 * Receive a MP'IPN and write it back inside our database
	 * @param  string $preferenceID  		MP unique id
	 * @param  string $eventID				id of event
	 * @return bool 							operation success
	 */
	function paymentConfirmation($mercadoPago, $notificationID, $eventID) {

		// Get the payment reported by the IPN. Glossary of attributes response in https://developers.mercadopago.com
		$payment_info = $mercadoPago->get_payment_info($notificationID);

		// Show payment information
		if ($payment_info["response"]["collection"]["status"] == "approved") {

			$paymentID = $payment_info['response']["collection"]["external_reference"];

			$update = resourceForQuery(
				"UPDATE
					`payment`
				SET
					`payment`.`paid` = 1
				WHERE 1
					AND `payment`.`id` = $paymentID
			");

			return $update;

		} else {
			http_status_code(412, "Your MP credentials are invalid");
		}

	}

?>