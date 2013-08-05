<?php

    function printPost($result) {
        for ($i = 0; $i < mysql_num_rows($result); $i++) {
        
            $id = mysql_result($result, $i, "id");
            $acronym = mysql_result($result, $i, "acronym");
            $name = mysql_result($result, $i, "name");
            $color = mysql_result($result, $i, "color");
            $photo = mysql_result($result, $i, "photo");
        
        ?>
        
        <li value="<?php echo $id ?>" class="post infoContainer" style="background-color: <?php echo $color ?>;">
            <form method="post" action="#">
                <input type="hidden" id="memberID" value="<?php echo $id ?>" />
                <div class="postHolder"></div>
                <?php if ($this->group == 3 /* RH */ || $this->level >= 10) { ?>
                <div class="postTurner">
                    <img class="editButton" src="images/64-Pencil.png" alt="Turn the card around" />
                </div>
                <?php } ?>
                <div class="postPin">
                    <img src="images/128-pushpin.png" alt="Group Logo" />
                </div>
                <div class="postInformationWrapper">
                
                    <div class="postLogo infoContainerImage">
                        <div id="file-uploader">
                            <noscript>
                                <p>Please enable JavaScript to use file uploader.</p>
                                <!-- or put a simple form for upload here -->
                            </noscript>
                        </div>
                        <img src="<?php echo $photo ?>" alt="Group logo" />
                    </div>  
                
                    <div class="postInformation">
                        <span title="name" class="postName infoContainerInputContent"><?php echo $this->truncateName(ucwords(strtolower($name)), 24) ?></span> 
                        <span class="postParenthesisLeft">(</span><span title="acronym" class="postAcronym infoContainerInputContent"><?php echo strtoupper($acronym) ?></span><span class="postParenthesisRight">)</span>
                    </div>
                    <div class="infoContainerSave saveButton">Salvar!</div>
                    <div class="saveButtonError"></div>
                </div>
                
                <div class="postExtra infoContainerExtra"></div>
                
                <div class="postBadges">
                    <ul class="badgeListSortable">
                        <?php $this->printUsersForGroupID($id, false) ?>
                    </ul>
                </div>
            </form>
        </li>

        <?php
        }
    }

?>