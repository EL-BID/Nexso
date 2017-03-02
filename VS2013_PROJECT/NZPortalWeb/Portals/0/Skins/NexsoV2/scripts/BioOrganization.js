

//variables
var globalPositionY = 0;
var globalFileName = null;
var originalFileName = null;
var OrganizationIdVar = null;
var template = '<div id="PrevDiv" class="preview">' +
						'<span class="imageHolder">' +
							'<img />' +
							'<span class="uploaded"></span>' +
						'</span>' +
						'<div class="progressHolder">' +
							'<div class="progress"></div>' +
						'</div>' +
					'</div>';

var templateRepositioning =
        '<div id="RepDiv" class="preview">' +


							'<span style="backgroundcolor:#555;" >Repositioning the image and Save</span>' +

                        '</div>';


var files = null;

var currentLanguage = 'EN';

$(document).ready(function () {
    var a = window.location.href;
    var b = a.split("/");
    var OrgId = b[b.length - 1];
    
    $.ajax({

        type: "GET",
        url: window.location.protocol + "//" + window.location.host + "/DesktopModules/NexsoServices/API/Nexso/GetOrganizationHeaderImage?orgnizationId=" + OrgId,
        dataType: 'json',
        headers: {
            Accept: "application/json", "Access-Control-Allow-Origin": "*"
        },
        success: function (resp) {
            $("#banner").attr("src", resp);
            //$("#banner").attr("src", window.location.host + resp);
        },
        error: function (e) {
        }
    });

    Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(EndRequestHandler);
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);
    function EndRequestHandler(sender, args) {
        activateUploaderControls('en-US', $('#btnEnableBannerUploader'),$( '#btnCancelBanner'),   $('#btnSaveBanner'),OrgId);
    }


});




//general methods
function createImage(file) {

    var dropbox = $('#dropbox'),
		message = $('.message', dropbox);
    var preview = $(template),
        image = $('img', preview);

    var reader = new FileReader();

    image.width = 100;
    image.height = 100;

    reader.onload = function (e) {

        // e.target.result holds the DataURL which
        // can be used as a source of the image:

        image.attr('src', e.target.result);
    };

    // Reading the file as a DataURL. When finished,
    // this will trigger the onload function above:
    reader.readAsDataURL(file);

    message.hide();
    preview.appendTo(dropbox);

    // Associating a preview container
    // with the file, using jQuery's $.data():

    $.data(file, preview);
}

//drag and drop methods



function activateUploader(OrganizationId) {


    var dropbox = $('#dropbox'),
		message = $('.message', dropbox);
    message.show();
    dropbox.show();
    dropbox.filedrop({
        // The name of the $_FILES entry:
        paramname: 'pic',
        data: { "organizationId": OrganizationId },
        maxfiles: 1,
        maxfilesize: 2,
        url: window.location.protocol + "//" + window.location.host + '/DesktopModules/NexsoServicesV2/API/Organizations/UploadBanner',

        uploadFinished: function (i, file, response) {

            if (response.Filename.length > 0) {
                deactivateUploader(OrganizationId);
                stepController('Repositioning', response.Filename + response.Extension);

            }
        },

        error: function (err, file) {
            switch (err) {
                case 'BrowserNotSupported':
                    if (currentLanguage == 'EN')
                        showMessage('Your browser does not support HTML5 file uploads!');
                    else if (currentLanguage == 'ES')
                        showMessage('Su navegador no soporta la carga de archivos HTML5!');
                    else if (currentLanguage == 'PT')
                        showMessage('Seu navegador n\xe3o suporta o upload de arquivos em HTML5!');
                    break;
                case 'TooManyFiles':
                    if (currentLanguage == 'EN')
                        alert('Too many files! Please select 1 at most! ');
                    else if (currentLanguage == 'ES')
                        alert('Demasiados archivos! Por favor seleccione 1 como m\xe1ximo!');
                    else if (currentLanguage == 'PT')
                        alert('Muitos arquivos! Por favor seleccione um a mais!');

                    break;
                case 'FileTooLarge':
                    if (currentLanguage == 'EN')
                        alert(file.name + ' is too large! Please upload files up to 2mb.');
                    else if (currentLanguage == 'ES')
                        alert(file.name + ' es demasiado grande! Por favor, subir archivos de hasta 2 MB.');
                    else if (currentLanguage == 'PT')
                        alert(file.name + ' \xe9 muito grande! Fa\xc7a upload de arquivos de at\xe9 2MB.');


                    break;
                default:
                    break;
            }
        },

        // Called before each upload is started
        beforeEach: function (file) {
            if (!file.type.match(/^image\/png|^image\/jpeg/)) {

                if (currentLanguage == 'EN')
                    alert('Only images jpg or png are allowed!');
                else if (currentLanguage == 'ES')
                    alert('S\xf3lo las im\xe1genes jpg o png est\xe1n permitidas!');
                else if (currentLanguage == 'PT')
                    alert('Apenas as imagens s\xe3o jpg o png permitidas!');



                // Returning false will cause the
                // file to be rejected
                return false;
            }
        },
        uploadStarted: function (i, file, len) {
            createImage(file);
        },
        progressUpdated: function (i, file, progress) {
            $.data(file).find('.progress').width(progress);
        }

    });

    function showMessage(msg) {
        message.html(msg);
    }

}



