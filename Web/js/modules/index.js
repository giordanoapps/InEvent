$(document).ready(function() {


// -------------------------------------- LOADER -------------------------------------- //
	
	/**
	 * Page initialization
	 * @return {null}
	 */
	$("#homeContent").live("hashDidLoad", function() {

		var $thumbs = $(this).find(".coolBoxSelfish.thumbs");

		$thumbs.one('inview', function (event, visible) {
			if (visible == true) {
		    	$thumbs.find(".diagonalBox").addClass("diagonalBoxAnimated");
			}
		});

	});

// -------------------------------------- PAGE -------------------------------------- //
	
	/**
	 * Page initialization
	 * @return {null}
	 */
	$("#homeContent .coolBoxSelfish.thumbs .upperBox img").live("click", function() {

		// Toggle content
		$(this).closest(".thumbs").find(".dock").slideToggle(300);
		
		if ($(this).attr('src') == 'images/64-Pencil.png') {
			$(this).toggle(0).attr('src', 'images/32-Check.png').fadeIn(500);
		} else {
			$(this).toggle(0).attr('src', 'images/64-Pencil.png').fadeIn(500);
		}

	});

// ------------------------------------- INDEX ------------------------------------- //

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

// -------------------------------------- TABLE -------------------------------------- //

	// DISPLAY BADGE
	$("#homeContent .indexContentTypeOption").live("click", function() {
		
		// We gotta know where the content are
		var ref = $(this).find(".indexContentTypeOptionContent");
		// And make a deep copy of it
		var clone = $(this).find(".indexContentTypeOptionContentWrapper").clone();

		// We send the information to the server
//		$.post('ajaxIndex.php',
//		{	
//			badgeExtra: "badgeExtra", 
//			memberID: memberID
//		}, // And we print it on the screen
//		function(data) {
//			ref.find(".badgeExtra").html(data);
//		}, 'html' );

		
		// Then we get its position
		var offsetRef = ref.position();
		
		// We need to append the clone to the body so we can calculate the difference between the absolute position and its relative position
		// So first we must set the same css properties for height and width and set the visibility to hidden (so the user will not see it)
		clone.css({
			"width": ref.width(),
			"height": ref.height(),
			"visibility": "hidden"
		});
		
		// Then we can add it to the system
		clone.appendTo(".boardContent");
		
		// And we set a minimum height for the wrapping box
		$(".boardContent").css("min-height", (offsetRef.top + ref.height() + 20) + "px");
		
		// We calculate where the clone is supposed to be, plus its original parent width for later calculations
		var offsetClone = clone.find(".indexContentTypeOptionContent").position();
		var width = ref.parents(".indexContentType").width();
		
		// And then we make it absolute
		clone.addClass("indexContentTypeOptionContentSelected");
		
		// And we define the css that will place it right above the original copy
		clone.css({
			"width": ref.width(),
			"height": ref.height(),
			"left": offsetRef.left,
			"top": offsetRef.top,
			"visibility": "visible"
		});
	
		// We fade the box out
		ref.parents(".indexContentType").fadeOut(600, function () {
			// And we recalculate the positions of the new box (with relative positioning now)
			clone.css({
				"left": offsetRef.left - offsetClone.left,
				"top":offsetRef.top - (offsetClone.top - width),
				"position": "relative"
			});
	
			// And to finish we just expand the option
			clone.css("height", '').addClass("indexContentTypeOptionContentAnimated", 800);
		});


	});

});