<?php  

    function printBadge($result, $infoContainer = true) {
        
        for ($i = 0; $i < mysql_num_rows($result); $i++) {
        
            $id = mysql_result($result, $i, "id");
            $name = mysql_result($result, $i, "name");
            $position = mysql_result($result, $i, "position");
            $photo = mysql_result($result, $i, "photo");

            printSingleBadge($id, $name, $position, $photo, "", $infoContainer);
        }

        // One element for the form
        // printSingleBadge(0, "Nome", "Cargo", "images/128-man.png", "newBadge defaultInfoContainer", true);
    }
        
    function printSingleBadge($id, $name, $position, $photo, $className, $infoContainer) {

        $core = Core::singleton();

        ?>
        
        <li class="badge <?php if ($infoContainer) { ?> infoContainer <?php } ?><?php echo $className ?>">
            <form method="post" action="#">
                <input type="hidden" id="memberID" value="<?php echo $id ?>" />
                <div class="badgeHolder"></div>
                <div class="badgeTurner">
                    <img <?php if (($core->groupID == 3 /* RH */ || $core->permission >= 10 || $core->memberID == $id ) && $infoContainer == true) { ?>class="editButton" style="opacity: 1;" <?php } ?>src="images/64-Pencil.png" alt="Turn the badge around" />
                </div>
                <div class="badgeImage <?php if ($infoContainer) { ?> infoContainerImage <?php } ?>">
                    <div id="file-uploader">
                        <noscript>
                            <p>Please enable JavaScript to use file uploader.</p>
                            <!-- or put a simple form for upload here -->
                        </noscript>
                    </div>
                    <img src="<?php echo $photo ?>" alt="Imagem do membro" id="imagePhoto" />
                </div>
                <div class="badgeName">
                    <p class="<?php if ($infoContainer) { ?> infoContainerInputContent <?php } else { ?> infoContainerTextContent <?php } ?>" data-placeholder="Nome" title="name"><?php echo truncateName($name, 17) ?></p>
                </div>
                <div class="badgePosition">
                    <p class="<?php if ($infoContainer) { ?> infoContainerInputContent <?php } else { ?> infoContainerTextContent <?php } ?>" data-placeholder="Posição" title="position"><?php echo truncateName($position, 15) ?></p>
                </div>
                <div class="badgeExtra <?php if ($infoContainer) { ?> infoContainerExtra <?php } ?>"></div>
            </form>
        </li>

        <?php
    }

    function printNewBadge() {
        ?>
        
        <li class="badge newBadge badgeCentralized infoContainer defaultInfoContainer">
            <form method="post" action="#">
                <input type="hidden" id="memberID" value="0" />
                <div class="badgeHolder"></div>
                <div class="badgeTurner">
                    <img class="editButton" src="images/48-redo.png" alt="Turn the badge around" />
                </div>
                <div class="badgeImage infoContainerImage">
                    <div id="file-uploader"></div>
                    <img src="images/128-man.png" alt="Imagem do membro" id="imagePhoto" />
                </div>
                <div class="badgeName">
                    <input class="infoContainerInputContent" data-placeholder="Nome" type="text" title="name" id="name" />
                </div>
                <div class="badgePassword">
                    <input class="infoContainerInputContent" data-placeholder="Senha" type="password" title="password" id="password" />
                </div>
                <div class="badgePosition">
                    <input class="infoContainerInputContent" data-placeholder="Cargo" type="text" title="position" id="position" />
                </div>
                <div class="badgeExtra infoContainerExtra">
                    <p class="general">
                        <span class="bold">Aniversário:</span>
                        <input class="infoContainerInputContent" data-placeholder="Aniversário" type="text" title="birthday" id="birthday" />
                    </p>
                    <p class="general">
                        <span class="bold">Telefone:</span>
                        <input class="infoContainerInputContent" data-placeholder="Telefone" type="text" title="telephone" id="telephone" />
                    </p>
                    <p class="general">
                        <span class="bold">Email:</span>
                        <input class="infoContainerInputContent" data-placeholder="Email" type="text" title="email" id="email" />
                    </p>
                    
                    <div class="infoContainerSave badgeSave saveButton">Salvar!</div>
                    <div class="saveButtonError"></div>
                </div>
            </form>
        </li>
        
        <?php
    }

    function printBadgeExtraForID($id, $table) {


    }

?>