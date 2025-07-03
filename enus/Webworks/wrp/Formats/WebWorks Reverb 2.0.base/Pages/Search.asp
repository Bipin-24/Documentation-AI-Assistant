<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:wwpage="urn:WebWorks-Page-Template-Schema" xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document" xml:lang="en" wwpage:attribute-xml-lang="locale" lang="en" wwpage:attribute-lang="locale" data-highlight-require-whitespace="true" wwpage:attribute-data-highlight-require-whitespace="highlight-require-whitespace">
<head>
  <wwpage:Block wwpage:condition="emit-mark-of-the-web" wwpage:replace="mark-of-the-web" />

  <meta http-equiv="Content-Type" content="text/html;charset=utf-8" wwpage:attribute-content="content-type" />
  <meta http-equiv="Content-Style-Type" content="text/css" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />

  <title wwpage:content="title">Search</title>

  <link rel="StyleSheet" href="css/font-awesome/css/all.min.css" wwpage:attribute-href="relative-to-output-root" />
  <link rel="StyleSheet" href="css/search.css" wwpage:attribute-href="copy-from-data-relative-to-output-root" type="text/css" media="all" />
  <link rel="StyleSheet" href="../css/skin.css" type="text/css" media="all" />
</head>
<body>
  <div id="page_loading"><i class="spin fa"></i></div>
  <input type="hidden" id="search_onload_url" value="" wwpage:attribute-value="search-onload-url" />
  <div class="ww_search_container">
    <div class="ww_search_content">
      <h2 class="search_title" wwpage:content="title">Search</h2>

      <!-- was search helpful button -->
      <!--                           -->
      <div class="ww_skin_was_this_helpful_container" wwpage:condition="search-helpful-buttons-enabled">
        <div class="ww_skin_was_this_helpful_message" wwpage:content="locales-search-helpful-message">Was this search helpful?</div>
        <div class="ww_skin_was_this_helpful_buttons_container">
          <div id="helpful_thumbs_up" class="ww_skin_was_this_helpful_button" title="Helpful" wwpage:attribute-title="helpful-button"><i class="far"></i></div>
          <div id="helpful_thumbs_down" class="ww_skin_was_this_helpful_button" title="Unhelpful" wwpage:attribute-title="unhelpful-button"><i class="far"></i></div>
        </div>
      </div>
      <div id="search_filter_message_container" class="ww_skin_search_filter_message_container" wwpage:condition="more-than-one-group search-scope-enabled">
        <span id="search_filter_by_message" wwpage:content="filter-message">Applied Filter: </span>
        <span id="search_filter_by_groups">All</span>
      </div>
      <div wwpage:condition="include-search-result-count" id="search_results_count_container">
        <span id="search_results_count_message" wwpage:content="results-count-message">Search results found: </span>
        <span id="search_results_count">0</span>
      </div>
      <div wwpage:condition="include-search-result-count" id="search_results_loading_container">
        <span id="search_results_loading_message" wwpage:content="results-loading-message">Searching...</span>
      </div>

      <div id="custom_search_engine">
        <div id="search_results_container"></div>
      </div>
    </div>
  </div>

  <script type="text/javascript" src="scripts/unidata.js" wwpage:attribute-src="copy-relative-to-output-root"></script>
  <script type="text/javascript" src="scripts/unibreak.js" wwpage:attribute-src="copy-relative-to-output-root"></script>
  <script type="text/javascript" src="scripts/common.js" wwpage:attribute-src="copy-relative-to-output-root"></script>
  <script type="text/javascript" src="scripts/search-client.js" wwpage:attribute-src="copy-relative-to-output-root"></script>
  <script type="text/javascript" src="../scripts/search.js"></script>
</body>
</html>
