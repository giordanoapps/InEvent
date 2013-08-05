<?php

	/**
	 * Wrappers for api needs
	 */

    /**
     * Print the query result in a given output format
     * @param  string 	$table  table name
     * @param  resource $result query result
     * @param  boolean 	$data   enable data output
     * @param  string 	$format output format
     * @return object 			encoded data
     */
	function printInformation($table, $result, $data, $format = "json") {
		$notificationText["count"] = mysql_num_rows($result);
		
		$secretFields = array("password", "permission", "companyName", "cnpj", "cpf", "sessionKey", "sessionAmount", "notificationTypeID", "delivered");

		if ($data == true) {
			$notificationText["data"] = array();
			
			for ($i = 0; $i < mysql_num_rows($result); $i++) {
			
				$row = mysql_fetch_row($result);
				// And then creating bindings by their variable name
				for ($j = 0; $j < mysql_num_fields($result); $j++) {
					$field = mysql_field_name($result, $j);
					
					if (in_array($field, $secretFields) == FALSE) {
						$notificationText["data"][$i][$field] = utf8_encode($row[$j]);
					}
				}
				
			}
		}
		
		// We check the format and return the requested information
		if ($format == "json") {
			return json_encode($notificationText);
		} else 

		if ($format == "object") {
			return $notificationText;
		}
	}

	/**
	 * Query the given table and select the output format
	 * @param  string $table    table name
	 * @param  string $extraSql aditional sql parameters
	 * @param  string $format   output format
	 * @return object           encoded data
	 */
	function informationForTable($table, $extraSql = '', $format) {

        $result = resourceForQuery("SELECT * FROM `$table` $extraSql");

        return printInformation($table, $result, true, $format);
    }
	
	/**
	 * Count the query result inside the given table inside a given enterprise and select the output format
	 * @param  string $table    			table name
	 * @param  integer $companyID    enterprise id
	 * @param  string $extraSql 			aditional sql parameters
	 * @param  string $format   		output format
	 * @return object           		encoded data
	 */
	function informationCountForEnterpriseID($table, $companyID, $extraSql = '', $format) {
		
		$result = resourceForQuery("SELECT * FROM `$table` WHERE `companyID`=$companyID $extraSql");
		
		return printInformation($table, $result, false, $format);
	}
	
	/**
	 * Query the given table inside a given enterprise and select the output format
	 * @param  string $table    			table name
	 * @param  integer $companyID    enterprise id
	 * @param  string $extraSql 			aditional sql parameters
	 * @param  string $format   		output format
	 * @return object           		encoded data
	 */
	function informationForEnterpriseID($table, $companyID, $extraSql = '', $format) {
		
		$result = resourceForQuery("SELECT * FROM `$table` WHERE `companyID`=$companyID $extraSql");

		return printInformation($table, $result, true, $format);
	}
	
	/**
	 * Query the given table inside a given enterprise using a unique id and select the output format
	 * @param  string $table    			table name
	 * @param  integer $companyID    enterprise id
	 * @param  integer $uniqueID 		unique id
	 * @param  string $extraSql 			aditional sql parameters
	 * @param  string $format   		output format
	 * @return object           		encoded data
	 */
	function informationForEnterpriseIDForUniqueID($table, $companyID, $uniqueID, $extraSql = '', $format) {
		
		$result = resourceForQuery("SELECT * FROM `$table` WHERE `companyID`=$companyID AND `id`=$uniqueID $extraSql");

		return printInformation($table, $result, true, $format);
	}
?>