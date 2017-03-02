function ValidateTerms(source, args) {
    var elem = document.getElementById(chkTerms);
    if (elem.checked) {
        args.IsValid = true;
    }
    else {
        args.IsValid = false;
    }
}

function UpdateValidator(checked) {
    var elem = document.getElementById(rfvTermsValidator);
    elem.IsValid = checked;
    window.ValidatorValidate(elem);
}

$('.connect-wizard .btn, .solution-wizard .btn').parents('table').attr('align', 'center');
//Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);

function EndRequestHandler(sender, args) {

    $('.connect-wizard .btn, .solution-wizard .btn').parents('table').attr('align', 'center');
}
$(window).keypress(function (e) {
    if (e.keyCode == 13) {
        return false;

    }
});