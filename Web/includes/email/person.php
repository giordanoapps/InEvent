<?php

    function sendEnrollmentEmail($name, $password, $email) {

	    // Load our template
	    $template = file_get_contents(__DIR__ . "/personEnrollment.html");

	    // Replace some ocurrences
	    $template = str_replace('{{name}}', $name, $template);
	    $template = str_replace('{{password}}', $password, $template);

	    // Send the email
        sendEmail("Inscrição", $template, $email);
    }

    function sendRecoveryEmail($password, $email) {

	    // Load our template
	    $template = file_get_contents(__DIR__ . "/passwordRecovery.html");

	    // Replace some ocurrences
	    $template = str_replace('{{password}}', $password, $template);

	    // Send the email
        sendEmail("Sua nova senha", $template, $email);
    }

?>