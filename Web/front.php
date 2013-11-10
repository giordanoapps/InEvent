<?php
	include_once("includes/check/login.php")
?>

<?php include_once("includes/html/header.php") ?>
<body>
	<?php include_once("includes/html/bar.php") ?>
	<div id="content">
		<div id="frontContent" class="pageContent">
			<div class="boardContent">

				<?php if ($core->workAtEvent) { ?>
				<div class="menuContent">
					
					<!-- Tool Triggers -->
					<div class="toolBox">
						<div class="toolBoxPeople">
							<div class="toolBoxLeft"></div>
							<div class="toolBoxLeft editingToolBox"></div>
							
							<div class="toolBoxRight">
								<img src="images/32-Pencil-_-Edit.png" alt="Preferências" title="Entrar no modo de edição" class="toolPreferences"/>
							</div>
							<div class="toolBoxRight editingToolBox">
								<input type="button" name="Finalizar" value="Finalizar" title="Finalizar o modo de edição" class="toolDone toolBoxButton submitButton" />
							</div>
						</div>
					</div>
				</div>
				<?php } ?>
				
				<?php

					// Get some data
					if ($core->auth) {
						$result = getEventForMemberQuery($core->eventID, $core->memberID);
					} else {
						$result = getEventForEventQuery($core->eventID);
					}

					// Display some data
					printFrontAtEvent($result);
				?>
			
			</div>
		</div>
	</div>
	
	<?php include_once("includes/html/wrapper.php") ?>
	
</body>
</html>