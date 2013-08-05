<?php

    function printProjectCell($result) {
        
        for ($i = 0; $i < mysql_num_rows($result); $i++) {
            $id = mysql_result($result, $i, "id");
            $name = mysql_result($result, $i, "name");
            $headline = mysql_result($result, $i, "headline");
            $statusID = mysql_result($result, $i, "statusID");
            
            $resultStatus = $this->resourceForQuery("SELECT * FROM $this->tableProjectStatus WHERE `id`='$statusID'");
            $statusName = mysql_result($resultStatus, 0, "name");
            $statusColor = mysql_result($resultStatus, 0, "color");

        ?>
        <div class="projectBox">
            <input type="hidden" name="projectID" id="projectID" value="<?php echo $id ?>" />
            <div onclick="" class="projectCell reducedInfo" style="background-color: <?php echo $statusColor ?>">
                <div class="projectInfo">
                    <p class="projectName"><?php echo $name ?></p>
                    <p class="projectHeadline"><?php echo $headline ?></p>
                </div>
                <div class="projectStatus">
                    <p><?php echo $statusName ?></p>
                </div>
            </div>
            <div onclick="" class="projectCell completeInfo none"></div>
        </div>
        <?php
        }
    }

?>