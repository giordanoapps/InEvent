<?php
	include_once("includes/check/login.php")
?>

<?php include_once("includes/html/header.php") ?>
<body>
	<?php include_once("includes/html/bar.php") ?>
	<div id="content">
		<div id="frontContent" class="pageContent">
			<div class="boardContent">

				<?php

					if ($core->auth) {
						$result = getEventForMemberQuery($core->eventID, $core->memberID);
					} else {
						$result = getEventForEventQuery($core->eventID);
					}

					if (mysql_num_rows($result) > 0) {
						$data = mysql_fetch_array($result);
				?>
			
				<div class="cover" style="background-image: url(images/<?php echo $data['cover'] ?>);"></div>

				<div class="details">

					<div class="date">
						<div class="dateBegin">
							<img src="images/64-Clock.png" alt="Relógio" title="Horário de Início">
							<span><?php echo strftime("%d de %B às %Hh%M", $data['dateBegin']) ?></span>
						</div>	
						<div class="dateEnd">
							<img src="images/64-Clock-2.png" alt="Relógio" title="Horário de Fim">
							<span><?php echo strftime("%d de %B às %Hh%M", $data['dateEnd']) ?></span>
						</div>
					</div>

					<div class="upper">
						<p class="title"><?php echo $data['name'] ?></p>
						<p class="info">Em <span class="location"><?php echo $data['address'] . " " . $data['city'] . " - " . $data['state'] ?></span>, organizado por <span class="fugleman"><?php echo $data['fugleman'] ?></span>.</p>
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
					</div>

					<div class="bottom">
						<span class="description"><?php echo $data["description"] ?></span>
					</div>

				</div>

				<?php } ?>
			
			</div>
		</div>
	</div>
	
	<?php include_once("includes/html/wrapper.php") ?>
	
</body>
</html>