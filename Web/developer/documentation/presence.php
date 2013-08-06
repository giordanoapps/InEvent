<!-- PRESENÇA -->
<div class="documentationBox">
    <h2>InEvent</h2>

    <p>O conteúdo abaixo é referente a ferramenta InEvent.</p>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>presence.getCalendars(<b>tokenID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=presence.getCalendars&tokenID=$tokenID">
        </p>

        <p class="documentFunctionDescription">Retorna os dias do periodo especificado com as informações sobre a presença neste dia.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
        </div>
    </div>


    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>presence.getPeriod(<b>tokenID</b>, <b>calendarID</b>, <b>timestamp</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=presence.getPeriod&tokenID=$tokenID&calendarID=6&timestamp=1373166000">
        </p>

        <p class="documentFunctionDescription">Retorna o período de 7 (sete) dias iniciando no momento especificado em <i>timestamp</i> com as informações sobre a presença.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>calendarID</b><sub>GET</sub> : id do calendário </p>
            <p><b>timestamp</b><sub>GET</sub> : data <i>UNIX timestamp</i> do início do período</p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>presence.confirmPresence(<b>tokenID</b>, <b>presenceID</b>, <b>location</b>)</span>
             <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=presence.confirmPresence&tokenID=$tokenID&presenceID=1&location=123456">
        </p>

        <p class="documentFunctionDescription">Confirma a presença dentro do período <i>presenceID</i> para o membro com <i>tokenID</i> utilizando a localização <i>location</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>presenceID</b><sub>GET</sub> : id da presença </p>
            <p><b>location</b><sub>GET</sub> : localização </p>
        </div>
    </div>

</div>