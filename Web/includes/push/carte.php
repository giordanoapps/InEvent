<?php

    /**
     * Send a notification about the new 
     * @param  int $companyID       id of the company
     * @param  date $lastChange     last change
     * @return resource             the database resource
     */
    function pushCarteUpdate($carteID, $lastChange) {
        pushURI("carte/update", "carte", $carteID, $lastChange);
    }

?>