<?php
    
    function getActivitiesForMemberAtEventQuery($eventID, $memberID, $exclusive = false) {
        return getActivitiesForMemberQuery("AND `activity`.`eventID` = $eventID", $memberID, $exclusive);
    }

    function getActivitiesForMemberAtActivityQuery($activityID, $memberID, $exclusive = false) {
        return getActivitiesForMemberQuery("AND `activity`.`id` = $activityID", $memberID, $exclusive);
    }
    
    function getActivitiesForMemberQuery($selector, $memberID, $exclusive) {

        $filter = ($exclusive == true) ? "AND `activityMember`.`memberID` = $memberID" : "";

        $result = resourceForQuery(
        // echo (
            "SELECT
                `activity`.`id`,
                `activity`.`groupID`,
                `activity`.`name`,
                `activity`.`description`,
                `activity`.`latitude`,
                `activity`.`longitude`,
                `activity`.`location`,
                UNIX_TIMESTAMP(`activity`.`dateBegin`) AS `dateBegin`,
                UNIX_TIMESTAMP(`activity`.`dateEnd`) AS `dateEnd`,
                `activity`.`capacity`,
                `activity`.`general`,
                `activity`.`highlight`,
                IF(`activityMember`.`memberID` = $memberID, `activityMember`.`approved`, -1) AS `approved`,
                IF(`activityMember`.`memberID` = $memberID, `activityMember`.`priori`, 0) AS `priori`,
                COALESCE(`activityGroup`.`id`, 0) AS `groupID`
            FROM
                `activity`
            LEFT JOIN
                `activityMember` ON `activity`.`id` = `activityMember`.`activityID` AND `activityMember`.`memberID` = $memberID
            LEFT JOIN
                `activityGroup` ON `activity`.`groupID` = `activityGroup`.`id`
            WHERE 1
                AND (`activityMember`.`memberID` = $memberID OR ISNULL(`activityMember`.`memberID`))
                $selector
                $filter
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
            "SELECT
                `activity`.`id`,
                `activity`.`groupID`,
                `activity`.`name`,
                `activity`.`description`,
                `activity`.`latitude`,
                `activity`.`longitude`,
                `activity`.`location`,
                UNIX_TIMESTAMP(`activity`.`dateBegin`) AS `dateBegin`,
                UNIX_TIMESTAMP(`activity`.`dateEnd`) AS `dateEnd`,
                `activity`.`capacity`,
                `activity`.`general`,
                `activity`.`highlight`,
                COUNT(`activityMember`.`id`) AS `entries`
            FROM
                `activity`
            LEFT JOIN
                `activityMember` ON `activity`.`id` = `activityMember`.`activityID`
            WHERE 1
                AND `activity`.`eventID` = $eventID
            GROUP BY
                `activity`.`id`
            ORDER BY
                `activity`.`dateBegin` ASC,
                `activity`.`dateEnd` ASC
        ");

        return $result;
    }

?>