var modules = [];
modules.push('jquery');
modules.push('common');
modules.push('modules/cookie');

define(modules, function($, common, cookie) {$(function() {

// -------------------------------------- MENU -------------------------------------- //

	/**
	 * Close all the inputs that are open
	 * @return {null}
	 */
	$("#frontContent").on("click", ".toolBox .toolDone", function() {

		// Prepare the trigger
		var event = jQuery.Event("keyup");
		event.which = 13;

		// Send it
		$("#frontContent .titleInput").trigger(event);

		// Close all the bonus boxes
		$("#frontContent .toolBonus").slideUp(300);
		
	});

	/**
	  * CALENDAR BOX
	  */

	/**
	 * Load the clocks
	 * @return {null}
	 */
	$("#frontContent").on("click", ".details .dateBegin, .details .dateEnd", function() {

		// Make sure that we are on editing mode
		if (!$("#frontContent").hasClass("editingMode")) return true;

		// Get some properties
		var $details = $(this).closest(".details");
		var $toolBonusCalendar = $("#frontContent .toolBonusCalendar");

		// Move or hide the tool
		$toolBonusCalendar.slideToggle(200);

		// Write the components
		// ("0" + (this.getMonth() + 1)).slice(-2)
		$toolBonusCalendar.find(".monthBegin").val($details.attr("data-monthBegin"));
		$toolBonusCalendar.find(".dayBegin").val($details.attr("data-dayBegin"));
		$toolBonusCalendar.find(".hourBegin").val($details.attr("data-hourBegin"));
		$toolBonusCalendar.find(".minuteBegin").val($details.attr("data-minuteBegin"));
		$toolBonusCalendar.find(".enrollmentBegin").val($details.attr("data-enrollmentBegin"));
		$toolBonusCalendar.find(".monthEnd").val($details.attr("data-monthEnd"));
		$toolBonusCalendar.find(".dayEnd").val($details.attr("data-dayEnd"));
		$toolBonusCalendar.find(".hourEnd").val($details.attr("data-hourEnd"));
		$toolBonusCalendar.find(".minuteEnd").val($details.attr("data-minuteEnd"));
		$toolBonusCalendar.find(".enrollmentEnd").val($details.attr("data-enrollmentEnd"));

		// Update the clocks onscreen
		$toolBonusCalendar.find("input").trigger("keyup");
	});

	/**
	 * Load an additional box
	 * @return {null}
	 */
	$("#frontContent").on("click", ".details .enrollmentTrigger", function() {
		$(this).closest(".calendarBox").siblings(".enrollmentBox").slideToggle(200);
		$(this).find(".pathArrow").toggleClass("rotateArrow");
	});

	/**
	 * Send all the updates times to the server
	 * @return {null}
	 */
	$("#frontContent").on("focusout", ".toolBonusCalendar input", function () {

		if (!$(this).hasClass("badTime")) {

			// Fresh filter
			if ($(this).attr("data-serverParse") != "true") {
				$(this).val(("0" + parseInt($(this).val())).slice(-2));
			}

			// Get some properties
			var $date = $(this).closest(".toolBonus").siblings(".date");
			var name = $(this).attr("name");
			var value = $(this).val();

			// Save it
			$.post('developer/api/?' + $.param({
				method: "event.edit",
				eventID: cookie.read("eventID"),
				name: name,
				format: "html"
			}), {
				value: value
			}, function(data, textStatus, jqXHR) {

				if (jqXHR.status == 200) {
					// Replace the old one
					$date.find(".dateBegin span").text($(data).find(".dateBegin span").text());
					$date.find(".dateEnd span").text($(data).find(".dateEnd span").text());
				}

			}, 'html').fail(function(jqXHR, textStatus, errorThrown) {});

		}
	});

	/**
	  * TEXT BOX
	  */

	/**
	 * Start a text inline edition
	 * @return {null}
	 */
	$("#frontContent").on("click", ".title, .address, .city, .state, .fugleman, .description", function(event) {

		// Make sure that we are on editing mode
		if (!$("#frontContent").hasClass("editingMode")) return true;
		if ($(this).hasClass("titleInput")) return true;

		// Get the value
		var value = $(this).text();

		if ($(this).hasClass("description")) {
			// Create the textarea
			$(this).field("createField", "textarea", {
				"class" : $(this).attr("class") + " titleInput",
				"value" : value,
				"placeholder": value
			}).focus();

		} else {
			// Create the input
			$(this).field("createField", "input", {
				"class" : $(this).attr("class") + " titleInput",
				"value" : value,
				"placeholder": value,
				"maxlength": 200
			}).focus();
		}

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
	$("#frontContent").on("keyup", ".titleInput", function(event) {

		// Remove the focus from the current field
		var code = (event.keyCode ? event.keyCode : event.which);
		if (code == 13) $(this).blur();
	});

	$("#frontContent").on("focusin", ".titleInput", function(event) {
		var $elem = $(this);
		$elem.one("focusout", function() {
			$elem.trigger("saveField");
		})
	});

	$("#frontContent").on("saveField", ".titleInput", function(event) {

		var $elem = $(this);

		var value = $elem.val();
		var name = $elem.attr("name");
		
		$elem = $elem.field("removeField", {"class": $elem.attr("class").replace(/titleInput/g, "")});

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "event.edit",
			eventID: cookie.read("eventID"),
			name: name,
			format: "html"
		}), {
			value: value
		},
		function(data, textStatus, jqXHR) {

			if (jqXHR.status == 200) {
				// Update event name
				if (name == "name") $(".locationItem[value=" + cookie.read("eventID") + "]").text(value);
			}

		}, 'html').fail(function(jqXHR, textStatus, errorThrown) {});

	});

	/**
	 * Go to an event
	 * @return {null}
	 */
	$("#frontContent").on("click", ".toolEnrolled", function() {

		// Create the cookie
		cookie.create("eventID", $(this).closest(".enroll").attr("data-id"), 10);

		// Move to the event page
		window.location.hash = "event";

		// Reload our page
		window.location.reload();

	});

	/**
	 * Enroll at an event
	 * @return {null}
	 */
	$("#frontContent").on("click", ".toolEnroll", function () {
			
		// Current element
		var $elem = $(this);

		// Get the current event
		var eventID = $elem.closest(".enroll").attr("data-id");
		
		// See if the person is authenticated
		if (cookie.read("tokenID") != null) {

			$elem.fadeOut(200);

			// We request the information on the server
			$.post('developer/api/?' + $.param({
				method: "event.requestEnrollment",
				eventID: eventID,
				format: "html"
			}), {},
			function(data, textStatus, jqXHR) {
				// Move to the event page
				window.location.hash = "event";

				// Reload our page
				window.location.reload();

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
	
});});