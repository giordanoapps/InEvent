<?php
	include_once("includes/check/login.php");
	
		if (!$core->auth) logout();
?>

<?php include_once("includes/header.php") ?>
<body>
	<?php include_once("includes/bar.php") ?>
	<div id="content">

		<!--Content-->
		<div id="projectContent" class="pageContent" data-ajax="ajaxProjects">
				
			<div class="menuContent">
				<div class="menuBoard leftBoard">
					<?php if ($core->group == 1 || $core->level >= 10) { ?>
						<input type="button" name="" value="Novo projeto" class="menuInput" id="addProject" />
					<?php } ?>
				</div>
				
				<div class="searchBoard rightBoard">
					<form method="post" action="#" class="searchBoardWrapper">
						<input placeholder="Buscar" type="text" name="" value="" class="searchBoardInput" />
						<img src="images/64-Magnifying-Glass-2.png" alt="Search" class="searchBoardImg" />
					</form>
				</div>
			</div>
													
			<div id="userBox"></div>

			<div class="boardContent">
				<div class="pageContentBox">
					<?php $core->printAllProjects(); ?>
				</div>
				<div class="pageContentSearchBox"></div>
			</div>
			
		</div>

    </div>
	
	<?php include_once("includes/wrapper.php") ?>
	
</body>
</html>