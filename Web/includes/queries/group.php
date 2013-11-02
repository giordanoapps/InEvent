<?php
    
    function getGroupsForMemberAtEventQuery($eventID, $memberID, $exclusive = false) {
        return getGroupsForMemberQuery("AND `group`.`eventID` = $eventID", $memberID, $exclusive);
    }

    function getGroupsForMemberAtGroupQuery($groupID, $memberID, $exclusive = false) {
        return getGroupsForMemberQuery("AND `group`.`id` = $groupID", $memberID, $exclusive);
    }
    
    function getGroupsForMemberQuery($selector, $memberID, $exclusive) {

        $filter = ($exclusive == true) ? "AND `groupMember`.`memberID` = $memberID" : "";

        $result = resourceForQuery(
        // echo (
            "SELECT
                `group`.`id`,
                `group`.`name`,
                `group`.`description`,
                `group`.`location`,
                UNIX_TIMESTAMP(`group`.`dateBegin`) AS `dateBegin`,
                UNIX_TIMESTAMP(`group`.`dateEnd`) AS `dateEnd`,
                `group`.`highlight`,
                IF(`groupMember`.`memberID` = $memberID, $memberID, 0) AS `memberID`,
                IF(`groupMember`.`memberID` = $memberID, `groupMember`.`approved`, -1) AS `approved`
            FROM
                `group`
            LEFT JOIN
                `groupMember` ON `group`.`id` = `groupMember`.`groupID` AND `groupMember`.`memberID` = $memberID
            WHERE 1
                AND (`groupMember`.`memberID` = $memberID OR ISNULL(`groupMember`.`memberID`))
                $selector
                $filter
            GROUP BY
                `group`.`id`
            ORDER BY
                `group`.`dateBegin` ASC,
                `group`.`dateEnd` ASC
        ");

        return $result;
    }

    function getGroupsForEventQuery($eventID) {

        $result = resourceForQuery(
            "SELECT
                `group`.`id`,
                `group`.`name`,
                `group`.`description`,
                `group`.`location`,
                UNIX_TIMESTAMP(`group`.`dateBegin`) AS `dateBegin`,
                UNIX_TIMESTAMP(`group`.`dateEnd`) AS `dateEnd`,
                `group`.`highlight`,
                COUNT(`groupMember`.`id`) AS `entries`
            FROM
                `group`
            WHERE 1
                AND `group`.`eventID` = $eventID
            GROUP BY
                `group`.`id`
            ORDER BY
                `group`.`dateBegin` ASC,
                `group`.`dateEnd` ASC
        ");

        return $result;
    }

?>