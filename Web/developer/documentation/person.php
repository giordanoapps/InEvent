<div class="documentationBox">
	<h2>Pessoa</h2>
	
	<p>O conteúdo abaixo é referente as operações sobre a Pessoa. As informações fornecidas sobre a mesma serão seu nome, identificador, eventos em que está inscrito e seu id de autenticação.</p>
	
	<h3 class="documentationHeader">Funções</h3>
	
	<div class="documentationFunctionBox">
		<p class="documentFunctionName">
			<span>person.signIn(<b>name</b>, <b>password</b>)</span>
			<img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=person.signIn&name=Nome&password=Senha">
		</p>

		<p class="documentFunctionDescription">Inicia a sessão de uma pessoa e retorna o <b>tokenID</b> (60 caracteres) caso a operação tenha sido bem sucedida.</p>

		<div class="documentationFunctionParametersBox">
			<p><b>name</b><sub>GET</sub> : nome do membro </p>
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
			<span>person.register(<b>name</b>, <b>password</b>, <b>email</b>, <b>cpf</b> = null, <b>rg</b> = null, <b>telephone</b> = null, <b>university</b> = null, <b>course</b> = null)</span>
			<img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=person.register" data-post="member=&password=&email=&cpf=00000000000&rg=0000000&telephone=&university=&course=">
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
			<span>person.getEvents(<b>tokenID</b>)</span>
			<img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=person.getEvents&tokenID=$tokenID">
		</p>

		<p class="documentFunctionDescription">Retorna todas os eventos em que a pessoa com o <i>tokenID</i> está inscrita.</p>

		<div class="documentationFunctionParametersBox">
			<p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
		</div>
	</div>

</div>