$(document).ready(function() {

// -------------------------------------- STYLE -------------------------------------- //

	/**
	 * Remove extra padding from selected elements
	 * @return {null}
	 */
	$("#presenceContent td").live("removePadding", function() {
		$(this).has(".multipleUsers").each(function() {
			$(this).css("padding", "0");
		});
	});

// -------------------------------------- LOADER -------------------------------------- //
	
	/**
	 * Page initialization
	 * @return {null}
	 */
	$("#presenceContent").live("hashDidLoad", function() {

		// We request the information on the server
		$.post("ajaxPresence.php",
		{	
			computerState: localStorage.getItem("tokenID") || "no",
		}, // And we print it on the screen
		function(data, textStatus, jqXHR) {
			if (data.status == 200) {
				$("#presenceContent #favoriteTool").trigger("click", [true]);
			}
		}, 'html');

	});

// -------------------------------------- START MENU -------------------------------------- //

	$("#presenceContent .startMenu .primary > div").live("click", function() {

		var $ref = $(this);
		var $menu = $ref.parents(".startMenu");
		var $primary = $menu.find(".primary");

		// Hide
		$menu.find(".middleLine").slideUp(0);
		
		// Show
		$primary.find("span").slideUp(0);

		$primary.find("img").animate({
			"width": "32px"
		}, 300);

		var $element = $menu.find(".secondary ." + $ref.attr("class"));
		if (!$element.is(":visible")) {
			$menu.find(".secondary > div").not($element).fadeOut(300, function() {
				$menu.find(".secondary ." + $ref.attr("class")).fadeIn(300);
			});
		}

		$menu.find("select").chosen({
			width: "35%",
			disable_search_threshold: 30
		});
	});

	$("#presenceContent .startMenu #createPeriod").live("click", function() {

		// We request the information on the server
		$.post("ajaxPresence.php",
		{	
			createPeriod: $(this).closest("form").serializeArray()
		}, // And we print it on the screen
		function(data, textStatus, jqXHR) {
			$("#presenceContent .calendarBox .weekSelected").trigger("click");
		}, 'html');
	});

	$("#presenceContent .startMenu #copyPeriod").live("click", function() {

		// We request the information on the server
		$.post("ajaxPresence.php",
		{	
			copyPeriod: $(this).closest(".startMenu").attr("data-timestamp"),
			shiftWeeks: $(this).siblings("#numberWeeks").val()
		}, // And we print it on the screen
		function(data, textStatus, jqXHR) {
			$("#presenceContent .calendarBox .weekSelected").trigger("click");
		}, 'html');
	});

// -------------------------------------- CALENDAR -------------------------------------- //

	/**
	 * Create a field to add the name of the new calendar
	 * @return {null}
	 */
	$("#presenceContent .calendarThumbNew .calendarThumbArt, #presenceContent .calendarThumb .title").live("click", function (event) {

		// Don't trigger the already created calendars
		event.stopPropagation();

		if ($(this).hasClass("calendarThumbArt")) {
			var $title = $(this).siblings(".title");
		} else {
			var $title = $(this);
		}

		$title.field("createField", "input", {"class": "titleButton"}).focus();
	});

	/**
	 * Create a new calendar
	 * @return {null}
	 */
	$("#presenceContent .calendarThumb .titleButton").live("keyup", function (event) {

		var code = (event.keyCode ? event.keyCode : event.which);
		// Enter keycode
		if (code == 13) {

			var $elem = $(this);
			var $thumb = $elem.closest(".calendarThumb");
			var name = $elem.val();

			// Trigger click outside the view as a dismissal
			$elem.field("removeField", {"class": "title"});

			if ($thumb.hasClass("calendarThumbNew")) {

				// Copy and add the new calendar
				$thumb.clone().insertAfter($thumb);

				// Animate the change
				$thumb.removeClass("calendarThumbNew");
				$thumb.find("img").slideUp(300);
				$thumb.find("p").slideDown(700);

				// Get the updated calendar
				$.post("ajaxPresence.php", {
					updateCalendar: 0,
					calendarName: name
				}, 
				function(data, textStatus, jqXHR) {
					if (data.status == 200) {
						// Update the newly created calendar setting it as the selected
						$thumb.attr("data-value", data);
						$thumb.find(".calendarThumbArt").trigger("click");
					}
				}, 'html');

			} else {

				$.post("ajaxPresence.php", {
					updateCalendar: $thumb.attr("data-value"),
					calendarName: name
				}, 
				function(data, textStatus, jqXHR) {
					if (data.status == 200) {
						// Update the calendar with its updated name
						$thumb.find(".title").text(name);
					}
				}, 'html');
			}
		}
	});

	/**
	 * Load a calendar
	 * @return {null}
	 */
	$("#presenceContent .calendarThumb .calendarThumbArt").live("click", function () {
		
		var $parent = $(this).closest(".optionContent");
		$parent.find(".calendarThumbArtSelected").removeClass("calendarThumbArtSelected");
		$(this).addClass("calendarThumbArtSelected");

		var calendarID = $(this).closest(".calendarThumb").attr("data-value");

		// Get the updated calendar
		$.post("ajaxPresence.php", {
			showMonth: 0,
			calendarID: calendarID
		}, 
		function(data, textStatus, jqXHR) {
			if (data.status == 200) {
				// Append the content to the left
				$(".placerContent").html(data);

				// Clean the table _ TODO
				$(".realContent").html("");
			}
		}, 'html');
	});

	/**
	 * Load all the available calendars
	 * @return {null} 
	 */
	$("#presenceContent #calendarTool").live("click", function () {
		
		$.post("ajaxPresence.php", {
			showCalendars: "showCalendars"
		}, 
		function(data, textStatus, jqXHR) {
			$(".optionContent").html(data).slideToggle(500);
		}, 'html');
	});

// -------------------------------------- PERIOD -------------------------------------- //
	
	/**
	 * Load information for each week
	 * @return {null}
	 */
	$("#presenceContent .calendarBox .week").live("click", function () {
	
		$(".week").removeClass("weekSelected");
		$(this).addClass("weekSelected");

		var timestamp = $(this).attr("data-timestamp");
		
		$.post("ajaxPresence.php", {
			getPeriod: timestamp
		}, 
		function(data, textStatus, jqXHR) {
			if (data.status == 200) {
				$(".realContent").fadeOut(0).html(data).fadeIn(500);
			}
		}, 'html');
			
	});

// -------------------------------------- CREATE -------------------------------------- //
	
	/**
	 * Load the menu for a given week
	 * @return {null}
	 */
	$("#presenceContent #createTool").live("click", function () {
	
		var timestamp = $(".realContent table").attr("data-timestamp");

		if (typeof timestamp === 'undefined' || timestamp === false) {
			var timestamp = $(".realContent .startMenu").attr("data-timestamp");
		}
		
		$.post("ajaxPresence.php", {
			showCreateTool: timestamp
		}, 
		function(data, textStatus, jqXHR) {
			if (data.status == 200) {
				$(".realContent").fadeOut(0).html(data).fadeIn(500);
			}
		}, 'html');
			
	});

// -------------------------------------- ARROW -------------------------------------- //

	/**
	 * Change which week is on focus
	 * @return {null}
	 */
	$("#presenceContent #upArrow, #presenceContent #downArrow").live("click", function () {
	
		var timestamp = parseInt($(".calendarBox .week").first().attr("data-timestamp"), 10);
		var $wrapper = $(this).parent();
		
		// Disable it for no futher simultaneous requisitions 
		$wrapper.attr('disabled','disabled');

		// See which element was clicked
		timestamp = ($(this).attr("id") == "upArrow") ?  timestamp - 45 * 86400 : timestamp + 135 * 86400;

		// Get the updated calendar
		$.post("ajaxPresence.php", {
			showMonth: timestamp
		}, 
		function(data, textStatus, jqXHR) {
			$(".placerContent").html(data);
		}, 'html');

		// Enable the button
		$wrapper.removeAttr('disabled');
	});

	/**
	 * Change which week is on focus
	 * @return {null}
	 */
	$("#presenceContent #leftArrow, #presenceContent #rightArrow").live("click", function () {
	
		var $ref = $(this).parent();
		var $weeks = $("#presenceContent .calendarBox .week");
		
		// Disable it for no futher simultaneous requisitions 
		$ref.attr('disabled','disabled');

		// Get the index of the currently selected week
		var weekSelectedIndex = $weeks.index($weeks.filter(".weekSelected"));

		// See which element was clicked
		($(this).attr("id") == "leftArrow") ?  weekSelectedIndex-- : weekSelectedIndex++;

		// Animate the change
		$weeks.filter(".weekSelected").removeClass("weekSelected");
		
		// Load some new content
		$weeks.eq(weekSelectedIndex).addClass("weekSelected").trigger("click");

		// Enable the button
		$ref.removeAttr('disabled');
	});

// -------------------------------------- EDIT -------------------------------------- //

	/**
	 * Change edit mode
	 * @return {null}
	 */
	$("#presenceContent #editTool").live("click", function () {

		// Toggle content
		$("#presenceContent .dock").slideToggle(300);
		
		if ($(this).attr('src') == 'images/64-Pencil.png') {
			$(this).toggle(0).attr('src', 'images/32-Check.png').attr("data-active", true).fadeIn(500);
		} else {
			$(this).toggle(0).attr('src', 'images/64-Pencil.png').removeAttr("data-ctive").fadeIn(500);
		}
	});

// -------------------------------------- FAVORITE -------------------------------------- //

	/**
	 * Tool to favorite a carte
	 * @return {null}       
	 */
	$("#presenceContent #favoriteTool").live("click", function (event, propagate) {	
		
		// We must stop the bubble
		event.stopPropagation();
	
		$image = $(this);

		// Toggle the image
		if ($image.hasClass("favorite")) {
		    $image.attr('src', 'images/32-Unfavorite.png');
		} else {
			$image.attr('src', 'images/32-Favorite.png');
		}

		// A little animation to give the impression the user has put some pressure on the click (it's really cool)
		$image.toggleClass("favorite") // Toggle the class
			.width($image.width() * 1.25) // Set the width a little bigger
			.animate({
				"width": $image.width() / 1.25 // And then default it
			}, 100);

		if (propagate !== true) {
			// Toggle the tokenID
			$.post("ajaxPresence.php", {
				toggleToken:localStorage.getItem("tokenID") || "no",
			}, 
			function(data, textStatus, jqXHR) {
				// Save the item
				localStorage.setItem("tokenID", data);
			}, 'html');
		}

	});
	
// -------------------------------------- TABLE -------------------------------------- //
	
	/**
	 * Begin and end shift
	 * @return {null}
	 */
	$("#presenceContent .star").live("click", function () {
	
		if ($("#presenceContent #editTool").attr("data-active") != true) {
			var $elem = $(this);

			// Remove the old shift
			$elem.fadeOut(600);

			$.post("ajaxPresence.php", {
				confirm: $(this).val(),
				tokenID: localStorage.getItem("tokenID") || "no",
			}, 
			function(data, textStatus, jqXHR) {
			
				// Append the modified 
				var $parent = $elem.parent();
				$elem.remove();
				$parent.append($(data).hide().fadeIn(600));
				
			}, 'html').fail(function() {
				$elem.fadeIn(600);
			});
		}
		
	});
	

// -------------------------------------- DOCK -------------------------------------- //
	
	/**
	 * Request a user shift to change
	 * @return {null}
	 */
	$("#presenceContent .dock .edit").live("click", function () {

		var $cell = $(this).closest("td");
		var $photoThumb = $(this).closest(".photoThumb");
		var $picker = $cell.find(".picker");

		var presenceID = $photoThumb.val();

		// Prepare animation
		$photoThumb.find(".dock").hide(300);
		$photoThumb.find(".shadow").addClass("opacity");
		$photoThumb.append("<img src='images/64-loading.gif' class='loading'>");
		
		$.post("ajaxPresence.php", {
			membersList: "edit",
			presenceID: presenceID
		},
		function(data, textStatus, jqXHR) {
			if (data.status == 200) {

				// Animate and remove old member
				$photoThumb.fadeOut(600, function() {
					// Remove old member
					$photoThumb.remove();

					// Display a list of available members
					$picker.html(data).slideDown(300);
					$picker.find("select").chosen({
						width: "90%",
						disable_search_threshold: 100
					});
				});
			}
		}, 'html');
		
	});
		
	/**
	 * Add and remove members from a certain shift
	 * @return {null}
	 */
	$("#presenceContent .dock .remove").live("click", function () {
	
		var $cell = $(this).closest("td");
		var $photoThumb = $(this).closest(".photoThumb");

		var presenceID = $photoThumb.val();

		$photoThumb.find(".dock").hide(300);
		$photoThumb.find(".shadow").addClass("opacity");
		$photoThumb.append("<img src='images/64-loading.gif' class='loading'>");
		
		$.post("ajaxPresence.php", {
			removeShift: presenceID
		}, 
		function(data, textStatus, jqXHR) {
			// Animate and remove old member
			$photoThumb.fadeOut(600, function() {
				$photoThumb.remove();
			});

		}, 'html').fail(function() {
			$photoThumb.find(".dock").show(300);
			$photoThumb.find(".shadow").removeClass("opacity");
			$photoThumb.find(".loading").remove();
		});
	});

	/**
	 * Add and remove members from a certain shift
	 * @return {null}
	 */
	$("#presenceContent .dock .add").live("click", function () {
		
		var $cell = $(this).closest("td");
		var $picker = $cell.find(".picker");

		var siblingID = $cell.find(".photoThumb").first().val();

		$.post("ajaxPresence.php", {
			membersList: "add",
			presenceID: siblingID
		},
		function(data, textStatus, jqXHR) {
			if (data.status == 200) {

				// Display a list of available members
				$picker.html(data).slideDown(300);
				$picker.find("select").chosen({
					width: "90%",
					disable_search_threshold: 100
				});
			}
		}, 'html');
	});
	
	/**
	 * Confirm which shift has been changed
	 * @return {null	}
	 */
	$("#presenceContent #confirmSelect").live("change", function () {
		
		var $cell = $(this).closest("td");
		var $picker = $cell.find(".picker");
		var $list = $cell.find(".membersOnShift");

		var type = $(this).attr("data-type");
		var presenceID = $(this).attr("data-value");
		var choosenUser = $(this).val();

		$.post("ajaxPresence.php", {
			changeShift: type,
			memberID: choosenUser,
			presenceID: presenceID
		}, 
		function(data, textStatus, jqXHR) {
			if (data.status == 200) {

				// Hide the picker
				$picker.slideUp(600, function() {
					// Add the new content
					$list.append($(data).hide().fadeIn(600));
				});
			}
		}, 'html');
			
	});

// -------------------------------------- EXPLANATION -------------------------------------- //

	/**
	 * Request the addition of a new justification
	 * @return {null}
	 */
	$("#presenceContent .dock .review").live("click", function () {

		var presenceID = $(this).closest(".photoThumb").val();
		
		$.post("ajaxPresence.php", {
			paperAirplane: presenceID
		}, 
		function(data, textStatus, jqXHR) {
			$(".optionContent").html(data).slideDown(500).find("select").chosen({"width": "800px"});
			$("html, body").animate({ scrollTop: 0 }, 'slow');
		}, 'html');
	});
	
	/**
	 * Confirm the insertion of a justification
	 * @return {null}
	 */
	$("#presenceContent #addExplanation").live("click", function () {
	
		var ref = $(this).parent();
		var presenceID = $(this).parent().find("#presenceID").val();
		var justificationID = $("#justificationID").val();
		var justificationText = $("#justificationText").val();
		
		$.post("ajaxPresence.php", {
			addExplanationTool: presenceID,
			justificationID: justificationID,
			justificationText: justificationText
		}, 
		function(data, textStatus, jqXHR) {
			ref.toggle().html(data).fadeIn(800, function () {
				$(".optionContent").slideToggle(500);
			});
		}, 'html');
			
	});
	
	/**
	 * If the notification is already know, we can make a small tweak
	 * @return {null}
	 */
	$("#presenceContent #justificationID").live("change", function () {
		
		if ($(this).val() == "0") {
			$(this).siblings("#justificationTextBox").slideDown(500);
		} else {
			$(this).siblings("#justificationTextBox").slideUp(500);
		}
			
	});

// -------------------------------------- REVIEW -------------------------------------- //
	
	/**
	 * Request the explanations to be reviewed
	 * @return {null}
	 */
	$("#presenceContent #reviewTool").live("click", function () {
		
		$.post("ajaxPresence.php", {
			requestReview: "requestReview"
		}, 
		function(data, textStatus, jqXHR) {
			$(".optionContent").html(data).slideToggle(500);
		}, 'html');
	});
	
	/**
	 * Confirm which explanations have been reviewed
	 * @return {null}
	 */
	$("#presenceContent #handContraTool, #presenceContent #handProTool").live("click", function () {

		var ref = $(this).parents("#reviewBox");
		var refHandBox = $(this).parents("#handBox");
		var dateID = ref.find("#dateID").val();
		var decision = ($(this).attr("id") == "handContraTool") ?  -1 : 1;
		
		$.post("ajaxPresence.php", {
			confirmReview: dateID,
			decision: decision
		}, 
		function(data, textStatus, jqXHR) {
			refHandBox.html(data).fadeIn(800);
		}, 'html');
			
	});
	
});