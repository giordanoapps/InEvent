$(document).ready(function() {

// ------------------------------------- LOADERS ------------------------------------- //

	/**
	 * Remove date picker reference
	 */
	$(".ui-datepicker a").live("click", function() {
		$(this).removeAttr("href"); 
	});

	/**
	 * Make sure that the hash is set
	 */
	$(window).ajax("hashConfigureSource", window.location.hash);
	
});