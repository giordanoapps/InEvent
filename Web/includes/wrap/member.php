<?php  

    function printAllMembers($companyID) {
        // '-' is the special user for the Presenca tool
        $result = resourceForQuery(
            "SELECT
                `member`.`id`,
                `member`.`name`,
                `member`.`position`,
                `member`.`photo`
            FROM
                `member`
            WHERE 1
                AND `member`.`name` != '-'
                AND `member`.`companyID` = $companyID
            ORDER BY
                `name`
        ");
        
        ?><ul class='badgeListSortable'><?php printBadge($result); ?></ul><?php
    }

    function printMembersForGroupID($companyID, $groupID, $infoContainer = true) {
        $result = resourceForQuery(
            "SELECT
                `member`.`id`,
                `member`.`name`,
                `member`.`position`,
                `member`.`photo`
            FROM
                `member`
            WHERE 1
                AND `member`.`name` != '-'
                AND `member`.`companyID` = $companyID
                AND `member`.`groupID` = $groupID
            ORDER BY
                `name`
        ");
        
        printBadge($result, $infoContainer);
    }

    function printMemberSettingsForMemberID($companyID, $memberID) {
        $result = resourceForQuery(
            "SELECT
                `member`.`id`,
                `member`.`name`,
                `member`.`position`,
                `member`.`photo`
            FROM
                `member`
            WHERE 1
                AND `member`.`id` = $memberID
                AND `member`.`companyID` = $companyID
            ORDER BY
                `name`
        ");
        
        if (mysql_num_rows($result) == 1) printBadge($result);
    }

    function printPowerMembers($companyID) {

        $result = resourceForQuery(
            "SELECT
                `member`.`id`,
                `member`.`name`
            FROM
                `member`
            WHERE 1
                AND `member`.`companyID` = $companyID
                AND `member`.`permission` >= 10
                AND `member`.`name` != '-'
            ORDER BY
                `member`.`name`
        ");
            
        if (mysql_num_rows($result) > 0) {
            for ($i = 0; $i < mysql_num_rows($result); $i++) {
                ?>
                <li value="<?php echo mysql_result($result, $i, "id") ?>"><?php echo mysql_result($result, $i, "name") ?></li>
                <?php
            }
        } else {
            ?><li>0 membros</li><?php
        }
    }

    function printMemberForSearch($companyID, $searchText) {

        $result = resourceForQuery(
            "SELECT
                `member`.`id`,
                `member`.`name`,
                `member`.`position`,
                `member`.`photo`
            FROM
                `member`
            WHERE 1
                AND `companyID` = $companyID
                AND MATCH(`name`, `position`, `email`, `telephone`) AGAINST ('$searchText' IN NATURAL LANGUAGE MODE)
        ");
        
        if (mysql_num_rows($result) > 0) {
            printBadge($result);
        } else {
            ?><p class="searchEmptyResult">0 resultados</p><?php
        }  
    }

?>