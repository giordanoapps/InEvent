<?php

    function printFrontAtEvent($result) {

        // Get the singleton
        $core = Core::singleton();

        if (mysqli_num_rows($result) > 0) {
            $data = mysqli_fetch_array($result);

        ?>
            <div class="cover infoContainerImage" name="cover" style="background-image: url(images/<?php echo $data['cover'] ?>);">
                <div class="file-uploader"></div>
                <progress value="0" max="100"></progress>
            </div>

            <div
                class="details"
                data-dateBegin="<?php echo $data['dateBegin'] ?>"
                data-monthBegin="<?php echo date("m", $data['dateBegin']) ?>"
                data-dayBegin="<?php echo date("d", $data['dateBegin']) ?>"
                data-hourBegin="<?php echo date("H", $data['dateBegin']) ?>"
                data-minuteBegin="<?php echo date("i", $data['dateBegin']) ?>"
                data-enrollmentBegin="<?php echo date("d/m/y H:i", $data['enrollmentBegin']) ?>"
                data-dateEnd="<?php echo $data['dateEnd'] ?>"
                data-monthEnd="<?php echo date("m", $data['dateEnd']) ?>"
                data-dayEnd="<?php echo date("d", $data['dateEnd']) ?>"
                data-hourEnd="<?php echo date("H", $data['dateEnd']) ?>"
                data-minuteEnd="<?php echo date("i", $data['dateEnd']) ?>"
                data-enrollmentEnd="<?php echo date("d/m/y H:i", $data['enrollmentEnd']) ?>">

                <div class="date">
                    <div class="dateBegin">
                        <img src="images/64-Clock.png" alt="Relógio" title="Horário de Início">
                        <span><?php echo strftime("%d de %B às %Hh%M", $data['dateBegin']) ?></span>
                    </div>
                </div>

                <!-- ToolBonus Calendar -->
                <div class="toolBonus toolBonusCalendar">
                    <div class="innerWrapper calendarBox">

                        <div class="firstSection">
                        
                            <p class="title">Início do evento</p>
                            <ul class="clock">
                                <li id="sec"></li>
                                <li id="hour"></li>
                                <li id="min"></li>
                            </ul>
                            <div class="dateBox">
                                <input type="text" class="day dayBegin" name="dayBegin" placeholder="00" value="">
                                <span> / </span>
                                <input type="text" class="month monthBegin" name="monthBegin" placeholder="00" value="">
                            </div>
                            <div class="timeBox">
                                <input type="text" class="hour hourBegin" name="hourBegin" placeholder="00" value="">
                                <span> : </span>
                                <input type="text" class="minute minuteBegin" name="minuteBegin" placeholder="00" value="">
                            </div>
                            
                        </div>
                        
                        <div class="secondSection">
                        
                            <p class="title">Fim do evento</p>
                            <ul class="clock">
                                <li id="sec"></li>
                                <li id="hour"></li>
                                <li id="min"></li>
                            </ul>
                            <div class="dateBox">
                                <input type="text" class="day dayEnd" name="dayEnd" placeholder="00" value="">
                                <span> / </span>
                                <input type="text" class="month monthEnd" name="monthEnd" placeholder="00" value="">
                            </div>
                            <div class="timeBox">
                                <input type="text" class="hour hourEnd" name="hourEnd" placeholder="00" value="">
                                <span> : </span>
                                <input type="text" class="minute minuteEnd" name="minuteEnd" placeholder="00" value="">
                            </div>
                        </div>

                        <div class="enrollmentTrigger">
                            <span>Inscrições</span>
                            <img src="images/64-Bended-Arrow-Down.png" alt="Arrow down" class="pathArrow">
                        </div>
                    
                    </div>

                    <div class="enrollmentBox">
                        <div>
                            <p>Início das inscrições</p>
                            <input type="text" class="enrollmentBegin" name="enrollmentBegin" placeholder="DD/MM/YY HH:MM" value="" data-serverParse="true">
                        </div>

                        <div>
                            <p>Fim das inscrições</p>
                            <input type="text" class="enrollmentEnd" name="enrollmentEnd" placeholder="DD/MM/YY HH:MM" value="" data-serverParse="true">
                        </div>
                    </div>
                </div>

                <div class="upper">
                    <p class="title" name="name"><?php echo $data['name'] ?></p>
                    <p class="info">Em <span class="address" name="address"><?php echo $data['address'] ?></span> <span class="city" name="city"><?php echo $data['city'] ?></span><b> - </b><span class="state" name="state"><?php echo $data['state'] ?></span>, organizado por <span class="fugleman" name="fugleman"><?php echo $data['fugleman'] ?></span>.</p>
                </div>

                <div class="middle">
                    <div class="enroll" data-id="<?php echo $data['id'] ?>">
                        <?php if ($core->auth && $data['approved'] >= 0) { ?>
                            <input type="button" value="Ir para evento" title="Veja suas atividades dentro do evento" class="singleButton toolEnrolled">
                        <?php } elseif ($data['enrollmentBegin'] > time()) { ?>
                            <input type="button" value="Inscrições não abertas" title="As inscrições do evento ainda não foram abertas" class="singleButton toolEarly">
                        <?php } elseif ($data['enrollmentEnd'] < time()) { ?>
                             <input type="button" value="Inscrições encerradas" title="As inscrições evento já foram encerradas" class="singleButton toolLate">
                        <?php } else { ?>
                            <input type="button" value="Inscrever" title="Se inscreva para escolher as atividades dentro do evento" class="singleButton toolEnroll">
                        <?php } ?>
                    </div>
                    <p class="nicknameWrapper">#<span class="nickname" name="nickname"><?php echo $data['nickname'] ?></span></p>
                </div>

                <div class="bottom">
                    <span class="description" name="description"><?php echo $data["description"] ?></span>
                </div>

            </div>
    <?php

        }
    }
?>