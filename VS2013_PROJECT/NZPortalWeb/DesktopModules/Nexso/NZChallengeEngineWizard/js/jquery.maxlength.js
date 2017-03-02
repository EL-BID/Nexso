var languages = [];

languages['en-US'] = {
    // Default regional settings
    feedbackText: '{c} words remaining ({m} limit)',
    // Display text for feedback message, use {r} for remaining characters,
    // {c} for characters entered, {m} for maximum
    overflowText: '{o} words too many ({m} limit)',
    // Display text when past maximum, use substitutions above
    // and {o} for characters past maximum
    globalCounterText: 'Word count:<br /><span class="no">{p}</span> <em>of</em> <span class="no">500</span>'
};

languages['es-ES'] = {
    // Default regional settings
    feedbackText: '{c} palabras disponibles de {m}',
    // Display text for feedback message, use {r} for remaining characters,
    // {c} for characters entered, {m} for maximum
    overflowText: '{o} supero el límite ({m} máximo)',
    // Display text when past maximum, use substitutions above
    // and {o} for characters past maximum
    globalCounterText: 'Contador de palabras:<br /><span class="no">{p}</span> <em>de</em> <span class="no">500</span>'
};

languages['pt-BR'] = {
    // Default regional settings
    feedbackText: '{c} palavras disponíveis {m}',
    // Display text for feedback message, use {r} for remaining characters,
    // {c} for characters entered, {m} for maximum
    overflowText: '{o} excedido o limite ({m} máximo)',
    // Display text when past maximum, use substitutions above
    // and {o} for characters past maximum
    globalCounterText: 'Contagem de palavras:<br /><span class="no">{p}</span> <em>de</em> <span class="no">500</span>'
};

var globalCounterMax = new Number;
var globalCounterAbsolute = new Number;
var globalCounterRelative = new Number;
var globalCounters = [];

var regex = /\b[\s\.,:;-]+\b/mi;

function countGlobal(template) {
    globalCounterRelative = 0;
    for (var ii = 0; ii < globalCounters.length; ii++) {
        globalCounterRelative = globalCounterRelative + globalCounters[ii];
    }

    $('.GlobalCounterContainer').html(template.replace(/\{p\}/, globalCounterAbsolute + globalCounterRelative).replace(/\{m\}/, globalCounterMax));
}

function adjustGlobalCounter(value) {
    if (value != 0) {
        globalCounterAbsolute = value;
        globalCounters = [];
    }
}

/* http://keith-wood.name/maxlength.html
   Textarea Max Length for jQuery v1.1.0.
   Written by Keith Wood (kwood{at}iinet.com.au) May 2009.
   Dual licensed under the GPL (http://dev.jquery.com/browser/trunk/jquery/GPL-LICENSE.txt) and 
   MIT (http://dev.jquery.com/browser/trunk/jquery/MIT-LICENSE.txt) licenses. 
   Please attribute the author if you use it. */

