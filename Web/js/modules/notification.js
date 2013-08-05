$(document).ready(function() {

// ------------------------------------- NOTIFICATION ---------------------------------- //

	(function checking() {
		if ($(".loginBar").length == 0) checkNotifications();

		setTimeout(checking, 5000); // 5s
	})();
	
	// Load the user notification info after 2s
	window.setTimeout(userNotifications, 1250);
	
	function checkNotifications() {

		// Let's try to find the last item on the notification center
		var lastNotificationID = $(".notificationsContent li:first-child").val();

		if (typeof lastNotificationID === 'undefined' || lastNotificationID === false) lastNotificationID = 0;
		
		$.post('ajax.php',
		{	// We are gonna roll it down according to the badge content flow (so if the flow changes, the code has to change)
			checkNotifications: lastNotificationID
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
			if ($(".notifications li[value = \"" + data.id + "\"]").length == 0) {

				// So we create an element with the content
				var $item = $("<li></li>").clone();
				$item.val(data.id).append($("<a></a>").attr("href", data.url).html(data.action));

				// See if the notification has already been delivered
				if (jsonReturn.data[i].status == 0) {
					// Open the box and then prepend the content to it
					$(".notificationBox").show().children("ul").prepend($item.addClass("unseenNotification"));
					
					// Show the info, wait for a while and then fade it out
					(function($item) {
						return (function() {
							$item.fadeIn(200).delay(8000).fadeOut(3000, function() {
								moveNotificationFromBoxToCenter($item);
							});
						})();
					})($item);
				} else {
					// Append and immediately after move item to notification center
					$(".notificationBox ul").prepend($item);
					moveNotificationFromBoxToCenter($item);
				}
			}
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
		if (!fresh) actualCount = parseInt($(".notificationsInfoCount").text());
		
		// Then we update the notifications count
		$(".notificationsInfoCount").text(actualCount + jsonReturn.count);
		
		// Then we loop to see if the data on the browser is consistent
		for (var i = 0; i < jsonReturn.data.length; i++) {
						
			if ($(".notificationsContent li[value = \"" + jsonReturn.data[i].id + "\"]").length == 0) {
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
		if ($(".notificationsContent li[value = \"" + $item.val() + "\"]").length == 0) {
			// Prepend the item
			$(".notificationsContent ul").prepend($item.show());
			
			// And update the notifications count if the item is still unseen
			if ($item.hasClass("unseenNotification")) {
				$(".notificationsInfoCount").text(parseInt($(".notificationsInfoCount").text())+1);
			}
		}

		// So first we remove it from the bottom
		$item.remove();
		
		// And we see if there is any notification left, otherwise, we just fade the box
		if ($(".notificationBox li").length == 0) {
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
		var notificationsLoaded = $sibling.find("li").length;
		
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
	
});