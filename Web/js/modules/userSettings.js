$(document).ready(function() {

// ----------------------------------- USER SETTINGS ---------------------------------- //

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
				var $data = $(data);
				if ($ref.find(".collectionBox").size() == 1) {
					$data.filter("li").append("<img src='images/16-Cross.png' alt='Delete' class='powerUsersDelete' />");
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
		function(data) {}, 'html' ).fail(function() {
			$(".errorBox").fadeToggle(200);
		});
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
		function(data) {}, 'html' ).fail(function() {
			$(".errorBox").fadeToggle(200);
		});
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
			},
			function(data) {
				// So the user can type the new password
				window.location.reload();
			}, 'html' ).fail(function() {
				$(".errorBox").fadeToggle(200);
			});
		}
		
	});
	
});