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
					
				<p class="byItself">Me diga seu email para adicionar a nossa lista de emails.</p>

				<input type="text" class="email" name="email" placeholder="Digite seu email">

				<input type="button" class="singleButton subscribe" value="Receber emails">

				<p class="byItself conflict">Email já estava adicionado.</p>

				<p class="byItself alert">Email adicionado com sucesso.</p>

			</div>

		</div>
    </div>
    
    <?php include_once("includes/html/wrapper.php") ?>
	
</body>
</html>