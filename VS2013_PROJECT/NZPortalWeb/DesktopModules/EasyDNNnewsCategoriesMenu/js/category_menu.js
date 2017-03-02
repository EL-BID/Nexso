!function () {
var eds_category_menu = function ($) {
	var $category_menue_items = $('.edn_category_menu_wrapper li, .edn_archive_menu_wrapper li');

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
					$clicked.removeClass('opened');
				} else {
					$child_list.slideDown(200);
					$expand_collapse.addClass('collapse');
					$clicked.addClass('opened');
				}
			}

			return false;
		}
	});
};

if (typeof eds1_8 !== 'undefined')
	eds1_8(eds_category_menu);
else if (typeof jQuery !== 'undefined')
	jQuery(eds_category_menu);
}();
