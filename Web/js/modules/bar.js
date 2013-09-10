// --------------------------------------- BAR --------------------------------------- //

define(["jquery", "common", "modules/cookie"], function($, common, cookie) {$(function() {

	/**
	 * Trigger for the login box
	 * @return {null}
	 */
	$(".bar .rightBar .anchorInnerHock").click(function (event) {

		$ref = $(this).parents(".anchorInfo");

		// Propagate only anchors
		if (!$(event.target).is(".mapIcon")) event.stopPropagation();

		// Register on our body that a popover is being presented
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
	 * Item has been clicked, we can hide the box
	 * @return {null}
	 */
	$(".bar .anchorBox a").click(function () {
		$(this).parents(".anchorBox").siblings(".anchorInnerHock").trigger("click");
	});

	$(".bar .loginBox").click(function (event) {
		event.stopPropagation();
	});

	/**
	 * Item has been clicked, we can hide the box
	 * @return {null}
	 */
	$(".bar .dynamicInput input").on({
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
	$(".bar .locationBox li:not(.header)").click(function (event) {

		// Create the cookie
		cookie.create("companyID", $(this).val(), 10);

		// Reload the page
		window.location.reload();
	});

	/**
	 * Change the selected tab
	 * @return {null}
	 */
	$(".barAdjacent a").click(function (event) {
		$(this).siblings().removeClass("tabSelected").end().addClass("tabSelected");
	});

});});