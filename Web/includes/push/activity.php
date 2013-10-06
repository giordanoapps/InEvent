<?php

	function pushActivityCreation($eventID, $activityID) {
        pushURI("activity/new", "event", $eventID, $activityID);
    }

    function pushActivityUpdate($eventID, $activityID) {
        pushURI("activity/update", "event", $eventID, $activityID);
    }

    function pushActivityRemove($eventID, $activityID) {
        pushURI("activity/remove", "event", $eventID, $activityID);
    }

?>