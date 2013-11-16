var modules = [];
modules.push('jquery');
modules.push('common');
modules.push('modules/storageExpiration');

define(modules, function($, common, storageExpiration) {$(function() {

// -------------------------------------- LOADER -------------------------------------- //
	
	/**
	 * Page initialization
	 * @return {null}
	 */
	$("#developerContent").on("hashDidLoad", function() {
		// Load the first application
		$(this).find(".optionMenuApplicationCategory").first().trigger("click");
	});

// -------------------------------------- APPLICATION -------------------------------------- //

	/**
	 * Change the currently selected documentation tab
	 * @return {null}
	 */
	$("#developerContent").on("click", ".switch li", function () {
		
		var index = $(this).index();
		
		if ($(".switchCategorySelected").index() != index) {
			$(".switchCategorySelected").removeClass("switchCategorySelected");
			$(this).addClass("switchCategorySelected");
			
			$(".containerBoxSelected").fadeOut(300, function () {
				$(this).removeClass("containerBoxSelected");
				$(".containerBox").eq(index).fadeIn(300, function() {
					$(".menuContent").trigger("resizeBar");
				}).addClass("containerBoxSelected");
			});
		}
	
	});

	/**
	 * Change the currently selected documentation tab
	 * @return {null}
	 */
	$("#developerContent").on("click", ".menuApplication li", function () {
		
		var appID = $(this).val();

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "app.getDetails",
			appID: appID,
			format: "html"
		}), {},
		function(data, textStatus, jqXHR) {

			if (jqXHR.status == 200) {
				// Update content
				$(".contentApplication").html(data);
			}

		}, 'html');

		// Change some classes
		var className = "optionMenuApplicationSelected";
		$(this).siblings("." + className).removeClass(className).end().addClass(className);
	
	});

	/**
	 * Toggle the box
	 * @return {null}
	 */
	$("#developerContent").on("click", ".toolCreate", function(event) {
		$(this).closest(".toolBox").siblings(".toolBoxOptionsCreate").slideToggle(400).find("input").first().focus();
	});

	/**
	 * Add an app
	 * @return {null}
	 */
	$("#developerContent").on("click", ".toolBoxOptionsCreate .singleButton", function(event) {
		
		// Hide the current button
		var $elem = $(this).hide(200);

		// Get some properties
		var name = $elem.siblings(".name").val();

		// Get the minimum length
		if (name.length > 3) {

			// We request the information on the server
			$.post('developer/api/?' + $.param({
				method: "app.create",
				format: "html"
			}), {
				name: name
			},
			function(data, textStatus, jqXHR) {

				if (jqXHR.status == 200) {

					// Get some properties
					var $updatedItem = $(data);
					var $originalItem = $(".optionMenuApplicationCategory").last();

					// Copy the item
					$originalItem.clone().insertAfter($originalItem)
						.text($updatedItem.filter(".title").text())
						.val($updatedItem.filter(".secretBox").attr("data-appid"))
						.trigger("click");

				}

				// Reset UI
				$elem.fadeIn(300).siblings(".name").val('').closest(".toolBoxOptionsCreate").slideToggle(400);

			}, 'html').fail(function(jqXHR, textStatus, errorThrown) {
				$elem.fadeIn(300);
			});

		} else {
			// Reset UI
			$elem.fadeIn(300).siblings(".name").val('');
		}

	});

	/**
	 * Toggle the box
	 * @return {null}
	 */
	$("#developerContent").on("click", ".toolPerson", function(event) {
		$(this).closest(".toolBox").siblings(".toolBoxOptionsEnrollPerson").slideToggle(400).find("input").first().focus();
	});

	/**
	 * Add a person to the activity
	 * @return {null}
	 */
	$("#developerContent").on("click", ".toolBoxOptionsEnrollPerson .singleButton", function(event) {
		
		var $elem = $(this);

		var appID = $(".optionMenuApplicationSelected").val();
		var name = $elem.siblings(".name").val();
		var email = $elem.siblings(".email").val();

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "app.requestEnrollment",
			appID: appID,
			name: name,
			email: email,
			format: "html"
		}), {},
		function(data, textStatus, jqXHR) {

			// Hide the toolbar
			$elem.closest(".toolBoxOptionsEnrollPerson").slideToggle(400);

			// Reload the table
			// $scheduleItemSelected.trigger("click");
			$(".contentApplication").html(data);

			// Reset values
			$elem.siblings(".name").val('');
			$elem.siblings(".email").val('');

		}, 'html');

	});

	/**
	  * TEXT BOX
	  */

	/**
	 * Start a text inline edition
	 * @return {null}
	 */
	$("#developerContent").on("click", ".title", function(event) {

		// Make sure that we are on editing mode
		if (!$("#developerContent").hasClass("editingMode")) return true;
		if ($(this).hasClass("titleInput")) return true;

		// Get the value
		var value = $(this).text();

		// Create the input
		$(this).field("createField", "input", {
			"class" : $(this).attr("class") + " titleInput",
			"value" : value,
			"placeholder": value,
			"maxlength": 200
		}).focus();

		// Stop propagating
		event.stopPropagation();

    	// Prevent the anchor from propagating
    	event.preventDefault();
	    return false;
	});

	/**
	 * Conclude a text inline edition
	 * @return {null}
	 */
	$("#developerContent").on("keyup", ".titleInput", function(event) {

		// Remove the focus from the current field
		var code = (event.keyCode ? event.keyCode : event.which);
		if (code == 13) $(this).blur();
	});

	$("#developerContent").on("focusin", ".titleInput", function(event) {
		var $elem = $(this);
		$elem.one("focusout", function() {
			$elem.trigger("saveField");
		})
	});

	$("#developerContent").on("saveField", ".titleInput", function(event) {

		var $elem = $(this);

		var appID = $(".optionMenuApplicationSelected").val();
		var value = $elem.val();
		var name = $elem.attr("name");
		
		$elem = $elem.field("removeField", {"class": $elem.attr("class").replace(/titleInput/g, "")});

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "app.edit",
			appID: appID,
			name: name,
			format: "html"
		}), {
			value: value
		},
		function(data, textStatus, jqXHR) {
			// Update the text menu
			$(".optionMenuApplicationSelected").text(value);

		}, 'html').fail(function(jqXHR, textStatus, errorThrown) {});

	});

	/**
	 * Remove a person from the app
	 * @return {null}
	 */
	$("#developerContent").on("click", ".pickerItem .toolRemove", function(event) {

		event.stopPropagation();

		var $name = $(this).closest(".pickerItem").find(".name");
		var name = $name.text();
		var firstName = name.split(" ")[0];

		// Create the input
		$name
			.field("createField", "input", {
				"class" : $name.attr("class") + " removeInput",
				"value" : "",
				"placeholder": "Digite: " + firstName,
				"data-first": firstName,
				"data-name": name,
			}).focus();

		// Hide the current button
		$(this).hide(300);

	});

	/**
	 * Remove a person from the app
	 * @return {null}
	 */
	$("#developerContent").on("keyup", ".pickerItem .removeInput", function(event) {

		var code = (event.keyCode ? event.keyCode : event.which);
		// Enter keycode
		if (code == 13) {

			var $elem = $(this);

			if ($elem.val() == $elem.attr("data-first")) {
				$elem = $elem.val($elem.attr("data-name")).field("removeField", {"class": $elem.attr("class").replace(/removeInput/g, "")});

				var $pickerItem = $elem.closest(".pickerItem");
				var appID = $(".optionMenuApplicationSelected").val();
				var personID = $pickerItem.attr("data-value");

				// We request the information on the server
				$.post('developer/api/?' + $.param({
					method: "app.dismissEnrollment",
					personID: personID,
					appID: appID,
					format: "html"
				}), {},
				function(data, textStatus, jqXHR) {

					if (jqXHR.status == 200) {
						// Hide the current entry
						$pickerItem.slideDown(600, function() {
							$pickerItem.remove();
						});
					}

				}, 'html').fail(function(jqXHR, textStatus, errorThrown) {
					$elem.closest(".pickerItem").find(".toolRemove").fadeIn(300);
				});
			} else {
				$elem = $elem.val($elem.attr("data-name")).field("removeField", {"class": $elem.attr("class").replace(/removeInput/g, "")});

				// Show the button
				$elem.closest(".pickerItem").find(".toolRemove").fadeIn(300);
			}
		}

	});

	/**
	 * Attach an event to create a box to verify the person intention
	 * @return {null}
	 */
	$("#developerContent").on("verifyStep", ".title", function(event, classUnique) {

		event.stopPropagation();

		var $name = $(this);
		var name = $name.text();
		var firstName = name.split(" ")[0];

		// Create the input
		$name
			.field("createField", "input", {
				"class" : $name.attr("class") + " " + classUnique,
				"value" : "",
				"placeholder": "Digite: " + firstName,
				"data-first": firstName,
				"data-name": name,
				"data-class": classUnique
			}).focus();

	});

	$("#developerContent").on("keyup", ".title", function(event) {

		var code = (event.keyCode ? event.keyCode : event.which);
		// Enter keycode
		if (code == 13) {

			// Capture the current element
			var $elem = $(this);

			// Get its unique class
			var classUnique = $elem.attr("data-class");

			if ($elem.val() == $elem.attr("data-first")) {
				// Take the action
				$elem = $elem
					.val($elem.attr("data-name"))
					.trigger("takeAction")
					.field("removeField", {"class": $elem.attr("class").replace(classUnique, "", "g")});

			} else {
				// Revert the action
				$elem = $elem
					.val($elem.attr("data-name"))
					.trigger("revertAction")
					.field("removeField", {"class": $elem.attr("class").replace(classUnique, "", "g")});
			}
		}

	});

	/**
	 * Renew app credentials
	 * @return {null}
	 */
	$("#developerContent").on("click", ".secretBox .singleButton", function(event) {

		// Create a box to verify the action
		$(this).closest(".secretBox").siblings(".title").trigger("verifyStep", "renewInput");

		// Hide the current button
		$(this).hide(300);
	});

	$("#developerContent").on("takeAction", ".renewInput", function(event) {

		var appID = $(".optionMenuApplicationSelected").val();

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "app.renew",
			appID: appID,
			format: "html"
		}), {},
		function(data, textStatus, jqXHR) {

			if (jqXHR.status == 200) {
				// Hide the current entry
				$(".contentApplication").html(data);
			}

		}, 'html').fail(function(jqXHR, textStatus, errorThrown) {
			$elem.siblings(".secretBox").find(".singleButton").fadeIn(300);
		});

	});

	$("#developerContent").on("revertAction", ".renewInput", function(event) {
		// Show the button
		$(this).siblings(".secretBox").find(".singleButton").fadeIn(300);
	});

	/**
	 * Delete app from ecosystem
	 * @return {null}
	 */
	$("#developerContent").on("click", ".wipeOut .singleButton", function(event) {

		// Create a box to verify the action
		$(this).closest(".wipeOut").siblings(".title").trigger("verifyStep", "wipeInput");

		// Hide the current button
		$(this).hide(300);
	});

	$("#developerContent").on("takeAction", ".wipeInput", function(event) {

		var appID = $(".optionMenuApplicationSelected").val();

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "app.remove",
			appID: appID,
			format: "html"
		}), {},
		function(data, textStatus, jqXHR) {

			if (jqXHR.status == 200) {
				// Get some properties
				var $items = $(".optionMenuApplicationCategory");
				var $itemSelected = $items.filter(".optionMenuApplicationSelected");

				// Remove the current item
				$itemSelected.slideUp(200, function() {
					$itemSelected.remove();
				});
				$items.first().trigger("click");
			}

		}, 'html').fail(function(jqXHR, textStatus, errorThrown) {
			$elem.siblings(".wipeOut").find(".singleButton").fadeIn(300);
		});

	});

	$("#developerContent").on("revertAction", ".wipeInput", function(event) {
		// Show the button
		$(this).siblings(".wipeOut").find(".singleButton").fadeIn(300);
	});

