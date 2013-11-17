<?php
	include_once("includes/check/login.php");

	if (isset($_GET["collection_id"])) {

		// Get the provided data
		$notificationID = getAttribute($_GET["collection_id"]);

		// Confirm our payment
		$update = paymentConfirmation($mercadoPago, $notificationID, $core->eventID);	

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
?>
