// ------------------------------------- AJAX ------------------------------------- //

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
			} else {

				var index = window.location.pathname.lastIndexOf('/'); 
				var hash = window.location.pathname.substring(index+1).replace(fileType, "");

				if (hash != "") {
					window.location.hash = hash;
				} else {
					window.location.hash = "home";
				}
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

			// Resize the bar size
			$(".menuContent").trigger("resizeBar");

			// if (readCookie("eventID") == null) createCookie("eventID", $(".bar .locationBox .locationItem").first().val(), 10);
			if (readCookie("eventID") == null) createCookie("eventID", 1);

			// Load the specific initalizer of each page
			$("#" + newHash + "Content").trigger("hashDidLoad");
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

// ------------------------------------- AJAX ------------------------------------- //

	/**
	 * Always load content dinamically with few expections
	 */
	$("a").live("click", function(e) {

		if ($(this).attr("data-lock") == "yes") {
			e.preventDefault();
			return false;
		}

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
		
		e.preventDefault();
	    return false;
	});

	/**
	 * Load the new hash
	 */
	$(window).bind('hashchange', function(event, href) {
		$(this).ajax("hashStartLoad");
	});

});