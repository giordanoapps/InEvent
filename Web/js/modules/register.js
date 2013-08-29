$(document).ready(function() {

// --------------------------------- REGISTER ------------------------------------ //

	/**
	 * Page initialization
	 * @return {null}
	 */
	$("#registerContent").live("hashDidLoad", function() {
		
		// Hold the current content
		var $content = $(this);

		// Get the saved information
		var details = JSON.parse(localStorage.getItem("registrationData")) || {};

		// We send the details to the server
		$.post('developer/api/?' + $.param({
			method: "person.register",
			format: "html"
		}), {
			name: details.name,
			password: details.password,
			email: details.email,
			cpf: details.cpf,
			rg: details.rg,
			telephone: details.telephone,
			university: details.university,
			course: details.course,
			usp: details.usp
		},
		function(data, textStatus, jqXHR) {

			if (jqXHR.status == 200) {
				// Show the sucess message
				$content.find(".registrationComplete").fadeIn(0); //.delay(5000).fadeOut(300);

				// Remove the registration data
				localStorage.removeItem("registrationData");

				// Define the form url
				var url = $content.find("iframe").attr("src");
				url = url.replace(/myName/i, details.name);
				url = url.replace(/myEmail/i, details.email);
				$content.find("iframe").attr("src", url);
			}

		}, 'html').fail(function(jqXHR, textStatus, errorThrown) {

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