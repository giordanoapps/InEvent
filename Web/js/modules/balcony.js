var modules = [];
modules.push('jquery');
modules.push('common');
modules.push('modules/cookie');

define(modules, function($, common, cookie) {$(function() {

// -------------------------------------- LOADER -------------------------------------- //
	
	/**
	 * Page initialization
	 * @return {null}
	 */
	$("#balconyContent").on("hashDidLoad", function() {
		// Load the first application
		$(this).find(".section").first().trigger("validateSection");
	});

// -------------------------------------- MENU -------------------------------------- //

	/**
	 * Validate all sections on load
	 * @return {null}
	 */
	$("#balconyContent").on("validateSection", ".section", function() {
		// Focus on this class
		$(this).siblings(".sectionFocus").removeClass("sectionFocus").end().addClass("sectionFocus");
	});

	/**
	 * Validate the person that is authenticated
	 * @return {null}
	 */
	$("#balconyContent").on("validateSection", ".person", function() {

		// See if the person is already authenticated
		if (cookie.read("tokenID") != null) {
			// Find the name of the person
			var name = $(".loginInfo p").text();

			// Write the name on the text
			$(this).find(".title").text("Olá " + name);

			// Hide all the inputs
			$(this).find("input").slideUp(400);			

			// Jump to the next section
			$(this).next().trigger("validateSection");
		}
		
	});

	/**
	 * Register the new person
	 * @return {null}
	 */
	$("#balconyContent").on("click", ".person .singleButton", function() {

		// Get some properties
		var $elem = $(this).hide(200);
		var name = $elem.siblings(".name").val();
		var email = $elem.siblings(".email").val();

		// We send the details to the server
		$.post('developer/api/?' + $.param({
			method: "person.enroll",
			format: "html"
		}), {
			name: name,
			password: "123456",
			email: email
		},
		function(data, textStatus, jqXHR) {

			// Create our cookie
			cookie.create("tokenID", data.tokenID, 30);

			// Reload our page
			window.location.reload();

		}, 'json').fail(function(jqXHR, textStatus, errorThrown) {

			// Case the company or member is already registered
			if (jqXHR.status == 303 || jqXHR.status == 409) {
				$elem.siblings("input").addClass("duplicatedValue");
				$(".userLoginLeading").trigger("click");
			} else {
				$elem.siblings("input").addClass("badValue");
			}
		});

	});

	/**
	 * Create a hashtag based on the event name
	 * @return {null}
	 */
	$("#balconyContent").on("keyup", ".event .name", function() {
		// Copy all the contents to the hashtag
		$(this).siblings(".nickname").val("#" + $(this).val().replace(/[|&;$%@"<>()+, ]/g, ""));
	});

	/**
	 * Trigger event validation
	 * @return {null}
	 */
	$("#balconyContent").on("click", ".event .singleButton", function() {

		// Get some properties
		var $elem = $(this);
		var name = $elem.siblings(".name").val();
		var nickname = $elem.siblings(".nickname").val();

		// See if all the values are right
		if (name.length >= 4 && nickname.length >= 4) {

			// We send the details to the server
			$.post('developer/api/?' + $.param({
				method: "event.create",
				format: "json"
			}), {
				name: name,
				nickname: nickname
			},
			function(data, textStatus, jqXHR) {

				// Save our eventID
				localStorage.setItem("newEvent", data.data[0].id);

				// Remove bad classes
				$elem.siblings("input").removeClass("badValue");

				// Go to the next section
				$elem.closest(".section").next().trigger("validateSection");

			}, 'json').fail(function(jqXHR, textStatus, errorThrown) {

				// Case the company or member is already registered
				if (jqXHR.status == 303 || jqXHR.status == 409) {
					$elem.siblings("input").addClass("duplicatedValue");
				} else {
					$elem.siblings("input").addClass("badValue");
				}
			});

		} else {
			// Inform about the error
			$elem.siblings("input").addClass("badValue");
		}
	});

	/**
	 * Calculate the total event price
	 * @return {null}
	 */
	$("#balconyContent").on("keyup", ".payment .number", function() {
		var quantity = parseFloat($(this).val()) || 0;
		var unit = parseFloat($(this).siblings(".unit").text().replace(',', '.'))
		var total = Math.round(unit * quantity * 10) / 10;
		$(this).siblings(".total").text(total.toFixed(2).toString().replace('.', ','));
	});

	/**
	 * Generate MP link
	 * @return {null}
	 */
	$("#balconyContent").on("focusout", ".payment .number", function() {

		// Get some properties
		var $elem = $(this);
		var eventID = localStorage.getItem("newEvent");
		var tickets = $elem.val();
		var advertisements = 0;

		// We send the details to the server
		$.post('developer/api/?' + $.param({
			method: "payment.create",
			eventID: eventID,
			format: "html"
		}), {
			tickets: tickets,
			advertisements: advertisements
		},
		function(data, textStatus, jqXHR) {

			// Remove the newly created event
			// localStorage.removeItem("newEvent");

			// Update address and show payment button
			$elem.closest(".value").siblings("a").attr("href", data.address).find(".singleButton").slideDown(200);

		}, 'json').fail(function(jqXHR, textStatus, errorThrown) {

			// Case something fails
			if (jqXHR.status == 303 || jqXHR.status == 409) {
				$elem.siblings("input").addClass("duplicatedValue");
			} else {
				$elem.siblings("input").addClass("badValue");
			}
		});

	});

});});