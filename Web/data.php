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
								$result = resourceForQuery("SELECT * FROM `company` WHERE `id`=$core->companyID");
								$data = mysql_fetch_assoc($result);
							?>
							
							<p class="inputHeader">Empresa</p>
							
							<p class="fullWidth">
								<span class="inputTitle">Nome:</span>
								<input
									type="text"
									name="companyName"
									id="companyName"
									class="companyName"
									<?php if ($core->auth) { ?> readonly="readonly" <?php } ?>
									value="<?php if ($core->auth) { echo $data["companyName"]; } ?>"
									placeholder="Nome Fantasia" />
							</p>
							
							<p class="fullWidth">
								<span class="inputTitle">Endereço:</span>
								<input
									type="text"
									name="address"
									id="address"
									class="address"
									<?php if ($core->auth) { ?> readonly="readonly" <?php } ?>
									value="<?php if ($core->auth) { echo $data["address"]; } ?>"
									placeholder="Endereço" />
							</p>
							
							<p class="thirdWidth">
								<span class="inputTitle">Cidade:</span>
								<input
									type="text"
									name="city"
									id="city"
									class="city"
									<?php if ($core->auth) { ?> readonly="readonly" <?php } ?> 
									value="<?php if ($core->auth) { echo $data["city"]; } ?>"
									placeholder="Cidade" />
							</p>
							<p class="thirdWidth">
								<span class="inputTitle">Estado:</span>
								<input
									type="text"
									name="state"
									id="state"
									class="state upperCase"
									<?php if ($core->auth) { ?> readonly="readonly" <?php } ?> 
									value="<?php if ($core->auth) { echo $data["state"]; } ?>"
									placeholder="Estado"
									maxlength="2"
									list="brazilStates"/>
							</p>
							<datalist id="brazilStates">
								<option value="AC">AC</option>  
								<option value="AL">AL</option>  
								<option value="AM">AM</option>  
								<option value="AP">AP</option>  
								<option value="BA">BA</option>  
								<option value="CE">CE</option>  
								<option value="DF">DF</option>  
								<option value="ES">ES</option>  
								<option value="GO">GO</option>  
								<option value="MA">MA</option>  
								<option value="MG">MG</option>  
								<option value="MS">MS</option>  
								<option value="MT">MT</option>  
								<option value="PA">PA</option>  
								<option value="PB">PB</option>  
								<option value="PE">PE</option>  
								<option value="PI">PI</option>  
								<option value="PR">PR</option>  
								<option value="RJ">RJ</option>  
								<option value="RN">RN</option>  
								<option value="RO">RO</option>  
								<option value="RR">RR</option>  
								<option value="RS">RS</option>  
								<option value="SC">SC</option>  
								<option value="SE">SE</option>  
								<option value="SP">SP</option>  
								<option value="TO">TO</option>  
							</datalist>					
							<p class="thirdWidth">
								<span class="inputTitle">CEP:</span>
								<input
									type="text"
									name="zipCode"
									id="zipCode"
									class="zipCode"
									<?php if ($core->auth) { ?> readonly="readonly" <?php } ?>
									value="<?php if ($core->auth) { echo $data["zipCode"]; } ?>"
									placeholder="CEP" />
							</p>

							<?php if (!$core->auth) { ?>
							<p class="inputHeader">Responsável</p>
													
							<p class="halfWidth">
								<span class="inputTitle">Nome:</span>
								<input
									type="text"
									name="bossName"
									id="bossName"
									class="bossName"
									value=""
									placeholder="Nome do Responsável"
								/>
							</p>
							<p class="halfWidth">
								<span class="inputTitle">Email:</span>
								<input
									type="text"
									name="bossEmail"
									id="bossEmail"
									class="bossEmail"
									value=""
									placeholder="Email do Responsável"
								/>
							</p>
							
							<p class="halfWidth">
								<span class="inputTitle">Senha:</span>
								<input
									type="password"
									name="bossPassword"
									id="bossPassword"
									class="bossPassword"
									value=""
									placeholder="Senha"
								/>
							</p>
							<p class="halfWidth">
								<span class="inputTitle">Confirmar Senha:</span>
								<input
									type="password"
									name="bossPasswordConfirm"
									id="bossPasswordConfirm"
									class="bossPasswordConfirm"
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
										Li e estou de acordo com os <a href="terms.php" target="_blank">Termos de Uso do Presença</a>.
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
						<a href="location.php" data-lock	="yes"><li>Localização <span class="navigatorHint navigatorHintRight">Próxima</span></li></a>
					</ul>
					<?php } ?>
					
				</div>
			</div>

		</div>
    </div>
    
    <?php include_once("includes/html/wrapper.php") ?>
</body>
</html>