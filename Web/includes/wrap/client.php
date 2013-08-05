<?php

function printClients() {
    $result = $this->resourceForQuery("SELECT * FROM $this->tableClient WHERE `enterpriseID`=$this->enterpriseID AND `user`!='-' ORDER BY user");
    
    echo "<ul>";
    
    $this->printCard($result);
    
    echo "</ul>";
}

function printClientForSearch($searchText) {

    $result = $this->resourceForQuery("SELECT * FROM $this->tableClient WHERE `enterpriseID`=$this->enterpriseID AND MATCH(user, position, email, telephone) AGAINST ('$searchText' IN NATURAL LANGUAGE MODE)");

    if (mysql_num_rows($result) > 0) {
        $this->printCard($result);
    } else {
        ?><p class="searchEmptyResult">0 resultados</p><?php
    }
}

?>