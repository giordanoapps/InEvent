<?php
	include_once("includes/check/login.php")
?>

<?php include_once("includes/html/header.php") ?>
<body>
	<?php include_once("includes/html/bar.php") ?>
	<div id="content">
	
		<div id="frontContent" class="pageContent fullPageContent">

			<?php

				if ($core->auth) {
					$result = getEventForMemberQuery($core->eventID, $core->memberID);
				} else {
					$result = getEventForEventQuery($core->eventID);
				}

				if (mysql_num_rows($result) > 0) {
					$data = mysql_fetch_array($result);
			?>
		
			<div class="cover" style="background-image: url(images/<?php echo $data['cover'] ?>);">
				<!-- <div class="titleWrapper"></div> -->
				<div class="title"><?php echo $data['name'] ?></div>
			</div>

			<div class="left">
	
				<div class="dateBegin">
					<img src="images/64-Clock.png" alt="Relógio" title="Horário de Início">
					<span><?php echo date("j/m G:i", $data['dateBegin']) ?></span>
				</div>

				<div class="dateEnd">
					<img src="images/64-Clock-2.png" alt="Relógio" title="Horário de Término">
					<span><?php echo date("j/m G:i", $data['dateEnd']) ?></span>
				</div>

				<div class="location">
					<img src="images/64-Maps.png" alt="Mapa" title="Localização">
					<span><?php echo $data['address'] . " " . $data['city'] . " - " . $data['state'] ?></span>
				</div>

				<div class="fugleman">
					<img src="images/64-Shades.png" alt="Mister x" title="Realizado por">
					<span><?php echo $data['fugleman'] ?></span>
				</div>

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

			</div>

			<div class="right">
				<span class="description"><?php echo $data["description"] ?></span>
			</div>

			<?php } ?>
			
		</div>
			
	</div>
	
	<?php include_once("includes/html/wrapper.php") ?>
	
</body>
</html>