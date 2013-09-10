var modules = [];
modules.push('jquery');
modules.push('common');
modules.push('google.maps');

define(modules, function($) {$(function() {

// ------------------------------------- LOCATION ------------------------------------- //

	/**
	 * Page initialization
	 * @return {null}
	 */
	$("#locationContent").on("hashDidLoad", function() {

		// Some variables
		var $locationContent = $(this);
		var $mapLocation = $locationContent.find("#mapCanvas");
		var $searchLocation = $locationContent.find(".searchLocation");

		var registrationData = JSON.parse(localStorage.getItem("registrationData")) || {};

		if (registrationData || $searchLocation.hasClass("writtenOnStone")) {
			// First we try to capture the data directly from our database
			var longitude = $searchLocation.attr("data-longitude");
			var latitude = $searchLocation.attr("data-latitude");
			var text = $searchLocation.val();

			// Process the current state of the location
			if (typeof longitude === 'undefined' || longitude === false || longitude == "") {
				longitude = registrationData.longitude;
				latitude = registrationData.latitude;
				text = registrationData.address + " " + registrationData.city;
			}

			// Update the address
			$searchLocation.val(text);

			// Set the values
			if (longitude && latitude) {
				// If we already have the location, we just mark it
				// We instantiate the map
				var locationData = $mapLocation.np("geoMap");

				try {
					// And we get the coordinates and send to the object
					initialLocation = new google.maps.LatLng(latitude, longitude);

					// Update the coordinates
					locationData.marker.setPosition(initialLocation);
					locationData.map.setCenter(initialLocation);
				} catch (Exception) {
					console.log("Location could not be loaded");
				}

			} else {
				// Otherwise we search for it
				var locationData = $mapLocation.np("geocoder", text);
			}

		} else {
			var locationData = $mapLocation.np("geolocate");
		}

    	// Save the location data
    	$locationContent.data("locationData", locationData);

	});

	/**
	 * Search for an address and display it
	 * @return {null}
	 */
	$("#locationContent").on("submit", "searchLocationWrapper", function() {
		
		var text = $(this).find(".searchLocation").val();
		$("#locationContent #mapCanvas").np("geocoder", text);
		
		return false;
	});

	/**
	 * Data must be saved before advancing
	 * @return {null}
	 */
	$("#locationContent").on("click", ".navigator li, .sequenceContent li", function() {

		var $parent = $(this).parents("#locationContent");

		// Load the data from the database
		var locationData = $parent.data("locationData");
		var registrationData = JSON.parse(localStorage.getItem("registrationData")) || {};

		// Define longitude and latitude
		registrationData.longitude = locationData.marker.getPosition().lng();
		registrationData.latitude = locationData.marker.getPosition().lat();

		// We save the data in a cookie just to be sure that the user keep it no matter what
		localStorage.setItem("registrationData", JSON.stringify(registrationData));

		if (registrationData.longitude && registrationData.latitude) {
			// Release the anchor and load the new page
			$(this).closest("a").attr("data-lock", "no").trigger("click");
		}

	});

});});