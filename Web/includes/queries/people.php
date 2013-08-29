<?php

    function getPeopleAtActivityQuery($activityID, $complement = "", $order = "`activityMember`.`id`") {

        $result = resourceForQuery(
            "SELECT
                `member`.`id` AS `memberID`,
                `member`.`name`,
                `member`.`telephone`,
                `activityMember`.`id` AS `requestID`,
                `activityMember`.`approved`,
                `activityMember`.`paid`,
                `activityMember`.`present`,
                `activityMember`.`priori`
            FROM
                `member`
            INNER JOIN
                `activityMember` ON `member`.`id` = `activityMember`.`memberID`
            WHERE 1
                AND `activityMember`.`activityID` = $activityID
                $complement
            ORDER BY
                $order ASC
        ");

        return $result;
    }

    function getPeopleAtEventQuery($eventID, $complement = "", $order = "`member`.`name`") {

        $result = resourceForQuery(
            "SELECT
                `member`.`id` AS `memberID`,
                `member`.`name`,
                `member`.`cpf`, 
                `member`.`rg`, 
                `member`.`usp`, 
                `member`.`telephone`, 
                `member`.`city`, 
                `member`.`email`, 
                `member`.`university`, 
                `member`.`course`,
                `eventMember`.`id` AS `requestID`,
                `eventMember`.`approved`,
                `eventMember`.`roleID`
            FROM
                `member`
            INNER JOIN
                `eventMember` ON `member`.`id` = `eventMember`.`memberID`
            WHERE 1
                AND `eventMember`.`eventID` = $eventID
                $complement
            ORDER BY
                $order ASC
        ");

        return $result;
    }

?>