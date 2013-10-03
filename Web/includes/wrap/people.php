<?php

    function printPeopleAtActivity($result, $order = "name") {

        $imageOrder = "<img src='images/64-Power.png' class='power' alt='Ordem' title='Essa tabela está ordenada pela coluna zap!'>";

        ?>

        <table>
            <thead>
                <tr>
                    <td data-order="memberID">Inscrição <?php if ($order == "memberID") echo $imageOrder ?></td>
                    <td data-order="position">Posição <?php if ($order == "position") echo $imageOrder ?></td>
                    <td data-order="name">Nome <?php if ($order == "name") echo $imageOrder ?></td>
                    <td data-order="email">Email <?php if ($order == "email") echo $imageOrder ?></td>
                    <td data-order="approved">Aprovado <?php if ($order == "approved") echo $imageOrder ?></td>
                    <td data-order="paid">Pago <?php if ($order == "paid") echo $imageOrder ?></td>
                    <td data-order="present">Presente <?php if ($order == "present") echo $imageOrder ?></td>
                    <td></td>
                </tr>
            </thead>
            <tbody>

            <?php

            $position = 0;

            while ($data = mysql_fetch_assoc($result)) {

                ?>
                <tr class="pickerItem" data-value="<?php echo $data['memberID'] ?>">
                    <td>
                        <p class="memberID"><b><?php echo str_pad($data['memberID'], 4, "0", STR_PAD_LEFT) ?></b></p>
                    </td>
                    <td>
                        <p class="position"><b><?php echo $data['position'] ?></b></p>
                    </td>
                    <td>
                        <p class="name"><?php echo ucwords(strtolower($data['name'])) ?></p>
                    </td>
                    <td>
                        <p class="email"><?php echo $data['email'] ?></p>
                    </td>
                    <td>
                        <?php /* if ($data["approved"] == 1) { ?>
                        <img class="approved" src="images/32-Check.png" title="Está pessoa foi aprovada!!">
                        <?php } else { ?>
                        <img class="approved" src="images/32-Cross.png" title="Essa pessoa ainda está na lista de espera">
                        <?php } */ ?>
                        <img 
                            src="images/<?php if ($data["approved"]) { echo '44-checkOn.png'; } else { echo '44-checkOff.png'; } ?>" 
                            alt="checkBox"
                            title="Aprovar a entrada!"
                            class="checkbox approved <?php if ($data["approved"]) { echo 'active'; } ?>" 
                            data-exclusive="yes" 
                            data-value="<?php if ($data["approved"]) { echo '1'; } else { echo '0'; } ?>">
                    </td>
                    <td>
                        <img 
                            src="images/<?php if ($data["paid"]) { echo '44-checkOn.png'; } else { echo '44-checkOff.png'; } ?>" 
                            alt="checkBox"
                            title="Confirmar o pagamento!"
                            class="checkbox paid <?php if ($data["paid"]) { echo 'active'; } ?>" 
                            data-exclusive="yes" 
                            data-value="<?php if ($data["paid"]) { echo '1'; } else { echo '0'; } ?>">
                    </td>
                    <td>
                        <img 
                            src="images/<?php if ($data["present"]) { echo '44-checkOn.png'; } else { echo '44-checkOff.png'; } ?>" 
                            alt="checkBox"
                            title="Confirmar a presença!"
                            class="checkbox present <?php if ($data["present"]) { echo 'active'; } ?>" 
                            data-value="<?php if ($data["present"]) { echo '1'; } else { echo '0'; } ?>">
                    </td>
                    <td>
                        <input
                            type="button"
                            value="Remover!"
                            title="Remover a inscrição da pessoa e chamar a próxima na lista de espera"
                            class="singleButton toolRemove">
                    </td>
                </tr>
                <?php
            }

            ?>
            </tbody>
        </table>
        <?php
    }

    function printPeopleAtEvent($result, $order = "name") {

        $imageOrder = "<img src='images/64-Power.png' class='power' alt='Ordem' title='Essa tabela está ordenada pela coluna zap!'>";

        ?>

        <table>
            <thead>
                <tr>
                    <td data-order="roleID"><i>Staff</i> <?php if ($order == "roleID") echo $imageOrder ?></td>
                    <td data-order="memberID">Inscrição <?php if ($order == "memberID") echo $imageOrder ?></td>
                    <td data-order="name">Nome <?php if ($order == "name") echo $imageOrder ?></td>
                    <td data-order="email">Email <?php if ($order == "email") echo $imageOrder ?></td>
                    <td data-order="present">Presença <?php if ($order == "present") echo $imageOrder ?></td>
                    <td data-order="cpf">CPF <?php if ($order == "cpf") echo $imageOrder ?></td>
                    <td data-order="rg">RG <?php if ($order == "rg") echo $imageOrder ?></td>
                </tr>
            </thead>
            <tbody>

            <?php

            while ($data = mysql_fetch_assoc($result)) {

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
                        <p class="memberID"><b><?php echo str_pad($data['memberID'], 4, "0", STR_PAD_LEFT) ?></b></p>
                    </td>
                    <td>
                        <p class="name"><?php echo ucwords(strtolower($data['name'])) ?></p>
                    </td>
                    <td>
                        <p class="email"><?php echo $data['email'] ?></p>
                    </td>
                    <td>
                        <p class="present"><?php echo $data['present'] ?> %</p>
                    </td>
                    <td>
                        <p class="cpf"><?php echo $data['cpf'] ?></p>
                    </td>
                    <td>
                        <p class="rg"><?php echo $data['rg'] ?></p>
                    </td>
                    <!-- <td>
                        <input
                            type="button"
                            value="Make boss!"
                            title="Torna a pessoa em um membro da organização, permitindo que altere as pessoas, confirme a presença e vaidar o pagamento em cada atividade."
                            class="singleButton toolBoss">
                    </td> -->
                </tr>
                <?php
            }

            ?>
            </tbody>
        </table>
        <?php
    }
?>