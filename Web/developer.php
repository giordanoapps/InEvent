<?php
	include_once("includes/check/login.php")
?>

<?php include_once("includes/html/header.php") ?>
<body>
	<?php include_once("includes/html/bar.php") ?>
	<div id="content">
		<div id="developerContent" class="pageContent">			
			<div class="boardContent">

				<div class="switch">
					
					<ul>
						<li class="switchCategory switchCategorySelected">Aplicativos</li>
						<li class="switchCategory">Documentação</li>
					</ul>

				</div>

				<div class="application containerBox containerBoxSelected">

					<div class="menuContent">

						<!-- ToolBox Create App -->
						<div class="toolBoxOptions toolBoxOptionsCreateApp">
							<input type="text" placeholder="Nome da aplicação \o/" class="name">
							<input type="button" value="Criar" class="singleButton">
						</div>
						
						<!-- ToolBox Enroll People -->
						<div class="toolBoxOptions toolBoxOptionsEnrollPerson">
							<input type="text" placeholder="Nome da pessoa" class="name">
							<input type="text" placeholder="Email" class="email">
							<input type="button" value="Criar" class="singleButton">
						</div>

						<!-- ToolBox Add Event -->
						<div class="toolBoxOptions toolBoxOptionsAddEvent">
							<input type="text" placeholder="Nome do evento" class="name">
							<input type="text" placeholder="Apelido (hashtag) do evento" class="nickname">
							<input type="button" value="Criar" class="singleButton">
						</div>

						<!-- Tool Triggers -->
						<div class="toolBox">
							<div class="toolBoxPeople">
								<div class="toolBoxLeft">

								</div>
								<div class="toolBoxLeft editingToolBox">
									<img src="images/64-iPad.png" alt="Aplicação" title="Adicionar uma nova aplicação" class="toolApp"/>
									<img src="images/64-Users.png" alt="Pessoa" title="Adicionar nova pessoa à aplicação" class="toolPerson"/>
									<img src="images/64-Balloons.png" alt="Evento" title="Adicionar novo evento à aplicação" class="toolEvent"/>
								</div>
								
								<div class="toolBoxRight">
									<img src="images/32-Pencil-_-Edit.png" alt="Preferências" title="Entrar no modo de edição" class="toolPreferences"/>
								</div>
								<div class="toolBoxRight editingToolBox">
									<input type="button" name="Finalizar" value="Finalizar" title="Finalizar o modo de edição" class="toolDone toolBoxButton submitButton" />
								</div>
							</div>
						</div>
					</div>
						
					<div class="menuApplication">
						<ul>
						<?php
							$result = resourceForQuery(
								"SELECT
									`app`.`id`,
									`app`.`name`,
									`app`.`secret`
								FROM
									`app`
								INNER JOIN
									`appMember` ON `appMember`.`appID` = `app`.`id`
								WHERE 1
									AND `appMember`.`memberID` = $core->memberID
							");

							// And then each one of the restaurants
							for ($i = 0; $i < mysqli_num_rows($result); $i++) {
								?>
								<li
									class="optionMenuApplicationCategory"
									value="<?php echo mysqli_result($result, $i, "id") ?>">
									<?php echo mysqli_result($result, $i, "name") ?>
								</li>
								<?php
							}
						?>
						</ul>
					</div>

					<div class="contentApplication"></div>

				</div>

				<div class="documentation containerBox">

					<div class="menuDocumentation">
						<ul>
							<li class="optionMenuDocumentationCategory optionMenuDocumentationSelected"><b>Como usar</b></li>
							<li>Anúncio</li>
							<li>Atividade</li>
							<li>Aplicação</li>
							<li>Concurso</li>
							<li>Evento</li>
							<li>Foto</li>
							<li>Grupo</li>
							<li>Pessoa</li>
						</ul>
					</div>

					<div class="contentDocumentation">

						<?php
							include_once("developer/documentation/howTo.php");
							include_once("developer/documentation/ad.php");
							include_once("developer/documentation/activity.php");
							include_once("developer/documentation/app.php");
							include_once("developer/documentation/contest.php");
							include_once("developer/documentation/event.php");
							include_once("developer/documentation/photo.php");
							include_once("developer/documentation/group.php");
							include_once("developer/documentation/person.php");
						?>

						<div class="demoDocumentation">
							<div class="tokenWrapper">
								<div class="inert"><input type="text" class="token" placeholder="$tokenID"></div>
							</div>
							<div class="getWrapper">
								<div class="inert solid"><input type="text" class="getField" placeholder="GET"></div>
							</div>
							<div class="postWrapper">
								<div class="inert solid"><input type="text" class="postField" placeholder="POST"></div>
							</div>
							<pre placeholder="Nenhuma resposta até o momento! Verifique se seus parâmetros estão corretos." class="return"></pre>
						</div>

					</div>

				</div>
			</div>
		</div>
	</div>

	<?php include_once("includes/html/wrapper.php") ?>

</body>
</html>