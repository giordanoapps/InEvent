<?php
    
    function getActivitiesForMemberAtEventQuery($eventID, $memberID) {
        return getActivitiesForMemberQuery("AND `activity`.`eventID` = $eventID", $memberID);
    }

    function getActivitiesForMemberAtActivityQuery($activityID, $memberID) {
        return getActivitiesForMemberQuery("AND `activity`.`id` = $activityID", $memberID);
    }
    
    function getActivitiesForMemberQuery($selector, $memberID) {

        $result = resourceForQuery(
        // echo (
            "SELECT
                `activity`.`id`,
                `activity`.`name`,
                `activity`.`capacity`,
                `activity`.`description`,
                `activity`.`highlight`,
                DAYOFYEAR(`activity`.`dateBegin`) AS `day`,
                UNIX_TIMESTAMP(`activity`.`dateBegin`) AS `dateBegin`,
                UNIX_TIMESTAMP(`activity`.`dateEnd`) AS `dateEnd`,
                IF(`activityMember`.`memberID` = $memberID, $memberID, 0) AS `memberID`,
                IF(`activityMember`.`memberID` = $memberID, `activityMember`.`approved`, 0) AS `approved`,
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
                `activity`.`name`,
                `activity`.`description`,
                `activity`.`capacity`,
                COUNT(`activityMember`.`id`) AS `entries`,
                DAYOFYEAR(`activity`.`dateBegin`) AS `day`,
                UNIX_TIMESTAMP(`activity`.`dateBegin`) AS `dateBegin`,
                UNIX_TIMESTAMP(`activity`.`dateEnd`) AS `dateEnd`
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