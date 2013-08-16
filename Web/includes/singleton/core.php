<?php

class Core {

    // Global
    public $auth = false;

    // Member
    public $name = "";
    public $memberID = 0;

    // Company
    public $eventID = 0;
    public $workAtEvent = false;
    public $roleID = ROLE_ATTENDEE;
    
	// Store a class instance
    static private $instance;

    // Singleton method
    static public function singleton() {
        
        if (!isset(self::$instance)) {
            $c = __CLASS__;
            self::$instance = new $c;
        }

        return self::$instance;
    }
}

// Instantiate the object
$core = Core::singleton();
    
?>