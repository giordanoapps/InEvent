<?php
    
    function getActivitiesForMemberQuery($eventID, $memberID) {

        $result = resourceForQuery(
        // echo (
            "SELECT
                `activity`.`id`,
                `activity`.`name`,
                `activity`.`description`,
                `activity`.`highlight`,
                DAYOFYEAR(`activity`.`dateBegin`) AS `day`,
                UNIX_TIMESTAMP(`activity`.`dateBegin`) AS `dateBegin`,
                UNIX_TIMESTAMP(`activity`.`dateEnd`) AS `dateEnd`,
                IF(`activityMember`.`memberID` = $memberID, $memberID, 0) AS `memberID`,
                IF(`activityMember`.`memberID` = $memberID, `activityMember`.`approved`, 0) AS `approved`,
                COALESCE(`activityGroup`.`id`, 0) AS `groupID`
            FROM
                `activity`
            INNER JOIN
                `event` ON `event`.`id` = `activity`.`eventID`
            LEFT JOIN
                `activityMember` ON `activity`.`id` = `activityMember`.`activityID`
            LEFT JOIN
                `activityGroup` ON `activity`.`groupID` = `activityGroup`.`id`
            WHERE 1
                AND `event`.`id` = $eventID
                AND (`activityMember`.`memberID` = $memberID OR ISNULL(`activityMember`.`memberID`))
            GROUP BY
                `activity`.`id`
            ORDER BY
                `activity`.`dateBegin` ASC,
                `activity`.`dateEnd` ASC
        ");

        return $result;
    }

    
    function getActivityForMemberQuery($activityID, $memberID) {

        $result = resourceForQuery(
        // echo (
            "SELECT
                `activity`.`id`,
                `activity`.`name`,
                `activity`.`description`,
                `activity`.`highlight`,
                DAYOFYEAR(`activity`.`dateBegin`) AS `day`,
                UNIX_TIMESTAMP(`activity`.`dateBegin`) AS `dateBegin`,
                UNIX_TIMESTAMP(`activity`.`dateEnd`) AS `dateEnd`,
                IF(`activityMember`.`memberID` = $memberID, $memberID, 0) AS `memberID`,
                IF(`activityMember`.`memberID` = $memberID, `activityMember`.`approved`, 0) AS `approved`,
                COALESCE(`activityGroup`.`id`, 0) AS `groupID`
            FROM
                `activity`
            LEFT JOIN
                `activityMember` ON `activity`.`id` = `activityMember`.`activityID`
            LEFT JOIN
                `activityGroup` ON `activity`.`groupID` = `activityGroup`.`id`
            WHERE 1
                AND `activity`.`id` = $activityID
                AND (`activityMember`.`memberID` = $memberID OR ISNULL(`activityMember`.`memberID`))
            GROUP BY
                `activity`.`id`
            ORDER BY
                `activity`.`dateBegin` ASC,
                `activity`.`dateEnd` ASC
        ");

        return $result;
    }

    function getActivitiesForEventQuery($eventID) {

        $result = resourceForQuery(
        // echo (
            "SELECT
                `activity`.`id`,
                `activity`.`name`,
                `activity`.`description`,
                DAYOFYEAR(`activity`.`dateBegin`) AS `day`,
                UNIX_TIMESTAMP(`activity`.`dateBegin`) AS `dateBegin`,
                UNIX_TIMESTAMP(`activity`.`dateEnd`) AS `dateEnd`
            FROM
                `activity`
            INNER JOIN
                `event` ON `event`.`id` =  `activity`.`eventID`
            WHERE 1
                AND `event`.`id` = $eventID
            ORDER BY
                `activity`.`dateBegin` ASC,
                `activity`.`dateEnd` ASC
        ");

        return $result;
    }
?>