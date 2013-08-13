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
		var data = JSON.parse(localStorage.getItem("registrationData")) || {};

		// We send the data to the server
		$.post('developer/api/?' + $.param({
			method: "person.enroll",
			format: "html"
		}), {
			name: data.name,
			password: data.password,
			email: data.email,
			cpf: data.cpf,
			rg: data.rg,
			telephone: data.telephone,
			university: data.university,
			course: data.course
		},
		function(data, textStatus, jqXHR) {

			if (data.status == 200) {
				// Show the sucess message
				$content.find(".registrationComplete").fadeIn(0).delay(5000).fadeOut(300);

				// Remove the registration data
				localStorage.removeItem("registrationData");
				data = {};
			}

		}, 'html').fail(function(data, textStatus, jqXHR) {

			// Case the company or member is already registered
			if (data.status == 409) {
				$content.find(".registrationConflict").fadeIn(0).delay(5000).fadeOut(300);
			} else {
				$content.find(".registrationFailed").fadeIn(0);
				$content.find(".box").fadeOut(0);
			}
		});

	});

});