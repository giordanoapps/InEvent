require.config({
    "baseUrl": "js/lib",
    "waitSeconds": 15,
  	"urlArgs": "bust=" + (new Date()).getTime(),
    "paths": {
    	'jquery': 'jquery-1.8.3.min',
    	'jquery-ui': 'jquery-ui-1.9.2.custom.min',
		'jquery.inview': 'jquery.inview.min',
		'jquery.validate': 'jquery.validate',
		'jquery.maskedinput': 'jquery.maskedinput-1.3.min',
		'jquery.mousewheel': 'jquery.mousewheel.min',
		'jquery.scrollbar': 'perfect-scrollbar-0.4.4.min',
		'jquery.fileuploader': 'jquery.fileuploader.min',
		'jquery.chosen': 'chosen.jquery.min',
		'google.analytics': 'analytics.min',
		'google.maps': 'https://maps.googleapis.com/maps/api/js?sensor=false&region=BR',
    	'imagesLoaded': 'imagesLoaded.min',
      	'modules': '../modules'
    },
    shim: {

    	// Plugins
		'jquery-ui': ['jquery'],
		'jquery.inview': ['jquery'],
		'jquery.validate': ['jquery'],
		'jquery.maskedinput': ['jquery'],
		'jquery.mousewheel': ['jquery'],
		'jquery.scrollbar': ['jquery', 'jquery.mousewheel'],
		'jquery.fileuploader': ['jquery'],
		'jquery.chosen': ['jquery'],

		// Modules
		'modules/ajax': ['jquery'],
		'modules/bar': ['jquery'],
		'modules/collection': ['jquery'],
		'modules/data': ['jquery'],
		'modules/event': ['jquery'],
		'modules/field': ['jquery'],
		'modules/forgot': ['jquery'],
		'modules/home': ['jquery'],
		'modules/loaders': ['jquery'],
		'modules/location': ['jquery'],
		'modules/marketplace': ['jquery'],
		'modules/notification': ['jquery'],
		'modules/np': ['jquery'],
		'modules/people': ['jquery'],
		'modules/register': ['jquery'],
		'modules/smartresize': ['jquery'],
		'modules/tools': ['jquery'],
		'modules/userSettings': ['jquery'],
		'modules/validator': ['jquery', 'jquery.validate'],
		'modules/window': ['jquery']
    }
});

// Load some modules
var basic = [];

basic.push('jquery-ui');
basic.push('jquery.inview');
basic.push('jquery.mousewheel');
basic.push('jquery.scrollbar');
basic.push('google.analytics');

basic.push('modules/np');
basic.push('modules/field');
basic.push('modules/ajax');
basic.push('modules/smartresize');
basic.push('modules/loaders');
basic.push('modules/window');
basic.push('modules/collection');
basic.push('modules/bar');
// basic.push('modules/notification');
basic.push('modules/userSettings');
basic.push('modules/tools');

define(basic);
