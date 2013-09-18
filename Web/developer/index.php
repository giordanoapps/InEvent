<?php include_once("../includes/check/login.php"); ?>
<?php
	if ($globalDev == 1) {
		define("URL", "http://inevent:8888/developer/api/");
	} else {
		$host = (strstr($_SERVER['HTTP_HOST'], "dev.") != FALSE) ? "dev.inevent.us" : "inevent.us";

		define("URL", "http://" . $host . "/developer/api/");
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
	<link rel="stylesheet" href="../css/jquery-ui-1.9.2.custom.min.css" type="text/css" />
	<link rel="stylesheet" href="../css/shCore.css" type="text/css" />
	<link rel="stylesheet" href="../css/shThemeDefault.css" type="text/css" />
	
	<script src="../js/lib/shCore.js" type="text/javascript"></script>
	<script src="../js/lib/shBrushJScript.js" type="text/javascript"></script>
	<script src="../js/lib/require.js" type="text/javascript" data-main="../js/developer"></script>
	
	<link href="../favicon.ico" rel="icon" type="image/x-icon" />
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
			
			<div class="boardContent">
		
				<div class="documentation">
					<div class="menuDocumentation">
						<ul>
							<li class="optionMenuDocumentationCategory optionMenuDocumentationSelected"><b>Como usar</b></li>
							<li>Atividade</li>
							<li>Evento</li>
							<li>Notificação</li>
							<li>Pessoa</li>
						</ul>
					</div>
					<div class="contentDocumentation">

						<?php
							include_once("documentation/howTo.php");
							include_once("documentation/activity.php");
							include_once("documentation/event.php");
							include_once("documentation/notification.php");
							include_once("documentation/person.php");
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