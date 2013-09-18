var modules = [];
modules.push('jquery');
modules.push('common');
modules.push('modules/cookie');
modules.push('jquery.scrollbar');
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

		// Create the scrollable container
		$(this).find(".placerContent > ul").perfectScrollbar();
	});

// -------------------------------------- TOOLS -------------------------------------- //

	/**
	 * Tool to export data to excel
	 * @return {null}
	 */
	$("#peopleContent").on("click", ".toolBox .toolExport", function(event) {
		// Change the selected class
		$("#peopleContent .scheduleItemSelected").trigger("click", [null, "excel"]);
	});

	/**
	 * Toggle the box
	 * @return {null}
	 */
	$("#peopleContent").on("click", ".toolCreate", function(event) {
		$(this).closest(".toolBox").siblings(".toolBoxOptionsEnrollPerson").slideToggle(400).find("input").first().focus();
	});

	/**
	 * Add a person to the activity
	 * @return {null}
	 */
	$("#peopleContent").on("click", ".toolBoxOptionsEnrollPerson .singleButton", function(event) {
		
		var $elem = $(this);
		var $scheduleItemSelected = $("#peopleContent .scheduleItemSelected");

		var namespace = $scheduleItemSelected.attr("data-type");
		var activityID = $scheduleItemSelected.val();
		var eventID = cookie.read("eventID");
		var name = $elem.siblings(".name").val();
		var email = $elem.siblings(".email").val();

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: namespace + ".requestEnrollment",
			activityID: activityID,
			eventID: eventID,
			name: name,
			email: email,
			format: "html"
		}), {},
		function(data, textStatus, jqXHR) {

			// Hide the toolbar
			$elem.closest(".toolBoxOptionsEnrollPerson").slideToggle(400);

			// Reload the table
			var order = $("#peopleContent .power").closest("td").attr("data-order");
			$scheduleItemSelected.trigger("click", [order]);

			// Reset values
			$elem.siblings(".name").val('');
			$elem.siblings(".email").val('');

		}, 'html');

	});

	/**
	 * Toggle the box
	 * @return {null}
	 */
	$("#peopleContent").on("click", ".toolMail", function(event) {
		// Toggle the div
		$(this).closest(".toolBox").siblings(".toolBoxOptionsMail").slideToggle(400);

		// Trigger the content load
		$("#peopleContent .scheduleItemSelected").trigger("click", [null, "gmail"]);
	});

	/**
	 * Load an activity and populate with usage
	 * @return {null}
	 */
	$("#peopleContent").on("click", ".scheduleItemSelectable", function(event, order, format) {

		// Change the selected class
		$(this).siblings(".scheduleItemSelected").removeClass("scheduleItemSelected").end().addClass("scheduleItemSelected");

		// Get the new activityID
		var activityID = $(this).val();
		var eventID = cookie.read("eventID");

		// Define the namespace
		var namespace = $(this).attr("data-type");

		// Filter the order
		if (order == undefined || order == null) order = "null";

		// Filter the format
		if (format == undefined || format == null) format = "html";
		
		// Define the url
		var url = 'developer/api/?' + $.param({
			method: namespace + ".getPeople",
			activityID: activityID,
			eventID: eventID,
			selection: "all",
			order: order,
			format: format
		});

		if (format == "excel") {
			// Load the excel requisition on its own frame
			$("#excelFrame").attr("src", url);

		} else {
			// We request the information on the server
			$.post(url, {},
			function(data, textStatus, jqXHR) {
				if (jqXHR.status == 200) {

					if (format == "gmail") {
						// Load the excel requisition on its own frame
						$(".toolBoxOptionsMail textarea").html(data).focus().select();

					} else {
						// Append the content
						$("#peopleContent .realContent")
							.hide(0)
							.html(data)
							.show(300)
							.perfectScrollbar("destroy")
							.perfectScrollbar({
								minScrollbarLength: 120
							});

						// Scroll to top
						$('html, body').animate({ scrollTop: 0 }, 'slow');
					}
				}
			}, "html");
		}

	});

	/**
	 * Select a random person on the list
	 * @return {null}
	 */
	$("#peopleContent").on("click", ".toolBox .toolRandom", function(event) {

		// Select all the items on the list
		var $pickerItem = $("#peopleContent .pickerItem").removeClass("pickerItemLucky");

		// Select a random item from the collection
		var $pickerItemLucky = $pickerItem.eq(Math.floor(Math.random() * $pickerItem.length));

		// Animate the item transition
		$pickerItemLucky
			.stop(true, true)
			.addClass("pickerItemLucky", 100)
			.delay(20000) // 20s
			.removeClass("pickerItemLucky", 100);

		// Scroll the table
		var $realContent = $("#peopleContent .realContent");
		$realContent.scrollTop($pickerItemLucky.position().top + $realContent.scrollTop() - 132);
	});

	/**
	 * Order the sequence of a list
	 * @return {null}
	 */
	$("#peopleContent").on("click", "thead td", function(event) {

		// Get the order
		var order = $(this).attr("data-order");

		// Change the selected class
		$("#peopleContent .scheduleItemSelected").trigger("click", [order]);

	});

// -------------------------------------- MENU -------------------------------------- //


	/**
	 * Remove a item from the person schedule
	 * @return {null}
	 */
	$("#peopleContent").on("click", ".head", function(event) {

		var $elem = $(this);
		var method = ($elem.hasClass("staff")) ? "revokePermission" : "grantPermission";
		var eventID = cookie.read("eventID");
		var personID = $elem.closest(".pickerItem").attr("data-value");

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "event." + method,
			eventID: eventID,
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
	$("#peopleContent").on("instantSave", ".checkbox.paid, .checkbox.present", function(event) {

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
	$("#peopleContent").on("click", ".pickerItem .toolRemove", function(event) {

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
	$("#peopleContent").on("keyup", ".pickerItem .titleInput", function(event) {

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