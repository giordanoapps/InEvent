$(document).ready(function() {

// ------------------------------------- SEARCH ------------------------------------- //

	/**
	 * Search trigger
	 * @return {null}
	 */
	$(".searchBoard form").live("submit", function () {
		// We just trigger a click on the magnifier
		$(".searchBoardImg").trigger("click");
		
		return false;
	});
	
	/**
	 * Search button has been clicked
	 * @return {null}
	 */
	$(".searchBoardImg").live("click", function () {
		// We get the search query
		var searchText = $(".searchBoardInput").val();
		
		// We gotta split the text
		var max = 0;
		var splitText = searchText.split(" ");
		
		// Get the size of the biggest string
		for (var i = 0; i < splitText.length; i++) {
			if (splitText[i].length > max) {
				max = splitText[i].length;
			}
		}
		
		// And then check it to see if it matches the minimum size and is not empty
		if (max > 0 && max < 4) {
			$(".searchBoardInput").addClass("searchBoardInputFalse");
			return false;
		} else {
			$(".searchBoardInput").removeClass("searchBoardInputFalse");
		}
		
		var destiny = $(this).parents(".pageContent").attr("data-ajax");
		
		// And then we send it to the server, if the conditions have been met
		$.post(destiny + '.php',
		{	
			searchQuery: "searchQuery", 
			searchText: $(".searchBoardInput").val()
		}, 
		function(data) {
			// And we print it on the appropriate box
			$(".pageContentSearchBox").show().html(data);
			// While hiding the full result box
			$(".pageContentBox").hide();
		}, 'html' );
		
	
	});
	
	/**
	 * Update input relative to given input
	 * @return {null}
	 */
	$(".searchBoardInput").live("keyup", function () {
		// If we have an empty string, we can reset it
		if ($(this).val().length == 0) {
			// By reseting the color and the boxes
			$(this).removeClass("searchBoardInputFalse");
			$(".pageContentSearchBox").hide();
			$(".pageContentBox").show();
		} else {
			$(".searchBoardImg").trigger("click");
		}
	});
	
});