function deactivateUploader(OrganizationId) {
    $('#dropbox').hide();
    $('#dropbox').off();
}

//classic uploader

function acivateUploaderButton(OrganizationId) {
    OrganizationIdVar = OrganizationId;
    $('form').on('submit', uploadFiles);
    $("#btnUploadBanner").on('change', prepareUpload);

}

function prepareUpload(event) {
    files = event.target.files;
    $(this).closest('form').submit();
}

function uploadFiles(event) {
    event.stopPropagation(); // Stop stuff happening
    event.preventDefault(); // Totally stop stuff happening

    // START A LOADING SPINNER HERE
    var formData = new FormData();
    formData.append('files[]', $('#btnUploadBanner').get(0).files[0]);
    formData.append('OrganizationId', OrganizationIdVar);
    // Create a formdata object and add the files

    //dataIn.append( "solutionID", SolutionIdVar );
    $.ajax({
        url: window.location.protocol + "//" + window.location.host + '/DesktopModules/NexsoServicesV2/API/Organizations/UploadBanner',
        type: 'POST',
        data: formData,
        cache: false,
        dataType: 'json',

        contentType: false, // Set content type to false as jQuery will tell the server its a query string request

        processData: false,
        success: function (response, textStatus, jqXHR) {
            if (response.Filename.length > 0) {
                deactivateUploader(OrganizationIdVar);
                stepController('Repositioning', response.Filename + response.Extension);

            }
        },
        error: function (jqXHR, textStatus, errorThrown) {
            // Handle errors here
            console.log('ERRORS: ' + textStatus);
            // STOP LOADING SPINNER
        },
        beforeSend: function (i, file, len) {

            var fileTmp = $('#btnUploadBanner').get(0).files[0];
            if (fileTmp.size > 1024 * 1024 * 2) {
                if (currentLanguage == 'EN')
                    alert(fileTmp.name + ' is too large! Please upload files up to 2mb.');
                else if (currentLanguage == 'ES')
                    alert(fileTmp.name + ' es demasiado grande! Por favor, subir archivos de hasta 2 MB.');
                else if (currentLanguage == 'PT')
                    alert(fileTmp.name + ' \xe9 muito grande! Fa\xc7a upload de arquivos de at\xe9 2MB.');
                return false;
            }

            if (!fileTmp.type.match(/^image\/png|^image\/jpeg/)) {
                if (currentLanguage == 'EN')
                    alert('Only images jpg or png are allowed!');
                else if (currentLanguage == 'ES')
                    alert('S\xf3lo las im\xe1genes jpg o png est\xe1n permitidas!');
                else if (currentLanguage == 'PT')
                    alert('Apenas as imagens s\xe3o jpg o png permitidas!');

                // Returning false will cause the
                // file to be rejected
                return false;
            }

            createImage(fileTmp);
        }


    });
}


