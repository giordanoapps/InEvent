<?php header('Content-Type:application/javascript; charset=UTF-8'); ?>
<?php

	// Define the javascript modules
	$modules = array(
		"validator.js",
		"np.js",
		"field.js",
		"ajax.js",

		"loaders.js",
		"functions.js",
		"window.js",
		"collection.js",
		"infoContainer.js",
		"notification.js",
		"search.js",
		"select.js",
		"userSettings.js",

		"home.js",
		"bar.js",
		"data.js",
		"location.js",
		"register.js",
	);

	$hashes = "";

	// Include the modules
	for ($i = 0; $i < count($modules); $i++) {
		include_once("modules/" . $modules[$i]);
		$hashes .= md5_file("modules/" . $modules[$i]);
	}

	echo "// Hash: " . md5($hashes) . "\n";
?>