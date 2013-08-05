<?php

class Date {
    
    // Global
    public $monday = false;
    public $weekFromNow = 0;

    // Store a class instance
    static private $instance;

    // Our private constructor
    private function __construct() {
        $now = getdate();
        $this->monday = date("c", mktime(0, 0, 0, $this->now["mon"], $this->now["mday"] - $this->now["wday"] + 1, $this->now["year"]));
    }

    // Singleton method
    static public function singleton() {

        if (!isset(self::$instance)) {
            $c = __CLASS__;
            self::$instance = new $c;
        }

        return self::$instance;
    }
}

?>