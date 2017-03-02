function getIndexAccordion(sender, args) {
    var active = $("#accordion").accordion("option", "active");
    $("#" + hFSelector).val(active);
}

$(function () {
    $(function () {
        js();

    });
});



function js() {

    var activeIndex = parseInt($("#" + hFSelector).val());

    $("#accordion").accordion({
        autoHeight: false,
        event: "mousedown",
        active: activeIndex,
        change: function (event, ui) {
            var index = $(this).accordion("option", "active");
            $("#" + hFSelector).val(index);

        }
    });
}

function EndRequestHandler(sender, args) {
    js();

}

function doClick(buttonName, e) {
    var key;
    if (window.event)
        key = window.event.keyCode;     //IE
    else
        key = e.which;     //firefox

    if (key == 13) {

        var btn = document.getElementById(buttonName);
        if (btn != null) {
            btn.click();
            event.keyCode = 0
        }
    }
}
$(window).keypress(function (e) {
    if (e.keyCode == 13) {
        return false;

    }
});