<?php
    
    function getPhotosForEventQuery($eventID) {

        $result = resourceForQuery(
            "SELECT
                `photo`.`id`,
                `photo`.`url`,
                UNIX_TIMESTAMP(`photo`.`date`) AS `date`
            FROM
                `photo`
            WHERE 1
                AND `photo`.`eventID` = $eventID
            ORDER BY
                `photo`.`date` ASC
        ");

        return $result;
    }

?>