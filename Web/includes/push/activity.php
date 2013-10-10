<?php

	function pushActivityCreation($eventID, $activityID) {
		$activity = getActivityName($activityID);
		$event = getEventName($eventID);
        pushURI("activity/new", "event", $eventID, $activityID, "A atividade $activity foi criada no evento $event.");
    }

    function pushActivityUpdate($eventID, $activityID) {
		$activity = getActivityName($activityID);
		$event = getEventName($eventID);
        pushURI("activity/update", "event", $eventID, $activityID, "A atividade $activity foi atualizada no evento $event.");
    }

    function pushActivityRemove($eventID, $activityID) {
		$activity = getActivityName($activityID);
		$event = getEventName($eventID);
        pushURI("activity/remove", "event", $eventID, $activityID, "A atividade $activity foi removida do evento $event.");
    }

?>