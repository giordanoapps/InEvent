<?php
	include_once("includes/check/login.php");
	
	if (!$core->auth) logout();
?>

<?php include_once("includes/html/header.php") ?>
<body>
	<?php include_once("includes/html/bar.php") ?>
	<div id="content">

		<div id="membersContent" class="pageContent fullPageContent" data-ajax="ajaxMembers">
			
			<div class="placerContent"></div>
			
			<div class="boardContent">
				<div class="menuContent">
					<div class="menuBoard leftBoard">
						<?php if ($core->groupID == 3 || $core->permission >= 10) { ?>
							<input type="button" name="" value="Novo membro" class="menuInput" id="add" />
						<?php } ?>
					</div>
					
					<div class="searchBoard rightBoard">
						<div class="sliderBoardWrapper"><div class="sliderBoard"></div><p>Redimensionar</p></div>
						<form method="post" action="#" class="searchBoardWrapper">
							<input placeholder="Buscar" type="text" name="" value="" class="searchBoardInput" />
							<img src="images/64-Magnifying-Glass-2.png" alt="Search" class="searchBoardImg" />
						</form>
					</div>
				</div>
			
				<div id="userBox"></div>
				<div class="snowflake"></div>
				
				<div class="pageContentBox">
					<?php printAllMembers($core->companyID); ?>
					<?php printNewBadge(); ?>
				</div>
				
				<div class="pageContentSearchBox"></div>
				
			</div>

		</div>
    </div>
    
    <?php include_once("includes/html/wrapper.php") ?>
	
</body>
</html>