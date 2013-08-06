<?php
	include_once("includes/check/login.php");
?>

<?php include_once("includes/html/header.php") ?>
<body class="deadNotifications">
	<?php include_once("includes/html/bar.php") ?>	
	<div id="content">

		<div id="registerContent" class="pageContent">
		
			<div class="titleContent">Cadastro</div>
					
			<div class="boardContent">
				<div class="boardContentInnerWrapper">
					
					<div class="pageContentBox">
					
						<div class="registrationConflict">
							<p><img src="images/64-Alert-2.png" alt="Alert" />Aparentemente elas já estavam cadastradas em nosso banco de dados.</p>
						</div>
					
						<div class="registrationComplete">
							<p><img src="images/32-Check.png" alt="Check" />Seu cadastro foi concluído com sucesso!</p>
						</div>
						
						<div class="registrationFailed">
							<p><img src="images/32-Cross.png" alt="Cross" />Hum, seus dados ainda não foram salvos. Revise-os e tente novamente.</p>
							<ul class="navigator">
								<a href="location.php"><li>Localização <span class="navigatorHint navigatorHintRight">Anterior</span></li></a>
							</ul>
						</div>
						
						<div class="box informationBox">
							<p class="informationTitle">Informações gerais</p>
							
							<p class="firstParagraph">Antes de mais nada, <b>seja bem-vindo ao InEvent!</b> Nossa plataforma foi criada para que você, diretor de GP ou RH, pudesse oferecer o melhor serviço para acompanhar quando os membros da empresa estiveram no local.</p>
							
							<p>Nosso sistema funciona preferencialmente no <b>Google Chrome</b>, atualmente o melhor navegador do mercado. Se os computadores de seu restaurante ainda não o tem instalado, <a href="http://www.google.com/chrome" target="_blank">clique aqui para baixar</a>.</p>
							
							<p>E sempre que precisar de qualquer ajuda, consulte nossa central de suporte. Nós levamos seu negócio muito a sério e, por isso, nós nunca lhe deixaremos na mão.</p>
							
							<p class="signature">Obrigado, <br />Diretoria do InEvent</p>
							
							<!-- <p class="reminder">As informações abaixo também foram enviadas para seu email.</p> -->
						</div>
					</div>
					
				</div>
			</div>

		</div>
    </div>
    
    <?php include_once("includes/html/wrapper.php") ?>
</body>
</html>