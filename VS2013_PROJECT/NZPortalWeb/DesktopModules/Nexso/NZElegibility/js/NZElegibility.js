//Keyup action required to validate if the field is empty and display message (textbox)
$(".required").keyup(function () {

    var control = document.getElementById($(this).attr("id"));
    if ($(this).attr("type") == "text" || $(this).attr("type") == "textbox") {
        if ($(this).val() != "")
            removeMessage(control);
        else
            addMessage(control);
    }
    DivMessage();
});

//Action click to validate whether the required field was not checked at and display message (chechkBox)
$(".required").click(function () {

    var span = $(this);
    if (span[0].type == "checkbox") {
        if (span[0].checked)
            removeMessage(span[0]);
        else
            addMessage(span[0]);
    }
    DivMessage();
});

// Continue button event
function Continue() {

    ValidateTextBox();
    ValidateCheckBox();
    var required = $("span[id*='message']");
    if (required.length == 0) {
        $("#" + ResponseHTML).val(SaveData());
        return true;
    } else {
        var divMesagge = document.getElementById("divMessage");
        divMesagge.style.display = "block";
        return false;
    }
    return false;
}

//Validates checkBox
function ValidateCheckBox(html) {
    var lHtml = document.getElementById(lHtml);
    var chkList = lHtml.getElementsByTagName("input");
    for (var i = 0; i < chkList.length; i++) {
        if (chkList[i].type == "checkbox") {
            if (chkList[i].checked)
                removeMessage(chkList[i]);
            else
                addMessage(chkList[i]);
        }
    }
}

//Validates textbox
function ValidateTextBox(html) {
    var lHtml = document.getElementById(lHtml);
    var textBoxList = lHtml.getElementsByTagName("input");
    for (var i = 0; i < textBoxList.length; i++) {
        if (textBoxList[i].type == "text" || textBoxList[i].type == "textbox") {
            if (textBoxList[i].value != "")
                removeMessage(textBoxList[i]);
            else
                addMessage(textBoxList[i]);
        }
    }
}
//remove warning messages when it meets the requirement
function removeMessage(control) {
    var message = document.getElementById("message" + control.id);
    if (message != null)
        message.remove();
}

//adds warning messages when not meet the requirement
function addMessage(control) {
    if (control.className == "required" || control.parentNode.className == "required") {
        if (document.getElementById("message" + control.id) == null) {
            var message = document.createElement("span");
            message.innerText = "*";
            message.id = "message" + control.id;
            message.className = "message";
            $(control).before(message);
        }
    }
}


//generates HTML with all that income the user and returns the HTML
function SaveData() {
    var lHtml = document.getElementById(lHtml);
    var nodes = lHtml.childNodes;
    var html = "<!DOCTYPE html><html xmlns='http://www.w3.org/1999/xhtml'><head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'/> <title></title></head><body>";

    for (var i = 0; i < nodes.length; i++) {
        if (nodes[i]) {
            if (nodes[i].nodeName == "LABEL") {
                html += "<label>" + nodes[i].innerText + "</label>";
            }
            if (nodes[i].nodeName == "INPUT") {
                if (nodes[i].type == "checkbox") {
                    if (nodes[i].checked) {
                        html += "<input type='checkbox' id='" + nodes[i].id + "' class='" + nodes[i].className + "' checked>";
                    } else {
                        html += "<input type='checkbox' id='" + nodes[i].id + "' class='" + nodes[i].className + "' >";
                    }
                }
                if (nodes[i].type == "text" || nodes[i].type == "textbox") {
                    html += "<input type='textbox' id='" + nodes[i].id + "' value='" + nodes[i].value + "' class='" + nodes[i].className + "'>";
                }
            }
            if (nodes[i].nodeName == "BR") {
                html += "</BR>";
            }
        }
    }
    html += "</body></html>";
    return html;
}

//Shows or hides general message of requirement 
function DivMessage() {

    var required = $("span[id*='message']");
    if (required.length != 0) {
        var divMesagge = document.getElementById("divMessage");
        divMesagge.style.display = "block";
    } else {

        var divMesagge = document.getElementById("divMessage");
        divMesagge.style.display = "none";
    }
}