<?php
	include_once("includes/check/login.php");
?>
<?php include_once("includes/html/header.php") ?>
<body>
	<?php include_once("includes/html/bar.php") ?>
	<div id="content">
	
		<div id="homeContent" class="pageContent" tabindex="0">

			<div class="upperDeck"></div>

			<div class="middlePort">
				<div class="trigger">
					<img src="images/32-Cross-Light.png" class="close" alt="Close the app deck">
					<img src="images/64-iPhone-4.png" class="open" alt="Show the app deck">
				</div>
				<div class="header">
					<p class="title">Aplicativo nativo</p>
					<p class="description">Baixe nosso aplicativo, disponível para iOS e Android.</p>
				</div>
				<ul>
					<li>
						<a target="_blank" href="https://itunes.apple.com/us/app/inevent/id687142023?ls=1&mt=8">
							<img src="images/appstore-black.png" alt="Download from App Store">
						</a>
					</li>
					<li>
						<a target="_blank" href="https://play.google.com/store/apps/details?id=com.estudiotrilha.inevent">
							<img src="images/googleplay-grey.png" alt="Download from Google Play">
						</a>
					</li>
				</ul>
			</div>
		
			<article class="section" style="	background-image: url(uploads/sao_paulo.jpg);">
				
				<div class="deck" onclick="">
					<div class="leftBox">
						<img src="images/64-Marker.png" alt="Map">
						<p class="title bigTitle">InEvent</p>
					</div>

					<div class="rightBox">
						<p class="description">Um aplicativo que traz para dentro do seu evento um fluxo constante de interações. Tenha uma linha do tempo baseada em suas escolhas, acompanhe cada atividade com um cartão exclusivo e receba alterações de horários instantâneas.</p>
					</div>
				</div>
				
			</article>

			<article class="section" style="	background-image: url(uploads/salvador.jpg);">
				
				<div class="deck" onclick="">
					<div class="leftBox">
						<img src="images/64-Footprints.png" alt="Map">
						<p class="title">Linha do Tempo personalizada</p>
					</div>

					<div class="rightBox">
						<p class="description">Para cada participante do evento, será criada uma linha do tempo exclusiva para ele! Será baseada nas palestras e viagens que gostaria de ir assim como atividades pré-estabelecidas pela organização, como horário para almoço ou <i>coffee-break</i>.</p>
					</div>
				</div>
				
			</article>

			<article class="section" style="	background-image: url(uploads/rio.jpg);">
				
				<div class="deck" onclick="">
					<div class="leftBox">
						<img src="images/64-Map.png" alt="Map">
						<p class="title">Mapas integrados</p>
					</div>

					<div class="rightBox">
						<p class="description">Os participantes agora terão um acompanhante pessoal, o mapa do local do evento! Nele poderá identificar a localização de cada atividade, assim como espaços comuns, como banheiros e restaurantes.</p>
					</div>
				</div>
				
			</article>

			<article class="section" style="	background-image: url(uploads/brasilia.jpg);">
				
				<div class="deck" onclick="">
					<div class="leftBox">
						<img src="images/64-Flip-Clock.png" alt="Clock">
						<p class="title">Horário flexível</p>
					</div>

					<div class="rightBox">
						<p class="description">Alterar o horário do evento nunca foi tão simples! Ocorreu algum imprevisto de última hora? Basta alterar o cronograma e todos os participantes receberão em seu dispositivo móvel um aviso sobre a alteração.</p>
					</div>
				</div>
				
			</article>
			
		</div>
			
	</div>
	
	<?php include_once("includes/html/wrapper.php") ?>
	
</body>
</html>