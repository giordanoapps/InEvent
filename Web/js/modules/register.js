$(document).ready(function() {

// --------------------------------- REGISTER ------------------------------------ //

	/**
	 * Page initialization
	 * @return {null}
	 */
	$("#registerContent").live("hashDidLoad", function() {
		
		// Hold the current content
		$content = $(this);

		// Get the saved information
		var registrationData = JSON.parse(localStorage.getItem("registrationData")) || {};

		// We send the data to the server
		$.post('ajaxRegister.php',
		{
			registration: registrationData,
		},
		function(data, textStatus, jqXHR) {

			if (jqXHR.status == 200) {
				
				// Show the sucess message
				$content.find(".registrationComplete").fadeIn(0).delay(5000).fadeOut(300);

				// Remove the registration data
				localStorage.removeItem("registrationData");
				registrationData = {};
			}

		}, 'html' ).fail(function(data, textStatus, jqXHR) {

			// Case the company or member is already registered
			if (jqXHR.status == 409) {
				$content.find(".registrationConflict").fadeIn(0).delay(5000).fadeOut(300);
			} else {
				$content.find(".registrationFailed").fadeIn(0);
				$content.find(".box").fadeOut(0);
			}
		});

	});

});