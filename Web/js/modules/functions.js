
	// Code by Paul Irish
	(function($,sr){

		// debouncing function from John Hann
		// http://unscriptable.com/index.php/2009/03/20/debouncing-javascript-methods/
		var debounce = function (func, threshold, execAsap) {
			var timeout;

			return function debounced () {
				var obj = this, args = arguments;
				function delayed () {
					if (!execAsap)
						func.apply(obj, args);
					timeout = null; 
				};

				if (timeout)
					clearTimeout(timeout);
				else if (execAsap)
					func.apply(obj, args);

				timeout = setTimeout(delayed, threshold || 100); 
			};
		}
		// smartresize 
		jQuery.fn[sr] = function(fn){  return fn ? this.bind('resize', debounce(fn)) : this.trigger(sr); };

	})(jQuery,'smartresize');

	// Additional JS functions here
	window.fbAsyncInit = function() {
		FB.init({
			appId      : '163067900545662', // App ID
			channelUrl : '//presenca.me/channel.html', // Channel File
			status     : true, // check login status
			cookie     : true, // enable cookies to allow the server to access the session
			xfbml      : true  // parse XFBML
		});

		// Here we subscribe to the auth.authResponseChange JavaScript event. This event is fired
		// for any authentication related change, such as login, logout or session refresh. This means that
		// whenever someone who was previously logged out tries to log in again, the correct case below 
		// will be handled. 
		FB.Event.subscribe('auth.authResponseChange', function(response) {
			// Here we specify what we do with the response anytime this event occurs. 
			if (response.status === 'connected') {
			  // The response object is returned with a status field that lets the app know the current
			  // login status of the person. In this case, we're handling the situation where they 
			  // have logged in to the app.
			  testAPI();
			} else if (response.status === 'not_authorized') {
			  // In this case, the person is logged into Facebook, but not into the app, so we call
			  // FB.login() to prompt them to do so. 
			  // In real-life usage, you wouldn't want to immediately prompt someone to login 
			  // like this, for two reasons:
			  // (1) JavaScript created popup windows are blocked by most browsers unless they 
			  // result from direct interaction from people using the app (such as a mouse click)
			  // (2) it is a bad experience to be continually prompted to login upon page load.
			  FB.login();
			} else {
			  // In this case, the person is not logged into Facebook, so we call the login() 
			  // function to prompt them to do so. Note that at this stage there is no indication
			  // of whether they are logged into the app. If they aren't then they'll see the Login
			  // dialog right after they log in to Facebook. 
			  // The same caveats as above apply to the FB.login() call here.
			  FB.login();
			}
		});

	};

	// Load the SDK asynchronously
	(function(d){
		var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
		if (d.getElementById(id)) {return;}
		js = d.createElement('script'); js.id = id; js.async = true;
		js.src = "//connect.facebook.net/en_US/all.js";
		ref.parentNode.insertBefore(js, ref);
	}(document));

	function testAPI() {
		console.log('Welcome!  Fetching your information.... ');
		FB.api('/me', function(response) {
			console.log('Good to see you, ' + response.name + '.');
		});
	}

	/**
	 * Type of device being used
	 * @return {null}
	 */
	var isMobile = {
	    Android: function() {
	        return navigator.userAgent.match(/Android/i) ? true : false;
	    },
	    BlackBerry: function() {
	        return navigator.userAgent.match(/BlackBerry/i) ? true : false;
	    },
	    iOS: function() {
	        return navigator.userAgent.match(/iPhone|iPad|iPod/i) ? true : false;
	    },
	    Windows: function() {
	        return navigator.userAgent.match(/IEMobile/i) ? true : false;
	    },
	    any: function() {
	        return (isMobile.Android() || isMobile.BlackBerry() || isMobile.iOS() || isMobile.Windows());
	    }
	};

	/**
	 * Cookies!
	 * @return {null}
	 */
	function createCookie(name, value, days) {
	    if (days) {
	        var date = new Date();
	        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
	        var expires = "; expires=" + date.toGMTString();
	    } else var expires = "";
	    document.cookie = escape(name) + "=" + escape(value) + expires + "; path="+ window.location.pathname;
	}

	function readCookie(name) {
	    var nameEQ = escape(name) + "=";
	    var ca = document.cookie.split(';');
	    for (var i = 0; i < ca.length; i++) {
	        var c = ca[i];
	        while (c.charAt(0) == ' ') c = c.substring(1, c.length);
	        if (c.indexOf(nameEQ) == 0) return unescape(c.substring(nameEQ.length, c.length));
	    }
	    return null;
	}

	function eraseCookie(name) {
	    createCookie(name, "", -1);
	}

	/**
	 * Local storage with expiration!
	 * @type {null}
	 */
	var storageExpiration = {
		save: function(key, data, expirationMin) {
			var expirationMS = expirationMin * 60 * 1000;
			var record = {
				value: data,
				timestamp: new Date().getTime() + expirationMS
			};

			localStorage.setItem(key, JSON.stringify(record));

			return data;
		},
		load: function(key) {
			var record = JSON.parse(localStorage.getItem(key));
			if (record) {
				if (new Date().getTime() < record.timestamp) {
				 	return record.value;
				} else {
					localStorage.removeItem(key);
				}
			}

			return false;
		}
	}

	/**
	 * Swap the cache
	 */
	// window.applicationCache.addEventListener("updateready", function() {
	// 	alert(JSON.stringify(localStorage).length);
	// 	window.applicationCache.swapCache();
	// });
	window.applicationCache.addEventListener('updateready', function(e) {
		if (window.applicationCache.status == window.applicationCache.UPDATEREADY) {
			window.applicationCache.swapCache();
			// alert(JSON.stringify(localStorage).length);
		} else {
	      // Manifest didn't changed. Nothing new to server.
	    }
	}, false);