$(function () {
    /**************************************************************/
    /*          ---  DO NOT ALTER PAST THIS POINT  ---            */
    /**************************************************************/

    if ($('#browse').length === 0) {
        return;
    }

    var settings = {
        api: {
            solutions: '/DesktopModules/NexsoServices/API/Nexso/GetSolutions',
            categories: '/DesktopModules/NexsoServices/API/Nexso/GetListCategory'
        },
        base_path: window.location.protocol+"//"+window.location.host,
        language: $('input[name="CurrentLanguage"]').val() ? $('input[name="CurrentLanguage"]').val() : 'en-US',
        uid: getQuery('ui') !== false ? $('input[name="CurrentUserId"]').val() : -1,
    };

    // Handlebars helper for translations.
    Handlebars.registerHelper('i18n', function (txt) {
        if (typeof i18n[txt] != 'undefined') {
            if (typeof i18n[txt][settings.language] != 'undefined') {
                return i18n[txt][settings.language];
            }
        }
        return txt;
    });

    // Handlebars helper to capitalise.
    Handlebars.registerHelper('ucfirst', function (txt) {
        txt = txt.toLowerCase();
        return txt.charAt(0).toUpperCase() + txt.slice(1);
    });

    // Handlebars helper to check if solution is draft
    Handlebars.registerHelper('is_draft', function (status, options) {
        if (status < 800) {
            return options.fn(this);
        }
        else {
            return options.inverse(this);
        }
    });

    // Request needed resources.
    async.waterfall([
      function (callback) {
          // Get the categories.
          $.get(settings.api.categories, {
              'Category': 'Theme',
              'Language': settings.language

          }, function (data) {
              // For some reason the result is encoded twice.
              data = JSON.parse(data);
              callback(null, data);

          }, 'json').fail(function () {
              callback(true, null);
          });

      },

      function (themes, callback) {
          // Get the beneficiaries.
          $.get(settings.api.categories, {
              'Category': 'Beneficiaries',
              'Language': settings.language

          }, function (data) {
              // For some reason the result is encoded twice.
              data = JSON.parse(data);
              callback(null, themes, data);

          }, 'json').fail(function () {
              callback(true, null);
          });
      },

      function (themes,beneficiaries, callback) {
          // Get the beneficiaries.
          $.get(settings.api.categories, {
              'Category': 'DeliveryFormat',
              'Language': settings.language

          }, function (data) {
              // For some reason the result is encoded twice.
              data = JSON.parse(data);
              callback(null, themes,beneficiaries, data);

          }, 'json').fail(function () {
              callback(true, null);
          });
      },

      function (themes, beneficiaries, deliveryFormat, callback) {
          // Render the part of the template that will not change.
          var source = $('#tpl-browse').html();
          var template = Handlebars.compile(source);

          var rendered = template({
              'themes': themes,
              'beneficiaries': beneficiaries,
              'deliveryFormat': deliveryFormat
          });

          $('#browse').html(rendered);

          // Render 3 solution placeholders.
          // This doesn't have any handlebars tags.
          // Save resources by not compiling it.
          var ph_source = $('#tpl-solution-placeholder').html();
          for (var i = 0; i < 3; i++) {
              $('.solution-grid').append(ph_source);
          }

          callback(null, 'done');
      }

    ], function (err) {

        if (err)
            return;

        // Initialise the filter system.
        SOL_filters.init();

        // Render function for handlebars template.
        var Renderer = function () {
            var _self = this;

            this.page_size = 12;
            this.current_page = 1;

            var source = $("#tpl-solution").html();
            this.template = Handlebars.compile(source);

            this.content_holder = $('#browse .solution-grid');

            this.load_more_button = $('#show-more-trigger').click(function (e) {
                e.preventDefault();
                var $self = $(this);

                if (!$self.hasClass('disabled')) {
                    // Show more elements.
                    _self.render_next();
                }

            });

            this.render = function (invalidate) {
                invalidate = typeof invalidate == 'undefined';
                var _self = this;
                // If invalidate is true means that the present data is not valid anymore
                // and it's to be replaced by new one.
                // This will add the placeholders.
                if (invalidate) {
                    _self.reset();
                }

                $('#loading').addClass('on');
                this.request_solutions(function (data) {
                    $('#loading').removeClass('on');

                    // If invalidate is true, placeholders were added.
                    // Clean before appending new data.
                    if (invalidate) {
                        _self.content_holder.html('');
                    }

                    if (data.length) {
                        var html = _self.template({ "solutions": data, "curr_lang": settings.language, "base_path": settings.base_path });
                        _self.content_holder.append(html);
                    }
                    else {
                        _self.load_more_button.addClass('disabled');
                    }
                });
            };

            this.reset = function () {
                this.current_page = 1;
                this.load_more_button.removeClass('disabled');
                this.content_holder.html('');
                // Render 3 solution placeholders.
                // This doesn't have any handlebars tags.
                // Save resources by not compiling it.
                var ph_source = $('#tpl-solution-placeholder').html();
                for (var i = 0; i < 3; i++) {
                    this.content_holder.append(ph_source);
                }
            };

            this.render_next = function () {
                this.current_page++;
                this.render(false);
            };

            this.request_solutions = function (callback) {
                var _self = this;
                var search_ = getQuery("search");
                if (search_ ==!1)
                    search_ = '';
                $.get(settings.api.solutions, {
                    'language': settings.language,
                    'rows': _self.page_size,
                    'page': _self.current_page,
                    'min': 0,
                    'max': 0,
                    'state': getQuery("ui") == !1 ? 1000:0,
                    'categories': JSON.stringify(SOL_filters.get_active('themes')),
                    'beneficiaries': JSON.stringify(SOL_filters.get_active('beneficiaries')),
                    'deliveryFormat': JSON.stringify(SOL_filters.get_active('deliveryFormat')),
                    'userId': settings.uid,
                    'search': search_ ,
                    contentType: "application/json; charset=utf-8",
                }, function (data) {
                    // For some reason the result is encoded twice.
                    data = JSON.parse(data);
                    callback(data);

                }, 'json');
            };

        };

        var renderer = new Renderer();
        renderer.render();

        // Now that the rendering is done, add click listeners.
        // Add dropdown behaviour to menus.
        $('.filters-toggle').click(function (event) {
            event.stopPropagation();
            event.preventDefault();
            var $links = $(this).siblings('.drop2');
            $('.drop2').not($links).hide();
            if ($links.is(':hidden')) {
                console.log('show');
                $links.show();
            } else {
                console.log('hide');
                $links.hide();
            }
        });

        $(document).click(function (e) {
            // If the click didn't originate on drop then hide.
            if ($(e.target).closest('.drop2').length === 0) {
                $('.drop2').hide();
            }
        });

        // Apply filters.
        $('.filters-apply').click(function (e) {
            e.preventDefault();

            // Hide filters after applying
            $('.drop2').hide();

            renderer.render();
        });
    });
});

/**
 * Returns the value of the key in the querystring.
 * @param string key
 */
function getQuery(a) {
    var b = location.pathname.split("/");

    for (var i = 0; i < b.length; i++) {
        if (b[i] == a) {
            if (b[i + 1] != null)
                return decodeURIComponent(b[i + 1]);
            else
                return !1;
        }



    }
    return !1;

}