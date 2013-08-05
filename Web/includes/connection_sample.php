<?php

/* Se desejar adicionar mais uma configuração, siga estes passos:

else if ($modo == x) {
	$conexao = mysql_connect ("localhost", "login", "senha");
	mysql_select_db ("bd");
}

*/


	$conexao = mysql_connect (host, user, password);
	mysql_select_db (database);


?>
