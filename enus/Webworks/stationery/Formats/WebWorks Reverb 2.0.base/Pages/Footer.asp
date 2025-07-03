<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:wwpage="urn:WebWorks-Page-Template-Schema" xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document" xml:lang="en" wwpage:attribute-xml-lang="locale" wwpage:attribute-lang="locale" data-highlight-require-whitespace="true" wwpage:attribute-data-highlight-require-whitespace="highlight-require-whitespace">
<head>
  <title>Footer</title>
</head>
<body>
  <!-- All content below this comment contains the footer -->
  <!-- Any content above this comment will not be         -->
  <!-- copied into the Output. Custom stylesheets         -->
  <!-- should be added to Connect.asp, where this         -->
  <!-- content will also be added during generation       -->
  <!--                                                    -->
  <div class="ww_skin_footer" wwpage:condition="footer-enabled">
    <div class="ww_skin_footer_logo_container" wwpage:condition="footer-logo-enabled linked-footer-logo-enabled">
      <a id="footer_logo_link" class="" wwpage:attribute-class="footer-logo-link-class" href="#" wwpage:attribute-href="footer-logo-link" wwpage:condition="footer-logo-link-exists">
        <img class="ww_skin_footer_logo" src="images/logo.gif" wwpage:condition="footer-logo-override-exists" wwpage:attribute-src="footer-logo-src" />
        <img class="ww_skin_footer_logo" src="images/logo.gif" wwpage:condition="company-logo-for-footer-logo company-logo-src-exists footer-logo-override-not-exists" wwpage:attribute-src="company-logo-src" />
        <span class="ww_skin_footer_logo" wwpage:condition="company-name-for-footer-logo company-name-exists footer-logo-override-not-exists" wwpage:content="company-name">Company Name</span>
      </a>
    </div>
    <div class="ww_skin_footer_logo_container" wwpage:condition="footer-logo-enabled linked-footer-logo-disabled">
      <img class="ww_skin_footer_logo" src="images/logo.gif" wwpage:condition="footer-logo-override-exists" wwpage:attribute-src="footer-logo-src" />
      <img class="ww_skin_footer_logo" src="images/logo.gif" wwpage:condition="company-logo-for-footer-logo company-logo-src-exists footer-logo-override-not-exists" wwpage:attribute-src="company-logo-src" />
      <span class="ww_skin_footer_logo" wwpage:condition="company-name-for-footer-logo company-name-exists footer-logo-override-not-exists" wwpage:content="company-name">Company Name</span>
    </div>
    <div wwpage:condition="company-info-exists">
      <table class="ww_skin_footer_connect_info" wwpage:condition="company-phone-exists, company-fax-exists, company-email-exists">
        <tr>
          <td class="ww_skin_footer_connect_message" colspan="2" wwpage:content="connect-with-us">Connect with us</td>
        </tr>
        <tr wwpage:condition="company-phone-exists" class="ww_skin_footer_company_phone">
          <td class="ww_skin_footer_connect_info_icon" title="Phone" wwpage:attribute-title="phone-label"><i class="fa"></i></td>
          <td class="ww_skin_footer_connect_info_content" wwpage:content="company-phone">000-000-0000</td>
        </tr>
        <tr wwpage:condition="company-fax-exists" class="ww_skin_footer_company_fax">
          <td class="ww_skin_footer_connect_info_icon" title="Fax" wwpage:attribute-title="fax-label"><i class="fa"></i></td>
          <td class="ww_skin_footer_connect_info_content" wwpage:content="company-fax">000-000-0000</td>
        </tr>
        <tr wwpage:condition="company-email-exists" class="ww_skin_footer_company_email">
          <td class="ww_skin_footer_connect_info_icon" title="E-Mail" wwpage:attribute-title="email-label"><i class="fa"></i></td>
          <td class="ww_skin_footer_connect_info_content"><a href="mailto:sales@webworks.com" wwpage:attribute-href="company-email-href" wwpage:content="company-email">sales@webworks.com</a></td>
        </tr>
      </table>
    </div>
    <div class="ww_skin_footer_end_content" wwpage:condition="company-copyright-exists, footer-publish-date-exists">
      <wwexsldoc:nobreak />
      <hr />
      <div class="ww_skin_footer_publish_date" wwpage:condition="footer-publish-date-exists" wwpage:content="publish-date">Publish Date</div>
      <div class="ww_skin_footer_company_copyright" wwpage:condition="company-copyright-exists" wwpage:content="company-copyright">Copyright &#169; 2024 WebWorks</div>
    </div>
  </div>
  <!-- All content above this comment contains the footer -->
  <!-- Any content after this comment will not be         -->
  <!-- copied into the Output. Custom stylesheets         -->
  <!-- should be added to Connect.asp, where this         -->
  <!-- content will also be added during generation       -->
  <!--                                                    -->
</body>
</html>
