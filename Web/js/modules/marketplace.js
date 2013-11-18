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
	$("#marketplaceContent").on("click", ".toolEnrolled", function() {

		// Create the cookie
		cookie.create("eventID", $(this).closest(".eventItem").val(), 10);

		// Reload our page
		window.location.replace('/' + $(this).closest(".bottom").attr("data-nick"));

	});

	/**
	 * Enroll a person on an event
	 * @return {null}
	 */
	$("#marketplaceContent").on("click", ".toolEnroll", function() {

		var $elem = $(this);
		var $eventItem = $elem.closest(".eventItem");
		var eventID = $eventItem.val();

		// Hide the current button
		$elem.hide(200);

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "event.requestEnrollment",
			eventID: eventID,
			format: "html"
		}), {},
		function(data, textStatus, jqXHR) {

			if (jqXHR.status == 200) {
				// Remove the class and trigger a click on the new one
				$elem.removeClass("toolEnroll").addClass("toolEnrolled").trigger("click");
			}

		}, 'html').fail(function(jqXHR, textStatus, errorThrown) {
			$elem.fadeIn(300);
		});

	});
	
	/**
	 * Remove a person from a event
	 * @return {null}
	 */
	$("#marketplaceContent").on("click", ".toolExpel", function() {

		var $name = $(this).closest(".eventItem").find(".title");
		var name = $name.text();
		var firstName = name.split(" ")[0];

		// Create the input
		$name
			.field("createField", "input", {
				"class" : "titleInput",
				"value" : "",
				"placeholder": "Digite: " + firstName,
				"data-first": firstName,
				"data-name": name,
			}).focus();

		// Hide the current button
		$(this).hide(300);

	});

	/**
	 * Remove a person from a event
	 * @return {null}
	 */
	$("#marketplaceContent").on("keyup", ".titleInput", function(event) {

		var code = (event.keyCode ? event.keyCode : event.which);
		// Enter keycode
		if (code == 13) {

			var $elem = $(this);

			if ($elem.val() == $elem.attr("data-first")) {
				$elem = $elem.val($elem.attr("data-name")).field("removeField", {"class": "name"});

				var eventID = $elem.closest(".eventItem").val();

				// We request the information on the server
				$.post('developer/api/?' + $.param({
					method: "event.dismissEnrollment",
					eventID: eventID
				}), {},
				function(data, textStatus, jqXHR) {

					if (jqXHR.status == 200) {
						// Reload our page
						window.location.reload();
					}

				}, 'html').fail(function(jqXHR, textStatus, errorThrown) {
					$elem.fadeIn(300);
				});
			}
		}

	});

});});