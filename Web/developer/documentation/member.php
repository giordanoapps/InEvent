<!-- MEMBROS -->
<div class="documentationBox">
    <h2>Membros</h2>

    <p>O conteúdo abaixo é referente a ferramenta sobre os Membros.</p>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>member.signIn(<b>name</b>, <b>password</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=member.signIn&name=Nome&password=Senha">
        </p>

        <p class="documentFunctionDescription">Loga um membro na plataforma e retorna o <i>tokenID</i> (60 caracteres) caso a operação tenha sido bem sucedida.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>name</b><sub>GET</sub> : nome de membro</p>
            <p><b>password</b><sub>GET</sub> : senha do membro</p>
        </div>
    </div>
    
    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>member.getNumberOfMembers(<b>tokenID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=member.getNumberOfMembers&tokenID=$tokenID">
        </p>

        <p class="documentFunctionDescription">Retorna o número de membros cadastrados para o <i>tokenID</i> fornecido.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>member.getMembers(<b>tokenID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=member.getMembers&tokenID=$tokenID">
        </p>
        
        <p class="documentFunctionDescription">Retorna a lista dos membros registrados para o <i>tokenID</i> fornecido.</p>
        
        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>member.getSingleMember(<b>tokenID</b>, <b>memberID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=member.getSingleMember&tokenID=$tokenID&memberID=149">
        </p>

        <p class="documentFunctionDescription">Retorna informações sobre o membro <i>memberID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>memberID</b><sub>GET</sub> : id do membro </p>
        </div>
    </div>

<!--     <div class="documentationFunctionBox">
        <p class="documentFunctionName">member.createMember(<b>tokenID</b>, <b>name</b>, <b>password</b>)
        <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=member.createMember&tokenID=$tokenID" data-post="name=Nome&password=Senha"></p>
        
        <p class="documentFunctionDescription">Cria um novo membro com nome <i>name</i> e senha <i>password</i> para a empresa associada ao <i>tokenID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>name</b><sub>POST</sub> : nome do membro </p>
            <p><b>password</b><sub>POST</sub> : senha do membro </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>member.updateMember(<b>tokenID</b>, <b>details</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=member.updateMember&tokenID=$tokenID" data-post="details={}">
        </p>

        <p class="documentFunctionDescription">Atualiza os detalhes <i>details</i> do membro associado ao <i>tokenID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>details</b><sub>POST</sub> : detalhes do membro </p>
        </div>
    </div> -->
    
</div>