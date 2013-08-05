// VARS

	var lastProportionInfoContainer = 1.0;
	var telephoneInput = "";

// ------------------------------------- GENERAL ------------------------------------- //
	
	$.fn.np = function(method) {

		var methods = {
			/**
			 * Verification for brazilian telephones, including the ones within São Paulo
			 * @return {null}
			 */
			telephoneVerification: function() {

				// We apply the mask and see if the user is in São Paulo, where the phone may have 9 digits
				this.mask("(99) 9999-9999")
				.keyup(function () {
						var beginning = $(this).val().substring(0, 6);
						if ((beginning == "(11) 6" || beginning == "(11) 7" || beginning == "(11) 8" || beginning == "(11) 9") && $(this).parent().find(".infoContainerFieldContentSub").size() == 0) {
							$(this).parent().append("<br><span class='infoContainerFieldContentSub'>O prefixo 9 será adicionado automaticamente.</span>");
						}
				}).blur(function () {
					telephoneInput = $(this).val();
					$(this).parent().find(".infoContainerFieldContentSub").text("");
					
					var beginning = $(this).val().substring(0, 6);
					if (beginning == "(11) 6" || beginning == "(11) 7" || beginning == "(11) 8" || beginning == "(11) 9") {
						$(this).val($(this).val().replace(/\(11\)\ /g,"(11) 9"));
					}
				}).focus(function () {
					if (telephoneInput.length = 15) {
						$(this).val(telephoneInput);
					}
				});

				return this;

			},

			/**
			 * Verification for dates, adopting the standard brazilian format
			 * @return {null}
			 */
			dateVerification: function() {

				// We apply a mask, so the user recognize the date format and we also da a GUI picker
				this.mask("99/99/9999")
				.datepicker( {
					"dateFormat": "dd/mm/yy"
				});

			},

			/**
			 * Create a field inside a infoContainer
			 * @param  {string} elementType Type of element (HTML)
			 * @param  {object} attrOptions Options for the attributes
			 * @param  {object} cssOptions  Options for the css
			 * @return {null}         
			 */
			createField: function (elementType, attrOptions, cssOptions) {

				// We gotta check if the arguments are properly designed
				if (typeof elementType !== "string") {
					elementType = "div";
				}
				
				if (typeof attrOptions !== "object") {
					attrOptions = {};
				}

				if (typeof cssOptions !== "object") {
					cssOptions = {};
				}

				this.each(function () {
					var className = $(this).attr('class');
					var name = $(this).attr("title");
					var placeholder = $(this).attr("placeholder");
					var value = $(this).text();

					var $fieldContent = $(document.createElement(elementType))
							.val(value) // We must set a value
							.attr("name", name) // We must set a name
							.attr("placeholder", placeholder) // We must set a placeholder
							.addClass(className) // We must set the class it came with
							.attr(attrOptions) // We must set attrOptions
							.css(cssOptions); // We must set cssOptions

					$(this).replaceWith($fieldContent);
				});
			},

			/**
			 * Remove a field inside a infoContainer
			 * @param  {object} attrOptions Options for the attributes
			 * @param  {object} cssOptions  Options for the css
			 * @return {null}         
			 */
			removeField: function (attrOptions, cssOptions) {

				// We gotta check if the arguments are properly designed
				if (typeof attrOptions !== "object") {
					attrOptions = {};
				}

				if (typeof cssOptions !== "object") {
					cssOptions = {};
				}

				this.each(function () {
					var className = $(this).attr('class');
					var name = $(this).attr("name");
					var placeholder = $(this).attr("placeholder");
					var value = $(this).val();

					var $fieldContent = $(document.createElement("span"))
							.text(value) // We must set a value
							.attr("title", name) // We must set a name
							.attr("placeholder", placeholder) // We must set a placeholder
							.addClass(className) // We must set the class it came with
							.attr(attrOptions) // We must set attrOptions
							.css(cssOptions); // We must set cssOptions

					$(this).replaceWith($fieldContent);
				});
			},

			consistentForm: function(vector) {

				var consistent = false;
			
				for (var i = 0; i < vector.length; i++) {
					if (vector[i].value != "") {
						consistent = true;
					} else {
						consistent = false;
						break;
					}
				}

				return consistent;
			},

			saveForm: function() {
				$info = this.parents(".infoContainer").toggleClass("editMode");
		
				if ($info.hasClass("editMode")) {
					// We change the icon
					this.toggle(0).attr('src', 'images/32-Check.png').fadeIn(500);

					// So we have to loop through all elements on the form
					// First we go with the input
					$info.find(".infoContainerInputContent[type!='password']").np("createField", "input", {"type": "text"});
					$info.find(".infoContainerInputContent[type='password']").np("createField", "input", {"type": "password"});

					// And finally we load the necessary components
					$info.find(".infoContainerInputContent[name='telephone']").np("telephoneVerification");
					
					$info.find(".infoContainerInputContent[name='birthday'], .infoContainerInputContent[name='historyDate']").np("dateVerification");

					$info.find(".infoContainerSave").show();


					// Special elements (according to layout) - will not always apply
					$info.find(".badgeHistory").hide();
					$info.find(".badgeActive").show();

					
					// Creating the uploader
					var uploader = new qq.FileUploader({
						// pass the dom node (ex. $(selector)[0] for jQuery users)
						element: $info.find('#file-uploader')[0],
						// path to server-side upload script
						action: 'fileuploader.php',
						
						onComplete: function(id, fileName, responseJSON){
							
							$(".qq-upload-list").css("display", "none");
							$info.find(".infoContainerImage img").attr("src", responseJSON.path);
							
						}
					});
					
					
				} else {
					
					var memberID = $info.find("#memberID").val();
					var vector = $info.find("form").serializeArray();
					
					// Since the function does not serialize the image, we have to do this ourselves
					if ($info.find(".infoContainerImage img").size() != 0) {
						vector[vector.length] = {
							"name": "photo",
							"value": $info.find(".infoContainerImage img").attr("src")
						}
					}

					if ($info.np("consistentForm", vector) == true) {

						// And the part of url necessary for the ajax requisition
						var destiny = $info.parents(".pageContent").attr("data-ajax");
		
						// And then we send it to the server, if the conditions have been met
						$.post(destiny + '.php',
						{	// We are gonna roll it down according to the badge content flow (so if the flow changes, the code has to change)
							saveForm: "saveForm",
							memberID: memberID,
							data: vector
						},
						function(data) {
							// And just need to make sure that the content was properly saved

							if (data != "true") {
								$(".errorBox").fadeToggle(200);
							}
						}, 'html' );

						// Since we saved it, we can now remove
						$info.removeClass("newInfoContainer");
						
						// We change the icon
						this.toggle(0).attr('src', 'images/64-Pencil.png').fadeIn(500);
						
						// So we have to loop through all elements on the form and reset them to their default state
						$info.find(".infoContainerInputContent").np("removeField");
						$info.find(".infoContainerSave").hide();

						// Delete the uploader
						$info.find("#file-uploader").html('<noscript>Javascript please!</noscript>');
						// Reset the error message
						$info.find(".saveButtonError").text("");

						// Special elements (according to layout) - will not always apply
						$info.find(".badgeHistory").show();
						$info.find(".badgeActive").hide();
						
					} else {
						$info.toggleClass("editMode").find(".saveButtonError").text("Insira todos os dados.");
					}
				}
			}
		};

		// Method calling logic
	    if ( methods[method] ) {
	      return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
	    } else if ( typeof method === 'object' || ! method ) {
	      return methods.init.apply( this, arguments );
	    } else {
	      $.error( 'Method ' +  method + ' does not exist on jQuery.tooltip' );
	    } 

	};

	$.fn.ajax = function(method) {

		// Control variables
		var contentTag = "#content", fileType = ".php";
		var loadingHtml = '<img src="images/128-loading.gif" class="loadingBike" alt="Carregando..." />';
		var $mainContent = $(contentTag), $loadingContent = $(loadingHtml);

		var methods = {

			/**
			 * Set the hash based on the given attributes
			 * @return {null	}
			 */
			hashConfigureSource: function(href) {

				// Force the hash to load
				if (href && window.location.hash == href) {
					$(this).ajax("hashStartLoad");
				// Or load a new one
				} else if (href) {
					window.location.hash = href.replace(fileType, "");
				// Or use the current document to set the path
				} else if (window.location.hash == "") {
					var index = window.location.pathname.lastIndexOf('/'); 
					var hash = window.location.pathname.substring(index+1).replace(fileType, "");

					if (hash == "") {
					    hash = "index";
					}

					$(this).ajax("hashDidLoad", hash);
				}
			},
	
			/**
			 * Load the new document on the screen
			 * @return {null	}
			 */
			hashStartLoad: function() {

			    var hash = window.location.hash.substring(1);
			    
			    if (hash) {
			        $mainContent.fadeOut(300, function() {
			        	$mainContent.after($loadingContent);
			            $mainContent.empty().load(hash + fileType + " " + contentTag, function() {
			                $loadingContent.remove();
			                $mainContent.children().unwrap().fadeIn(300).ajax("hashDidLoad", hash);
			            });
			        });
			    }
			},

			/**
			 * Hash has already been loaded and we cannot set up the additional components
			 * @return {null}
			 */
			hashDidLoad: function(newHash) {
				// Custom code that may need to be executed onload
		
				// We must reset the variable
				lastProportionInfoContainer = 1.0;
				
				// And we create the slider
				$(".sliderBoard").slider({
					value:1.0,
					min: 0.4,
					max: 1.6,
					step: 0.15,
				});
				
				$(".sliderBoard").bind("slidestop", function (event, ui) {

					$infoContainer = $(".infoContainer");
					var value = ($(this).slider("value"));
					var width = $infoContainer.width() * value / lastProportionInfoContainer;
					var height = $infoContainer.height() * value / lastProportionInfoContainer;
					
					$infoContainer.width(width);
					$infoContainer.height(height);
					$infoContainer.css("font-size", value * 100 + "%");
				
					lastProportionInfoContainer = value;
				});

				if (newHash == "presenca") {
					// We request the information on the server
					$.post('ajaxPresence.php',
					{	
						computerState: "computerState", 
						tokenID: localStorage.getItem("tokenID") || "no",
					}, // And we print it on the screen
					function(data) {
						if (data == "true") {
							$("#presencaContent #favoriteButton").trigger("click", [true]);
						}
					}, 'html' );
				}
			}
		};


		// Method calling logic
	    if ( methods[method] ) {
	      return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
	    } else if ( typeof method === 'object' || ! method ) {
	      return methods.init.apply( this, arguments );
	    } else {
	      $.error( 'Method ' +  method + ' does not exist on jQuery.tooltip' );
	    }

	};


