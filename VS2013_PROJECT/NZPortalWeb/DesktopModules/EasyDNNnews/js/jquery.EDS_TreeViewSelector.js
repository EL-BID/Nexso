(function ($) {
	var public_methods = {
			destroy: function() {
				return this.each(function () {
					var $this = $(this);

					$this.data('EDS_TreeViewSelector').state_checkbox.unbind('.EDS_TreeViewSelector');

					$this
						.undelegate('.EDS_TreeViewSelector')
						.removeData('EDS_TreeViewSelector');
				});
			}
		},

		init = function(options) {
			return this.each(function(){
				var $container = $(this),
					is_advanced = $container.hasClass('edn_advanced_tree_view');

				if ($container.data('EDS_TreeViewSelector') || typeof options !== 'object' || !options.state_checkbox)
					return;

				options.state_checkbox.bind('click.EDS_TreeViewSelector', function () {
					var $selected_checkboxes = $container.find('input[type="checkbox"]:checked'),
						$child_checkboxes = $();

					if (is_advanced)
						$selected_checkboxes.each(function () {
							$child_checkboxes = $child_checkboxes.add($(this).parents().eq(1).siblings('ul').find('input[type="checkbox"]'));
						});
					else
						$child_checkboxes = $selected_checkboxes.parents('table').next('div').find('input[type="checkbox"]');

					$container.find('input[type="checkbox"]').prop('disabled', false);

					if (this.checked)
						$child_checkboxes
							.prop('checked', true)
							.prop('disabled', true);
					else
						$child_checkboxes
							.prop('checked', false)
							.prop('disabled', false);
				});

				if (options.state_checkbox[0].checked)
					if (is_advanced)
						$container.find('input[type="checkbox"]:checked').each(function () {
							$(this).parents().eq(1).siblings('ul').find('input[type="checkbox"]')
								.prop('checked', true)
								.prop('disabled', true);
						});
					else
						$container.find('input[type="checkbox"]:checked').parents('table').next('div').find('input[type="checkbox"]')
							.prop('checked', true)
							.prop('disabled', true);

				$container
					.data('EDS_TreeViewSelector', {
						state_checkbox: options.state_checkbox
					})
					.delegate('input[type="checkbox"]', 'change.EDS_TreeViewSelector', function () {
						var $changed = $(this),
							$child_checkboxes;

						if (!$container.data('EDS_TreeViewSelector').state_checkbox[0].checked)
							return;

						if (is_advanced)
							$child_checkboxes = $changed.parents().eq(1).siblings('ul').find('input[type="checkbox"]');
						else
							$child_checkboxes = $changed.parents('table:first').next('div').find('input[type="checkbox"]');

						if ($child_checkboxes.length) {
							if ($changed.is(':checked')) {
								$child_checkboxes
									.prop('checked', true)
									.prop('disabled', true);
							} else {
								$child_checkboxes
									.prop('checked', false)
									.prop('disabled', false);
							}
						}
					});
			});
		};

	$.fn.EDS_TreeViewSelector = function(method) {
		if (public_methods[method])
			return public_methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
		else if (typeof method === 'object' || !method)
			return init.apply(this, arguments);
	};
})(jQuery);
