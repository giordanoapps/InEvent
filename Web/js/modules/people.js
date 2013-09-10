var modules = [];
modules.push('jquery');
modules.push('common');
modules.push('modules/cookie');
modules.push('jquery.mCustomScrollbar');
modules.push('jquery.chosen');

define(modules, function($, common, cookie) {$(function() {

// -------------------------------------- LOADER -------------------------------------- //
	
	/**
	 * Page initialization
	 * @return {null}
	 */
	$("#peopleContent").on("hashDidLoad", function() {
		// Load the first activity
		$(this).find(".scheduleItemSelectable").first().trigger("click");
	});

// -------------------------------------- TOOLS -------------------------------------- //

	/**
	 * Load an activity and populate with usage
	 * @return {null}
	 */
	$("#peopleContent").on("click", ".scheduleItemSelectable", function(event, order) {

		// Change the selected class
		$(this).siblings(".scheduleItemSelected").removeClass("scheduleItemSelected").end().addClass("scheduleItemSelected");

		// Get the new activityID
		var activityID = $(this).val();
		var eventID = cookie.read("eventID");

		// Define the namespace
		var namespace = $(this).attr("data-type");

		// Filter the order
		if (order == undefined || order == null) order = "null";
		
		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: namespace + ".getPeople",
			activityID: activityID,
			eventID: eventID,
			selection: "all",
			order: order,
			format: "html"
		}), {},
		function(data, textStatus, jqXHR) {

			if (jqXHR.status == 200) {
				// Append the content
				$(".realContent").hide(0).html(data).show(300);

				// Scroll to top
				$('html, body').animate({ scrollTop: 0 }, 'slow');
			}

		}, 'html');

	});

	/**
	 * Order the sequence of a list
	 * @return {null}
	 */
	$("#peopleContent").on("click", "thead td", function() {

		// Get the order
		var order = $(this).attr("data-order");

		// Change the selected class
		$("#peopleContent").find(".scheduleItemSelected").trigger("click", [order]);

	});

// -------------------------------------- MENU -------------------------------------- //


	/**
	 * Remove a item from the person schedule
	 * @return {null}
	 */
	$("#peopleContent").on("click", ".head", function() {

		var $elem = $(this);
		var method = ($elem.hasClass("staff")) ? "revokePermission" : "grantPermission";
		var personID = $elem.closest(".pickerItem").attr("data-value");

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "event." + method,
			eventID: 2,
			personID: personID,
			format: "html"
		}), {},
		function(data, textStatus, jqXHR) {
			if ($elem.hasClass("staff")) {
			    $elem.attr("data-value", "0").removeClass("staff").attr('src', 'images/64-User.png');
			} else {
				$elem.attr("data-value", "1").addClass("staff").attr('src', 'images/64-Admin-User.png');
			}
		}, 'html');

	});

	/**
	 * Remove a item from the person schedule
	 * @return {null}
	 */
	$("#peopleContent").on("instantSave", ".checkbox.paid, .checkbox.present", function() {

		var $elem = $(this);
		var method = ($elem.hasClass("paid")) ? "confirmPayment" : "confirmEntrance";
		var activityID = $(".placerContent .scheduleItemSelected").val();
		var personID = $elem.closest(".pickerItem").attr("data-value");

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "activity." + method,
			activityID: activityID,
			personID: personID,
			format: "html"
		}), {}, function(data, textStatus, jqXHR) {}, 'html');

	});


// -------------------------------------- REMOVE -------------------------------------- //

	/**
	 * Remove a person from the activity
	 * @return {null}
	 */
	$("#peopleContent").on("click", ".pickerItem .toolRemove", function() {

		event.stopPropagation();

		var $name = $(this).closest(".pickerItem").find(".name");
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
	 * Remove a person from the activity
	 * @return {null}
	 */
	$("#peopleContent").on("keyup", ".pickerItem .titleInput", function() {

		var code = (event.keyCode ? event.keyCode : event.which);
		// Enter keycode
		if (code == 13) {

			var $elem = $(this);

			if ($elem.val() == $elem.attr("data-first")) {
				$elem = $elem.val($elem.attr("data-name")).field("removeField", {"class": "name"});

				var $pickerItem = $elem.closest(".pickerItem");
				var activityID = $(".placerContent .scheduleItemSelected").val();
				var personID = $pickerItem.attr("data-value");

				// We request the information on the server
				$.post('developer/api/?' + $.param({
					method: "activity.dismissEnrollment",
					personID: personID,
					activityID: activityID,
					format: "html"
				}), {},
				function(data, textStatus, jqXHR) {

					if (jqXHR.status == 200) {
						// Hide the current entry
						$pickerItem.slideDown(600, function() {
							$pickerItem.remove();
						});
					}

				}, 'html').fail(function(jqXHR, textStatus, errorThrown) {
					$elem.closest(".pickerItem").find(".toolRemove").fadeIn(300);
				});
			} else {
				$elem = $elem.val($elem.attr("data-name")).field("removeField", {"class": "name"});

				// Show the button
				$elem.closest(".pickerItem").find(".toolRemove").fadeIn(300);
			}
		}

	});
	
});});