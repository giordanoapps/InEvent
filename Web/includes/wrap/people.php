<?php

    function printPeopleAtActivity($result) {

        if (mysql_num_rows($result) > 0) {
            ?>

            <table>
                <thead>
                    <tr>
                        <td>Inscrição</td>
                        <td>Posição</td>
                        <td>Nome</td>
                        <td>Telefone</td>
                        <td>Aprovado</td>
                        <td>Pago</td>
                        <td>Presente</td>
                        <td></td>
                    </tr>
                </thead>
                <tbody>
                <?php

                $position = 0;

                while ($data = mysql_fetch_assoc($result)) {

                    ?>
                    <tr
                        class="pickerItem"
                        data-value="<?php echo $data['memberID'] ?>"
                        data-request="<?php echo $data['requestID'] ?>">
                        <td>
                            <p class="memberID"><b><?php echo str_pad($data['memberID'], 4, "0", STR_PAD_LEFT) ?></b></p>
                        </td>
                        <td>
                            <p class="requestID"><b><?php echo ++$position ?>&ordm;</b></p>
                        </td>
                        <td>
                            <p class="name"><?php echo ucwords(strtolower($data['name'])) ?></p>
                        </td>
                        <td>
                            <p class="telephone"><?php echo ucwords(strtolower($data['telephone'])) ?></p>
                        </td>
                        <td>
                            <?php if ($data["approved"] == 1) { ?>
                            <img src="images/32-Check.png" title="Está pessoa foi aprovada!!">
                            <?php } else { ?>
                            <img src="images/32-Cross.png" title="Essa pessoa ainda está na lista de espera">
                            <?php } ?>
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

        } else {
            ?>
            <tr>
                <p class="emptyCapital">Nenhuma pessoa inscrita na atividade :(</p>
            </tr>
            <?php
        }
    }

    function printPeopleAtEvent($result) {

        if (mysql_num_rows($result) > 0) {
            ?>

            <table>
                <thead>
                    <tr>
                        <td><i>Staff</i></td>
                        <td>Nome</td>
                        <td>CPF</td>
                        <td>RG</td>
                        <td>Telefone</td>
                        <td>Email</td>
                        <td>Universidade</td>
                        <td>Curso</td>
                        <td>USP</td>
                    </tr>
                </thead>
                <tbody>
                <?php

                while ($data = mysql_fetch_assoc($result)) {

                    ?>
                    <tr
                        class="pickerItem"
                        data-value="<?php echo $data['memberID'] ?>"
                        data-request="<?php echo $data['requestID'] ?>">
                        <td>
                            <?php if ($data['roleID'] != ROLE_ATTENDEE) { ?>
                            <img src="images/64-Admin-User.png" class="head staff" alt="Head" title="Altere os direitos da pessoa">
                            <?php } else { ?>
                            <img src="images/64-User.png" class="head" alt="Head" title="Altere os direitos da pessoa">
                            <?php } ?>
                        </td>
                        <td>
                            <p class="name"><?php echo ucwords(strtolower($data['name'])) ?></p>
                        </td>
                        <td>
                            <p class="cpf"><?php echo $data['cpf'] ?></p>
                        </td>
                        <td>
                            <p class="rg"><?php echo $data['rg'] ?></p>
                        </td>
                        <td>
                            <p class="telephone"><?php echo $data['telephone'] ?></p>
                        </td>
                        <td>
                            <p class="email"><?php echo $data['email'] ?></p>
                        </td>
                        <td>
                            <p class="university"><?php echo $data['university'] ?></p>
                        </td>
                        <td>
                            <p class="course"><?php echo $data['course'] ?></p>
                        </td>
                        <td>
                            <p class="usp"><?php echo $data['usp'] ?></p>
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

        } else {
            ?>
            <tr>
                <p class="emptyCapital">Nenhuma pessoa inscrita no evento :(</p>
            </tr>
            <?php
        }
    }
?>