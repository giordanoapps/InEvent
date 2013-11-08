<?php

    function printApplication($details, $order = "memberID") {

        if (count($details) > 0) {

            $imageOrder = "<img src='images/64-Power.png' class='power' alt='Ordem' title='Essa tabela está ordenada pela coluna zap!'>";
                            
        ?>

            <p class="title" name="name"><?php echo $details["name"] ?></p>

            <div class="secretBox">
                <p><b>appID</b>: <?php echo str_pad($details['id'], 32, "0", STR_PAD_LEFT) ?></p>
                <p><b>appSecret</b>: <?php echo $details['secret'] ?></p>
                <input
                    type="button"
                    value="Renovar credenciais"
                    title="Revoga as atuais credenciais e cria novas para a aplicação"
                    class="singleButton toolDangerous">
            </div>

            <!-- PEOPLE -->
            <table>
                <thead>
                    <tr>
                        <td data-order="memberID">personID <?php if ($order == "memberID") echo $imageOrder ?></td>
                        <td data-order="name">Nome <?php if ($order == "name") echo $imageOrder ?></td>
                        <td data-order="email">Email <?php if ($order == "email") echo $imageOrder ?></td>
                        <td data-order="roleID"><i>Staff</i> <?php if ($order == "roleID") echo $imageOrder ?></td>
                        <td></td>
                    </tr>
                </thead>
                <tbody>

                <?php

                $result = getAppMemberDetails($details["id"]);

                while ($data = mysqli_fetch_assoc($result)) {

                    ?>
                    <tr class="pickerItem" data-value="<?php echo $data['memberID'] ?>">
                        <td>
                            <p class="memberID"><b><?php echo str_pad($data['memberID'], 3, "0", STR_PAD_LEFT) ?></b></p>
                        </td>
                        <td>
                            <p class="name"><?php echo ucwords(strtolower($data['name'])) ?></p>
                        </td>
                        <td>
                            <p class="email"><?php echo $data['email'] ?></p>
                        </td>
                        <td>
                            <?php if ($data['roleID'] != ROLE_ATTENDEE) { ?>
                            <img src="images/64-Admin-User.png" class="head staff" alt="Head" title="Altere as permissões da pessoa, concedendo ou revogando poderes">
                            <?php } else { ?>
                            <img src="images/64-User.png" class="head" alt="Head" title="Altere as permissões da pessoa, concedendo ou revogando poderes">
                            <?php } ?>
                        </td>
                        <td>
                            <input
                                type="button"
                                value="Remover"
                                title="Remover a pessoa como administradora da aplicação"
                                class="singleButton toolRemove">
                        </td>
                    </tr>

                <?php } ?>

                </tbody>
            </table>

            <!-- EVENT -->
            <table>
                <thead>
                    <tr>
                        <td data-order="eventID">eventID <?php if ($order == "eventID") echo $imageOrder ?></td>
                        <td data-order="name">Nome <?php if ($order == "name") echo $imageOrder ?></td>
                        <td data-order="nickname">Nick <?php if ($order == "nickname") echo $imageOrder ?></td>
                        <td data-order="dateBegin">Início <?php if ($order == "dateBegin") echo $imageOrder ?></td>
                        <td data-order="dateEnd">Fim <?php if ($order == "dateEnd") echo $imageOrder ?></td>
                        <td data-order="city">Local <?php if ($order == "city") echo $imageOrder ?></td>
                        <td data-order="entries">Pessoas <?php if ($order == "entries") echo $imageOrder ?></td>
                    </tr>
                </thead>
                <tbody>

                <?php

                $result = getAppEventDetails($details["id"]);

                while ($data = mysqli_fetch_assoc($result)) {

                    ?>
                    <tr class="pickerItem" data-value="<?php echo $data['eventID'] ?>">
                        <td>
                            <p class="eventID"><b><?php echo str_pad($data['eventID'], 3, "0", STR_PAD_LEFT) ?></b></p>
                        </td>
                        <td>
                            <p class="name"><?php echo ucwords(strtolower($data['name'])) ?></p>
                        </td>
                        <td>
                            <p class="nickname"><?php echo "#" . $data['nickname'] ?></p>
                        </td>
                        <td>
                            <p class="dateBegin"><?php echo date("d/m H:i", $data['dateBegin']) ?></p>
                        </td>
                        <td>
                            <p class="dateEnd"><?php echo date("d/m H:i", $data['dateEnd']) ?></p>
                        </td>
                        <td>
                            <p class="city"><?php echo $data['city'] . " - " . $data['state'] ?></p>
                        </td>
                        <td>
                            <p class="entries"><?php echo $data['entries'] ?></p>
                        </td>
                    </tr>

                <?php } ?>

                </tbody>
            </table>

            <div class="wipeOut">
                <p>Danger Zone</p>
                 <input
                    type="button"
                    value="Remover permanentemente"
                    title="Deletar a aplicação e todos seus dados"
                    class="singleButton toolDangerous">
            </div>

        <?php } ?>

    </div>
    <?php

    }

?>