<?php
	include_once("includes/check/login.php");
	
	if (!$core->auth) logout();
	if (!$core->workAtEvent) logout();
?>

<?php include_once("includes/html/header.php") ?>
<body>
	<?php include_once("includes/html/bar.php") ?>
	<div id="content">

		<div id="peopleContent" class="pageContent fullPageContent">
			
			<div class="placerContent">
				<?php printScheduleForEvent($core->eventID); ?>
			</div>
			
			<div class="boardContent">

				<div class="menuContent">

					<!-- ToolBox Enroll People -->
					<div class="toolBoxOptions toolBoxOptionsEnrollPerson">
						<input type="text" placeholder="Nome completo" class="name">
						<input type="text" placeholder="Email" class="email">
						<input type="button" value="Criar!" class="singleButton">
					</div>

					<!-- Tool Triggers -->
					<div class="toolBox">
						<div class="toolBoxPeople">
							<div class="toolBoxLeft">
								<img src="images/64-Box-Outgoing-2.png" alt="Exportar" title="Exportar os dados para uma planilha" class="toolExport"/>
								<img src="images/64-Users.png" alt="Pessoa" title="Adicionar nova pessoa à atividade" class="toolCreate"/>
								<img src="images/64-Shuffle.png" alt="Aleatório" title="Escolher uma pessoa aleatória" class="toolRandom"/>
							</div>
							<div class="toolBoxLeft editingToolBox">
								<img src="images/32-Plus.png" alt="Adicionar" title="Adicionar uma atividade à agenda" class="toolAdd"/>
							</div>
							
							<div class="toolBoxRight">
								<?php if ($core->roleID != ROLE_ATTENDEE) { ?>
								<!-- <img src="images/32-Pencil-_-Edit.png" alt="Preferências" title="Entrar no modo de edição" class="toolPreferences"/> -->
								<?php } ?>
							</div>
							<div class="toolBoxRight editingToolBox">
								<input type="button" name="Finalizar" value="Finalizar" title="Finalizar o modo de edição" class="toolDone toolBoxButton submitButton" />
							</div>
						</div>
					</div>
				</div>

				<div class="realContent">
					<?php printPeopleAtActivity(getPeopleAtActivityQuery(0)) ?>
				</div>
				
			</div>
		</div>
    </div>
	
	<?php include_once("includes/html/wrapper.php") ?>
	
</body>
</html>