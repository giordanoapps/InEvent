// --------------------------------------- COOKIE --------------------------------------- //

define(function() {

	return {
		create: function(name, value, days) {
		    if (days) {
		        var date = new Date();
		        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
		        var expires = "; expires=" + date.toGMTString();
		    } else var expires = "";
		    document.cookie = escape(name) + "=" + escape(value) + expires + "; path="+ window.location.pathname;
		},
		read: function(name) {
		    var nameEQ = escape(name) + "=";
		    var ca = document.cookie.split(';');
		    for (var i = 0; i < ca.length; i++) {
		        var c = ca[i];
		        while (c.charAt(0) == ' ') c = c.substring(1, c.length);
		        if (c.indexOf(nameEQ) == 0) return unescape(c.substring(nameEQ.length, c.length));
		    }
		    return null;
		},
		erase: function(name) {
		    createCookie(name, "", -1);
		}
	}

});
