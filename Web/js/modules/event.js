$(document).ready(function() {

// -------------------------------------- LOADER -------------------------------------- //
	
	/**
	 * Page initialization
	 * @return {null}
	 */
	$("#eventContent").live("hashDidLoad", function() {

	});

// -------------------------------------- EVENT -------------------------------------- //

	/**
	 * Add a item to the person schedule
	 * @return {null}
	 */
	$("#eventContent .toolEnroll").live("click", function() {

		$(this).hide(300);

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "activity.requestEnrollment",
			activityID: activityID,
			format: "html"
		}), {},
		function(data, textStatus, jqXHR) {

			if (data.status == 200) {

			}

		}, 'html').fail(function(data, textStatus, jqXHR) {
			$(this).fadeIn(300);
		});

	});
	
	/**
	 * Remove a item from the person schedule
	 * @return {null}
	 */
	$("#eventContent .toolExpel").live("click", function() {

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "activity.dismissEnrollment",
			activityID: activityID,
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