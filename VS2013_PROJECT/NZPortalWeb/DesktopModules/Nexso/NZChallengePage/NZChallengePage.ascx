<%@ Control Language="C#" AutoEventWireup="true" CodeFile="NZChallengePage.ascx.cs" Inherits="NZChallengePage" %>
<%@ Register TagPrefix="dnn" Assembly="DotNetNuke" Namespace="DotNetNuke.UI.WebControls" %>


<asp:HiddenField ID="hfJsonContext" runat="server" />

<asp:Literal ID="litContent" runat="server"></asp:Literal>

<div id="textInclude"></div>
<script type="text/javascript">
    var dataJson = "";
    $(document).ready(function () {
        execCode();
        execCodeLatestSolutions();
    }
        );
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);

    function EndRequestHandler(sender, args) {

        execCode();
        execCodeLatestSolutions();


    }
    function execCode() {

        Handlebars.registerHelper('compare', function (lvalue, operator, rvalue, options) {

            var operators, result;

            if (arguments.length < 3) {
                throw new Error("Handlerbars Helper 'compare' needs 2 parameters");
            }

            if (options === undefined) {
                options = rvalue;
                rvalue = operator;
                operator = "===";
            }

            operators = {
                '==': function (l, r) { return l == r; },
                '===': function (l, r) { return l === r; },
                '!=': function (l, r) { return l != r; },
                '!==': function (l, r) { return l !== r; },
                '<': function (l, r) { return l < r; },
                '>': function (l, r) { return l > r; },
                '<=': function (l, r) { return l <= r; },
                '>=': function (l, r) { return l >= r; },
                'typeof': function (l, r) { return typeof l == r; }
            };

            if (!operators[operator]) {
                throw new Error("Handlerbars Helper 'compare' doesn't know the operator " + operator);
            }

            result = operators[operator](lvalue, rvalue);

            if (result) {
                return options.fn(this);
            } else {
                return options.inverse(this);
            }

        });

        //records NextURL in JSON
        Handlebars.registerHelper('nextUrl', function (options) {
            var currentIndex = parseInt(options.fn(this));
            if (options.fn(this) < dataJson.PagesContext.length - 1)
                return dataJson.PagesContext[currentIndex + 1].Url;
            return dataJson.PagesContext[0].Url;;
        });

        //records BackURL in JSON
        Handlebars.registerHelper('backUrl', function (options) {
            var currentIndex = parseInt(options.fn(this));
            if (options.fn(this) > 0)
                return dataJson.PagesContext[currentIndex - 1].Url;
            return "";
        });

        //It allows use conditional if
        Handlebars.registerHelper('ifCond', function (v1, v2, options) {
            if (v1 === v2) {
                return options.fn(this);
            }
            return options.inverse(this);
        });

        dataJson = $('#<%=hfJsonContext.ClientID%>').val();
        dataJson = JSON.parse(dataJson);
        var template = document.getElementById("challengePage").innerHTML;

        //Compila el template usando el método compile.
        var templateCompile = Handlebars.compile(template);

        //Inyecta la información en el template compilado y realizar los reemplazos.
        var result = templateCompile(dataJson);
        document.getElementById("textInclude").insertAdjacentHTML("afterend", result);
        $('#textInclude').remove();

    }

    function execCodeLatestSolutions() {
        /**************************************************************/
        /*          ---  DO NOT ALTER PAST THIS POINT  ---            */
        /**************************************************************/

        if ($('#latest_solutions').length === 0) {
            return;
        }

        var settings = {
            api: {
                solutions: '/DesktopModules/NexsoServices/API/Nexso/GetSolutions'
            },
            base_path: window.location.protocol+'//'+window.location.host,
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


        var source = $('#tpl-latest-solutions').html();
        var template = Handlebars.compile(source);
        $('#latest_solutions').append(template);

        // Render function for handlebars template.
        var Renderer_avina = function () {
            var _self = this;

            this.page_size = 20;
            this.current_page = 1;

            var source = $("#tpl-solution").html();
            this.template = Handlebars.compile(source);

            this.content_holder = $('#latest_solutions .solution-grid');

            this.load_more_button = $('#show-more-trigger').click(function (e) {
                e.preventDefault();
                var $self = $(this);

                if (!$self.hasClass('disabled')) {
                    // Show more elements.
                    _self.render_next_avina();
                }

            });

            this.render_avina = function (invalidate) {
                invalidate = typeof invalidate == 'undefined';
                var _self = this;
                // If invalidate is true means that the present data is not valid anymore
                // and it's to be replaced by new one.
                // This will add the placeholders.
                if (invalidate) {
                    _self.reset();
                }

                $('#loading').addClass('on');
                this.request_solutions_avina(function (data) {
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

                    if (data.length == 0 && invalidate) {
                        _self.empty();

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

            this.empty = function () {

                var source1 = $("#tpl-solution-emptyResult").html();
                var template1 = Handlebars.compile(source1);

                $("#latest_solutions").html('')
                $("#latest_solutions").append(template1);

            }

            this.render_next_avina = function () {
                this.current_page++;
                this.render_avina(false);
            };

            this.request_solutions_avina = function (callback) {

                $.get(window.location.protocol+'//'+window.location.host+'/DesktopModules/NexsoServices/API/Nexso/GetSolutions', {
                    'language': settings.language,
                    'rows': _self.page_size,
                    'page': _self.current_page,
                    'min': 0,
                    'max': 0,
                    'state': 1000,
                    'userId': settings.uid,
                    'filter': '[{"ChallengeReference":"' + dataJson.ChallengeReference +'", "SolutionType":"' + dataJson.SolutionType + '" }]'

                }, function (data) {
                    // For some reason the result is encoded twice.
                    data = JSON.parse(data);
                    callback(data);

                }, 'json');
            };

        };

        var renderer_avina = new Renderer_avina();
        renderer_avina.render_avina();

    }

    </script>


