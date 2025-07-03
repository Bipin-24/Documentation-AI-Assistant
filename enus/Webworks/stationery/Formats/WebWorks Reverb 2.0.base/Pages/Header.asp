<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:wwpage="urn:WebWorks-Page-Template-Schema" xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document" xml:lang="en" wwpage:attribute-xml-lang="locale" wwpage:attribute-lang="locale" data-highlight-require-whitespace="true" wwpage:attribute-data-highlight-require-whitespace="highlight-require-whitespace">
<head>
  <title>Header</title>
</head>
<body>
  <!-- All content below this comment contains the header -->
  <!-- Any content above this comment will not be         -->
  <!-- copied into the Output. Custom stylesheets         -->
  <!-- should be added to Connect.asp, where this         -->
  <!-- content will also be added during generation       -->
  <!--                                                    -->
  <div class="ww_skin_header" wwpage:condition="header-enabled">
    <div class="ww_skin_header_logo_container_outer" wwpage:condition="header-logo-enabled">
      <div class="ww_skin_header_logo_container" wwpage:condition="header-logo-enabled linked-header-logo-enabled">
        <a id="header_logo_link" class="" wwpage:attribute-class="header-logo-link-class" href="#" wwpage:attribute-href="header-logo-link" wwpage:condition="header-logo-link-exists">
          <img class="ww_skin_header_logo" src="images/logo.gif" wwpage:condition="header-logo-override-exists" wwpage:attribute-src="header-logo-src" />
          <img class="ww_skin_header_logo" src="images/logo.gif" wwpage:condition="company-logo-for-header-logo company-logo-src-exists header-logo-override-not-exists" wwpage:attribute-src="company-logo-src" />
          <div class="ww_skin_header_logo" wwpage:condition="company-name-for-header-logo company-name-exists header-logo-override-not-exists">
            <span wwpage:content="company-name">Company Name</span>
          </div>
        </a>
      </div>
      <div class="ww_skin_header_logo_container" wwpage:condition="header-logo-enabled linked-header-logo-disabled">
        <img class="ww_skin_header_logo" src="images/logo.gif" wwpage:condition="header-logo-override-exists" wwpage:attribute-src="header-logo-src" />
        <img class="ww_skin_header_logo" src="images/logo.gif" wwpage:condition="company-logo-for-header-logo company-logo-src-exists header-logo-override-not-exists" wwpage:attribute-src="company-logo-src" />
        <div class="ww_skin_header_logo" wwpage:condition="company-name-for-header-logo company-name-exists header-logo-override-not-exists">
          <span wwpage:content="company-name">Company Name</span>
        </div>
      </div>
    </div>
    <div class="ww_skin_header_company_info" wwpage:condition="company-info-exists">

      <table class="ww_skin_header_connect_info" wwpage:condition="company-phone-exists, company-fax-exists, company-email-exists">
        <tr wwpage:condition="company-phone-exists" class="ww_skin_header_company_phone">
          <td class="ww_skin_header_connect_info_icon" title="Phone" wwpage:attribute-title="phone-label"><i class="fa"></i></td>
          <td class="ww_skin_header_connect_info_content" wwpage:content="company-phone">000-000-0000</td>
        </tr>
        <tr wwpage:condition="company-fax-exists" class="ww_skin_header_company_fax">
          <td class="ww_skin_header_connect_info_icon" title="Fax" wwpage:attribute-title="fax-label"><i class="fa"></i></td>
          <td class="ww_skin_header_connect_info_content" wwpage:content="company-fax">000-000-0000</td>
        </tr>
        <tr wwpage:condition="company-email-exists" class="ww_skin_header_company_email">
          <td class="ww_skin_header_connect_info_icon" title="E-Mail" wwpage:attribute-title="email-label"><i class="fa"></i></td>
          <td class="ww_skin_header_connect_info_content"><a href="mailto:sales@webworks.com" wwpage:attribute-href="company-email-href" wwpage:content="company-email">sales@webworks.com</a></td>
        </tr>
      </table>
    </div>
  </div>
  <!-- All content above this comment contains the header -->
  <!-- Any content after this comment will not be         -->
  <!-- copied into the Output. Custom stylesheets         -->
  <!-- should be added to Connect.asp, where this         -->
  <!-- content will also be added during generation       -->
  <!--                                                    -->
</body>
</html>