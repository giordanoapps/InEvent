<?php
	include_once("includes/check/login.php");
	
	if (!$core->auth) logout();
	if (!$core->workAtEvent) logout();
?>

<?php include_once("includes/html/header.php") ?>
<body>
	<?php include_once("includes/html/bar.php") ?>
	<div id="content">

		<div id="peopleContent" class="pageContent fullPageContent">
			
			<div class="placerContent">
				<?php printScheduleForEvent($core->eventID); ?>
			</div>
			
			<div class="boardContent">

				<div class="menuContent">

					<!-- ToolBox Enroll People -->
					<div class="toolBoxOptions toolBoxOptionsEnrollPerson">
						<input type="text" placeholder="Nome completo" class="name">
						<input type="text" placeholder="Email" class="email">
						<input type="button" value="Criar" class="singleButton">
					</div>

					<!-- ToolBox Email -->
					<div class="toolBoxOptions toolBoxOptionsMail">
						<textarea name="mail"></textarea>
						<input type="text" placeholder="Qual o template que deseja enviar para todos os selecionados na lista?" class="template">
						<input type="button" value="Enviar" class="singleButton">
					</div>

					<!-- ToolBox Import -->
					<div class="toolBoxOptions toolBoxOptionsImport">
						<p class="inputHeader">Importar participantes</p>
						
						<p class="dropDetailedBox">Instruções</p>
						<div class="detailedBox">
							<p>Para adicionar uma lista de participantes a partir de um arquivo Excel <b>2007</b>, crie as seguintes colunas dentro de sua planilha:</p>
							
							<ul class="rotatedList">
								<li>
									<span class="title">coluna <b>A</b></span>
									<span class="description">Nome do participante</span>
								</li>
								<li>
									<span class="title">coluna <b>B</b></span>
									<span class="description">Email do participante</span>
								</li>
							</ul>
							<img src="images/emailList.png" alt="Colunas necessárias" title="Colunas que devem aparecer na planilha do Excel">
							
							<p>Após isso, para cada linha na planilha, adicionaremos um novo participante a seu evento.</p>
						</div>
						
						<div class="bottom">
							<p class="text">Com qual <b class="magicUnderline magicUnderlineSheet">planilha</b> deseja adicionar novos participantes?</p>
							<div class="file-uploader interactive"></div>
							<div class="action">
								<input type="button" value="Adicionar" class="singleButton">
							</div>
						</div>
					</div>

					<!-- ToolBox Filter -->
					<div class="toolBoxOptions toolBoxOptionsFilter">
						<p>Quais pessoas deseja selecionar?</p>
						<select name="filterOptions" id="filterOptions">
							<option value="all" selected="selected">Todas</option>
							<option value="present">Presentes</option>
							<option value="paid">Pagas</option>
							<option value="approved">Aprovadas</option>
							<option value="denied">Reprovadas</option>
						</select>
					</div>

					<!-- Tool Triggers -->
					<div class="toolBox">
						<div class="toolBoxPeople">
							<div class="toolBoxLeft">
								<img src="images/64-Box-Outgoing-2.png" alt="Exportar" title="Exportar os dados para uma planilha" class="toolExport"/>
								<img src="images/64-Mail.png" alt="Email" title="Exportar o email todas as pessoas para o formato de envio do Gmail" class="toolMail"/>
								<img src="images/64-Shuffle.png" alt="Aleatório" title="Escolher uma pessoa aleatória" class="toolRandom"/>
							</div>
							<div class="toolBoxLeft editingToolBox">
								<img src="images/64-Users.png" alt="Pessoa" title="Adicionar nova pessoa à atividade" class="toolPerson"/>
								<img src="images/64-Box-Incoming-2.png" alt="Importar" title="Importar os dados a partir de uma planilha" class="toolImport"/>
							</div>
							
							<div class="toolBoxRight">
								<img src="images/64-Blocks-_-Images.png" alt="Filtros" title="Filtrar a lista em determinada categoria" class="toolFilter"/>
								<img src="images/32-Pencil-_-Edit.png" alt="Preferências" title="Entrar no modo de edição" class="toolPreferences"/>
							</div>
							<div class="toolBoxRight editingToolBox">
								<input type="button" name="Finalizar" value="Finalizar" title="Finalizar o modo de edição" class="toolDone toolBoxButton submitButton" />
							</div>
						</div>
					</div>
				</div>

				<div class="realContent">
					<?php printPeopleAtActivity(getPeopleAtActivityQuery(0)) ?>
				</div>
				
			</div>
		</div>
    </div>
	
	<?php include_once("includes/html/wrapper.php") ?>
	
</body>
</html>