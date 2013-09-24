<?php
	include_once("includes/check/login.php");
?>

<?php include_once("includes/html/header.php") ?>
<body class="deadNotifications">
	<?php include_once("includes/html/bar.php") ?>

	<div id="content">
		<div id="forgotContent" class="pageContent">
			
			<div class="titleContent">Trocar a senha?</div>
			
			<div class="boardContent">
					
				<p class="byItself">Me diga sua senha antiga:</p>
				<input type="password" class="oldPassword" name="oldPassword" placeholder="Digite sua senha antiga">

				<p class="byItself">E agora sua senha nova:</p>
				<input type="password" class="newPassword" name="newPassword" placeholder="Digite sua senha nova">

				<input type="button" class="singleButton sendRecovery" value="Trocar senha">

				<p class="byItself alert">Senha alterada com sucesso!</p>

			</div>

		</div>
    </div>
    
    <?php include_once("includes/html/wrapper.php") ?>
	
</body>
</html>