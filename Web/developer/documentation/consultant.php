<!-- CONSULTORES -->
<div class="documentationBox">
    <h2>Consultores</h2>
    
    <p>O conteúdo abaixo é referente a ferramenta Consultores.</p>
    
    <div class="documentationFunctionBox">
        <p class="documentFunctionName">consultant.getNumberOfConsultants(<b>tokenID</b>)</p>

        <p class="documentFunctionDescription">Retorna o número de consultores cadastrados para o token fornecido.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : seu id recebido no início da sessão</p>

        </div>

    </div>


    <div class="documentationFunctionBox">
        <p class="documentFunctionName">consultant.getConsultants(<b>tokenID</b>)</p>

        <p class="documentFunctionDescription">Retorna a lista dos consultores registrados para o token fornecido.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : seu id recebido no início da sessão</p>

        </div>

    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">consultant.getSingleConsultant(<b>tokenID</b>, <b>consultantID</b>)</p>

        <p class="documentFunctionDescription">Retorna o JSON de um consultor baseado em seu ID.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : seu id recebido no início da sessão</p>
            <p><b>consultantID</b><sub>GET</sub> : id do consultor</p>

        </div>

    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">consultant.createConsultant(<b>tokenID</b>, <b>client</b>)</p>

        <p class="documentFunctionDescription">Esta função registra um novo consultor para essa empresa.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : seu id recebido no início da sessão</p>
            <p><b>consultant</b><sub>POST</sub> : objeto JSON com as informações do novo consultor</p>

        </div>

    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">consultant.updateConsultant(<b>tokenID</b>, <b>client</b>)</p>

        <p class="documentFunctionDescription">Esta função atualiza as informações de um consultor já existente.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : seu id recebido no início da sessão</p>
            <p><b>consultant</b><sub>POST</sub> : objeto JSON com as informações atualizadas do consultor</p>

        </div>

    </div>

</div>