<?php

    function printTimeline($eventID, $memberID) {

        $result = getActivitiesForMemberQuery($eventID, $memberID);

        ?><ul><?php

        if (mysql_num_rows($result) > 0) {

            while ($data = mysql_fetch_assoc($result)) {
                ?>
                <li value="<?php echo $data['id'] ?>" class="scheduleItem <?php if ($invisible) { ?>scheduleItemInvisible<?php } ?>">
                    <div class="left">
                        <p class="dateBegin"><span><?php echo date("j/m G:i", $data['dateBegin']) ?></span></p>
                        <p class="dateEnd"><span><?php echo date("j/m G:i", $data['dateEnd']) ?></span></p>
                    </div>
                    <div class="right">
                        <div class="upper">
                            <p class="name"><?php echo $data['name'] ?></p>
                        </div>
                        <div class="bottom">
                            <p class="description"><?php echo $data['description'] ?></p>
                        </div>
                    </div>
                </li>
                <?php
            }

        } else {
            ?>
            <li>
                <p class="emptyCapital">Nenhum calendário :(</p>
            </li>
            <?php
        }

        ?></ul><?php
    }

   function printActivities($eventID) {

        $result = getActivitiesForEventQuery($eventID);

        ?><ul><?php

        if (mysql_num_rows($result) > 0) {

            while ($data = mysql_fetch_assoc($result)) {
                ?>
                <li value="<?php echo $data['id'] ?>" class="scheduleItem <?php if ($invisible) { ?>scheduleItemInvisible<?php } ?>">
                    <div class="left">
                        <p class="dateBegin"><span><?php echo date("j/m G:i", $data['dateBegin']) ?></span></p>
                        <p class="dateEnd"><span><?php echo date("j/m G:i", $data['dateEnd']) ?></span></p>
                    </div>
                    <div class="right">
                        <div class="upper">
                            <p class="name"><?php echo $data['name'] ?></p>
                        </div>
                        <div class="bottom">
                            <p class="description"><?php echo $data['description'] ?></p>
                        </div>
                    </div>
                </li>
                <?php
            }

        } else {
            ?>
            <li>
                <p class="emptyCapital">Nenhum calendário :(</p>
            </li>
            <?php
        }

        ?></ul><?php
    }

    function printCalendarHelp(){
        ?>
        
        <div class="helpMenu">
            <div class="goBy">
                <p><b>1.</b> Crie um calendário clicando no ícone.</p>
                <img src="images/64-Day-Calendar.png" class="" alt="Calendar" id="calendarTool"/>
            </div>
            <div class="goBy">
                <p><b>2.</b> Escolha um nome adequado para o mesmo.</p>
            </div>
            <div class="goBy">
                <p><b>3.</b> Depois, já pode criar períodos dentro do novo calendário!</p>
            </div>
        </div>
        
        <?php
    }

    function printStartMenu($timestamp, $warning = false) {
        ?>

        <div class="startMenu" data-timestamp="<?php echo $timestamp ?>">
            <?php if ($warning) { ?>
            <div class="warning">
                <span>Atenção: Os dados desta semana serão reescritos!</span>
            </div>
            <?php } ?>
            <div class="primary">
                <div class="create">
                    <img src="images/64-Create-_-Write.png" class="" alt="Create" id="createButton"/>
                    <span>Criar</span>
                </div>
                
                <div class="middleLine">OU</div>
                
                <div class="copy">
                    <img src="images/64-Text-Documents.png" class="" alt="Copy" id="copyButton"/>
                    <span>Copiar</span>
                </div>
            </div>
            
            <div class="secondary">
                <div class="create">
                    <form action="">
                        <input type="hidden" name="timestamp" value="<?php echo $timestamp ?>">
                        <div class="step">
                            <p>Hora de personalizar o controle de presença!</p>
                        </div>
                        <div class="step">
                            <span>Dias</span>
                            <select name="dayBegin" id="dayBegin">
                                <option value="0">Domingo</option>
                                <option value="1" selected>Segunda</option>
                                <option value="2">Terça</option>
                                <option value="3">Quarta</option>
                                <option value="4">Quinta</option>
                                <option value="5">Sexta</option>
                                <option value="6">Sábado</option>
                            </select>
                            até
                            <select name="dayEnd" id="dayEnd">
                                <option value="0">Domingo</option>
                                <option value="1">Segunda</option>
                                <option value="2">Terça</option>
                                <option value="3">Quarta</option>
                                <option value="4">Quinta</option>
                                <option value="5" selected>Sexta</option>
                                <option value="6">Sábado</option>
                            </select>
                        </div>
                        <div class="step">
                            <span>Horário</span>
                            <select name="hourBegin" id="hourBegin">
                                <option value="0">0:00</option>
                                <option value="1">1:00</option>
                                <option value="2">2:00</option>
                                <option value="3">3:00</option>
                                <option value="4">4:00</option>
                                <option value="5">5:00</option>
                                <option value="6">6:00</option>
                                <option value="7">7:00</option>
                                <option value="8" selected>8:00</option>
                                <option value="9">9:00</option>
                                <option value="10">10:00</option>
                                <option value="11">11:00</option>
                                <option value="12">12:00</option>
                                <option value="13">13:00</option>
                                <option value="14">14:00</option>
                                <option value="15">15:00</option>
                                <option value="16">16:00</option>
                                <option value="17">17:00</option>
                                <option value="18">18:00</option>
                                <option value="19">19:00</option>
                                <option value="20">20:00</option>
                                <option value="21">21:00</option>
                                <option value="22">22:00</option>
                                <option value="23">23:00</option>
                            </select>
                            até
                            <select name="hourEnd" id="hourEnd">
                                <option value="0">0:00</option>
                                <option value="1">1:00</option>
                                <option value="2">2:00</option>
                                <option value="3">3:00</option>
                                <option value="4">4:00</option>
                                <option value="5">5:00</option>
                                <option value="6">6:00</option>
                                <option value="7">7:00</option>
                                <option value="8">8:00</option>
                                <option value="9">9:00</option>
                                <option value="10">10:00</option>
                                <option value="11">11:00</option>
                                <option value="12">12:00</option>
                                <option value="13">13:00</option>
                                <option value="14">14:00</option>
                                <option value="15">15:00</option>
                                <option value="16">16:00</option>
                                <option value="17">17:00</option>
                                <option value="18" selected>18:00</option>
                                <option value="19">19:00</option>
                                <option value="20">20:00</option>
                                <option value="21">21:00</option>
                                <option value="22">22:00</option>
                                <option value="23">23:00</option>
                            </select>
                        </div>
                        <div class="step">
                            <span>Duração</span>
                            <select name="duration" id="duration">
                                <option value="0">0:00</option>
                                <option value="5">0:05</option>
                                <option value="10">0:10</option>
                                <option value="15">0:15</option>
                                <option value="20">0:20</option>
                                <option value="25">0:25</option>
                                <option value="30">0:30</option>
                                <option value="45">0:45</option>
                                <option value="60" selected>1:00</option>
                                <option value="75">1:15</option>
                                <option value="90">1:30</option>
                                <option value="120">2:00</option>
                                <option value="150">2:30</option>
                                <option value="180">3:00</option>
                                <option value="240">4:00</option>
                                <option value="300">5:00</option>
                                <option value="360">6:00</option>
                            </select>
                        </div>
                        <div class="step">
                            <span>Intervalo</span>
                            <select name="interval" id="interval">
                                <option value="0">0:00</option>
                                <option value="5">0:05</option>
                                <option value="10" selected>0:10</option>
                                <option value="15">0:15</option>
                                <option value="20">0:20</option>
                                <option value="25">0:25</option>
                                <option value="30">0:30</option>
                                <option value="45">0:45</option>
                                <option value="60">1:00</option>
                                <option value="75">1:15</option>
                                <option value="90">1:30</option>
                                <option value="120">2:00</option>
                                <option value="150">2:30</option>
                                <option value="180">3:00</option>
                                <option value="240">4:00</option>
                                <option value="300">5:00</option>
                                <option value="360">6:00</option>
                            </select>
                            <p>Pausa entre os turnos? Diga o tempo para descanso.</p>
                        </div>
                        <div class="step">
                            <span>Tolerância</span>
                            <select name="tolerance" id="tolerance">
                                <option value="0">0:00</option>
                                <option value="5">0:05</option>
                                <option value="10" selected>0:10</option>
                                <option value="15">0:15</option>
                                <option value="20">0:20</option>
                                <option value="25">0:25</option>
                                <option value="30">0:30</option>
                                <option value="45">0:45</option>
                                <option value="60">1:00</option>
                                <option value="75">1:15</option>
                                <option value="90">1:30</option>
                                <option value="120">2:00</option>
                                <option value="150">2:30</option>
                                <option value="180">3:00</option>
                                <option value="240">4:00</option>
                                <option value="300">5:00</option>
                                <option value="360">6:00</option>
                            </select>
                            <p>Número de minutos autorizado a chegar atrasado.</p>
                        </div>
                        
                        <div class="step">
                            <input type="button" id="createPeriod" class="singleButton" value="Criar!" />
                        </div>
                        
                    </form>
                </div>
                
                <div class="copy">
                    <div class="step">
                        Copiar tabela de<input type="text" id="numberWeeks" value="1" class="singleInput" />semana(s) atrás.
                        <input type="button" id="copyPeriod" class="singleButton" value="Copiar!" />
                    </div>
                </div>
            </div>
        </div>
        
        <?php
    }

    function printTable($timestamp, $calendarID, $result) {

        // We must assemble a pile of all the hours before printing the table
        
        $hours = array();

        for ($i = 0; $i < mysql_num_rows($result); $i++) {

            $secondBegin = mysql_result($result, $i, "dateBegin") % 86400;
            $secondEnd = mysql_result($result, $i, "dateEnd") % 86400;

            // Try to find the begin hour inside the stack
            if (array_search($secondBegin, $hours) === FALSE) {
                // If we don't find it, we create and add it
                $hours[$secondBegin] = array();
                $hours[$secondBegin][] = $secondEnd;
            } else {
                // If we find it, we must know if the end hour is there too
                if (array_search($secondEnd, $hours[$secondBegin]) === FALSE) {
                    // If it is not, we must add it
                    $j = 0;
                    while ($hours[$secondBegin][$j] < $secondEnd) $j++;
                    
                    array_splice($hours[$secondBegin], $j, 0, array("$secondEnd"));
                }
            }
        }

        // First and last entry
        $firstEntry = mysql_result($result, 0, "dateBegin");
        $lastEntry = mysql_result($result, mysql_num_rows($result) - 1, "dateBegin");

        ?>
        
        <table class="master" rules="groups" data-timestamp="<?php echo $timestamp ?>">
            <thead>
                <tr>
                    <th>
                        <?php echo date("j/n/y", $firstEntry) ?><br />
                        <?php echo date("j/n/y", $lastEntry) ?>
                    </th>
                    <?php
                        $hourKeys = array_keys($hours);
                        for ($i = 0; $i < count($hours); $i++) {
                            for ($j = 0; $j < count($hours[$hourKeys[$i]]); $j++) {
                                ?><th><?php echo date("g:i", $hourKeys[$i]) . " - " . date("g:i", $hours[$hourKeys[$i]][$j]) ?></th><?php
                            }
                        }
                    ?>
                </tr>
            </thead>
            
            
            <tbody>
                <?php
                    $daysOfWeek = array("Domingo", "Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado");
                    $rowCounter = 0;

                    for ($i = date("w", $firstEntry); $i <= date("w", $lastEntry); $i++) {

                        ?><tr><th><?php echo $daysOfWeek[$i] ?></th><?php

                        for ($j = 0; $j < count($hours); $j++) {

                            ?>
                            <td>
                                <div class="upperCell"><?php

                                    for ($k = 0; $k < count($hours[$hourKeys[$j]]); $k++) {
                                        // Select any of the id's on this date and call the print function
                                        printTextForDateInterval($calendarID, mysql_result($result, $rowCounter, "dateBegin"), mysql_result($result, $rowCounter, "dateEnd"));

                                        // Increment our counter
                                        $rowCounter++;
                                    }

                                    ?>
                                    
                                    <div class="dock">
                                        <ul>
                                            <li class="add tool"><img src="images/32-Plus.png" alt="Adicionar"></li>
                                            <!-- <li class="price"><img src="images/64-User.png" alt="Entradas"><span><?php echo mysql_result($result, $rowCounter, "entries") ?></span></li> -->
                                        </ul>
                                    </div>
                                
                                </div>
                                
                                <div class="lowerCell">
                            
                                    <div class="picker">
                                        
                                    </div>
                                </div>
                           </td>
                           <?php
                        }

                        ?></tr><?php
                    }
                ?>
            </tbody>
        </table>
        <?php
    }

    /**
     * Print text for a single shift slot, where multiple people can appear
     * @param  integer $dateBegin
     * @param  integer $dateEnd
     * @return
     */
    function printTextForDateInterval($calendarID, $dateBegin, $dateEnd) {

        $result = getPeriodForDateQuery($calendarID, $dateBegin, $dateEnd);
        
        // We need to know how many cells this table willl have
        $lines = mysql_num_rows($result);
        
        ?><ul class="membersOnShift"><?php
        
            for ($k = 0; $k < mysql_num_rows($result); $k++) {
                printTextForPresenceID(mysql_result($result, $k, "id"));
            }
        
        ?></ul><?php
    }

    /**
     * Print text for a single date id
     * @param  integer $presenceID
     * @return
     */
    function printTextForPresenceID($presenceID) {
        $result = resourceForQuery(
            "SELECT
                `shiftMember`.`id`,
                `member`.`name`,
                `shiftMember`.`memberID`,
                `member`.`photo`,
                UNIX_TIMESTAMP(`shiftMember`.`dateBegin`) AS `dateBegin`,
                UNIX_TIMESTAMP(`shiftMember`.`dateEnd`) AS `dateEnd`,
                `shiftMember`.`statusID`,
                `shiftMember`.`tolerance`
            FROM
                `shiftMember`
            INNER JOIN
                `member` ON `member`.`id` = `shiftMember`.`memberID`
            WHERE 1
                AND `shiftMember`.`id` = $presenceID
        ");

        if (mysql_num_rows($result) == 1) {
            // Capture data
            $data = mysql_fetch_assoc($result);
            
            // Print it
            printTextForCell($data["id"], $data["name"], $data["memberID"], $data["photo"], $data["dateBegin"], $data["dateEnd"], $data["statusID"], $data["tolerance"]);
        }
    }

    function printTextForCell($id, $name, $memberID, $photo, $dateBegin, $dateEnd, $statusID, $tolerance) {
        
        $core = Core::singleton();
        $now = time();
        
        ?>
        
        <li class="photoThumb <?php
    
        // Check for permissions
        if ($memberID == $core->memberID || $core->groupID == 3 /* RH */ || $core->permission >= 10) {
            // Member has not logged in yet
            if ($statusID == 0) {
                // Special Member "-" is always absent
                if ($dateBegin + $tolerance*60 < $now && $name == "-") {
                    echo "red";
                // Member is late
                } elseif ($dateBegin + $tolerance*60 < $now) {
                    echo "red";
                // Member is within the time boundaries
                } elseif ($dateBegin + $tolerance*60 >= $now && $dateBegin - $tolerance*60 <= $now) {
                    echo "silver";
                // Still to early
                } else {
                    echo "black";
                }
            // Member has logged in
            } elseif ($statusID == 1) {
                // Member was too late to log out
                if ($dateEnd + $tolerance*60 < $now) {
                    echo "red";
                // Member is within the time boundaries
                } elseif ($dateBegin <= $now && $dateEnd + $tolerance*60 >= $now) {
                    echo "yellow";
                // Still to early
                } else {
                    echo "black";
                }
            // Member has logged out
            } elseif ($statusID == 2) {
                // Validate his presence
                if ($dateEnd <= $now) {
                    echo "green";
                // Still to early
                } else {
                    echo "black";
                }
            }
        // Permision has been denied
        } else {
            echo "black";
        }

        // Make cell touchable
        if ($dateBegin - $tolerance*60 <= $now && $dateEnd + $tolerance*60 >= $now) {
            echo " star";
        }

        ?>" value="<?php echo $id ?>">

            <div class="shadow">
                <img src="<?php echo $photo ?>" alt="Foto do Membro">
            </div>
            
            <div class="dock">
                <ul>
                    <?php
                    // Only allows justification if the condition below is verified
                    if ($memberID == $core->memberID && $statusID == 0 && $dateBegin + $tolerance*60 < $now) {
                        $resultExplanation = resourceForQuery(
                            "SELECT
                                `explanationMembers`.`statusID`,
                                `explanationPenalty`.`value` AS `penaltyValue`
                            FROM
                                `explanationMembers`
                            INNER JOIN
                                `explanationPenalty` ON `explanationPenalty`.`id` = `explanationMembers`.`penaltyID`
                            WHERE
                                `explanationMembers`.`presenceID` = $id
                        ");
                        
                        if (mysql_num_rows($resultExplanation) == 1) {
                            if (mysql_result($resultExplanation, 0, "statusID") == 1) {
                                // We have an entry that has been evaluated
                                $penalty = mysql_result($resultExplanation, 0, "penaltyValue");
                                ?><li class="review"><?php echo $penalty ?></li><?php
                            } else {
                                ?><li class="review"><img src="images/48-sand.png" alt="Wait for evaluation"></li><?php
                            }
                        } else {
                            ?><li class="review tool"><img src="images/48-paper-airplane.png" id="paperAirplane" alt="Send Explanation"></li><?php
                        }
                    } else {
                    ?><li class="edit tool"><img src="images/64-Pencil.png" alt="Editar"></li><?php
                    } ?>
                    <li class="remove tool"><img src="images/32-Cross.png" alt="Remover"></li>
                </ul>
            </div>
        </li>
            
        <?php
        
        // $result = resourceForQuery("SELECT * FROM tableUser WHERE `id`=userID AND `enterpriseID`=enterpriseID");
        // $photo = mysql_result($result, 0, "photo");

        // if (strpos($photo, "caricatura") === false) {
        //     // If the cell allows any interation
        //     if ($date + 90*60 >= $now && $date - 5*60 <= $now) {
        //         echo " star";
        //     }
        // }
        // 
    }

    function writeTable($calendarID, $timestamp, $dayBegin, $dayEnd, $hourBegin, $hourEnd, $duration, $interval, $tolerance, $force) {

        $result = getPeriodForTimestampQuery($calendarID, $timestamp);
        
        //  See if the current period is empty or the member has rights to rewrite it
        if (mysql_num_rows($result) == 0 || $force) {

            // Remove the current entries
            $remove = removePeriodForTimestampQuery($calendarID, $timestamp);

            // And add some new ones
            for ($j = $dayBegin; $j <= $dayEnd; $j++) { // Number of days
                for ($i = $hourBegin * 60; $i < $hourEnd * 60; $i = $i + $duration + $interval) { // Number of minutes

                    // Calculate the current timestamp
                    $dateBegin = $timestamp + $j * 24 * 3600 + $i * 60;

                    // Insert each row
                    $insert = resourceForQuery(
                        "INSERT INTO 
                            `shiftMember` 
                                (`calendarID`, `memberID`, `dateBegin`, `dateEnd`, `tolerance`)
                            VALUES (
                                $calendarID,
                                '1',
                                FROM_UNIXTIME($dateBegin),
                                FROM_UNIXTIME($dateBegin + $duration * 60),
                                $tolerance
                            )
                    ");

                    // Kill the insertion if something went wrong
                    if (!$insert) http_status_code(500);
                }
            }
        } else {
            http_status_code(406);
        }
    }

    function copyTable($calendarID, $fromTimestamp, $toTimestamp) {

        // Delete all the entries for the given timestamp
        $delete = resourceForQuery(
            "DELETE FROM
                `shiftMember`
             WHERE 1
                AND `shiftMember`.`calendarID` = $calendarID
                AND `shiftMember`.`dateBegin` >= FROM_UNIXTIME($toTimestamp)
                AND `shiftMember`.`dateEnd` <= DATE_ADD(FROM_UNIXTIME($toTimestamp), INTERVAL '7' DAY)
        ");

        if ($delete) {
            // Get the difference in days
            $days = ($toTimestamp - $fromTimestamp) / 86400;
            
            // Copy the rows inside the database
            $insert = resourceForQuery(
            // echo (
                "INSERT INTO
                    `shiftMember`
                    (`calendarID`, `memberID`, `dateBegin`, `dateEnd`, `tolerance`) 
                SELECT
                    `shiftMember`.`calendarID`,
                    `shiftMember`.`memberID`,
                    DATE_ADD(`shiftMember`.`dateBegin`, INTERVAL '$days' DAY),
                    DATE_ADD(`shiftMember`.`dateEnd`, INTERVAL '$days' DAY),
                    `shiftMember`.`tolerance`
                FROM
                    `shiftMember`
                WHERE 1
                    AND `shiftMember`.`calendarID` = $calendarID
                    AND `shiftMember`.`dateBegin` >= FROM_UNIXTIME($fromTimestamp)
                    AND `shiftMember`.`dateEnd` <= DATE_ADD(FROM_UNIXTIME($fromTimestamp), INTERVAL '7' DAY)
            ");

            if (!$insert) http_status_code(500);

            // notificationSave(array($userBD), "<b>$core->user</b> lhe adicionou no plantão.", "presence.php");
        } else {
            http_status_code(500);
        }
    }

?>