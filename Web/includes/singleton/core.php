<?php

class Core {

	// User Settings
    public $auth = false;
    public $name = "";
    public $companyID = 0;
    public $memberID = 0;
    public $groupID = 0;
    public $permission = 0;
    
    public $authenticatedMAC = false;
    
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