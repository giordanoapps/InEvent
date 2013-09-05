<?php
    
    function getEventsForMemberQuery($memberID, $exclusive = false) {

        $selector = ($exclusive == true) ? "AND `eventMember`.`memberID` = $memberID" : "";

        $result = resourceForQuery(
        // echo (
            "SELECT
                `event`.`id`,
                `event`.`name`,
                `event`.`description`,
                UNIX_TIMESTAMP(`event`.`dateBegin`) AS `dateBegin`,
                UNIX_TIMESTAMP(`event`.`dateEnd`) AS `dateEnd`,
                `event`.`latitude`,
                `event`.`longitude`,
                `event`.`address`,
                `event`.`city`,
                `event`.`state`,
                `event`.`zipCode`,
                `eventMember`.`roleID`,
                IF(`eventMember`.`memberID` = $memberID, $memberID, 0) AS `memberID`,
                IF(`eventMember`.`memberID` = $memberID, `eventMember`.`approved`, 0) AS `approved`
            FROM
                `event`
            LEFT JOIN
                `eventMember` ON `event`.`id` = `eventMember`.`eventID` AND `eventMember`.`memberID` = $memberID
            WHERE 1
                AND (`event`.`dateEnd` > NOW() OR `eventMember`.`approved` = 1)
                $selector
            GROUP BY
                `event`.`id`
            ORDER BY
                `event`.`dateBegin` ASC,
                `event`.`dateEnd` ASC
        ");

        return $result;
    }

?>