$(document).ready(function () {
    //query list
    var list = $("ul li");
    var defaultHomeLink = $("nav > div > a");
    var defaultfooter = $(".footer");

    //remove the default links
    $(defaultfooter).remove();
    $(defaultHomeLink).remove();

    if (list[0].innerText == "Home" && list[1].innerText == "Privacy") {
        $(list[0]).remove();
        $(list[1]).remove();
    }

    //create array of dictionaries
    var navItems = [
        { text: "AI", action: "Index" },
        { text: "Home", action: "Index" },
        { text: "Jobs", action: "Jobs" },
        { text: "GenAI Sites", action: "GenAISites" },
        { text: "Contact", action: "Contact" }
    ];

    //loop through array
    //create new <li> and <a> elements
    for (var i = 0; i < navItems.length; i++) {
        var listItem = $("<li class='nav-item'>");
        var link = $("<a class='nav-link custom-navbar-text' />");

        link.attr("asp-area", "");
        link.attr("asp-controller", "Home");
        link.attr("asp-action", navItems[i].action);
        link.attr("href", "/Home/" + navItems[i].action);
        link.text(navItems[i].text);

        //append <a> to <li>
        listItem.append(link);

        //add first link to most left of navbar
        //else add new link after prior link
        if (i === 0) {
            $("ul").prepend(listItem);
        } else {
            listItem.insertAfter($("ul li").eq(i - 1));
        }
    }

    //re-query because state not saved
    list = $("ul li");

    //remove element because it pops-up (not sure why)
    $(list[5]).remove();

    //remove classes
    $("body > div").removeClass("container");
    $("nav").removeClass("navbar-light bg-white border-bottom");
    $("ul li a").removeClass("text-dark");
    $("body > header > nav > div > div > ul:nth-child(2) > li:nth-child(2) > form > button").removeClass("text-dark"); //logout button

    //add classes
    $("body > div").addClass("container-fluid");
    $(".navbar-toggler").addClass("navbar-dark");
    $("nav").addClass("custom-navbar");
    $("ul li a").addClass("custom-navbar-text");

    //add css
    $("body > header > nav > div > div > ul:nth-child(2) > li:nth-child(2) > form > button").css('color', 'white'); //logout button

    //scroll to gen-sites-section after Create button in Create.cshtml fired
    var sectionToScroll = getQueryParameter("scrollToSection");
    
    if (sectionToScroll) {
        var target = $("#" + sectionToScroll);

        if (target.length) {
            $('html, body').animate({
                scrollTop: target.offset().top
            }, 1000); 
        }
    }
});

let linkCreated = false;

function monitorViewportWidth() {
    const viewportWidth = window.innerWidth;

    if (viewportWidth < 576 && !linkCreated) {
        //re-create link with navbar-brand class
        let newDefaultlink = $("<a class='navbar-brand' />");

        newDefaultlink.attr("asp-controller", "Home");
        newDefaultlink.attr("asp-action", "Index");
        newDefaultlink.attr("asp-area", "");
        newDefaultlink.attr("href", "/Home/Index");
        newDefaultlink.text("AI");

        newDefaultlink.insertBefore($("nav > div > button"));

        linkCreated = true;
    }
    else if (viewportWidth > 576 && linkCreated) {
        $("nav > div > a").remove();
        linkCreated = false;
    }
}

function isElementEntirelyInViewport(el) { 
    var rect = el.getBoundingClientRect();
    return (
        rect.top >= 0 &&
        rect.left >= 0 &&
        rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
        rect.right <= (window.innerWidth || document.documentElement.clientWidth)
    );
}

function onScroll() {
    var articles = document.querySelectorAll(".disappearing-article");

    for (var i = 0; i < articles.length; i++) {
        if (isElementEntirelyInViewport(articles[i])) {
            articles[i].style.transition = "opacity 4.0s"
            articles[i].style.opacity = "1";
        }
        else {
            articles[i].style.transition = "opacity 0s"
            articles[i].style.opacity = "0";
        }
    }
}

function getQueryParameter(name) {
    var match = RegExp('[?&]' + name + '=([^&]*)').exec(window.location.search);
    return match && decodeURIComponent(match[1].replace(/\+/g, ' '));
}

window.addEventListener('scroll', onScroll);
window.addEventListener('resize', monitorViewportWidth);