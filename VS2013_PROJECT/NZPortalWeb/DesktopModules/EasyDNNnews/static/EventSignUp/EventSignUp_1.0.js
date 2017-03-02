(function ($, undefined) {
	var sentRequest = undefined;

	window.edn_signUpToEvent = function (pathToAshx, actionBarMainDivID, parameters, radioValue) {
		if (sentRequest && sentRequest.readyState != 4)
			sentRequest.abort();

		$('input[value="' + radioValue + '"]', $('.eds_signUpActionBar')).prop('checked', true);

		parameters['action'] = radioValue;

		sentRequest = jQuery.ajax({
			url: pathToAshx,
			type: 'GET',
			contentType: 'application/json; charset=utf-8',
			data: parameters,
			dataType: 'json',
			success: function () {
				sentRequest = undefined;
			}
		});
	};
})(eds1_8);