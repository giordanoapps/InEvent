<?php
    
    function getEventsForMemberQuery($memberID, $exclusive = false) {

        $filter = ($exclusive == true) ? "AND `eventMember`.`memberID` = $memberID" : "";

        $result = resourceForQuery(
        // echo (
            "SELECT
                `event`.`id`,
                `event`.`name`,
                `event`.`nickname`,
                `event`.`description`,
                `event`.`cover`,
                UNIX_TIMESTAMP(`event`.`dateBegin`) AS `dateBegin`,
                UNIX_TIMESTAMP(`event`.`dateEnd`) AS `dateEnd`,
                UNIX_TIMESTAMP(`event`.`enrollmentBegin`) AS `enrollmentBegin`,
                UNIX_TIMESTAMP(`event`.`enrollmentEnd`) AS `enrollmentEnd`,
                `event`.`latitude`,
                `event`.`longitude`,
                `event`.`address`,
                `event`.`city`,
                `event`.`state`,
                `event`.`fugleman`,
                `eventMember`.`roleID`,
                IF(`eventMember`.`memberID` = $memberID, `eventMember`.`approved`, -1) AS `approved`
            FROM
                `event`
            LEFT JOIN
                `eventMember` ON `event`.`id` = `eventMember`.`eventID` AND `eventMember`.`memberID` = $memberID
            WHERE 1
                AND (`event`.`dateEnd` > NOW() OR `eventMember`.`approved` = 1)
                $filter
            GROUP BY
                `event`.`id`
            ORDER BY
                `event`.`dateBegin` ASC,
                `event`.`dateEnd` ASC
        ");

        return $result;
    }

    function getEventForEventQuery($eventID) {

        $result = resourceForQuery(
            "SELECT
                `event`.`id`,
                `event`.`name`,
                `event`.`nickname`,
                `event`.`description`,
                `event`.`cover`,
                UNIX_TIMESTAMP(`event`.`dateBegin`) AS `dateBegin`,
                UNIX_TIMESTAMP(`event`.`dateEnd`) AS `dateEnd`,
                UNIX_TIMESTAMP(`event`.`enrollmentBegin`) AS `enrollmentBegin`,
                UNIX_TIMESTAMP(`event`.`enrollmentEnd`) AS `enrollmentEnd`,
                `event`.`latitude`,
                `event`.`longitude`,
                `event`.`address`,
                `event`.`city`,
                `event`.`state`,
                `event`.`fugleman`,
                COUNT(`eventMember`.`memberID`) AS `entries`
            FROM
                `event`
            LEFT JOIN
                `eventMember` ON `event`.`id` = `eventMember`.`eventID`
            WHERE 1
                AND `event`.`id` = $eventID
            GROUP BY
                `event`.`id`
            ORDER BY
                `event`.`dateBegin` ASC,
                `event`.`dateEnd` ASC
        ");

        return $result;
    }

    function getEventForMemberQuery($eventID, $memberID) {

        $result = resourceForQuery(
            "SELECT
                `event`.`id`,
                `event`.`name`,
                `event`.`nickname`,
                `event`.`description`,
                `event`.`cover`,
                UNIX_TIMESTAMP(`event`.`dateBegin`) AS `dateBegin`,
                UNIX_TIMESTAMP(`event`.`dateEnd`) AS `dateEnd`,
                UNIX_TIMESTAMP(`event`.`enrollmentBegin`) AS `enrollmentBegin`,
                UNIX_TIMESTAMP(`event`.`enrollmentEnd`) AS `enrollmentEnd`,
                `event`.`latitude`,
                `event`.`longitude`,
                `event`.`address`,
                `event`.`city`,
                `event`.`state`,
                `event`.`fugleman`,
                IF(`eventMember`.`memberID` = $memberID, `eventMember`.`id`, 0) AS `enrollmentID`,
                IF(`eventMember`.`memberID` = $memberID, $memberID, 0) AS `memberID`,
                IF(`eventMember`.`memberID` = $memberID, `eventMember`.`approved`, -1) AS `approved`
            FROM
                `event`
            LEFT JOIN
                `eventMember` ON `event`.`id` = `eventMember`.`eventID` AND `eventMember`.`memberID` = $memberID
            WHERE 1
                AND `event`.`id` = $eventID
            GROUP BY
                `event`.`id`
            ORDER BY
                `event`.`dateBegin` ASC,
                `event`.`dateEnd` ASC
        ");

        return $result;
    }

?>