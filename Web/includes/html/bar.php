<div id="header">
	<div class="barWrapper">	
	
	<?php if ($core->auth) { ?>
		
		<div class="bar top">
			<ul class="leftBar">
				<a href="/home.php"><li>Home</li></a>
				<a href="/front.php"><li>Evento</li></a>
				<a href="/event.php"><li>Atividades</li></a>
				<?php if ($core->workAtEvent) { ?>
					<a href="/people.php"><li>Pessoas</li></a>
				<?php } ?>
			</ul>
			
			<ul class="rightBar">
				
				<li class="locationInfo anchorInfo collectionBox interactive">
					<div class="anchorInnerHock">
						<div class="dynamicInput">
							<a class="iconWrapper" href=	"marketplace.php" title="Descubra todos os eventos organizados pelo InEvent">
								<img src="images/64-Map.png" alt="Map Icon" class="mapIcon">
								<img src="images/64-Magnifying-Glass-2.png" alt="Search Icon" class="searchIcon">
							</a>
							<?php
								$result = resourceForQuery(
									"SELECT
										`event`.`id`,
										`event`.`name`
									FROM
										`event`
									WHERE
										`event`.`id` = $core->eventID
								");
							?>
							<input 
								value="<?php if (mysqli_num_rows($result) > 0) { echo mysqli_result($result, 0, "name"); } ?>"
								data-table="event"
								data-value="<?php if (mysqli_num_rows($result) > 0) { echo mysqli_result($result, 0, "id"); } ?>"
								type="text"
								class="collectionSelectedInput"
								name="collectionSelectedInput"
								autocomplete="off"
								placeholder="Onde ir?">
						</div>
					</div>
					<ul class="locationBox anchorBox popover">
						<li class="header">PESQUISA</li>
						<div class="collectionOptions">
							<ul></ul>
						</div>
						
						<?php
							$result = resourceForQuery(
								"SELECT
									`event`.`id`,
									`event`.`name`,
									`event`.`nickname`
								FROM
									`eventMember`
								INNER JOIN
									`event` ON `eventMember`.`eventID` = `event`.`id`
								WHERE 1
									AND `eventMember`.`memberID` = $core->memberID
									AND `eventMember`.`roleID` != @(ROLE_ATTENDEE)
							");

							if (mysqli_num_rows($result) > 0) {
								// Print the header
								?><li class="header">TRABALHO</li><?php

								// And then each one of the restaurants
								for ($i = 0; $i < mysqli_num_rows($result); $i++) {
									?>
									<li
										class="locationItem"
										value="<?php echo mysqli_result($result, $i, "id") ?>"
										data-nick="<?php echo mysqli_result($result, $i, "nickname") ?>">
										<?php echo mysqli_result($result, $i, "name") ?>
									</li>
									<?php
								}
							}
						?>
					</ul>
				</li>
				<li class="loginInfo anchorInfo">
					<div class="anchorInnerHock"><p><?php echo truncateName($core->name, 15) ?></p></div>
					<ul class="loginBox anchorBox popover">
						<a href="/data.php"><li>Editar perfil</li></a>
						<a href="/reinstate.php"><li>Trocar senha</li></a>
						<a href="/logout.php"><li>Sair da conta</li></a>
					</ul>
				</li>
			</ul>
		</div>
	
	<?php } else { ?>
	
		<div class="bar top loginBar">
			<ul class="leftBar">
				<a href="/home.php"><li>InEvent</li></a>
				<a href="/front.php"><li>Evento</li></a>
				<a href="/event.php"><li>Atividades</li></a>
			</ul>
			
			<ul class="rightBar">

				<a href="/data.php"><li class="first">Registrar</li></a>
				
				<li onclick="" class="userLoginLeading first">Entrar</li>
				<li onclick="" class="userLoginBox secondary">
					<div class="facebookBox">
						<img src="images/facebookButton.png" name="" id="" />
						<!-- <fb:login-button show-faces="true" width="200" max-rows="1"></fb:login-button> -->
					</div>
					
					<div class="middleLine">OU</div>
					
					<div class="memberBox">
						<form method="post" action="">
							<input type="text" placeholder="Email" name="email"/>
							<input type="password" placeholder="Senha" name="password"/>
							<input type="submit" class="singleButton" value="Entrar" />
							<?php if (isset($_POST["login_error"])) { ?>
								<p class="errorMessage"><?php echo $_POST["login_error"] ?></p>
								<?php if (isset($_POST["login_count"])) { ?>
									<p class="errorHint">Esta foi sua tentativa número <?php echo $_POST["login_count"] ?> de no máximo 3. Após isso sua conta será bloqueada e uma nova senha será enviada para seu email.</p>
								<?php } else { ?>
									<p class="errorHint">Sua conta foi bloqueada por 10 minutos e uma nova senha foi enviada para seu email.</p>
								<?php } ?>
							<?php } ?>
							<a class	="forgot" href="/forgot.php">Esqueci a senha</a>
						</form>
					</div>
				</li>
				
			</ul>
		</div>
		
	<?php } ?>
	
	</div>
</div>