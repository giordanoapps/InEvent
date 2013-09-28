<?php

    function getPeopleAtActivityQuery($activityID, $complement = "", $order = "`activityMember`.`id` ASC") {

        $eventID = getEventForActivity($activityID);

        $result = resourceForQuery(
            "SELECT
                `eventMember`.`position` AS `memberID`,
                `member`.`name`,
                `member`.`email`,
                `eventMember`.`position` AS `enrollmentID`,
                `activityMember`.`position`,
                `activityMember`.`approved`,
                `activityMember`.`paid`,
                `activityMember`.`present`,
                `activityMember`.`priori`
            FROM
                `member`
            INNER JOIN
                `eventMember` ON `member`.`id` = `eventMember`.`memberID`
            INNER JOIN
                `activityMember` ON `member`.`id` = `activityMember`.`memberID`
            WHERE 1
                AND `activityMember`.`activityID` = $activityID
                AND `eventMember`.`eventID` = $eventID
                $complement
            ORDER BY
                $order
        ");

        return $result;
    }

    function getPeopleAtEventQuery($eventID, $complement = "", $order = "`member`.`name` ASC") {

        $result = resourceForQuery(
            "SELECT
                COUNT(`activity`.`id`) AS `entries`
            FROM
                `activity`
            WHERE 1
                AND `activity`.`eventID` = $eventID
            GROUP BY
                `activity`.`eventID`
        ");

        // Count always return 1 row
        $entries = mysql_result($result, 0, "entries");

        $result = resourceForQuery(
            "SELECT
                `eventMember`.`position` AS `memberID`,
                `member`.`name`,
                `member`.`cpf`, 
                `member`.`rg`, 
                `member`.`usp`, 
                `member`.`telephone`, 
                `member`.`city`, 
                `member`.`email`, 
                `member`.`university`, 
                `member`.`course`,
                `eventMember`.`position` AS `enrollmentID`,
                `eventMember`.`approved`,
                `eventMember`.`roleID`,
                ROUND(SUM(`activityMember`.`present`) / $entries * 100, 2) AS `present`
            FROM
                `member`
            INNER JOIN
                `eventMember` ON `member`.`id` = `eventMember`.`memberID`
            INNER JOIN
                `activityMember` ON `member`.`id` = `activityMember`.`memberID`
            WHERE 1
                AND `eventMember`.`eventID` = $eventID
                $complement
            GROUP BY
                `activityMember`.`memberID`
            ORDER BY
                $order
        ");

        return $result;
    }

?>