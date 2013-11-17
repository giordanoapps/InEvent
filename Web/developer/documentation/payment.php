<div class="documentationBox">
    <h2>Pagamento</h2>
    
    <p>Para cada inscrição no evento, podemos utilizar o <i>gateway</i> do MercadoPago para lidar com todos os pagamentos.</p>

    <h3 class="documentationHeader">Funções</h3>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>payment.create(<b>tokenID</b>, <b>eventID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=payment.create&tokenID=$tokenID&eventID=1" data-post="tickets=1&advertisements=0">
        </p>

        <p class="documentFunctionDescription">Cria um novo pagamento, informando a quantidade de ingressos <i>tickets</i> com tantos <i>advertisements</i> vinculados para verem anúncios no evento <i>eventID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
            <p><b>tickets</b><sub>POST</sub> : número de vagas no evento </p>
            <p><b>advertisements</b><sub>POST</sub> : número de vagas habilitadas para ver anúncios </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>payment.getPayments(<b>tokenID</b>, <b>eventID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=payment.getPayments&tokenID=$tokenID&eventID=1">
        </p>

        <p class="documentFunctionDescription">Retorna todos os pagamentos para o evento <i>eventID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>payment.requestAddress(<b>tokenID</b>, <b>eventID</b>, <b>paymentID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=payment.requestAddress&tokenID=$tokenID&eventID=1&paymentID=1">
        </p>

        <p class="documentFunctionDescription">Solicita o endereço do pagamento <i>paymentID</i> no evento <i>eventID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
            <p><b>paymentID</b><sub>GET</sub> : id do pagamento </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>payment.confirmPayment(<b>collection_id</b>, <b>eventID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=payment.confirmPayment&collection_id=notificationID&eventID=3">
        </p>

        <p class="documentFunctionDescription">Informa o pagamento da transação <i>collection_id</i> no evento <i>eventID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>collection_id</b><sub>GET</sub> : id da notificação no Mercado Pago </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
        </div>
    </div>

</div>