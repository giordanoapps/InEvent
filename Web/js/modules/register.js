// --------------------------------- REGISTER ------------------------------------ //

define(["jquery", "modules/cookie"], function($) {$(function() {

	/**
	 * Page initialization
	 * @return {null}
	 */
	$("#registerContent").on("hashDidLoad", function() {
		
		// Hold the current content
		var $content = $(this);

		// Get the saved information
		var details = JSON.parse(localStorage.getItem("registrationData")) || {};

		// We send the details to the server
		$.post('developer/api/?' + $.param({
			method: "person.enroll",
			format: "html"
		}), {
			name: details.name,
			password: details.password,
			email: details.email,
			cpf: details.cpf,
			rg: details.rg,
			telephone: details.telephone,
			city: details.city,
			university: details.university,
			course: details.course,
			usp: details.usp
		},
		function(data, textStatus, jqXHR) {

			if (jqXHR.status == 200) {

				try {
					var jsonReturn = JSON.parse(data);
				} catch (Exception) {
					console.log("Couldn't parse JSON");
					return 0;
				}

				// Create our cookie
				cookie.create("tokenID", jsonReturn.tokenID, 30);

				// Show the sucess screen
				$content.find(".registrationComplete").fadeIn(0).delay(4000).fadeOut(300, function() {
					// Move to the event page
					window.location.hash = "marketplace";
					// Reload our page
					window.location.reload();
				});

				// Remove the registration data
				localStorage.removeItem("registrationData");
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

});});