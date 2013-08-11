$(document).ready(function() {


// -------------------------------------- LOADER -------------------------------------- //
	
	/**
	 * Page initialization
	 * @return {null}
	 */
	$("#homeContent").live("hashDidLoad", function() {

		$(this).focus();

		$(this).find(".section:first-child").addClass("sectionVisible");

		// $(this).find(".deck").first().toggle("bounce", {
		// 	distance: 12,
		// 	times: 2
		// }, 300);

	 $(this).find(".deck").first().delay(1000).show(1000);
	});


// -------------------------------------- PAGE -------------------------------------- //

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
			if (y > 10 && top > childHeight - parentHeight) {
				height = -childHeight;

			// Go up
			} else if (y < -10 && top < 0) {
				height = childHeight;
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
		if (code == 38) {
			$(this).trigger("loadCover", [-100]);
		} else if (code == 40) {
			$(this).trigger("loadCover", [100]);
		}

	 });


// ------------------------------------- HOME ------------------------------------- //

	/**
	 * Login button has been clicked
	 */	
	$(".userLoginLeading").live("click", function () {
		$(".userLoginBox").slideToggle(500);
	
		if ($(".userRegisterBox").is(":visible")) {
			$(".userRegisterBox").slideToggle(500);
		}

		// Create the scroller
		$(".userLoginBox .selectOptions").mCustomScrollbar({
			scrollInertia: 0
		});
	});
	
	/**
	 * Register button has been clicked
	 */
	$(".userRegisterLeading").live("click", function () {
		$(".userRegisterBox").slideToggle(500);
		
		if ($(".userLoginBox").is(":visible")) {
			$(".userLoginBox").slideToggle(500);
		}
		
		// Creating the uploader
		var uploader = new qq.FileUploader({
			// pass the dom node (ex. $(selector)[0] for jQuery users)
			element: document.getElementById('file-uploader'),
			// path to server-side upload script
			action: 'fileuploader.php',
			
			onComplete: function(id, fileName, responseJSON){
				
				$(".qq-upload-list").css("display", "none");
				$(".userRegisterBox .promoImage").css("background-image", "url('uploads/"+responseJSON.fileName+"')");
				$(".userRegisterBox #file-uploader").css("visibility", "hidden");
			}
		});
	
	});
	
	/**
	 * Reduce the image size and insert the select box to choose another enterprise
	 */
	$(".userLoginBox .promoImage").live("click", function () {
		$(this).toggleClass("promoImageReduced", 500).siblings(".selectBox").slideToggle(400);
	});

	/**
	 * Change the enterprise id on the hidden input of the form
	 */
	$(".userLoginBox .selectOptions li").live("click", function () {
		$(".userMemberBox #enterprise").val($(this).val());
	});

});