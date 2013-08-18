$(document).ready(function() {

// -------------------------------------- WINDOW -------------------------------------- //

	/**
	 * Callback for toggling the state of the loadingBox
	 * @return {null}       
	 */
	$(".loadingBox").bind("ajaxSend", function(event, jqxhr, settings) {
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
	$(".menuContent").live("resizeBar", function() {
		$(this).width($(this).parent().width() - $(this).css("padding-left").replace("px", "") - $(this).css("padding-right").replace("px", ""));
	});

	/**
	 * Callback for toggling the state of the loadingBox
	 * @return {null}       
	 */
	$(".errorBox").bind("ajaxError", function(event, jqXHR, settings) {
		if (jqXHR.status != 408) {
			$(this).fadeToggle(200);
		}
	});

	$(document).bind("ajaxComplete", function(event, jqXHR, settings) {

		// Tips
		$("[title != '']").qtip({
		    style: {
		    	classes: 'qtip-light qtip-rounded qtip-shadow'
		    },
		    position: {
		        my: 'top left',
		        at: 'center right',
		        target: "event" // my target
		    }
		});
	});
});