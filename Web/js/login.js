$(document).ready(function() {


// -------------------------------------- BAR -------------------------------------- //

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
				$(".userRegisterBox .promoImage").css("background-image", "url('uploads/"+fileName+"')");
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

// -------------------------------------- SELECT -------------------------------------- //

	var selectBoxOpen = false;

	$(document).on("click", function () {
		if (selectBoxOpen == true) {
			$(".selectBox .selectSelected").trigger("click"); // Close all open selected boxes
		}
	});

	$(".selectBox .selectSelected").live("click", function () {
		if ($(this).siblings(".selectOptions").is(":visible")) {
			$(this).removeClass("selectSelectedOpen").siblings(".selectOptions").slideUp(0);
			selectBoxOpen == false;
		} else {
			$(document).find(".selectBox .selectOptions").slideUp(0); // Close all open selected boxes
			$(this).addClass("selectSelectedOpen").siblings(".selectOptions").slideDown(0); // Open the clicked select box
			selectBoxOpen == true;
		}
	});
	
	$(".selectBox .selectOptions li").live("click", function () {
		$(this).parents(".selectOptions")
			.slideToggle(0)
			.parents(".selectBox")
			.find(".selectSelected")
			.removeClass("selectSelectedOpen")
			.find("li")
			.removeClass("placeholder")
			.replaceWith($(this).clone()[0]); // we close the select box and then load the selected option on the correspoding div
	});

});