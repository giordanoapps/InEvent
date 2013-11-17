<?php
	include_once("includes/check/login.php")
?>

<?php include_once("includes/html/header.php") ?>
<body>
	<?php include_once("includes/html/bar.php") ?>
	<div id="content">
		<div id="balconyContent" class="pageContent">
			<div class="boardContent">

				<div class="section person">
					<p class="title">Sobre você</p>
					<input type="text" class="name" name="name" placeholder="Qual seu nome?">
					<input type="text" class="email" name="email" placeholder="Qual seu email?">
					<input type="button" value="Cadastrar" class="singleButton">
				</div>

				<div class="section event">
					<p class="title">Seu evento</p>
					<input type="text" class="name" name="name" placeholder="Qual o nome?">
					<input type="text" class="nickname" name="nickname" placeholder="#hashtag">
					<input type="button" value="Próxima" class="singleButton">
				</div>

				<div class="section payment">
					<p class="title">Pagamento</p>
					<p class="information">Esse pagamento é processado diretamente pelo Mercado Pago, que irá utilizar o valor baseado no número de pessoas que estejam participando do evento.</p>
					<p class="value">
						<input type="text" class="number" placeholder="Pessoas"> x R$ <span class="unit">2,30</span> = R$ <span class="total">0,00</span>
					</p>
					<a href="#" target="_blank"><input type="button" value="Pagar" class="singleButton"></a>
				</div>
			
			</div>
		</div>
	</div>
	
	<?php include_once("includes/html/wrapper.php") ?>
	
</body>
</html>