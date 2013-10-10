define(["jquery", "common"], function($) {$(function() {

// ----------------------------------- USER SETTINGS ---------------------------------- //
	
	/**
	 * First item
	 */
	$(".bar").on({
		mouseenter: function () {			
			$(this).find(".firstAnchor").stop(false, true).fadeIn(100);
		},
		mouseleave: function () {
			$(this).find(".firstAnchor").delay(100).fadeOut(100);
		},
	}, ".firstItem");
	
	/**
	 * First anchor
	 */
	$(".bar").on({
		mouseenter: function () {
			$(this).stop(true, true);
		},
		mouseleave: function () {
			$(this).delay(100).fadeOut(100);
		},
	}, ".firstAnchor");
	
	/**
	 * Second item
	 */
	$(".bar").on({
		mouseenter: function () {
			$(this).find(".secondAnchor").stop(false, true).fadeIn(100);
		},
		mouseleave: function () {
			$(this).find(".secondAnchor").delay(100).fadeOut(100);
		},
	}, ".secondItem");
	
	/**
	 * Second anchor
	 */
	$(".bar").on({
		mouseenter: function () {
			$(this).stop(true, true);
			$(this).parents(".secondItem").stop(false, true).fadeIn(100);
		},
		mouseleave: function () {
			$(this).delay(100).fadeOut(100);
		},
	}, ".secondAnchor");
	
});});