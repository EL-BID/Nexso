eds1_8(document).ready(function ($) {
	var $category_menue_items = $('.edn_filter_menu li');

	$category_menue_items.click(function (e) {
		var $target = $(e.target),
			$clicked,
			$child_list,
			$expand_collapse;

		if ($target.is('div') || $target.is('a.expand_collapse')) {
			$clicked = $(this);
			$child_list = $clicked.find('> ul');
			$expand_collapse = $clicked.find('> div > a.expand_collapse');

			if ($child_list.length == 1) {
				if ($child_list.is(':visible')) {
					$child_list.slideUp(200);
					$expand_collapse.removeClass('collapse');
				} else {
					$child_list.slideDown(200);
					$expand_collapse.addClass('collapse');
				}
			}

			return false;
		}
	});
});
