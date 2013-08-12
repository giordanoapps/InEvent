$(document).ready(function() {


// -------------------------------------- LOADER -------------------------------------- //
	
	/**
	 * Page initialization
	 * @return {null}
	 */
	$("#homeContent").live("hashDidLoad", function() {

		// Focus on the element so the key event may work
		$(this).focus();

		// Select the first section
		$(this).find(".section:first-child").addClass("sectionVisible");
	
		// Trigger the initial animation		
		$(this).css("top", $(this).first().height()).trigger("loadCover", [-100]);

	});


// -------------------------------------- PAGE -------------------------------------- //


	/**
	 * Calculate the position and scroll the menuContent every time the human slides the screen
	 * @return {null}       
	 */
	$("#homeContent").live("mousewheel", function(event, delta, deltaX, deltaY) {
		// What the y position of the scroll is
		$(this).trigger("loadCover", [deltaY]);
	});


	/**
	 * Change the current cover
	 * @return {null}
	 */
	$("#homeContent").live("loadCover", function(event, y) {

		// Only scroll if no animation is taking place
		if(!$(this).is(":animated")) {

			var height = 0;
			var parentHeight = $(this).height() * $(this).children().length;
			var childHeight = $(this).first().height();
			var top = parseFloat($(this).css("top")) || 0;

			// Go down
			if (y > 0.2 && top < 0) {
				height = childHeight;

			// Go up
			} else if (y < -0.2 && top > childHeight - parentHeight) {
				height = -childHeight;
			}

			if (height != 0) {

				var nextPosition = top + height;

				var $home = $(this);
				var $section = $home.find(".section").eq(Math.floor(Math.abs(nextPosition) / Math.abs(height)));
				var $deck = $section.find(".deck");

				// Hide all the decks to animate them later
				$home.find(".deck").hide(200);

				// Animate the transition
				$(this).animate({
					"top": nextPosition
				}, 500, "linear", function() {

					// Mark the current visible section
					$section.siblings(".sectionVisible").removeClass("sectionVisible").end().addClass("sectionVisible");
					
					// Animate the deck
					$deck.toggle("bounce", {
						distance: 12,
						times: 2
					}, 220);

				});

			}
		}

	});

	$("#homeContent").live("keyup", function(event) {
		
		var code = (event.keyCode ? event.keyCode : event.which);
		// Enter keycode
		if (code == 33 || code == 38) {
			$(this).trigger("loadCover", [100]);
		} else if (code == 34 || code == 40) {
			$(this).trigger("loadCover", [-100]);
		}

	 });


// ------------------------------------- HOME ------------------------------------- //

	/**
	 * Login button has been clicked
	 */	
	$(".userLoginLeading").live("click", function () {
		
		$(this).siblings(".userLoginBox").slideToggle(500);
	
		if ($(this).siblings(".userRegisterBox").is(":visible")) {
			$(this).siblings(".userRegisterBox").slideToggle(500);
		}

	});

});