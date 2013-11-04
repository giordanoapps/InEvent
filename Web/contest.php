<?php
	include_once("includes/check/login.php");

	// Insert the person on the event
	$result = resourceForQuery(
	// echo (
		"SELECT
	        `contest`.`id`,
	        `contest`.`template`,
	        `contest`.`name`,
	        UNIX_TIMESTAMP(`contest`.`dateBegin`) AS `dateBegin`,
	        UNIX_TIMESTAMP(`contest`.`dateEnd`) AS `dateEnd`
		FROM
			`contest`
		LEFT JOIN
			`contestMember` ON `contestMember`.`contestID` = `contest`.`id`
		WHERE 1
			AND `contest`.`eventID` = $core->eventID
			AND (`contest`.`dateEnd` > NOW() OR `contestMember`.`memberID` = $core->memberID)
	");

	// See if we have an event
	if (mysql_num_rows($result) > 0) {
		// Include the default template
		// See that contests are rare, because our core IS NOT to personalize things for free and WILL NEVER BE.
		include_once("includes/template/" . mysql_result($result, 0, "template") . ".php");

	} else {
?>

	<?php include_once("includes/html/header.php") ?>
	<body>
		<?php include_once("includes/html/bar.php") ?>

			<div id="content">
				<div id="contestContent" class="pageContent">
					
					<div class="titleContent">Concursos</div>
					
					<div class="boardContent">
						<p class="byItself">Infelizmente não temos nenhum concurso aberto para esse evento :(</p>
						<p class="megaLink"><a href="marketplace.php">Seus eventos</a></p>
					</div>

				</div>
		    </div>
	    
	    <?php include_once("includes/html/wrapper.php") ?>
		
	</body>
	</html>

<?php } ?>