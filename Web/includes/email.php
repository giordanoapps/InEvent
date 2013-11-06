<?php

/**
 * Fetch data from the database and wrap them with html
 */

function sendEmail($title, $template, $email) {

    // Verify that the email is not blacklisted
    $result = resourceForQuery(
        "SELECT
            `emailBlacklist`.`email`
        FROM
            `emailBlacklist`
        WHERE 1
            AND `emailBlacklist`.`email` = '$email'
    ");

    if (mysqli_num_rows($result) == 0) {

        // Import Swift parser
        require_once(__DIR__ . '/../classes/Swift/lib/swift_required.php');

        // Create the Transport
        $transport = new Swift_AWSTransport(
            'AKIAJJ7U5KNZFVK2AN5Q',
            'HJ01wFuJTx8Zow32hQpUEv6ibypkmFBt07siuYJ7'
        );

        // Create the Mailer using your created Transport
        $mailer = Swift_Mailer::newInstance($transport);

        // Create the message
        $message = Swift_Message::newInstance()
            ->setSubject("InEvent - $title")
            ->setFrom(array("contato@estudiotrilha.com.br" => "Estúdio Trilha"))
            ->setTo(array($email))
            ->setBody($template, "text/html");

        $mailer->send($message);
    }
}

// Pages
include_once("email/activity.php");
include_once("email/app.php");
include_once("email/event.php");
include_once("email/person.php");

?>