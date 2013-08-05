<?php

function printConsultants() {
    $result = $this->resourceForQuery("SELECT * FROM $this->tableConsultant WHERE `enterpriseID`=$this->enterpriseID AND `user`!='-' ORDER BY user");
    
    echo "<ul>";
    
     $this->printCard($result, true);
    
    echo "</ul>";

    $result = resourceForQuery(
        "SELECT
            `consultant`.`id`,
            `consultant`.`name`,
            `consultant`.`position`,
            `consultant`.`email`,
            `consultant`.`telephone`
        FROM
            `consultant`
        WHERE 1
            AND `consultant`.`name` != '-'
            AND `consultant`.`companyID` = $companyID
        ORDER BY
            `name`
    ");
        
        ?><ul><?php printCard($result); ?></ul><?php
}

function printConsultantForSearch($searchText) {

    $result = resourceForQuery(
        "SELECT
            `consultant`.`id`,
            `consultant`.`name`,
            `consultant`.`position`,
            `consultant`.`email`,
            `consultant`.`telephone`
        FROM
            `consultant`
        WHERE 1
            AND `companyID` = $core->companyID
            AND MATCH(`name`, `position`, `course`, `email`, `telephone`) AGAINST ('$searchText' IN NATURAL LANGUAGE MODE)
    ");
    
    if (mysql_num_rows($result) > 0) {
        $this->printCard($result, true);
    } else {
        ?><p class="searchEmptyResult">0 resultados</p><?php
    }
}

?>