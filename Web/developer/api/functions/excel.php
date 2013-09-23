<?php

	/**
	 * Export some Mysql resource to an Excel spreadsheet
	 * @param  resource $result mysql resource
	 * @return file         		the saved file, encoded and headers ready to download
	 */
	function resourceToExcel($result) {

		// Import the PHPExcel parser
		include_once(__DIR__ . "/../../../classes/PHPExcel/IOFactory.php");

		// Create a new document and sheet
		$objPHPExcel = new PHPExcel();
		$objPHPExcel->createSheet();

		// Headers
		for ($j = 0; $j < mysql_num_fields($result); $j++) {
			$objPHPExcel->getActiveSheet()->setCellValueByColumnAndRow($j, 1, mysql_field_name($result, $j));
		}

		// Content
		for ($i = 1; $i < mysql_num_rows($result); $i++) {
			for ($j = 0; $j < mysql_num_fields($result); $j++) {
				$value = html_entity_decode(mysql_result($result, $i, $j), ENT_COMPAT | ENT_HTML401, "ISO-8859-1");
				$objPHPExcel->getActiveSheet()->setCellValueByColumnAndRow($j, $i + 1, $value);
			}
		}

		// Redirect output to client browser
		header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
		header('Content-Disposition: attachment;filename="document.xlsx"');
		header('Cache-Control: max-age=0');

		$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel2007');
		$objWriter->save('php://output');

	}

	/**
	 * Import some Excel spreadsheet inside a Mysql table
	 * @param  resource  $path 	file path
	 * @param  string 	 $type 		
	 * @return null
	 */
	function saveFromExcel($path, $type, $referenceID) {

		// Import the PHPExcel parser
		include_once(__DIR__ . "/../../../classes/PHPExcel/IOFactory.php");

		// Number of rows on the spreadsheet
		$totalRows = -1;

		// Create an absolute path
		$absolutePath = __DIR__ . "/../../../" . $path;

		// And check that it exists and has a valid path
		if (file_exists($absolutePath)) {

			// And if the format is right
			if (pathinfo($absolutePath, PATHINFO_EXTENSION) == "xlsx") {

				// Read the object
				$objReader = PHPExcel_IOFactory::createReader('Excel2007');
				$objReader->setReadDataOnly(true);
				$objPHPExcel = $objReader->load($absolutePath);
				$objWorksheet = $objPHPExcel->getActiveSheet();
				$totalRows = $objPHPExcel->getActiveSheet()->getHighestRow();

				foreach ($objWorksheet->getRowIterator() as $row) {

					// Clean the variables
					// Item
					$name = "";
					$email = "";
					
					// Get the cell iterator
					$cellIterator = $row->getCellIterator();
					// This loops all cells, even if it is not set.
					// By default, only cells that are set will be iterated.
					$cellIterator->setIterateOnlyExistingCells(false);

					foreach ($cellIterator as $key => $cell) {
						$value = getEmptyAttribute($cell->getValue());

						// Process each type of column
						switch ($key) {
							case 0:
								$name = $value;
								break;
							case 1:
								$email = $value;
								break;
						}
					}

					// Get the person for the given email
					$personID = getPersonForEmail($email, $name);

					if ($type == "event") {
						// Enroll the person at all the activities
						processEventEnrollmentWithEvent($referenceID, $personID);
					} elseif ($type == "activity") {
						// Enroll the person at the event if necessary
						processActivityEnrollment($referenceID, $personID);
					}

					// Decrement the unwritten rows
					$totalRows--;
				}
			} else {
				http_status_code(405, "file must be on .xlsx format");
			}
		} else {
			http_status_code(404, "file must exist");
		}

		// Response code
		if ($totalRows != 0) http_status_code(500);

	}
?>