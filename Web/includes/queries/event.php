<?php

    /**
     * Get all entries inside a given period of time
     * @param  int  $calendarID id of calendar
     * @param  date $dateBegin  lower limit
     * @param  date $dateEnd    upper limit
     * @return resource
     */
    function getPeriodForDateQuery($calendarID, $dateBegin, $dateEnd) {

        $result = resourceForQuery(
        // echo (
            "SELECT
                `shiftMember`.`id`
            FROM
                `shiftMember`
            WHERE 1
                AND `shiftMember`.`calendarID` = $calendarID
                AND `shiftMember`.`dateBegin` >= FROM_UNIXTIME($dateBegin)
                AND `shiftMember`.`dateEnd` <= FROM_UNIXTIME($dateEnd)
            ORDER BY
                `shiftMember`.`id` ASC
        ");

        return $result;
    }
    
    /**
     * Get all entries inside a given period of time
     * @param  int  $calendarID id of calendar
     * @param  date $timestamp  lower limit with upper contrains after 7 days
     * @return resource
     */
    function getPeriodForTimestampQuery($calendarID, $timestamp) {

        $result = resourceForQuery(
        // echo (
            "SELECT
                `shiftMember`.`id`,
                COUNT(`shiftMember`.`dateBegin`) AS `entries`,
                UNIX_TIMESTAMP(`shiftMember`.`dateBegin`) AS `dateBegin`,
                UNIX_TIMESTAMP(`shiftMember`.`dateEnd`) AS `dateEnd`
            FROM
                `shiftMember`
            WHERE 1
                AND `shiftMember`.`calendarID` = $calendarID
                AND `shiftMember`.`dateBegin` >= FROM_UNIXTIME($timestamp)
                AND `shiftMember`.`dateEnd` <= DATE_ADD(FROM_UNIXTIME($timestamp), INTERVAL '7' DAY)
            GROUP BY
                `shiftMember`.`dateBegin` ASC,
                `shiftMember`.`dateEnd` ASC
            ORDER BY
                `shiftMember`.`dateBegin` ASC,
                `shiftMember`.`dateEnd` ASC
        ");

        return $result;
    }

    /**
     * Remove all entries inside a given period of time
     * @param  int  $calendarID id of calendar
     * @param  date $timestamp  lower limit with upper contrains after 7 days
     * @return resource
     */
    function removePeriodForTimestampQuery($calendarID, $timestamp) {

        $result = resourceForQuery(
        // echo (
            "DELETE FROM
                `shiftMember`
            WHERE 1
                AND `shiftMember`.`calendarID` = $calendarID
                AND `shiftMember`.`dateBegin` >= FROM_UNIXTIME($timestamp)
                AND `shiftMember`.`dateEnd` <= DATE_ADD(FROM_UNIXTIME($timestamp), INTERVAL '7' DAY)
        ");

        return $result;
    }

    function getCalendarsQuery($memberID) {

        $result = resourceForQuery(
        // echo (
            "SELECT
                `shiftCalendar`.`id`,
                `shiftCalendar`.`name`,
                COUNT(`shiftCalendar`.`id`) AS `entries`,
                `member`.`calendarID`
            FROM
                `shiftMember`
            INNER JOIN
                `shiftCalendar` ON `shiftCalendar`.`id` = `shiftMember`.`calendarID`
            LEFT JOIN
                `member` ON `shiftMember`.`calendarID` = `member`.`calendarID`
            WHERE 0
                OR `shiftMember`.`memberID` = $memberID
                OR `shiftCalendar`.`id` = (
                    SELECT
                        `member`.`calendarID`
                    FROM
                        `member`
                    WHERE
                        `member`.`id` = $memberID
                )
            GROUP BY
                `shiftMember`.`calendarID`
        ");

        return $result;
    }

    function getPresenceQuery($companyID, $presenceID) {
        $result = resourceForQuery(
            "SELECT
                `shiftMember`.`memberID`,
                `shiftMember`.`dateBegin`,
                `shiftMember`.`dateEnd`
            FROM
                `shiftMember`
            INNER JOIN
                `shiftCalendar` ON `shiftCalendar`.`id` = `shiftMember`.`calendarID`
            WHERE 1
                AND `shiftMember`.`id` = $presenceID
                AND `shiftCalendar`.`companyID` = $companyID
        ");

        return $result;
    }

    function getNumberOfMembersQuery($companyID, $dateBegin, $dateEnd) {
        $result = resourceForQuery(
        // echo (
            "SELECT
                `shiftMember`.`id`
            FROM
                `shiftMember`
            INNER JOIN
                `shiftCalendar` ON `shiftCalendar`.`id` = `shiftMember`.`calendarID`
            WHERE 1
                AND `shiftCalendar`.`companyID` = $companyID
                AND `shiftMember`.`dateBegin` = '$dateBegin'
                AND `shiftMember`.`dateEnd` = '$dateEnd'
        ");

        return mysql_num_rows($result);
    }
?>