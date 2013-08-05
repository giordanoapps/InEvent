<?php

    function printCard($result, $course = null) {
        
        for ($i = 0; $i < mysql_num_rows($result); $i++) {
        
            $id = mysql_result($result, $i, "id");
            $name = mysql_result($result, $i, "name");
            $position = mysql_result($result, $i, "position");
            $email = mysql_result($result, $i, "email");
            $telephone = mysql_result($result, $i, "telephone");
        
            if ($course != null) {
                $course = mysql_result($result, $i, "course");
            }

            printSingleCard($id, $name, $position, $email, $telephone);
        }
    }
    
    function printSingleCard($id, $name, $position, $email, $telephone) {
        
        $core = Core::singleton();
        
        ?>
        
        <li class="card infoContainer">
            <form method="post" action="#">
                <input type="hidden" id="memberID" value="<?php echo $id ?>" />
                <?php if ($this->groupID == 3 /* RH */ || $this->permission >= 10) { ?>
                <div class="cardTurner">
                    <img class="editButton" src="images/64-Pencil.png" alt="Turn the card around" />
                </div>
                <?php } ?>
                <div class="cardName"><p class="infoContainerInputContent" title="user"><?php echo $this->truncateName($user, 21) ?></p></div>
                <div class="cardPosition"><p class="infoContainerInputContent" title="position"><?php echo $this->truncateName($position, 15) ?></p></div>
                
                <div class="cardBottom">
                    <div class="cardEmail">
                        <p class="general"><span class="bold">Email:</span> <span class="infoContainerInputContent" title="email"><?php echo $email ?></span></p>
                    </div>
                    <div class="cardTelephone">
                        <p class="general"><span class="bold">Telefone:</span> <span class="infoContainerInputContent" title="telephone"><?php echo $telephone ?></span></p>
                    </div>
                    
                    <?php if ($course != null) { ?>
                    <div class="cardCourse">
                        <p class="general"><span class="bold">Curso: </span> <span class="infoContainerInputContent" title="course"><?php echo $this->truncateName($user, 22) ?></span></p>
                    </div>
                    <?php } ?>
                    
                    <div class="infoContainerSave saveButton">Salvar!</div>
                    <div class="saveButtonError"></div>
                </div>
                
                <div class="cardExtra infoContainerExtra"></div>
            </form>
        </li>

        <?php
    }

    function printCardExtraForID($id, $table) {
        
        $result = $this->resourceForQuery("SELECT * FROM $table WHERE personID='$id'");

        for ($i = 0; $i < mysql_num_rows($result); $i++) {
            
            $projectID = mysql_result($result, $i, "projectID");
            $resultProject = $this->resourceForQuery("SELECT * FROM $this->tableProject WHERE id='$projectID'");
            
            $name = mysql_result($resultProject, 0, "name");
            $headline = mysql_result($resultProject, 0, "headline");
            $statusID = mysql_result($resultProject, 0, "statusID");
            
            $resultStatus = $this->resourceForQuery("SELECT * FROM $this->tableProjectStatus WHERE id='$statusID'");
            $statusName = mysql_result($resultStatus, 0, "name");
            $statusColor = mysql_result($resultStatus, 0, "color");
        ?> 
        
        <a href="projects.php">
            <div class="projectBox">
                <div onclick="" class="projectCell reducedInfo" style="background-color: <?php echo $statusColor ?>">
                    <div class="projectInfo">
                        <p class="projectName"><?php echo $name ?></p>
                        <p class="projectHeadline"><?php echo $headline ?></p>
                    </div>
                    <div class="projectStatus">
                        <p><?php echo $statusName ?></p>
                    </div>
                    <input type='hidden' id='id' value='<?php echo $projectID ?>' />
                </div>
                <div onclick="" class="projectCell completeInfo none"></div>
            </div>
        </a>

    <?php }
    }

?>