<div id="header">
	<div class="barWrapper">	
	
	<?php if ($core->auth) { ?>
		
		<div class="bar top">
			<ul class="leftBar">
				<a href="home.php"><li>Home</li></a>
				<a href="presence.php"><li>Presença</li></a>
				<!-- <a href="projects.php"><li>Projetos</li></a> -->
				<a href="members.php"><li>Membros</li></a>
				<!-- <a href="clients.php"><li>Clientes</li></a> -->
				<!-- <a href="consultants.php"><li>Consultores</li></a> -->
				<!-- <a href="groups.php"><li>Grupos</li></a> -->
			</ul>
			
			<ul class="rightBar">
				
				<li onclick="" class="notificationsInfo"><span class="notificationsInfoCount">0</span> <img class="downArrow" src="images/16-br-down.png" alt="Down arrow" /></li>
				
				<li onclick="" class="notifications barContainer">
					<div class="notificationsHeader"></div>
				
					<div class="notificationsContent">
						<ul></ul>
					</div>
					
					<div class="notificationsBottom">
						<ul><li class="notificationLoadExtra">Carregar mais notificações ...</li></ul>
					</div>
				</li>
			
				<li onclick="" class="userSettingsInfo">Olá <?php echo truncateName($core->name, 15) ?>! <img class="downArrow" src="images/16-br-down.png" alt="Down arrow" /></li>
				
				<li onclick="" class="userSettingsMenu barContainer">
					<ul>
						<!-- SUPER USERS -->
						<li class="powerUsersItem firstItem">
							<span class="firstItemText">Usuários com poderes</span>
							<ul>
							
							<?php if ($core->permission >= 10) { ?>

								<li class="powerUsersList firstAnchor barContainer collectionBox">
									<ul>
										<li class="powerUsersListAnchor secondItem">
											<span class="secondItemText">Adicionar usuário</span>
											<ul>
												<li class="powerUsersAddList secondAnchor barContainer collectionSelected">
													<ul>
														<li class="powerUsersSearch">
															<input
																type="text"
																name="powerUsersSearchInput"
																class="powerUsersSearchInput collectionSelectedInput"
																value=""
																placeholder="Quem?"
																data-table="member"
															/>
														</li>
													</ul>
													<ul class="collectionOptions barContainer">
						
													</ul>
												</li>
												<li class="powerUsersActiveUsers collectionSelectedList">
													<ul>
														<?php // $core->printPowerUsers() ?>
													</ul>
												</li>
											</ul>
										</li>
									</ul>
								</li>
						
							<?php } else { ?>
							
								<li class="powerUsersList firstAnchor powerUsersActiveUsers barContainer"></li>
							
							<?php } ?>
						
							</ul>
						</li>

						<!-- USER SETTINGS -->
						<li class="userSettingsItem firstItem">
							<span class="firstItemText">Preferências do usuário</span>
							<ul>
								<li class="firstAnchor barContainer">
									<ul>
										<li class="secondItem">
											<span class="secondItemText">Trocar senha</span>
											<ul>
												<li class="secondAnchor barContainer">
													<ul>
														<form method="post" action="#">
															<li><input type="password" name="oldPassword" class="oldPassword" placeholder="Senha atual" tabindex="1"/></li>
															<li><input type="password" name="newPassword" class="newPassword" placeholder="Nova senha" tabindex="2"/></li>
															<li class="saveButton">Trocar</li>
														</form>
													</ul>
												</li>
											</ul>
										</li>
									</ul>
								</li>
							</ul>
						</li>
						
						<a href="logout.php"><li class="logoutButton">Logout</li></a>
						
					</ul>
				</li>
			</ul>
		</div>
	
	<?php } else { ?>
	
		<div class="bar top loginBar">
			<ul class="leftBar">
				<a href="home.php"><li>Presença</li></a>
			</ul>
			
			<ul class="rightBar">
			
				<li onclick="" class="userLoginLeading first">Entrar!</li>
				
				<li onclick="" class="userLoginBox secondary">
				
					<div class="facebookBox">
						<img src="images/facebookButton.png" name="" id="" />
						<!-- <fb:login-button show-faces="true" width="200" max-rows="1"></fb:login-button> -->
					</div>
					
					<div class="middleLine">OU</div>
					
					<div class="memberBox">
						<form method="post" action="home.php">
							<input type="text" placeholder="Nome"  name="name"/>
							<input type="password" placeholder="Senha" name="password"/>
							<input type="submit" class="singleButton" value="Entrar!" />
						</form>
					</div>

				</li>
				
			</ul>
		</div>
		
	<?php } ?>
	
	</div>
</div>