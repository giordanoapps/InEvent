<?php
	include_once("includes/check/login.php");
?>
<?php include_once("includes/html/header.php") ?>
<body>
	<?php include_once("includes/html/bar.php") ?>
	<div id="content">
	
		<div id="homeContent" class="pageContent">
		
			<article class="section">
				
				
				
			</article>
			
			<article class="section">
				<div class="header">
					<p class="title">InEvent integrada</p>
					<p class="description">Controle a presença de todos os membros</p>
				</div>
				
				<div class="masterBlock">
					<div class="leftBlock coolBox">
						<ul>
							<li>
								<img src="images/64-Pencil.png" alt="Edit"/>
								<div class="text">
									<p class="title">Edite <i>on the go</i></p>
									<p class="description">Altere os horários de plantão de qualquer membro rapidamente.</p>
								</div>
							</li>
							<li>
								<img src="images/64-Text-Documents.png" alt="Copy"/>
								<div class="text">
									<p class="title">Mantenha a consistência</p>
									<p class="description">Toda semana, copie a tabela de plantões e altere apenas o necessário.</p>
								</div>
							</li>
							<li>
								<img src="images/64-Books.png" alt="Review"/>
								<div class="text">
									<p class="title">Revise as faltas</p>
									<p class="description">Avalie as justificativas de falta em um clique.</p>
								</div>
							</li>
							<li>
								<img src="images/32-Favorite.png" alt="Favorite">
								<div class="text">
									<p class="title">Autorize os pontos de acesso</p>
									<p class="description">Escolha onde seus membros podem entrar no plantão.</p>
								</div>
							</li>
							<li>
								<img src="images/64-Bended-Arrow-Left.png" alt="Shift">
								<div class="text">
									<p class="title">Histórico simplificado</p>
									<p class="description">Avance entre todas as semanas em razão de milisegundos!</p>
								</div>
							</li>
							
						</ul>
					</div>
					
					<div class="rightBlock">
						<img class="promoImage" src='images/demo/presence2.png' alt="Presence demo" />
					</div>
				</div>
				
				<div class="coolBoxSelfish thumbs">
					<div class="header">
						<p class="title">Uma cor para cada turno</p>
						<p class="description">Edição de turno simples e rápida, em apenas um clique!</p>
					</div>
					
					<div class="upperBox">
						<img src="images/64-Pencil.png" alt="Edit" />
					</div>
					
					<div class="diagonalBox">
						<img src="images/64-Bended-Arrow-Left.png" alt="Arrow" />
					</div>
				
					<ul class="membersOnShift">        
				        <li>
				        	<div class="photoThumb black">
					            <div class="shadow">
					                <img src="images/fotos/caricatura1.jpg" alt="Foto do Membro">
					            </div>
					            
					            <div class="dock">
					                <ul>
					                    <li class="review tool">
					                    	<img src="images/48-paper-airplane.png" id="paperAirplane" alt="Send Explanation">
					                    </li>
					                    <li class="edit tool">
					                    	<img src="images/64-Pencil.png" alt="Editar">
					                    </li>
					                    <li class="remove tool">
					                    	<img src="images/32-Cross.png" alt="Remover">
					                    </li>
					                </ul>
					            </div>
							</div>
							<p class="title">Preto</p>
							<p class="description">Turno já pode ser aberto!<br /><br /></p>
				        </li>
				        <li>
				        	<div class="photoThumb yellow">
					            <div class="shadow">
					                <img src="images/fotos/caricatura2.jpg" alt="Foto do Membro">
					            </div>
					            
					            <div class="dock">
					                <ul>
					                    <li class="review tool">
					                    	<img src="images/48-paper-airplane.png" id="paperAirplane" alt="Send Explanation">
					                    </li>
					                    <li class="edit tool">
					                    	<img src="images/64-Pencil.png" alt="Editar">
					                    </li>
					                    <li class="remove tool">
					                    	<img src="images/32-Cross.png" alt="Remover">
					                    </li>
					                </ul>
					            </div>
					        </div>
					        <p class="title">Amarelo</p>
					        <p class="description">Turno foi aberto com sucesso.<br /><br /></p>
				        </li>
				        <li>
				        	<div class="photoThumb green">
					            <div class="shadow">
					                <img src="images/fotos/caricatura3.jpg" alt="Foto do Membro">
					            </div>
					            
					            <div class="dock">
					                <ul>
					                    <li class="review tool">
					                    	<img src="images/48-paper-airplane.png" id="paperAirplane" alt="Send Explanation">
					                    </li>
					                    <li class="edit tool">
					                    	<img src="images/64-Pencil.png" alt="Editar">
					                    </li>
					                    <li class="remove tool">
					                    	<img src="images/32-Cross.png" alt="Remover">
					                    </li>
					                </ul>
					            </div>
				            </div>
				            <p class="title">Verde</p>
				            <p class="description">Turno foi aberto e fechado com sucesso.</p>
				        </li>
				        <li>
				        	<div class="photoThumb red">
					            <div class="shadow">
					                <img src="images/fotos/caricatura4.jpg" alt="Foto do Membro">
					            </div>
					            
					            <div class="dock">
					                <ul>
					                    <li class="review tool">
					                    	<img src="images/48-paper-airplane.png" id="paperAirplane" alt="Send Explanation">
					                    </li>
					                    <li class="edit tool">
					                    	<img src="images/64-Pencil.png" alt="Editar">
					                    </li>
					                    <li class="remove tool">
					                    	<img src="images/32-Cross.png" alt="Remover">
					                    </li>
					                </ul>
					            </div>
					        </div>
					        <p class="title">Vermelho</p>
					        <p class="description">Turno não foi fechado com sucesso.</p>
				        </li>
				        <li>
				        	<div class="photoThumb silver">
					            <div class="shadow">
					                <img src="images/fotos/caricatura2.jpg" alt="Foto do Membro">
					            </div>
					            
					            <div class="dock">
					                <ul>
					                    <li class="review tool">
					                    	<img src="images/48-paper-airplane.png" id="paperAirplane" alt="Send Explanation">
					                    </li>
					                    <li class="edit tool">
					                    	<img src="images/64-Pencil.png" alt="Editar">
					                    </li>
					                    <li class="remove tool">
					                    	<img src="images/32-Cross.png" alt="Remover">
					                    </li>
					                </ul>
					            </div>
					        </div>
					        <p class="title">Cinza</p>
					        <p class="description">Turno no futuro ou sem permissão para vê-lo.</p>
				        </li>
			        </ul>
				</div>
				
			</article>
				
			<!-- <article class="section">
				<div class="header">
					<p class="title">Exponha seus projetos</p>
					<p class="description">Gerencie os projetos de sua empresa</p>
				</div>
				
				<div class="masterBlock">
					<div class="leftBlock">
						<img class="promoImage" src='images/demo/projects.png' alt="Projetos demo" />
					</div>
					
					<div class="rightBlock coolBox">
						<ul>
							<li>
								<img src="images/64-Pencil.png" alt="Edit"/>
								<div class="text">
									<p class="title">Rápidas edições</p>
									<p class="description">Altere as informações em instantes.</p>
								</div>
							</li>
							<li>
								<img src="images/50-photos.png" alt="Photos"/>
								<div class="text">
									<p class="title">Escolha uma foto</p>
									<p class="description">Seu projeto com uma imagem para rápida assimilição.</p>
								</div>
							</li>
							<li>
								<img src="images/50-calendar.png" alt="Details">
								<div class="text">
									<p class="title">Detalhe suas informações</p>
									<p class="description">Use os campos adequados para uma maior eficiência.</p>
								</div>
							</li>
							<li>
								<img src="images/64-Users.png" alt="Users">
								<div class="text">
									<p class="title">Indique as pessoas</p>
									<p class="description">Mostre em seu projeto quem está atualmente associado com ele.</p>
								</div>
							</li>
							<li>
								<img src="images/50-screen.png" alt="Display"/>
								<div class="text">
									<p class="title">Visualize seus projetos</p>
									<p class="description">Escolha a maneira para dispor seus projetos.</p>
								</div>
							</li>
						</ul>
					</div>
				</div>

			</article> -->
				
			<article class="section">
				<div class="header">
					<p class="title">Valorize seus membros</p>
					<p class="description">Cartões pessoais dos membros de sua equipe</p>
				</div>
				
				<div class="masterBlock">
					<div class="leftBlock coolBox">
						<ul>
							<li>
								<img src="images/64-Address-Book-5.png" alt="Contacts"/>
								<div class="text">
									<p class="title">Acesso aos contatos</p>
									<p class="description">Rapidamente encontre os contatos dos membros.</p>
								</div>
							</li>
							<li>
								<img src="images/64-Mail.png" alt="Email">
								<div class="text">
									<p class="title">Envie email</p>
									<p class="description">Utilizando o Gmail, envie emails diretamente!</p>
								</div>
							</li>
							<li>
								<img src="images/64-Pencil.png" alt="Edit"/>
								<div class="text">
									<p class="title">Edite <i>on the go</i></p>
									<p class="description">Modifique os dados em dois cliques.</p>
								</div>
							</li>
							<li>
								<img src="images/64-Power.png" alt="Active"/>
								<div class="text">
									<p class="title">Escolha os membros ativos</p>
									<p class="description">Saiba quem são os atuais e ex-membros.</p>
								</div>
							</li>
							<li>
								<img src="images/64-Locked-2.png" alt="Locked">
								<div class="text">
									<p class="title">Defina as permissões</p>
									<p class="description">Mantenha usuários selecionados para alterar o sistema.</p>
								</div>
							</li>
						</ul>
					</div>
					
					<div class="rightBlock">
						<img class="promoImage" src='images/demo/members.png' alt="Members demo" />
					</div>
				</div>
				
			</article>
				
			<article class="section">
				<div class="header">
					<p class="title">Ferramentas únicas</p>
					<p class="description">Ferramentas que complementam sua experiência</p>
				</div>
				
				<div class="masterBlock featureBoxMiniWrapper">
					<div class="featureBoxMini coolBox">
						<img src="images/64-Mail.png" alt="Notification">
						<div class="text">
							<p class="title">Central de Notificações</p>
							<p class="description">Notificações em tempo real para todos os usuários.</p>
						</div>
						<img class="promoImage mini floatLeft" src='images/demo/notification2.png' alt="Feature Notification" />
					</div>
					
					<div class="featureBoxMini coolBox">
						<img src="images/64-Cog.png" alt="Preferences">
						<div class="text">
							<p class="title">Menu de Preferências</p>
							<p class="description">Veja quem tem poders, altere sua senha e muito mais!</p>
						</div>
						<img class="promoImage mini floatLeft" src='images/demo/settings2.png' alt="Feature Settings" />
					</div>
					
					<div class="featureBoxMini coolBox">
						<img src="images/64-Magnifying-Glass-2.png" alt="Search">
						<div class="text">
							<p class="title">Barra para Pesquisa</p>
							<p class="description">Procurando algo? Use nossa barra de pesquisa e encontre na hora!</p>
						</div>
						<img class="promoImage mini floatLeft" src='images/demo/search2.png' alt="Feature Search" />
					</div>
				</div>
				
				<div style="clear: both;"></div>
		
			</article>
			
		</div>
			
	</div>
	
	<?php include_once("includes/html/wrapper.php") ?>
	
</body>
</html>