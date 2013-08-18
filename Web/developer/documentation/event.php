<div class="documentationBox">
    <h2>Evento</h2>
    
    <p>Para cada evento, podemos informar quais as pessoas e atividades que estão ocorrendo dentro do mesmo. Cada um recebe um identificador <i>eventID</i>, o que lhes permite acessar suas informações, assim como adicionar novas pessoas ou ver suas atividades.</p>
    
    <h3 class="documentationHeader">Push</h3>
    
    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>event/ : <b>eventID</b></span>
            <span><img src="../images/64-Archive.png" alt="Channel">event/<b>eventID</b></span>
        </p>
        <p class="documentFunctionDescription">Requisita a validação do evento <i>eventID</i>.</p>
    </div>

    <h3 class="documentationHeader">Funções</h3>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>event.requestEnrollment(<b>tokenID</b>, <b>eventID</b>, <b>personID</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=event.requestEnrollment&tokenID=$tokenID&eventID=1&personID=null">
        </p>

        <p class="documentFunctionDescription">Solicita a entrada da pessoa <i>personID</i> no evento <i>eventID</i>. Se a pessoa <i>personID</i> não for especificada ou o <i>tokenID</i> fornecido não tiver permissão para enviar para a pessoa <i>personID</i>, será utilizada a pessoa associada ao <i>tokenID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
            <p><b>personID</b><sub>GET</sub> : id da pessoa </p>
        </div>
    </div>
    
    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>event.approveEnrollment(<b>tokenID</b>, <b>requestID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=event.approveEnrollment&tokenID=$tokenID&requestID=1">
        </p>

        <p class="documentFunctionDescription">Aprova a solicitação <i>requestID</i> para entrada da pessoa.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>requestID</b><sub>GET</sub> : id da requisição de entrada </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>event.grantPermission(<b>tokenID</b>, <b>eventID</b>, <b>personID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=event.grantPermission&tokenID=$tokenID&eventID=1&personID=1">
        </p>

        <p class="documentFunctionDescription">Concede direitos de organizador para a pessoa <i>personID</i> no evento <i>eventID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
            <p><b>personID</b><sub>GET</sub> : id da pessoa </p>
        </div>
    </div>
    
    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>event.revokePermission(<b>tokenID</b>, <b>eventID</b>, <b>personID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=event.revokePermission&tokenID=$tokenID&eventID=1&personID=1">
        </p>

        <p class="documentFunctionDescription">Revoga os direitos de organizador para a pessoa <i>personID</i> no evento <i>eventID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
            <p><b>personID</b><sub>GET</sub> : id da pessoa </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>event.getPeople(<b>tokenID</b>, <b>eventID</b>, <b>selection</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=event.getPeople&tokenID=$tokenID&eventID=1&selection=all">
        </p>

        <p class="documentFunctionDescription">Retorna todas as pessoas que solicitaram entrar no evento <i>eventID</i>, filtradas por uma seleção <i>selection</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
            <p><b>selection</b><sub>GET</sub> : quem irá ao evento, podendo ser filtradas em aprovadas <i>approved</i>, negadas <i>denied</i>, não avaliadas <i>unseen</i> e todas <i>all</i></p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>event.getActivities(<b>eventID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=event.getActivities&eventID=1">
        </p>

        <p class="documentFunctionDescription">Retorna todas as atividades do evento <i>eventID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
        </div>
    </div>
    
    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>event.getSchedule(<b>tokenID</b>, <b>eventID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=event.getSchedule&tokenID=$tokenID&eventID=1">
        </p>

        <p class="documentFunctionDescription">Retorna todas o cronograma da pessoa com <i>tokenID</i> no evento <i>eventID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
        </div>
    </div>

</div>