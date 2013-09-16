<?php
	include_once("includes/check/login.php");
	
	if (!$core->auth) logout();
?>

<?php include_once("includes/html/header.php") ?>
<body>
	<?php include_once("includes/html/bar.php") ?>
	<div id="content">

		<div id="eventContent" class="pageContent fullPageContent">
			<div class="boardContent">
<?php /*
				<div class="menuContent">

					<!-- ToolBox Create Activity -->
					<div class="toolBoxOptions toolBoxOptionsCreateActivity">
						<input type="text" placeholder="Nome completo" class="name">
						<input type="text" placeholder="Email" class="email">
						<input type="button" value="Criar!" class="singleButton">

						<div class="innerWrapper calendarBox">

				            <div class="left">
				            
				                <p class="title">Início</p>
				                <ul class="clock">
				                    <li id="sec"></li>
				                    <li id="hour"></li>
				                    <li id="min"></li>
				                </ul>
				                <div class="timeBox">
				                    <input type="text" class="time hours" name="timeBegin" placeholder="00" data-optional="hours" value="<?php echo date("H", $timeBegin) ?>">
				                    <span> : </span>
				                    <input type="text" class="time minutes" name="timeBegin" placeholder="00" data-optional="minutes" value="<?php echo date("i", $timeBegin) ?>">
				                </div>
				                
				            </div>
				            
				            <div class="middle">
				            
				                <p class="title">Fim</p>
				                <ul class="clock">
				                    <li id="sec"></li>
				                    <li id="hour"></li>
				                    <li id="min"></li>
				                </ul>
				                <div class="timeBox">
				                    <input type="text" class="time hours" name="timeEnd" placeholder="00" data-optional="hours" value="<?php echo date("H", $timeEnd) ?>">
				                    <span> : </span>
				                    <input type="text" class="time minutes" name="timeEnd" placeholder="00" data-optional="minutes" value="<?php echo date("i", $timeEnd) ?>">
				                </div>
				            </div>
				        </div>

					</div>

					<!-- Tool Triggers -->
					<div class="toolBox">
						<div class="toolBoxPeople">
							<div class="toolBoxLeft">
								<img src="images/64-Box-Outgoing-2.png" alt="Exportar" title="Exportar os dados para uma planilha" class="toolExport"/>
								<img src="images/64-Users.png" alt="Pessoa" title="Adicionar nova pessoa à atividade" class="toolCreate"/>
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
				*/ ?>

				<div class="realContent">
					<?php printAgenda($core->eventID, $core->memberID); ?>
				</div>

			</div>
		</div>
    </div>
	
	<?php include_once("includes/html/wrapper.php") ?>
	
</body>
</html>