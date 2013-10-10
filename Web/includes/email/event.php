<?php

    function sendEventEnrollmentEmail($event, $nick, $email) {

	    // Load our template
	    $template = file_get_contents(__DIR__ . "/eventEnrollment.html");

	    // Replace some ocurrences
	    $template = str_replace('{{event}}', $event, $template);
	    $template = str_replace('{{nick}}', $nick, $template);

	    // Send the email
        sendEmail("Inscrição em Evento", $template, $email);
    }

?>