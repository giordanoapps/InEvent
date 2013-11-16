// -------------------------------------- TOOLS -------------------------------------- //

define(["jquery", "common", "modules/cookie"], function($, common, cookie) {$(function() {

	/**
	 * Edit tool has been clicked (or the done button)
	 * @return {null}
	 */
	$(document).on("click", ".toolBox .toolPreferences, .toolBox .toolDone", function() {

		// Get the pageContent
		var $pageContent = $(".pageContent").toggleClass("editingMode");
		var $pageContentSector = $(".pageContentSector:visible");
		var level = $pageContentSector.index();

		// Hide any options box
		$(".toolBoxOptions").slideUp(300);

		// Sanitize the data
		if (isNaN(parseFloat(level)) || !isFinite(level) || level < 0) level = 0;

		// PREFERENCES TOOL
		if ($pageContent.hasClass("editingMode")) {
			$(".toolBox > div:eq(" + level + ") div")
				.not(".editingToolBox, .toolBoxBreadcrumb")
				.slideToggle(300)
				.end()
				.filter(".editingToolBox")
				.delay(300)
				.slideToggle(300);
		
		// DONE TOOL
		} else {
			// Hide the items and show others
			$(".toolBox > div:eq(" + level + ") div")
				.filter(".editingToolBox")
				.slideToggle(300)
				.end()
				.not(".editingToolBox, .toolBoxBreadcrumb")
				.delay(300)
				.slideToggle(300);

			// Make sure that all classes are deselected and that the special itemExtra is hidden
			$pageContentSector.find(".pageContentItemSelected").toggleClass("pageContentItemSelected");
			$pageContentSector.find(".pageContentItemExtra").hide();
		}
		
	});

	/**
	 * Trigger for mouse events on the image
	 */
	$(document).on({
		"mouseenter": function () {
			$(this).find(".file-uploader").show();
		},
		"mouseleave": function () {
			$(this).find(".file-uploader").hide();
		},
	}, ".infoContainerImage");

	/**
	  * CHECKBOX TOOL
	  */
	 
	/**
	 * Tool to change the state of a checkbox
	 * @return {null}
	 */
	$(document).on("click", ".editingMode .checkbox", function (event, propagateSave, isPropagating) {

		if ($(this).attr("readonly") == "readonly") return;

		// Define the default state of the variable
		if (typeof propagateSave === "undefined") propagateSave = true;

		// Toggle the state of the propagation save
		if (isPropagating == false && ($image.attr("data-shouldsavepropagation") == "no")) propagateSave = false;

		// Update the state of the propagation itself
		if (typeof isPropagating === "undefined") isPropagating = true;
		
		// We must stop the bubble
		event.stopPropagation();
	
		// Assign a reference
		$image = $(this);

		// Toggle the image
		if ($image.hasClass("active")) {
		    $image.attr("data-value", "0").attr('src', 'images/44-checkOff.png');
		} else {
			$image.attr("data-value", "1").attr('src', 'images/44-checkOn.png');
		}

		// Checkboxes need to cancel their parents, but we don't wanna save it on our database
		if (propagateSave) $image.trigger("instantSave");

		// A little animation to give the impression the user has put some pressure on the click (it's really cool)
		$image.toggleClass("active") // Toggle the class
			.width($image.width() * 1.25) // Set the width a little bigger
			.animate({
				"width": $image.width() / 1.25 // And then default it
			}, 100, function() {
				if ($image.attr("data-exclusive") == "yes" && isPropagating) {
					// Exclusive parent means that, from all the checkboxs below this parent, only one can be selected
					// The only expection is if you are an indie, which is autonomous and independent
				    $image.parents("[data-exclusiveparent='yes']").not("[data-indie!='yes']").find(".checkbox.active:visible").not($image).trigger("click", [true, false]);
				}
			});

	});

	/**
	  * CALENDAR TOOL
	  */
	
	/**
	 * Update the month everytime the human hits any key
	 * @return {null}
	 */
	$(document).on("keyup", ".calendarBox .month", function () {

		var month = parseInt($(this).val(), 10);

		if (month > 0 && month <= 12) {
			$(this).removeClass("badTime");
		} else {
			$(this).addClass("badTime");
		}
	});

	/**
	 * Update the day everytime the human hits any key
	 * @return {null}
	 */
	$(document).on("keyup", ".calendarBox .day", function () {

		var day = parseInt($(this).val(), 10);

		if (day > 0 && day <= 31) {
			$(this).removeClass("badTime");
		} else {
			$(this).addClass("badTime");
		}
	});

	/**
	 * Update the hour and minute everytime the human hits any key
	 * @return {null}
	 */
	$(document).on("keyup", ".calendarBox .hour", function () {
		
		var hour = parseInt($(this).val(), 10);

		if (hour >= 0 && hour < 24) {
			$(this).removeClass("badTime");

			var mins = parseInt($(this).siblings(".minute").val(), 10) || 0;
			var hdegree = hour * 30 + (mins / 2);
			var hrotate = "rotate(" + hdegree + "deg)";

			$(this).closest(".timeBox").siblings(".clock").find("#hour").css({
				"-webkit-transform": hrotate,
				"-moz-transform": hrotate,
				"-ms-transform": hrotate,
				"-o-transform": hrotate,
				"transform": hrotate,
			});
		} else {
			$(this).addClass("badTime");
		}
	});

	/**
	 * Update the minute everytime the human hits any key
	 * @return {null}
	 */
	$(document).on("keyup", ".calendarBox .minute", function () {

		var mins = parseInt($(this).val(), 10) || 0;

		if (mins >= 0 && mins < 60) {
			$(this).removeClass("badTime");

			var mdegree = mins * 6;
			var mrotate = "rotate(" + mdegree + "deg)";

			// Update the hour
			$(this).siblings(".hour").trigger("keyup");

			// Update the minute
			$(this).closest(".timeBox").siblings(".clock").find("#min").css({
				"-webkit-transform": mrotate,
				"-moz-transform": mrotate,
				"-ms-transform": mrotate,
				"-o-transform": mrotate,
				"transform": mrotate,
			});
		} else {
			$(this).addClass("badTime");
		}
	});

});});