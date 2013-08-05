$(document).ready(function() {

// -------------------------------------- SELECT -------------------------------------- //

	var selectBoxOpen = false;

	/**
	 * If the member clickd on the document and the select box is not yet closed, we do so
	 * @return {[type]} [description]
	 */
	$(document).on("click", function () {
		if (selectBoxOpen == true) {
			$(".selectBox .selectSelected").trigger("click"); // Close all open selected boxes
		}
	});

	/**
	 * Select box has been clicked
	 * @return {null}
	 */
	$(".selectBox .selectSelected").live("click", function () {
		var $selected = $(this);
		
		if ($(this).siblings(".selectOptions").is(":visible")) {
			$(this).removeClass("selectSelectedOpen").siblings(".selectOptions").slideUp(0);
			selectBoxOpen == false;
		} else {
			$(document).find(".selectBox .selectOptions").slideUp(0); // Close all open selected boxes
			$(this).addClass("selectSelectedOpen").siblings(".selectOptions").slideDown(0, function () {
				$selected.siblings(".selectOptions").mCustomScrollbar("update");
			}); // Open the clicked select box
			selectBoxOpen == true;
		}
	});
	
	/**
	 * One of the select box options has been clicked
	 * @return {null}
	 */
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