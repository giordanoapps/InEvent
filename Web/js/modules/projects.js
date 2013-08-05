$(document).ready(function() {

// ------------------------------------- PROJECTS ------------------------------------- //

// 	VARS //
	var deleteImgHtml = "<img src='images/32-Cross.png' alt='Delete' class='collectionOptionsDelete' />";

// -------------------------------------- TABLE -------------------------------------- //

	/**
	 * Button to edit the project has been clicked
	 */
	$("#projectContent .editButton").live("click", function () {
		
		// One reference for the image and other for the parent container (we add the class for easiness on the parsing process
		var $ref = $(this);
		var $parent = $(this).parents(".projectBox").toggleClass("editMode");

		if ($parent.hasClass("editMode")) {
			$(this).toggle(0).attr('src', 'images/32-Check.png').fadeIn(500);

			$.post('ajaxProjects.php', {addProjectButton: "addProjectButton"}, 
				function(data) {

					// By far the longest method, but still and not event close to be the hardest one
					
					// This is the object that holds the generic form
					var $data = $(data);
					
					// Project ID
					$data.find("#projectID").val($parent.find("#projectID").val());
					
					// Image
					$data.find(".projectImage img").attr("src", ($parent.find(".projectImage img").attr("src")));
					
					// Name
					$data.find(".projectName input").val($parent.find(".projectName").text());
					
					// Date
					$data.find(".projectDate input").val($parent.find(".projectDate p.info").text());

					// Price
					//$data.find(".projectPrice input").val(parseFloat($parent.find(".projectPrice p.info").text().substr(3)));
					$data.find(".projectPrice input").val($parent.find(".projectPrice p.info").text());
					
					// Members
					$data.find(".projectMembers .collectionSelectedList")
						.append($parent.find(".projectMembers .projectPersonCellName")
						.removeClass("projectPersonCellName")
						.each(function () {
							$(this).append(deleteImgHtml);
						}));
						
					// Clients
					$data.find(".projectClients .collectionSelectedList")
						.append($parent.find(".projectClients .projectPersonCellName")
						.removeClass("projectPersonCellName")
						.each(function () {
							$(this).append(deleteImgHtml);
						}));
						
					// Consultants
					$data.find(".projectConsultants .collectionSelectedList")
						.append($parent.find(".projectConsultants .projectPersonCellName")
						.removeClass("projectPersonCellName")
						.each(function () {
							$(this).append(deleteImgHtml);
						}));
						
					// Headline
					$data.find(".projectHeadline p.content input").val($parent.find(".projectHeadline").text());
					
					// Description
					$data.find(".projectDescription p.content textarea").val($parent.find(".projectDescription p.content").text());
					
					// Submit
					$data.find(".projectSubmit input").val("Atualizar!");
					

					// Scroller
					$data.find(".selectOptions").mCustomScrollbar({
						scrollInertia: 0,
					});
					
					// And we update the content on the screen
					$parent.find(".completeInfo").html($data);

					// We create our widgets
					$data.find("#dateInput").np("dateVerification");
				
					// Creating the uploader
					var uploader = new qq.FileUploader({
						// pass the dom node (ex. $(selector)[0] for jQuery users)
						element: document.getElementById('file-uploader'),
						// path to server-side upload script
						action: 'fileuploader.php',
						
						onComplete: function(id, fileName, responseJSON){
							
							$(".qq-upload-list").css("display", "none");
							$(".completeInfo .projectImage img").attr("src", "uploads/"+responseJSON.fileName);
							
						}
					});
					
				}, 'html' );
			
		} else {
			$(this).toggle(0).attr('src', 'images/64-Pencil.png').fadeIn(500);

		}
	});
	
	/**
	 * Load the complete information of the clicked project
	 */
	$("#projectContent .reducedInfo").live("click", function() {
		var ref = $(this);
		var dest = $(this).parents(".projectBox").find(".completeInfo");
		var id = $(this).parents(".projectBox").find("#projectID").val();
		
		if(dest.is(":visible")) {
			dest.slideUp(500);
		} else {
			$.post('ajaxProjects.php', {projectComplete: id}, 
				function(data) {
					dest.html(data).slideDown(500);
				}, 'html' );
		}

	});

	/**
	 * Button to add a new project
	 */
	$("#projectContent .menuBoardInput#addProject").live("click", function () {
		
		$.post('ajaxProjects.php', {addProjectButton: "addProjectButton"}, 
			function(data) {

				$data = $(data);

				$(".optionContent").html($data).slideDown(500);


				$data.find("#dateInput").np("dateVerification");
			
				// Creating the uploader
				var uploader = new qq.FileUploader({
					// pass the dom node (ex. $(selector)[0] for jQuery users)
					element: $data.find('#file-uploader')[0],
					// path to server-side upload script
					action: 'fileuploader.php',
					
					onComplete: function(id, fileName, responseJSON){
						
						$data.find(".qq-upload-list").css("display", "none");
						$data.find(".projectImage img").attr("src", "uploads/"+responseJSON.fileName);
						
					}
				});
				
			}, 'html' );
	});

	/**
	 * Save the project
	 */
	$("#projectContent #projectSubmitButton").live("click", function () {
		
		// Here we have the parent, everything has to be namespaced
		var $parent = $(this).parents(".projectBox");
		
		// We gotta know if the user is inserting a new project or updating an old one
		var id = $parent.find("#projectID").val();
		var image = $parent.find("#imageImg").attr("src");
		var date = $parent.find("#dateInput").val();
		var price = $parent.find("#priceInput").val();
		var name = $parent.find("#nameInput").val();
		var members = [], clients = [], consultants = [];
		var headline = $parent.find("#headlineInput").val();
		var description = $parent.find("#descriptionTextarea").val();
		var updateText = $parent.find("#updateTextarea").val();
		var updateStatus = $parent.find(".projectUpdates .selectSelected li").val();
		
		$parent.find(".projectMembers .collectionSelectedList li").each(function (index) {
			members[index] = $(this).val();
		});
		$parent.find(".projectClients .collectionSelectedList li").each(function (index) {
			clients[index] = $(this).val();
		});
		$parent.find(".projectConsultants .collectionSelectedList li").each(function (index) {
			consultants[index] = $(this).val();
		});

					
		$.post('ajaxProjects.php',
		{	
			projectSubmitButton: "projectSubmitButton",
			id: id,
			image: image,
			date: date,
			price: price,
			name: name,
			members: members,
			clients: clients,
			consultants: consultants,
			headline: headline,
			description: description,
			updateText: updateText,
			updateStatus: updateStatus
		}, 
			function(data) {
				$('html, body').animate({ scrollTop: 0 }, 'slow');
			
				$parent.slideToggle().html(data).fadeIn(1000, function () {
					$parent.slideToggle(500);
					
					$.post('ajaxProjects.php', {printProjects: "printProjects"}, 
						function(data) {
							$(".pageContentBox").html(data);
							
							// Reset editing
							$parent.removeClass("editMode");
						}, 'html' );
				});
			}, 'html' );
				
	});
	
	/**
	 * Change the project status while editing
	 */
	$("#projectContent .projectUpdatesContent .selectOptions li").live("click", function () {
		$(this).parents(".projectUpdatesContent").css("background-color", $(this).css("background-color"));
	});
	
});