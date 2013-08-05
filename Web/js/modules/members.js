$(document).ready(function() {

// ------------------------------------- MEMBERS ------------------------------------- //
	
	/**
	 * Active state of the member
	 * @return {null}
	 */
	$("#membersContent .infoContainerSelected .badgeActive").live("click", function () {
	
		var $badge = $(this).parents(".badge");
		
		// We change the label
		if ($.trim($(this).text()) == "Ativar membro") {
			$(this).text("Arquivar membro");
		} else {
			$(this).text("Ativar membro");
		}
		
		// We don't need to send information referencing the state of the user because we will always invert its state
		$.post('ajaxMembers.php', {
			updateMemberActive: "updateMemberActive",
			memberID: $badge.find("#memberID").val()
		}, 
		function(data) {}, 'html');
	});
	
	/**
	 * Load events information
	 * @return {null}
	 */
	$("#membersContent .infoContainerSelected .badgeNewEvent").live("click", function () {
	
		$badge = $(this).parents(".badge");
	
		$badge.find(".badgeHistory").html(" \
			<p class='general'><span class='bold'>Novo evento:</span> <input class='badgeFieldContent' name='historyText' type='text'></input></span></p> \
			<p class='general'><span class='bold'>Data:</span> <input class='badgeFieldContent' name='historyDate' type='text'></input></span></p> \
			<div class='badgeNewEventSave saveButton'>Salvar!</div> \
		");
		
		$badge.find(".badgeFieldContent[name='historyDate']").np("dateVerification");
		
		$badge.find(".badgeNewEventSave").show();
	});
	
	/**
	 * Save a new event 
	 * @return {null}
	 */
	$("#membersContent .infoContainerSelected .badgeNewEventSave").live("click", function () {
		var $info = $(this).parents(".badge");
		
		var memberID = $info.find("#memberID").val();
		var vector = $info.find("form").serializeArray();
		
		if ($info.np("consistentForm", vector) == true) {
			
			// We send the data to the server
			$.post('ajaxMembers.php',
			{	// We are gonna roll it down according to the badge content flow (so if the flow changes, the code has to change)
				saveForm: "saveForm",
				memberID: memberID,
				data: vector
			},
			function(data) {
				// And just need to make sure that the content was properly saved
				// We request the information on the server
				$.post('ajaxMembers.php',
				{	
					infoContainerExtra: "infoContainerExtra", 
					memberID: memberID
				}, // And we print it on the screen
				function(data) {
					$info.find(".infoContainerExtra").html(data);
				}, 'html');

				
			}, 'html');
		} else {
			$info.toggleClass("editMode").find(".saveButtonError").text("Insira todos os dados, incluindo a imagem.");	
		}
	
	});


	/**
	 * Create the form so the user can type in the new password
	 * @return {null}
	 */
	$("#membersContent .infoContainerSelected .badgeChangePassword").live("click", function () {
		
		// First we need to create our form
		var form = "<input placeholder='Nova senha' type='password'></input><div class='saveButton'>Trocar!</div";

		// We add an input and toggle some classes
		$(this).removeClass("badgeChangePassword").addClass("badgeSubmitChangePassword").html(form);

		// We have to show our save button too
		$(this).find(".saveButton").show();

	});

	/**
	 * Submit the new password
	 * @return {null}
	 */
	$("#membersContent .infoContainerSelected .badgeSubmitChangePassword .saveButton").live("click",function () {
		
		var $info = $(this).parents(".badge");
		var memberID = $info.find("#memberID").val();
		var newPassword = $(this).siblings("input").val();


		// We send the new password to our server
		$.post('ajaxMembers.php',
		{	
			changeMemberPassword: "changeMemberPassword", 
			memberID: memberID,
			newPassword: newPassword
		}, // And we print it on the screen
		function(data) {
			// Remove the old button
			$info.find(".badgeSubmitChangePassword").remove();
		}, 'html');
	
	});

});