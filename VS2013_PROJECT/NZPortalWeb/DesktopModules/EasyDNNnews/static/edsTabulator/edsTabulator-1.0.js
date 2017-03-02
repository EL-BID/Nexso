(function ($, window) {
	var activeClass = 'edsTabulator_active',
		tabTriggerSelector = '.edsTabulator_tabTrigger',
		tabSelector = '.edsTabulator_tab';

	function edsTabulator (elem) {
		var self = this,
			$mainWrapper = $(elem);

		$mainWrapper
			.on('click', tabTriggerSelector, function () {
				var $clicked = $(this),
					itemIndex = $clicked.index(),
					$tabContentWrappers = $('.edsTabulator_tabsWrapper .edsTabulator_tab', $mainWrapper);

				if ($clicked.hasClass(activeClass))
					return;

				$tabContentWrappers.removeClass(activeClass);
				$(tabTriggerSelector, $mainWrapper).removeClass(activeClass);

				$clicked.addClass(activeClass);
				$tabContentWrappers.eq(itemIndex).addClass(activeClass);
			});

		if ($(tabTriggerSelector + '.' + activeClass, $mainWrapper).length == 0) {
			$(tabSelector + '.' + activeClass, $mainWrapper).removeClass(activeClass);

			$(tabTriggerSelector, $mainWrapper).eq(0).addClass(activeClass);
			$(tabSelector, $mainWrapper).eq(0).addClass(activeClass);
		}
	}

	edsTabulator.prototype = {};

	$.fn.edsTabulator_1 = function () {
		var instanceKey = 'edsTabulatorRun';

		return this.each(function () {
			var self = this;

			if (!$.data(self, instanceKey))
				$.data(self, instanceKey, new edsTabulator(self));
		});
	};

})(jQuery, window);