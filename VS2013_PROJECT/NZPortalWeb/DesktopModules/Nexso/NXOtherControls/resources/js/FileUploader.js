function onClientFileUploaded(sender, args) {
    document.getElementById("<%=RadButton1.ClientID%>").click();
}

function onClientUploaderHandler(arg) {

    window.open("/cheese/file/" + arg, "NEXSO", "width=450,height=200");

}

function fileSelected(upload, args) {
    $telerik.$(".ruInputs li:first", upload.get_element()).addClass('hidden');
    upload.addFileInput();
    $telerik.$(".ruFakeInput", upload.get_element()).val(args.get_fileName());
    upload.set_enabled(true);
}

function processException(sender,args,clientId)
{
    $('#rfvWrongExtension' + clientId).hide();
    $('#rfvWrongSize' + clientId).hide();

    var fileExtention = args.get_fileName().substring(args.get_fileName().lastIndexOf('.') + 1, args.get_fileName().length);
    if (args.get_fileName().lastIndexOf('.') != -1) {//this checks if the extension is correct
        if (sender.get_allowedFileExtensions().indexOf(fileExtention) == -1) {
            $('#rfvWrongExtension' + clientId).show();
        }
        else {
            $('#rfvWrongSize' + clientId).show();
        }
    }
    else {
        $('#rfvWrongExtension' + clientId).show();
    }
}