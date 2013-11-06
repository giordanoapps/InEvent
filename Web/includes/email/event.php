<?php

    function sendEventEnrollmentEmail($eventID, $personID) {

	    // Load our template
	    $template = file_get_contents(__DIR__ . "/eventEnrollment.html");

	    $result = resourceForQuery(
			"SELECT
				`event`.`name`,
				`event`.`nickname`
			FROM
				`event`
			WHERE 1
				AND `event`.`id` = $eventID
			LIMIT 1
		");

		// Get some properties from the event
		$event = mysqli_result($result, 0, "name");
		$nick = mysqli_result($result, 0, "nickname");

		$result = resourceForQuery(
			"SELECT
				`member`.`name`,
				COALESCE(`memberSessions`.`sessionKey`, '') AS `sessionKey`
			FROM
				`member`
			LEFT JOIN
				`memberSessions` ON `memberSessions`.`memberID` = `member`.`id`
			WHERE 1
				AND `memberSessions`.`memberID` = $personID
			ORDER BY
				`memberSessions`.`id` DESC
		");

		// Get some properties from the person
		$name = mysqli_result($result, 0, "name");
		$tokenID = mysqli_result($result, 0, "sessionKey");

	    // Replace some ocurrences
	    $template = str_replace('{{event}}', $event, $template);
	    $template = str_replace('{{nick}}', $nick, $template);
	    $template = str_replace('{{eventID}}', $eventID, $template);
	    $template = str_replace('{{tokenID}}', $tokenID, $template);
	    $template = str_replace('{{memberID}}', $personID, $template);
	    $template = str_replace('{{name}}', $name, $template);

	    // Get the person email
	    $email = getEmailForPerson($personID);

	    // Send the email
        sendEmail("Inscrição em Evento", $template, $email);
    }

?>