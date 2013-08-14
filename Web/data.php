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
										`member`.`telephone`,
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
							
							<p class="inputHeader">Pessoa</p>
							
							<p class="fullWidth">
								<span class="inputTitle">Nome Completo:</span>
								<input
									type="text"
									name="name"
									id="name"
									class="name"
									<?php if ($core->auth) { ?> readonly="readonly" <?php } ?>
									value="<?php if ($core->auth) { echo $data["name"]; } ?>"
									placeholder="Nome Completo"
								/>
							</p>

							<p class="halfWidth">
								<span class="inputTitle">CPF:</span>
								<input
									type="text"
									name="cpf"
									id="cpf"
									class="cpf"
									<?php if ($core->auth) { ?> readonly="readonly" <?php } ?>
									value="<?php if ($core->auth) { echo $data["cpf"]; } ?>"
									placeholder="CPF"
								/>
							</p>
							<p class="halfWidth">
								<span class="inputTitle">RG:</span>
								<input
									type="text"
									name="rg"
									id="rg"
									class="rg"
									<?php if ($core->auth) { ?> readonly="readonly" <?php } ?>
									value="<?php if ($core->auth) { echo $data["rg"]; } ?>"
									placeholder="RG"
								/>
							</p>
							
							<p class="halfWidth">
								<span class="inputTitle">Telefone:</span>
								<input
									type="text"
									name="telephone"
									id="telephone"
									class="telephone"
									<?php if ($core->auth) { ?> readonly="readonly" <?php } ?>
									value="<?php if ($core->auth) { echo $data["telephone"]; } ?>"
									placeholder="Telefone"
								/>
							</p>
							<p class="halfWidth">
								<span class="inputTitle">Email:</span>
								<input
									type="text"
									name="email"
									id="email"
									class="email"
									<?php if ($core->auth) { ?> readonly="readonly" <?php } ?>
									value="<?php if ($core->auth) { echo $data["email"]; } ?>"
									placeholder="Email"
								/>
							</p>

							<p class="halfWidth">
								<span class="inputTitle">Universidade:</span>
								<input
									type="text"
									name="university"
									id="university"
									class="university"
									value=""
									placeholder="Universidade"
								/>
							</p>
							<p class="halfWidth">
								<span class="inputTitle">Curso:</span>
								<input
									type="text"
									name="course"
									id="course"
									class="course"
									value=""
									placeholder="Curso"
								/>
							</p>
							
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

							<p class	="miniIntro">Caso seja aluno da USP, </p>

							<p class="halfWidth">
								<input
									type="usp"
									name="usp"
									id="usp"
									class="usp"
									value=""
									placeholder="Número USP"
								/>
							</p>

							<p>Caso seja aluno da USP e também curse Engenharia Aeronáutica, preencha o formulário complementar disponível em <a href="https://docs.google.com/forms/d/16EwOvoq24_b8P4LG9Pz7bgr5gVL9y9m3SoTekTxXYYw/viewform" target="_blank">https://docs.google.com/forms/d/16EwOvoq24_b8P4LG9Pz7bgr5gVL9y9m3SoTekTxXYYw/viewform</a>.</p>
							
							
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
								<p>
									<input
										type="checkbox"
										name="newsletter"
										id="newsletter"
										class="newsletter"
										<?php if ($core->auth) { ?> disabled="disabled" <?php } ?>
										checked="true"
									/>
									<span class="newsletterTitle">
										Desejo receber informações sobre novidades na plataforma (1 email por mês).
									</span>
								</p>
							</div>
						</form>
						
					</div>
					
					<?php if (!$core->auth) { ?>
					<ul class="navigator">
						<a href="register.php" data-lock	="yes"><li>Registro <span class="navigatorHint navigatorHintRight">Próxima</span></li></a>
					</ul>
					<?php } ?>
					
				</div>
			</div>

		</div>
    </div>
    
    <?php include_once("includes/html/wrapper.php") ?>
</body>
</html>