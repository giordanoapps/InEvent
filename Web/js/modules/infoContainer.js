$(document).ready(function() {

// -------------------------------------- INFO CONTAINER -------------------------------------- //

	/* Info Cointainer is the name of the generic class I have created to all its subclasses, including infoContainer, card, post , etc ... */


	/**
	 * Select input text on click and reset
	 */
	// $(".infoContainer input").live("focusin", function() {
	// 	$(this).val("");
	// });

	/**
	 * Trigger for mouse events on the image
	 */
	$(".infoContainerImage").live({
		"mouseenter": function () {
			$(this).find("#file-uploader").show();
		},
		"mouseleave": function () {
			$(this).find("#file-uploader").hide();
		},
	});

	/**
	 * Add new infoContainer on the page
	 * @return {null}
	 */
	$(".boardContent .menuInput#add").live("click", function() {
		
		// First we are going to delete all the forms and create a fresh one
		$(".newInfoContainer").remove();
	    $(".defaultInfoContainer").clone().removeClass("defaultInfoContainer").addClass("newInfoContainer").appendTo(".pageContentBox > ul"); // It gotta be the first element, otherwise it will drill down the whole chain

		// We select our newInfoContainer element
		var $newContainer = $(".newInfoContainer");
		
		// Then we calculate the vertical offset of the document right now relative to the bottom of the screen
		var vertical = $(document).scrollTop() + $(window).height();

		// And we write these values on the element
		$newContainer.slideDown(0).height($newContainer.height()).css({
			"top": vertical+"px"
		});

		// And the default function will handle the rest
		$newContainer.trigger("click");
	
	});

	/**
	 * Show the infoContainer
	 * @return {null}
	 */
	$(".infoContainer").live("click", function() {
		
		// We hold a reference to the container
		var $info = $(this);
		
		// We gotta make sure that the user is not clicking on an already selected badge
		if (!($info.hasClass("infoContainerSelected"))) {
		
			// We get the member ID using a hidden value
			var memberID = $info.find("#memberID").val();
			// And the part of url necessary for the ajax requisition
			var destiny = $(this).parents(".pageContent").attr("data-ajax");
			
			// Only load data for existing infoContainers
			if (!($info.hasClass("newInfoContainer"))) {
				// We request the information on the server
				$.post(destiny + '.php',
				{	
					infoContainerExtra: "infoContainerExtra", 
					memberID: memberID
				}, // And we print it on the screen
				function(data) {
					$info.find(".infoContainerExtra").html(data);
				}, 'html' );
			}
			
			// Then we get the position
			var offset = $info.position();
			var proportion = $(".sliderBoard").slider("value");
			var margin = ($info.offsetParent().width() - $info.width()*1.5 / proportion) / 2;

			// We save the old width and height
			$info.data("oldWidth", $info.width());
			$info.data("oldHeight", $info.height());

			// Set it on the badge element and animate
			$info.css({
				"left": offset.left,
				"top": offset.top,
			}).addClass("infoContainerSelected").animate({
				"width": $info.width()*1.5 / proportion + "px",
				"height": $info.height()*1.5 / proportion + "px",
				"top": 0,
				"left": 0,
				"right": 0,
				"font-size": "1.3em",
				"margin-left": margin + "px",
				"margin-right": margin + "px"
			}, 600, function () {
				$(".snowflake").addClass("blackSnowflake");
				// Revealing the ajax loaded content it the end
				$info.find(".infoContainerExtra").slideDown(400);
				// And we turn the edit button to visible
				$(".infoContainerSelected  .editButton").css("visibility", "visible");
			});

			// Case it is a new item, we can already set it on edit mode
			if ($info.hasClass("newInfoContainer")) {
			    $info.find(".editButton").trigger("click");
			}
			
			// And we make sure that the user is gonna see the right part of the webpage
			$('html, body').animate({ scrollTop: 0 }, 'slow');
		}

	});
	

	/**
	 * Hide the infoContainer
	 * @return {null}
	 */
	$(".snowflake").live("click", function() {

		// Hold a reference
		$info = $(".infoContainerSelected");

		// First we check if the user is still editing the form
		if ($info.hasClass("editMode")) {

			$info.find(".editButton").trigger("click");

			if (!($info.hasClass("newInfoContainer"))) {

				var vector = $info.find("form").serializeArray();
						
				// Since the function does not serialize the image, we have to do this ourselves
				if ($info.find(".infoContainerImage img").size() != 0) {
					vector[vector.length] = {
						"name": "photo",
						"value": $info.find(".infoContainerImage img").attr("src")
					}
				}

				if ($(this).np("consistentForm", vector) != true) {
					return;
				}
			}
		}

	
		// Second we remove the black opaque background
		$(this).removeClass("blackSnowflake");
		// And we turn the edit button hidden
		$info.find(".editButton").css("visibility", "hidden");

		// Then calculate the variables for the css
		var width = "", height = "", fontSize = "";

		// We see if the slider is available with this tool
		if ($(".sliderBoard").size() == 1) {
			width = $info.data("oldWidth");
			height = $info.data("oldHeight");
			fontSize = ($(".sliderBoard").slider("value") * 100 + "%");
		}

		// And then we selected the badge, remove the classes and leave the css properties zeroed and we slide the info up.
		$info
			.removeClass("infoContainerSelected")
			.css({
				"width": width,
				"height": height,
				"top": 0,
				"left": 0,
				"right": "",
				"font-size": fontSize,
				"margin-left":"",
				"margin-right": ""
			})
			.css("display", "")
			.find(".infoContainerExtra")
			.slideToggle(0);

		// If the user didn't save the infoContainer, we have to hide it
		if ($info.hasClass("newInfoContainer")) {
		    $info.css({
				"width": $info.width()/1.5 + "px",
				"height": $info.height()/1.5 + "px",
				"font-size": ""
			}).hide();
		}

	});

	/**
	 * Save the infoContainer (infoContainerSave clicked)
	 * @return {null}
	 */
	$(".infoContainerSelected .infoContainerSave").live("click", function () {
		
		// We just trigger the save function
		$(".infoContainerSelected .editButton").trigger("click");
		
	});

	/**
	 * Edit button has been clicked
	 * @param  {object} event Click events
	 * @return {null} 
	 */
	$(".infoContainerSelected .editButton").live("click", function () {

		// Call a method to save the form
		$(this).np("saveForm");
	});
	
});