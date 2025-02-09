$(document).ready(function () {
    var sections = $(".gradient-block");
    var blockToScroll = getQueryParameter("scrollToBlock"); //getQueryParameter() defined in Index.js

    for (var i = 0; i < $(sections).length; i++) {
        if (i % 2 == 0) {
            $(sections[i]).addClass("blue");
        }
        else {
            $(sections[i]).addClass("orange");
        }
    }

    if (blockToScroll) {
        var target = $("#" + blockToScroll);

        if (target.length) {
            $('html, body').animate({
                scrollTop: target.offset().top
            }, 1000);
        }
    }
});