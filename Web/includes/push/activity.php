<?php

	function pushOrderCreation($tableID, $orderID) {
        pushURI("order/new", "table", $tableID, $orderID);
    }

    function pushOrderUpdate($tableID, $orderID) {
        pushURI("order/update", "table", $tableID, $orderID);
    }

?>