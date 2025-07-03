<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:wwpage="urn:WebWorks-Page-Template-Schema" xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document" xml:lang="en" wwpage:attribute-xml-lang="locale" lang="en" wwpage:attribute-lang="locale">
<head>
  <wwpage:block wwpage:condition="emit-mark-of-the-web" wwpage:replace="mark-of-the-web" />

  <meta http-equiv="Content-Type" content="text/html;charset=utf-8" wwpage:attribute-content="content-type" />
  <meta http-equiv="Content-Style-Type" content="text/css" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />

  <link wwpage:condition="favicon-enabled" rel="icon" type="image/icon" href="#" wwpage:attribute-href="favicon-src" />

  <base target="connect_page" />

  <title wwpage:content="title">Title</title>

  <noscript>
    <div id='noscript_padding'></div>
  </noscript>

  <link rel="StyleSheet" href="css/font-awesome/css/all.min.css" type="text/css" media="all" />
  <link rel="StyleSheet" href="css/connect.css" wwpage:attribute-href="copy-from-data-relative-to-output-root" type="text/css" media="all" />
  <link rel="StyleSheet" href="css/skin.css" wwpage:attribute-href="copy-from-data-relative-to-output-root" type="text/css" media="all" />
  <link rel="StyleSheet" href="css/menu_initial_open.css" wwpage:attribute-href="copy-from-data-relative-to-output-root" type="text/css" wwpage:condition="menu-initial-state-open" media="all" />
  <link rel="StyleSheet" href="css/menu_initial_closed.css" wwpage:attribute-href="copy-from-data-relative-to-output-root" type="text/css" wwpage:condition="menu-initial-state-closed" media="all" />
