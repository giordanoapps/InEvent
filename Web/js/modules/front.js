var modules = [];
modules.push('jquery');
modules.push('common');
modules.push('modules/cookie');

define(modules, function($, common, cookie) {$(function() {

// -------------------------------------- MENU -------------------------------------- //

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