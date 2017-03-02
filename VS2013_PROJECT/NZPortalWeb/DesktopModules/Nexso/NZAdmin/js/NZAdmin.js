function onRequestStart(sender, args) {

    if (args.get_eventTarget().indexOf('btnExport') != -1) {
        args.set_enableAjax(false);
    }

}