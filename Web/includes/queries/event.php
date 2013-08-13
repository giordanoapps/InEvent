<?php
    
    function getActivitiesForMemberQuery($eventID, $memberID) {

        $result = resourceForQuery(
        // echo (
            "SELECT
                `activityMember`.`id`,
                `activity`.`name`,
                `activity`.`description`,
                UNIX_TIMESTAMP(`activity`.`dateBegin`) AS `dateBegin`,
                UNIX_TIMESTAMP(`activity`.`dateEnd`) AS `dateEnd`
            FROM
                `activityMember`
            INNER JOIN
                `activity` ON `activity`.`id` =  `activityMember`.`activityID`
            INNER JOIN
                `event` ON `event`.`id` =  `activity`.`eventID`
            WHERE 1
                AND `event`.`id` = $eventID
                AND `activityMember`.`memberID` = $memberID
            ORDER BY
                `activity`.`dateBegin` ASC
        ");

        return $result;
    }

    function getActivitiesForEventQuery($eventID) {

        $result = resourceForQuery(
        // echo (
            "SELECT
                `activity`.`name`,
                `activity`.`description`,
                UNIX_TIMESTAMP(`activity`.`dateBegin`) AS `dateBegin`,
                UNIX_TIMESTAMP(`activity`.`dateEnd`) AS `dateEnd`
            FROM
                `activity`
            INNER JOIN
                `event` ON `event`.`id` =  `activity`.`eventID`
            WHERE 1
                AND `event`.`id` = $eventID
            ORDER BY
                `activity`.`dateBegin` ASC
        ");

        return $result;
    }
?>