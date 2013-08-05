$(document).ready(function() {

// ------------------------------------- COLLECTION ------------------------------------- //
	
	// Function for appending an element from the select box to the box
	function appendElement(ref) {
		var $parent = ref.parents(".collectionBox");
		// We need to hide the select box
		$parent.find(".collectionOptions").slideUp(0);
		// Then make a clone of the item and append it
		$parent.find(".collectionSelectedList").append(ref.clone().append("<img src='images/16-Cross.png' alt='Delete' class='collectionOptionsDelete' />"));
		// Reset the search box
		$parent.find(".collectionSelectedInput").val('');
	}
	
	$(".collectionBox").live("click", function () {
		// Focus on the input if the user has clicked on the box
		$(this).find(".collectionSelectedInput").focus();
	});

	
	// SEARCH
	$(".collectionBox .collectionSelectedInput").live("keyup", function (e) {
	
		var $parent = $(this).parents(".collectionBox");

		// We get the search query and the type
		var searchText = $(this).val();
		var searchType = $(this).attr("data-table");
		
		// Code for moving around the options with the keyboard
		switch (e.keyCode) {
			case 8: //backspace
				// Delete the last element if everything is empty
				if (searchText.length == 0 && $parent.find(".collectionSelectedList li").length > 0) {
					$parent.find(".collectionSelectedList li").eq(-1).remove();
				}
				return;
			case 13: // enter
				// Append select element to box
				$parent.find(".collectionOptionsItemFocus").removeClass("collectionOptionsItemFocus").trigger("click");
				return;
			case 38: // up
				// Go one option up
				var index = $parent.find(".collectionOptionsItemFocus").removeClass("collectionOptionsItemFocus").index() - 1;
				$parent.find(".collectionOptions li").eq(index).addClass("collectionOptionsItemFocus");
				return;
			case 40: // down
				// Go one option down
				var index = $parent.find(".collectionOptionsItemFocus").removeClass("collectionOptionsItemFocus").index() + 1;
				$parent.find(".collectionOptions li").eq(index).addClass("collectionOptionsItemFocus");
				return;
		}

		// We gotta split the text
		var max = 0;
		var splitText = searchText.split(" ");
		
		// Get the size of the biggest string
		for (var i = 0; i < splitText.length; i++) {
			if (splitText[i].length > max) {
				max = splitText[i].length;
			}
		}
		
		// And then check it to see if it matches the minimum size
		if (max < 3) {
			$(this).addClass("collectionSelectedInputFalse");
			$parent.find(".collectionOptions").slideUp(0);
		} else {
			$(this).removeClass("collectionSelectedInputFalse");
			
			// And then we send it to the server, if the conditions have been met
			$.post('ajax.php',
			{	
				searchQuery: searchType,
				searchText: searchText
			}, // And we print it on the screen
			function(data) {
				$parent.find(".collectionOptions").slideDown(0).html(data);
			}, 'html' );
		}
		
	
	});
	
	// Case the user leaves the box -- TODO
	$(".collectionBox .collectionSelectedInput").bind("focusout", function () {
		var $parent = $(this).parents(".collectionBox");
		$parent.find(".collectionOptions").slideDown(0);
	});
	
	// Delete the clicked item
	$(".collectionBox li img").live("click", function (event) {
		event.stopPropagation();
		$(this).parent().remove();
	});
	
	// Append the clicked element to the box
	$(".collectionBox .collectionOptions li").live("click", function () {
		// We make sure the user is clicking on a valid result
		if ($(this).val() != "0") {
			appendElement($(this));	
		}
	});
	
	// Remove the class resposible for keyboard moving if the user has decided to use the mouse
	$(".collectionBox .collectionOptions li").live("hover", function () {
		$(this).removeClass("collectionOptionsItemFocus");
	});
	
});