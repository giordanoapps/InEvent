<?php
	include_once("includes/check/login.php");
?>

<?php include_once("includes/html/header.php") ?>
<body>
	<?php include_once("includes/html/bar.php") ?>	
	<div id="content">
		
		<div id="locationContent" class="pageContent">
			
			<div class="titleContent">Localização</div>
			
			<div class="boardContent">
				<div class="boardContentInnerWrapper">
					<?php
						$result = resourceForQuery("SELECT * FROM `company` WHERE `id`=$core->companyID");
						$data = mysqli_fetch_assoc($result);
					?>
				
					<div class="menuContent notFixed">
						<form method="post" action="#" class="searchLocationWrapper">
							<input
								type="text"
								name="searchLocation"
								placeholder="Qual seu endereço?" 
								value="<?php if ($core->auth) echo $data["address"] ?>" 
								data-longitude="<?php if ($core->auth) echo $data["longitude"] ?>" 
								data-latitude="<?php if ($core->auth) echo $data["latitude"] ?>" 
								<?php if ($core->auth) { ?> readonly="readonly" <?php } ?> 
								class="searchLocation <?php if ($core->auth) echo "writtenOnStone" ?>"
							/>
						</form>
					</div>
					
					<div id="mapCanvas"></div>
					
					<?php if (!$core->auth) { ?>
					<ul class="navigator">
						<a href="register.php" data-lock	="yes"><li>Registro <span class="navigatorHint navigatorHintRight">Próxima</span></li></a>
					</ul>
					<?php } ?>
				</div>
			</div>

		</div>
    </div>
    
    <?php include_once("includes/html/wrapper.php") ?>
</body>
</html>