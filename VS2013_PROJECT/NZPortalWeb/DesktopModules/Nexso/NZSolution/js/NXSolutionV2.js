function DeleteConfirmation() {

    return confirm(messageConfirmation);

}

function InitializeControls() {

}


function activateUploaderControls(language, btnEnableBannerUploader, btnCancelBanner, btnSaveBanner, solutionId) {
    currentLanguage = language;
    btnEnableBannerUploader.click(function () {
        stepController('DragAndDrop', solutionId);
    });
    btnCancelBanner.click(function () {
        stepController('Cancel', solutionId);
    });
    btnSaveBanner.click(function () {
        stepController('Saving', solutionId);
    });



}

// Modals
(function ($) {

    var settings = {
        api: {
            sendMessage: 'https://www.nexso.org/DesktopModules/NexsoServices/API/Nexso/SendMessage'
        }
    };




    // Modal trigger code.
    $(function () {

        $('[data-modal-id]').click(function (e) {
            e.preventDefault();
            var id = $(this).attr('data-modal-id');

            $('#' + id).addClass('revealed');

            //var userId =<%=UserInfo.UserID%>;
            if (userId > -1) {
                var id = $(this).attr('data-modal-id');

                $('.messageAuthentication').addClass('hideMessage');
                $('.modal-body').removeClass('hideMessage');
                $('.modal-footer').removeClass('hideMessage');
            }
            else {
                $('.modal-body').addClass('hideMessage');
                $('.modal-footer').addClass('hideMessage');
                $('.messageAuthentication').removeClass('hideMessage');
            }

        });







        $('[data-modal-dismiss]').click(function (e) {
            e.preventDefault();
            $(this).closest('.modal').removeClass('revealed');
        });

    });

    // #conector-modal code
    $(function () {
        var $modal = $('#conector-modal');
        var $status = $modal.find('#status-message');

        var recipientId = $('input#hfOwnerSolutionId').val() || null;
        // Move modal.
        $modal.appendTo('body');

        // Update recipient name before opening modal.
        $('.author-user [data-modal-id]').click(function (e) {
            e.preventDefault();
            var userName = $('.author-user h1.card-title span').text();
            $modal.find('#message-recipient').text(userName);

            // Hide status message.
            $status.removeClass('revealed status-message-success status-message-alert');
        });

        $modal.find('[data-modal-confirm]').click(function (e) {
            e.preventDefault();
            var message = $.trim($modal.find('#message-body').val());
            if (message == '') {
                $status.addClass('revealed status-message-alert')
                  .html($('<p>').text('The message is empty.'));



                return;
            }

            $status.addClass('revealed')
              .removeClass('status-message-success status-message-alert')
                .html($('<p>').text('Loading...'));

            $.get(settings.api.sendMessage, {
                'userIdTo': recipientId,
                'Message': message,
            })
            .done(function (data) {
                $modal.find('#message-body').val('');

                $status.addClass('status-message-success')
                  .html($('<p>').text('Message sent.'));
            })
            .fail(function (data) {
                console.log('fail', data);

                $status.addClass('status-message-alert')
                  .html($('<p>').text('An error occurred while trying to send the message. Please try again.'));

            });



        });
    });

})($);

/// js

function PopUpReportSpam() {

    //var messageConfirmation ='<%=Localization.GetString("PopUpReportSpam", this.LocalResourceFile)%>';
    var title = "";
    jAlert(textPopUpReportSpam, title);
}

function Confirmation(PopUp) {

    var messageConfirmation = "";
    var title = "";
    if (PopUp == "Unpublish") {
        messageConfirmation = textConfirmationUnPublish;
        title = textUnpublishTitle;
    }

    if (PopUp == "Delete") {
        messageConfirmation = messageConfirmation2;
        title = textDeleteTitle;
    }

    $.alerts.okButton = textbtnOk;
    $.alerts.cancelButton = textbtnCancel;


    jConfirm(messageConfirmation, title, function (r) {
        if (r) {
            if (PopUp == "Unpublish") {
                document.getElementById(btnEdit).click();
            }
            if (PopUp == "Delete") {
                document.getElementById(btnDelete).click();
            }
        }
    });


    return false;

}

$(document).ready(function () {
    activateTransalte();
}
    );


function EndRequestHandler(sender, args) {

    activateTransalte();
}



function activateTransalte() {
    if (languageName != SolutionLanguage) {
        if (languageName == 'EN') {
            $('#btnTranslate').val('Translate');
        }
        else if (languageName == 'ES') {
            $('#btnTranslate').val('Traducir');
        }
        else if (languageName == 'PT') {
            $('#btnTranslate').val('Traduzir');
        }
        $('#btnTranslate').show();
    } else {
        $('#btnTranslate').hide();
    }
}


