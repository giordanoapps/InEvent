<div class="documentationBox">
    <h2>Aplicação</h2>
    
    <p>Para uso contínuo da API com benefícios exclusivos a parceiros é necessário a criação da aplicação dentro do InEvent para melhor controle sobre segurança e limites de uso. Para cada aplicação cadastrada, é gerado o identificador da aplicação <i>appID</i> e seu segredo <i>appSecret</i>, dados necessários para a correta autorização de acesso.</p>

    <h3 class="documentationHeader">Funções</h3>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>app.signIn(<b>appID</b>, <b>cryptMessage</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=app.signIn&appID=1&cryptMessage={}">
        </p>

        <p class="documentFunctionDescription"> Inicia a sessão da pessoa <i>personID</i> no aplicativo <i>appID</i>, retornando o <b>tokenID</b> (60 caracteres) caso a operação tenha sido bem sucedida.</p>

        <p>Para o correto envio de <i>cryptMessage</i>, é necessário gerar um objeto com a chave personID, encriptar os dados usando o <i>appSecret</i> como chave primária em AES 128bit modo ECB e converter para base 64.</p>

        <pre class="json">
{
  "personID": 1
}
        </pre>

        <p>Em PHP, temos:</p>
<pre>$cryptMessage = base64_encode(mcrypt_encrypt(MCRYPT_RIJNDAEL_128, $appSecret, json_encode($json), MCRYPT_MODE_ECB));</pre>

        <div class="documentationFunctionParametersBox">
            <p><b>appID</b><sub>GET</sub> : id da aplicação </p>
            <p><b>appSecret</b><sub>GET</sub> : segredo da aplicação </p>
            <p><b>personID</b><sub>GET</sub> : id da pessoa </p>
            <p><b>cryptMessage</b><sub>GET</sub> : chave encriptada </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>app.getDetails(<b>tokenID</b>, <b>appID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=app.getDetails&tokenID=$tokenID">
        </p>

        <p class="documentFunctionDescription">Retorna todos detalhes da pessoa com token <i>tokenID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>app.create(<b>tokenID</b>, <b>name</b> = null)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=app.create&tokenID=$tokenID" data-post="name=null">
        </p>

       <p class="documentFunctionDescription">Cria uma aplicação nomeada <i>name</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>name</b><sub>POST</sub> : nome da atividade </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>app.edit(<b>tokenID</b>, <b>appID</b>, <b>name</b>, <b>value</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=app.edit&tokenID=$tokenID&appID=1&name=nome" data-post="value=valor">
        </p>

        <p class="documentFunctionDescription">Edita o valor <i>value</i> no campo <i>name</i> da aplicação <i>appID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>appID</b><sub>GET</sub> : id da aplicação </p>
            <p><b>name</b><sub>GET</sub> : nome do campo </p>
            <p><b>value</b><sub>POST</sub> : valor do campo </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>app.remove(<b>tokenID</b>, <b>appID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=app.remove&tokenID=$tokenID&appID=1">
        </p>

        <p class="documentFunctionDescription">Remove a atividade <i>appID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>appID</b><sub>GET</sub> : id da aplicação </p>
        </div>
    </div>

</div>