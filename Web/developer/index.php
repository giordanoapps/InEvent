<?php include_once("../includes/check/login.php"); ?>
<?php 

//	$url = explode(".", $_SERVER["SERVER_NAME"]);
//	$position = array_search("negociopresente", $url);
//	
//	
//	if ($position) {
//		if ($url[$position-1] != "developer") {
//			header("Location: http://developer.negociopresente.com/");
//		}
//	}
?>
<?php
	if ($globalDev == 1) {
		define("URL", "http://localhost:8888/Presenca-dev/Web/developer/api/");
	} else {
		define("URL", "http://presenca.me/developer/api/");
	}
?>
<!--

	SISTEMA PROPRIEDADE DO ESTÚDIO TRILHA (estudiotrilha.com.br)
	
	DEDICADO A MEMÓRIA DE FRANCISCO PEÇANHA MARTINS

-->
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<title>InEvent Developer - Acessar seus dados nunca foi tão fácil!</title>
	
	<!--[if lt IE 9]>
	<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
	<![endif]-->
	
	<link rel="stylesheet" href="../css/default.css" type="text/css" />
	<link rel="stylesheet" href="../css/jquery-ui-1.8.21.custom.min.css" type="text/css" />
	<link rel="stylesheet" href="../css/shCore.css" type="text/css" />
	<link rel="stylesheet" href="../css/shThemeDefault.css" type="text/css" />
	<link href='http://fonts.googleapis.com/css?family=Open+Sans:400,700' rel='stylesheet' type='text/css'>
	
	<?php if ($globalDev == 1) { ?>
	
	<script src="../js/jquery-1.8.3.min.js" type="text/javascript"></script>
	<script src="../js/jquery-ui-1.8.21.custom.min.js" type="text/javascript"></script>
	
	<?php } else { ?>
	
	<script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
	<script>!window.jQuery && document.write(unescape('%3Cscript src="../js/jquery-1.8.3.min.js"%3E%3C/script%3E'))</script>
	<script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"></script>
	<script>!window.jQuery.ui && document.write(unescape('%3Cscript src="../js/jquery-ui-1.8.21.custom.min.js"%3E%3C/script%3E'))</script>
	
	<?php } ?>
	
	<script src="../js/analytics.js" type="text/javascript"></script>
	<script src="../js/modules/functions.js" type="text/javascript"></script>
	<script src="../js/developer.js" type="text/javascript"></script>
	<script src="../js/shCore.js" type="text/javascript"></script>
	<script src="../js/shBrushJScript.js" type="text/javascript"></script>

	<link href="../favicon.ico" rel="icon" type="image/x-icon" />

</head>
<body>

	<div id="header">
		<div class="barWrapper">
			<div class="bar top">
				<ul class="leftBar">
					<a href="../" target="_blank"><li>InEvent</li></a>
				</ul>
				
				<ul class="rightBar">
					<li onclick="">Developer</li>
				</ul>
			</div>
		</div>
	</div>
	
	<div id="content">
		
		<div class="developerContent pageContent">
			
			<div class="titleContent">Desenvolvedor</div>
			
			<div class="boardContent" data-ajax="ajaxDeveloper">
		
				<div class="features menuContent">
				
					<div class="featureBox header">
						<p class="title">Sua API. Nossa API.</p>
						<p class="description">Acessar seus dados nunca foi tão fácil.</p>
					</div>
								
					<div style="clear: both;"></div>
			
				</div>
		
				<div class="documentation">
					<div class="menuDocumentation">
						<ul>
							<li class="optionMenuDocumentationCategory optionMenuDocumentationSelected"><b>Como usar</b></li>
							<!-- <li>Home</li> -->
							<!-- <li>Clientes</li> -->
							<!-- <li>Consultores</li> -->
							<!-- <li>Grupos</li> -->
							<li>Notificações</li>
							<li>Membros</li>
							<li>InEvent</li>
							<!-- <li>Projetos</li> -->
						</ul>
					</div>
					<div class="contentDocumentation">

						<?php
							include_once("documentation/howTo.php");
							// include_once("documentation/home.php");
							// include_once("documentation/client.php");
							// include_once("documentation/consultant.php");
							// include_once("documentation/group.php");
							include_once("documentation/notification.php");
							include_once("documentation/member.php");
							include_once("documentation/presence.php");
							// include_once("documentation/project.php");
						?>

						<div class="demoDocumentation">
							<div class="tokenWrapper">
								<div class="inert"><input type="text" class="token" placeholder="$tokenID"></div>
							</div>
							<div class="getWrapper">
								<div class="inert solid"><input type="text" class="getField" placeholder="GET"></div>
							</div>
							<div class="postWrapper">
								<div class="inert solid"><input type="text" class="postField" placeholder="POST"></div>
							</div>
							<pre placeholder="Nenhuma resposta até o momento! Verifique se seus parâmetros estão corretos." class="return"></pre>
						</div>

					</div>
				</div>
			</div>
		</div>
	</div>

	<?php include_once(__DIR__ . "/../includes/html/wrapper.php") ?>

</body>
</html>