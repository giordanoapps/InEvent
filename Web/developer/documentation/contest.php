<div class="documentationBox">
    <h2>Concurso</h2>
    
    <p>Ocasionalmente, ocorrem concursos dentro dos eventos realizados. Para estes casos, é possível controlar a inscrição de cada participante dentro do concurso, assim como checar a existência do envio do material.</p>

    <h3 class="documentationHeader">Funções</h3>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>contest.requestAddress(<b>tokenID</b>, <b>eventID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=contest.requestAddress&tokenID=$tokenID&eventID=1">
        </p>

        <p class="documentFunctionDescription">Solicita o endereço do recurso (imagem, vídeo, texto) enviado pela pessoa com token <i>tokenID</i> para o concurso no evento <i>eventID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>contest.informAddress(<b>tokenID</b>, <b>eventID</b>, <b>url</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=contest.informAddress&tokenID=$tokenID&eventID=1" data-post="url=url">
        </p>

        <p class="documentFunctionDescription">Informa o endereço do recurso (imagem, vídeo, texto) da pessoa com token <i>tokenID</i> para o concurso no evento <i>eventID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
            <p><b>url</b><sub>POST</sub> : endereço do recurso </p>
        </div>
    </div>

</div>