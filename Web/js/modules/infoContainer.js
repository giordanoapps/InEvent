$(document).ready(function() {

// -------------------------------------- INFO CONTAINER -------------------------------------- //

	/* Info Cointainer is the name of the generic class I have created to all its subclasses, including infoContainer, card, post , etc ... */

	/**
	 * Trigger for mouse events on the image
	 */
	$(".infoContainerImage").live({
		"mouseenter": function () {
			$(this).find("#file-uploader").show();
		},
		"mouseleave": function () {
			$(this).find("#file-uploader").hide();
		},
	});

	/**
	  * CHECKBOX TOOL
	  */
	 
	/**
	 * Tool to change the state of a checkbox
	 * @return {null}
	 */
	$(".checkbox:not(.active)").live("click", function(event, isPropagating) {

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
	
});