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

?>