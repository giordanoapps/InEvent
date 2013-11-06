// -------------------------------------- WINDOW -------------------------------------- //

var modules = [];
modules.push('jquery');
modules.push('common');

define(modules, function($) {$(function() {

	/**
	 * Callback for windows and popovers dismissal
	 * @return {null}       
	 */
	$("body").click(function () {

		// Only trigger the change if there is an activePopover
		if ($(this).data("activePopover")) {

			if (typeof $(this).data("activePopover") === 'function') {
				var f = $(this).data("activePopover");
				f.call($(".activePopover"));
			}
			$(".activePopover").removeClass("activePopover").slideUp(100);

			// Remove the boolean
			$(this).data("activePopover", false);
		}

		// Only trigger the change if there is an activeField
		if ($(this).data("activeField") == true) {
			// Trigger any instantSave component and then remove the field
			var $components = $(".activeField").removeClass("activeField").filter(".instantSave").pn("instantSave").end();

			// Remove the components
			$components.filter("input, textarea").field("removeField");
			$components.filter("select").attr("disabled", true).trigger("liszt:updated");

			// Remove the boolean
			$(this).data("activeField", false);
		}

	});

	/**
	 * Callback for toggling the state of the loadingBox
	 * @return {null}       
	 */
	$(".loadingBox").bind("ajaxSend", function(event, jqXHR, settings) {
		if (settings.url != "ajax.php") $(this).show();	
	}).bind("ajaxComplete", function() {
		$(this).hide();
	});

	/**
	 * Recalculates the window size after the resizing has ended
	 * @param  {object} event
	 * @return {null}
	 */
	$(window).smartresize(function(event) {
		$(".menuContent").trigger("resizeBar");
	});
	
	/**
	 * Calculate the size of the menu bar
	 * @return {null}       
	 */
	$(document).on("resizeBar", ".menuContent", function() {
		$(this).width($(this).parent().width() - $(this).css("padding-left").replace("px", "") - $(this).css("padding-right").replace("px", ""));
	});

	/**
	 * Callback for toggling the state of the loadingBox
	 * @return {null}       
	 */
	$(".errorBox").bind("ajaxError", function(event, jqXHR, settings) {
		if (jqXHR.status != 408) {
			$(this).stop(false, true).fadeToggle(200).delay(6000).fadeToggle(2000);
		}
	});

	/**
	 * Update the tips for every content load
	 * @return {null}       
	 */
	// $(document).on("hashDidLoad", function(event, jqXHR, settings) {
	// 	// Tips
	// 	$("[title != '']").qtip({
	// 	    style: {
	// 	    	classes: 'qtip-light qtip-rounded qtip-shadow'
	// 	    },
	// 	    position: {
	// 	        my: 'top left',
	// 	        at: 'center center',
	// 	        target: "event" // my target
	// 	    }
	// 	});
	// });
	
});});