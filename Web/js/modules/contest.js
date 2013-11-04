// --------------------------------------- CONTEST --------------------------------------- //

define(["jquery", "common", "modules/cookie"], function($, common, cookie) {$(function() {

// -------------------------------------- LOADER -------------------------------------- //
	
	/**
	 * Page initialization
	 * @return {null}
	 */
	$("#contestContent").on("hashDidLoad", function (event) {

		// Hold the current input
		var $elem = $(this);

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "contest.requestAddress",
			eventID: cookie.read("eventID"),
			format: "json"
		}), {},
		function(data, textStatus, jqXHR) {

			if (jqXHR.status == 200) {
				if (data.data.length > 0) {
					$elem.find(".youtubeURL").val(data.data[0].url).addClass("validURL");
				}
			}

		}, 'json');

	});


// -------------------------------------- PAGE -------------------------------------- //


	/**
	 * Get the current url
	 * @return {null}       
	 */
	$("#contestContent").on("focusout", ".youtubeURL", function (event) {

		// Hold the current input
		var $elem = $(this);

		// We request the information on the server
		$.post('developer/api/?' + $.param({
			method: "contest.informAddress",
			eventID: cookie.read("eventID"),
			format: "html"
		}), {
			url: $elem.val()
		},
		function(data, textStatus, jqXHR) {

			if (jqXHR.status == 200) {
				$elem.addClass("validURL");
			}

		}, 'html').fail(function(jqXHR, textStatus, errorThrown) {
			$elem.addClass("invalidURL");
		});

	});

});});