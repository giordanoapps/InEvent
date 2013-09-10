<?php

    function printScheduleForMember($eventID, $memberID) {
        printSchedule(getActivitiesForMemberAtEventQuery($eventID, $memberID), "member");
    }

    function printScheduleForEvent($eventID) {
        printSchedule(getActivitiesForEventQuery($eventID), "event");
    }

    function printSchedule($result, $target) {

        // Get the singleton
        $core = Core::singleton();

        ?><ul><?php

        $rows = mysql_num_rows($result);

        if ($rows > 0) {

            // Display a row exclusive to all participants
            if ($target == "event") {

                // Get informations specific for this event
                $resultEvent = getEventForEventQuery($core->eventID);

                // Element to grab all people
                printScheduleItem(
                    array(
                        "id" => 1,
                        "type" => "event",
                        "dateBegin" => mysql_result($resultEvent, 0, "dateBegin"),
                        "dateEnd" => mysql_result($resultEvent, 0, "dateEnd"),
                        "name" => "Todas as pessoas",
                        "description" => "",
                        "capacity" => "0",
                        "entries" => mysql_result($resultEvent, 0, "entries")
                    ),
                    "event"
                );
            }

            $day = 0;

            while ($data = mysql_fetch_assoc($result)) {

                if ($day != date("z", $data['dateBegin'])) {
                    $day = date("z", $data['dateBegin']);

                    ?>
                        <li value="" class="scheduleDay">
                            <span><?php echo date("j/m", $data['dateBegin']) ?></span>
                            <span><?php echo getDayNameForDate($data['dateBegin']) ?></span>
                        </li>
                    <?php
                }

                printScheduleItem($data, $target);
            }

        } else {
            ?>
            <li>
                <p class="emptyCapital">Nenhuma atividade :(</p>
            </li>
            <?php
        }

        ?></ul><?php
    }

    function printScheduleItem($data, $target) {
        ?>
        <li
            value="<?php echo $data['id'] ?>"
            class="scheduleItem <?php if ($target == "event") { ?>scheduleItemSelectable<?php } elseif($data['memberID'] == 0) { ?>scheduleItemInvisible<?php } ?>"
            data-type="<?php if (isset($data["type"])) { echo $data["type"]; } else { ?>activity<?php } ?>">
            <div class="left">
                <div class="upper">
                    <p class="dateBegin"><?php if (isset($data["type"])) { echo date("j/m", $data['dateBegin']); } else { echo date("G:i", $data['dateBegin']); } ?></p>
                </div>
                <div class="bottom">
                    <p class="dateEnd"><?php if (isset($data["type"])) { echo date("j/m", $data['dateEnd']); } else { echo date("G:i", $data['dateEnd']); } ?></p>
                </div>
            </div>
            <div class="right">
                <?php if ($target == "event") { ?>
                <div class="upper">
                    <p class="name"><?php echo $data['name'] ?></p>
                </div>
                <?php } else { ?>
                <div class="upper" title="<?php if ($data['approved'] == 1) { ?>Aprovado<?php } else { ?>Lista de espera<?php } ?>">
                    <p class="name"><?php echo $data['name'] ?></p>
                    <p class="hint <?php if ($data['approved'] == 1) { ?>hintApproved<?php } else { ?>hintDenied<?php } ?>"></p>
                </div>
                <?php } ?>
                <div class="bottom">
                    <p class="description"><?php echo $data['description'] ?></p>
                    <?php if ($target == "event") { ?>
                        <div class="dock">
                            <ul>
                                <li class="">
                                    <img src="images/32-Users.png" alt="Pessoas" title="Número de pessoas inscritas na atividade">
                                    <span>
                                        <b><?php echo $data['entries'] ?></b> /
                                        <?php if ($data['capacity'] != 0) { echo $data['capacity']; } else { ?>&infin;<?php } ?></span>
                                </li>
                            </ul>
                        </div>
                    <?php } else { ?>
                        <div class="dock">
                            <ul>
                                <?php if ($data['approved'] == 0) { ?>
                                <li class="tool toolPriority <?php if ($data['priori'] == 1) { ?>toolSelected<?php } ?>">
                                    <img src="images/32-Vault.png" alt="Aumentar a prioridade" title="Marque essa opção caso queira que esta atividade seja selecionada quando surgirem vagas, mesmo que isto implique na remoção de outras atividades do grupo.">
                                </li>
                                <?php } ?>
                                <?php if ($data['capacity'] == 0) { ?>
                                <li class="tool toolExpel">
                                    <img src="images/32-Cross.png" alt="Remover" title="Remover da lista, o que implicará em ir para a lista de espera caso decida voltar e não existam mais vagas.">
                                </li>
                                <?php } ?>
                            </ul>
                        </div>
                    <?php } ?>
                </div>
            </div>
        </li>
        <?php
    }

    function printAgenda($eventID, $memberID) {

        // See if the person is enrolled on the current event
        $result = resourceForQuery(
            "SELECT
                `eventMember`.`id`
            FROM
                `eventMember`
            WHERE 1
                AND `eventMember`.`eventID` = $eventID
                AND `eventMember`.`memberID` = $memberID
        ");

        $enrolled = (mysql_num_rows($result) > 0) ? true : false;

        $result = getActivitiesForMemberAtEventQuery($eventID, $memberID);

        ?><ul><?php

        if (mysql_num_rows($result) > 0) {

            // If the member is not enrolled, we show a option enabling him to do so
            if (!$enrolled) {
                ?>
                    <li>
                        <p class="message">Ainda não está registrado nesse evento! Clique no botão caso queira se inscrever.</p>
                         <input type="button" value="Inscrever" title="Se inscreva para escolher as atividades dentro do evento" class="singleButton toolEnroll">
                    </li>
                <?php
            }

            $day = 0;

            while ($data = mysql_fetch_assoc($result)) {

                if ($day != date("z", $data['dateBegin'])) {
                    $day = date("z", $data['dateBegin']);

                    ?>
                        <li value="" class="agendaDay">
                            <span><?php echo date("j/m", $data['dateBegin']) ?></span>
                            <span><?php echo getDayNameForDate($data['dateBegin']) ?></span>
                        </li>
                    <?php
                }

                ?>
                <li
                    value="<?php echo $data['id'] ?>"
                    class="agendaItem <?php if ($data['highlight'] == 1) { ?>agendaItemHighlight<?php } ?>"
                    data-group="<?php echo $data['groupID'] ?>">
                    <div class="left">
                        <div class="upper">
                            <p class="dateBegin"><?php echo date("G:i", $data['dateBegin']) ?></p>
                        </div>
                        <div class="bottom">
                            <p class="dateEnd"><?php echo date("G:i", $data['dateEnd']) ?></p>
                        </div>
                    </div>
                    <div class="right">
                        <div class="upper">
                            <p class="name"><?php echo $data['name'] ?></p>
                        </div>
                        <div class="middle">
                            <p class="description"><?php echo $data['description'] ?></p>
                        </div>
                        <div class="bottom">
                            <a target="_blank" href="https://www.google.com/maps/preview#!q=<?php echo urlencode(html_entity_decode($data['location'], ENT_COMPAT, "UTF-8")) ?>">
                                <img src="images/32-Google-Maps.png" alt="Local" title="Local de realização da atividade. Para acompanhar no Google Maps, é necessário ter a versão mais nova do produto.">
                            </a>
                            <span>
                                <img src="images/32-Users.png" alt="Local" title="Número de vagas na atividade">
                                <span class="smallPadding"><?php if ($data['capacity'] != 0) { echo $data['capacity']; } else { ?>&infin;<?php } ?></span>
                            </span>
                            <span class="suckyVerticalAlign"></span>
                            <input
                                type="button"
                                value="Inscrever!"
                                title="Ao entrar nessa atividade, saberá imediatamente se foi aprovado ou está na lista de espera"
                                class="singleButton toolEnroll <?php if (!$enrolled || $data['memberID'] != 0) { ?>singleButtonInvisible<?php } ?>">
                        </div>
                    </div>
                </li>
                <?php
            }

        } else {
            ?>
            <li>
                <p class="emptyCapital">Nenhuma atividade :(</p>
            </li>
            <?php
        }

        ?></ul><?php
    }

?>