function translate(langTarget, langSource) {

    var count = $("#" + lblCount).html();

    TranslateControl($("#" + lblChallenge), null, null, false, count, langSource, langTarget);
    TranslateControl($("#" + lblApproach), null, null, false, count, langSource, langTarget);
    TranslateControl($("#" + lblResults), null, null, false, count, langSource, langTarget);
    TranslateControl($("#" + lblDescription), null, null, false, count, langSource, langTarget);
    TranslateControl($("#" + lblCostDetails), null, null, false, count, langSource, langTarget);
    TranslateControl($("#" + lbldurationDetails), null, null, false, count, langSource, langTarget);
    TranslateControl($("#" + lblImplementationDetails), null, null, false, count, langSource, langTarget);
    TranslateControl($("#" + lblOrganizationDescription), null, null, false, count, langSource, langTarget);
    TranslateControl($("#" + lblTitle), $("#" + hfTitle), $("#" + hfTitle2), true, count, langSource, langTarget);
    TranslateControl($("#" + lblTagLine), $("#" + hfTagLine), $("#" + hfTagLine2), true, count, langSource, langTarget);
    TranslateControl($("#" + lblInstitutionName), $("#" + hfInstitutionName), $("#" + hfInstitutionName2), true, count, langSource, langTarget);

    $("#" + lblCount).html(parseInt(count) + 1);
}

function translateAll(controlLanguage) {
    var langTarget = document.getElementById(controlLanguage.id).value;
    if (langTarget != "0")
        DetectLanguage($("#" + lblChallenge), $("#" + lblApproach), langTarget);

}


function DetectLanguage(control, control2, langTarget) {
    var failed = 0;
    var text = control.html();
    text += " " + control2.html();
    var apiKey = "AIzaSyB1gqjm4RqlcFCBJvPSlblg1uZNSkrFsgg";

    var apiurldetect = "https://www.googleapis.com/language/translate/v2/detect?key=" + apiKey + "&q=";

    var hfLnguage = $("#" + hfLnguage);
    $.ajax({
        url: apiurldetect + encodeURIComponent(text),
        dataType: 'jsonp',
        type: "GET",
        beforeSend: function () {
            if (failed == 1) {
                hfLnguage.html('<span class="translated">Translating Again ...</span>'); // Updates the status of translation.
            }
            else {
                hfLnguage.html('<span class="translated">Translating...</span>'); // Updates the status of translation.
            }
        },
        success: function (data) {

            var datalanguage = data.data.detections[0];

            hfLnguage.html(datalanguage[0].language);
            var langSource = GetLang(datalanguage[0].language);
            var langTarget1 = GetLang(langTarget);
            if (langSource != langTarget1) {
                $(".translatedGoogle").remove();
                translate(langTarget1, langSource);
            }
        },
        error: function (data) {
            failed = 1;
            hfLnguage.html('<span class="translated">Translation Failed!</span>');
        }
    });

    return false;
}

function GetLang(lang) {
    if (lang == "en-US")
        lang = "en";
    if (lang == "es-ES")
        lang = "es";
    if (lang == "pt-BR")
        lang = "pt";
    return lang;
}

function TranslateControl(control, control2, control3, sw, count, langSource, langTarget) {

    var text;

    if (sw) {
        text = control2.html()
    }
    else {
        text = control.html();
    }



    var apiKey = "AIzaSyB1gqjm4RqlcFCBJvPSlblg1uZNSkrFsgg";
    //var langTarget = languageName;
    //var langSource = '<%=SolutionLanguage%>';


    var apiurl = "https://www.googleapis.com/language/translate/v2?key=" + apiKey + "&source=" + langSource + "&target=" + langTarget + "&q=";
    var failed = 0;
    if (langSource != langTarget) {
        // Now we call the data
        $.ajax({
            url: apiurl + encodeURIComponent(text),
            dataType: 'jsonp',
            type: "GET",
            beforeSend: function () {
                if (failed == 1) {

                    control.html('<span class="translated">Translating Again ...</span>'); // Updates the status of translation.
                }
                else {
                    control.html('<span class="translated">Translating...</span>'); // Updates the status of translation.
                }
            },
            success: function (data) {


                var MessageTransalte = $("#" + MessageTransalte);
                MessageTransalte.html('</span><span class="translatedGoogle"> Translated by google</span>');
                var MessageTransalte2 = $("#" + MessageTransalte2);
                MessageTransalte2.html('</span><span class="translatedGoogle"> Translated by google</span>');
                if (sw) {
                    control.html(control3.val() + '<span class="translated"> (' + data.data.translations[0].translatedText + ') </span>'); // Inserts translated text.
                    control2.html(data.data.translations[0].translatedText);
                }
                else {

                    control.html('<span class="translated">' + data.data.translations[0].translatedText + '</span><span class="translatedGoogle"> Translated by google</span>');  // Inserts translated text.



                }
            },
            error: function (data) {
                failed = 1;
                control.html('<span class="translated">Translation Failed!</span>');
            }
        });
    }



    return false;

}

$('body').on('keyup', 'textarea', function (

) {
    var value = $('textarea[id*="txtDescription"]').val();

    if (value.length == 0) {
        var text = Text(140);
        $('span[id*="lblCountDescription"]').html(text);
        return;
    }

    var regex = /\s+/gi;
    var wordCount = value.trim().replace(regex, ' ').split(' ').length;
    var ramaining = 130 - wordCount;
    var text = Text(ramaining);
    $('span[id*="lblCountDescription"]').html(text);

});

function  Text (value)
{
    var lang = document.documentElement.lang;
    if (lang.toLowerCase() == "en-us") 
    {
        return value.toString() + " words remaining (130 limit)";
    }
    else
    if (lang.toLowerCase() == "es-es") 
    {
        return value.toString() + " palabras restantes (130 limite)";
    }
    else
    if (lang.toLowerCase() == "pt-br") {
        return value.toString() + " palavras restantes (8 limite)";
    }  
}

