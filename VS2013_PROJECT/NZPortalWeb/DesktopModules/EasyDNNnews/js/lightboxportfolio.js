(function ($) {
    $.fn.portfolioSetter = function (options) {
        var defaults = {
            //default settings
            ppanimationSpeed: false,
            ppgroup: 'M300',
            pptheme: 'dark_rounded',
            ppslideshow: false,
            ppautoplay_slideshow: false,
            ppoverlay_gallery: false,
            ppLightboxTitle: 'False',
            ppLightboxDescription: 'False',
            ppMediaTitle: 'False',
            ppMediaDescription: 'False',
            pfqtip: 'False',
            pfShowQtip: 'False',
            pfdiv: 'EasyDNNGallery',
            pfShowEffect: 'slide',
            pfHideEffect: 'slide',
            pfShowDuration: '300',
            pfHideDuration: '300',
            pfTargetPos: 'topMiddle',
            pfTooltipPos: 'topMiddle',
            pfTheme: 'cream',
            pfcorner: 5,
            pfradius: 5,
            pfOpenMediaUrl: 'False',
            pfOpenMediaTarget: '_self',
            itemMargin: 10,  //margin of each of the portfolio items
            showCategories: true,
            myshowCategories: true,  // if set to false, the categories will be hidden
            allText: 'ALL', //the ALL text displayed before the categories names
            easing: 'easeOutExpo', //the animation easing
            animationSpeed: 800, //the speed of the animation of the pagination
            navButtonWidth: 21,  //the width of the pagination button
            xmlSource: 'portfolio.xml',  //the XML file from which the data is exctracted
            navigationId: 'portfolio_pagination',  //the ID of the pagination div
            categoriesId: 'portfolio_categories', //the ID of the categories div
            itemClass: 'EDGimage', //the class of the div that wraps each portfolio item data
            itemsPerPage: 0,

            categorySelector: 'classic', //classic, dropdown
            showNavigationArrows: true,
            hidableNavigationArrows: true,
            hideNavigationArrowsOnEnds: false,
            customTitle: false,
            fullscreenable: true,
            fullscreenButtonText: 'Show fullscreen',
            moduleCssId: 'EDG_0_Shadow',
            fullscreenCssId: 'EDG_0_Shadow',
            scrollableContent: false,

            // dropdown and arrows sprite files
            navDDMFile: false,
            navArrowsFile: false,

            // XML request parameters
            xmlRequestParams: {
                GalleryType: 'portfolio',
                ModuleID: 0,
                ModulePath: '/DesktopModules/EasyDNNGallery/',
                PortalHome: '/Portals/0/',
                PortalID: 0,
                LocaleCode: 'False'
            },

            // Rendering options
            maxImgWidth: 150,
            maxImgHeight: 150,
            containerWidth: 710,
            containerHeight: 410,
            smartResize: true,
            spaceOutPage: true,
            fullscreenMode: false
        };

        var options = $.extend(defaults, options),

        //define some helper variables
			categories = [], items = [], pageWrappers = [], imagesLoaded = 0, counter = 0, ie = false, categoryHolder,

			root = $('<div />').css({ width: (options.containerWidth), height: options.containerHeight, float: 'left' }),
			rootParent = $(this),
			rootGrandparent = rootParent.parent(),

        // Dropdown category selector vars
			$portfolioCategoriesDropdown, $portfolioCategoriesDropdownSelector, $portfolioCategoriesDropdownContainer, dropdownCategorySelectorTimer = null,

        // Navigation arrows
			$navigationArrowLeft, $navigationArrowRight,

        // Rendering vars
			rendering = {
			    itemContainerWidth: 0,
			    itemContainerHeight: 0,
			    itemTopSpace: 0,
			    itemLeftSpace: 0,
			    itemsPerPage: 0,
			    maxItemsPerRow: 0,
			    maxRowCount: 0,
			    pageCount: 0,
			    pageRightPadding: 0,
			    pageWidth: 0,
			    pageHeight: 0,
			    valuesInitialized: false
			};

        if (options.fullscreenMode) {
            options.ppgroup = options.ppgroup + '_fullscreen';

            options.navigationId = options.navigationId + '_fullscreen';
            options.categoriesId = options.categoriesId + '_fullscreen';
        }

        rootParent
			.css({ width: options.containerWidth, height: 'auto', overflow: 'hidden' })
			.append(root);

        rootGrandparent.addClass('portfolio_gallery_container').width(options.containerWidth);

        init();
        function init() {
            rootParent.append('<div class="loading"></div>');
            loadItems();
        }

        if (options.fullscreenMode) {
            var $fullscreenMain = rootGrandparent.parent(),
				$fullscreenWrapper = $fullscreenMain.parent();

            $fullscreenMain
				.bind('resize_gallery', function () {
				    options.containerWidth = $fullscreenMain.width();
				    options.containerHeight = $fullscreenWrapper.height() - $fullscreenMain.data('initialOuterHeight') - (options.categorySelector == 'classic' ? (options.customTitle ? 135 : 107) : 70);

				    root.height(options.containerHeight);
				    rootParent.width(options.containerWidth);
				    rootGrandparent.width(options.containerWidth);

				    displayItems()
				})
				.bind('toNextPage', function () {
				    moveToNext();
				})
				.bind('toPrevPage', function () {
				    moveToPrev();
				});
        } else {
            // show the fullscreen button if enabled
            if (options.fullscreenable) {
                rootParent.after('<div class="EasyDNNGallery_fullscreen_btn_container"><a class="EasyDNNGallery_fullscreen_btn" href="#" onclick="jQuery().fullscreenPortfolioGallery(\'' + rootParent.attr('id') + '\'); return false;">' + options.fullscreenButtonText + '</a></div>');
            }
        }

        if (options.fullscreenMode || options.scrollableContent) {
            var scrollTarget = options.fullscreenMode ? $fullscreenWrapper : root;

            scrollTarget.bind('mousewheel.EasyDNNGallery_portfolio_mousewheel', function (event, delta) {
                if (delta > 0) {
                    moveToPrev();
                } else {
                    moveToNext();
                }

                return false;
            });
        }

        if (!options.fullscreenMode) {
            rootParent.data('EasyDNNGallery.portfolio.options', options);
        }


        /**
        * Parses the XML portfolio item data.
        */
        function loadItems() {
            $.ajax({
                type: 'POST',
                url: options.xmlSource,
                dataType: 'xml',
                data: options.xmlRequestParams,
                cache: false,
                success: function (xml) {
                    //get the settings
                    if ($(xml).find('show_categories:first').text() === 'off') {
                        options.showCategories = false;
                    }

                    if (options.showCategories) {
                        //get the portfolio categories
                        $(xml).find('categories').eq(0).find('category').each(function (i) {
                            var current = $(this);
                            var category = {
                                id: current.attr('id'),
                                name: current.text()
                            };
                            categories.push(category);
                        });
                    }

                    //get the portfolio items
                    $(xml).find('item').each(function (i) {
                        var current = $(this);
                        var thum = current.find('thumbnail:first').text().replace('\\', '/');
                        var prev = current.find('preview:first').text();
                        var cat = current.find('category:first').text().split(',');
                        var desc = current.find('description:first').text();
                        var imgtitle = current.find('title:first').text();
                        var imgalt = current.find('title:first').text();
                        var imgdesc = current.find('description:first').text();
                        var imgURL = current.find('mediaURL:first').text();
                        var mediatype = current.find('mediatype:first').text();
                        var cssClass = 'empty';
                        if (imgtitle.length > 0 && options.ppMediaTitle == 'True') {
                            cssClass = 'title';
                        }

                        if (desc.length > 0 && options.ppMediaDescription == 'True') {
                            cssClass = 'title';
                        }

                        if (options.ppLightboxTitle == 'False') {
                            imgalt = '';
                        }

                        if (options.ppLightboxDescription == 'False') {
                            imgdesc = '';
                        }

                        if (options.ppMediaTitle == 'False') {
                            imgtitle = '';

                        }

                        if (options.ppMediaDescription == 'False') {
                            desc = '';

                        }
                        medTarget = options.pfOpenMediaTarget;
                        relTag = "PortPhoto";
                        if (options.pfOpenMediaUrl == 'True' && mediatype == "Image") {
                            prev = imgURL;
                            relTag = "";
                        }
                        else {
                            medTarget = "";
                        }

                        var itemData = {
                            itemClass: options.itemClass,
                            relTag: relTag,
                            ppgroup: options.ppgroup,
                            prev: prev,
                            imgdesc: imgdesc,
                            medTarget: medTarget,
                            imgalt: imgalt,
                            thum: thum,
                            cssClass: cssClass,
                            imgtitle: imgtitle,
                            desc: desc
                        },
							item = {
							    thumbnail: thum,
							    category: cat,
							    data: itemData,
							    obj: generateItemObject(itemData)
							};
                        items.push(item);
                    });

                    setSetter();
                }
            });
        }

        /**
        * Calls the main functions for setting the portfolio items.
        */
        function setSetter() {

            if ($.browser.msie) {
                ie = true;
            }
            root.siblings('.loading').remove();
            root.after('<div id="' + options.navigationId + '" class="EDG_portfolio_pagination"><ul></ul></div>');
            if (options.fullscreenMode) {
                rootParent.before('<a href="#" class="closeFullscreenBtn ' + options.categorySelector + '"></a>');
                $fullscreenMain.trigger('fullscreen_close_btn_initialized');
            }

            if (options.myshowCategories) {
                displayCategories();
            }
            if (options.customTitle) {
                rootParent.before('<h1 class="portfolio_custom_title">' + options.customTitle + '</h1>');
            } else {
                if (options.categorySelector == 'dropdown') {
                    rootParent.before('<h1 class="portfolio_custom_title">&nbsp;</h1>');
                }
            }
            loadImages();

        }

        /**
        * Displays the categories.
        */
        function displayCategories() {
            switch (options.categorySelector) {
                case 'dropdown':
                    displayDropdownCategories();
                    break;

                default:
                    displayClassicCategories();
            }
        }

        /**
        * Displays the dropdown category selector.
        */
        function displayDropdownCategories() {
            categoryHolder = $('<div class="portfolio_gallery_categories_dropdown" class="portfolio_gallery_category_selector"></div>');
            categoryHolder.append('<a href="#" class="portfolio_categories_dropdown_selector"><span></span></a><div class="portfolio_categories_dropdown_container"><ul></ul></div>');
            rootParent.before(categoryHolder);

            var catUl = categoryHolder.find('ul'),
				selectedCat = categoryHolder.find('.portfolio_categories_dropdown_selector');

            selectedCat
				.children('span:first').text(options.allText)
				.click(function () {
				    return false;
				});

            //add the ALL link
            var allLink = $('<li><a href="#">' + options.allText + '</a><span class="id">0</span></li>');
            catUl.append(allLink);

            //add all the category names to the list
            var catNumber = categories.length;
            for (var i = 0; i < catNumber; i++) {
                catUl.append('<li><a href="#">' + categories[i].name + '</a><span class="id">' + categories[i].id + '</span></li>');
            };

            $portfolioCategoriesDropdown = rootGrandparent.children('.portfolio_gallery_categories_dropdown');
            $portfolioCategoriesDropdownSelector = rootGrandparent.find('.portfolio_categories_dropdown_selector');
            $portfolioCategoriesDropdownContainer = rootGrandparent.find('.portfolio_categories_dropdown_container');

            if (options.navDDMFile) {
                $portfolioCategoriesDropdownSelector.css('background-image', 'url("' + options.navDDMFile + '")');
                $portfolioCategoriesDropdownContainer.find('a').css('background-image', 'url("' + options.navDDMFile + '")');
            }

            // Preload dropdown background
            (new Image()).src = options.xmlRequestParams.ModulePath + 'Themes/portfolio/bgrd_gray_tr.png';

            $portfolioCategoriesDropdownContainer
				.data('closable', true)
				.delegate('a', 'click', function () {
				    var $clicked = $(this), galleryId;

				    $portfolioCategoriesDropdownSelector.find('span:first').text($clicked.text());
				    $portfolioCategoriesDropdownContainer.hide();

				    galleryId = $clicked.parent().children('span.id').text();
				    if (galleryId == '0') {
				        displayItems();
				    } else {
				        displayItems(galleryId);
				    }

				    return false;
				})
				.mouseover(function () {
				    clearTimeout(dropdownCategorySelectorTimer);
				    $portfolioCategoriesDropdownContainer.data('closable', false);
				})
				.mouseout(function () {
				    $portfolioCategoriesDropdownContainer.data('closable', true);
				    dropdownCategorySelectorTimer = setTimeout(function () {
				        if ($portfolioCategoriesDropdownContainer.data('closable')) {
				            $portfolioCategoriesDropdownContainer.hide();
				        }
				    }, 150);
				});

            $portfolioCategoriesDropdownSelector
				.mouseover(function () {
				    $portfolioCategoriesDropdownContainer.data('closable', false);
				    $portfolioCategoriesDropdownContainer.show();
				})
				.mouseout(function () {
				    $portfolioCategoriesDropdownContainer.data('closable', true);
				    dropdownCategorySelectorTimer = setTimeout(function () {
				        if ($portfolioCategoriesDropdownContainer.data('closable')) {
				            $portfolioCategoriesDropdownContainer.hide();
				        }
				    }, 150);
				});
        }

        /**
        * Displays the classic category selector.
        */
        function displayClassicCategories() {
            categoryHolder = $('<div id="' + options.categoriesId + '" class="EDG_portfolio_categories_classic"></div>');
            categoryHolder.append('<div class="EDG_portfolio_categories_classic_left"></div><ul></ul><div class="EDG_portfolio_categories_classic_right"></div>');

            root.before(categoryHolder);
            var catUl = categoryHolder.find('ul');


            //add the ALL link
            var allLink = $('<li>' + options.allText + '</li>');
            catUl.append(allLink);
            showSelectedCat(allLink);

            //bind the click event
            allLink.bind({
                'click': function () {
                    displayItems();
                    showSelectedCat($(this));

                    return false;
                },
                'mouseover': function () {
                    $(this).css({ cursor: 'pointer' });
                }
            });

            //add all the category names to the list
            var catNumber = categories.length;
            for (var i = 0; i < catNumber; i++) (function (i) {
                var category = $('<li>' + categories[i].name + '</li>');
                catUl.append(category);

                //bind the click event
                category.bind({
                    'click': function () {
                        displayItems(categories[i].id);
                        showSelectedCat($(this));

                        return false;
                    },
                    'mouseover': function () {
                        $(this).css({ cursor: 'pointer' });
                    }
                });
            })(i);
        }

        function showSelectedCat(selected) {
            //hide the previous selected element
            var prevSelected = categoryHolder.find('ul li.selected');
            if (prevSelected[0]) {
                var prevHtml = prevSelected.find('div.port_cat').html();
                prevSelected.html(prevHtml);
                prevSelected.removeClass('selected');
            }

            //show the new selected element
            var html = selected.html();
            selected.html('<div class="port_cat_active"><div class="port_cat_l"></div><div class="port_cat">' + html + '</div><div class="port_cat_r"></div> </div>');
            selected.addClass('selected');
        }

        /**
        * Loads the images. When all the images are loaded calls the displayItems 
        * function to display the images.
        */
        function loadImages() {
            var imageCount = items.length;
            for (var i in items) {
                if (items.hasOwnProperty(i)) {
                    var img = new Image();
                    $(img).load(function () {
                        imagesLoaded++;
                        if (imagesLoaded === imageCount) {
                            //all the images are loaded, display them all
                            displayItems();
                        }
                    }).attr('src', items[i].thumbnail);
                }
            }
        }

        /**
        * Displays the portfolio items.
        */
        function displayItems() {
            root
				.html('')
				.animate({ marginLeft: 0 })
				.width(1);
            pageWrappers = [];

            var itemCount = items.length,
				catId = arguments[0],
				$currentEDGmain = null,
				$pageDiv = null,
				itemsDisplayed = 0;

            // Determine the width and height of .EDGmainContainer
            if (rendering.valuesInitialized != true) {
                rendering.valuesInitialized = true;
                items[0].obj.css('visibility', 'hidden');
                root.append(items[0].obj);
                $currentEDGmain = root.find('.EDGmain');

                rendering.itemContainerWidth = options.maxImgWidth + ($currentEDGmain.outerWidth(true) - $currentEDGmain.find('img').width());
                rendering.itemContainerHeight = options.maxImgHeight + ($currentEDGmain.outerHeight(true) - $currentEDGmain.find('img').height());

                rendering.itemTopSpace = parseInt($currentEDGmain.css('borderTopWidth')) + parseInt($currentEDGmain.css('paddingTop')) + parseInt($currentEDGmain.css('marginTop'));
                rendering.itemLeftSpace = parseInt($currentEDGmain.css('borderLeftWidth')) + parseInt($currentEDGmain.css('paddingLeft')) + parseInt($currentEDGmain.css('marginLeft'));

                $currentEDGmain = null;
                root.html('');
                items[0].obj.css('visibility', '');

                // Calculate the rendering vars
                rendering.maxItemsPerRow = Math.floor(options.containerWidth / rendering.itemContainerWidth + 0.05);
                rendering.pageWidth = rendering.maxItemsPerRow * rendering.itemContainerWidth;

                if (!options.containerHeight) {
                    if (!options.itemsPerPage) {
                        options.containerHeight = 410;
                    } else {
                        options.containerHeight = Math.ceil(options.itemsPerPage / rendering.maxItemsPerRow) * rendering.itemContainerHeight;
                        root.height(options.containerHeight);
                    }
                }

                rendering.maxRowCount = Math.floor(options.containerHeight / rendering.itemContainerHeight + 0.15);
                rendering.itemsPerPage = options.itemsPerPage == 0 ? rendering.maxRowCount * rendering.maxItemsPerRow : options.itemsPerPage;
                rendering.pageHeight = rendering.maxRowCount * rendering.itemContainerHeight;
            }

            if (options.fullscreenMode) {
                if (rendering.pageWidth < options.containerWidth) {
                    rendering.pageWidth = options.containerWidth;
                }
            } else {
                if (options.spaceOutPage && rendering.pageWidth < options.containerWidth) {
                    rendering.pageRightPadding = options.containerWidth - rendering.pageWidth;
                }
            }

            for (var i = 0; i < itemCount; i++) {
                if (catId == undefined || (catId && items[i].category.contains(catId))) {
                    if (itemsDisplayed % rendering.itemsPerPage === 0) {
                        $pageDiv = $('<div />').css({ float: 'left', overflow: 'hidden', width: rendering.pageWidth, height: rendering.pageHeight, display: 'none', paddingRight: rendering.pageRightPadding });
                        pageWrappers.push($pageDiv);
                        root.width(root.width() + rendering.pageWidth + rendering.pageRightPadding);
                        root.append($pageDiv);

                        $pageDiv.fadeIn().animate({ opacity: 1 }, 0);

                        if (options.fullscreenMode && options.spaceOutPage) {
                            $pageDiv = $('<div />').css({ margin: 'auto', overflow: 'hidden', width: (rendering.maxItemsPerRow * rendering.itemContainerWidth) });
                            pageWrappers[pageWrappers.length - 1].append($pageDiv);
                        }
                    }

                    if (ie) {
                        items[i].obj = generateItemObject(items[i].data);
                        $pageDiv.append(items[i].obj);
                    } else {
                        $pageDiv.append(items[i].obj);
                    }

                    items[i].obj
						.width(rendering.itemContainerWidth)
						.height(rendering.itemContainerHeight);

                    itemsDisplayed++;

                    if (!options.smartResize) {
                        $currentEDGmain = items[i].obj.children('.EDGmain');

                        if (rendering.itemContainerHeight - $currentEDGmain.outerHeight(true) > 1) {
                            $currentEDGmain.css({
                                position: 'relative',
                                top: '50%',
                                marginTop: -Math.floor($currentEDGmain.find('img').height() / 2)
                            });
                        }
                        if (rendering.itemContainerWidth - $currentEDGmain.outerWidth(true) > 1) {
                            $currentEDGmain.css({
                                position: 'relative',
                                left: '50%',
                                marginLeft: -Math.floor($currentEDGmain.find('img').width() / 2)
                            });
                        }
                    }
                }
            }
            root.width(root.width() - 1);

            rendering.pageCount = pageWrappers.length;

            //call the lightbox plugin
            $(document).ready(function () {

                //				if (options.pfOpenMediaUrl == 'False') 
                //				{
                $('a[rel="PortPhoto[' + options.ppgroup + ']"]').prettyPhoto({
                    animationSpeed: 'options.ppanimationSpeed',
                    slideshow: options.ppslideshow,
                    overlay_gallery: options.ppoverlay_gallery,
                    autoplay_slideshow: options.ppautoplay_slideshow,
                    hideflash: false,
                    showTitle: true,
                    theme: options.pptheme
                });
                // }
                if (options.pfShowQtip == 'True') {
                    $('#' + options.pfdiv + ' .EDGcontent a[title]').each(function () {
                        if ($(this).attr("title").length > 0) {
                            $(this).qtip({
                                show: { effect: { type: options.pfShowEffect, length: options.pfShowDuration} },
                                hide: { effect: { type: options.pfHideEffect, length: options.pfHideDuration} },
                                position: { corner: { target: options.pfTargetPos, tooltip: options.pfTooltipPos} },
                                style: { name: options.pfTheme, tip: true, border: { width: options.pfcorner, radius: options.pfradius} }
                            });
                        }
                    });
                }
                else {
                    $('#' + options.pfdiv + ' .EDGcontent a[title]').each(function () {
                        if ($(this).attr("title").length > 0) {
                            $(this).attr("title", "");
                        }
                    });
                }

            });

            //show the navigation buttons
            showNavigation();
            setHoverFunctionality();
        }


        /**
        * Displays the navigation buttons.
        */
        function showNavigation() {
            //reset the divs and arrays
            var navUl = root.siblings('#' + options.navigationId).find('ul'),
				paginationArrows;

            navUl.html('');

            rootGrandparent.children('div.portfolio_navigation_arrows_container').remove();

            if (rendering.pageCount > 1) {

                for (var i = 0; i < rendering.pageCount; i++) {
                    navUl.append('<li></li>');
                }

                navUl.delegate('li', 'click', function () {
                    moveItemContainer($(this).index());
                });

                navUl.find('li:first').addClass('selected');

                // Show navigation arrows
                if (options.showNavigationArrows) {
                    rootParent.after('<div class="portfolio_navigation_arrows_container"><a href="#" class="portfolio_paggination_arrow left"></a><a href="#" class="portfolio_paggination_arrow right"></a></div>');
                    $navigationArrowLeft = rootGrandparent.find('div.portfolio_navigation_arrows_container > a.portfolio_paggination_arrow.left');
                    $navigationArrowRight = rootGrandparent.find('div.portfolio_navigation_arrows_container > a.portfolio_paggination_arrow.right');

                    if (options.navArrowsFile) {
                        $navigationArrowLeft.css('background-image', 'url("' + options.navArrowsFile + '")');
                        $navigationArrowRight.css('background-image', 'url("' + options.navArrowsFile + '")');
                    }

                    if (options.hidableNavigationArrows) {
                        $navigationArrowLeft.hide();
                        $navigationArrowRight.hide();
                        rootGrandparent
							.mouseenter(function () {
							    var selectedPage = navUl.find('li.selected').index(),
									totalPages = navUl.children().length;

							    if (!options.hideNavigationArrowsOnEnds || (options.hideNavigationArrowsOnEnds && selectedPage != 0)) {
							        $navigationArrowLeft.fadeIn(250);
							    }
							    if (!options.hideNavigationArrowsOnEnds || (options.hideNavigationArrowsOnEnds && selectedPage != totalPages - 1)) {
							        $navigationArrowRight.fadeIn(250);
							    }
							})
							.mouseleave(function () {
							    var selectedPage = navUl.find('li.selected').index(),
									totalPages = navUl.children().length;

							    if (!options.hideNavigationArrowsOnEnds || (options.hideNavigationArrowsOnEnds && selectedPage != 0)) {
							        $navigationArrowLeft.stop(false, true).fadeOut(250);
							    }
							    if (!options.hideNavigationArrowsOnEnds || (options.hideNavigationArrowsOnEnds && selectedPage != totalPages - 1)) {
							        $navigationArrowRight.stop(false, true).fadeOut(250);
							    }
							})
							.mousemove(function () {
							    $(this).unbind('mousemove');
							    $navigationArrowRight.fadeIn(250);
							});
                    }

                    if (options.hideNavigationArrowsOnEnds) {
                        $navigationArrowLeft.hide();
                    }

                    var arrowsTopValue = -(Math.round(options.containerHeight / 2) + 63);
                    $navigationArrowLeft.css('top', arrowsTopValue);
                    $navigationArrowRight.css('top', arrowsTopValue);

                    if (options.fullscreenMode) {
                        $navigationArrowLeft.css('left', -10);
                        $navigationArrowRight.css('right', -10);
                    }

                    $navigationArrowLeft.click(function () {
                        moveToPrev();

                        return false;
                    });

                    $navigationArrowRight.click(function () {
                        moveToNext();

                        return false;
                    });
                }

                centerNavigation();
            }
        }

        function centerNavigation() {
            var navUl = root.siblings('#' + options.navigationId).find('ul');

            navUl.css({ marginLeft: (options.containerWidth / 2 - rendering.pageCount * options.navButtonWidth / 2) });
        }

        function moveToPrev() {
            var navUl = $('#' + options.navigationId).find('ul'),
				currentPageIndex = navUl.children('li.selected').index();

            moveItemContainer(currentPageIndex - 1);
        }

        function moveToNext() {
            var navUl = $('#' + options.navigationId).find('ul'),
				currentPageIndex = navUl.children('li.selected').index();

            moveItemContainer(currentPageIndex + 1);
        }

        function moveItemContainer(i) {
            var navUl = root.siblings('#' + options.navigationId).find('ul'),
				totalPages = navUl.children().length,
				currentPageIndex = navUl.children('li.selected').index(),
				marginLeft;

            if (i < 0 || i > totalPages - 1) {
                return false;
            }

            if (options.showNavigationArrows && options.hideNavigationArrowsOnEnds) {
                if (i == 0) {
                    $navigationArrowLeft.stop(false, true).fadeOut(250);
                }
                if (i != 0) {
                    $navigationArrowLeft.fadeIn(250);
                }

                if (i == totalPages - 1) {
                    $navigationArrowRight.stop(false, true).fadeOut(250);
                }
                if (i != totalPages - 1) {
                    $navigationArrowRight.fadeIn(250);
                }
            }

            marginLeft = i * (rendering.pageWidth + rendering.pageRightPadding);

            root.stop(true, false).animate({ marginLeft: [-marginLeft, options.easing] }, options.animationSpeed);

            navUl.find('li.selected').removeClass('selected');
            navUl.children().eq(i).addClass('selected');
        }

        function setHoverFunctionality() {
            $('.portfolio_item').hover(function () {
                $(this).stop().animate({ opacity: 0.8 }, 300);
            }, function () {
                $(this).stop().animate({ opacity: 1 }, 300);
            });
        }

        function generateItemObject(itemData) {
            return $('<div class="EDGmainContainer"><div class="EDGmain"><div class="' + itemData.itemClass + '"><a rel="' + itemData.relTag + '[' + itemData.ppgroup + ']" href="' + itemData.prev + '" title="' + itemData.imgdesc + '" pptitle="' + itemData.imgdesc + '" target="' + itemData.medTarget + '"><img alt="' + itemData.imgalt + '" src="' + itemData.thum + '" /> <span class="flagObject"></span><span class="flag"></span><span class="leftsh"></span><span class="rightsh"></span><span class="botsh"></span><span class="topsh"></span><span class="round1"></span><span class="round2"></span><span class="round3"></span><span class="round4"></span><span class="' + itemData.cssClass + '"><span style="display:block">' + itemData.imgtitle + '</span><span class="Description">' + itemData.desc + '</span></span></a></div></div></div>');
        }
    };
} (jQuery));


