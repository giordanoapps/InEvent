$(document).ready(function() {

// --------------------------------------- BAR --------------------------------------- //

	/**
	 * Trigger for the login box
	 * @return {null}
	 */
	$(".bar .rightBar .anchorInnerHock").live("click", function (event) {

		$ref = $(this).parents(".anchorInfo");

		// Register on our body that a popover is being presented
		event.stopPropagation();
		$("body").data("activePopover", function() {
			$(this).siblings(".anchorInnerHock").trigger("click");
		});

		// Hide all the open boxes expect we
		$(".anchorInfoSelected").not($ref).removeClass("anchorInfoSelected").children(".anchorBox").slideUp(100);

		if ($ref.hasClass("anchorInfoSelected")) {
			$ref.children(".anchorBox").removeClass("activePopover").slideToggle(100, function () {
				$ref.removeClass("anchorInfoSelected");
			});

		} else {
			$ref.addClass("anchorInfoSelected");
			$ref.children(".anchorBox").addClass("activePopover").slideToggle(100);
			$ref.find("input").eq(0).focus();
		}
	});


	/**
	 * Don't allow the box to be hidden
	 * @return {null}
	 */
	$(".bar .rightBar .anchorBox").live("click", function (event) {
		event.stopPropagation();
	});

	/**
	 * Item has been clicked, we can hide the box
	 * @return {null}
	 */
	$(".bar .anchorBox a").live("click", function () {
		$(this).parents(".anchorBox").siblings(".anchorInnerHock").trigger("click");
	});


	/**
	 * Item has been clicked, we can hide the box
	 * @return {null}
	 */
	$(".bar .dynamicInput input").live({
		"focusin": function () {
			var $ref = $(this);
			$(this).siblings().find(".mapIcon").slideUp(100, function() {
				$ref.siblings().find(".searchIcon").slideDown(100);
			});
		},
		"focusout": function () {
			var $ref = $(this);
			$(this).siblings().find(".searchIcon").slideUp(100, function() {
				$ref.siblings().find(".mapIcon").slideDown(100);
			});
		},
	});

	/**
	 * Change the current selected company
	 * @return {null}
	 */
	$(".bar .locationBox li:not(.header)").live("click", function (event) {

		// Create the cookie
		createCookie("eventID", $(this).val(), 10);

		// Reload the page
		window.location.reload();
	});

	/**
	 * Change the selected tab
	 * @return {null}
	 */
	$(".barAdjacent a").live("click", function (event) {
		$(this).siblings().removeClass("tabSelected").end().addClass("tabSelected");
	});
});