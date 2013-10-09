define(["jquery", "common"], function($) {$(function() {

// -------------------------------------- MENU -------------------------------------- //

	/**
	 * Add a person from the email list
	 * @return {null}
	 */
	$("#forgotContent").on("click", ".subscribe", function() {

		var $elem = $(this);
		var email = $elem.siblings(".email").val();

		// Hide the current button
		$elem.hide(200);

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "person.subscribe",
			email: email,
			format: "html"
		}), {},
		function(data, textStatus, jqXHR) {

			if (jqXHR.status == 200) {
				// Remove the class and trigger a click on the new one
				$elem.siblings(".alert").show(200);
			}

		}, 'html').fail(function(jqXHR, textStatus, errorThrown) {
			$elem.siblings(".conflict").show(200);
		});

	});

});});