<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:wwpage="urn:WebWorks-Page-Template-Schema" xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document" xml:lang="en" wwpage:attribute-xml-lang="locale" lang="en" wwpage:attribute-lang="locale">
<head>
  <wwpage:Block wwpage:condition="emit-mark-of-the-web" wwpage:replace="mark-of-the-web" />

  <meta http-equiv="Content-Type" content="text/html;charset=utf-8" wwpage:attribute-content="content-type" />
  <meta http-equiv="Content-Style-Type" content="text/css" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />

  <title wwpage:content="title">Title</title>

  <link rel="StyleSheet" href="css/font-awesome/css/all.min.css" wwpage:attribute-href="relative-to-output-root" type="text/css" media="all" />
  <link rel="StyleSheet" href="css/webworks.css" wwpage:attribute-href="copy-from-data-relative-to-output-root" type="text/css" media="all" />
  <link rel="StyleSheet" href="css/skin.css" wwpage:attribute-href="copy-from-data-relative-to-output-root" type="text/css" media="all" />
  <link rel="StyleSheet" href="css/social.css" wwpage:attribute-href="copy-from-data-relative-to-output-root" type="text/css" media="all" />
  <link rel="StyleSheet" href="css/print.css" wwpage:attribute-href="copy-from-data-relative-to-output-root" type="text/css" media="print" />
</head>

<body id="splash" class="" wwpage:attribute-class="body-class" style="" wwpage:attribute-style="body-style">
  <input type="hidden" id="page_onload_url" value="" wwpage:attribute-value="page-onload-url" />
  <header id="wwconnect_header">
    <div class="ww_skin_page_toolbar">
      <wwexsldoc:NoBreak />

      <div id="social_links" wwpage:condition="social-enabled">
        <wwexsldoc:NoBreak />

        <!-- Twitter -->
        <!--         -->
        <a id="social_twitter" wwpage:condition="twitter-enabled" class="ww_social ww_social_twitter" title="Twitter" target="_blank" href="#">
          <i class="fab"></i>
        </a>

        <!-- FaceBook Like -->
        <!--               -->
        <a id="social_facebook_like" wwpage:condition="facebook-like-enabled" class="ww_social ww_social_facebook" title="Facebook" target="_blank" href="#">
          <i class="fab"></i>
        </a>

        <!-- LinkedIn Share -->
        <!--                -->
        <a id="social_linkedin" wwpage:condition="linkedin-share-enabled" class="ww_social ww_social_linkedin" title="LinkedIn" target="_blank" href="#">
          <i class="fab"></i>
        </a>

        <span class="ww_skin_page_toolbar_divider">&#160;</span>
      </div>

      <a wwpage:condition="print-enabled" class="ww_behavior_print ww_skin ww_skin_print" title="Print" wwpage:attribute-title="navigation-print-title" href="#">
        <i class="fa"></i>

      </a>
      <a wwpage:condition="feedback-email" class="ww_behavior_email ww_skin ww_skin_email" title="Email" wwpage:attribute-title="navigation-email-title" href="#" target="_blank" wwpage:attribute-target="wwsetting:external-url-target">
        <i class="far"></i>
      </a>
      <a wwpage:condition="pdf-exists pdf-download-exists" class="ww_behavior_pdf ww_skin ww_skin_pdf" title="PDF" wwpage:attribute-title="navigation-pdf-title" href="#" wwpage:attribute-href="pdf-link" target="_blank" wwpage:attribute-target="pdf-target" wwpage:attribute-alt="navigation-pdf-title" download="" wwpage:attribute-download="pdf-download">
        <i class="far"></i>
      </a>
      <a wwpage:condition="pdf-exists pdf-download-not-exists" class="ww_behavior_pdf ww_skin ww_skin_pdf" title="PDF" wwpage:attribute-title="navigation-pdf-title" href="#" wwpage:attribute-href="pdf-link" target="_blank" wwpage:attribute-target="pdf-target" wwpage:attribute-alt="navigation-pdf-title">
        <i class="far"></i>
      </a>
    </div>
  </header>
  <div class="ww_skin_splash_container">
    <div class="ww_skin_splash_content">
      <div align="center">
        <!-- Splash image and styling -->
        <!--                          -->
        <style>
          .splash_card {
            margin-top: 30px;
            max-width: 75%;
          }
        </style>
        <img class="splash_card" alt="WebWorks" wwpage:attribute-alt="title" src="images/splash.png" wwpage:attribute-src="copy-relative-to-output-root" />
      </div>

      <footer>
        <!-- WebWorks Logo and message -->
        <!--                           -->
        <style>
          .splash_disclaimer {
            color: #333333;
            font: italic 9px/1.4 Arial, Helvetica, sans-serif;
          }

          .webworks_logo_img {
            width: 120px;
            height: auto;
            margin-bottom: 10px;
          }
        </style>
        <table style="margin: 30px auto 0px;">
          <tr>
            <td>
              <div>
                <img class="webworks_logo_img" src="images/WebWorks-Logo-Black.png" wwpage:attribute-src="copy-relative-to-output-root" />
              </div>
            </td>
            <td>
              <p class="splash_disclaimer">
                Home of ePublisher and CloudDrafts. Publishing solutions made easy.
              </p>
            </td>
          </tr>
        </table>

        <!-- Google Translation -->
        <!--                    -->
        <div class="ww_skin_page_globalization" wwpage:condition="google-translation-enabled">
          <div id="google_translate_element">&#160;</div>
        </div>

        <br />
      </footer>
    </div>
  </div>
  <input type="hidden" id="preserve_unknown_file_links" value="false" wwpage:attribute-value="preserve-unknown-file-links" />
  <noscript>
   <div id='noscript_warning' wwpage:content="locales-no-javascript-message">This site works best with JavaScript enabled</div>
  </noscript>

  <script type="text/javascript" src="scripts/common.js" wwpage:attribute-src="copy-relative-to-output-root"></script>
  <script type="text/javascript" src="scripts/page.js" wwpage:attribute-src="copy-relative-to-output-root"></script>
</body>
</html>
