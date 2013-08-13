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

                ?>
                <li value="<?php echo $data['id'] ?>" class="scheduleItem">
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
                        <div class="bottom">
                            <p class="description"><?php echo $data['description'] ?></p>
                            <input type="button" value="Não mais :(" class="singleButton toolExpel">
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

   function printActivities($eventID, $memberID) {

        $result = getActivitiesForEventQuery($eventID);

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
                <li value="<?php echo $data['id'] ?>" class="pickerItem">
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
                            <input type="button" value="Quero essa!" class="singleButton toolEnroll">
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