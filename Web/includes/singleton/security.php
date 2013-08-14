<?php

class Security {
    
    // Global
    public $remote = false;
    public $attempts = 0;
    public $key = "tokenID";

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
$security = Security::singleton();

?>