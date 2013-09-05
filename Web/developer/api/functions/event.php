<?php

	function groupActivitiesInDays($data) {

		$dayTimestamp = 0;
		$days = -1;

		$convertedData = array();
		$convertedData["count"] = 0;
		$convertedData["data"] = array();

		for ($i = 0; $i < $data["count"]; $i++) {
			
			$activityData = $data["data"][$i];

            if ($dayTimestamp != date("z", $data['dateBegin'])) {
                $dayTimestamp = date("z", $data['dateBegin']);

                $days++;

                $convertedData["data"][] = array();
                // $convertedData["data"][$days]["dateDay"] = $dayTimestamp;
            }

            $convertedData["data"][$days][] = $data["data"][$i];
        }

        $convertedData["count"] = count($convertedData["data"]);

        return $convertedData;
	}


?>