define(["jquery", "common"], function($) {$(function() {

// -------------------------------------- MENU -------------------------------------- //

	/**
	 * Change the password of a person
	 * @return {null}
	 */
	$("#forgotContent").on("click", ".changePass", function() {

		var $elem = $(this);
		var oldPassword = $elem.siblings(".oldPassword").val();
		var newPassword = $elem.siblings(".newPassword").val();

		// Hide the current button
		$elem.slideUp(200);

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "person.changePassword",
			oldPassword: oldPassword,
			newPassword: newPassword,
			format: "html"
		}), {},
		function(data, textStatus, jqXHR) {

			if (jqXHR.status == 200) {
				// Remove the class and trigger a click on the new one
				$elem.siblings(".alert").show(200);
			}

		}, 'html').fail(function(jqXHR, textStatus, errorThrown) {
			$elem.slideDown(300);
		});

	});

});});