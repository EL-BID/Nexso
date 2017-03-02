

function SetUniform() {
    $("input[type='file']").uniform();
}

function SetShowHideSupportText() {
    $(".row input, .row textarea").focus(function () {
        $(this).closest(".field").find(".support-text").show();
    });
    $(".row input, .row textarea").blur(function () {
        $(this).closest(".field").find(".support-text").hide();
    });

    $("div.rdControl").hover(function () {
        $(this).closest(".field").find(".support-text").show();
    });

    $("div.rdControl").mouseleave(function () {
        $(this).closest(".field").find(".support-text").hide();
    });

}

function ToggleHelp(obj) {
    $(obj).closest(".field").find(".support-text").toggle();
}
/*
old version, pending for deleting

$(function () {

$("input[type='file']").uniform();

});

$(document).ready(function () {
$(".wizard-form input, .wizard-form textarea").focus(function () {
$(this).closest(".field").find(".support-text").show();
});
$(".wizard-form input, .wizard-form textarea").blur(function () {
$(this).closest(".field").find(".support-text").hide();
});
});
*/