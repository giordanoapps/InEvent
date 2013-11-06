<?php

    function printEvents($memberID) {

        $result = getEventsForMemberQuery($memberID, false);

        ?><ul><?php

        if (mysqli_num_rows($result) > 0) {

            $day = 0;

            while ($data = mysqli_fetch_assoc($result)) {
                ?>
                <li class="eventItem" value="<?php echo $data['id'] ?>">
                    <div class="upper">
                        <p class="title"><?php echo $data['name'] ?></p>
                    </div>
                    <div class="middle">
                        <p class="description"><?php echo $data['description'] ?></p>
                        <p class="dateBegin">
                            <span class="dayMonth"><?php echo date("j/n", $data['dateBegin']) ?></span>
                            <span class="hourMinute"><?php echo date("G:i", $data['dateBegin']) ?></span>
                        </p>
                        <p class="dateEnd">
                            <span class="dayMonth"><?php echo date("j/n", $data['dateEnd']) ?></span>
                            <span class="hourMinute"><?php echo date("G:i", $data['dateEnd']) ?></span>
                        </p>
                    </div>
                    <div class="bottom" data-nick="<?php echo $data['nickname'] ?>">
                        <?php if ($data['approved'] >= 0) { ?>
                            <input type="button" value="Ir para evento" title="Veja suas atividades dentro do evento" class="singleButton toolEnrolled">
                        <?php } elseif ($data['enrollmentBegin'] > time()) { ?>
                            <input type="button" value="Inscrições não abertas" title="As inscrições do evento ainda não foram abertas" class="singleButton toolEarly">
                        <?php } elseif ($data['enrollmentEnd'] < time()) { ?>
                             <input type="button" value="Inscrições encerradas" title="As inscrições evento já foram encerradas" class="singleButton toolLate">
                        <?php } else { ?>
                            <input type="button" value="Inscrever" title="Se inscreva para escolher as atividades dentro do evento" class="singleButton toolEnroll">
                            <!-- <input type="button" value="Sair do evento" title="Será automaticamente removido do evento e todas suas atividades serão excluídas" class="singleButton toolExpel"> -->
                        <?php } ?>
                    </div>
                </li>
                <?php
            }

        } else {
            ?>
            <li>
                <p class="emptyCapital">Nenhum evento :(</p>
            </li>
            <?php
        }

        ?></ul><?php
    }

?>