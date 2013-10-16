<div class="documentationBox">
    <h2>Evento</h2>
    
    <p>Para cada evento, podemos informar quais as pessoas e atividades que estão ocorrendo dentro do mesmo. Cada um recebe um identificador <i>eventID</i>, o que lhes permite acessar suas informações, assim como adicionar novas pessoas ou ver suas atividades.</p>
    
    <h3 class="documentationHeader">Push</h3>
    
    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>event/new : <b>eventID</b></span>
            <span><img src="../images/64-Archive.png" alt="Channel">event_<b>eventID</b></span>
        </p>
        <p class="documentFunctionDescription">Informa a criação do evento <i>eventID</i>.</p>
    </div>

    <h3 class="documentationHeader">Funções</h3>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>event.edit(<b>tokenID</b>, <b>eventID</b>, <b>name</b>, <b>value</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=event.edit&tokenID=$tokenID&eventID=1&name=nome" data-post="value=valor">
        </p>

        <p class="documentFunctionDescription">Edita o valor <i>value</i> no campo <i>name</i> do evento <i>eventID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id da atividade </p>
            <p><b>name</b><sub>GET</sub> : nome do campo </p>
            <p><b>value</b><sub>POST</sub> : valor do campo </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>event.getEvents(<b>tokenID</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=event.getEvents&tokenID=null">
        </p>

        <p class="documentFunctionDescription">Retorna todos os eventos cadastrados, com nomes ordenados em ordem alfabética. Caso seja fornecido um <i>tokenID</i>, será informado se a pessoa associada ao <i>tokenID</i> está inscrita.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>event.getSingle(<b>eventID</b>, <b>tokenID</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=event.getSingle&eventID=1&tokenID=null">
        </p>

        <p class="documentFunctionDescription">Retorna o evento <i>eventID</i>. Caso seja fornecido um <i>tokenID</i>, será informado se a pessoa associada ao <i>tokenID</i> está inscrita.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>event.requestEnrollment(<b>tokenID</b>, <b>eventID</b>, <b>name</b> = null, <b>email</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=event.requestEnrollment&tokenID=$tokenID&eventID=1&name=null&email=null">
        </p>

        <p class="documentFunctionDescription">Solicita a entrada da pessoa <i>personID</i> no evento <i>eventID</i>. Se o nome <i>name</i> e email <i>email</i> da pessoa não for especificada ou o <i>tokenID</i> fornecido não tiver permissão para enviar para a pessoa com email <i>email</i>, será utilizada a pessoa associada ao <i>tokenID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
            <p><b>name</b><sub>GET</sub> : nome da pessoa </p>
            <p><b>email</b><sub>GET</sub> : email da pessoa </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>event.requestMultipleEnrollment(<b>tokenID</b>, <b>eventID</b>, <b>path</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=event.requestMultipleEnrollment&tokenID=$tokenID&eventID=1&path=null">
        </p>

        <p class="documentFunctionDescription">Solicita a entrada de múltiplas pessoas no evento <i>eventID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
            <p><b>path</b><sub>GET</sub> : local do arquivo </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>event.dismissEnrollment(<b>tokenID</b>, <b>eventID</b>, <b>personID</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=event.dismissEnrollment&tokenID=$tokenID&eventID=1&personID=null">
        </p>

        <p class="documentFunctionDescription">Solicita a remoção da pessoa <i>personID</i> no evento <i>eventID</i>. Se a pessoa <i>personID</i> não for especificada ou o <i>tokenID</i> fornecido não tiver permissão para enviar para a pessoa <i>personID</i>, será utilizada a pessoa associada ao <i>tokenID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
            <p><b>personID</b><sub>GET</sub> : id da pessoa </p>
        </div>
    </div>
    
    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>event.approveEnrollment(<b>tokenID</b>, <b>eventID</b>, <b>personID</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=event.approveEnrollment&tokenID=$tokenID&eventID=1&personID=null">
        </p>

        <p class="documentFunctionDescription">Aprova a entrada da pessoa <i>personID</i> no evento <i>eventID</i>. Se a pessoa <i>personID</i> não for especificada ou o <i>tokenID</i> fornecido não tiver permissão para enviar para a pessoa <i>personID</i>, será utilizada a pessoa associada ao <i>tokenID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
            <p><b>personID</b><sub>GET</sub> : id da pessoa </p>
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
            <span>event.getPeople(<b>tokenID</b>, <b>eventID</b>, <b>selection</b>, <b>order</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=event.getPeople&tokenID=$tokenID&eventID=1&selection=all&order=name">
        </p>

        <p class="documentFunctionDescription">Retorna todas as pessoas que solicitaram entrar no evento <i>eventID</i>, filtradas por uma seleção <i>selection</i> e ordem <i>order</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
            <p><b>selection</b><sub>GET</sub> : quem irá ao evento, podendo ser filtradas em aprovadas <i>approved</i>, negadas <i>denied</i>, não avaliadas <i>unseen</i> e todas <i>all</i></p>
            <p><b>order</b><sub>GET</sub> : ordem baseada na coluna </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>event.sendMail(<b>tokenID</b>, <b>eventID</b>, <b>selection</b>, <b>order</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=event.sendMail&tokenID=$tokenID&eventID=1&selection=all&order=name">
        </p>

        <p class="documentFunctionDescription">Envia um email todas as pessoas que solicitaram entrar no evento <i>eventID</i>, filtradas por uma seleção <i>selection</i> e ordem <i>order</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
            <p><b>selection</b><sub>GET</sub> : quem irá ao evento, podendo ser filtradas em aprovadas <i>approved</i>, negadas <i>denied</i>, não avaliadas <i>unseen</i> e todas <i>all</i></p>
            <p><b>order</b><sub>GET</sub> : ordem baseada na coluna </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>event.getActivities(<b>eventID</b>, <b>tokenID</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=event.getActivities&tokenID=null&eventID=1">
        </p>

        <p class="documentFunctionDescription">Retorna todas as atividades do evento <i>eventID</i>. Caso seja fornecido um <i>tokenID</i>, será informado se a pessoa associada ao <i>tokenID</i> está inscrita em cada atividade.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>event.getGroups(<b>eventID</b>, <b>tokenID</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=event.getGroups&tokenID=null&eventID=1">
        </p>

        <p class="documentFunctionDescription">Retorna todas os grupos do evento <i>eventID</i>. Caso seja fornecido um <i>tokenID</i>, será informado se a pessoa associada ao <i>tokenID</i> está inscrita em cada grupo.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>event.getOpinion(<b>tokenID</b>, <b>eventID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=event.getOpinion&tokenID=$tokenID&eventID=1">
        </p>

        <p class="documentFunctionDescription">Retorna a pontuação <i>rating</i> para o evento <i>eventID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>event.sendOpinion(<b>tokenID</b>, <b>eventID</b>, <b>rating</b>, <b>message</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=event.sendOpinion&tokenID=$tokenID&eventID=1" data-post="rating=5&message=Maravilhoso!">
        </p>

        <p class="documentFunctionDescription">Envia a pontuação <i>rating</i> e a mensagem <i>message</i> para o evento <i>eventID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id da atividade </p>
            <p><b>rating</b><sub>POST</sub> : inteiro com a pontuação </p>
            <p><b>message</b><sub>POST</sub> : texto da mensagem </p>
        </div>
    </div>

</div>