<?php include_once("includes/check/login.php") ?>
<?php include_once("includes/html/header.php") ?>
<body>
	<?php include_once("includes/html/bar.php") ?>
	<div id="content">
	
		<div id="certificateContent" class="pageContent fullPageContent">
		
			<p class="introduction">Abaixo estão todas as atividades em que participou e obteve <b>presença</b>.</p>

			<?php

				// Get only the activities where the person is present
				$result = getActivitiesForMemberQuery("AND `activity`.`eventID` = $core->eventID AND `activityMember`.`present` = 1", $core->memberID, true);

				if (mysql_num_rows($result) > 0) {
            ?>

	            <table>
	                <thead>
	                    <tr>
	                        <td data-order="name">Nome</td>
	                        <td data-order="description">Descrição</td>
	                        <td data-order="dateBegin">Data de início</td>
	                        <td data-order="dateEnd">Data de fim</td>
	                        <td data-order="location">Localização</td>
	                    </tr>
	                </thead>
	                <tbody>
	                <?php

	                while ($data = mysql_fetch_assoc($result)) {

	                    ?>
	                    <tr class="pickerItem">
	                        <td>
	                            <p class="name"><?php echo ucwords($data['name']) ?></p>
	                        </td>
	                        <td>
	                            <p class="description"><?php echo $data['description'] ?></p>
	                        </td>
	                        <td>
	                            <p class="dateBegin"><?php echo date("d/m G:i", $data['dateBegin']) ?></p>
	                        </td>
	                       	<td>
	                            <p class="dateBegin"><?php echo date("d/m G:i", $data['dateEnd']) ?></p>
	                        </td>
   	                        <td>
	                            <p class="location"><?php echo $data['location'] ?></p>
	                        </td>
	                    </tr>
	                    <?php } ?>
	                </tbody>
	            </table>
			<?php } ?>
		</div>
			
	</div>
	
	<?php include_once("includes/html/wrapper.php") ?>
	
</body>
</html>