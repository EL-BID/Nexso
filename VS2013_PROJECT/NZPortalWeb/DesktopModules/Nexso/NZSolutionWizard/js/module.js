

function SetUniform() {
    //$("input[type='file']").uniform();
}

function SetShowHideSupportText() {
    $(".wizard-form input, .wizard-form textarea , .wizard-form select").focus(function () {
        $(this).closest(".field").find(".support-text").show();
    });
    $(".wizard-form input, .wizard-form textarea, .wizard-form select").blur(function () {
        $(this).closest(".field").find(".support-text").hide();
    });

    $("div.rdControl").hover(function () {
        $(this).closest(".field").find(".support-text").show();
    });

    $("div.rdControl").mouseleave(function () {
        $(this).closest(".field").find(".support-text").hide();
    });
}


     
function onChangeVideo(id, element, sw ){
    var m = $("textarea[class*='words'");
    var n = $("input[class*='words'");
    count(m);
    count(n);

    var control= $("#"+id);
    if(sw)
        control = $("#"+element.id);
     

    if(typeof control.val() == 'undefined')
        return;
    var iframe = $("iframe[id*='video"+control.attr("id") +"'");
    if(iframe!= null)
        iframe.remove();

    if(control.val() != "")
    {
        var value=control.val();
           
        if(value.indexOf('www.youtube.com/embed/')>=0){
            if(value.indexOf('http')==-1){
                value ="https://"+ control.val();
            }
            control.after("<iframe id='video"+ control.attr("id") +"' width=\"560\" height=\"315\" src='"+value+"' frameborder=\"0\" allowfullscreen></iframe>");
        }else{
                
            var url ="";
            var video_id = videoId(value,'v=');
            var base = "https://www.youtube.com/embed/";
            if(video_id != ""){
                url = base + video_id;
            }
            else
            {
                video_id = videoId(value,'youtu.be/');
                if(video_id != ""){
                    url = base + video_id;
                }
                else
                {
                    video_id = videoId(value,'vimeo.com/');
                    if(video_id != ""){

                        url = "//player.vimeo.com/video/" + video_id;
                    }
                    
                    
                }
            }

            if(url!=""){

                control.after("<iframe id='video"+ control.attr("id") +"' width=\"560\" height=\"315\" src='"+url+"' frameborder=\"0\" allowfullscreen></iframe>");
            }
        }
    }
        
};


function videoId(url, par){
    var video_id = url.split(par)[1];

    if(typeof video_id != 'undefined'){

        var ampersandPosition = video_id.indexOf('&');
        if(ampersandPosition != -1) {
            video_id = video_id.substring(0, ampersandPosition);
        }

        return video_id;

    }else
        return "";
    
}


function Finish(text){
    $(function() {
        $( "#dialog-modal" ).dialog({
            height: 620,
            width: 1200,
            modal: true,
            dialogClass: "ui-dialog ui-widget ui-widget-content ui-corner-all ui-front dnnFormPopup ui-draggable ui-resizable"
        });
        $("div[aria-describedby*='dialog-modal'] > div[class*='titlebar'] > button[title*='close']").remove();
        $('#<%=lbHeader.ClientID%>').html(text);
        $("#dialog-modal").show();
           
    });
    
}
 


SetUniform();
setInterval(function () { keepAlive(); }, 600000);
$(document).ready(function () {
    $("#dialog-modal").hide();  
    setMaxLenght();
    setBackGround();
    SetShowHideSupportText();
    $('.connect-wizard .btn, .solution-wizard .btn').parents('table').attr('align', 'center');
        

    var m = $("textarea[class*='words'");
    var n = $("input[class*='words'");
    count(m);
    count(n);

}
);

 
function count(m) {
    for (var i = 0; i < m.length; i++) {

        var s = document.getElementById(m[i].id);
        WordCount(s, -1);

    }

}

function EndRequestHandler(sender, args) {

    $('.connect-wizard .btn, .solution-wizard .btn').parents('table').attr('align', 'center');
    SetShowHideSupportText();

    setBackGround();
   
    SetUniform();
    setMaxLenght();

}


