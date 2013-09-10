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
	$("#eventContent").on("hashDidLoad", function() {
		$(this).find(".placerContent ul").mCustomScrollbar({ scrollInertia: 150 });
	});

// -------------------------------------- MENU -------------------------------------- //

	/**
	 * Add a item to the person schedule
	 * @return {null}
	 */
	$("#eventContent").on("click", ".toolEnroll", function() {

		var $elem = $(this);
		var $agendaItem = $elem.closest(".agendaItem");

		if ($agendaItem.length > 0) {
			var namespace = "activity";
			var eventID = undefined;
			var activityID = $agendaItem.val();
			var groupID = parseInt($agendaItem.attr("data-group"), 10);
		} else {
			var namespace = "event";
			var eventID = cookie.read("eventID");
			var activityID = undefined;
		}

		// Hide the current button
		$elem.hide(200);

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: namespace + ".requestEnrollment",
			activityID: activityID,
			eventID: eventID,
			format: "html"
		}), {},
		function(data, textStatus, jqXHR) {

			if (jqXHR.status == 200) {

				if ($agendaItem.length > 0) {
					var $scheduleItem = $(data).addClass("scheduleItemInvisible");

					// Find and replace the new element
					$(".scheduleItem[value = \"" + activityID + "\"]").replaceWith($scheduleItem);
					$scheduleItem.slideDown(300);

					// Hide all activities that belong to the same group
					// if (groupID != 0) $(".agendaItem[data-group = \"" + groupID + "\"]").find(".toolEnroll").hide(200);

				} else {
					// Reload page
					window.location.reload();
				}
			}

		}, 'html').fail(function(jqXHR, textStatus, errorThrown) {
			$elem.fadeIn(300);
		});

	});
	
	/**
	 * Remove a item from the person schedule
	 * @return {null}
	 */
	$("#eventContent").on("click", ".toolExpel", function() {

		var $elem = $(this);
		var activityID = $elem.closest(".scheduleItem").val();

		// Hide the current button
		$elem.hide(300);

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "activity.dismissEnrollment",
			activityID: activityID,
			format: "html"
		}), {},
		function(data, textStatus, jqXHR) {

			if (jqXHR.status == 200) {
				// Hide the current item
				$elem.closest(".scheduleItem").slideUp(300);

				// Enable the button on the agenda
				$(".agendaItem[value = \"" + activityID + "\"]").find(".toolEnroll").slideDown(200);
			}

		}, 'html').fail(function(jqXHR, textStatus, errorThrown) {
			$elem.fadeIn(300);
		});

	});

	/**
	 * Remove a item from the person schedule
	 * @return {null}
	 */
	$("#eventContent").on("click", ".toolPriority", function() {

		var $elem = $(this);
		var activityID = $elem.closest(".scheduleItem").val();

		// Hide the current button
		var method = ($(this).hasClass("toolSelected")) ? "decreasePriority" : "risePriority";

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "activity." + method,
			activityID: activityID,
			format: "html"
		}), {},
		function(data, textStatus, jqXHR) {
			if (jqXHR.status == 200) $elem.toggleClass("toolSelected");
		}, 'html');

	});

});});