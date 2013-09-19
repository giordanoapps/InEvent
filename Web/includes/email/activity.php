<?php

    function sendActivityEnrollmentEmail($activity, $email) {

	    // Load our template
	    $template = file_get_contents(__DIR__ . "/activityEnrollment.html");

	    // Replace some ocurrences
	    $template = str_replace('{{activity}}', $activity, $template);

	    // Send the email
        sendEmail("Inscrição em Atividade Destacada", $template, $email);
    }

?>