Array.prototype.contains = function (value) {
    var length = this.length;
    for (var i = 0; i < length; i++) {
        if (this[i] === value) {
            return true;
        }
    }
    return false;
};


(function ($) {
    $.fn.fullscreenPortfolioGallery = function (rootId) {
        var $window = $(window), $body = $('body'), $rootObject,
			$fullscreenContainer, $fullscreenWrapper, $fullscreenMain,
			fullscreenWrapperResizeTimer, fullscreen_options,
			$fullscreen_close_btn;

        if (typeof rootId == 'string') {
            $rootObject = $('#' + rootId);
            fullscreen_options = $.extend(true, {}, $rootObject.data('EasyDNNGallery.portfolio.options'));
        } else if (typeof rootId == 'object') {
            fullscreen_options = rootId;
        }

        $fullscreenContainer = $('<div class="portfolio_gallery_fullscreen_container" id="' + fullscreen_options.fullscreenCssId + '"></div>');

        $fullscreenContainer
			.css('top', $window.scrollTop());

        $body
			.append($fullscreenContainer)
			.css({ overflow: 'hidden' });

        $fullscreenWrapper = $('<div class="portfolio_gallery_fullscreen_wrapper"></div>');
        $fullscreenContainer
			.append($fullscreenWrapper);

        $fullscreenWrapper
			.bind('reposition', function () {
			    positionFullscreenWrapper();
			    positionFullscreenCloseBtn();
			    $fullscreenMain.trigger('resize_gallery');
			});

        $fullscreenMain = $('<div class="portfolio_gallery_fullscreen_main"><div style="position: relative;"><div class="portfolio_gallery_fullscreen_inner"></div></div></div>');
        $fullscreenWrapper.append($fullscreenMain);

        $fullscreenMain.data('initialOuterHeight', $fullscreenMain.outerHeight(true));

        positionFullscreenWrapper();

        $window
			.scroll(function () {
			    $fullscreenContainer.css('top', $window.scrollTop());
			})
			.resize(function () {
			    clearTimeout(fullscreenWrapperResizeTimer);
			    fullscreenWrapperResizeTimer = setTimeout(function () {
			        $fullscreenWrapper.trigger('reposition');
			    }, 50);
			});

        $(document).bind('keydown.EasyDNNGallery_fullscreen', function (e) {
            var $lightboxOverlay = $('body > .pp_overlay');

            if ($lightboxOverlay.length == 0) {
                switch (e.keyCode) {
                    case 27:
                        destroyFullscreenWindow();
                        break;

                    case 39:
                        $fullscreenMain.trigger('toNextPage');
                        break;


                    case 37:
                        $fullscreenMain.trigger('toPrevPage');
                        break;

                    default:
                }
            }
        });

        var fullscreen_options = $.extend(fullscreen_options, {
            containerWidth: $fullscreenMain.width(),
            containerHeight: $fullscreenWrapper.height() - $fullscreenMain.data('initialOuterHeight'),
            fullscreenMode: true,
            fullscreenable: false,
            itemsPerPage: 0,
            spaceOutPage: true,
            scrollableContent: true,
            hideNavigationArrowsOnEnds: true
        });

        fullscreen_options.containerHeight -= fullscreen_options.categorySelector == 'classic' ? (fullscreen_options.customTitle ? 135 : 107) : 70;

        $fullscreenMain.find('div.portfolio_gallery_fullscreen_inner').portfolioSetter(fullscreen_options);

        $fullscreenMain
			.delegate('.closeFullscreenBtn', 'click', function () {
			    destroyFullscreenWindow();

			    return false;
			})
			.bind('fullscreen_close_btn_initialized', function () {
			    $fullscreen_close_btn = $fullscreenMain.find('.closeFullscreenBtn');
			    positionFullscreenCloseBtn();
			});

        function positionFullscreenWrapper() {
            $fullscreenWrapper
				.width($window.width() - 8 - parseInt($fullscreenWrapper.css('border-left-width'), 10) - parseInt($fullscreenWrapper.css('border-right-width'), 10))
				.height($window.height() - 8 - parseInt($fullscreenWrapper.css('border-top-width'), 10) - parseInt($fullscreenWrapper.css('border-bottom-width'), 10))
				.css('top', Math.round(($window.height() - $fullscreenWrapper.outerHeight()) / 2));
        }

        function positionFullscreenCloseBtn() {
            $fullscreen_close_btn
				.css('left', ($window.width() - 45 - parseInt($fullscreenWrapper.css('border-left-width'), 10) * 2 - parseInt($fullscreenWrapper.css('border-right-width'), 10) * 2));
        }

        function destroyFullscreenWindow() {
            $(document).unbind('keydown.EasyDNNGallery_fullscreen');
            $body.css({ overflow: '' });
            $fullscreenContainer
				.fadeOut(200, function () {
				    $fullscreenContainer.remove();
				});
        }
    };
} (jQuery));
