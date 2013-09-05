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
				<div class="realContent">
					<?php printPeopleAtActivity(getPeopleAtActivityQuery(0)) ?>
				</div>
			</div>
		</div>
    </div>
	
	<?php include_once("includes/html/wrapper.php") ?>
	
</body>
</html>