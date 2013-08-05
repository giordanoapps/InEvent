<?php

	/**
	 * Wrappers, functions and code for database needs
	 */

	function logout() {
		$filename = basename($_SERVER['PHP_SELF']);
		$path = str_replace($filename, '', $_SERVER['PHP_SELF']);

		$security = Security::singleton();

		setcookie($security->key, '', 0, $path);
		header("Location: $path");	
		exit("Monkeys are on the way to solve whatever you need!");
	}

?>