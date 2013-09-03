$(document).ready(function() {

// -------------------------------------- MENU -------------------------------------- //

	/**
	 * Enroll a person on an event
	 * @return {null}
	 */
	$("#forgotContent .sendRecovery").live("click", function() {

		var $elem = $(this);
		var email = $elem.siblings(".email").val();

		// Hide the current button
		$elem.hide(200);

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "person.sendRecovery",
			email: email,
			format: "html"
		}), {},
		function(data, textStatus, jqXHR) {

			if (jqXHR.status == 200) {
				// Remove the class and trigger a click on the new one

			}

		}, 'html').fail(function(jqXHR, textStatus, errorThrown) {
			$elem.fadeIn(300);
		});

	});

});