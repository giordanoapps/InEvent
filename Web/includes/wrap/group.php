<?php

function printGroups() {
    $result = $this->resourceForQuery("SELECT * FROM $this->tableGroup WHERE `enterpriseID`=$this->enterpriseID ORDER BY id, name");
    
    echo "<ul>";
    
    $this->printPost($result);
    
    echo "</ul>";
}

function printGroupAsSelect() {
    ?><div class="selectBox">
        <div class="selectSelected">
            <ul>
                <li value="0">Qual?</li>
            </ul>
        </div>
        <div class="selectOptions">
            <ul>
            <?php
                $result = $this->resourceForQuery("SELECT * FROM $this->tableGroup WHERE `enterpriseID`=$this->enterpriseID");
                
                for ($i = 0; $i < mysql_num_rows($result); $i++) {
                    $id = mysql_result($result, $i, "id");
                    $name = mysql_result($result, $i, "name");
            ?>
                <li value="<?php echo $id ?>"><?php echo $name ?></li>
            <?php
                }
            ?>
            </ul>
        </div>
    </div>
    <?php
}

function printGroupForSearch($searchText) {

    $result = $this->resourceForQuery("SELECT * FROM $this->tableGroup WHERE `enterpriseID`=$this->enterpriseID AND MATCH(acronym, name) AGAINST ('$searchText' IN NATURAL LANGUAGE MODE)");

    if (mysql_num_rows($result) > 0) {
        $this->printPost($result);
    } else {
        ?><p class="searchEmptyResult">0 resultados</p><?php
    }
}

?>