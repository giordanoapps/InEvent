<!-- PROJETOS -->
<div class="documentationBox">
	<h2>Projetos</h2>

	<p>O conteúdo abaixo é referente a ferramenta Projetos.</p>

	<div class="documentationFunctionBox">
		<p class="documentFunctionName">project.getNumberOfProjects(<b>tokenID</b>)</p>

		<p class="documentFunctionDescription">Retorna o número de projetos cadastrados para o token fornecido.</p>

		<div class="documentationFunctionParametersBox">
			<p><b>tokenID</b><sub>GET</sub> : seu id recebido no início da sessão</p>

		</div>

	</div>

	<div class="documentationFunctionBox">
        <p class="documentFunctionName">project.getProjects(<b>tokenID</b>)</p>

        <p class="documentFunctionDescription">Retorna a lista dos projetos registrados para o token fornecido.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : seu id recebido no início da sessão</p>

        </div>

    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">project.getSingleProject(<b>tokenID</b>, <b>projectID</b>)</p>

        <p class="documentFunctionDescription">Retorna informações de um projeto.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : seu id recebido no início da sessão</p>
            <p><b>projectID</b><sub>GET</sub> : id do projeto</p>

        </div>
    
    </div>
    
    <div class="documentationFunctionBox">
        <p class="documentFunctionName">project.getStates(<b>tokenID</b>)</p>

        <p class="documentFunctionDescription">Retorna todos os possíveis estados que um projeto pode ter.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : seu id recebido no início da sessão</p>

        </div>
    
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">project.createProject(<b>tokenID</b>, <b>project</b>)</p>
        
        <p class="documentFunctionDescription">Esta função cria um novo projeto para essa empresa.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : seu id recebido no início da sessão</p>
            <p><b>project</b><sub>GET</sub> : objeto JSON com as informações do novo projeto</p>

        </div>

    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">project.updateProject(<b>tokenID</b>, <b>project</b>)</p>
        
        <p class="documentFunctionDescription">Esta função atualiza as informações de um projeto já existente.</p>
        
        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : seu id recebido no início da sessão</p>
            <p><b>project</b><sub>GET</sub> : objeto JSON com as informações a serem atualizadas</p>

        </div>

    </div>

</div>