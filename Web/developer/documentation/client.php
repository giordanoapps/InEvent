<!-- CLIENTES -->
<div class="documentationBox">
    <h2>Clientes</h2>
    
    <p>O conteúdo abaixo é referente a ferramenta Clientes.</p>
    
    <div class="documentationFunctionBox">
        <p class="documentFunctionName">client.getNumberOfClients(<b>tokenID</b>)</p>

        <p class="documentFunctionDescription">Retorna o número de clientes cadastrados para o token fornecido.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : seu id recebido no início da sessão</p>

        </div>

    </div>


    <div class="documentationFunctionBox">
        <p class="documentFunctionName">client.getClients(<b>tokenID</b>)</p>

        <p class="documentFunctionDescription">Retorna a lista dos clientes registrados para o token fornecido.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : seu id recebido no início da sessão</p>

        </div>

    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">client.getSingleClient(<b>tokenID</b>, <b>clientID</b>)</p>

        <p class="documentFunctionDescription">Retorna o JSON de um cliente baseado em seu ID.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : seu id recebido no início da sessão</p>
            <p><b>clientID</b><sub>GET</sub> : id do cliente</p>

        </div>

    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">client.createClient(<b>tokenID</b>, <b>client</b>)</p>

        <p class="documentFunctionDescription">Esta função registra um novo cliente para essa empresa.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : seu id recebido no início da sessão</p>
            <p><b>client</b><sub>POST</sub> : objeto JSON com as informações do novo cliente</p>

        </div>

    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">client.updateClient(<b>tokenID</b>, <b>client</b>)</p>

        <p class="documentFunctionDescription">Esta função atualiza as informações de um cliente já existente.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : seu id recebido no início da sessão</p>
            <p><b>client</b><sub>POST</sub> : objeto JSON com as informações atualizadas do cliente</p>

        </div>

    </div>

</div>