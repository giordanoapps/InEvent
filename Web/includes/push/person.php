<?php

	function pushPersonPromotion($eventID, $personID) {
		$event = getEventName($eventID);
        pushURI("person/promote", "person", $personID, $eventID, "Seus privilégios foram promovidos no evento $event.");
    }

    function pushPersonDemote($eventID, $personID) {
        $event = getEventName($eventID);
        pushURI("person/demote", "person", $personID, $eventID, "Seus privilégios foram removidos no evento $event.");
    }

?>