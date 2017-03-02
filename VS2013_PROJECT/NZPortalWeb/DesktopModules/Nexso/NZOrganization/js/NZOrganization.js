function NavigateUrlOrg(id) {
    window.open(id, '_newtab');
    return false;
}

$(document).ready(function () {
    setMaxLenghtOrg();
    activateTransalte();
}
);


function EndRequestHandler(sender, args) {
    activateTransalte();
    setMaxLenghtOrg();
}
function setMaxLenghtOrg() {
    $("#" + txtDescription).maxlength({ max: 800 });
}
function activateTransalte() {

    if (languageName != OrganizationLanguage) {
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

function translateAll() {

    var count = $("#" + lblCount).html();


    TranslateControl($("#" + lblInstitutionNameTxt), $("#" + hfInstitutionNameTxt), true, count);
    TranslateControl($("#" + lblDesciptionTxt), null, false, count);

    $("#" + lblCount).html(parseInt(count) + 1);

}
function TranslateControl(control, control2, sw, count) {

    var text;
    if (sw) {
        text = control2.html()
    }
    else {
        text = control.html();
    }

    var apiKey = "AIzaSyB1gqjm4RqlcFCBJvPSlblg1uZNSkrFsgg";

    var langTarget = languageName;
    var langSource = OrganizationLanguage;
    var apiurl = "https://www.googleapis.com/language/translate/v2?key=" + apiKey + "&source=" + langSource + "&target=" + langTarget + "&q=";
    var failed = 0;

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
            if (sw) {
                control.html(text + " ( " + '<span class="translated">' + data.data.translations[0].translatedText + '</span>' + "  ) "); // Inserts translated text.
            }
            else {
                if (count == 0) {
                    control.html('<span class="translated">' + data.data.translations[0].translatedText + '</span><span class="translatedGoogle"> Translated by google</span>');  // Inserts translated text.

                } else {

                    control.html(text);
                }

            }
        },
        error: function (data) {
            failed = 1;
            control.html('<span class="translated">Translation Failed!</span>');
        }
    });

    return false;

}