//nexso ajax calls

function RepositioningImage(OrganizationFile) {

    $(".picturecontainer").css({
        height: $(".headerimage").width() / 2, border: "1px solid #888", overflow: "hidden", cursor: "-webkit-grab"
    });
    $(".headerimage").attr("src", '/Portals/0/OrgImages/TempImages/' + OrganizationFile).load(
        function () {
            var y1 = $('.picturecontainer').height();
            var y2 = $('.headerimage').height();
            var x1 = $('.picturecontainer').width();
            var x2 = $('.headerimage').width();

            $(".headerimage").draggable({
                scroll: false,
                axis: "y x",
                drag: function (event, ui) {
                    //Moving up and down
                    if (ui.position.top >= 0) {
                        ui.position.top = 0;
                    }
                    else if (ui.position.top <= y1 - y2) {
                        ui.position.top = y1 - y2;
                    }

                    //Moving left and right
                    if (ui.position.left >= 0) {
                        ui.position.left = 0;
                    }
                    else if (ui.position.left <= x1 - x2) {
                        ui.position.left = x1 - x2;
                    }
                },
                stop: function (event, ui) {
                    globalPositionY = ui.position.top;
                    // alert("Top: " + ui.position.top + " | " + "Left: " + ui.position.left);
                }
            });

        }
        );
}



function cropImage(arg) {
    if (globalPositionY != null) {
        $.ajax({
            type: "PUT",
            contentType: "application/json; charset=utf-8",


            url: window.location.protocol + "//" + window.location.host + "/DesktopModules/NexsoServicesV2/API/Organizations/CropSaveBanner?organizationId=" + OrganizationIdVar,
            data: JSON.stringify({ Filename: globalFileName, yCrop: globalPositionY }),
            success: function (data, response, i) {
                for (var i = 0; i < data.length; i++) {

                    if (data[i].Filename.toLowerCase().indexOf("cropbig") >= 0) {

                        originalFileName = '/Portals/0/OrgImages/HeaderImages/' + data[i].Filename + data[i].Extension;

                        globalFileName = null;
                        globalPositionY = null;
                        stepController('Cancel', arg);
                        return;
                    }
                }




            }
        });
    }
}

//step controller

function stepController(step, arg) {
    switch (step) {
        case 'Cancel':
            {
                $(".headerimage").attr("src", originalFileName);
                $(".picturecontainer").css({ border: "", overflow: "", cursor: "" });
                $(".headerimage").css({ top: "0", cursor: "" });
                $(".controllerTopBar").show();
                $(".controllerBotomBar").hide();
                $("#RepDiv").remove();
                $("#PrevDiv").remove();
                deactivateUploader(arg);
                $('.single-headline').fadeIn(1000);
                return;
            }
        case 'DragAndDrop':
            {
                originalFileName = $(".headerimage").attr("src");
                $(".controllerTopBar").hide();
                $(".controllerBotomBar").show();
                $("#btnSaveBanner").hide();
                $(".uploadControl").show();
                activateUploader(arg);
                acivateUploaderButton(arg);
                $('.single-headline').fadeOut(1000);
                return;
            }
        case 'Saving':
            {
                cropImage(arg);
                return;
            }

        case 'Repositioning':
            {
                $("#btnSaveBanner").show();
                $(".uploadControl").hide();
                var preview = $(templateRepositioning);
                preview.appendTo($(".picturecontainer"));
                globalFileName = arg;
                RepositioningImage(arg);
            }
    }
}

function activateUploaderControls(language, btnEnableBannerUploader, btnCancelBanner, btnSaveBanner, organizationId) {
    currentLanguage = language;
    btnEnableBannerUploader.click(function () {
        stepController('DragAndDrop', organizationId);
    });
    btnCancelBanner.click(function () {
        stepController('Cancel', organizationId);
    });
    btnSaveBanner.click(function () {
        stepController('Saving', organizationId);
    });



}