</head>
<body id="connect_body" class="" wwpage:attribute-class="body-class" style="" wwpage:attribute-style="body-style">
  <div id="page_loading"><i class="spin fa"></i></div>
  <div id="layout_div" class="layout_initial">

    <!-- Presentation -->
    <!--              -->
    <div id="presentation_div" class="menu_initial" wwpage:attribute-class="presentation-div-initial-class">
      <!-- Header -->
      <!--        -->
      <div id="header_div">
        <div wwpage:replace="header-content"></div>
      </div>
      <!-- Toolbar -->
      <!--         -->
      <div id="toolbar_div">
        <table class="ww_skin_toolbar" cellpadding="0" cellspacing="0">
          <tr>
            <td class="ww_skin_toolbar_cluster ww_skin_toolbar_cluster_left">
              <wwexsldoc:nobreak />

              <div class="ww_skin_toolbar_logo_spacer">
                <div class="ww_skin_menu_button_container" wwpage:condition="menu-enabled">
                  <!--<span class="ww_skin_menu ww_skin_menu_toggle_button">-->
                  <span class="ww_skin_menu_toggle_button">
                    <a class="ww_behavior_menu ww_skin ww_skin_menu ww_skin_menu_toggle_button" title="Menu" wwpage:attribute-title="menu-button-title" href="#">
                      <i class="fa"></i>
                    </a>
                  </span>
                </div>
                <div class="ww_skin_toolbar_logo_container ww_skin_toolbar_logo_container_empty" wwpage:condition="toolbar-logo-disabled"></div>
                <div class="ww_skin_toolbar_logo_container" wwpage:condition="toolbar-logo-enabled linked-toolbar-logo-enabled">
                  <a id="toolbar_logo_link" class="" wwpage:attribute-class="toolbar-logo-link-class" href="#" wwpage:attribute-href="toolbar-logo-link" wwpage:condition="toolbar-logo-link-exists">
                    <img class="ww_skin_toolbar_logo" src="images/logo.gif" wwpage:condition="toolbar-logo-override-exists" wwpage:attribute-src="toolbar-logo-src" />
                    <img class="ww_skin_toolbar_logo" src="images/logo.gif" wwpage:condition="company-logo-for-toolbar-logo company-logo-src-exists toolbar-logo-override-not-exists" wwpage:attribute-src="company-logo-src" />
                    <div class="ww_skin_toolbar_logo" wwpage:condition="company-name-for-toolbar-logo company-name-exists toolbar-logo-override-not-exists">
                      <span wwpage:content="company-name">Company Name</span>
                    </div>
                  </a>
                </div>
                <div class="ww_skin_toolbar_logo_container" wwpage:condition="toolbar-logo-enabled linked-toolbar-logo-disabled">
                  <img class="ww_skin_toolbar_logo" src="images/logo.gif" wwpage:condition="toolbar-logo-override-exists" wwpage:attribute-src="toolbar-logo-src" />
                  <img class="ww_skin_toolbar_logo" src="images/logo.gif" wwpage:condition="company-logo-for-toolbar-logo company-logo-src-exists toolbar-logo-override-not-exists" wwpage:attribute-src="company-logo-src" />
                  <div class="ww_skin_toolbar_logo" wwpage:condition="company-name-for-toolbar-logo company-name-exists toolbar-logo-override-not-exists">
                    <span wwpage:content="company-name">Company Name</span>
                  </div>
                </div>
              </div>
            </td>

            <td class="ww_skin_toolbar_cluster ww_skin_toolbar_cluster_search">
              <wwexsldoc:nobreak />
              <form class="ww_skin_search_form" method="get">
                <wwexsldoc:nobreak />

                <span class="ww_skin_toolbar_button_left ww_skin_toolbar_background_default ww_skin_toolbar_button_enabled ww_skin_search_form_inner">
                  <wwexsldoc:nobreak />
                  <table class="ww_skin_search_table">
                    <tr>
                      <!-- Search Scope button -->
                      <!--                     -->
                      <td id="search_scope_container" class="ww_skin_search_scope_container selector_options_closed">
                        <div id="search_scope" class="ww_skin_search_scope_selector" wwpage:condition="more-than-one-group search-scope-enabled">
                          <div class="ww_skin_search_scope_selector_value">
                            <span id="search_scope_value"></span>
                          </div>
                          <div class="ww_skin_search_scope_selector_caret">
                            <i class="fa"></i>
                          </div>
                        </div>
                        <div id="search_scope_options" class="ww_skin_search_scope_options" wwpage:condition="more-than-one-group search-scope-enabled"></div>
                      </td>
                      <td id="search_input_container" class="ww_skin_search_input_container">
                        <input id="search_input" class="ww_skin_search_input" autofocus="true" placeholder="" wwpage:attribute-placeholder="search-input-placeholder" />
                      </td>
                      <td class="ww_skin_search_button_container_outer">
                        <div class="ww_skin_search_button_container_inner">
                          <a class="ww_behavior_search ww_skin ww_skin_search ww_skin_search_button" title="Search" wwpage:attribute-title="search-button-title" href="#">
                            <i class="fa"></i>
                          </a>
                        </div>
                      </td>
                    </tr>
                  </table>
                </span>
              </form>
            </td>

            <!-- Search bar, nav buttons -->
            <!--                         -->
            <td class="ww_skin_toolbar_cluster ww_skin_toolbar_cluster_right">
              <div class="ww_skin_toolbar_menu_spacer ww_skin_toolbar_button_spacer">
                <wwexsldoc:nobreak />
                <span class="ww_skin_toolbar_button_right ww_skin_toolbar_background_default ww_skin_toolbar_button_disabled">
                  <wwexsldoc:nobreak />
                  <a class="ww_behavior_prev ww_skin ww_skin_button ww_skin_prev" title="Previous" wwpage:attribute-title="previous-button-title" href="#">
                    <i class="fa"></i>
                  </a>
                </span>
                <span class="ww_skin_toolbar_button_right ww_skin_toolbar_background_default ww_skin_toolbar_button_disabled">
                  <wwexsldoc:nobreak />
                  <a class="ww_behavior_next ww_skin ww_skin_button ww_skin_next" title="Next" wwpage:attribute-title="next-button-title" href="#">
                    <i class="fa"></i>
                  </a>
                </span>
                <span wwpage:condition="home-enabled" class="ww_skin_toolbar_button_left ww_skin_toolbar_background_default ww_skin_toolbar_button_disabled">
                  <wwexsldoc:nobreak />
                  <a class="ww_behavior_home ww_skin ww_skin_button ww_skin_home" title="Home" wwpage:attribute-title="home-button-title" href="#">
                    <i class="fa"></i>
                  </a>
                </span>
                <span wwpage:condition="globe" class="ww_skin_toolbar_button_right ww_skin_toolbar_background_default ww_skin_toolbar_button_enabled">
                  <wwexsldoc:nobreak />
                  <a class="ww_behavior_globe ww_skin ww_skin_button ww_skin_globe" title="Translate" wwpage:attribute-title="translate-button-title" href="#">
                    <i class="fa"></i>
                  </a>
                </span>
              </div>
            </td>
          </tr>
        </table>
        <table wwpage:condition="toolbar-tabs-enabled" class="ww_skin_toolbar_tabs_container" cellpadding="0" cellspacing="0">
          <tr>
            <td id="tab_content">
              <ul class="ww_skin_toolbar_tab_group">
                <li wwpage:replace="toolbar-tabs">
                  <div class="ww_skin_toolbar_tab">
                    <a href="connect/splash.html" title="Home">
                      Home
                    </a>
                  </div>
                </li>
              </ul>
            </td>
          </tr>
        </table>
      </div>

      <!-- Container -->
      <!--           -->
      <div id="container_div">
        <!-- Menu  -->
        <!--       -->
        <div id="menu_frame" class="ww_skin_menu_frame">
          <wwexsldoc:nobreak />

          <div id="menu_content" class="ww_skin_menu_content" wwpage:condition="menu-enabled"></div>
        </div>
        <div id="menu_backdrop"></div>

        <!-- Page -->
        <!--      -->
        <div id="page_div">
          <wwexsldoc:nobreak />
          <div id="popup_div">
            <wwexsldoc:nobreak />
            <iframe id="popup_iframe" name="connect_popup" frameborder="0"></iframe>
          </div>
          <iframe id="page_iframe" name="connect_page" frameborder="0" width="100%" height="100%"></iframe>
          <div wwpage:condition="footer-location-page-end" wwpage:replace="footer-content"></div>
        </div>

        <!-- Search -->
        <!--        -->
        <div id="search_div" class="ww_skin_search_background">
          <div id="search_title">&#160;</div>
          <iframe id="search_iframe" name="connect_search" frameborder="0" width="100%" height="100%" src="connect/search.html"></iframe>
          <div wwpage:condition="footer-location-page-end" wwpage:replace="footer-content"></div>
        </div>

        <!-- Footer -->
        <!--        -->
        <div id="footer_div">
          <div wwpage:condition="footer-location-layout-end" wwpage:replace="footer-content"></div>
        </div>
      </div>

      <!-- Back to Top -->
      <!--             -->
      <div wwpage:condition="back-to-top-enabled" id="back_to_top" class="ww_skin_page_back_to_top back_to_top">
        <wwexsldoc:nobreak />

        <a class="ww_behavior_back_to_top" href="#" title="To top" wwpage:attribute-title="back-to-top-title">&#160;</a>
      </div>
    </div>
  </div>

  <!-- Panels -->
  <!--        -->
  <div id="panels">
    <!-- Menu Nav Buttons -->
    <!--                  -->
    <div id="nav_buttons_div">
      <div class="ww_skin_menu_nav">
        <div class="ww_skin_menu_type_selector" wwpage:condition="menu-enabled">
          <span class="ww_skin_menu_nav_type ww_skin_menu_nav_type_toc" wwpage:condition="toc-enabled">
            <a class="ww_behavior_toc ww_skin ww_skin_menu_toc" title="TOC" wwpage:attribute-title="toc-button-title" href="#">
              <i class="fa"></i>
            </a>
          </span>
          <span class="ww_skin_menu_nav_type ww_skin_menu_nav_type_index" wwpage:condition="index-enabled">
            <a class="ww_behavior_index ww_skin ww_skin_menu_index" title="Index" wwpage:attribute-title="index-button-title" href="#">
              <i class="fa"></i>
            </a>
          </span>
        </div>
      </div>
    </div>

    <!-- TOC -->
    <!--     -->
    <div id="toc" class="ww_skin_toc_background ww_skin_toc_container">
      <div id="toc_title">&#160;</div>
      <div id="toc_content" class="toc_icons_left" wwpage:attribute-class="toc-content-class">
        Table of Contents
      </div>
    </div>

    <!-- Index -->
    <!--       -->
    <div id="index" class="ww_skin_index_background">
      <div id="index_title">&#160;</div>
      <div id="index_content">
        Index
      </div>
    </div>
  </div>

  <!-- Lightbox -->
  <!--          -->
  <div id="lightbox_background" class="ww_skin_lightbox_background">
    <div class="ww_skin_lightbox_close_container">
      <span id="lightbox_close" class="ww_skin ww_skin_lightbox_close">
        <i class="fa"></i>
      </span>
    </div>
    <div id="lightbox_frame" class="ww_skin_lightbox_frame">
      <div id="lightbox_content" class="ww_skin_lightbox_content">&#160;</div>
    </div>
  </div>

  <!-- Parcels -->
  <!--         -->
  <div id="parcels" wwpage:content="parcels">
    Parcel list.
  </div>

  <div id="unsupported_browser_container">
    <div id="unsupported_browser" wwpage:replace="unsupported-browser-content">
      This browser is not supported
    </div>
  </div>

  <noscript>
    <div id='noscript_warning' wwpage:content="locales-no-javascript-message">
      This site works best with JavaScript enabled
    </div>
  </noscript>

  <script type="text/javascript" src="scripts/analytics.js" wwpage:condition="google-analytics-enabled"></script>
  <script type="text/javascript" src="scripts/common.js" wwpage:attribute-src="copy-relative-to-output-root"></script>
  <script type="text/javascript" src="scripts/menu.js" wwpage:attribute-src="copy-relative-to-output-root"></script>
  <script type="text/javascript" src="scripts/scope.js" wwpage:attribute-src="copy-relative-to-output-root" wwpage:condition="more-than-one-group search-scope-enabled"></script>
  <script type="text/javascript" src="scripts/connect.js"></script>
</body>
</html>
