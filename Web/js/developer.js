$(document).ready(function() {

// -------------------------------------- DEVELOPER -------------------------------------- //

	/**
	 * Change the currently selected documentation tab
	 * @return {null}
	 */
	$(".menuDocumentation li").live("click", function () {
		
		var index = $(this).index();
		
		if ($(".optionMenuDocumentationSelected").index() != index) {
			$(".optionMenuDocumentationSelected").removeClass("optionMenuDocumentationSelected");
			$(this).addClass("optionMenuDocumentationSelected");
			
			$(".documentationBoxSelected").fadeOut(300, function () {
				$(this).removeClass("documentationBoxSelected");
				$(".documentationBox").eq(index).fadeIn(300).addClass("documentationBoxSelected");
			
			});
		}

		// Highlight the content
		SyntaxHighlighter.highlight();
	
	});

	/**
	 * Trigger the inline api debugger
	 * @return {null}
	 */
	$(".contentDocumentation .documentFunctionName img").live("click", function () {
		
		var $sibling = $(this).closest(".documentationFunctionBox").next();

		if ($sibling.hasClass("demoDocumentation") && $sibling.is(":visible")) {
			$sibling.hide(200);
		} else {
			// Obtain the strings with the default values
			var get = $(this).attr("data-get") || "";
			var post = $(this).attr("data-post") || "";

			// Move the demo box to the right position
			var $demoDocumentation = $(".demoDocumentation");
			$demoDocumentation.insertAfter($(this).parents(".documentationFunctionBox")).show(200);

			// Append the token if it is available
			$demoDocumentation.find(".token").val(storageExpiration.load("devTokenID"));

			// Trigger a custom event
			$demoDocumentation.find("pre").trigger("callback", [post, get]);
		}
	});

	/**
	 * Update the debugger fields
	 * @param  {object} event
	 * @return {null}
	 */
	$(".demoDocumentation input").live("keydown", function (event) {
		
		// If the user is typing, we should only process it what he hits enter
		if (event.type == "keydown" && event.keyCode != 13) return;

		var $demoDocumentation = $(this).parents(".demoDocumentation");
		var $getWrapper = $demoDocumentation.find(".getWrapper");
		var $postWrapper = $demoDocumentation.find(".postWrapper");

		// Obtain the strings with the default values
		var get = $getWrapper.buildQuery();
		var post = $postWrapper.buildQuery();
		
		// Trigger a custom event
		$(".demoDocumentation pre").trigger("callback", [post, get]);
	});

	$.fn.buildQuery = function () {
		var str = "";
		$(this).find("div").each(function(index, elem) {
			if (index % 2 == 0 && index != 0) str += "&";

			if ($(this).hasClass("attribute")) {
				str += $(this).text();
			} else if ($(this).is("div")) {
				str += $(this).find("input").val();
			}
		});
		if (str.slice(-1) == "&") str = str.slice(0, -1);

		return str;
	};

	/**
	 * Process and display the debugger responses
	 * @param  {object} event
	 * @param  {string} post  post attributes
	 * @param  {string} get   get attributes
	 * @return {null}
	 */
	$(".demoDocumentation pre").live("callback", function (event, post, get) {
		
		var url = $(".oficialURL").text() + "?";
		var $demoDocumentation = $(this).parents(".demoDocumentation");

		/**
		 * GET
		 */
		var $getWrapper = $demoDocumentation.find(".getWrapper");
		var $getInput = $getWrapper.find(".inert").last().clone();
		$getInput.find("input").val('');
		$getWrapper.find("div").remove();

		var getTemp = get.split("&");
		if (getTemp.length == 1) getTemp = get.split(";");
		var getAttributes = $(this).displayAttributes($getWrapper, getTemp);

		var keys = Object.keys(getAttributes);
		for (var i = 0; i < keys.length; i++) {
			// Append the & caracter
			if (i != 0) url += "&";
			url += keys[i] + "=" + getAttributes[keys[i]];
		}

		// Append the parameters to the box
		$getWrapper.append($getInput);

		/**
		 * POST
		 */
		var $postWrapper = $demoDocumentation.find(".postWrapper");
		var $postInput = $postWrapper.find(".inert").last().clone();
		$postInput.find("input").val('');
		$postWrapper.find("div").remove();

		var postTemp = post.split("&");
		if (postTemp.length == 1) postTemp = post.split(";");
		var postAttributes = $(this).displayAttributes($postWrapper, postTemp);

		// Append the parameters to the box
		$postWrapper.append($postInput);

		/**
		 * AJAX
		 */
		$.ajax({
			url: url,
			dataType: "json",
			type: "POST",
			data: postAttributes,
			success: function(data) {
				// Append the content
				$demoDocumentation.find("pre").html(JSON.stringify(data, null, 2));
				SyntaxHighlighter.highlight();

				// Set the token returned by the server
				if (getAttributes["method"] == "member.signIn") {
					// Append to the document
					$demoDocumentation.find(".token").val(data["tokenID"]);

					// Save as a local storage object for one hour
					storageExpiration.save("devTokenID", data["tokenID"], 60);
				}
			},
			error: function(jqXHR, textStatus, errorThrown) {
				if (data.status == 200) {
					$demoDocumentation.find("pre").html(JSON.stringify(jqXHR.responseText, null, 2));
				} else {
					$demoDocumentation.find("pre").html(data.status + " " + data.statusText);
				}
			},
		});
	});

	/**
	 * Display the attibutes inside the wrapper
	 * @param  {object} $wrapper   Wrapper to append content
	 * @param  {object} attributes contents to be processed
	 * @return {object}            processed attributes
	 */
	$.fn.displayAttributes = function ($wrapper, attributes) {

		var processedAttributes = {};
		var tokenID = $wrapper.closest(".demoDocumentation").find(".token").val();

		for (var i = 0; i < attributes.length; i++) {
			// Split the attribute
			var attrTemp = attributes[i].split("=");
			// Process its size
			if (attrTemp.length >= 2) {
				// Input them inside the array 
				if (attrTemp[0] == "tokenID" && tokenID.length > 0) {
					processedAttributes[attrTemp[0]] = tokenID;
				} else {
					processedAttributes[attrTemp[0]] = attrTemp[1];
				}

				// Create the first element
				$(document.createElement("div")).addClass("attribute").text(attrTemp[0] + "=").appendTo($wrapper);

				// Create the second element
				if (attrTemp[0] == "method") {
					$(document.createElement("div")).addClass("attribute").text(processedAttributes[attrTemp[0]]).appendTo($wrapper);
				} else {
					var $input = $(document.createElement("input"))
									.attr("type", "text");

					var $div = $(document.createElement("div"))
									.addClass("inert")
									.append($input)
									.appendTo($wrapper);

					$input.attr("value", processedAttributes[attrTemp[0]]);
					$div.width((($input.val().length + 3) * 9) + 'px');
				}
			}
		}

		return processedAttributes;
	};

	$(".demoDocumentation .inert input").live("keydown", function (event) {
		$(this).parent().width((($(this).val().length + 3) * 9) + 'px');
	});


// -------------------------------------------------------------------------------------- //

});