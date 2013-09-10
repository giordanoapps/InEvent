// ------------------------------------- STORAGE ---------------------------------- //

define(function() {

	return {
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

});