$(document).ready(function() {

	

// ------------------------------------- DANGEROUS ------------------------------------- //
	
	/**
	 * Remove date picker reference
	 */
	$(".ui-datepicker a").live("click", function() {
		$(this).removeAttr("href"); 
	});

	// Checking for very dangerous stuff (also called Microsoft IE)
	var pattern = /Microsoft/gi;
	if (pattern.test(navigator.appName)) {
		alert("Esse site felizmente não suporta o Internet Explorer.");
		window.location = "https://www.google.com/chrome";
	}

	/**
	 * Make sure that the hash is set
	 */
	$(window).ajax("hashConfigureSource", window.location.hash);
	

// ------------------------------------- AJAX ------------------------------------- //

	/**
	 * Always load content dinamically with few expections
	 */
	$(window).delegate("a", "click", function() {

		if ($(this).attr("target") == "_blank") {
			return true;
		}
		
		if ($(this).attr("href") != undefined) {

			if ($(this).attr("href").substr(0, 7) == "http://") {
				return true;
			}
			
			if ($(this).attr("href").substr(0, 8) == "https://") {
				return true;
			}
			
			if ($(this).attr("href").substr(0, 7) == "mailto:") {
				return true;
			}
			
			if ($(this).attr("href") == "logout.php") {
				return true;
			}
		}

		$(this).ajax("hashConfigureSource", $(this).attr("href"));
		
	    return false;
	});
	
	/**
	 * Load the new hash
	 */
	$(window).bind('hashchange', function(event, href) {
		$(this).ajax("hashStartLoad");
	});
	
	
	
// ------------------------------------- BAR ------------------------------------- //


	$(".bar .rightBar .userSettingsInfo").live("click", function () {
		$(".bar .userSettingsMenu").slideToggle(100);
	});


// ------------------------------------- NOTIFICATION ---------------------------------- //

	(function checking() {
		if ($(".loginBar").length == 0) checkNotifications();
		
		setTimeout(checking, 5000); // 5s
	})();
	
	// Load the user notification info after 2s
	window.setTimeout(userNotifications, 1250);
	
	function checkNotifications() {
		
		$.post('ajax.php',
		{	// We are gonna roll it down according to the badge content flow (so if the flow changes, the code has to change)
			checkNotifications: "checkNotifications"
		},
		function(data) {
			processNotification(data);
		}, 'html' );
		
	}
	
	function processNotification(jsonData) {
	
		// First we parse the JSON object that we received
		try {
			var jsonReturn = JSON.parse(jsonData);
		} catch (Exception) {
			console.log("Couldn't parse JSON");
			return 0;
		}
		
		// Then we loop to see if we have any data
		for (var i = 0; i < jsonReturn.data.length; i++) {
			data = jsonReturn.data[i];
			// See if the notification has already been delivered
			if ($(".notifications li[value = \"" + data.id + "\"]").size() != 0) {
				return;
			}
		
			// So we create an element with the content (THE CLONE PART IS SUPER IMPORTANT DUE TO JAVASCRIPT SUCKY CLOSURE CONCEPTION	)
			var $item = $("<li></li>").clone();
			$item.val(data.id).addClass("unseenNotification").append($("<a></a>").attr("href", data.url).html(data.action));
			
			// Open the box and then prepend the content to it
			$(".notificationBox").show().children("ul").prepend($item);
			
			// Show the info, wait for a while and then fade it out
			(function($item) {
				return (function() {
					$item.fadeIn(200).delay(8000).fadeOut(3000, function() {
						moveNotificationFromBoxToCenter($item);
					});
				})();
			})($item);
		}
		
	}
	
	/**
	 * Notify the server that a notification has been seen
	 * @param  {object} ref       	List element that holds the notification
	 * @param  {bool} 	decrement 	Inform if the notification center counter should be decremented
	 * @param  {bool} 	clean 		Inform if the past notifications should be set as seen too
	 * @return {null	}
	 */
	function updateNotificationStatus(ref, decrement, clean) {

		$.post('ajax.php',
		{	// We are gonna roll it down according to the badge content flow (so if the flow changes, the code has to change)
			updateNotificationStatus: "updateNotificationStatus",
			value: ref.val(),
			clean: clean
		},
		function(data) {
			// We remove the class and update the unseen notification counter
			ref.removeClass("unseenNotification");
			if (decrement) {
				$(".notificationsInfoCount").text(parseInt($(".notificationsInfoCount").text())-1);
			}
		
		});
	
	}
	
	function userNotifications() {
		// And then we check if all notifications have been delivered
		$.post('ajax.php',
		{
			userNotifications: "userNotifications"
		},
		function(data) {
			processUserNotifications(data, true);	
		}, 'html' );
	}
	
	function processUserNotifications(jsonData, fresh) {
		// First we parse the JSON object that we received
		try {
			var jsonReturn = JSON.parse(jsonData);
		} catch (Exception) {
			console.log("Couldn't parse JSON");
			return 0;
		}

		var integrity = true;
		var $notifications = $(".notificationsContent ul");
		var actualCount = 0;
		
		// If this is a new insertion, we must be oblivious to what has been defined before
		if (!fresh) {
			actualCount = parseInt($(".notificationsInfoCount").text());
		}
		
		// Then we update the notifications count
		$(".notificationsInfoCount").text(actualCount + jsonReturn.count);
		
		// Then we loop to see if the data on the browser is consistent
		for (var i = 0; i < jsonReturn.data.length; i++) {
						
			if ($(".notificationsContent li[value = \"" + jsonReturn.data[i].id + "\"]").size() == 0) {
					// If not, we break it
					integrity = false;
					break;
			}
		}
		
		// And append the whole post message to the menu
		if (!integrity) {
			
			if (fresh) {
				// But we gotta clean the notifications before filling it (if the parameters say that)
				$notifications.html("");
			}
		
			for (var i = 0; i < jsonReturn.data.length; i++) {
				var $item = $("<li></li>").val(jsonReturn.data[i].id).append($("<a></a>").attr("href", jsonReturn.data[i].url).html(jsonReturn.data[i].action));
				// We add a class so we know which notifications have not been seen yet
				if (jsonReturn.data[i].status == 0) {
					$item.addClass("unseenNotification");
				}
				$notifications.append($item);
			}
		}

		$(".notifications").mCustomScrollbar("update");

	}
	
	function moveNotificationFromBoxToCenter($item) {
		// Case the user didn't see the notification, we gotta add it to the stack
				
		// And then write it on the notification center if it is not still there
		if ($(".notificationsContent li[value = \"" + $item.val() + "\"]").size() == 0) {
			$(".notificationsContent ul").prepend($item.show());
			// And update the notifications count
			$(".notificationsInfoCount").text(parseInt($(".notificationsInfoCount").text())+1);
		}

		// So first we remove it from the bottom
		$item.remove();
		
		// And we see if there is any notification left, otherwise, we just fade the box
		if ($(".notificationBox li").size() == 0) {
			$(".notificationBox").hide();
		}
	}
	
	$(".notificationsInfo").live("click", function () {
		
		var $notifications = $(".notifications");
		
		// We fetch new data only if the notification center was hidden
		if (!($notifications.is(":visible"))) {
		
			// We check it the slider has already been set up
			if (!($notifications.hasClass("mCustomScrollbar"))) {
				$notifications.mCustomScrollbar({
					scrollInertia: 0,
					callbacks: {
						onTotalScroll: function() {
							$(".notificationsBottom .notificationLoadExtra").trigger("click");
						}
					}
				});
			}
			
			$notifications.slideToggle(100, function () {
				$(this).mCustomScrollbar("update");
			});
			
			// And we ask for the notifications
			userNotifications();
		} else {
			$notifications.slideToggle(100);
		}
	});

	/**
	 * The user has clicked on a notification inside the notification box
	 */
	$(".notificationBox li").live({
		mouseenter: function () {
			// Stop the animation and restore the full opace state
			$(this).stop(true, true).show();

			updateNotificationStatus($(this), false, false);
		},
		mouseleave: function () {

			// Or we can continue to fade the information out
			$(this).delay(2000).fadeOut(3000, function () {
				moveNotificationFromBoxToCenter($(this));
			});
	
		}
	});
	
	/**
	 * Tell the server that the user has seen the notification
	 * @return {null}
	 */
	$(".notifications .unseenNotification").live("click", function () {
		updateNotificationStatus($(this), true, true);
	});
	
	/**
	 * Hide the notification center
	 * @return {null}
	 */
	$(".notificationsContent li").live("click", function () {
		$(this).parents(".notifications").slideToggle(100);
	});
	
	/**
	 * Load new notifications on the notification center
	 * @return {null}
	 */
	$(".notificationsBottom .notificationLoadExtra").live("click", function () {
		var $ref = $(this);
		var $sibling = $(this).parents(".notificationsBottom").siblings(".notificationsContent");
		var notificationsLoaded = $sibling.find("li").size();
		
		$.post('ajax.php',
		{
			notificationLoadExtra: "notificationLoadExtra",
			value: notificationsLoaded
		},
		function(data) {
			processUserNotifications(data, false);
			
			// If the bucket came empty, we inform the user about it
			if (!data.data) {
				$ref.text("Todas as notificações foram carregadas.");
				$(".notifications").mCustomScrollbar("update");
			}
		});
	});
	

// ----------------------------------- USER SETTINGS ---------------------------------- //

	var powerUsersDelete = "<img src='images/32-Cross.png' alt='Delete' class='powerUsersDelete' />";

	/**
	 * Get a list with the power users
	 */
	$(".powerUsersItem").live({
		mouseenter: function () {			
			var $ref = $(this);

			$.post('ajax.php',
			{	
				powerUsers: "powerUsers"
			}, // And we print it on the screen
			function(data) {
				$data = $(data);
				if ($ref.find(".collectionBox").size() == 1) {
					$data.filter("li").append(powerUsersDelete);
				}
				$(".powerUsersActiveUsers").html($data);
			}, 'html' );
			
		}
	});
	
	/**
	 * First item
	 */
	$(".firstItem").live({
		mouseenter: function () {			
			$(this).find(".firstAnchor").stop(false, true).fadeIn(100);
		},
		mouseleave: function () {
			$(this).find(".firstAnchor").delay(100).fadeOut(100);
		},
	});
	
	/**
	 * First anchor
	 */
	$(".firstAnchor").live({
		mouseenter: function () {
			$(this).stop(true, true);
		},
		mouseleave: function () {
			$(this).delay(100).fadeOut(100);
		},
	});
	
	/**
	 * Second item
	 */
	$(".secondItem").live({
		mouseenter: function () {
			$(this).find(".secondAnchor").stop(false, true).fadeIn(100);
		},
		mouseleave: function () {
			$(this).find(".secondAnchor").delay(100).fadeOut(100);
		},
	});
	
	/**
	 * Second anchor
	 */
	$(".secondAnchor").live({
		mouseenter: function () {
			$(this).stop(true, true);
			$(this).parents(".secondItem").stop(false, true).fadeIn(100);
		},
		mouseleave: function () {
			$(this).delay(100).fadeOut(100);
		},
	});
	
	/**
	 * New power user has been added
	 * @return {null}
	 */
	$(".powerUsersList.collectionBox .collectionOptions li").live("click", function () {
	
		$.post('ajax.php',
		{	
			addPowerUser: "addPowerUser",
			memberID: $(this).val()
		}, // And we print it on the screen
		function(data) {
			// And just need to make sure that the content was properly saved
			if (data != "true") {
				$(".errorBox").fadeToggle(200);
			}
		}, 'html' );
	});

	/**
	 * Delete the clicked item
	 * @return {null	}
	 */
	$(".powerUsersList.collectionBox li img").live("click", function () {
		
		$.post('ajax.php',
		{	
			removePowerUser: "removePowerUser",
			memberID: $(this).parent().val()
		}, // And we print it on the screen
		function(data) {
			// And just need to make sure that the content was properly saved
			if (data != "true") {
				$(".errorBox").fadeToggle(200);
			}
		}, 'html' );
	});
	
	/**
	 * Trigger of password change
	 * @return {null}
	 */
	$(".userSettingsItem form").live("submit", function () {
		// We just trigger the form submition
		$(".userSettingsItem .saveButton").trigger("click");
		
		return false;
	});
	
	/**
	 * Changing the password
	 * @return {null}
	 */
	$(".userSettingsItem .saveButton").live("click", function () {
	
		var $parent = $(this).parents("form");
		var oldPassword = $parent.find(".oldPassword").val();
		var newPassword = $parent.find(".newPassword").val();

		// Check if the user has typed the old and new passwords
		if (oldPassword != "" && oldPassword != null && newPassword != "" && newPassword != null) {
	
			$.post('ajax.php',
			{	
				changePassword: "changePassword",
				oldPassword: oldPassword,
				newPassword: newPassword
			}, // And we print it on the screen
			function(data) {
				// And just need to make sure that the content was properly saved
				if (data != "true") {
					$(".errorBox").fadeToggle(200);
				}
				
				// So the user can type the new password
				window.location.reload();

			}, 'html' );
		}
		
	});

// -------------------------------------- SELECT -------------------------------------- //

	var selectBoxOpen = false;

	/**
	 * If the member clickd on the document and the select box is not yet closed, we do so
	 * @return {[type]} [description]
	 */
	$(document).on("click", function () {
		if (selectBoxOpen == true) {
			$(".selectBox .selectSelected").trigger("click"); // Close all open selected boxes
		}
	});

	/**
	 * Select box has been clicked
	 * @return {null}
	 */
	$(".selectBox .selectSelected").live("click", function () {
		var $selected = $(this);
		
		if ($(this).siblings(".selectOptions").is(":visible")) {
			$(this).removeClass("selectSelectedOpen").siblings(".selectOptions").slideUp(0);
			selectBoxOpen == false;
		} else {
			$(document).find(".selectBox .selectOptions").slideUp(0); // Close all open selected boxes
			$(this).addClass("selectSelectedOpen").siblings(".selectOptions").slideDown(0, function () {
				$selected.siblings(".selectOptions").mCustomScrollbar("update");
			}); // Open the clicked select box
			selectBoxOpen == true;
		}
	});
	
	/**
	 * One of the select box options has been clicked
	 * @return {null}
	 */
	$(".selectBox .selectOptions li").live("click", function () {
		$(this).parents(".selectOptions")
			.slideToggle(0)
			.parents(".selectBox")
			.find(".selectSelected")
			.removeClass("selectSelectedOpen")
			.find("li")
			.removeClass("placeholder")
			.replaceWith($(this).clone()[0]); // we close the select box and then load the selected option on the correspoding div
	});

// ------------------------------------- COLLECTION ------------------------------------- //
	
	// Function for appending an element from the select box to the box
	function appendElement(ref) {
		var $parent = ref.parents(".collectionBox");
		// We need to hide the select box
		$parent.find(".collectionOptions").slideUp(0);
		// Then make a clone of the item and append it
		$parent.find(".collectionSelectedList").append(ref.clone().append("<img src='images/32-Cross.png' alt='Delete' class='collectionOptionsDelete' />"));
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
				searchQuery: "searchQuery", 
				searchType: searchType,
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
	$(".boardContent .menuBoardInput#add").live("click", function() {
		
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
		$info.removeClass("infoContainerSelected")
			.css({
				"width": width,
				"height": height,
				"top": 0,
				"left": 0,
				"right": "",
				"font-size": fontSize,
				"margin-left":"",
				"margin-right": ""
			}).css("display", "").find(".infoContainerExtra").slideToggle(0);

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

// ------------------------------------- INDEX ------------------------------------- //
// -------------------------------------- ----- -------------------------------------- //
// -------------------------------------- ----- -------------------------------------- //

$(document).ready(function() {
	
// -------------------------------------- TABLE -------------------------------------- //

	// DISPLAY BADGE
	$("#indexContent .indexContentTypeOption").live("click", function() {
		
		// We gotta know where the content are
		var ref = $(this).find(".indexContentTypeOptionContent");
		// And make a deep copy of it
		var clone = $(this).find(".indexContentTypeOptionContentWrapper").clone();

		// We send the information to the server
//		$.post('ajaxIndex.php',
//		{	
//			badgeExtra: "badgeExtra", 
//			memberID: memberID
//		}, // And we print it on the screen
//		function(data) {
//			ref.find(".badgeExtra").html(data);
//		}, 'html' );

		
		// Then we get its position
		var offsetRef = ref.position();
		
		// We need to append the clone to the body so we can calculate the difference between the absolute position and its relative position
		// So first we must set the same css properties for height and width and set the visibility to hidden (so the user will not see it)
		clone.css({
			"width": ref.width(),
			"height": ref.height(),
			"visibility": "hidden"
		});
		
		// Then we can add it to the system
		clone.appendTo(".boardContent");
		
		// And we set a minimum height for the wrapping box
		$(".boardContent").css("min-height", (offsetRef.top + ref.height() + 20) + "px");
		
		// We calculate where the clone is supposed to be, plus its original parent width for later calculations
		var offsetClone = clone.find(".indexContentTypeOptionContent").position();
		var width = ref.parents(".indexContentType").width();
		
		// And then we make it absolute
		clone.addClass("indexContentTypeOptionContentSelected");
		
		// And we define the css that will place it right above the original copy
		clone.css({
			"width": ref.width(),
			"height": ref.height(),
			"left": offsetRef.left,
			"top": offsetRef.top,
			"visibility": "visible"
		});
	
		// We fade the box out
		ref.parents(".indexContentType").fadeOut(600, function () {
			// And we recalculate the positions of the new box (with relative positioning now)
			clone.css({
				"left": offsetRef.left - offsetClone.left,
				"top":offsetRef.top - (offsetClone.top - width),
				"position": "relative"
			});
	
			// And to finish we just expand the option
			clone.css("height", '').addClass("indexContentTypeOptionContentAnimated", 800);
		});


	});

});

// ------------------------------------- CLIENTS ------------------------------------- //
// -------------------------------------- ----- -------------------------------------- //
// -------------------------------------- ----- -------------------------------------- //


// ------------------------------------- CONSULTANTS ------------------------------------- //
// -------------------------------------- ----- -------------------------------------- //
// -------------------------------------- ----- -------------------------------------- //


// ------------------------------------- FLOWCHART ------------------------------------ //
// -------------------------------------- ----- -------------------------------------- //
// -------------------------------------- ----- -------------------------------------- //

	
	/**
	 * Button to add a new project
	 */
	$("#projectContent .menuBoardInput#addFlowchart").live("click", function () {
		
		$.post('ajaxFlowcharts.php', {addProjectButton: "addFlowchartButton"}, 
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
	 * Confirm which table is being copied
	 * @return {null}
	 */
	$("#flowchartContent #copyTableButton").live("click", function () {
	
		var ref = $(this).parent();
		var weeks = $("#numberWeeks").val();
		
		// Disable it for no futher simultaneous requisitions 
		ref.attr('disabled','disabled');
		
		$.post('ajaxPresence.php', {
			copyTable: weekFromNow, 
			fromShift: weeks
		}, 
		function(data) {
			ref.toggle().html(data).fadeIn(800, function () {
				$(".optionContent").slideToggle(500);
				
				$("table").fadeOut(500);
				
				$.post('ajaxPresence.php', {shiftWeek: weekFromNow}, 
					function(data) {
						ref.removeAttr('disabled');
						$("table").replaceWith(data).fadeIn(500);
						removeCellPadding();
					}, 'html' );
			});
		}, 'html' );
			
	});



// ------------------------------------- GROUPS ------------------------------------- //
// -------------------------------------- ----- -------------------------------------- //
// -------------------------------------- ----- -------------------------------------- //

$(document).ready(function() {

// 	VARS	//
	var draggingGroup = false;
	
// -------------------------------------- GROUP --------------------------------------- //
	
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


// -------------------------------------- INDEX ------------------------------------- //
// -------------------------------------- ----- -------------------------------------- //
// -------------------------------------- ----- -------------------------------------- //

	/**
	 * Login button has been clicked
	 */	
	$(".userLoginLeading").live("click", function () {
		$(".userLoginBox").slideToggle(500);
	
		if ($(".userRegisterBox").is(":visible")) {
			$(".userRegisterBox").slideToggle(500);
		}

		// Create the scroller
		$(".userLoginBox .selectOptions").mCustomScrollbar({
			scrollInertia: 0
		});
	});
	
	/**
	 * Register button has been clicked
	 */
	$(".userRegisterLeading").live("click", function () {
		$(".userRegisterBox").slideToggle(500);
		
		if ($(".userLoginBox").is(":visible")) {
			$(".userLoginBox").slideToggle(500);
		}
		
		// Creating the uploader
		var uploader = new qq.FileUploader({
			// pass the dom node (ex. $(selector)[0] for jQuery users)
			element: document.getElementById('file-uploader'),
			// path to server-side upload script
			action: 'fileuploader.php',
			
			onComplete: function(id, fileName, responseJSON){
				
				$(".qq-upload-list").css("display", "none");
				$(".userRegisterBox .promoImage").css("background-image", "url('uploads/"+responseJSON.fileName+"')");
				$(".userRegisterBox #file-uploader").css("visibility", "hidden");
			}
		});
	
	});
	
	/**
	 * Reduce the image size and insert the select box to choose another enterprise
	 */
	$(".userLoginBox .promoImage").live("click", function () {
		$(this).toggleClass("promoImageReduced", 500).siblings(".selectBox").slideToggle(400);
	});

	/**
	 * Change the enterprise id on the hidden input of the form
	 */
	$(".userLoginBox .selectOptions li").live("click", function () {
		$(".userMemberBox #enterprise").val($(this).val());
	});


// ------------------------------------- MEMBERS ------------------------------------- //
// -------------------------------------- ----- -------------------------------------- //
// -------------------------------------- ----- -------------------------------------- //


$(document).ready(function() {

	
// -------------------------------------- BADGE --------------------------------------- //
	
	
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
		function(data) {
			if (data != "true") {
				$(".errorBox").fadeToggle(200);
			}
			
		}, 'html' );
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
				if (data != "true") {
					$(".errorBox").fadeToggle(200);
				}
				
				// We request the information on the server
				$.post('ajaxMembers.php',
				{	
					infoContainerExtra: "infoContainerExtra", 
					memberID: memberID
				}, // And we print it on the screen
				function(data) {
					$info.find(".infoContainerExtra").html(data);
				}, 'html' );

				
			}, 'html' );
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
			if (data != "true") {
				$(".errorBox").fadeToggle(200);
			}

			$info.find(".badgeSubmitChangePassword").remove();
		}, 'html' );
	
	});

});

// ------------------------------------- PRESENCA ------------------------------------- //
// -------------------------------------- ----- -------------------------------------- //
// -------------------------------------- ----- -------------------------------------- //

$(document).ready(function() {

// 	VARS	//
	var editingPresenca = false;
	var editingCell = false;
	var star = $(".star");
	var weekFromNow = 0;
	
// -------------------------------------- STYLE -------------------------------------- //

	function removeCellPadding() {
		$("td").has(".multipleUsers").each(function () {
			$(this).css("padding", "0");
		});
	}

// -------------------------------------- MENU -------------------------------------- //
	
	/**
	 * Change edit mode
	 * @return {null}
	 */
	$("#presencaContent #editButton").live("click", function () {
		editingPresenca = !editingPresenca;
		
		if (editingPresenca) {
			$(this).toggle(0).attr('src', 'images/32-Check.png').fadeIn(500);
			star = $(".star");
			star.removeClass('star');
		} else {
			$(this).toggle(0).attr('src', 'images/64-Pencil.png').fadeIn(500);
			star.addClass('star');
		}
	});

	/**
	 * Request a table that will be copied
	 * @return {null} 
	 */
	$("#presencaContent #copyButton").live("click", function () {
		
		$.post('ajaxPresence.php', {
			copyButton: "copyButton"
		}, 
		function(data) {
			$(".optionContent").html(data).slideToggle(500);
		}, 'html' );
	});
	
	/**
	 * Confirm which table is being copied
	 * @return {null}
	 */
	$("#presencaContent #copyTableButton").live("click", function () {
	
		var ref = $(this).parent();
		var weeks = $("#numberWeeks").val();
		
		// Disable it for no futher simultaneous requisitions 
		ref.attr('disabled','disabled');
		
		$.post('ajaxPresence.php', {
			copyTable: weekFromNow, 
			fromShift: weeks
		}, 
		function(data) {
			ref.toggle().html(data).fadeIn(800, function () {
				$(".optionContent").slideToggle(500);
				
				$("table").fadeOut(500);
				
				$.post('ajaxPresence.php', {
					shiftWeek: weekFromNow
				}, 
				function(data) {
					ref.removeAttr('disabled');
					$("table").replaceWith(data).fadeIn(500);
					removeCellPadding();
				}, 'html' );
			});
		}, 'html' );
			
	});
	
	/**
	 * Request the explanations to be reviewed
	 * @return {null}
	 */
	$("#presencaContent #reviewButton").live("click", function () {
		
		$.post('ajaxPresence.php', {
			reviewButton: "reviewButton"
		}, 
		function(data) {
			$(".optionContent").html(data).slideToggle(500);
		}, 'html' );
	});
	
	/**
	 * Confirm which explanations have been reviewed
	 * @return {null}
	 */
	$("#presencaContent #handContraButton, #presencaContent #handProButton").live("click", function () {

		var ref = $(this).parents("#reviewBox");
		var refHandBox = $(this).parents("#handBox");
		var dateID = ref.find("#dateID").val();
		var decision = ($(this).attr("id") == "handContraButton") ?  -1 : 1;
		
		$.post('ajaxPresence.php', {
			confirmReview: dateID,
			decision: decision
		}, 
		function(data) {
			refHandBox.html(data).fadeIn(800);
		}, 'html' );
			
	});
	
	
	/**
	 * Change which week is on focus
	 * @return {null}
	 */
	$("#presencaContent #leftArrow, #presencaContent #rightArrow").live("click", function () {
	
		var ref = $(this).parent();
		
		// Disable it for no futher simultaneous requisitions 
		ref.attr('disabled','disabled');
		
		// See which element was clicked
		($(this).attr("id") == "leftArrow") ?  weekFromNow-- : weekFromNow++;
		
		$("table").fadeOut(500);

		$.post('ajaxPresence.php', {
			shiftWeek: weekFromNow
		}, 
		function(data) {
			ref.removeAttr('disabled');
			$("table").replaceWith(data).fadeIn(500);
			removeCellPadding();
		}, 'html' );
			
	});

	/**
	 * Tool to favorite a carte
	 * @return {null}       
	 */
	$("#presencaContent #favoriteButton").live("click", function (event, propagate) {	
		
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
			$.post('ajaxPresence.php', {
				toggleToken: "toggleToken",
				tokenID: localStorage.getItem("tokenID") || "no",
			}, 
			function(data) {
				// Save the item
				localStorage.setItem("tokenID", data);
			}, 'html' );
		}

	});
	
// -------------------------------------- TABLE -------------------------------------- //
	
	/**
	 * Begin and end shift
	 * @return {[type]} [description]
	 */
	$("#presencaContent .star").live("click", function () {
	
		// We have to check if this cell still can be selected (can be on edit mode)
		if ($(this).hasClass('star')) { 
			var ref = $(this);
			var html = $(this).html();
			var dateID = ref.find("#dateID").val();
			
			if ($(this).siblings("#multipleUserCell").val() == 'YES') {
				// MIGHT NEW A REVISION!
				ref = $(this).parents("td"); // We need to get out of our nested table!
				ref.css("padding", "20px 0");
			}
			
			ref.html("<img src='images/64-loading.gif'>");
			ref.removeClass().addClass("white");
			
			$.post('ajaxPresence.php', {
				confirm: "confirm",
				tokenID: localStorage.getItem("tokenID"),
			}, 
			function(data) {
					
				ref.html(data);
				
				// Animate and only loads the box again when the animation is complete
				ref.find("img").toggle().fadeIn(500, function () {
					$.post('ajaxPresence.php', {cellText: "cellText", date:dateID}, 
						function(data) {
							var content = $(data); // Hold a reference for the newly created element
							ref.toggle(0).replaceWith(content).fadeIn(500);
							content.has(".multipleUsers").css("padding", "0");
						}, 'html' );
				});
				
			}, 'html' );
		}
		
	});
	
	
	/**
	 * Request a user shift to change
	 * @return {null}
	 */
	$("#presencaContent td").live("click", function () {
		if (editingPresenca == true && editingCell == false) {
		
			editingCell = true;
	
			var ref = $(this);
			var dateID = $(this).find("#dateID").val();

			if ($(this).siblings("#multipleUserCell").val() == 'YES') {
				// MIGHT NEW A REVISION!
				ref = $(this).parents("td"); // We need to get out of our nested table!
				ref.css("padding", "20px 0");
			}

			ref.html("<img src='images/64-loading.gif'>");
			ref.removeClass().addClass("white");
			
			$.post('ajaxPresence.php', {usersList: "usersList", date: dateID}, 
				function(data) {
					ref.html(data);
				}, 'html' );
		}
		
	});


	/**
	 * Confirm which shift has been changed
	 * @return {null	}
	 */
	$("#confirmButton").live("click", function () {
		
		var ref = $(this).parents("td");
		var dateID = $(this).parents("td").find("#dateID").val();
		var choosenUser = $("#confirmSelect").val();

		$.post('ajaxPresence.php', {
			changeUser: choosenUser,
			date: dateID
		}, 
		function(data) {
			var content = $(data); // Hold a reference for the newly created element
			ref.toggle(0).replaceWith(content).fadeIn(500);
			content.has(".multipleUsers").css("padding", "0");

			if (editingPresenca == true) {
				star = $(".star");
				content.removeClass('star').find(".star").removeClass('star'); // $(this) referencing the new element
			}
			
			editingCell = false;
			
		}, 'html' );
			
	});
		
	/**
	 * Add and remove users from a certain shift
	 * @return {null}
	 */
	$("#presencaContent #addUserToCell, #presencaContent #removeUserFromCell").live("click", function () {
	
		// We must get the type before changing ref
		var type = ($(this).attr("id") == "removeUserFromCell") ?  0 : 1;
	
		var ref = $(this).parents("td");
		var dateID = $(this).parents("td").find("#dateID").val();
		
		$.post('ajaxPresence.php', {addRemoveUserToCell: type, date: dateID}, 
			function(data) {
				var content = $(data); // Hold a reference for the newly created element
				ref.toggle(0).replaceWith(content).fadeIn(500);
				content.has(".multipleUsers").css("padding", "0");
				
				if (editingPresenca == true) {
					star = $(".star");
					content.removeClass('star').find(".star").removeClass('star'); // $(this) referencing the new element
				}
				
				editingCell = false;
				
			}, 'html' );
	});
	

	/**
	 * Request the addition of a new justification
	 * @return {null}
	 */
	$("#presencaContent #paperAirplane").live("click", function () {
		
		var dateID = $(this).parents("td").find("#dateID").val();
		
		$.post('ajaxPresence.php', {paperAirplane: dateID}, 
			function(data) {
				$(".optionContent").html(data).slideDown(500);
				$('html, body').animate({ scrollTop: 0 }, 'slow');
			}, 'html' );
	});
	
	/**
	 * Confirm the insertion of a justification
	 * @return {null}
	 */
	$("#presencaContent #addExplanationButton").live("click", function () {
	
		var ref = $(this).parent();
		var dateID = $(this).parent().find("#dateID").val();
		var justificationID = $("#justificationID").val();
		var justificationText = $("#justificationText").val();
		
		$.post('ajaxPresence.php', {
			addExplanationButton: dateID,
			justificationID: justificationID,
			justificationText: justificationText
		}, 
		function(data) {
			ref.toggle().html(data).fadeIn(800, function () {
				$(".optionContent").slideToggle(500);
			});
		}, 'html' );
			
	});
	
	/**
	 * If the notification is already know, we can make a small tweak
	 * @return {null}
	 */
	$("#presencaContent #justificationID").live("change", function () {
		
		if ($(this).val() == "0") {
			$(this).siblings("#justificationTextBox").slideDown(500);
		} else {
			$(this).siblings("#justificationTextBox").slideUp(500);
		}
			
	});
	
});

// ------------------------------------- PROJECTS ------------------------------------- //
// -------------------------------------- ----- -------------------------------------- //
// -------------------------------------- ----- -------------------------------------- //

$(document).ready(function() {

// 	VARS	//
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