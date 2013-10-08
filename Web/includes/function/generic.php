<?php

    /**
     * Wrappers, functions and code for database needs
     */

    /**
     * Wrapper to run a query, process any errors
     * @param  string   $query  Query
     * @return object       query resource or boolean
     */
    function resourceForQuery($query) {
        $result = mysql_query(replaceConstantForQuery($query)) or trigger_error(mysql_error() . " @ " . $query);
        
        return $result;
    }

    /**
     * Replace all constants prepended with a @ with the value of the constant
     * @param  string $s string
     * @return string    string
     */
    function replaceConstantForQuery($query) {
        
        // Init with the first position
        $currentChar = 0;

        // Get the position of @
        while (($firstChar = strpos($query, "@(", $currentChar)) !== FALSE) {
            
            // Find the end position
            $lastChar = strpos($query, ")", $firstChar);

            // Round to the end if whitespace wasn't found
            if ($lastChar === FALSE) $lastChar = strlen($query);

            // Get the constant name
            $constant = substr($query, $firstChar + 2, $lastChar - ($firstChar + 2));

            // Get its value
            $value = constant($constant);

            // Replace it
            $query = substr_replace($query, $value, $firstChar, ($lastChar + 1) - $firstChar);

            // Advance to the next, trimming the difference between the constant and the value
            $currentChar = $lastChar - (strlen($constant) - strlen($value));
        }

        return $query;
    }

    /**
     * Allow an attribute to be empty
     * @param  object $attr The given object
     * @return object       The cleaned $attr
     */
    function getEmptyAttribute($attr) {

        if (isset($attr)) {

            // If it is an array, we can parse all its elements
            if (is_array($attr)) {
                $attribute = array_map("getAttribute", $attr);
            // Else, we can parse the string
            } elseif(is_string($attr)) {
                $attribute = trim(htmlentities($attr, ENT_QUOTES, "UTF-8"));
            } else {
                $attribute = $attr;
            }

            return $attribute;

        } else {
            return "";
        }
    }

    /**
     * Get an attribute by running security checks
     * @param  object $attr The given object
     * @return object       The cleaned $attr
     */
    function getAttribute($attr) {

        $attribute = getEmptyAttribute($attr);

        if (function_exists("http_status_code") && $attribute == "") {
            http_status_code(409, "Attribute cannot be empty");
        } else {
            return $attribute;
        }
    }

    function clean($value) {

        if (is_array($value)) {
            foreach ($value as $k => $v) {
                $value[$k] = clean($v);
            }
        } else {
            if (get_magic_quotes_gpc() == 1) {
                $value = stripslashes($value);
            }

            $value = trim(htmlspecialchars($value, ENT_QUOTES, "UTF-8")); //convert input into friendly characters to stop XSS
            $value = mysql_real_escape_string($value);
        }
   
        return $value;
    }

    /**
     * Current implementation of the http_status_code function
     */
    function http_status_code($code, $message = "") {

        if (!empty($code)) {

            switch ($code) {
                case 100: $text = 'Continue'; break;
                case 101: $text = 'Switching Protocols'; break;
                case 200: $text = 'OK'; break;
                case 201: $text = 'Created'; break;
                case 202: $text = 'Accepted'; break;
                case 203: $text = 'Non-Authoritative Information'; break;
                case 204: $text = 'No Content'; break;
                case 205: $text = 'Reset Content'; break;
                case 206: $text = 'Partial Content'; break;
                case 300: $text = 'Multiple Choices'; break;
                case 301: $text = 'Moved Permanently'; break;
                case 302: $text = 'Moved Temporarily'; break;
                case 303: $text = 'See Other'; break;
                case 304: $text = 'Not Modified'; break;
                case 305: $text = 'Use Proxy'; break;
                case 400: $text = 'Bad Request'; break;
                case 401: $text = 'Unauthorized'; break;
                case 402: $text = 'Payment Required'; break;
                case 403: $text = 'Forbidden'; break;
                case 404: $text = 'Not Found'; break;
                case 405: $text = 'Method Not Allowed'; break;
                case 406: $text = 'Not Acceptable'; break;
                case 407: $text = 'Proxy Authentication Required'; break;
                case 408: $text = 'Request Time-out'; break;
                case 409: $text = 'Conflict'; break;
                case 410: $text = 'Gone'; break;
                case 411: $text = 'Length Required'; break;
                case 412: $text = 'Precondition Failed'; break;
                case 413: $text = 'Request Entity Too Large'; break;
                case 414: $text = 'Request-URI Too Large'; break;
                case 415: $text = 'Unsupported Media Type'; break;
                case 500: $text = 'Internal Server Error'; break;
                case 501: $text = 'Not Implemented'; break;
                case 502: $text = 'Bad Gateway'; break;
                case 503: $text = 'Service Unavailable'; break;
                case 504: $text = 'Gateway Time-out'; break;
                case 505: $text = 'HTTP Version not supported'; break;
                default:
                    exit('Unknown http status code "' . htmlentities($code) . '"');
                break;
            }

            $protocol = (isset($_SERVER['SERVER_PROTOCOL']) ? $_SERVER['SERVER_PROTOCOL'] : 'HTTP/1.0');
            
            // Append the content if not empty
            if (!empty($message)) $message = " - " . $message;

            header($protocol . ' ' . $code . ' ' . $text . "$message");

            $GLOBALS['http_status_code'] = $code;

        } else {

            $code = (isset($GLOBALS['http_status_code']) ? $GLOBALS['http_status_code'] : 200);

        }

        // We must kill the requisition
        die($code);
    }
?>