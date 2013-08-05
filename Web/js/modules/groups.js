$(document).ready(function() {

	// 	VARS	//
	var draggingGroup = false;

	// ------------------------------------- GROUPS ------------------------------------- //
	
	/**
	 * Draggable button has been clicked
	 * @param  {object} event Click events
	 * @return {null} 
	 */
	$("#groupsContent .menu .editButton").live("click", function () {
		draggingGroup = !draggingGroup;
				
		if (draggingGroup) {
			// We change the icon
			$(this).toggle(0).attr('src', 'images/48-canDrag.png').fadeIn(500);
			
			// We load the draggable component
			$(".badgeListSortable").sortable({
				connectWith: ".badgeListSortable",
				placeholder: "badgeListSortablePlaceholder",
				stop: function (event, ui) {

					// Item
					$item = $(ui.item);
					
					$.post('ajaxGroups.php', {
						updateMemberGroup: "updateMemberGroup",
						memberID: $item.find("#memberID").val(),
						groupID: $item.parents(".post").val()
					}, 
					function(data) {
						if (data != "true") {
							$(".errorBox").fadeToggle(200);
						}
						
					}, 'html' );
				}
			}).disableSelection();
		} else {
			// We change the icon
			$(this).toggle(0).attr('src', 'images/48-drag.png').fadeIn(500);
			
			// And we cancel the draggable
			$(".badgeListSortable").sortable("destroy");
		}
		
	});

});