<?php

/* Se desejar adicionar mais uma configuração, siga estes passos:

else if ($modo == x) {
	$conexao = mysql_connect ("localhost", "login", "senha");
	mysql_select_db ("bd");
}

*/


// Choose the basic connection type
$whitelist = array('localhost', '127.0.0.1', '::1');
$remote = $_SERVER['REMOTE_ADDR'];

if (in_array($remote, $whitelist) || substr($remote, 0, 8) == "192.168.") {
    $globalDev = 1;
} else {
	$globalDev = 0;
}

if ($globalDev == 0) {
	$conn = mysql_connect("localhost", user, password);

	// See if we can connect to the development server
	if (strstr($_SERVER['HTTP_HOST'], "dev.") != FALSE) {
		mysql_select_db("et_inevent-dev");
	} else {
		mysql_select_db("et_inevent");
	}
}

else if ($globalDev == 1) {
	$conn = mysql_connect("localhost", user, password);
	mysql_select_db("inevent");
}


?>
