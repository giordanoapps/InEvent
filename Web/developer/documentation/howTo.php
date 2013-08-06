<!-- COMO USAR -->
<div class="documentationBox documentationBoxSelected">
    <h2>Uso</h2>

    <p>Para utilizar a API do <b>InEvent</b>, basta consultar nossa documentação disponível à esquerda. Abaixo temos um exemplo que será utilizado posteriormente para explicar o envio de requisições.</p>
    
    <h3>URL oficial</h3>
        <pre class="url oficialURL"><?php echo URL ?></pre>
    
    <h3>Exemplo de documentação</h3>
        <p>Para testar a função, basta clicar no ícone <img src="../images/64-Chemical.png" class="tryItOut" alt="Try it out!"> que uma requisição será efetuada para demonstrar o uso da chamada.</p>
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
        
        <pre class="url"><?php echo URL ?>?method=member.signIn&member=Nome&password=Senha</pre>
    
    <h3>Explicação</h3>
        <p>Existem três seções demarcadas: <b>cabeçalho, retorno e parâmetros</b>, cada qual sendo explicada separadamente:</p>
            <ul>
                <li>O <b>cabeçalho</b> (member.signIn) apresenta a chamada, composto de um <u>namespace</u> (member) e seu <u>método</u> (signIn). A chamada deve ser enviada ao servidor através do parâmetro method via GET, para que seja identificada o tipo de informação que o cliente deseja.</li>
                <li>O <b>retorno</b> explica quais dados serão retornados, podendo o usuário sempre pode fazer uma requisição de teste para ver quais serão os dados de retorno.</li>
                <li>Os <b>parâmetros</b> (member, password) mostram seu significado e por qual método devem ser enviados, variando sempre entre GET e POST.</li>
            </ul>
            
    <h3>Notas</h3>
    <p>A API do <b>InEvent</b> utiliza um RPC-REST híbrido, utilizando o POST carregado como forma de enviar dados que necessitem de mais espaço. Além disso, todas as requisições são encriptadas em 256 bit por padrão.</p>
    
</div>