<div class="documentationBox">
    <h2>Atividade</h2>
    
    <p>Durante um evento, existem diversas atividades que se iniciam e ocorrem em períodos determinados de tempo. Cada uma recebe um identificador <i>activityID</i>, o que lhes permite acessar suas informações, assim como adicionar novas pessoas ou receber alterações em seus canais.</p>
    
    <h3 class="documentationHeader">Push</h3>
    
    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity/new : <b>activityID</b></span>
            <span><img src="../images/64-Archive.png" alt="Channel">event/<b>eventID</b></span>
        </p>
        <p class="documentFunctionDescription">Informa a criação da atividade <i>activityID</i> no evento <i>eventID</i>.</p>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity/update : <b>activityID</b></span>
            <span><img src="../images/64-Archive.png" alt="Channel">event/<b>eventID</b></span>
        </p>
        <p class="documentFunctionDescription">Informa a atualização da atividade <i>activityID</i> no evento <i>eventID</i>.</p>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity/remove : <b>activityID</b></span>
            <span><img src="../images/64-Archive.png" alt="Channel">event/<b>eventID</b></span>
        </p>
        <p class="documentFunctionDescription">Informa a remoção da atividade <i>activityID</i> no evento <i>eventID</i>.</p>
    </div>

    <h3 class="documentationHeader">Funções</h3>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.requestCheckIn(<b>tokenID</b>, <b>activityID</b>, <b>personID</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.requestCheckIn&tokenID=$tokenID&activityID=1&personID=null">
        </p>

        <p class="documentFunctionDescription">Solicita a entrada da pessoa <i>personID</i> na atividade <i>activityID</i>. Se a pessoa <i>personID</i> não for especificada ou o <i>tokenID</i> fornecido não tiver permissão para enviar para a pessoa <i>personID</i>, será utilizada a pessoa associada ao <i>tokenID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>activityID</b><sub>GET</sub> : id da atividade </p>
            <p><b>personID</b><sub>GET</sub> : id da pessoa </p>
        </div>
    </div>
    
    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.approveCheckIn(<b>tokenID</b>, <b>requestID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.approveCheckIn&tokenID=$tokenID&requestID=1">
        </p>

        <p class="documentFunctionDescription">Aprova a solicitação <i>requestID</i> para entrada da pessoa.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>requestID</b><sub>GET</sub> : id da requisição de entrada </p>
        </div>
    </div>
    
    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.getPeople(<b>tokenID</b>, <b>activityID</b>, <b>selection</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.getPeople&tokenID=$tokenID&activityID=1&selection=all">
        </p>

        <p class="documentFunctionDescription">Retorna todas as pessoas que foram confirmadas na atividade <i>activityID</i>, filtradas por uma seleção <i>selection</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>activityID</b><sub>GET</sub> : id da atividade </p>
            <p><b>selection</b><sub>GET</sub> : quem irá ao evento, podendo ser filtradas em aprovadas <i>approved</i>, negadas <i>denied</i>, não avaliadas <i>unseen</i> e todas <i>all</i></p>
        </div>
    </div>
    
</div>