(function ($) { // Hide scope, no $ conflict

    /* Max length manager. */
    function MaxLength() {
        this.regional = []; // Available regional settings, indexed by language code
        this.regional[''] = { // Default regional settings
            feedbackText: '{r} words remaining ({m} limit)',
            // Display text for feedback message, use {r} for remaining characters,
            // {c} for characters entered, {m} for maximum
            overflowText: '{o} words too many ({m} limit)',
            // Display text when past maximum, use substitutions above
            // and {o} for characters past maximum
            globalCounterText: 'Word count:<br /><span class="no">{p}</span> <em>of</em> <span class="no">500</span>'
        };
        this._defaults = {
            max: 200, // Maximum length
            truncate: true, // True to disallow further input, false to highlight only
            showFeedback: true, // True to always show user feedback, 'active' for hover/focus only
            feedbackTarget: null, // jQuery selector or function for element to fill with feedback
            onFull: null, // Callback when full or overflowing,
            // receives one parameter: true if overflowing, false if not
            counterType:'character',
            internalId:null
        };
        $.extend(this._defaults, this.regional['']);
    }

    $.extend(MaxLength.prototype, {
        /* Class name added to elements to indicate already configured with max length. */
        markerClassName: 'hasMaxLength',
        /* Name of the data property for instance settings. */
        propertyName: 'maxlength',

        /* Class name for the feedback section. */
        _feedbackClass: 'maxlength-feedback',
        /* Class name for indicating the textarea is full. */
        _fullClass: 'maxlength-full',
        /* Class name for indicating the textarea is overflowing. */
        _overflowClass: 'maxlength-overflow',
        /* Class name for indicating the textarea is disabled. */
        _disabledClass: 'maxlength-disabled',

        /* Override the default settings for all max length instances.
        @param  options  (object) the new settings to use as defaults
        @return  (MaxLength) this object */
        setDefaults: function (options) {

            $.extend(this._defaults, options || {});
            return this;
        },

        /* Attach the max length functionality to a textarea.
        @param  target   (element) the control to affect
        @param  options  (object) the custom options for this instance */
        _attachPlugin: function (target, options) {
            target = $(target);


            if (target.hasClass(this.markerClassName)) {
                return;
            }
            globalCounters.push(0);

            var inst = { options: $.extend({}, this._defaults), feedbackTarget: $([]), internalId:globalCounters.length-1 };

            globalCounterMax = globalCounterMax + inst.options.max;

            target.addClass(this.markerClassName).
			data(this.propertyName, inst).
			bind('keypress.' + this.propertyName, function (event) {
			    if (!inst.options.truncate) {
			        return true;
			    }
			    var ch = String.fromCharCode(
					event.charCode == undefined ? event.keyCode : event.charCode);
			    if (inst.options.counterType == 'character') {
			        return (event.ctrlKey || event.metaKey || ch == '\u0000' ||
			            $(this).val().length < inst.options.max);
			    } else if (inst.options.counterType =='word') {
			        return (event.ctrlKey || event.metaKey || ch == '\u0000' ||
			            ($(this).val().split(regex).length-1) < inst.options.max);

			    } else {
			        return true;
			    }
			})
                .bind('keyup.' + this.propertyName, function (e) {plugin._checkLength($(this));})
                .bind('paste.' + this.propertyName, function (e) {
                    var self = this;
                    setTimeout(function() {
                        plugin._checkLength($(self));
                    }, 100);
                }); // set new event paste, delay call checkLength, the data is not in the element yet.
            this._optionPlugin(target, options);

        },

        /* Retrieve or reconfigure the settings for a control.
        @param  target   (element) the control to affect
        @param  options  (object) the new options for this instance or
        (string) an individual property name
        @param  value    (any) the individual property value (omit if options
        is an object or to retrieve the value of a setting)
        @return  (any) if retrieving a value */
        _optionPlugin: function(target, options, value) {
            target = $(target);
            var inst = target.data(this.propertyName);
            if (!options || (typeof options == 'string' && value == null)) { // Get option
                var name = options;
                options = (inst || {}).options;
                return (options && name ? options[name] : options);
            }

            if (!target.hasClass(this.markerClassName)) {
                return;
            }
            options = options || {};
            if (typeof options == 'string') {
                var name = options;
                options = {};
                options[name] = value;
            }
            $.extend(inst.options, options);
            if (inst.feedbackTarget.length > 0) { // Remove old feedback element
                if (inst.hadFeedbackTarget) {
                    inst.feedbackTarget.empty().val('').
                        removeClass(this._feedbackClass + ' ' + this._fullClass + ' ' + this._overflowClass);
                } else {
                    inst.feedbackTarget.remove();
                }
                inst.feedbackTarget = $([]);
            }
            if (inst.options.showFeedback) { // Add new feedback element
                inst.hadFeedbackTarget = !!inst.options.feedbackTarget;
                if ($.isFunction(inst.options.feedbackTarget)) {
                    inst.feedbackTarget = inst.options.feedbackTarget.apply(target[0], []);
                } else if (inst.options.feedbackTarget) {
                    inst.feedbackTarget = $(inst.options.feedbackTarget);
                } else {
                    inst.feedbackTarget = $('<span></span>').insertAfter(target);
                }
                inst.feedbackTarget.addClass(this._feedbackClass);
            }
            target.unbind('mouseover.' + this.propertyName + ' focus.' + this.propertyName +
                'mouseout.' + this.propertyName + ' blur.' + this.propertyName);
            if (inst.options.showFeedback == 'active') { // Additional event handlers
                target.bind('mouseover.' + this.propertyName, function() {
                    inst.feedbackTarget.css('visibility', 'visible');
                }).bind('mouseout.' + this.propertyName, function() {
                    if (!inst.focussed) {
                        inst.feedbackTarget.css('visibility', 'hidden');
                    }
                }).bind('focus.' + this.propertyName, function() {
                    inst.focussed = true;
                    inst.feedbackTarget.css('visibility', 'visible');
                }).bind('blur.' + this.propertyName, function() {
                    inst.focussed = false;
                    inst.feedbackTarget.css('visibility', 'hidden');
                });
                inst.feedbackTarget.css('visibility', 'hidden');
            }


            if (inst.options.counterType == 'character') {
                globalCounterAbsolute = globalCounterAbsolute - target.val().length;
            } else if (inst.options.counterType == 'word') {
                if(target.val().length!=0)
                    globalCounterAbsolute = globalCounterAbsolute - (target.val().split(regex).length);

            } else {
                globalCounterAbsolute = globalCounterAbsolute - target.val().length;
            }

            this._checkLength(target);
        },

        /* Retrieve the counts of characters used and remaining.
        @param  target  (jQuery) the control to check
        @return  (object) the current counts with attributes used and remaining */
        _curLengthPlugin: function (target) {
            var inst = target.data(this.propertyName);
            var value = target.val();
            var len = 0;
            if (inst.options.counterType == 'character') {
                len= value.replace(/\r\n/g, '~~').replace(/\n/g, '~~').length;
            }
            else if (inst.options.counterType == 'word') {
                if (value.length == 0) {
                    len = value.split(regex).length - 1;
                } else {
                    len = value.split(regex).length;
                }
            } else {
                len= value.replace(/\r\n/g, '~~').replace(/\n/g, '~~').length;
            }


            return { used: len, remaining: inst.options.max - len };
        },

        /* Check the length of the text and notify accordingly.
        @param  target  (jQuery) the control to check */
        _checkLength: function(target) {
            var inst = target.data(this.propertyName);
            var value = target.val();
            var len = 0;
            if (inst.options.counterscounterType == 'character') {
                len = value.replace(/\r\n/g, '~~').replace(/\n/g, '~~').length;
            } else if (inst.options.counterType == 'word') {
                if (value.length == 0) {
                    len = value.split(regex).length - 1;
                } else {
                    len = value.split(regex).length;
                }
            } else {
                len = value.replace(/\r\n/g, '~~').replace(/\n/g, '~~').length;
            }


            target.toggleClass(this._fullClass, len >= inst.options.max).
                toggleClass(this._overflowClass, len > inst.options.max);
            if (len > inst.options.max && inst.options.truncate) { // Truncation

                var lines = '';


                value = '';
                var i = 0;
                if (inst.options.counterscounterType == 'character') {
                    lines = target.val().split(/\r\n|\n/);
                    while (value.length < inst.options.max && i < lines.length) {
                        value += lines[i].substring(0, inst.options.max - value.length) + '\r\n';
                        i++;
                    }
                    target.val(value.substring(0, inst.options.max));
                } else if (inst.options.counterType == 'word') {
                    lines = target.val().split(regex);
                    while (value.split(regex).length-1 < inst.options.max && i < lines.length-1) {
                        value += lines[i] + ' ';
                        i++;
                    }
                    target.val(value);

                } else {
                    lines = target.val().split(/\r\n|\n/);
                    while (value.length < inst.options.max && i < lines.length) {
                        value += lines[i].substring(0, inst.options.max - value.length) + '\r\n';
                        i++;
                    }
                    target.val(value.substring(0, inst.options.max));
                }

                target[0].scrollTop = target[0].scrollHeight; // Scroll to bottom
                len = inst.options.max;
            }


            inst.feedbackTarget.toggleClass(this._fullClass, len >= inst.options.max).
                toggleClass(this._overflowClass, len > inst.options.max);
            var feedback = (len > inst.options.max ? // Feedback
                inst.options.overflowText : inst.options.feedbackText).
                replace(/\{c\}/, len).replace(/\{m\}/, inst.options.max).
                replace(/\{r\}/, inst.options.max - len).
                replace(/\{o\}/, len - inst.options.max);
            try {
                inst.feedbackTarget.text(feedback);
            } catch(e) {
                // Ignore
            }
            try {
                inst.feedbackTarget.val(feedback);
            } catch(e) {
                // Ignore
            }
            if (len >= inst.options.max && $.isFunction(inst.options.onFull)) {
                inst.options.onFull.apply(target, [len > inst.options.max]);
            }

            if (target.val().length != 0) {
                globalCounters[inst.internalId] = len;
            } else {
                globalCounters[inst.internalId] = 0;
            }
            countGlobal(inst.options.globalCounterText);
        },

        /* Enable the control.
        @param  target  (element) the control to affect */
        _enablePlugin: function (target) {
            target = $(target);
            if (!target.hasClass(this.markerClassName)) {
                return;
            }
            target.prop('disabled', false).removeClass(this.propertyName + '-disabled');
            var inst = target.data(this.propertyName);
            inst.feedbackTarget.removeClass(this.propertyName + '-disabled');
        },

        /* Disable the control.
        @param  target  (element) the control to affect */
        _disablePlugin: function (target) {
            target = $(target);
            if (!target.hasClass(this.markerClassName)) {
                return;
            }
            target.prop('disabled', true).addClass(this.propertyName + '-disabled');
            var inst = target.data(this.propertyName);
            inst.feedbackTarget.addClass(this.propertyName + '-disabled');
        },

        /* Remove the plugin functionality from a control.
        @param  target  (element) the control to affect */
        _destroyPlugin: function (target) {
            target = $(target);
            if (!target.hasClass(this.markerClassName)) {
                return;
            }
            var inst = target.data(this.propertyName);
            if (inst.feedbackTarget.length > 0) {
                if (inst.hadFeedbackTarget) {
                    inst.feedbackTarget.empty().val('').css('visibility', 'visible').
					removeClass(this._feedbackClass + ' ' + this._fullClass + ' ' + this._overflowClass);
                }
                else {
                    inst.feedbackTarget.remove();
                }
            }
            target.removeClass(this.markerClassName + ' ' +
				this._fullClass + ' ' + this._overflowClass).
			removeData(this.propertyName).
			unbind('.' + this.propertyName);
        }
    });

    // The list of methods that return values and don't permit chaining
    var getters = ['curLength'];

    /* Determine whether a method is a getter and doesn't permit chaining.
    @param  method     (string, optional) the method to run
    @param  otherArgs  ([], optional) any other arguments for the method
    @return  true if the method is a getter, false if not */
    function isNotChained(method, otherArgs) {
        if (method == 'option' && (otherArgs.length == 0 ||
			(otherArgs.length == 1 && typeof otherArgs[0] == 'string'))) {
            return true;
        }
        return $.inArray(method, getters) > -1;
    }

    /* Attach the max length functionality to a jQuery selection.
    @param  options  (object) the new settings to use for these instances (optional) or
    (string) the method to run (optional)
    @return  (jQuery) for chaining further calls or
    (any) getter value */
    $.fn.maxlength = function (options) {

        var otherArgs = Array.prototype.slice.call(arguments, 1);
        if (isNotChained(options, otherArgs)) {
            return plugin['_' + options + 'Plugin'].apply(plugin, [this[0]].concat(otherArgs));
        }
        return this.each(function () {
            if (typeof options == 'string') {
                if (!plugin['_' + options + 'Plugin']) {
                    throw 'Unknown method: ' + options;
                }
                plugin['_' + options + 'Plugin'].apply(plugin, [this].concat(otherArgs));
            }
            else {
                plugin._attachPlugin(this, options || {});
            }
        });
    };

    /* Initialise the max length functionality. */
    var plugin = $.maxlength = new MaxLength(); // Singleton instance

})(jQuery);
