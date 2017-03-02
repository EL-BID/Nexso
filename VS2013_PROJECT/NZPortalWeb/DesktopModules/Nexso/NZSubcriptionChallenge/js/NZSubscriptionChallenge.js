$(document).ready(function () {
    CheckBox();
});

function CheckBox() {
    var sw = $("#" + ckbAuthorization).attr('checked');

    if (typeof sw == 'undefined') {

        $("#"+ btnSubmit).prop('disabled', true);
        return false;
    } else {


        $("#" + btnSubmit).prop('disabled', false);
        return true;
    }


}