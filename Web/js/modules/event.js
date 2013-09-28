var modules = [];
modules.push('jquery');
modules.push('common');
modules.push('modules/cookie');
modules.push('jquery.scrollbar');
modules.push('jquery.chosen');

define(modules, function($, common, cookie) {$(function() {

// -------------------------------------- LOADER -------------------------------------- //
	
	/**
	 * Page initialization
	 * @return {null}
	 */
	$("#eventContent").on("hashDidLoad", function() {
		// Create the scrollable container
		$(this).find(".placerContent > ul, .realContent").perfectScrollbar();
	});

// -------------------------------------- MENU -------------------------------------- //

	/**
	 * Add a item to the person schedule
	 * @return {null}
	 */
	$("#eventContent").on("click", ".toolEnroll", function() {

		var $elem = $(this);
		var $agendaItem = $elem.closest(".agendaItem");

		if ($agendaItem.length > 0) {
			var namespace = "activity";
			var eventID = undefined;
			var activityID = $agendaItem.val();
			var groupID = parseInt($agendaItem.attr("data-group"), 10);
		} else {
			var namespace = "event";
			var eventID = cookie.read("eventID");
			var activityID = undefined;
		}

		// Hide the current button
		$elem.hide(200);

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: namespace + ".requestEnrollment",
			activityID: activityID,
			eventID: eventID,
			format: "html"
		}), {},
		function(data, textStatus, jqXHR) {

			if (jqXHR.status == 200) {

				if ($agendaItem.length > 0) {

					// Change the properties of the element
					$elem.removeClass("toolEnroll").addClass("toolEnrolled").val("Inscrito").fadeIn(300);

					// var $scheduleItem = $(data).addClass("scheduleItemInvisible");

					// Find and replace the new element
					// $(".scheduleItem[value = \"" + activityID + "\"]").replaceWith($scheduleItem);
					// $scheduleItem.slideDown(300);

					// Hide all activities that belong to the same group
					// if (groupID != 0) $(".agendaItem[data-group = \"" + groupID + "\"]").find(".toolEnroll").hide(200);

				} else {
					// Reload page
					window.location.reload();
				}
			}

		}, 'html').fail(function(jqXHR, textStatus, errorThrown) {
			$elem.fadeIn(300);
		});

	});

	/**
	 * Remove a item from the person schedule
	 * @return {null}
	 */
	$("#eventContent").on("mouseenter", ".toolEnrolled", function() {
		$(this).removeClass("toolEnrolled").addClass("toolExpel").val("Sair da atividade");
	});

	$("#eventContent").on("mouseleave", ".toolExpel", function() {
		// We must verify that the current row has the class and has the same state
		if ($(this).hasClass("toolExpel")) {
			$(this).removeClass("toolExpel").addClass("toolEnrolled").val("Inscrito");
		}
	});
	
	/**
	 * Remove a item from the person schedule
	 * @return {null}
	 */
	$("#eventContent").on("click", ".toolExpel", function() {

		var $elem = $(this);
		var activityID = $elem.closest(".agendaItem").val();

		// Hide the current button
		$elem.hide(300);

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "activity.dismissEnrollment",
			activityID: activityID,
			format: "html"
		}), {},
		function(data, textStatus, jqXHR) {

			if (jqXHR.status == 200) {
				// Change the properties of the element
				$elem.removeClass("toolExpel").addClass("toolEnroll").val("Inscrever").fadeIn(300);
			}

		}, 'html').fail(function(jqXHR, textStatus, errorThrown) {
			$elem.fadeIn(300);
		});

	});

	/**
	 * Remove a item from the person schedule
	 * @return {null}
	 */
	$("#eventContent").on("click", ".toolPriority", function() {

		var $elem = $(this);
		var activityID = $elem.closest(".scheduleItem").val();

		// Hide the current button
		var method = ($(this).hasClass("toolSelected")) ? "decreasePriority" : "risePriority";

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "activity." + method,
			activityID: activityID,
			format: "html"
		}), {},
		function(data, textStatus, jqXHR) {
			if (jqXHR.status == 200) $elem.toggleClass("toolSelected");
		}, 'html');

	});

	/**
	 * Remove a item from the person schedule
	 * @return {null}
	 */
	$("#eventContent").on("click", ".toolCertificate", function() {
		// Move to the certificate page
		window.location.hash = "certificate";
	});

	/**
	 * Close all the inputs that are open
	 * @return {null}
	 */
	$("#eventContent").on("click", ".toolBox .toolDone", function() {

		// Prepare the trigger
		var event = jQuery.Event("keyup");
		event.which = 13;

		// Send it
		$("#eventContent .titleInput").trigger(event);
	});


	/**
	  * TEXT BOX
	  */
	 
	/**
	 * Start a text inline edition
	 * @return {null}
	 */
	$("#eventContent").on("click", ".agendaItem .name, .agendaItem .description, .agendaItem .location, .agendaItem .capacity", function(event) {

		if (!$("#eventContent").hasClass("editingMode")) return true;
		if ($(this).hasClass("titleInput")) return true;

		// Get the value
		var value = $(this).text();

		// Create the input
		$(this).field("createField", "input", { "class" : $(this).attr("class") + " titleInput", "value" : value, "placeholder": value }).focus();

		// Stop propagating
		event.stopPropagation();

    	// Prevent the anchor from propagating
    	event.preventDefault();
	    return false;
	});

	/**
	 * Conclude a text inline edition
	 * @return {null}
	 */
	$("#eventContent").on("keyup", ".agendaItem .titleInput", function(event) {

		var code = (event.keyCode ? event.keyCode : event.which);
		// Enter keycode
		if (code == 13) {

			var $elem = $(this);
			var $agendaItem = $elem.closest(".agendaItem");

			var activityID = $agendaItem.val();
			var value = $elem.val();
			var name = $elem.attr("name");

			$elem = $elem.field("removeField", {"class": "name"});

			// We request the information on the server
			$.post('developer/api/?' + $.param({
				method: "activity.edit",
				activityID: activityID,
				name: name,
				format: "html"
			}), {
				value: value
			},
			function(data, textStatus, jqXHR) {

				if (jqXHR.status == 200) {
					// Replace the entry
					$agendaItem.replaceWith(data);
				}

			}, 'html').fail(function(jqXHR, textStatus, errorThrown) {});
		}

	});
	
	/**
	  * CALENDAR BOX
	  */

	/**
	 * Load the clocks
	 * @return {null}
	 */
	$("#eventContent").on("click", ".agendaItem .dateBegin, .agendaItem .dateEnd", function() {

		if (!$("#eventContent").hasClass("editingMode")) return true;

		// Get some properties
		var $agendaItem = $(this).closest(".agendaItem");
		var $toolBonusCalendar = $("#eventContent .toolBonusCalendar");

		// Move or hide the tool
		if ($toolBonusCalendar.prev().is($agendaItem)) {
			$toolBonusCalendar.slideToggle(200);	
		} else {
			$toolBonusCalendar.insertAfter($agendaItem).slideDown(200);
		}

		// Create both date objects
		var dateBegin = new Date(parseInt($agendaItem.attr("data-dateBegin"), 10) * 1000);
		var dateEnd = new Date(parseInt($agendaItem.attr("data-dateEnd"), 10) * 1000);

		// Write the components
		// ("0" + (this.getMonth() + 1)).slice(-2)
		$toolBonusCalendar.find(".monthBegin").val(("0" + (dateBegin.getMonth() + 1)).slice(-2));
		$toolBonusCalendar.find(".dayBegin").val(("0" + dateBegin.getDate()).slice(-2));
		$toolBonusCalendar.find(".hourBegin").val(("0" + dateBegin.getHours()).slice(-2));
		$toolBonusCalendar.find(".minuteBegin").val(("0" + dateBegin.getMinutes()).slice(-2));
		$toolBonusCalendar.find(".monthEnd").val(("0" + (dateEnd.getMonth() + 1)).slice(-2));
		$toolBonusCalendar.find(".dayEnd").val(("0" + dateEnd.getDate()).slice(-2));
		$toolBonusCalendar.find(".hourEnd").val(("0" + dateEnd.getHours()).slice(-2));
		$toolBonusCalendar.find(".minuteEnd").val(("0" + dateEnd.getMinutes()).slice(-2));

		// Update the clocks onscreen
		$toolBonusCalendar.find("input").trigger("keyup");
	});

	/**
	 * Update the hour and minute everytime the human hits any key
	 * @return {null}
	 */
	$("#eventContent").on("keyup", ".calendarBox .hour", function () {
		
		var hour = parseInt($(this).val(), 10);

		if (hour < 24) {
			$(this).removeClass("badTime");

			var mins = parseInt($(this).siblings(".minute").val(), 10) || 0;
			var hdegree = hour * 30 + (mins / 2);
			var hrotate = "rotate(" + hdegree + "deg)";

			$(this).closest(".timeBox").siblings(".clock").find("#hour").css({
				"-webkit-transform": hrotate,
				"-moz-transform": hrotate,
				"-ms-transform": hrotate,
				"-o-transform": hrotate,
				"transform": hrotate,
			});
		} else {
			$(this).addClass("badTime");
		}
	});

	/**
	 * Update the minute everytime the human hits any key
	 * @return {null}
	 */
	$("#eventContent").on("keyup", ".calendarBox .minute", function () {

		var mins = parseInt($(this).val(), 10) || 0;

		if (mins < 60) {
			$(this).removeClass("badTime");

			var mdegree = mins * 6;
			var mrotate = "rotate(" + mdegree + "deg)";

			// Update the hour
			$(this).siblings(".hour").trigger("keyup");

			// Update the minute
			$(this).closest(".timeBox").siblings(".clock").find("#min").css({
				"-webkit-transform": mrotate,
				"-moz-transform": mrotate,
				"-ms-transform": mrotate,
				"-o-transform": mrotate,
				"transform": mrotate,
			});
		} else {
			$(this).addClass("badTime");
		}
	});

	/**
	 * Send all the updates times to the server
	 * @return {null}
	 */
	$("#eventContent").on("focusout", ".calendarBox input", function () {

		if (!$(this).hasClass("badTime")) {

			// Fresh filter
			$(this).val(("0" + parseInt($(this).val())).slice(-2));

			// Get some properties
			var activityID = $(this).closest(".toolBonusCalendar").prev().val();
			var name = $(this).attr("name");
			var value = $(this).val();

			// Save it
			$.post('developer/api/?' + $.param({
				method: "activity.edit",
				activityID: activityID,
				name: name,
				format: "html"
			}), {
				value: value
			});
		}
	});

	/**
	  * MAP BOX
	  */

	/**
	 * Load the map
	 * @return {null}
	 */
	$("#eventContent").on("click", ".agendaItem #local", function(event) {

		if (!$("#eventContent").hasClass("editingMode")) return true;
		
		// Some variables
		var $agendaItem = $(this).closest(".agendaItem");
		var $toolBonusMap = $("#eventContent .toolBonusMap");
		var $mapLocation = $toolBonusMap.find("#mapCanvas");

		// Move or hide the tool
		if ($toolBonusMap.prev().is($agendaItem)) {
			$toolBonusMap.slideToggle(200);	
		} else {
			$toolBonusMap.insertAfter($agendaItem).slideDown(200);
		}

		// First we try to capture the data directly from our database
		var activityID = $agendaItem.val();
		var latitude = $agendaItem.attr("data-latitude");
		var longitude = $agendaItem.attr("data-longitude");
		var location = $agendaItem.attr("data-location");

		// Set the values
		if (latitude != 0 && longitude != 0) {
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

		} else if (location && location.length > 0) {
			// Otherwise we search for it
			var locationData = $mapLocation.np("geocoder", location);

		} else {
			// Lastly we try to locate it
			var locationData = $mapLocation.np("geolocate");
		}

		// Rewrite the attributes when the marker changes
		google.maps.event.addListener(locationData.marker, "dragend", function() {
			$agendaItem.attr("data-latitude", locationData.marker.getPosition().lat());
			$agendaItem.attr("data-longitude", locationData.marker.getPosition().lng());

			// Latitute
			$.post('developer/api/?' + $.param({
				method: "activity.edit",
				activityID: activityID,
				name: "latitude",
				format: "html"
			}), {
				value: locationData.marker.getPosition().lat()
			});

			// Longitude
			$.post('developer/api/?' + $.param({
				method: "activity.edit",
				activityID: activityID,
				name: "longitude",
				format: "html"
			}), {
				value: locationData.marker.getPosition().lng()
			});
		});

    	// Save the location data
    	$toolBonusMap.data("locationData", locationData);

    	// Prevent the anchor from propagating
    	event.preventDefault();
	    return false;
	});

});});