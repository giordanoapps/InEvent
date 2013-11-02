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
	 * Add an activity to the event
	 * @return {null}
	 */
	$("#eventContent").on("click", ".toolAdd", function() {

		// Hide the current button
		var $elem = $(this).hide(200);

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "activity.create",
			eventID: cookie.read("eventID"),
			format: "html"
		}), {},
		function(data, textStatus, jqXHR) {

			if (jqXHR.status == 200) {
				$(".realContent > ul").prepend($(data).hide(0).slideDown(300));
			}

			$elem.fadeIn(300);

		}, 'html').fail(function(jqXHR, textStatus, errorThrown) {
			$elem.fadeIn(300);
		});

	});

	/**
	 * Remove an activity from the event
	 * @return {null}
	 */
	$("#eventContent").on("click", ".toolRemove", function(event) {

		event.stopPropagation();

		var $name = $(this).closest(".agendaItem").find(".name");
		var name = $name.text();
		var firstName = name.split(" ")[0];

		// Create the input
		$name
			.field("createField", "input", {
				"class" : "titleInputRemove",
				"value" : "",
				"placeholder": "Digite: " + firstName,
				"data-first": firstName,
				"data-name": name,
			}).focus();

		// Hide the current button
		$(this).hide(300);

	});

	/**
	 * Confirm removal of an activity from the event
	 * @return {null}
	 */
	$("#eventContent").on("keyup", ".titleInputRemove", function() {

		var code = (event.keyCode ? event.keyCode : event.which);
		// Enter keycode
		if (code == 13) {

			var $elem = $(this);

			if ($elem.val() == $elem.attr("data-first")) {
				$elem = $elem.val($elem.attr("data-name")).field("removeField", {"class": "name"});

				var $agendaItem = $elem.closest(".agendaItem");

				// We request the information on the server
				$.post('developer/api/?' + $.param({
					method: "activity.remove",
					activityID: $agendaItem.val(),
					format: "html"
				}), {},
				function(data, textStatus, jqXHR) {

					if (jqXHR.status == 200) {
						$agendaItem.slideUp(300).remove();
					}

				}, 'html').fail(function(jqXHR, textStatus, errorThrown) {
					$elem.fadeIn(300);
				});
			}
		}

	});

	/**
	 * Add a item to the person schedule
	 * @return {null}
	 */
	$("#eventContent").on("click", ".toolEnroll", function() {

		// Current element
		var $elem = $(this);

		// See if the person is authenticated
		if (cookie.read("tokenID") != null) {

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
						$elem.closest(".agendaItem").replaceWith(data);

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

		} else {
			// Save it for later
			localStorage.setItem("enrollAtEvent", eventID);

			// Move to the event page
			window.location.hash = "data";
		}

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
				$elem.closest(".agendaItem").replaceWith(data);
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

		// Close all the bonus boxes
		$(".toolBonus").slideUp(300);
		
	});

	/**
	  * TEXT BOX
	  */

	/**
	 * Start a text inline edition
	 * @return {null}
	 */
	$("#eventContent").on("click", ".name, .description, .location, .capacity", function(event) {

		// Make sure that we are on editing mode
		if (!$("#eventContent").hasClass("editingMode")) return true;
		if ($(this).hasClass("titleInput")) return true;

		// Get the value
		var value = $(this).text();

		// Create the input
		$(this).field("createField", "input", {
			"class" : $(this).attr("class") + " titleInput",
			"value" : value,
			"placeholder": value,
			"maxlength": 200
		}).focus();

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
	$("#eventContent").on("keyup", ".titleInput", function(event) {

		// Remove the focus from the current field
		var code = (event.keyCode ? event.keyCode : event.which);
		if (code == 13) $(this).blur();
	});

	$("#eventContent").on("focusin", ".titleInput", function(event) {
		var $elem = $(this);
		$elem.one("focusout", function() {
			$elem.trigger("saveField");
		})
	});

	$("#eventContent").on("saveField", ".titleInput", function(event) {

		var $elem = $(this);
		var $agendaItem = $elem.closest(".agendaItem");
		if ($agendaItem.length == 0) $agendaItem = $elem.closest(".toolBonus").prev(".agendaItem");

		var activityID = $agendaItem.val();
		var value = $elem.val();
		var name = $elem.attr("name");
		
		$elem = $elem.field("removeField", {"class": $elem.attr("class").replace(/titleInput/g, "")});

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
				if (name == "capacity") $agendaItem.attr("data-" + name, value);
			}

		}, 'html').fail(function(jqXHR, textStatus, errorThrown) {});

	});
	
	/**
	  * CALENDAR BOX
	  */

	/**
	 * Load the clocks
	 * @return {null}
	 */
	$("#eventContent").on("click", ".agendaItem .dateBegin, .agendaItem .dateEnd", function() {

		// Make sure that we are on editing mode
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

		// Write the components
		// ("0" + (this.getMonth() + 1)).slice(-2)
		$toolBonusCalendar.find(".monthBegin").val($agendaItem.attr("data-monthBegin"));
		$toolBonusCalendar.find(".dayBegin").val($agendaItem.attr("data-dayBegin"));
		$toolBonusCalendar.find(".hourBegin").val($agendaItem.attr("data-hourBegin"));
		$toolBonusCalendar.find(".minuteBegin").val($agendaItem.attr("data-minuteBegin"));
		$toolBonusCalendar.find(".monthEnd").val($agendaItem.attr("data-monthEnd"));
		$toolBonusCalendar.find(".dayEnd").val($agendaItem.attr("data-dayEnd"));
		$toolBonusCalendar.find(".hourEnd").val($agendaItem.attr("data-hourEnd"));
		$toolBonusCalendar.find(".minuteEnd").val($agendaItem.attr("data-minuteEnd"));

		// Update the clocks onscreen
		$toolBonusCalendar.find("input").trigger("keyup");
	});

	/**
	 * Update the month everytime the human hits any key
	 * @return {null}
	 */
	$("#eventContent").on("keyup", ".calendarBox .month", function () {

		var month = parseInt($(this).val(), 10);

		if (month > 0 && month <= 12) {
			$(this).removeClass("badTime");
		} else {
			$(this).addClass("badTime");
		}
	});

	/**
	 * Update the day everytime the human hits any key
	 * @return {null}
	 */
	$("#eventContent").on("keyup", ".calendarBox .day", function () {

		var day = parseInt($(this).val(), 10);

		if (day > 0 && day <= 31) {
			$(this).removeClass("badTime");
		} else {
			$(this).addClass("badTime");
		}
	});

	/**
	 * Update the hour and minute everytime the human hits any key
	 * @return {null}
	 */
	$("#eventContent").on("keyup", ".calendarBox .hour", function () {
		
		var hour = parseInt($(this).val(), 10);

		if (hour >= 0 && hour < 24) {
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

		if (mins >= 0 && mins < 60) {
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
			var $agendaItem = $(this).closest(".toolBonus").prev(".agendaItem");
			var activityID = $agendaItem.val();
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
			}, function(data, textStatus, jqXHR) {

				if (jqXHR.status == 200) {

					// Get the new date of the element
					var dateBeginOld = parseInt($agendaItem.attr("data-datebegin"), 10);
					var dateBeginNew = parseInt($(data).attr("data-datebegin"), 10);

					var dateBeginMax = (dateBeginOld > dateBeginNew) ? dateBeginOld : dateBeginNew;
					var dateBeginMin = (dateBeginOld < dateBeginNew) ? dateBeginOld : dateBeginNew;

					// Move all the cells in between the new and old datas
					var $movable = $agendaItem.siblings().filter(function() {
						var dateBegin = parseInt($(this).attr("data-datebegin"), 10);
					    return (dateBegin > dateBeginMin && dateBegin < dateBeginMax);
					});

					// Decide to where ww should move the elements
					if (dateBeginOld > dateBeginNew) {
						$movable.insertAfter($agendaItem.add($agendaItem.siblings(".toolBonus")).last());
					} else {
						$movable.insertBefore($agendaItem);
					}

					// Replace the old one
					$agendaItem.replaceWith(data);
				}

			}, 'html').fail(function(jqXHR, textStatus, errorThrown) {});

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

		// Make sure that we are on editing mode
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

	/**
	  * OPTIONS BOX
	  */

	/**
	 * Load the options
	 * @return {null}
	 */
	$("#eventContent").on("click", "#options", function(event) {

		// Make sure that we are on editing mode
		if (!$("#eventContent").hasClass("editingMode")) return true;
		
		// Some variables
		var $agendaItem = $(this).closest(".agendaItem");
		var $toolBonusOptions = $("#eventContent .toolBonusOptions");

		// Move or hide the tool
		if ($toolBonusOptions.prev().is($agendaItem)) {
			$toolBonusOptions.slideToggle(200);
		} else {
			$toolBonusOptions.insertAfter($agendaItem).slideDown(200);
		}

		// Get some properties
		var activityID = $agendaItem.val();
		var capacity = $agendaItem.attr("data-capacity");
		var general = $agendaItem.attr("data-general");
		var highlight = $agendaItem.attr("data-highlight");

		// And some components
		var $general = $toolBonusOptions.find(".general");
		var $highlight = $toolBonusOptions.find(".highlight");

		// Set the values
		$toolBonusOptions.find(".capacity").html((capacity == 0) ? "&infin;" : capacity);
		if (parseInt(general, 10) != parseInt($general.attr("data-value"), 10)) $general.trigger("click", [true]);
		if (parseInt(highlight, 10) != parseInt($highlight.attr("data-value"), 10)) $highlight.trigger("click", [true]);
		
	});

	/**
	 * Change the property of the activity
	 * @return {null}
	 */
	$("#eventContent").on("instantSave", ".checkbox.general, .checkbox.highlight", function(event) {

		var $elem = $(this);
		var $agendaItem = $(this).closest(".toolBonus").prev(".agendaItem");

		// Get some properties
		var activityID = $agendaItem.val();
		var value = $elem.attr("data-value");
		var name = $elem.attr("name");

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
			// Update the backend
			$agendaItem.attr("data-" + name, value);
			
			// Replace with an updated element
			$agendaItem.replaceWith(data);

		}, 'html');

	});

});});