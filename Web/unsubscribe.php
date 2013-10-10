<?php
	include_once("includes/check/login.php");
?>

<?php include_once("includes/html/header.php") ?>
<body class="deadNotifications">
	<?php include_once("includes/html/bar.php") ?>

	<div id="content">
		<div id="forgotContent" class="pageContent">
			
			<div class="titleContent">Envio de emails</div>
			
			<div class="boardContent">
					
				<p class="byItself">Me diga seu email e não mais lhe enviaremos emails.</p>

				<input type="text" class="email" name="email" placeholder="Digite seu email atualmente cadastrado">

				<input type="button" class="singleButton unsubscribe" value="Cancelar emails">

				<p class="byItself conflict">Email já estava fora da lista.</p>

				<p class="byItself alert">Email retirado com sucesso.</p>

			</div>

		</div>
    </div>
    
    <?php include_once("includes/html/wrapper.php") ?>
	
</body>
</html>