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
			$(this).find("#file-uploader").show();
		},
		"mouseleave": function () {
			$(this).find("#file-uploader").hide();
		},
	}, ".infoContainerImage");

	/**
	  * CHECKBOX TOOL
	  */
	 
	/**
	 * Tool to change the state of a checkbox
	 * @return {null}
	 */
	$(document).on("click", ".checkbox", function (event, isPropagating) {

		if ($(this).attr("readonly") == "readonly") return;
		// Toggle the state of the propagation save
		propagateSave = true;
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
				    $image.parents("[data-exclusiveparent='yes']").not("[data-indie!='yes']").find(".checkbox.active:visible").not($image).trigger("click", [false]);
				}
			});

	});
	
});});