function setBackGround() {

    $('#divWizardStep0').css({ "background": "url(\"" + '<%=Request.Url.AbsoluteUri.Replace(Request.Url.PathAndQuery,"")+ControlPath+"images/WizardHeader0." + System.Threading.Thread.CurrentThread.CurrentCulture.ToString()+".png"%>' + "\") top left no-repeat" });
}
function setMaxLenght() {

    adjustGlobalCounter(parseInt($("#" + hiddenFieldCurrentWords).val()));

    $("#"+ txtSubmissionTitle).maxlength($.extend({ max: 8, counterType: 'word' }, languages[language]));
    $("#"+ txtShortDescription).maxlength($.extend({ max: 32, counterType: 'word' }, languages[language]));
    $("#"+ txtChallenge).maxlength($.extend({ max: 75, counterType: 'word' }, languages[language]));
    $("#"+ txtApproach).maxlength($.extend({ max: 75, counterType: 'word' }, languages[language]));
    $("#"+ txtResults).maxlength($.extend({ max: 75, counterType: 'word' }, languages[language]));
    $("#"+ txtLongDescription).maxlength($.extend({ max: 60, counterType: 'word' }, languages[language]));
    $("#"+ txtCostDetails).maxlength($.extend({ max: 50, counterType: 'word' }, languages[language]));
    $("#"+ txtDurationDetails).maxlength($.extend({ max: 50, counterType: 'word' }, languages[language]));
    $("#"+ txtImplementationDetails).maxlength($.extend({ max: maxLengthImplementationDetails, counterType: 'word' }, languages[language]));

    countGlobal(languages[language].globalCounterText);

}

function keepAlive() {
    document.getElementById(btnDoKeep).click();
}

function CheckValidateOnClick(check, customValidator) {
    var chk = null;
    var customValidate = null;
    if (check == "cblTheme") {
        chk = cblTheme; customValidate = cvcblTheme;
    }
    if (check == "cblBeneficiaries") {
        chk = cblBeneficiaries; customValidate = cvcblBeneficiaries;
    }
    if (check == "cblDeliveryFormat") {
        chk = cblDeliveryFormat; customValidate =cvcblDeliveryFormat;
    }


    var chkListinputs = document.getElementById(chk).getElementsByTagName("input");
    var customValidator = document.getElementById(customValidate);
    var maxChecked = 0;

    for (var i = 0; i < chkListinputs.length; i++) {
        if (chkListinputs[i].checked) {
            maxChecked++;

        }
    }

    if (maxChecked >= 1 && maxChecked <= 3) {
        customValidator.style.visibility = 'hidden';
    }
    else {
        customValidator.style.visibility = 'visible';
    }
}

function ValidateChk(source, args) {

    var check = null;
    if (source.id == cvcblTheme) {
        check = cblTheme;
    }
    if (source.id == cvcblBeneficiaries) {
        check = cblBeneficiaries;
    }
    if (source.id ==cvcblDeliveryFormat) {
        check = cblDeliveryFormat;
    }


    var chkListinputs = document.getElementById(check).getElementsByTagName("input");
    var maxChecked = 0;

    for (var i = 0; i < chkListinputs.length; i++) {
        if (chkListinputs[i].checked) {

            maxChecked++;
        }
    }


    if (maxChecked >= 1 && maxChecked <= 3) {
        args.IsValid = true;
    }
    else {
        args.IsValid = false;
    }
}
function DeleteConfirmation() {
    $.alerts.okButton = btnOk;
    $.alerts.cancelButton = btnCancel;

    jConfirm(confirmationDelete, titlePopUp, function (r) {
        if (r)
            document.getElementById(btnDeleteSol).click();
    });

}



$(window).keypress(function (e) {
    var ListTextArea = $("textarea");
    var sw= false;
    for (var i = 0; i < ListTextArea.length; i++) {
        if(e.target == ListTextArea[i]){
            sw = true;
        }
    }

    if(!sw){
        if (e.keyCode == 13) {
            return false;
        }
    }
    
});

function addHeaderClass(headerClass) {
    $("ul[id*='header']").addClass(headerClass);
}

    

function WordCount(obj, limit) {

    var txt = obj.value.replace(/[-'`~!@#$%^&*()_|+=?;:'",.<>\{\}\[\]\\\/]/gi, "");
    var words = "";
    if (txt != "") {
        words = txt.match(/\S+/g).length;
    } else {
        words = 0;
    }

    var lengthText = words;
    var id = obj.id.split("_");
    var textMessage = $("span[id*='words" + id[id.length - 1] + "']").text();
    var txt = textMaxlength;
        //"<%= Localization.GetString("Maxlength", LocalResourceFile)%>";
    if (parseInt(limit) >= 0) {
        if (words > parseInt(limit)) {
            // Split the string on first limit words and rejoin on spaces
            var trimmed = $(obj).val().split(/\s+/, limit).join(" ");
            // Add a space at the end to make sure more typing creates new words
            $(obj).val(trimmed + " ");
            lengthText = limit;
        }
        $("span[id*='words" + id[id.length - 1] + "']").text(txt.replace("{m}", limit).replace("{r}", lengthText));

    } else {
        var textLimit = textMessage.split(/\s+/);
        var txtReplace = textMessage.replace(textLimit[0], words);
        $("span[id*='words" + id[id.length - 1] + "']").text(txtReplace);
    }
}