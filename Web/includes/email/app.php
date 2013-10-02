<?php

    function sendAppInformation($email) {

	    // Load our template
	    $template = file_get_contents(__DIR__ . "/appAttributes.html");

	    // Send the email
        sendEmail("Aplicativo oficial InEvent", $template, $email);
    }

?>