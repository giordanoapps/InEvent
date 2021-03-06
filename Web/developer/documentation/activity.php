<div class="documentationBox">
    <h2>Atividade</h2>
    
    <p>Durante um evento, existem diversas atividades que se iniciam e ocorrem em períodos determinados de tempo. Cada uma recebe um identificador <i>activityID</i>, o que lhes permite acessar suas informações, assim como adicionar novas pessoas ou receber alterações em seus canais.</p>
    
    <h3 class="documentationHeader">Push</h3>
    
    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity/new : <b>activityID</b></span>
            <span><img src="../images/64-Archive.png" alt="Channel">event_<b>eventID</b></span>
        </p>
        <p class="documentFunctionDescription">Informa a criação da atividade <i>activityID</i> no evento <i>eventID</i>.</p>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity/update : <b>activityID</b></span>
            <span><img src="../images/64-Archive.png" alt="Channel">event_<b>eventID</b></span>
        </p>
        <p class="documentFunctionDescription">Informa a atualização da atividade <i>activityID</i> no evento <i>eventID</i>.</p>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity/remove : <b>activityID</b></span>
            <span><img src="../images/64-Archive.png" alt="Channel">event_<b>eventID</b></span>
        </p>
        <p class="documentFunctionDescription">Informa a remoção da atividade <i>activityID</i> no evento <i>eventID</i>.</p>
    </div>

    <h3 class="documentationHeader">Funções</h3>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.create(<b>tokenID</b>, <b>eventID</b>, <b>name</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.create&tokenID=$tokenID&eventID=1" data-post="name=null">
        </p>

       <p class="documentFunctionDescription">Cria uma atividade nomeada <i>name</i> dentro do evento <i>eventID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
            <p><b>name</b><sub>POST</sub> : nome da atividade </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.edit(<b>tokenID</b>, <b>activityID</b>, <b>name</b>, <b>value</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.edit&tokenID=$tokenID&activityID=1&name=nome" data-post="value=valor">
        </p>

        <p class="documentFunctionDescription">Edita o valor <i>value</i> no campo <i>name</i> da atividade <i>activityID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>activityID</b><sub>GET</sub> : id da atividade </p>
            <p><b>name</b><sub>GET</sub> : nome do campo </p>
            <p><b>value</b><sub>POST</sub> : valor do campo </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.remove(<b>tokenID</b>, <b>activityID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.remove&tokenID=$tokenID&activityID=1">
        </p>

        <p class="documentFunctionDescription">Remove a atividade <i>activityID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>activityID</b><sub>GET</sub> : id da atividade </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.requestEnrollment(<b>tokenID</b>, <b>activityID</b>, <b>name</b> = null, <b>email</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.requestEnrollment&tokenID=$tokenID&activityID=1&name=null&email=null">
        </p>

        <p class="documentFunctionDescription">Solicita a entrada da pessoa com email <i>email</i> na atividade <i>activityID</i>. Se o nome <i>name</i> e email <i>email</i> da pessoa não for especificada ou o <i>tokenID</i> fornecido não tiver permissão para enviar para a pessoa com email <i>email</i>, será utilizada a pessoa associada ao <i>tokenID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>activityID</b><sub>GET</sub> : id da atividade </p>
            <p><b>name</b><sub>GET</sub> : nome da pessoa </p>
            <p><b>email</b><sub>GET</sub> : email da pessoa </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.requestMultipleEnrollment(<b>tokenID</b>, <b>activityID</b>, <b>path</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.requestMultipleEnrollment&tokenID=$tokenID&activityID=1&path=null">
        </p>

        <p class="documentFunctionDescription">Solicita a entrada de múltiplas pessoas na atividade <i>activityID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>activityID</b><sub>GET</sub> : id da atividade </p>
            <p><b>path</b><sub>GET</sub> : local do arquivo </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.dismissEnrollment(<b>tokenID</b>, <b>activityID</b>, <b>personID</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.dismissEnrollment&tokenID=$tokenID&activityID=1&personID=null">
        </p>

        <p class="documentFunctionDescription">Solicita a remoção da pessoa <i>personID</i> da atividade <i>activityID</i>. Se a pessoa <i>personID</i> não for especificada ou o <i>tokenID</i> fornecido não tiver permissão para enviar para a pessoa <i>personID</i>, será utilizada a pessoa associada ao <i>tokenID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>activityID</b><sub>GET</sub> : id da atividade </p>
            <p><b>personID</b><sub>GET</sub> : id da pessoa </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.confirmApproval(<b>tokenID</b>, <b>activityID</b>, <b>personID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.confirmApproval&tokenID=$tokenID&activityID=1&personID=1">
        </p>

        <p class="documentFunctionDescription">Confirma que a pessoa <i>personID</i> está aprovada na atividade <i>activityID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>activityID</b><sub>GET</sub> : id da atividade </p>
            <p><b>personID</b><sub>GET</sub> : id da pessoa </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.revokeApproval(<b>tokenID</b>, <b>activityID</b>, <b>personID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.revokeApproval&tokenID=$tokenID&activityID=1&personID=1">
        </p>

        <p class="documentFunctionDescription">Nega que a pessoa <i>personID</i> está aprovada na atividade <i>activityID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>activityID</b><sub>GET</sub> : id da atividade </p>
            <p><b>personID</b><sub>GET</sub> : id da pessoa </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.confirmEntrance(<b>tokenID</b>, <b>activityID</b>, <b>personID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.confirmEntrance&tokenID=$tokenID&activityID=1&personID=1">
        </p>

        <p class="documentFunctionDescription">Confirma que a pessoa <i>personID</i> está presente na atividade <i>activityID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>activityID</b><sub>GET</sub> : id da atividade </p>
            <p><b>personID</b><sub>GET</sub> : id da pessoa </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.revokeEntrance(<b>tokenID</b>, <b>activityID</b>, <b>personID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.revokeEntrance&tokenID=$tokenID&activityID=1&personID=1">
        </p>

        <p class="documentFunctionDescription">Nega que a pessoa <i>personID</i> está presente na atividade <i>activityID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>activityID</b><sub>GET</sub> : id da atividade </p>
            <p><b>personID</b><sub>GET</sub> : id da pessoa </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.confirmPayment(<b>tokenID</b>, <b>activityID</b>, <b>personID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.confirmPayment&tokenID=$tokenID&activityID=1&personID=1">
        </p>

        <p class="documentFunctionDescription">Confirma que a pessoa <i>personID</i> realizou o pagamento da atividade <i>activityID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>activityID</b><sub>GET</sub> : id da atividade </p>
            <p><b>personID</b><sub>GET</sub> : id da pessoa </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.revokePayment(<b>tokenID</b>, <b>activityID</b>, <b>personID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.revokePayment&tokenID=$tokenID&activityID=1&personID=1">
        </p>

        <p class="documentFunctionDescription">Nega que a pessoa <i>personID</i> realizou o pagamento da atividade <i>activityID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>activityID</b><sub>GET</sub> : id da atividade </p>
            <p><b>personID</b><sub>GET</sub> : id da pessoa </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.risePriority(<b>tokenID</b>, <b>activityID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.risePriority&tokenID=$tokenID&activityID=1">
        </p>

        <p class="documentFunctionDescription">Confirma que a pessoa aumentou a prioridade de entrar na atividade <i>activityID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>activityID</b><sub>GET</sub> : id da atividade </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.decreasePriority(<b>tokenID</b>, <b>activityID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.decreasePriority&tokenID=$tokenID&activityID=1">
        </p>

        <p class="documentFunctionDescription">Confirma que a pessoa reduziu a prioridade de entrar na atividade <i>activityID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>activityID</b><sub>GET</sub> : id da atividade </p>
        </div>
    </div>
    
    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.getPeople(<b>tokenID</b>, <b>activityID</b>, <b>selection</b>, <b>order</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.getPeople&tokenID=$tokenID&activityID=1&selection=all&order=name">
        </p>

        <p class="documentFunctionDescription">Retorna todas as pessoas que foram confirmadas na atividade <i>activityID</i>, filtradas por uma seleção <i>selection</i> e ordem <i>order</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>activityID</b><sub>GET</sub> : id da atividade </p>
            <p><b>selection</b><sub>GET</sub> : quem irá ao evento, podendo ser filtradas em aprovadas <i>approved</i>, negadas <i>denied</i>, não avaliadas <i>unseen</i>, pagas <i>paid</i>, presentes <i>present</i> e todas <i>all</i></p>
            <p><b>order</b><sub>GET</sub> : ordem baseada na coluna </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.getQuestions(<b>tokenID</b>, <b>activityID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.getQuestions&tokenID=$tokenID&activityID=1">
        </p>

        <p class="documentFunctionDescription">Retorna todas as perguntas enviadas para a atividade <i>activityID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>activityID</b><sub>GET</sub> : id da atividade </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.sendQuestion(<b>tokenID</b>, <b>activityID</b>, <b>question</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.sendQuestion&tokenID=$tokenID&activityID=1" data-post="question=Pergunta">
        </p>

        <p class="documentFunctionDescription">Envia uma pergunta <i>question</i> para a atividade <i>activityID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>activityID</b><sub>GET</sub> : id da atividade </p>
            <p><b>question</b><sub>POST</sub> : texto da pergunta </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.removeQuestion(<b>tokenID</b>, <b>questionID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.removeQuestion&tokenID=$tokenID&questionID=1">
        </p>

        <p class="documentFunctionDescription">Remove a pergunta <i>questionID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>questionID</b><sub>GET</sub> : id da pergunta </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.upvoteQuestion(<b>tokenID</b>, <b>questionID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.upvoteQuestion&tokenID=$tokenID&questionID=1">
        </p>

        <p class="documentFunctionDescription">Dá um voto positivo para a pergunta <i>questionID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>questionID</b><sub>GET</sub> : id da pergunta </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.getOpinion(<b>tokenID</b>, <b>activityID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.getOpinion&tokenID=$tokenID&activityID=1">
        </p>

        <p class="documentFunctionDescription">Retorna a pontuação <i>rating</i> para a atividade <i>activityID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>activityID</b><sub>GET</sub> : id da atividade </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>activity.sendOpinion(<b>tokenID</b>, <b>activityID</b>, <b>rating</b>, <b>personID</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=activity.sendOpinion&tokenID=$tokenID&activityID=1&personID=null" data-post="rating=5">
        </p>

        <p class="documentFunctionDescription">Envia a pontuação <i>rating</i> para a atividade <i>activityID</i>. Se a pessoa <i>personID</i> não for especificada ou o <i>tokenID</i> fornecido não tiver permissão para enviar para a pessoa <i>personID</i>, será utilizada a pessoa associada ao <i>tokenID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>activityID</b><sub>GET</sub> : id da atividade </p>
            <p><b>rating</b><sub>POST</sub> : inteiro com a pontuação </p>
            <p><b>personID</b><sub>GET</sub> : id da pessoa </p>
        </div>
    </div>
    
</div>