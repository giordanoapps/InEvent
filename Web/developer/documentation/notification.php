<!-- NOTIFICAÇÕES -->
<div class="documentationBox">
    <h2>Notificações</h2>
    
    <p>O conteúdo abaixo é referente a ferramenta Notificações. O número retornado de notificações varia para cada função.</p>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>notification.getNumberOfNotifications(<b>tokenID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=notification.getNumberOfNotifications&tokenID=$tokenID">
        </p>
        
        <p class="documentFunctionDescription">Retorna o número de notificações para o <i>tokenID</i> fornecido.</p>
        
        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
        </div>
    </div>
    
    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>notification.getLastNotificationID(<b>tokenID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=notification.getLastNotificationID&tokenID=$tokenID">
        </p>

        <p class="documentFunctionDescription">Retorna o id da última notificação para o <i>tokenID</i> fornecido.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
        </div>
    </div>
    
    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>notification.getNotificationsSinceNotification(<b>tokenID</b>, <b>lastNotificationID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=notification.getNotificationsSinceNotification&tokenID=$tokenID&lastNotificationID=1">
        </p>

        <p class="documentFunctionDescription">Retorna uma lista com as notificações mais recentes que <i>lastNotificationID</i> para o <i>tokenID</i> fornecido.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>lastNotificationID</b><sub>GET</sub> : id da última notificação recebida </p>
        </div>
    </div>
    
    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>notification.getNotificationsWithOffset(<b>tokenID</b>, <b>offset</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=notification.getNotificationsWithOffset&tokenID=$tokenID&offset=10">
        </p>

        <p class="documentFunctionDescription">Retorna uma lista com as últimas notificações partindo da posição definida por <i>offset</i> para o <i>tokenID</i> fornecido.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>offset</b><sub>GET</sub> : número inteiro referente a posição de início </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>notification.getSingleNotification(<b>tokenID</b>, <b>notificationID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=notification.getSingleNotification&tokenID=$tokenID&notificationID=1">
        </p>

        <p class="documentFunctionDescription">Retorna a notificação <i>notificationID</i> para <i>tokenID</i> fornecido.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>notificationID</b><sub>GET</sub> : id da notificação </p>
        </div>
    </div>

</div>