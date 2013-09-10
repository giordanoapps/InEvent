// --------------------------------------- HOME --------------------------------------- //

define(["jquery", "common", "modules/cookie"], function($, common, cookie) {$(function() {

// -------------------------------------- LOADER -------------------------------------- //
	
	/**
	 * Page initialization
	 * @return {null}
	 */
	$("#homeContent").on("hashDidLoad", function() {

		// Focus on the element so the key event may work
		$(this).focus();

		$(this).find(".middlePort").delay(1000).animate({left: "30%"}, 300);

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
	$("#homeContent").on("mousewheel", function(event, delta, deltaX, deltaY) {
		// What the y position of the scroll is
		$(this).trigger("loadCover", [deltaY]);
	});


	/**
	 * Change the current cover
	 * @return {null}
	 */
	$("#homeContent").on("loadCover", function(event, y) {

		// Only scroll if no animation is taking place
		if(!$(this).is(":animated")) {

			var height = 0;
			var parentHeight = $(this).height() * $(this).children("article").length;
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
				}, 400, "linear", function() {

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

	/**
	 * Change the cover based on the keyboard (arrows and page's)
	 * @return {null}
	 */
	$("#homeContent").on("keyup", function(event) {
		
		var code = (event.keyCode ? event.keyCode : event.which);
		
		// Let's go up
		if (code == 33 || code == 38) {
			$(this).trigger("loadCover", [100]);

		// Let's go down
		} else if (code == 34 || code == 40) {
			$(this).trigger("loadCover", [-100]);
		}

	 });

	/**
	 * Change the cover for mobile devices
	 * @return {null}
	 */
	$("#homeContent").on("click", ".upperDeck, .deck", function(event) {

		if ($(this).hasClass("upperDeck")) {
			$(this).closest("#homeContent").trigger("loadCover", [100]);
		} else {
			$(this).closest("#homeContent").trigger("loadCover", [-100]);
		}

	 });

	/**
	 * Toggle the app deck
	 * @return {null}
	 */
	$("#homeContent").on("click", ".middlePort .trigger", function(event) {

		var $close = $(this).find(".close");
		var $open = $(this).find(".open");

		if ($close.is(":visible")) {
			$open.fadeIn(300);
			$close.fadeOut(300);
			$(this).closest(".middlePort").animate({left: "-40%"}, 300);
		} else {
			$open.fadeOut(300);
			$close.fadeIn(300);
			$(this).fadeIn(300).closest(".middlePort").animate({left: "30%"}, 300);
		}

	 });


// ------------------------------------- HOME ------------------------------------- //

	/**
	 * Login button has been clicked
	 */	
	$(".userLoginLeading").on("click", function () {
		
		$(this).siblings(".userLoginBox").slideToggle(500);
	
		if ($(this).siblings(".userRegisterBox").is(":visible")) {
			$(this).siblings(".userRegisterBox").slideToggle(500);
		}

	});

});});