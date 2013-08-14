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

		var $elem = $(this);
		var $pickerItem = $elem.closest(".pickerItem");
		var activityID = $pickerItem.val();
		var groupID = parseInt($pickerItem.attr("data-group"), 10);

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
				// if (groupID != 0) $(".pickerItem[data-group = \"" + groupID + "\"]").find(".toolEnroll").hide(200);
			}

		}, 'html').fail(function(data, textStatus, jqXHR) {
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
				$(".pickerItem[value = \"" + activityID + "\"]").find(".toolEnroll").slideDown(200);
			}

		}, 'html').fail(function(data, textStatus, jqXHR) {
			$elem.fadeIn(300);
		});

	});
	
});