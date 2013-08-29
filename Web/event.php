<?php
	include_once("includes/check/login.php");
	
	if (!$core->auth) logout();
?>

<?php include_once("includes/html/header.php") ?>
<body>
	<?php include_once("includes/html/bar.php") ?>
	<div id="content">

		<div id="eventContent" class="pageContent fullPageContent">
			
			<div class="placerContent">
				<?php printScheduleForMember(2, $core->memberID); ?>
			</div>
			
			<div class="boardContent">		
				<div class="realContent">
					<?php printAgenda(2, $core->memberID); ?>
				</div>
			</div>
		</div>
    </div>
	
	<?php include_once("includes/html/wrapper.php") ?>
	
</body>
</html>