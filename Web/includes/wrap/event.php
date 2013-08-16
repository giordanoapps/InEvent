<?php

    function printTimeline($eventID, $memberID) {

        $result = getActivitiesForMemberQuery($eventID, $memberID);

        ?><ul><?php

        if (mysql_num_rows($result) > 0) {

            $day = 0;

            while ($data = mysql_fetch_assoc($result)) {

                if ($day != $data['day']) {
                    $day = $data['day'];

                    ?>
                        <li value="" class="scheduleDay">
                            <span><?php echo date("j/m", $data['dateBegin']) ?></span>
                            <span><?php echo getDayNameForDate($data['dateBegin']) ?></span>
                        </li>
                    <?php
                }

                printTimelineItem($data);
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

    function printTimelineItem($data) {
        ?>
        <li
            value="<?php echo $data['id'] ?>"
            class="scheduleItem <?php if ($data['memberID'] == 0) { ?>scheduleItemInvisible<?php } ?>"
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
                <div class="upper" title="<?php if ($data['approved'] == 1) { ?>Aprovado<?php } else { ?>Lista de espera<?php } ?>">
                    <p class="name"><?php echo $data['name'] ?></p>
                    <p class="hint <?php if ($data['approved'] == 1) { ?>hintApproved<?php } else { ?>hintDenied<?php } ?>"></p>
                </div>
                <div class="bottom">
                    <p class="description"><?php echo $data['description'] ?></p>
                    <?php if ($data['capacity'] == 0) { ?>
                    <div class="dock">
                        <ul>
                            <li class="orderPrint tool">
                                <img src="images/32-Cross.png" alt="Remover" title="Remover" class="toolExpel">
                            </li>
                        </ul>
                    </div>
                    <?php } ?>
                </div>
            </div>
        </li>
        <?php
    }

    function printActivities($eventID, $memberID) {

        $result = getActivitiesForMemberQuery($eventID, $memberID);

        ?><ul><?php

        if (mysql_num_rows($result) > 0) {

            $day = 0;

            while ($data = mysql_fetch_assoc($result)) {

                if ($day != $data['day']) {
                    $day = $data['day'];

                    ?>
                        <li value="" class="pickerDay">
                            <span><?php echo date("j/m", $data['dateBegin']) ?></span>
                            <span><?php echo getDayNameForDate($data['dateBegin']) ?></span>
                        </li>
                    <?php
                }

                ?>
                <li
                    value="<?php echo $data['id'] ?>"
                    class="pickerItem <?php if ($data['highlight'] == 1) { ?>pickerItemHighlight<?php } ?>"
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
                            <input
                                type="button"
                                value="Inscrever!"
                                class="singleButton toolEnroll <?php if ($data['memberID'] != 0) { ?>singleButtonInvisible<?php } ?>">
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