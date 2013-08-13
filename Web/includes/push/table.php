<?php

    function pushRequestTableValidation($tableID) {
        pushURI("table/request/validate", "table", $tableID, $tableID);
    }

    function pushRequestTableClosure($tableID) {
        pushURI("table/request/close", "table", $tableID, $tableID);
    }

    function pushRequestWaiter($tableID) {
        pushURI("table/request/waiter", "table", $tableID, $tableID);
    }

    function pushConfirmTableValidation($tableID) {
        pushURI("table/confirmation/validate", "table", $tableID, $tableID);
    }

    function pushConfirmTableClosure($tableID) {
        pushURI("table/confirmation/close", "table", $tableID, $tableID);
    }

    function pushConfirmWaiter($tableID) {
        pushURI("table/confirmation/waiter", "table", $tableID, $tableID);
    }

?>