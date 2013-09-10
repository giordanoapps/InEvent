// ------------------------------------- NP MODULE ------------------------------------- //

var modules = [];
modules.push('jquery');
modules.push('common');
modules.push('jquery.maskedinput');

define(modules, function($) {$(function() {

	$.fn.np = function(method) {

		var telephoneInput = "";

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
			 * Create a map, a marker and a default location
			 * @param  {google.maps.LatLng} deadLocation 	The default location
			 * @param  {oject}				mapOptions    	Options for the map
			 * @param  {object}				markerOptions	Options for the marker
			 * @return {object} 			locationData 	Information
			 */
			geoMap: function(deadLocation, mapOptions, markerOptions) {

				// Allocate an object
				var locationData = {};

				try {
					// Case the user didn't send a default location
					if (typeof deadLocation !== "object") {
						locationData.deadLocation = new google.maps.LatLng(-23.5489433, -46.6388182); // SP
					}

					if (typeof mapOptions !== "object") {
						mapOptions = {
							zoom: 16,
							mapTypeId: google.maps.MapTypeId.ROADMAP
						};
					}

					locationData.map = new google.maps.Map(this[0], mapOptions);

					if (typeof markerOptions !== "object") {
						markerOptions = {
							map: locationData.map,
							animation: google.maps.Animation.DROP,
							draggable: true
						};
					}

					locationData.marker = new google.maps.Marker(markerOptions);

				} catch (Exception) {
					console.log("Map could not be loaded");
				}

				return locationData;
			},

			/**
			 * Geocoder the user for a certain address
			 * @param  {string} 			text          The address
			 * @param  {google.maps.LatLng} deadLocation  The default location
			 * @param  {object}				mapOptions    Options for the map
			 * @param  {object} 			markerOptions Options for the marker
			 * @return {object} 			locationData  Information
			 */
			geocoder: function(text, deadLocation, mapOptions, markerOptions) {
				
				var locationData = this.np("geoMap", deadLocation, mapOptions, markerOptions);
				
				locationData.geocoder = new google.maps.Geocoder();

				locationData.geocoder.geocode(
					{'address': text}, 
					function(results, status) { 
						if (status == google.maps.GeocoderStatus.OK) { 
							var loc = results[0].geometry.location;
							locationData.map.setCenter(loc);
							locationData.marker.setPosition(loc);
			            }  else {
			            	// Case not, we default it to São Paulo
			            	locationData.marker.setPosition(locationData.deadLocation);
			            	locationData.map.setCenter(locationData.deadLocation); 
			            }
			        }
				);

				return locationData;
			},

			/**
			 * Geolocate the user based on his actual location
			 * @param  {object} 			locationData  	Information
			 * @param  {google.maps.LatLng} deadLocation  	The default location
			 * @param  {object} 			mapOptions   	Options for the map
			 * @param  {object} 			markerOptions 	Options for the marker
			 * @return {object} 			locationData  	Information
			 */
			geolocate: function(locationData, deadLocation, mapOptions, markerOptions) {

				var locationData = this.np("geoMap", deadLocation, mapOptions, markerOptions);

				// Geolocation is not so accurate, so we must zoom it out a bit
				locationData.map.setZoom(10);

				// Try W3C Geolocation (Preferred)
				if (navigator.geolocation) {
				  	navigator.geolocation.getCurrentPosition(function(position) {
				  		// We get the geocoderd position and define it as our center
				  		initialLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
				  		locationData.marker.setPosition(initialLocation);
				  		locationData.map.setCenter(initialLocation);
				  	}, function() {
				  		handleNoGeolocation();
				  	});
				// Browser doesn't support Geolocation
				} else {
					browserSupportFlag = false;
					handleNoGeolocation();
				}

				function handleNoGeolocation(errorFlag) {
					locationData.map.setCenter(locationData.deadLocation);
				}

				return locationData;
			},

			/**
			 * See if all the form input's are valid
			 * @return {null}
			 */
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

			/**
			 * Get all form inputs, serialize and save them
			 * @return {null}
			 */
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
						$info.toggleClass("editMode").find(".saveButtonError").text("Insira todos os dados, incluindo a imagem.");
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

});});