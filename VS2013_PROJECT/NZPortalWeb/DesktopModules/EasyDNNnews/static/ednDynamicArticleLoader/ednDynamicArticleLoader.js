(function ($) {
$.fn.ednDynamicArticleLoader = function (settings) {
	return this.each(function(i, el) {
		var startingArticle = settings.startingArticle,
			$articlesContainer = $(el),
			$triggerWrapper = $(settings.triggerWrapperSelector),
			$returnHtml = $('> .trigger > .actionTextContainer > span', $triggerWrapper),
			$window = $(window),
			$document = $(document),

			requestInProgress = false,
			allArticlesLoaded = false,
			isotopeLayout = $.fn.isotope && $articlesContainer.parent().hasClass('edn_isotopeLayout'),

			getMoreArticles = function () {
				if (requestInProgress || allArticlesLoaded)
					return false;

				requestInProgress = true;

				$.ajax({
					data: $.extend({}, settings.params, {startingArticle: startingArticle}),
					dataType: 'json',
					success: function (response) {
						var $newHtml,
							isotopeItems = [];

						$newHtml = $(response.content).appendTo($articlesContainer);

						if (isotopeLayout) {
							$newHtml.each(function () {
								if ($(this).hasClass('edn_articleWrapper'))
									isotopeItems.push(this);
							});

							$articlesContainer.isotope('insert', isotopeItems);
						}

						startingArticle = startingArticle + settings.numberOfPostsperPage;

						if (response.itemsRemaining < 1)
							allArticlesLoaded = true;

						if (response.itemsRemaining < 1)
							$triggerWrapper.addClass('hide');

						$returnHtml.html(response.newActionText);

						if (settings.addThis) {
							window.addthis_config = {
								ui_delay: 500,
								data_track_addressbar: false
							}

							if (window.addthis) {
								window.addthis = null;
								window._adr = null;
								window._atc = null;
								window._atd = null;
								window._ate = null;
								window._atr = null;
								window._atw = null;
							}

							$.getScript('//s7.addthis.com/js/300/addthis_widget.js#domready=1');
						}
					},
					complete: function () {
						var $imgs,
							imageLoadedKey = 'imageLoaded';

						requestInProgress = false;

						$triggerWrapper.removeClass('loading');
						$('.rateit').rateit();

						if (isotopeLayout) {
							$imgs = $('img', $articlesContainer);

							if ($imgs.length != 0)
								$imgs.imagesLoaded()
									.progress(function (instance, image) {
										var $img = $(image.img);

										if ($img.data(imageLoadedKey))
											return;

										$img.data(imageLoadedKey, true);

										$articlesContainer.isotope('layout');
									});

							$articlesContainer.isotope('layout');
						}
					},
					url: settings.sourceUrl
				});

				return true;
			};

		$('> .trigger', $triggerWrapper).on('click', function () {
			if (getMoreArticles())
				$triggerWrapper.addClass('loading');

			return false;
		});

		if (settings.triggerOnScroll) {
			$window.scroll(function () {
				var pixelsToBottom = $document.height() - $window.scrollTop() - $window.height();

				if (pixelsToBottom < 500 && getMoreArticles())
					$triggerWrapper.addClass('loading');
			});
		}
	});
};
})(eds1_8);
