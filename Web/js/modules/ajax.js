// ------------------------------------- AJAX ------------------------------------- //

define(["jquery", "common"], function($) {$(function() {

	// Control variables
	var contentTag = "#content", fileType = ".php";
	var loadingHtml = '<img src="images/128-loading.gif" class="loadingBike" alt="Carregando..." />';
	var $mainContent = $(contentTag), $loadingContent = $(loadingHtml);

	// Current hash
	var oldHash = window.location.hash;

	$.fn.ajax = function(method) {

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
				} else {

					var appIndex = window.location.origin.length;
					var eventIndex = window.location.href.lastIndexOf('/');

					// See if we are on the same position
					if (appIndex == eventIndex) {

						var hash = window.location.pathname.substring(eventIndex + 1).replace(fileType, "");

						if (hash != "") {
							window.location.hash = hash;
						} else {
							window.location.hash = "home";
						}
					} else {
						window.location.hash = "front";
					}
				}

				// Remove the old hash
				if (oldHash != window.location.hash) {
					// Undefine the module
					require.undef("modules/" + oldHash.replace("#", ""));

					// Inform the old hash
					oldHash = window.location.hash;
				}
			},

			/**
			 * Load the new document on the screen
			 * @return {null	}
			 */
			hashStartLoad: function() {

			    var hash = window.location.hash.substring(1);
			    
			    if (hash) {
			    	var top = $mainContent.css("top");
			        $mainContent.fadeOut(300, function() {
			            $mainContent.empty().load(hash + fileType + " " + contentTag, function() {
			                $mainContent = $mainContent.children().unwrap();
			                $mainContent.fadeIn(300, function() {
			                	$mainContent.css("top", top).ajax("hashDidLoad", hash);
			                });
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

				// Create the smart banner
				$.smartbanner({
					title: "InEvent", // What the title of the app should be in the banner (defaults to <title>)
					author: "Estúdio Trilha", // What the author of the app should be in the banner (defaults to <meta name="author"> or hostname)
					price: 'Gratuito', // Price of the app
					appStoreLanguage: 'pt-br', // Language code for App Store
					inAppStore: 'Na App Store', // Text of price for iOS
					inGooglePlay: 'No Google Play', // Text of price for Android
					icon: 'images/logo@512.png', // The URL of the icon (defaults to <meta name="apple-touch-icon">)
					iconGloss: null, // Force gloss effect for iOS even for precomposed
					button: 'Ver', // Text for the install button
					scale: 'auto', // Scale based on viewport size (set to 1 to disable)
					speedIn: 300, // Show animation speed of the banner
					speedOut: 400, // Close animation speed of the banner
					daysHidden: 15, // Duration to hide the banner after being closed (0 = always show banner)
					daysReminder: 90, // Duration to hide the banner after "VIEW" is clicked *separate from when the close button is clicked* (0 = always show banner)
					force: null // Choose 'ios' or 'android'. Don't do a browser check, just always show this banner
				});

				// Resize the bar size
				$(".menuContent").trigger("resizeBar");

				// Load the module
				require(["modules/" + newHash], function() {
					// Load the specific initalizer of each page
					$("#" + newHash + "Content").trigger("hashDidLoad");
				});
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

// ------------------------------------- AJAX ------------------------------------- //

	/**
	 * Always load content dinamically with few expections
	 */
	$(document).on("click", "a", function(event) {

		if ($(this).attr("data-lock") != "yes") {

			if ($(this).attr("target") == "_blank") return true;
			if ($(this).hasClass("reloadPage")) return true;
			
			if ($(this).attr("href") != undefined) {
				if ($(this).attr("href").substr(0, 10) == "javascript") return true; // Chosen
				if ($(this).attr("href").substr(0, 7) == "http://") return true;
				if ($(this).attr("href").substr(0, 8) == "https://") return true;
				if ($(this).attr("href").substr(0, 7) == "mailto:") return true;
				if ($(this).attr("href") == "logout.php") return true;
			}

			$(this).ajax("hashConfigureSource", $(this).attr("href"));
		}
		
		event.preventDefault();
	    return false;
	});

	/**
	 * Load the new hash
	 */
	$(window).bind('hashchange', function(event) {
		$(this).ajax("hashConfigureSource", window.location.hash);
	});

});});