<?php
	include_once("includes/check/login.php");
?>

<?php include_once("includes/html/header.php") ?>
<body>
	<?php include_once("includes/html/bar.php") ?>	
	<div id="content">
	
		<div id="dataContent" class="pageContent">
			
			<div class="titleContent">Dados</div>
			
			<div class="boardContent">
				<div class="boardContentInnerWrapper">
					
					<div class="pageContentBox">
						<form method="post" action="#" class="dataForm">
						
							<?php
								$result = resourceForQuery(
									"SELECT
										`member`.`id`,
										`member`.`name`,
										`member`.`password`,
										`member`.`cpf`,
										`member`.`rg`,
										`member`.`usp`,
										`member`.`telephone`,
										`member`.`city`,
										`member`.`email`,
										`member`.`university`,
										`member`.`course`
									FROM
										`member`
									WHERE
										`member`.`id` = $core->memberID
								");
								$data = mysql_fetch_assoc($result);
							?>
							
							<!-- <p class="inputHeadline">Informe seus dados para o InEvent, a plataforma oficial da Semana SusIE!</p> -->

							<p class="inputHeader">Pessoa</p>
							
							<p class="fullWidth">
								<span class="inputTitle">Nome Completo:</span>
								<input
									type="text"
									name="name"
									id="name"
									class="name"
									value="<?php if ($core->auth) { echo $data["name"]; } ?>"
									placeholder="Nome Completo"
								/>
							</p>

							<p class="fullWidth">
								<span class="inputTitle">Email:</span>
								<input
									type="text"
									name="email"
									id="email"
									class="email"
									value="<?php if ($core->auth) { echo $data["email"]; } ?>"
									placeholder="Email"
								/>
							</p>

							<?php if ($core->auth) { ?>
							<p class="halfWidth">
								<span class="inputTitle">CPF:</span>
								<input
									type="text"
									name="cpf"
									id="cpf"
									class="cpf"
									value="<?php if ($core->auth) { echo $data["cpf"]; } ?>"
									placeholder="CPF"
								/>
							</p>
							<?php } ?>

							<?php if ($core->auth) { ?>
							<p class="halfWidth">
								<span class="inputTitle">RG:</span>
								<input
									type="text"
									name="rg"
									id="rg"
									class="rg"
									value="<?php if ($core->auth) { echo $data["rg"]; } ?>"
									placeholder="RG"
								/>
							</p>
							<?php } ?>

							<?php if ($core->auth) { ?>
							<p class="halfWidth">
								<span class="inputTitle">Universidade:</span>
								<input
									type="text"
									name="university"
									id="university"
									class="university"
									value="<?php if ($core->auth) { echo $data["university"]; } ?>"
									placeholder="Universidade"
								/>
							</p>
							<?php } ?>

							<?php if ($core->auth) { ?>
							<p class="halfWidth">
								<span class="inputTitle">USP:</span>
								<input
									type="text"
									name="usp"
									id="usp"
									class="usp"
									value="<?php if ($core->auth) { echo $data["usp"]; } ?>"
									placeholder="Número USP"
								/>
							</p>
							<?php } ?>
							
							<?php if (!$core->auth) { ?>
							<p class="halfWidth">
								<span class="inputTitle">Senha:</span>
								<input
									type="password"
									name="password"
									id="password"
									class="password"
									value=""
									placeholder="Senha"
								/>
							</p>
							<p class="halfWidth">
								<span class="inputTitle">Confirmar Senha:</span>
								<input
									type="password"
									name="passwordConfirm"
									id="passwordConfirm"
									class="passwordConfirm"
									value=""
									placeholder="Senha"
								/>
							</p>
							<?php } ?>
							
							<div class="checkBoxWrapper">
								<p>
									<input
										type="checkbox"
										name="agreement"
										id="agreement"
										class="agreement"
										<?php if ($core->auth) { ?> checked="true" disabled="disabled" <?php } ?>
									/>
									<span class="agreementTitle">
										Li e estou de acordo com os <a href="terms.php" target="_blank">Termos de Uso do InEvent</a>.
									</span>
								</p>
							</div>
						</form>

						<!-- <div class="docsForm">
							<p class="inputHeadline">Finalize seu cadastro enviando o formulário abaixo:</p>

							<iframe
								class="docsFrame"
								src="https://docs.google.com/forms/d/1D8MmZ8va92XF6AqqsNRvzI-Rdv7xsg-3PQeHIsit90o/viewform?embedded=true&entry.1562333277=myName&entry.268295612&entry.1839222973=myEmail" 
								data-src="https://docs.google.com/forms/d/1D8MmZ8va92XF6AqqsNRvzI-Rdv7xsg-3PQeHIsit90o/viewform?embedded=true&entry.1562333277=myName&entry.268295612&entry.1839222973=myEmail" 
								width="760" height="500" frameborder="0" marginheight="0" marginwidth="0">Loading...</iframe>
						</div> -->
					
					</div>
					
					<?php if ($core->auth) { ?>
					<ul class="navigator">
						<a href="event.php" data-lock="yes"><li><span class="navigatorHint navigatorHintSave">Salvar</span></li></a>
					</ul>	
					<?php } else { ?>
					<ul class="navigator">
						<a href="register.php" data-lock="yes"><li><span class="navigatorHint navigatorHintRight">Próxima</span></li></a>
					</ul>
					<?php } ?>
					
				</div>
			</div>

		</div>
    </div>
    
    <?php include_once("includes/html/wrapper.php") ?>
</body>
</html>