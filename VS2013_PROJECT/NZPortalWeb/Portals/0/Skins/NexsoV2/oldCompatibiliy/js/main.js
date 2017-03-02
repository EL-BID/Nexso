$(document).ready(function () {

    // Changing the language names of the language dropdown
    $('#dnn_dnnLANGUAGE_selectCulture option').each(function () {
        if (this.value == 'en-US') {
            $(this).text('English');

            if (this.selected) {
                if ($.browser.msie) {

                    if ($.browser.version < 8) {
                        $('#page').before('<div class="dnnFormMessage dnnFormValidationSummary">"To get the best possible experience using this website we recommend that you upgrade to a newer version of Internet Explorer, or try using Google Chrome."</div>');
                    }
                }
            }


        } else if (this.value == 'es-ES') {
            $(this).text('Español');
            if (this.selected ) {
                if ($.browser.msie) {

                    if ($.browser.version < 8) {
                        $('#page').before('<div class="dnnFormMessage dnnFormValidationSummary">"Para lograr la mejor experiencia posible en este sitio le recomendamos que actualice a una versión más reciente de Internet Explorer o intente utilizar Google Chrome."</div>');
                    }
                }
            }


        } else if (this.value == 'pt-BR') {
            $(this).text('Português');
            if (this.selected) {
                if ($.browser.msie) {

                    if ($.browser.version < 8) {
                        $('#page').before('<div class="dnnFormMessage dnnFormValidationSummary">"Para a melhor experiência possível neste site, recomendamos que você atualize para uma versão mais recente do Internet Explorer ou experimentar o Google Chrome."</div>');
                    }
                }
            }

        }
    });

    // Hard-coding the markup of the main menu
    $('#dnn_dnnNAV_ctldnnNAVctr1513 a span').html('what is <strong>Nexso?</strong>');
    $('#dnn_dnnNAV_ctldnnNAVctr1515 a span').html('<strong>Discover</strong> solutions');
    $('#dnn_dnnNAV_ctldnnNAVctr1517 a span').html('<strong>Submit</strong> your solution');
    $('#dnn_dnnNAV_ctldnnNAVctr1514 a span').html('qué es <strong>Nexso?</strong>');
    $('#dnn_dnnNAV_ctldnnNAVctr1516 a span').html('<strong>Descubra</strong> soluciones');
    $('#dnn_dnnNAV_ctldnnNAVctr1518 a span').html('<strong>Presente</strong> soluciones');
    $('#dnn_dnnNAV_ctldnnNAVctr1549 a span').html('O que é <strong>Nexso?</strong>');
    $('#dnn_dnnNAV_ctldnnNAVctr1550 a span').html('<strong>Busque</strong> soluções');
    $('#dnn_dnnNAV_ctldnnNAVctr1551 a span').html('<strong>Inscreva</strong> sua solução');


    $('.carousel').carousel();

    $('.dropdown-toggle').dropdown();

});