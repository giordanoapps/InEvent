<?php

    function printApplication($data, $order = "memberID") {

        if (count($data) > 0) {

            $imageOrder = "<img src='images/64-Power.png' class='power' alt='Ordem' title='Essa tabela está ordenada pela coluna zap!'>";
                            
        ?>

            <p class="title" name="name"><?php echo $data["name"] ?></p>

            <div class="secretBox">
                <p><b>appID</b>: <?php echo $data["id"] ?></p>
                <p><b>appSecret</b>: <?php echo $data["secret"] ?></p>
            </div>

            <table>
                <thead>
                    <tr>
                        <td data-order="roleID"><i>Staff</i> <?php if ($order == "roleID") echo $imageOrder ?></td>
                        <td data-order="memberID">personID <?php if ($order == "memberID") echo $imageOrder ?></td>
                        <td data-order="name">Nome <?php if ($order == "name") echo $imageOrder ?></td>
                        <td data-order="email">Email <?php if ($order == "email") echo $imageOrder ?></td>
                        <td></td>
                    </tr>
                </thead>
                <tbody>

                <?php

                $result = getAppMemberDetails($data["id"]);

                while ($data = mysqli_fetch_assoc($result)) {

                    ?>
                    <tr class="pickerItem" data-value="<?php echo $data['memberID'] ?>">
                        <td>
                            <?php if ($data['roleID'] != ROLE_ATTENDEE) { ?>
                            <img src="images/64-Admin-User.png" class="head staff" alt="Head" title="Altere as permissões da pessoa, concedendo ou revogando poderes">
                            <?php } else { ?>
                            <img src="images/64-User.png" class="head" alt="Head" title="Altere as permissões da pessoa, concedendo ou revogando poderes">
                            <?php } ?>
                        </td>
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
                            <input
                                type="button"
                                value="Remover"
                                title="Remover a inscrição da pessoa e chamar a próxima na lista de espera"
                                class="singleButton toolRemove">
                        </td>
                    </tr>

                <?php } ?>

                </tbody>
            </table>

        <?php } ?>

    </div>
    <?php

    }

?>