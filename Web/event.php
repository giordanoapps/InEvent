<?php
	include_once("includes/check/login.php");
	
	// if (!$core->auth) logout();
?>

<?php include_once("includes/html/header.php") ?>
<body>
	<?php include_once("includes/html/bar.php") ?>
	<div id="content">
		<div id="eventContent" class="pageContent fullPageContent">
			<div class="boardContent">
	
				<?php if ($core->auth) { ?>
				<div class="menuContent">
					
					<!-- Tool Triggers -->
					<div class="toolBox">
						<div class="toolBoxPeople">
							<div class="toolBoxLeft">
								<img src="images/64-Text-Document.png" alt="Certificado" title="Emitir certificado de participação" class="toolCertificate"/>
							</div>
							<div class="toolBoxLeft editingToolBox">
								<img src="images/32-Plus.png" alt="Adicionar" title="Adicionar uma atividade à agenda" class="toolAdd"/>
							</div>
							
							<div class="toolBoxRight">
								<?php if ($core->roleID != ROLE_ATTENDEE) { ?>
								<img src="images/32-Pencil-_-Edit.png" alt="Preferências" title="Entrar no modo de edição" class="toolPreferences"/>
								<?php } ?>
							</div>
							<div class="toolBoxRight editingToolBox">
								<input type="button" name="Finalizar" value="Finalizar" title="Finalizar o modo de edição" class="toolDone toolBoxButton submitButton" />
							</div>
						</div>
					</div>
				</div>
				<?php } ?>

				<div class="realContent">
					<?php printAgenda($core->eventID, $core->memberID); ?>

					<!-- ToolBonus Calendar -->
					<li class="toolBonus toolBonusCalendar">
				        <div class="innerWrapper calendarBox">

				            <div class="firstSection">
				            
				                <p class="title">Início</p>
				                <ul class="clock">
				                    <li id="sec"></li>
				                    <li id="hour"></li>
				                    <li id="min"></li>
				                </ul>
				                <div class="dateBox">
				                	<input type="text" class="day dayBegin" name="dayBegin" placeholder="00" value="">
				                    <span> / </span>
				                    <input type="text" class="month monthBegin" name="monthBegin" placeholder="00" value="">
				                </div>
				                <div class="timeBox">
				                    <input type="text" class="hour hourBegin" name="hourBegin" placeholder="00" value="">
				                    <span> : </span>
				                    <input type="text" class="minute minuteBegin" name="minuteBegin" placeholder="00" value="">
				                </div>
				                
				            </div>
				            
				            <div class="secondSection">
				            
				                <p class="title">Fim</p>
				                <ul class="clock">
				                    <li id="sec"></li>
				                    <li id="hour"></li>
				                    <li id="min"></li>
				                </ul>
				                <div class="dateBox">
				                	<input type="text" class="day dayEnd" name="dayEnd" placeholder="00" value="">
				                    <span> / </span>
				                    <input type="text" class="month monthEnd" name="monthEnd" placeholder="00" value="">
				                </div>
				                <div class="timeBox">
				                    <input type="text" class="hour hourEnd" name="hourEnd" placeholder="00" value="">
				                    <span> : </span>
				                    <input type="text" class="minute minuteEnd" name="minuteEnd" placeholder="00" value="">
				                </div>
				            </div>

				        </div>
					</li>

					<!-- ToolBonus Map -->
					<li class="toolBonus toolBonusMap">
						<div id="mapCanvas"></div>
					</li>

					<!-- ToolBonus Options -->
					<li class="toolBonus toolBonusOptions">
						<div>
							<span class="title">Número de vagas</span>
	                    	<span class="explanation">Indica até quantas pessoas deverão ser aprovadas por padrão, com consequente aprovação manual para as seguintes.</span>
	                        <img src="images/32-Users.png" alt="Local" title="Número de vagas na atividade">
	                        <span class="capacity" name="capacity">&infin;</span>
	                    </div>
	                    <div>
	                    	<span class="title">Inscrição automática</span>
	                    	<span class="explanation">Todos os participantes serão automaticamente inscritos nesta atividade quando se registrarem.</span>
		                    <img src="images/44-checkOn.png" alt="checkBox" name="general" class="checkbox general active" data-value="1">
						</div>

						<div>
							<span class="title">Posição destacada</span>
							<span class="explanation">Será mostrada em destaque entre as outras atividades, com cor de fundo e altura diferenciadas.</span>
							<img src="images/44-checkOn.png" alt="checkBox" name="highlight" class="checkbox highlight active" data-value="1">
                        </div>
					</li>

				</div>

			</div>
		</div>
    </div>
	
	<?php include_once("includes/html/wrapper.php") ?>
	
</body>
</html>