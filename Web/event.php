<?php
	include_once("includes/check/login.php");
	
	if (!$core->auth) logout();
?>

<?php include_once("includes/html/header.php") ?>
<body>
	<?php include_once("includes/html/bar.php") ?>
	<div id="content">

		<div id="eventContent" class="pageContent fullPageContent" data-ajax="ajaxPresence">
			
			<div class="placerContent">
				<?php printTimeline(1, 1); ?>
			</div>
			
			<div class="boardContent">
			
				<div class="menuContent">
					<div class="menuBoard leftBoard">
						<img src="images/64-Bended-Arrow-Left.png" class="" alt="Left" id="leftArrow"/>
						<img src="images/64-Bended-Arrow-Right.png" class="" alt="Right" id="rightArrow"/>
					</div>
					
					<div class="searchBoard rightBoard">
						<?php if ($core->groupID == 3 || $core->permission >= 10) { ?>
							<img src="images/64-Pencil.png" class="" alt="Edit" id="editTool"/>
							<img src="images/64-Books.png" class="" alt="Review" id="reviewTool"/>
							<img src="images/64-Day-Calendar.png" class="" alt="Calendar" id="calendarTool"/>
							<img src="images/32-Unfavorite.png" class="" alt="Favorite" id="favoriteTool"/>
							<img src="images/64-Create-_-Write.png" class="" alt="Create" id="createTool"/>
						<?php } ?>
					</div>
				</div>
				
				<div class="optionContent"></div>
				
				<div class="realContent">
					<?php printActivities(1); ?>
				</div>
				
			</div>
		</div>
    </div>
	
	<?php include_once("includes/html/wrapper.php") ?>
	
</body>
</html>