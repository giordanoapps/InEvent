<div class="documentationBox">
    <h2>Grupo</h2>
    
    <p>Durante um evento, existem diversos grupos que se iniciam e ocorrem em períodos curtos mas indeterminados de tempo. Cada uma recebe um identificador <i>groupID</i>, o que lhes permite acessar suas informações, assim como adicionar novas pessoas ou receber alterações em seus canais.</p>
    
    <h3 class="documentationHeader">Push</h3>
    
    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>group/new : <b>groupID</b></span>
            <span><img src="../images/64-Archive.png" alt="Channel">event_<b>eventID</b></span>
        </p>
        <p class="documentFunctionDescription">Informa a criação do grupo <i>groupID</i> no evento <i>eventID</i>.</p>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>group/update : <b>groupID</b></span>
            <span><img src="../images/64-Archive.png" alt="Channel">event_<b>eventID</b></span>
        </p>
        <p class="documentFunctionDescription">Informa a atualização do grupo <i>groupID</i> no evento <i>eventID</i>.</p>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>group/remove : <b>groupID</b></span>
            <span><img src="../images/64-Archive.png" alt="Channel">event_<b>eventID</b></span>
        </p>
        <p class="documentFunctionDescription">Informa a remoção do grupo <i>groupID</i> no evento <i>eventID</i>.</p>
    </div>

    <h3 class="documentationHeader">Funções</h3>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>group.create(<b>tokenID</b>, <b>eventID</b>, <b>name</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=group.create&tokenID=$tokenID&eventID=1" data-post="name=null">
        </p>

       <p class="documentFunctionDescription">Cria um grupo nomeado <i>name</i> dentro do evento <i>eventID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
            <p><b>name</b><sub>POST</sub> : nome do grupo </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>group.edit(<b>tokenID</b>, <b>groupID</b>, <b>name</b>, <b>value</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=group.edit&tokenID=$tokenID&groupID=1&name=nome" data-post="value=valor">
        </p>

        <p class="documentFunctionDescription">Edita o valor <i>value</i> no campo <i>name</i> do grupo <i>groupID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>groupID</b><sub>GET</sub> : id do grupo </p>
            <p><b>name</b><sub>GET</sub> : nome do campo </p>
            <p><b>value</b><sub>POST</sub> : valor do campo </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>group.remove(<b>tokenID</b>, <b>groupID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=group.remove&tokenID=$tokenID&groupID=1">
        </p>

        <p class="documentFunctionDescription">Remove o grupo <i>groupID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>groupID</b><sub>GET</sub> : id do grupo </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>group.requestEnrollment(<b>tokenID</b>, <b>groupID</b>, <b>name</b> = null, <b>email</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=group.requestEnrollment&tokenID=$tokenID&groupID=1&name=null&email=null">
        </p>

        <p class="documentFunctionDescription">Solicita a entrada da pessoa com email <i>email</i> no grupo <i>groupID</i>. Se o nome <i>name</i> e email <i>email</i> da pessoa não for especificada ou o <i>tokenID</i> fornecido não tiver permissão para enviar para a pessoa com email <i>email</i>, será utilizada a pessoa associada ao <i>tokenID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>groupID</b><sub>GET</sub> : id do grupo </p>
            <p><b>name</b><sub>GET</sub> : nome da pessoa </p>
            <p><b>email</b><sub>GET</sub> : email da pessoa </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>group.dismissEnrollment(<b>tokenID</b>, <b>groupID</b>, <b>personID</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=group.dismissEnrollment&tokenID=$tokenID&groupID=1&personID=null">
        </p>

        <p class="documentFunctionDescription">Solicita a remoção da pessoa <i>personID</i> do grupo <i>groupID</i>. Se a pessoa <i>personID</i> não for especificada ou o <i>tokenID</i> fornecido não tiver permissão para enviar para a pessoa <i>personID</i>, será utilizada a pessoa associada ao <i>tokenID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>groupID</b><sub>GET</sub> : id do grupo </p>
            <p><b>personID</b><sub>GET</sub> : id da pessoa </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>group.confirmApproval(<b>tokenID</b>, <b>groupID</b>, <b>personID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=group.confirmApproval&tokenID=$tokenID&groupID=1&personID=1">
        </p>

        <p class="documentFunctionDescription">Confirma que a pessoa <i>personID</i> está aprovada no grupo <i>groupID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>groupID</b><sub>GET</sub> : id do grupo </p>
            <p><b>personID</b><sub>GET</sub> : id da pessoa </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>group.revokeApproval(<b>tokenID</b>, <b>groupID</b>, <b>personID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=group.revokeApproval&tokenID=$tokenID&groupID=1&personID=1">
        </p>

        <p class="documentFunctionDescription">Nega que a pessoa <i>personID</i> está aprovada no grupo <i>groupID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>groupID</b><sub>GET</sub> : id do grupo </p>
            <p><b>personID</b><sub>GET</sub> : id da pessoa </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>group.confirmEntrance(<b>tokenID</b>, <b>groupID</b>, <b>personID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=group.confirmEntrance&tokenID=$tokenID&groupID=1&personID=1">
        </p>

        <p class="documentFunctionDescription">Confirma que a pessoa <i>personID</i> está presente no grupo <i>groupID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>groupID</b><sub>GET</sub> : id do grupo </p>
            <p><b>personID</b><sub>GET</sub> : id da pessoa </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>group.revokeEntrance(<b>tokenID</b>, <b>groupID</b>, <b>personID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=group.revokeEntrance&tokenID=$tokenID&groupID=1&personID=1">
        </p>

        <p class="documentFunctionDescription">Nega que a pessoa <i>personID</i> está presente no grupo <i>groupID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>groupID</b><sub>GET</sub> : id do grupo </p>
            <p><b>personID</b><sub>GET</sub> : id da pessoa </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>group.getPeople(<b>tokenID</b>, <b>groupID</b>, <b>selection</b>, <b>order</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=group.getPeople&tokenID=$tokenID&groupID=1&selection=all&order=name">
        </p>

        <p class="documentFunctionDescription">Retorna todas as pessoas que foram confirmadas no grupo <i>groupID</i>, filtradas por uma seleção <i>selection</i> e ordem <i>order</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>groupID</b><sub>GET</sub> : id do grupo </p>
            <p><b>selection</b><sub>GET</sub> : quem irá ao evento, podendo ser filtradas em aprovadas <i>approved</i>, negadas <i>denied</i>, não avaliadas <i>unseen</i>, pagas <i>paid</i>, presentes <i>present</i> e todas <i>all</i></p>
            <p><b>order</b><sub>GET</sub> : ordem baseada na coluna </p>
        </div>
    </div>
    
</div>