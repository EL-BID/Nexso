(function ($) {
	$.fn.EDNGenerateUrl = function (target_selector, replace_map) {
		var $source = $(this),
			$target,
			run_filter = function () {
				var input = $source.val(),
					input_length = input.length,
					i,
					filter_output = '',
					final_output = '';

				for (i = 0; i < input_length; i++)
					if (typeof replace_map[input.charAt(i)] == 'string')
						filter_output += replace_map[input.charAt(i)];
					else
						filter_output += input.charAt(i);

				input_length = filter_output.length;

				for (i = 0; i < input_length; i++) {
					final_output += filter_output.charAt(i);

					if (filter_output.charAt(i) == '-')
						while (filter_output.charAt(i + 1) == '-')
							i++;
				}

				$target.val(final_output);
			};

		if (typeof target_selector == 'string')
			$target = $(target_selector);
		else if (target_selector instanceof jQuery)
			$target = target_selector;
		else
			return false;

		$source
			.keyup(run_filter)
			.change(run_filter);
	};
} (jQuery));
