<div class="documentationBox">
    <h2>Foto</h2>
    
    <p>Dentro do evento, a comunicação visual é facilitada por uma sequência exclusiva de fotos. Enquanto o Facebook não implementa em seus servidores a capacidade de acessar tais fotos por uma <i>hashtag</i>, é necessário a criação de um api própria para gerenciar tais recursos. Cada foto recebe um identificador <i>photoID</i>, que é diretamente associada a uma <i>url</i> única.</p>
    
    <h3 class="documentationHeader">Push</h3>
    
    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>photo/new : <b>eventID</b></span>
            <span><img src="../images/64-Archive.png" alt="Channel">event_<b>eventID</b></span>
        </p>
        <p class="documentFunctionDescription">Informa a postagem de uma nova foto no evento <i>eventID</i>.</p>
    </div>

    <h3 class="documentationHeader">Funções</h3>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>photo.post(<b>tokenID</b>, <b>eventID</b>, <b>url</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=photo.post&tokenID=$tokenID&eventID=1" data-post="url=url">
        </p>

        <p class="documentFunctionDescription">Adiciona no evento <i>eventID</i> a foto localizada em <i>url</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
            <p><b>url</b><sub>POST</sub> : url da foto </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>photo.getPhotos(<b>tokenID</b>, <b>eventID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=photo.getPhotos&tokenID=$tokenID&eventID=1">
        </p>

        <p class="documentFunctionDescription">Retorna todos as fotos postadas no evento <i>eventID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>eventID</b><sub>GET</sub> : id do evento </p>
        </div>
    </div>

    <div class="documentationFunctionBox">
        <p class="documentFunctionName">
            <span>photo.getSingle(<b>tokenID</b>, <b>photoID</b>)</span>
            <img src="../images/64-Chemical.png" alt="Try it out!" class="tryItOut" data-get="method=photo.getSingle&tokenID=$tokenID&photoID=1">
        </p>

        <p class="documentFunctionDescription">Retorna a foto <i>photoID</i>.</p>

        <div class="documentationFunctionParametersBox">
            <p><b>tokenID</b><sub>GET</sub> : id de autenticação </p>
            <p><b>photoID</b><sub>GET</sub> : id da foto </p>
        </div>
    </div>

</div>