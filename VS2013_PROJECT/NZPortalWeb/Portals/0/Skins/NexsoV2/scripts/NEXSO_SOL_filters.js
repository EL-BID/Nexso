(function ($) {
    $.fn.activate = function () {
        this.filter('.filter').each(function () {
            $(this).addClass('on');
        });
        return this;
    };
    $.fn.activateToggle = function () {
        this.filter('.filter').each(function () {
            $(this).toggleClass('on');
        });
        return this;
    };
    $.fn.deactivate = function () {
        this.filter('.filter').each(function () {
            $(this).removeClass('on');
        });
        return this;
    };
    $.fn.isActive = function () {
        return this.hasClass('on');
    };
    $.fn.getFilterId = function () {
        return this.attr('data-filter-id');
    };
    $.fn.getByFilterId = function (id) {
        return this.filter('[data-filter-id="' + id + '"]');
    };
    $.fn.getActive = function () {
        return this.filter('.filter.on');
    };
})(jQuery);

/**
 * Static object to setup filters.
 */
var SOL_filters = {
    // Default settings.
    settings: {
        cb_click_themes: function () { },
        cb_click_beneficiaries: function () { },
        cb_initialize: function () { },
    },

    // Store the themes filters
    themes: [],
    // Store beneficiaries filters
    beneficiaries: [],

    deliveryFormat: [],
    /**
     * Init function.
     */
    init: function (options) {
        // Extend settings
        SOL_filters.settings = $.extend({}, SOL_filters.settings, options);

        // Get themes filters
        SOL_filters.themes = $('[data-filter-type="themes"]');
        // Get beneficiaries filters
        SOL_filters.beneficiaries = $('[data-filter-type="beneficiaries"]');
        // Get delivery format filters
        SOL_filters.deliveryFormat = $('[data-filter-type="deliveryFormat"]');

        // Click listeners to activate. Using delegation.
        $('#browse .actions').on('click', '.filter[data-filter-type="themes"]', function (e) {
            e.preventDefault();
            $(this).activateToggle();

            SOL_filters.settings.cb_click_themes.apply(this);
        });

        $('#browse .actions').on('click', '.filter[data-filter-type="beneficiaries"]', function (e) {
            e.preventDefault();
            $(this).activateToggle();

            SOL_filters.settings.cb_click_beneficiaries.apply(this);
        });

        $('#browse .actions').on('click', '.filter[data-filter-type="deliveryFormat"]', function (e) {
            e.preventDefault();
            $(this).activateToggle();

            SOL_filters.settings.cb_click_beneficiaries.apply(this);
        });

        SOL_filters.settings.cb_initialize();
    },

    /**
     * Returns the active filters of the given type in an array.
     * Only returns the filter id
     * @param string type
     *   Filter type.
     * @return array
     *   Filter id
     */
    get_active: function (type) {
        // Empty jQuery object to start with.
        var active = [];
        switch (type) {
            case 'themes':
                SOL_filters.themes.getActive().each(function () {
                    active.push($(this).getFilterId());
                });
                break;
            case 'beneficiaries':
                SOL_filters.beneficiaries.getActive().each(function () {
                    active.push($(this).getFilterId());
                });
                break;
            case 'deliveryFormat':
                SOL_filters.deliveryFormat.getActive().each(function () {
                    active.push($(this).getFilterId());
                });
                break;
        }
        return active;
    },

};