// -------------------------------------- DOCUMENTATION -------------------------------------- //

	/**
	 * Change the currently selected documentation tab
	 * @return {null}
	 */
	$("#developerContent").on("click", ".menuDocumentation li", function () {
		
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
	$("#developerContent").on("click", ".documentFunctionName .tryItOut", function () {
		
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
	$("#developerContent").on("keydown", ".demoDocumentation input", function (event) {
		
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
				var value = $(this).find("input").val();
				str += (value != "nulo") ? value : "";
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
	$("#developerContent").on("callback", ".demoDocumentation pre", function (event, post, get) {
		
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
				if (getAttributes["method"] == "person.signIn") {
					// Append to the document
					$demoDocumentation.find(".token").val(data["tokenID"]);

					// Save as a local storage object for one hour
					storageExpiration.save("devTokenID", data["tokenID"], 60);
				}
			},
			error: function(jqXHR, textStatus, errorThrown) {
				if (jqXHR.status == 200) {
					$demoDocumentation.find("pre").html(JSON.stringify(jqXHR.responseText, null, 2));
				} else {
					$demoDocumentation.find("pre").html(jqXHR.status + " " + jqXHR.statusText);
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
				if (attrTemp[0] == "tokenID" && tokenID.length > 0 && attrTemp[1] != "null") {
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
					$div.width((($input.val().length + 3) * 8) + 'px');
				}
			}
		}

		return processedAttributes;
	};

	$("#developerContent").on("keydown", ".demoDocumentation .inert input", function (event) {
		$(this).parent().width((($(this).val().length + 2) * 8) + 'px');
	});

});});