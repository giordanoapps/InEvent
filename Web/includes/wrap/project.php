<?php

function printGroupMembersForID($id) {
    $result = $this->resourceForQuery("SELECT * FROM $this->tableUser WHERE `enterpriseID`=$this->enterpriseID AND `groupID` = $id");
    
    for ($i = 0; $i < mysql_num_rows($result); $i++) {
        $id = mysql_result($result, $i, "id");
        $user = mysql_result($result, $i, "user");
        echo "<li value='$id'>$user</li>";  
    }
}

function printAllProjects() {
    $result = $this->resourceForQuery("SELECT * FROM $this->tableProject WHERE `enterpriseID`=$this->enterpriseID");

    $this->printProjectCell($result);
}

function printProjectForSearch($searchText) {

    $result = $this->resourceForQuery("SELECT * FROM $this->tableProject WHERE `enterpriseID`=$this->enterpriseID AND MATCH(name, headline, description) AGAINST ('$searchText' IN NATURAL LANGUAGE MODE)");
    
    if (mysql_num_rows($result) > 0) {
        $this->printProjectCell($result);
    } else {
        ?><p class="searchEmptyResult">0 resultados</p><?php
    }
}

?>