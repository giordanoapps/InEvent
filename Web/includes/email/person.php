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

	function sendPasswordChangeEmail($email) {

	    // Load our template
	    $template = file_get_contents(__DIR__ . "/passwordChange.html");

	    // Send the email
        sendEmail("Senha trocada", $template, $email);
    }

    function sendSubscribedEmail($email) {

	    // Load our template
	    $template = file_get_contents(__DIR__ . "/personSubscribed.html");

	    // Replace some ocurrences
	    $template = str_replace('{{email}}', $email, $template);

	    // Send the email
        sendEmail("Email adicionado", $template, $email);
    }

    function sendUnsubscribedEmail($email) {

	    // Load our template
	    $template = file_get_contents(__DIR__ . "/personUnsubscribed.html");

	    // Replace some ocurrences
	    $template = str_replace('{{email}}', $email, $template);

	    // Send the email
        sendEmail("Email removido", $template, $email);
    }

?>