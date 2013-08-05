// ------------------------------------- FIELD MODULE ------------------------------------- //

$.fn.field = function(method) {

	var telephoneInput = "";

	var methods = {
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

			var $fields = $();

			this.each(function () {
				var className = $(this).attr('class');
				var name = $(this).attr("name");
				var value = $(this).text();

				// Seek an optional name
				if (typeof name === 'undefined' || name === false) {
				    var name = $(this).attr("title");
				}

				var $fieldContent = $(document.createElement(elementType))
						.val(value) // We must set a value
						.attr("name", name) // We must set a name
						.addClass(className) // We must set the class it came with
						.attr(attrOptions) // We must set attrOptions
						.css(cssOptions); // We must set cssOptions

				// Add the new field and capture the collection
				$fields = $fields.add($fieldContent);

				$(this).replaceWith($fieldContent);
			});

			return $fields;
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

			var $fields = $();
			// $fields.add("div");
			this.each(function () {
				var className = $(this).attr('class');
				var name = $(this).attr("name");
				var value = ($(this).val() + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br ' + '/>' + '$2');

				var $fieldContent = $(document.createElement("span"))
						.html(value) // We must set a value
						.attr("name", name) // We must set a name
						.attr("title", name) // We must set a name
						.addClass(className) // We must set the class it came with
						.attr(attrOptions) // We must set attrOptions
						.css(cssOptions); // We must set cssOptions

				if ($(this).attr('type') == 'password') {
					$fieldContent.text("*****");
				}

				// Add the new field and capture the collection
				$fields = $fields.add($fieldContent);

				$(this).replaceWith($fieldContent);
			});

			return $fields;
		},

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