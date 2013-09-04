<?php
	include_once("includes/check/login.php");
?>

<?php include_once("includes/html/header.php") ?>
<body class="deadNotifications">
	<?php include_once("includes/html/bar.php") ?>

	<div id="content">
		<div id="forgotContent" class="pageContent">
			
			<div class="titleContent">Esqueceu a senha?</div>
			
			<div class="boardContent">
					
				<p class="byItself">Me diga seu email ... e lhe enviarei uma nova senha!</p>

				<input type="text" class="email" name="email" placeholder="Digite seu email (espero que não tenha esquecido!)">

				<input type="button" class="singleButton sendRecovery" value="Enviar nova senha">

				<p class="byItself alert">Email alterado com sucesso!</p>

			</div>

		</div>
    </div>
    
    <?php include_once("includes/html/wrapper.php") ?>
	
</body>
</html>