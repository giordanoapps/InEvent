$(document).ready(function() {

// -------------------------------------- LOADER -------------------------------------- //
	
	/**
	 * Page initialization
	 * @return {null}
	 */
	$("#eventContent").live("hashDidLoad", function() {
		$(this).find(".placerContent ul").mCustomScrollbar({ scrollInertia: 150 });
	});

// -------------------------------------- MENU -------------------------------------- //

	/**
	 * Add a item to the person schedule
	 * @return {null}
	 */
	$("#eventContent .toolEnroll").live("click", function() {

		var $elem = $(this);
		var $agendaItem = $elem.closest(".agendaItem");
		var activityID = $agendaItem.val();
		var groupID = parseInt($agendaItem.attr("data-group"), 10);

		// Hide the current button
		$elem.hide(200);

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "activity.requestEnrollment",
			activityID: activityID,
			format: "html"
		}), {},
		function(data, textStatus, jqXHR) {

			if (jqXHR.status == 200) {
				var $scheduleItem = $(data).addClass("scheduleItemInvisible");

				// Find and replace the new element
				$(".scheduleItem[value = \"" + activityID + "\"]").replaceWith($scheduleItem);
				$scheduleItem.slideDown(300);

				// Hide all activities that belong to the same group
				// if (groupID != 0) $(".agendaItem[data-group = \"" + groupID + "\"]").find(".toolEnroll").hide(200);
			}

		}, 'html').fail(function(jqXHR, textStatus, errorThrown) {
			$elem.fadeIn(300);
		});

	});
	
	/**
	 * Remove a item from the person schedule
	 * @return {null}
	 */
	$("#eventContent .toolExpel").live("click", function() {

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
	$("#eventContent .toolPriority").live("click", function() {

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

});