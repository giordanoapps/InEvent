<?php

function printCollectionForSearch($companyID, $searchText, $searchType) {
    $result = resourceForQuery(
        "SELECT
            `$searchType`.`id`,
            `$searchType`.`name`
        FROM
            `$searchType`
        WHERE 1
            AND `$searchType`.`companyID` = $companyID
            AND MATCH(`$searchType`.`name`) AGAINST ('$searchText' IN NATURAL LANGUAGE MODE)
    ");
        
    if (mysql_num_rows($result) > 0) {
        for ($i = 0; $i < mysql_num_rows($result); $i++) {
            ?>
            <li value="<?php echo $position = mysql_result($result, $i, "id") ?>"><?php echo $position = mysql_result($result, $i, "name") ?></li>
            <?php
        }
    } else {
        ?><li value="0">0 resultados</li><?php
    }
}

?>