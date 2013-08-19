<?php if ($core->auth) { ?>

	<div id="wrapper">
		<div class="bar bottom">
			<ul class="leftBar">
				<li>&reg;<a target="_blank" href="http://estudiotrilha.com.br">Estúdio Trilha 2013</a> &nbsp;&nbsp;&nbsp; Todos os direitos reservados</li>
			</ul>
			
			<ul class="rightBar">
				<li><a href="mailto:contato@estudiotrilha.com.br">Sugestões? Problemas?</a></li>
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
			<ul>
				<li>&reg;<a target="_blank" href="http://estudiotrilha.com.br">Estúdio Trilha 2013</a> &nbsp;&nbsp;&nbsp; Todos os direitos reservados</li>
			</ul>
		</div>
	</div>

<?php } ?>