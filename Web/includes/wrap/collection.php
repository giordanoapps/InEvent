<?php

function printCollectionForSearch($eventID, $searchText, $searchType) {
    $result = resourceForQuery(
        "SELECT
            `$searchType`.`id`,
            `$searchType`.`name`
        FROM
            `$searchType`
        WHERE 1
            AND `$searchType`.`id` = $eventID
            AND `$searchType`.`name` LIKE '%$searchText%'
    ");
        
    if (mysqli_num_rows($result) > 0) {
        for ($i = 0; $i < mysqli_num_rows($result); $i++) {
            ?>
            <li value="<?php echo $position = mysqli_result($result, $i, "id") ?>">
                <?php echo $position = mysqli_result($result, $i, "name") ?>
            </li>
            <?php
        }
    } else {
        ?><li value="0">0 resultados</li><?php
    }
}

?>