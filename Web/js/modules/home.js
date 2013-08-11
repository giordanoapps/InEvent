$(document).ready(function() {


// -------------------------------------- LOADER -------------------------------------- //
	
	/**
	 * Page initialization
	 * @return {null}
	 */
	$("#homeContent").live("hashDidLoad", function() {

		// $("body").trigger("click");

	});


// -------------------------------------- PAGE -------------------------------------- //

	/**
	 * Page initialization
	 * @return {null}
	 */
	$("#homeContent").live("loadCover", function(event, y) {

		if(!$(this).is(":animated")) {

			var height = 0;
			var top = parseFloat($(this).css("top")) || 0;

			console.log(y);

			if (y > 10 && top >= 0) {
				height = -$(this).first().height();
			} else if (y < -10 && top + $(this).first().height() < $(this).height()) {
				height = $(this).first().height();
			}

			if (height != 0) {

				$(this).animate({
					"top": top + height
				}, 300, "easeInQuad");

			}

		} else {

			console.log("not");
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