$(document).ready(function () {
    // Create the footer element
    const footer = $('<footer id="login-partial-footer" class="row"></footer>');

    // Create the first section
    const section1 = $('<section class="row"></section>');

    // Create and append Home link
    const homeLink = createFooterLink("Home", "/Home/Index");
    section1.append(homeLink);

    // Create and append Jobs link
    const jobsLink = createFooterLink("Jobs", "/Home/Jobs");
    section1.append(jobsLink);

    // Create and append About Us link
    const aboutUsLink = createFooterLink("About Us", "/Home/Contact");
    section1.append(aboutUsLink);

    // Create and append Follow Us text
    const followUsText = createFooterText("Follow Us");
    section1.append(followUsText);

    // Append the first section to the footer
    footer.append(section1);

    // Create the second section
    const section2 = $('<section class="row"></section>');

    // Create and append Gen AI Sites link
    const genAISitesLink = createFooterLink("Gen AI Sites", "/Home/GenAISites");
    section2.append(genAISitesLink);

    // Create and append Contact link
    const contactLink = createFooterLink("Contact", "/Home/Contact");
    section2.append(contactLink);

    // Create and append Copyright Info link
    const copyrightInfoLink = createFooterLink("Copyright Info", "/Home/Contact");
    section2.append(copyrightInfoLink);

    // Create and append social media icons
    const socialMediaIcons = createSocialMediaIcons();
    section2.append(socialMediaIcons);
    footer.append(section2);

    // Add the footer where needed
    footer.insertAfter($('#registerSubmit'));
    footer.insertAfter($("#account > div:nth-child(7)"));
    footer.insertAfter($("#CreatePage"));
    footer.insertAfter($("#EditPage"));
    footer.insertAfter($("#DeletePage"));

    // Helper function to create footer links
    function createFooterLink(text, href) {
        const link = $('<a class="footer-link"></a>');
        const footerLinkDiv = $('<div class="col-md-3 col-sm-6 col-12"></div>');

        link.attr('href', href);
        link.text(text);

        footerLinkDiv.append(link);
        return footerLinkDiv;
    }

    // Helper function to create footer text
    function createFooterText(text) {
        const textElement = $('<div class="col-md-3 col-sm-6 col-12"></div>');
        textElement.text(text);
        return textElement;
    }

    // Helper function to create social media icons
    function createSocialMediaIcons() {
        const socialMediaIconsDiv = $('<div class="col-md-3 col-sm-6 col-12"></div>');

        const icons = ["fa-google", "fa-youtube", "fa-twitter", "fa-facebook", "fa-linkedin"];
        for (const iconClass of icons) {
            const icon = $('<i class="fa ' + iconClass + '"></i>');
            socialMediaIconsDiv.append(icon);
        }

        return socialMediaIconsDiv;
    }
});