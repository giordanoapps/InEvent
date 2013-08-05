<!-- GRUPOS -->
<div class="documentationBox">
    <h2>Grupos</h2>

    <p>O conteúdo abaixo é referente a ferramenta Grupos</p>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">group.getNumberOfGroups(<b>tokenID</b>)</p>

        <p class="documentFunctionDescription">Retorna o número de grupos cadastrados para o token fornecido.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : seu id recebido no início da sessão</p>

        </div>

    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">group.getGroups(<b>tokenID</b>)</p>

        <p class="documentFunctionDescription">Retorna a lista dos grupos registrados para o token fornecido.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : seu id recebido no início da sessão</p>

        </div>

    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">group.getSingleGroup(<b>tokenID</b>, <b>groupID</b>)</p>

        <p class="documentFunctionDescription">Retorna as informações de um grupo específico baseado em seu ID.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : seu id recebido no início da sessão</p>
            <p><b>groupID</b><sub>GET</sub> : id do grupo</p>

        </div>
    
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">group.createGroup(<b>tokenID</b>, <b>group</b>)</p>
        
        <p class="documentFunctionDescription">Esta função cria um novo grupo para essa empresa.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : seu id recebido no início da sessão</p>
            <p><b>group</b><sub>GET</sub> : objeto JSON com as informações do novo grupo</p>

        </div>

    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">group.updateGroup(<b>tokenID</b>, <b>group</b>)</p>

        <p class="documentFunctionDescription">Esta função atualiza as informações de um grupo já existente.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : seu id recebido no início da sessão</p>
            <p><b>group</b><sub>GET</sub> : objeto JSON com as informações a serem atualizadas</p>

        </div>

    </div>

</div>