<?php

    function getPeopleAtActivityQuery($activityID, $complement = "", $order = "`activityMember`.`id` ASC") {

        $eventID = getEventForActivity($activityID);

        $result = resourceForQuery(
            "SELECT
                `member`.`id` AS `memberID`,
                `member`.`name`,
                `member`.`email`,
                `member`.`image`,
                `eventMember`.`position` AS `enrollmentID`,
                `activityMember`.`position`,
                `activityMember`.`approved`,
                `activityMember`.`paid`,
                `activityMember`.`present`,
                `activityMember`.`priori`,
                `activityMember`.`rating`
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

    function getPeopleAtGroupQuery($groupID, $complement = "", $order = "`groupMember`.`id` ASC") {

        $result = resourceForQuery(
            "SELECT
                `member`.`id` AS `memberID`,
                `member`.`name`,
                `member`.`email`,
                `member`.`image`,
                `groupMember`.`approved`,
                `groupMember`.`present`
            FROM
                `member`
            INNER JOIN
                `groupMember` ON `member`.`id` = `groupMember`.`memberID`
            WHERE 1
                AND `groupMember`.`groupID` = $groupID
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
        $entries = (mysql_num_rows($result) > 0) ? mysql_result($result, 0, "entries") : 1;

        $result = resourceForQuery(
            "SELECT
                `member`.`id` AS `memberID`,
                `member`.`name`,
                `member`.`role`,
                `member`.`company`,
                `member`.`image`,
                `member`.`telephone`, 
                `member`.`city`, 
                `member`.`email`, 
                `member`.`university`, 
                `member`.`course`,
                `member`.`facebookID`,
                `member`.`linkedInID`,
                `eventMember`.`position` AS `enrollmentID`,
                `eventMember`.`approved`,
                `eventMember`.`roleID`,
                ROUND(SUM(`activityMember`.`present`) / $entries * 100, 2) AS `present`
            FROM
                `member`
            INNER JOIN
                `eventMember` ON `member`.`id` = `eventMember`.`memberID`
            INNER JOIN
                `activity` ON `activity`.`eventID` = `eventMember`.`eventID`
            INNER JOIN
                `activityMember` ON `activityMember`.`activityID` = `activity`.`id` AND `activityMember`.`memberID` = `member`.`id`
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