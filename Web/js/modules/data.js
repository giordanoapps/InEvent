$(document).ready(function() {

// --------------------------------------- DATA -------------------------------------- //

	/**
	 * Page initialization
	 * @return {null}
	 */
	$("#dataContent").live("hashDidLoad", function() {

		var $parent = $(this);
		var $form = $parent.find(".dataForm");

		// Populate the old fields
		var registrationData = JSON.parse(localStorage.getItem("registrationData")) || {};
		if (Object.keys(registrationData).length != 0) {
			var vector = Object.keys(registrationData);
			for (var i = 0; i<vector.length; i++) {
				if (registrationData[vector[i]] != "") {
					var $element = $form.find("#" + vector[i]);
					if ($element.attr("readonly") != "readonly") {
						$element.val(registrationData[vector[i]]);
					}
				}
			}
		}

		// Create the basic fields
		$form.find(".cnpj").mask("99.999.999/9999-99");
		$form.find(".zipCode").mask("99999-999");
		$form.find(".bossCPF").mask("999.999.999-99");
		$form.find(".telephone").np("telephoneVerification");

		var validator = $parent.find(".dataForm").validate({
	        rules: {
	            companyName: {
					required: true,
					minlength: 10
				},
				address: {
					required: true,
					minlength: 10
				},
				city: {
					required: true,
				},
				state: {
					required: true,
					minlength: 2
				},
				zipCode: {
					required: true,
					minlength: 8
				},
				bossName: {
					required: true,
					minlength: 5
				},
				bossEmail: { 
	                required: true, 
	                email: true
	            },
				bossPassword: { 
	                required: true, 
	                minlength: 6  
	            }, 
	            bossPasswordConfirm: { 
	                required: true, 
	                minlength: 6,
	                equalTo: "#bossPassword"
	            },
				agreement: {
					required: true
				},
				newsletter: {
					required: false
				},
	        }, 
	        messages: {
	            companyName: {
					required: "Insira um Razão Social válida",
					minlength: jQuery.format("Insira pelo menos {0} caracteres")
				}, 
				address: {
					required: "Insira um endereço válido",
					minlength: jQuery.format("Insira pelo menos {0} caracteres")
				},
				city: {
					required: "Insira uma cidade válida",
				},
				state: {
					required: "Insira um estado válido",
					minlength: jQuery.format("Insira pelo menos {0} caracteres")
				},
				zipCode: {
					required: "Insira um CEP válido",
				},
				bossName: {
					required: "Insira um nome válido",
					minlength: jQuery.format("Insira pelo menos {0} caracteres")
				},
				bossEmail: { 
	                required: "Insira um email válido", 
	                minlength: jQuery.format("Insira pelo menos {0} caracteres")
	            },
				bossPassword: {
	                required: "Insira uma senha", 
	                minlength: jQuery.format("Insira pelo menos {0} caracteres")
	            }, 
	            bossPasswordConfirm: {
	                required: "Insira uma senha", 
	                minlength: jQuery.format("Insira pelo menos {0} caracteres"),
	                equalTo: "Insira a mesma senha"
	            },
				agreement: {
					required: "Concorde com os termos para efetuar o registro",
				},
				newsletter: {}
	        }, 
	        // the errorPlacement has to take the table layout into account 
	        errorPlacement: function(error, element) { 
	            if ( element.is(":radio") ) 
	                error.appendTo( element.parent().next().next() ); 
	            else if ( element.is(":checkbox") ) 
	                error.appendTo ( element.next() ); 
	            else 
	                error.appendTo( element.parent() ); 
	        }, 
	        // set this class to error-labels to indicate valid fields 
	        success: function(label) { 
	            // set   as text for IE 
	            label.html("").addClass("checked"); 
	        }
	    });
	});

	/**
	 * Cancel the default behavior of the form
	 * @return {null} 
	 */
	$("#dataContent .dataForm").live("submit", function() {
		return false;
	});

	/**
	 * Trigger the form validator
	 * @return {null}
	 */
	$("#dataContent .navigator li, #dataContent .sequenceContent li").live("click", function() {

		var $parent = $(this).parents("#dataContent");

		if ($parent.find(".dataForm").valid()) {

			var temp = $parent.find(".dataForm").serializeArray();

			var registrationData = JSON.parse(localStorage.getItem("registrationData")) || {};

			for (var i = 0; i < temp.length; i++) {
				if (temp[i].name != "") {
					registrationData[temp[i].name] = temp[i].value;
				}
			}

			localStorage.setItem("registrationData", JSON.stringify(registrationData));

			// Release the anchor and load the new page
			$(this).closest("a").attr("data-lock", "no").trigger("click");
		}
	});

});