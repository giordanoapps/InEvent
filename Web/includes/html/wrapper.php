<?php if ($core->auth) { ?>

	<iframe name="excelFrame" id="excelFrame" width="320" height="0" frameborder="0" src="about:blank"></iframe>

	<div id="wrapper">

		<div class="bar bottom">
			<ul class="leftBar">
				<li>&reg;<a target="_blank" href="http://estudiotrilha.com.br">Estúdio Trilha 2013</a> &nbsp;&nbsp;&nbsp; Todos os direitos reservados</li>
			</ul>
			
			<ul class="rightBar">
				<li><a target="_blank" href="https://www.facebook.com/pages/In-Event/150798025113523">Curta nossa página no Facebook!</a></li>
				<!-- <li><a href="mailto:contato@estudiotrilha.com.br">Sugestões? Problemas?</a></li> -->
			</ul>
		</div>
		
		<div class="boxes">
			<div class="loadingBox">
				<img src="images/128-loading.gif" class="loadingBike" alt="Carregando..." />
			</div>
		
			<div class="errorBox">
				<span>Tentando recuperar a conexão! Alterações podem não ter sido salvas.</span>
				<a href="#" onClick="window.location.reload();return false;">Recarregar página</a>
			</div>

			<div class="notificationBox">
				<ul></ul>
			</div>
		</div>
		
	</div>
</div>

<?php } else { ?>

	<div id="wrapper">
		<div class="bar bottom">
			<ul class="leftBar">
				<li>&reg;<a target="_blank" href="http://estudiotrilha.com.br">Estúdio Trilha 2013</a> &nbsp;&nbsp;&nbsp; Todos os direitos reservados</li>
			</ul>
			
			<ul class="rightBar">
				<li><a target="_blank" href="https://www.facebook.com/pages/In-Event/150798025113523">Curta nossa página no Facebook!</a></li>
				<!-- <li><a href="mailto:contato@estudiotrilha.com.br">Sugestões? Problemas?</a></li> -->
			</ul>
		</div>
	</div>

<?php } ?>