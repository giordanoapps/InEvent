<div class="documentationBox">
	<h2>Pessoa</h2>
	
	<p>O conteúdo abaixo é referente as operações sobre a Pessoa. As informações fornecidas sobre a mesma serão seu nome, identificador, eventos em que está inscrito e seu id de autenticação.</p>

	<h3 class="documentationHeader">Push</h3>
    
    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>person/promote : <b>eventID</b></span>
            <span><img src="../images/64-Archive.png" alt="Channel">person_<b>personID</b></span>
        </p>
        <p class="documentFunctionDescription">Informa que a pessoa <i>personID</i> foi promovida no evento <i>eventID</i>.</p>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>person/demote : <b>eventID</b></span>
            <span><img src="../images/64-Archive.png" alt="Channel">person_<b>personID</b></span>
        </p>
        <p class="documentFunctionDescription">Informa que a pessoa <i>personID</i> foi demitida no evento <i>eventID</i>.</p>
    </div>

	<h3 class="documentationHeader">Funções</h3>
	
	<div class="documentationFunctionBox">
		<p class="documentFunctionName">
			<span>person.signIn(<b>email</b>, <b>password</b>)</span>
			<img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=person.signIn&email=Email&password=Senha">
		</p>

		<p class="documentFunctionDescription">Inicia a sessão de uma pessoa e retorna o <b>tokenID</b> (60 caracteres) caso a operação tenha sido bem sucedida.</p>

		<div class="documentationFunctionParametersBox">
			<p><b>email</b><sub>GET</sub> : email do membro </p>
			<p><b>password</b><sub>GET</sub> : senha do membro </p>
		</div>
	</div>
	
	<div class="documentationFunctionBox">
		<p class="documentFunctionName">
			<span>person.signInWithFacebook(<b>facebookToken</b>)</span>
			<img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=person.signInWithFacebook&facebookToken=token">
		</p>

		<p class="documentFunctionDescription">Inicia a sessão de uma pessoa baseada no <i>facebookToken</i> e retorna o <b>tokenID</b> (60 caracteres) caso a operação tenha sido bem sucedida.</p>

		<div class="documentationFunctionParametersBox">
			<p><b>facebookToken</b><sub>GET</sub> : token de autenticação fornecido pelo Facebook </p>
		</div>
	</div>
	
	<div class="documentationFunctionBox">
		<p class="documentFunctionName">
			<span>person.enroll(<b>name</b>, <b>password</b>, <b>email</b>, <b>cpf</b> = null, <b>rg</b> = null, <b>telephone</b> = null, <b>university</b> = null, <b>course</b> = null)</span>
			<img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=person.enroll" data-post="member=&password=&email=&cpf=00000000000&rg=0000000&telephone=&university=&course=">
		</p>

		<p class="documentFunctionDescription">Cria uma conta para a pessoa com nome <i>name</i>, senha <i>password</i>, email <i>email</i>, CPF <i>cpf</i>, RG <i>rg</i>, telefone <i>telephone</i>, universidade <i>university</i> e curso <i>course</i>, retornando o <b>tokenID</b> (60 caracteres) caso a operação tenha sido bem sucedida.</p>

		<div class="documentationFunctionParametersBox">
			<p><b>name</b><sub>POST</sub> : nome da pessoa </p>
			<p><b>password</b><sub>POST</sub> : senha da pessoa </p>
			<p><b>email</b><sub>POST</sub> : email da pessoa </p>
			<p><b>cpf</b><sub>POST</sub> : CPF da pessoa </p>
			<p><b>rg</b><sub>POST</sub> : RG da pessoa </p>
			<p><b>telephone</b><sub>POST</sub> : telefone da pessoa </p>
			<p><b>university</b><sub>POST</sub> : universidade da pessoa </p>
			<p><b>course</b><sub>POST</sub> : curso da pessoa </p>
		</div>
	</div>

	<div class="documentationFunctionBox">
		<p class="documentFunctionName">
			<span>person.sendRecovery(<b>email</b>)</span>
			<img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=person.sendRecovery&email=">
		</p>

		<p class="documentFunctionDescription">Envia um email com a nova senha da pessoa associada ao email <i>email</i>.</p>

		<div class="documentationFunctionParametersBox">
			<p><b>email</b><sub>GET</sub> : email da pessoa </p>
		</div>
	</div>

	<div class="documentationFunctionBox">
		<p class="documentFunctionName">
			<span>person.subscribe(<b>email</b>)</span>
			<img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=person.subscribe&email=">
		</p>

		<p class="documentFunctionDescription">Adiciona o email <i>email</i> a lista de envio de emails.</p>

		<div class="documentationFunctionParametersBox">
			<p><b>email</b><sub>GET</sub> : email da pessoa </p>
		</div>
	</div>

	<div class="documentationFunctionBox">
		<p class="documentFunctionName">
			<span>person.unsubscribe(<b>email</b>)</span>
			<img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=person.unsubscribe&email=">
		</p>

		<p class="documentFunctionDescription">Remove a pessoa associada ao email <i>email</i> da lista de envio de emails.</p>

		<div class="documentationFunctionParametersBox">
			<p><b>email</b><sub>GET</sub> : email da pessoa </p>
		</div>
	</div>

	<div class="documentationFunctionBox">
		<p class="documentFunctionName">
			<span>person.changePassword(<b>tokenID</b>, <b>oldPassword</b>, <b>newPassword</b>)</span>
			<img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=person.changePassword&tokenID=$tokenID&oldPassword=123&newPassword=456">
		</p>

		<p class="documentFunctionDescription">Troca a senha antiga <i>oldPassword</i> pela nova senha <i>newPassword</i>.</p>

		<div class="documentationFunctionParametersBox">
			<p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
			<p><b>oldPassword</b><sub>GET</sub> : senha antiga </p>
			<p><b>newPassword</b><sub>GET</sub> : senha nova </p>
		</div>
	</div>
	
	<div class="documentationFunctionBox">
		<p class="documentFunctionName">
			<span>person.getWorkingEvents(<b>tokenID</b>)</span>
			<img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=person.getWorkingEvents&tokenID=$tokenID">
		</p>

		<p class="documentFunctionDescription">Retorna todas os eventos em que a pessoa com o <i>tokenID</i> está trabalhando.</p>

		<div class="documentationFunctionParametersBox">
			<p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
		</div>
	</div>

</div>