<?php
    
    function getAppDetails($appID, $order = "id") {

        $result = resourceForQuery(
            "SELECT
                `app`.`id`,
                `app`.`name`,
                `app`.`secret`
            FROM
                `app`
            WHERE 1
                AND `app`.`id` = $appID
            ORDER BY
                $order
        ");

        return $result;
    }

    function getAppMemberDetails($appID) {

        $result = resourceForQuery(
            "SELECT
                `member`.`id` AS `memberID`,
                `member`.`name`,
                `member`.`email`,
                `appMember`.`roleID`
            FROM
                `member`
            INNER JOIN
                `appMember` ON `member`.`id` = `appMember`.`memberID`
            WHERE 1
                AND `appMember`.`appID` = $appID
        ");

        return $result;
    }

    function getAppEventDetails($appID) {

        $result = resourceForQuery(
            "SELECT
                `event`.`id` AS `eventID`,
                `event`.`name`,
                `event`.`nickname`,
                UNIX_TIMESTAMP(`event`.`dateBegin`) AS `dateBegin`,
                UNIX_TIMESTAMP(`event`.`dateEnd`) AS `dateEnd`,
                UNIX_TIMESTAMP(`event`.`enrollmentBegin`) AS `enrollmentBegin`,
                UNIX_TIMESTAMP(`event`.`enrollmentEnd`) AS `enrollmentEnd`,
                `event`.`city`,
                `event`.`state`,
                `event`.`fugleman`,
                COUNT(`eventMember`.`memberID`) AS `entries`
            FROM
                `appEvent`
            INNER JOIN
                `event` ON `event`.`id` = `appEvent`.`eventID`
            LEFT JOIN
                `eventMember` ON `event`.`id` = `eventMember`.`eventID`
            WHERE 1
                AND `appEvent`.`appID` = $appID
            GROUP BY
                `event`.`id`
        ");

        return $result;
    }

?>