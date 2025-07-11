'use strict';
// Copyright (c) 2010-2024 Quadralay Corporation.  All rights reserved.
//
// ePublisher 2024.1
//

// IMPORTANT: global variables are modified by connect.xsl and should not be changed.
var GLOBAL_SHOW_FIRST_DOCUMENT = true;
var GLOBAL_NAVIGATION_MIN_PAGE_WIDTH = 900;
var GLOBAL_LIGHTBOX_LARGE_IMAGES = true;
var GLOBAL_DISQUS_ID = '';
var GLOBAL_EMAIL = '';
var GLOBAL_EMAIL_MESSAGE = 'Feedback: $Location;';
var GLOBAL_FOOTER_END_OF_LAYOUT = true;
var GLOBAL_SEARCH_TITLE = 'Search Results';
var GLOBAL_SEARCH_SCOPE_ALL_LABEL = 'All';
var GLOBAL_SEARCH_QUERY_MIN_LENGTH = 4;
var GLOBAL_PROGRESSIVE_SEARCH_ENABLED = true;
var GLOBAL_USE_MERGED_INDEX = true;
var GLOBAL_NOT_FOUND_PAGE_ENABLED = true;

var Connect_Window = window;
Connect_Window.name = 'connect_main';

// Lightbox
//
function Lightbox_Show() {
  // Set up the background
  //
  this.lightbox_background.style.display = 'block';

  // Configure the frame
  //
  this.lightbox_frame.style.visibility = 'visible';
}

function Lightbox_Hide() {
  // Hide lightbox
  //
  this.lightbox_frame.style.visibility = 'hidden';
  this.lightbox_background.style.display = 'none';

  // Teardown
  //
  if (this.teardown !== undefined && this.teardown !== null) {
    this.teardown(this.lightbox_frame, this.lightbox_content);
    this.teardown = undefined;
  }
}

function Lightbox_Display(param_setup, param_teardown) {
  var this_lightbox;

  // Setup
  //
  param_setup(this.lightbox_frame, this.lightbox_content);

  // Configure teardown
  //
  this.teardown = param_teardown;

  // Show!
  //
  this_lightbox = this;
  Connect_Window.setTimeout(function () {
    this_lightbox.Show();
  });
}

function Lightbox_Object(param_connect) {
  var this_lightbox;

  this.connect = param_connect;

  this.lightbox_background = Connect_Window.document.getElementById('lightbox_background');
  this.lightbox_frame = Connect_Window.document.getElementById('lightbox_frame');
  this.lightbox_content = Connect_Window.document.getElementById('lightbox_content');
  this.lightbox_close = Connect_Window.document.getElementById('lightbox_close');
  this.teardown = undefined;

  this_lightbox = this;
  this.page_iframe = Connect_Window.document.getElementById('page_iframe');
  this.lightbox_close.onclick = function () {
    this_lightbox.Hide();
  };
  this.lightbox_background.onclick = function () {
    this_lightbox.Hide();
  };

  this.Show = Lightbox_Show;
  this.Hide = Lightbox_Hide;
  this.Display = Lightbox_Display;
}

// Parcels
//
var Parcels = {
  all_parcels: [],
  anchors: [],
  context_ids: {},
  current_parcels: { '_all_': true },
  div: Connect_Window.document.getElementById('parcels'),
  entries: {},
  ids: [],
  index: [],
  loaded_initial: false,
  loaded_all: false,
  loading_remaining: false,
  loaded_callbacks: [],
  prefixes: {},
  required: [],
  required_loaded: 0,
  remaining: [],
  remaining_loaded: 0,
  search: [],
  title: {}
};

Parcels.all_parcels = function () {
  // load parcel names into a list for reference
  var result, parcel_elements;

  result = [];

  parcel_elements = Parcels.div.querySelectorAll('li[data-group-title]');

  for (var i = 0;i < parcel_elements.length;i++) {
    var parcel_element, parcel_title;

    parcel_element = parcel_elements[i];
    parcel_title = parcel_element.getAttribute('data-group-title');

    result.push(parcel_title);
  }

  return result;
}();

Parcels.PrepareForLoad = function () {
  var parcel_anchors, parcel_anchor, parcel_context_and_id, parcel_context, parcel_id, parcel_title;

  Parcels.entries = {};
  Parcels.required = [];
  Parcels.required_loaded = 0;
  Parcels.remaining = [];
  Parcels.remaining_loaded = 0;
  Parcels.anchors = [];
  Parcels.ids = [];
  Parcels.context_ids = {};
  Parcels.prefixes = {};
  Parcels.prefixes[Navigation.base_url + 'connect/'] = true;

  if (Navigation.url_handler_object['parcels']) {
    Parcels.current_parcels['_all_'] = false;
  }

  Connect.toc_content_div.innerHTML = Parcels.CreateHTML();

  parcel_anchors = Connect.toc_div.getElementsByTagName('a');
  Parcels.div.style.display = 'none';

  if (parcel_anchors.length === 0) {
    parcel_anchors = Connect_Window.document.links;
  }

  for (var index = 0;index < parcel_anchors.length;index += 1) {
    parcel_anchor = parcel_anchors[index];
    Parcels.anchors[Parcels.anchors.length] = parcel_anchor;

    // Add to collection of valid parcels
    //
    parcel_context_and_id = parcel_anchor.id.split(':');
    if (parcel_context_and_id[0] !== '') {
      parcel_context = parcel_context_and_id[0];
      parcel_id = parcel_context_and_id[1];
      parcel_title = Browser.DecodeURIComponent(parcel_anchor.innerText);

      Parcels.current_parcels[parcel_title] = true;

      Parcels.Add(parcel_context, parcel_id, parcel_anchor.href, parcel_title);

      // Add to search scopes
      //
      if (Connect.scope_enabled) {
        Scope.AddSearchScope(parcel_anchor, parcel_id, parcel_context, index);
      }
    }
  }

  if (Connect.scope_enabled) {
    Scope.search_scope_selections = ['all'];
    Scope.RenderScopeSelector(Connect_Window.document, Scope.search_scopes);
    Scope.WriteSelectionsString();
  }
};

Parcels.Load = function () {
  // Begin loading parcels
  //
  var required_and_remaining_parcel_anchors, on_parcel_load, on_parcel_load_done, on_parcels_complete;

  Parcels.PrepareForLoad();

  // Configure parcel TOC levels
  //
  Connect.ConfigureTOCLevels(Connect.toc_div, 0);

  // Configure Tabs
  //
  Connect.ConfigureTabs(Connect.toolbar_div);

  // Determine required and remaining parcels
  //
  required_and_remaining_parcel_anchors = Parcels.DetermineRequiredAndRemaining();
  Parcels.required = required_and_remaining_parcel_anchors.required;
  Parcels.remaining = required_and_remaining_parcel_anchors.remaining;

  on_parcel_load = function () {
    this.iframe_container = document.createElement('div');
    this.iframe_container.id = 'ajax_iframe_container_' + this.id;
    this.iframe_container.style.visibility = 'hidden';

    document.body.appendChild(this.iframe_container);

    this.iframe_container.innerHTML = '<iframe src="' + this.entry.href + '"></iframe>';
  };

  on_parcel_load_done = function () {
    document.body.removeChild(this.iframe_container);

    Parcels.AddData(this.entry, this.content);
    Parcels.required_loaded = Parcels.required_loaded + 1;

    this.loaded = true;

    if (Parcels.required_loaded === Parcels.required.length) {
      this.complete();
    }
  };

  on_parcels_complete = function () {
    // Display specified document
    //
    Parcels.loaded_initial = true;

    // Check for hash changes
    //
    if ('onhashchange' in Connect_Window && typeof Connect_Window.history.pushState === 'function') {
      // Events are so nice!
      //
      Connect_Window.onhashchange = Navigation.HashChanged;
    } else {
      // Poll
      //
      Connect.poll_onhashchange = function () {
        Navigation.HashChanged();

        Connect_Window.setTimeout(Connect.poll_onhashchange, 100);
      };
      Connect_Window.setTimeout(Connect.poll_onhashchange);
    }

    if (Parcels.remaining.length === 0) {
      Parcels.loaded_all = true;
    }

    // Done!
    //
    Navigation.Navigate(Connect_Window.location.href);
    Connect.loading = false;

    // Need to load remaining parcels?
    //
    if (!Parcels.loaded_all) {
      // Complete parcel loading
      //
      Parcels.LoadRemaining();
    }

    // Show
    //
    Connect.presentation_div.style.visibility = 'visible';
  };

  for (var i = 0;i < Parcels.required.length;i++) {
    var parcel_entry, parcel;

    parcel_entry = Parcels.required[i];

    parcel = new Parcel_Object(parcel_entry, on_parcel_load, on_parcel_load_done, on_parcels_complete);

    Parcels.entries[parcel.id] = parcel;
    parcel.load();
  }
};

Parcels.LoadRemaining = function () {
  var on_parcel_load, on_parcel_load_done, on_parcels_complete;

  Parcels.loading_remaining = true;

  on_parcel_load = function () {
    this.iframe_container = document.createElement('div');
    this.iframe_container.id = 'ajax_iframe_container_' + this.id;
    this.iframe_container.style.visibility = 'hidden';

    document.body.appendChild(this.iframe_container);

    this.iframe_container.innerHTML = '<iframe src="' + this.entry.href + '"></iframe>';
  };

  on_parcel_load_done = function () {
    document.body.removeChild(this.iframe_container);

    Parcels.AddData(this.entry, this.content);
    this.loaded = true;
    Parcels.remaining_loaded = Parcels.remaining_loaded + 1;

    if (Parcels.remaining_loaded === Parcels.remaining.length) {
      Parcels.loading_remaining = false;
      Parcels.remaining_complete = true;
      this.complete();
    }
  };

  on_parcels_complete = function () {
    Parcels.loaded_all = true;
  };

  for (var i = 0;i < Parcels.remaining.length;i++) {
    var parcel_entry, parcel;

    parcel_entry = Parcels.remaining[i];

    parcel = new Parcel_Object(parcel_entry, on_parcel_load, on_parcel_load_done, on_parcels_complete);

    Parcels.entries[parcel.id] = parcel;
    parcel.load();
  }
};

Parcels.DetermineRequiredAndRemaining = function () {
  var result, context_signature,
    context_and_topic, topic_index, topic_only,
    page_signature, page_base_relative_url,
    parcel_anchor, required_parcel_anchor,
    handler_object;

  result = { required: [], remaining: [] };

  handler_object = Navigation.url_handler_object;

  // Determine requested page or context signature
  //
  context_signature = null;
  topic_only = false;

  if (handler_object['context'] !== undefined) {
    // Context/topic requested
    //
    context_and_topic = handler_object['context'];
    topic_index = context_and_topic.indexOf('/');

    if (topic_index === -1) {
      topic_only = true;
    }

    context_signature = context_and_topic.substring(0, topic_index) + ':';
  }

  page_signature = null;

  if (handler_object['page'] !== undefined) {
    page_base_relative_url = handler_object['page'];

    // Ignore top-level files
    //
    if (page_base_relative_url.indexOf('/') >= 0 || page_base_relative_url.indexOf('%2f') >= 0 || page_base_relative_url.indexOf('%2F') >= 0) {
      // Build secure URI
      //
      page_base_relative_url = Browser.DecodeURIComponent(page_base_relative_url);
      page_base_relative_url = page_base_relative_url.replace(/[\\<>:;"]|%5C|%3C|%3E|%3A|%3B|%22/gi, '');

      page_signature = page_base_relative_url.split('/')[0] + '.';
    }
  }

  // Check parcel anchors for a match against context or page signature
  //
  for (var i = 0; i < Parcels.anchors.length; i += 1) {
    parcel_anchor = Parcels.anchors[i];

    // Required parcel?
    //
    required_parcel_anchor = false;
    if (i === 0) {
      // Always load first parcel
      //
      required_parcel_anchor = true;
    } else if (context_signature !== null && parcel_anchor.id.indexOf(context_signature) === 0) {
      // Captures exactly what we need
      //
      required_parcel_anchor = true;
    } else if (page_signature !== null && parcel_anchor.href.indexOf(page_signature) > 0) {
      // May capture more than we need
      //
      required_parcel_anchor = true;
    } else if (topic_only) {
      // Load all parcels if we have a topic without context
      //
      required_parcel_anchor = true;
    }

    // Assign parcel
    //
    if (required_parcel_anchor) {
      result.required.push(parcel_anchor);
    } else {
      result.remaining.push(parcel_anchor);
    }
  }

  return result;
};

Parcels.Add = function (param_parcel_context, param_parcel_id, param_parcel_url, param_parcel_title) {
  var parcel_directory_url;

  parcel_directory_url = param_parcel_url.substring(0, param_parcel_url.lastIndexOf('.'));

  // Track context
  //
  Parcels.context_ids[param_parcel_context] = param_parcel_id;

  // Include original file and directory prefix
  //
  Parcels.prefixes[param_parcel_url] = true;
  Parcels.prefixes[parcel_directory_url] = true;
  Parcels.index.push({ 'id': param_parcel_id, 'url': parcel_directory_url + '_ix.html' });
  Parcels.search.push(parcel_directory_url + '_sx.js');
  Parcels.title[param_parcel_id] = param_parcel_title;
  Parcels.ids[Parcels.ids.length] = param_parcel_id;
};

Parcels.AddData = function (param_entry, param_content) {
  var parcel_div, parcel_context_and_id, parcel_id,
    parcel_toc_div_id, parcel_toc_div, parcel_toc_ul,
    toc_layout_li, level_offset, parcel_data_div_id,
    parcel_data_div;

  // Access parcel
  //
  parcel_div = Connect_Window.document.createElement('div');
  parcel_div.style.visibility = 'hidden';
  parcel_div.innerHTML = param_content;
  Connect_Window.document.body.appendChild(parcel_div);

  // Gather all of the "Data" links, no longer necessary to include the "TOC" links
  //
  var parcel_links = parcel_div.querySelectorAll('div[id*="page:"] a');

  for (var i = 0; i < parcel_links.length; i++) {
    var parcel_link = parcel_links[i];
    var link_href = parcel_link.href;

    if (!link_href) {
      continue;
    }

    // Remove hash from link
    //
    if (link_href.indexOf('#') > -1) {
      link_href = link_href.substring(0, link_href.indexOf('#'));
    }

    // Add if unique
    //
    Navigation.AddPageURL(link_href);
  }

  // Add to collection of valid parcels
  //
  parcel_context_and_id = param_entry.id.split(':');
  parcel_id = parcel_context_and_id[1];

  // TOC
  //
  parcel_toc_div_id = 'toc:' + parcel_id;
  parcel_toc_div = Connect_Window.document.getElementById(parcel_toc_div_id);
  if (parcel_toc_div !== null) {
    parcel_toc_ul = Browser.FirstChildElementWithTagName(parcel_toc_div, 'ul');
    if (parcel_toc_ul !== null) {
      // Extract TOC data
      //
      if (Parcels.ids.length === 1) {
        // Suppress parcel (group) folder
        //
        toc_layout_li = param_entry.parentNode.parentNode.parentNode.parentNode;
      } else {
        // Preserve parcel (group) folder
        //
        toc_layout_li = param_entry.parentNode.parentNode;
      }

      // Ensure TOC data initially collapsed when appended
      //
      parcel_toc_ul.className = 'ww_skin_toc_container_closed';
      toc_layout_li.appendChild(parcel_toc_ul);

      // Configure TOC levels
      //
      if (Parcels.ids.length === 1) {
        Connect.ConfigureTOCLevels(Connect.toc_div, 0);
      } else {
        level_offset = Connect.DetermineTOCLevel(Connect.toc_div, toc_layout_li) - 1;
        Connect.ConfigureTOCLevels(toc_layout_li, level_offset);
      }
    }
  }

  // Data
  //
  parcel_data_div_id = 'data:' + parcel_id;
  parcel_data_div = Connect_Window.document.getElementById(parcel_data_div_id);
  if (parcel_data_div !== null) {
    Parcels.div.appendChild(parcel_data_div);
  }

  // Remove parcel data
  //
  Connect_Window.document.body.removeChild(parcel_div);

  // Disable parcel link
  //
  if (Parcels.ids.length === 1) {
    param_entry.parentNode.parentNode.parentNode.parentNode.removeChild(param_entry.parentNode.parentNode.parentNode);
  } else {
    Browser.RemoveAttribute(param_entry, 'href', '');
  }

  // Update "bridge" links
  //
  Navigation.link_bridge.Update();

  // Update prev/next
  //
  Navigation.UpdatePrevNext();
};

Parcels.CreateHTML = function () {
  var parcels_html, parcels_html_full;

  parcels_html = '';
  parcels_html_full = Parcels.div.innerHTML;

  if (Navigation.url_handler_object['parcels'] !== undefined) {
    var parcel_group_objects;

    parcel_group_objects = Parcels.CreateGroupObjects();

    if (parcel_group_objects.length > 0) {
      // Begin writing HTML
      //
      parcels_html += '<ul>';
      for (var i = 0; i < parcel_group_objects.length; i++) {
        // Loop through the group objects, and select the HTML from the master TOC
        // to create a subset
        var parcel_group_object, parcel_li_element;

        parcel_group_object = parcel_group_objects[i];
        parcel_li_element = parcel_group_object['li_element'];

        if (parcel_group_object['children'] !== undefined) {
          // Clear <ul> child from <li>
          // Create new <ul>
          // Select and append all <li> to the <ul> by child id
          // Append new <ul> to parent <li>
          var filtered_children_ul_element;

          filtered_children_ul_element = document.createElement('ul');

          for (var j = 0; j < parcel_group_object['children'].length; j++) {
            var child_id, child_li;

            child_id = parcel_group_object['children'][j];
            child_li = document.querySelector('li[id="group:' + child_id + '"]');

            if (child_li !== null) {
              filtered_children_ul_element.appendChild(child_li);
            }
          }

          for (var j = 0; j < parcel_li_element.children.length; j++) {
            // Find the ul element and replace it.
            if (parcel_li_element.children[j].nodeName === 'UL') {
              var children_ul_element;

              children_ul_element = parcel_li_element.children[j];

              parcel_li_element.removeChild(children_ul_element);
              parcel_li_element.appendChild(filtered_children_ul_element);
            }
          }

          parcel_li_element.outerHTML.toString();
        }

        parcels_html += parcel_li_element.outerHTML.toString();
      }
      parcels_html += '</ul>';
    }
    else {
      parcels_html = parcels_html_full;
    }
  }
  else {
    parcels_html = parcels_html_full;
  }

  return parcels_html;
};

Parcels.CreateGroupObjects = function () {
  var parcel_group_objects, parcel_group_objects_final,
    parcel_requested_ids, parcels_requested_titles,
    parcel_li_elements;

  parcel_group_objects = [];
  parcel_group_objects_final = [];
  parcel_requested_ids = [];

  parcels_requested_titles = Browser.DecodeURIComponent(Navigation.url_handler_object['parcels']).split('/');
  parcel_li_elements = Parcels.div.getElementsByTagName('li');

  for (var i = 0; i < parcel_li_elements.length; i++) {
    // Loop through all <li> elements, create an array of group object from them
    //
    // parcel_group_object = {
    //   'li_element': <element>, do we need?
    //   'id': <groupId>,
    //   'children': <array of groupIds (if applicable)>
    // }
    //
    var parcel_li, parcel_id, parcel_group_object;

    parcel_li = parcel_li_elements[i];
    parcel_id = parcel_li.id.replace('group:', '');

    parcel_group_object = {};
    parcel_group_object['li_element'] = parcel_li;
    parcel_group_object['id'] = parcel_id;

    if (parcel_id.split(':').length > 1) {
      parcel_group_object['children'] = parcel_id.split(':');
    }

    if (!Parcels.GroupObjectsContainsId(parcel_group_objects, parcel_group_object['id'])) {
      parcel_group_objects.push(parcel_group_object);
    }
  }

  for (var i = 0; i < parcels_requested_titles.length; i++) {
    // Loop through the titles of requested parcels,
    // select <li> by it's 'data-group-title- attribute,
    // strip the groupId from it's 'id' attribute,
    // add the groupId to a list of requested groupIds
    //
    var requested_parcel_title, requested_parcel_li, requested_parcel_id;

    requested_parcel_title = parcels_requested_titles[i];
    requested_parcel_li = document.querySelector('li[data-group-title="' + requested_parcel_title + '"]');

    if (requested_parcel_li !== null) {
      requested_parcel_id = requested_parcel_li.id.replace('group:', '');
      parcel_requested_ids.push(requested_parcel_id);
    } else {
      // invalid parcel name

    }
  }

  for (var i = 0; i < parcel_group_objects.length; i++) {
    // Loop through the array of group objects
    //
    var parcel_group_object;

    parcel_group_object = parcel_group_objects[i];

    for (var j = 0; j < parcel_requested_ids.length; j++) {
      // Loop through the requested parcel groupIds
      //
      var parcel_requested_id;

      parcel_requested_id = parcel_requested_ids[j];

      if (parcel_requested_id !== '') {
        if (parcel_group_object['children'] !== undefined &&
          parcel_group_object['children'].indexOf(parcel_requested_id) > -1) {
          // If the current group object has children,
          // and the current requested id is in the list of children,
          // create an empty list for selected children
          //
          var children;

          children = [];

          for (var k = 0; k < parcel_group_object['children'].length; k++) {
            // Loop through the group object's children
            // if the list of requested ids contains the current child,
            // add the id to the new list of children,
            // and clear the id from the requested list
            // (to prevent duplicates, and retain the parent/child relationship for later)
            //
            var child;

            child = parcel_group_object['children'][k];

            if (parcel_requested_ids.indexOf(child) > -1) {
              children.push(child);
              parcel_requested_ids[parcel_requested_ids.indexOf(child)] = '';
            }
          }

          // Replace the full list of children on the group object
          // with the new list that only contains requested children
          //
          parcel_group_object['children'] = children;

          if (parcel_group_objects_final.indexOf(parcel_group_object) === -1) {
            parcel_group_objects_final.push(parcel_group_object);
          }
        } else if (parcel_group_object['id'] === parcel_requested_id) {
          // If the requested id does not match a child of the group object,
          // but matches the id of the group object, it is a top-level group.
          // Add it if it is not already present.
          if (parcel_group_objects_final.indexOf(parcel_group_object) === -1) {
            parcel_group_objects_final.push(parcel_group_object);
          }
        }
      }
    }
  }

  return parcel_group_objects_final;
};

Parcels.GroupObjectsContainsId = function (param_parcel_group_objects, param_id) {
  var parcel_group_objects, parcel_group_object, array_contains_id;

  parcel_group_objects = param_parcel_group_objects;
  array_contains_id = false;

  for (var i = 0; i < parcel_group_objects.length; i++) {
    parcel_group_object = parcel_group_objects[i];

    if (parcel_group_object['id'] === param_id) {
      array_contains_id = true;
    }
  }

  return array_contains_id;
};

// Index
//
var Index = {
  data: {},
  index_objects: {},
  is_merged: GLOBAL_USE_MERGED_INDEX,
  loaded: false,
  loading: false
}

Index.Load = function () {
  var index, parcel_id, parcel_entry_placeholder_div;

  // All parcels loaded?
  //
  if (!Parcels.loaded_all) {
    // Wait for all parcel data to be loaded
    //
    Connect_Window.setTimeout(Index.Load, 100);
    return;
  }

  Index.index_objects = {};
  Connect.index_entries_loaded = 0;

  for (var i = 0; i < Parcels.index.length; i++) {
    var index_entry = Parcels.index[i];

    var index_object = new Index_Object(
      // param_entry
      index_entry,
      // param_load
      function () {
        this.iframe_container = document.createElement('div');
        this.iframe_container.id = 'ajax_iframe_container_' + this.id;
        this.iframe_container.style.visibility = 'hidden';

        document.body.appendChild(this.iframe_container);

        this.iframe_container.innerHTML = '<iframe src="' + this.entry.url + '"></iframe>';
      },
      // param_done
      function () {
        document.body.removeChild(this.iframe_container);

        Index.AddData(this.entry, this.content);
        this.loaded = true;

        Connect.index_entries_loaded = Connect.index_entries_loaded + 1;

        if (Connect.index_entries_loaded === Parcels.index.length) {
          this.complete();
        }
      },
      // param_complete
      function () {
        var button_span;

        Index.RenderHTML();

        // Parcel indexes loaded!
        //
        Index.loaded = true;

        // Intercept all clicks
        //
        Browser.ApplyToChildElementsWithTagName(
          Connect.index_div,
          'a',
          function (param_link) {
            param_link.onclick = Index.OnLinkClick;
          }
        );

        // Done!
        //
        button_span = Connect.buttons['ww_behavior_index'];

        // Menu currently displayed?
        //
        if (button_span && Connect.Menu.menu_mode_visible === 'index') {
          // On stage!
          //
          Connect.Menu.menu_content.appendChild(Connect.index_div);
        }
      }
    );

    Index.index_objects[index_object.id] = index_object;
    index_object.load();
  }
};

Index.AddData = function (param_entry, param_content) {
  var parcel_data, parcel_entry_div_id, parcel_entry_div,
    parcel_index_div_id, parcel_index_div, parcel_index_json;

  try {
    parcel_index_json = JSON.parse(param_content)
  } catch (error) {
    console.error(error);
  }

  if (typeof parcel_index_json !== 'object') {
    // can't do anything if it didn't parse right
    return;
  }

  if (Index.is_merged) {
    if (Index.data['ww_merged_index'] === undefined) {
      Index.data['ww_merged_index'] = {}
    }

    // merge parcel_index_json into existing ww_merged_index property
    for (var section_id in parcel_index_json) {
      if (!Index.data['ww_merged_index'][section_id]) {
        Index.data['ww_merged_index'][section_id] = []
      }

      var section = parcel_index_json[section_id]

      for (var i = 0; i < section.length; i++) {
        var index_entry = section[i];
        Index.data['ww_merged_index'][section_id].push(index_entry)
      }
    }
  } else {
    Index.data[param_entry.id] = parcel_index_json;
  }
};

Index.RenderHTML = function () {
  for (var index_data_id in Index.data) {
    var index_data = Index.data[index_data_id];
    var index_keys = Object.keys(index_data).sort();

    if (!Index.is_merged) {
      var index_title_div = document.createElement('div');
      index_title_div.id = 'parcel_index:' + index_data_id;
      index_title_div.className = 'ww_skin_index_title';
      index_title_div.innerText = Parcels.title[index_data_id];

      Connect.index_content_div.appendChild(index_title_div);
    }

    var index_content_div = document.createElement('div');
    index_content_div.id = 'index:' + index_data_id;

    var index_dl = document.createElement('dl');
    index_dl.className = 'ww_skin_index_list';

    for (var k = 0; k < index_keys.length; k++) {
      var index_group_id = index_keys[k];
      var index_group = index_data[index_group_id];

      var group_dd = document.createElement('dd');
      group_dd.className = 'ww_skin_index_list_group';

      var group_label_div = document.createElement('div');
      group_label_div.className = 'ww_skin_index_group';
      group_label_div.innerText = index_group_id;

      group_dd.appendChild(group_label_div);

      var group_dl = document.createElement('dl');
      group_dl.className = 'ww_skin_index_list';

      // sort alphabetically by sort property
      index_group.sort(function (a, b) {
        return a.sort.localeCompare(b.sort);
      })

      for (var i = 0; i < index_group.length; i++) {
        var group_entry = index_group[i];
        Index.RenderEntryHTML(group_entry, group_dl);
      }

      group_dd.appendChild(group_dl);
      index_dl.appendChild(group_dd);
    }

    Connect.index_content_div.appendChild(index_dl);
  }
};

Index.RenderEntryHTML = function (param_entry, param_parent) {
  if (!param_entry || !param_parent || !param_entry.links || !param_entry.children) {
    // bad data
    return null;
  }

  var entry = param_entry;
  var parent = param_parent;

  if (entry.links.length > 0) {
    var id_added = false;

    for (var i = 0; i < entry.links.length; i++) {
      var entry_link = entry.links[i];
      var entry_dd = document.createElement('dd');
      entry_dd.className = 'ww_skin_index_list_entry';

      var entry_div = document.createElement('div');
      entry_div.className = 'ww_skin_index_entry';

      if (entry.id && !id_added) {
        entry_div.id = entry.id;
        id_added = true;
      }

      var entry_a = document.createElement('a');
      entry_a.className = 'ww_skin_index_link';
      entry_a.href = entry_link.href;

      if (entry.type === 'see') {
        entry_a.rel = 'See';
      }

      entry_a.innerText = entry_link.content || entry.content;

      entry_div.appendChild(entry_a);
      entry_dd.appendChild(entry_div);
      parent.appendChild(entry_dd);
    }
  } else {
    var entry_dd = document.createElement('dd');
    entry_dd.className = 'ww_skin_index_list_entry';
    entry_dd.innerText = entry.content;

    if (entry.id) {
      entry_dd.id = entry.id;
    }

    parent.appendChild(entry_dd);
  }

  if (entry.children.length > 0) {
    var child_dl = document.createElement('dl');
    child_dl.className = 'ww_skin_index_list';

    for (var i = 0; i < entry.children.length; i++) {
      var child_entry = entry.children[i];
      Index.RenderEntryHTML(child_entry, child_dl);
    }

    var last_entry_dd = parent.lastElementChild;
    last_entry_dd.appendChild(child_dl);
  }
}

Index.OnLinkClick = function (param_event) {
  var result, event, hash_index, see_also_id, index_entry;

  result = false;
  event = param_event;

  // Cancel event bubbling
  //
  event.cancelBubble = true;
  if (event.stopPropagation) {
    event.stopPropagation();
  } else {
    event.cancelBubble = true;
  }

  Connect.ProcessAnalyticsEvent('menu_click_index');

  // See/See Also link?
  //
  if (this.rel.toLowerCase() === 'see') {
    hash_index = this.href.indexOf('#');
    if (hash_index >= 0) {
      see_also_id = this.href.substring(hash_index + 1);

      index_entry = Connect_Window.document.getElementById(see_also_id);
      if (index_entry !== null) {
        // Scroll to Index position
        //
        Connect.ScrollToMenuElement(index_entry);
      }
    }

    result = false;
  } else {
    // Document link
    //
    result = Navigation.InterceptLink(this, true);
  }

  return result;
};

// Navigation
//
var Navigation = {
  base_url: '',
  default_page_url: '',
  splash_page_url: '',
  search_page_url: '',
  search_url: '',
  hash: '',
  link_bridge: {},
  page_urls: {},
  page_info: null,
  query_string: '',
  url_handler_object: {}
};

Navigation.CreateHandlerObject = function (param_hash) {
  var handler_object, hash, recognized_actions_regex, navigation_action_found, url_queries;

  handler_object = {};
  hash = param_hash;
  recognized_actions_regex = /^(?:context|page|search|scope|parcels|toc|index)(?:\/.*)?$/;
  navigation_action_found = false;
  url_queries = hash.split('#');

  for (var q = 0; q < url_queries.length; q++) {
    var url_query = url_queries[q];

    if (url_query === '') {
      continue;
    }

    if (url_query.match(recognized_actions_regex)) {
      // query is one of the recognized actions
      var action, argument;

      action = '';
      argument = '';

      if (url_query.indexOf('/') > -1) {
        action = url_query.substring(0, url_query.indexOf('/'));
        argument = url_query.substring(url_query.indexOf('/') + 1);
      } else {
        action = url_query;
      }

      switch (true) {
        case action === 'context':
        case action === 'page':
        case action === 'search':
          // can only have one of context, page, or search; first one wins
          if (!navigation_action_found) {
            handler_object[action] = argument;
            navigation_action_found = true;
          }
          break;
        case action === 'parcels':
          // only write valid parcels to the object
          var valid_parcels, parcel_titles;

          valid_parcels = [];
          parcel_titles = argument.split('/');

          for (var p = 0; p < parcel_titles.length; p++) {
            var parcel_title = parcel_titles[p];

            if (Parcels.all_parcels.indexOf(Browser.DecodeURIComponent(parcel_title)) > -1) {
              valid_parcels.push(parcel_title);
            }
          }

          argument = valid_parcels.join('/');

          if (argument) {
            handler_object[action] = argument;
          }
          break;
        case action === 'scope':
        case action === 'toc':
        case action === 'index':
        default:
          handler_object[action] = argument;
          break;
      }
    } else if (!handler_object['other']) {
      // query not recognized; pass the first one through
      handler_object['other'] = '#' + url_query;
    }
  }

  return handler_object;
};

Navigation.CreateHash = function (param_url_handler_object) {
  var url_handler_object, final_hash;

  url_handler_object = param_url_handler_object;
  final_hash = '';

  for (var prop in url_handler_object) {
    // loop through handler object and add properties
    var prop_hash;

    if (prop === 'other' || prop === 'parcels') {
      continue;
    }

    prop_hash = '#' + prop + '/' + url_handler_object[prop];

    final_hash += prop_hash;
  }

  if (!Parcels.current_parcels['_all_']) {
    // add parcels hash
    var parcels_argument, current_parcels;

    parcels_argument = '';
    current_parcels = [];

    for (var parcel_title in Parcels.current_parcels) {
      if (Parcels.current_parcels[parcel_title]) {
        current_parcels.push(parcel_title);
      }
    }

    parcels_argument = current_parcels.join('/');
    parcels_argument = encodeURIComponent(parcels_argument);

    final_hash += '#parcels/' + parcels_argument;
  }

  if (url_handler_object['other']) {
    final_hash += url_handler_object['other'];
  }

  return final_hash;
};

Navigation.AddPageURL = function (param_url) {
  var url;

  url = param_url || '';

  if (url && typeof url === 'string') {
    url = Browser.DecodeURIComponent(url);

    if (!Navigation.page_urls[url]) {
      Navigation.page_urls[url] = true;
    }
  }
};

Navigation.PageExists = function (param_url) {
  var result, url;

  result = false;

  url = param_url || '';

  if (url && typeof url === 'string') {
    if (url.indexOf('#') > -1) {
      url = url.substring(0, url.indexOf('#'));
    }

    url = Browser.DecodeURIComponent(url);

    result = !!Navigation.page_urls[url];
  }

  return result;
};

Navigation.Navigate = function (param_url, param_hide_menu) {
  // if there's a hash, use it to make a handler object and find out where to go
  // if there's no actionable hash, run through display page
  var url, hide_menu, hash, has_navigation_hash, query_string;

  url = param_url || '';
  hide_menu = param_hide_menu || false;
  hash = '';
  has_navigation_hash = false;
  query_string = Navigation.query_string;

  Connect.HidePopup();

  if (!url || typeof url !== 'string') {
    // can't navigate without a url
    Navigation.DisplayNotFoundPage();
    return;
  }

  var has_query_string = url.indexOf('?') > -1;
  var has_hash_string = url.indexOf('#') > -1;

  if (has_query_string) {
    var query_mark_position = url.indexOf('?');
    var hash_mark_position = url.indexOf('#');
    var query_string_start = query_mark_position;
    var query_string_end = (has_hash_string && hash_mark_position > query_mark_position) ? hash_mark_position : url.length;

    query_string = url.substring(query_string_start, query_string_end);
    url = url.replace(query_string, '');
  }

  if (has_hash_string) {
    var query_mark_position = url.indexOf('?');
    var hash_mark_position = url.indexOf('#');
    var hash_start = hash_mark_position;
    var hash_end = (has_query_string && query_mark_position > hash_mark_position) ? query_mark_position : url.length;

    hash = url.substring(hash_start, hash_end);
    url = url.replace(hash, '');
  }

  Navigation.url_handler_object = Navigation.CreateHandlerObject(hash);
  Navigation.hash = Navigation.CreateHash(Navigation.url_handler_object);
  Navigation.query_string = query_string;

  has_navigation_hash =
    Navigation.url_handler_object['context'] !== undefined ||
    Navigation.url_handler_object['page'] !== undefined ||
    Navigation.url_handler_object['search'] !== undefined;

  // catch changed parcels first if necessary
  Navigation.ParcelHashNavigation();

  if (has_navigation_hash) {
    // use hash to figure out where to go
    if (Navigation.url_handler_object['context'] !== undefined) {
      // use context hash to navigate
      Navigation.ContextHashNavigation();
    } else if (Navigation.url_handler_object['search'] !== undefined) {
      // use search hash to navigate
      Navigation.SearchHashNavigation();
    } else if (Navigation.url_handler_object['page'] !== undefined) {
      // use page hash to navigate
      Navigation.PageHashNavigation();
    }
  } else {
    if (Browser.SameDocument(url, Navigation.connect_page_url)) {
      url = Navigation.default_page_url;
    }

    if (Navigation.url_handler_object['other']) {
      url += Navigation.url_handler_object['other'];
    }

    // display page url
    Navigation.PageNavigation(url, hide_menu);
  }

  Navigation.TOCHashNavigation();
  Navigation.IndexHashNavigation();
};

Navigation.ParcelHashNavigation = function () {
  // Reload parcels
  //
  var parcels_changed;

  parcels_changed = false;

  if (Navigation.url_handler_object['parcels']) {
    // found #parcels hash, see if it is different from our current parcels
    if (Parcels.current_parcels['_all_']) {
      parcels_changed = true;
    } else {
      // get currently loaded parcel names into a list
      var current_parcels = [];

      for (var prop in Parcels.current_parcels) {
        if (prop === '_all_') {
          continue;
        }

        if (Parcels.current_parcels[prop]) {
          current_parcels.push(prop);
        }
      }

      // get requested parcel names into a list
      var requested_parcels = Browser.DecodeURIComponent(Navigation.url_handler_object['parcels']).split('/');

      // start comparing the two
      if (current_parcels.length !== requested_parcels.length) {
        // different length; a parcel has changed
        parcels_changed = true;
      } else {
        // same length; compare the names to find differences
        for (var i = 0; i < requested_parcels.length; i++) {
          var requested_parcel = requested_parcels[i];

          if (current_parcels.indexOf(requested_parcel) === -1) {
            // requested parcel is not present
            parcels_changed = true;
            break;
          }
        }
      }
    }
  } else if (!Parcels.current_parcels['_all_']) {
    // previously set parcels are now unset
    parcels_changed = true;
  }

  if (parcels_changed) {
    Connect_Window.location.reload();
  }
};

Navigation.ContextHashNavigation = function () {
  // #context/
  // Context/topic requested
  //
  var context_and_topic, url;

  context_and_topic = Navigation.url_handler_object['context'].split('/');
  url = '';

  if (!Parcels.loaded_all || Connect.loading) {
    // Try again after parcels are loaded
    Connect.ShowPageLoading();

    setTimeout(function () {
      Navigation.ContextHashNavigation();
    }, 10);
    return;
  }

  if (context_and_topic.length === 1) {
    var topic, context_ids, topic_id, topic_anchor;

    topic = context_and_topic[0];

    // Resolve context by selecting by ID iteratively
    //
    if (topic.length > 0) {
      context_ids = Parcels.context_ids;

      for (var context in context_ids) {
        var context_id = context_ids[context];

        if (context_id !== undefined) {
          var topic_id, topic_anchor;

          topic_id = 'topic:' + context_id + ':' + topic;
          topic_anchor = Connect_Window.document.getElementById(topic_id);

          if (topic_anchor !== null) {
            // Found topic!
            //
            url = topic_anchor.href;

            break;
          }
        }
      }
    }
  } else if (context_and_topic.length === 2) {
    var context, topic;

    context = context_and_topic[0];
    topic = context_and_topic[1];

    // Resolve context by selecting ID using topic and context
    //
    if (context.length > 0 && topic.length > 0 && typeof Parcels.context_ids[context] === 'string') {
      var parcel_id, topic_id, topic_anchor;

      parcel_id = Parcels.context_ids[context];
      topic_id = 'topic:' + parcel_id + ':' + topic;
      topic_anchor = Connect_Window.document.getElementById(topic_id);

      if (topic_anchor !== null) {
        // Found topic!
        //
        url = topic_anchor.href;
      }
    }

    Connect.ProcessAnalyticsEventTopic(context, topic);
  }

  if (url) {
    Navigation.PageNavigation(url);
  } else {
    Connect.HidePageLoading();

    Navigation.DisplayNotFoundPage();
  }
};

Navigation.PageHashNavigation = function () {
  // #page/
  // Page requested
  //
  var url, page_base_relative_url;

  url = '';

  page_base_relative_url = Navigation.url_handler_object['page'];

  // Ignore top-level files
  //
  if (page_base_relative_url.indexOf('/') > -1 ||
    page_base_relative_url.indexOf('%2f') > -1 ||
    page_base_relative_url.indexOf('%2F') > -1) {
    // Build secure URI
    //
    page_base_relative_url = page_base_relative_url.replace(/[\\<>:;"]|%5C|%3C|%3E|%3A|%3B|%22/gi, '');
  }

  url = Navigation.base_url + page_base_relative_url;

  if (Navigation.url_handler_object['other']) {
    url += Navigation.url_handler_object['other'];
  }

  Navigation.PageNavigation(url);
};

Navigation.SearchHashNavigation = function () {
  // #search/
  // Search enabled?
  //
  if (Connect.search_div !== null) {
    // Search requested
    //
    var search_words_parameter, search_words, search_scope, search_scope_selections;

    search_words_parameter = '';

    search_words_parameter = Navigation.url_handler_object['search'];
    search_words = Browser.DecodeURIComponent(search_words_parameter);

    if (Connect.scope_enabled) {
      search_scope = ['all'];

      if (Navigation.url_handler_object['scope'] !== undefined) {
        // #scope/
        // Load search scope selections
        //

        search_scope = [];
        search_scope_selections = Navigation.url_handler_object['scope'].split('/');

        // Loop through selections
        //
        for (var i = 0; i < search_scope_selections.length; i++) {
          var scope_selection, scope_title;

          scope_selection = search_scope_selections[i];
          scope_title = Browser.DecodeURIComponent(scope_selection);

          // Attempt to match selection to the title of a
          // scope in Connect
          //
          for (var property in Scope.search_scopes) {
            if (Scope.search_scopes.hasOwnProperty(property)) {
              var connect_scope_title;

              connect_scope_title = Scope.search_scopes[property].title;

              if (connect_scope_title === scope_title) {
                search_scope.push(String(property));
              }
            }
          }
        }
        // Fallback to 'all'
        //
        if (search_scope.length === 0) {
          search_scope = ['all'];
        }
      }

      Scope.search_scope_selections = search_scope;
      Scope.WriteSelectionsString();
      Scope.CheckCurrentSelectionCheckboxes();
    }

    // Show search page
    //
    if (!Connect.SearchEnabled()) {
      Connect.ShowSearchPage();
      Connect.AdjustLayoutForBrowserSize();
    }

    // Initiate search
    //
    Connect.search_query = search_words;
    Connect.search_input.value = search_words;
    Connect.HandleSearch();
    Connect.HidePageLoading();
  } else {
    Navigation.PageNavigation(Navigation.default_page_url);
  }
};

Navigation.TOCHashNavigation = function () {
  if (Navigation.url_handler_object['toc'] !== undefined) {
    Connect.DisplayTOC();
    delete Navigation.url_handler_object['toc'];
    Navigation.DocumentBookkeeping();
  }
};

Navigation.IndexHashNavigation = function () {
  if (Navigation.url_handler_object['index'] !== undefined) {
    Connect.DisplayIndex();
    delete Navigation.url_handler_object['index'];
    Navigation.DocumentBookkeeping();
  }
};

Navigation.OtherHashNavigation = function () {
  if (Navigation.url_handler_object['other']) {
    var hash, data;

    hash = Navigation.url_handler_object['other'];

    data = {
      'action': 'update_hash',
      'hash': hash
    };
    Message.Post(Connect.page_iframe.contentWindow, data, Connect_Window);
  }
};

Navigation.PageNavigation = function (param_href, param_hide_menu) {
  var href, hide_menu, data;

  href = param_href;
  hide_menu = !!param_hide_menu;

  if (!Navigation.PageExists(href)) {
    if (!Parcels.loaded_all) {
      // Try again after parcels are loaded
      Connect.ShowPageLoading();

      setTimeout(function () {
        Navigation.PageNavigation(href, hide_menu);
      }, 10);
      return;
    } else {
      // URL doesn't exist
      Connect.HidePageLoading();

      Navigation.DisplayNotFoundPage();
      return;
    }
  } else {
    Connect.HidePageLoading();

    if (!Navigation.page_info) {
      // Initialize content page
      //
      Connect.page_iframe.src = href;
    } else {
      // Load new page
      //
      var current_href, is_same_location;

      // If search is enabled, hide it and continue
      if (Connect.SearchEnabled()) {
        Connect.HideSearchPage();
      }

      // Disable home button?
      if (Browser.SameDocument(Navigation.default_page_url, href)) {
        Connect.EnableDisableButton('ww_behavior_home', 'ww_skin_home', false);
      } else {
        Connect.EnableDisableButton('ww_behavior_home', 'ww_skin_home', true);
      }

      // Hide menu?
      if (param_hide_menu) {
        if (Connect.Menu.Enabled && Connect.Menu.Visible() && !Connect.layout_wide) {
          Connect.Menu.Hide();
        }
      }

      // Reset back to top
      if (Connect.back_to_top_element !== null) {
        Connect.back_to_top_element.className = Browser.RemoveClass(Connect.back_to_top_element.className, 'back_to_top_show');
      }

      current_href = Navigation.page_info.href + Navigation.page_info.hash;
      is_same_location = href === current_href;

      if (!is_same_location) {
        data = {
          'action': 'page_replace',
          'href': href
        };
        Message.Post(Connect.page_iframe.contentWindow, data, Connect_Window);
      } else if (Navigation.page_info.hash) {
        data = {
          'action': 'update_hash',
          'hash': Navigation.page_info.hash
        };
        Message.Post(Connect.page_iframe.contentWindow, data, Connect_Window);
      } else if (Connect.search_query) {
        Connect.SearchQueryHighlight();
      }
    }
  }
};

Navigation.DisplayNotFoundPage = function () {
  var nav_url = Connect.not_found_page_enabled ? Navigation.not_found_page_url : Navigation.default_page_url;

  Navigation.PageNavigation(nav_url, true);
};

Navigation.HandleSearchURL = function () {
  var search_url, search_url_handler_object, replace_history;

  search_url = '';
  search_url_handler_object = Navigation.CreateHandlerObject('#search');
  replace_history = false;

  if (Connect.search_query) {
    search_url_handler_object['search'] = encodeURIComponent(Connect.search_query);
  }

  if (Connect.scope_enabled) {
    if (Scope.search_scope_selections.length > 0 && Scope.search_scope_selections[0] !== 'all') {
      // Build search scope hash
      //
      var scope_selections;

      scope_selections = [];

      for (var i = 0; i < Scope.search_scope_selections.length; i++) {
        var scope_selection, scope_title;

        scope_selection = Scope.search_scope_selections[i];
        scope_title = Scope.search_scopes[scope_selection].title;
        scope_title = Browser.EncodeURIComponentIfNotEncoded(scope_title);

        scope_selections.push(scope_title);
      }

      search_url_handler_object['scope'] = scope_selections.join('/');
    }
  }

  if (Navigation.url_handler_object['parcels']) {
    search_url_handler_object['parcels'] = Navigation.url_handler_object['parcels'];
  }

  if (Navigation.url_handler_object['search']) {
    replace_history = true;
  }

  Navigation.url_handler_object = search_url_handler_object;

  search_url = Navigation.connect_page_url + Navigation.query_string + Navigation.CreateHash(Navigation.url_handler_object);

  if (replace_history) {
    Connect_Window.location.replace(search_url);
  } else {
    Connect_Window.location.assign(search_url);
  }
};

Navigation.BackToCurrentPage = function () {
  var page_url, page_url_handler_object;

  page_url = '';
  page_url_handler_object = Navigation.CreateHandlerObject('#page');

  // Clear search results
  Connect.search_input.value = '';
  Connect.search_query = '';

  // Determine hash for last visited page
  if (Navigation.page_info) {
    var data, page_relative_path;

    Connect.SearchQueryHighlight();

    // build page hash
    page_relative_path = Browser.RelativePath(Navigation.base_url, Navigation.page_info.href);
    page_url_handler_object['page'] = page_relative_path;

    if (Navigation.page_info.hash) {
      page_url_handler_object['other'] = Navigation.page_info.hash;

      data = {
        'action': 'update_hash',
        'hash': Navigation.page_info.hash
      };
      Message.Post(Connect.page_iframe.contentWindow, data, Connect_Window);
    }

    if (Navigation.url_handler_object['parcels']) {
      page_url_handler_object['parcels'] = Navigation.url_handler_object['parcels'];
    }
  } else {
    // Search must have been the first place we landed,
    // Load splash page
    //
    var splash_relative_path = Browser.RelativePath(Navigation.base_url, Navigation.default_page_url);

    page_url_handler_object['page'] = splash_relative_path;
  }

  Navigation.url_handler_object = page_url_handler_object;
  page_url = Navigation.connect_page_url + Navigation.CreateHash(Navigation.url_handler_object);

  Connect_Window.location.assign(page_url);
};

Navigation.DocumentBookkeeping = function (param_same_document) {
  // when we get here, we've just loaded a page in the iframe...
  // we'll always have:
  // - a window.location that represents user/browser input
  //   - file.html (needs to change to index.html#page/file.html)
  //   - index.html#hash (needs to change if it is not correct)
  // - a Navigation.page_info that matches the recently loaded doc
  //   - href is the actual file
  //   - hash is only there if we navigated to another part of the page
  //
  // at this point THE FILE IS LOADED AND WE NEED THE BROWSER'S HREF TO MATCH THE PAGE
  //
  // we can ADD TO HISTORY
  // - forward movement; the loaded page has moved hashed or is a new page entirely
  //
  // we can REPLACE THE CURRENT ITEM WITH THE CORRECT ITEM
  // - the current href resembles the loaded page but needs to be renamed
  //
  // we can DO NOTHING
  // - the current href already represents whats been loaded
  //   - window.location.href
  //
  if (Navigation.page_info) {
    // responsibilites:
    // - update hash
    // - set href in history

    if (Browser.SameHierarchy(Navigation.base_url, Navigation.page_info.href)) {
      var current_href, result_href, is_result_not_found, is_different_documents,
        is_current_href_correct, result_relative_path;

      current_href = Connect_Window.location.href;
      result_href = '';
      is_result_not_found = false;
      is_current_href_correct = false;

      result_relative_path = Browser.RelativePath(Navigation.base_url, Navigation.page_info.href);

      Navigation.url_handler_object['page'] = result_relative_path;

      if (Navigation.page_info.hash) {
        Navigation.url_handler_object['other'] = Navigation.page_info.hash;
      }

      if (Navigation.url_handler_object['context']) {
        // #context hashes override #page and inner hashes
        delete Navigation.url_handler_object['page'];
        delete Navigation.url_handler_object['other'];
      }

      Navigation.hash = Navigation.CreateHash(Navigation.url_handler_object);
      result_href = Navigation.connect_page_url + Navigation.hash;
      is_result_not_found = Browser.SameDocument(Navigation.page_info.href, Navigation.not_found_page_url);
      is_different_documents = !Browser.SameDocument(current_href, result_href);
      is_current_href_correct =
        current_href === result_href ||
        is_result_not_found;

      // Determine what to do with the history
      //
      if (!is_current_href_correct) {
        // need to either assign to history or replace history item
        var replace_history = false;

        if (is_different_documents) {
          // have a file.html page... replace with index.html equivalent
          replace_history = true;
        } else {
          // basically, if the CURRENT DOCUMENT is the CONNECT PAGE with NO HASH or ONLY PARCELS,
          // and the LOADED PAGE IS THE SPLASH PAGE, we want to REPLACE
          var current_hash = current_href.substring(current_href.indexOf('#') > -1 ? current_href.indexOf('#') : current_href.length);

          if (current_hash) {
            // have a hash, make a handler object to check for navigation hashes
            var current_url_handler_object = Navigation.CreateHandlerObject(current_hash);
            var has_any_navigation_hash =
              !!current_url_handler_object['page'] ||
              !!current_url_handler_object['context'] ||
              !!current_url_handler_object['search'];

            // need to replace if there's no actionable hash
            replace_history = !has_any_navigation_hash;
          } else {
            // the connect page (index.html) with no hashes, splash page
            replace_history = true;
          }
        }

        if (Navigation.query_string) {
          var url, hash, query_string;

          if (result_href.indexOf('#') > -1) {
            url = result_href.substring(0, result_href.indexOf('#'));
            hash = result_href.substring(result_href.indexOf('#'));
          } else {
            url = result_href;
            hash = '';
          }

          query_string = Navigation.query_string;
          result_href = url + query_string + hash;
        }

        if (replace_history) {
          Connect_Window.location.replace(result_href);
        } else {
          Connect_Window.location.assign(result_href);
        }
      }
    }

    // Sync TOC
    //
    var cleanup_folders = Connect.toc_cleanup_folders;
    Connect.toc_cleanup_folders = true;

    Connect.SyncTOC(cleanup_folders);

    // Report to Analytics if enabled
    //
    if (Connect.page_cargo.search_query !== undefined) {
      Connect.ProcessAnalyticsEvent('search_page_view'); // Page view from search result click
    } else {
      Connect.ProcessAnalyticsEvent('page_view'); // Normal page view
    }

    // Highlight search words
    //
    if (Connect.page_cargo.search_query !== undefined) {
      Connect.SearchQueryHighlight();

      // Reset page cargo
      //
      Connect.page_cargo = {};
    }

    // Update anchors
    //
    if (!param_same_document) {
      var data = {
        'action': 'update_anchors',
        'target': Connect_Window.name,
        'base_url': Navigation.base_url,
        'parcel_prefixes': Parcels.prefixes,
        'button_behaviors': {},
        'email': Connect.email,
        'email_message': Connect.email_message
      };
      for (var behavior in Connect.button_behaviors) {
        if (typeof Connect.button_behaviors[behavior] === 'function') {
          data.button_behaviors[behavior] = true;
        }
      }
      Message.Post(Connect.page_iframe.contentWindow, data, Connect_Window);
    }
  }
};

Navigation.HashChanged = function () {
  if (Connect_Window.location.hash !== Navigation.hash) {
    // Update document
    //
    Navigation.Navigate(Connect_Window.location.href);
  }
};

Navigation.InterceptLink = function (param_link, param_hide_menu) {
  var result;

  result = Connect.HandleToolbarLink(param_link);

  if (result === true) {
    // Standard link
    //
    if (param_link.href) {
      if (!param_link.target || param_link.target === 'connect_page') {
        // Use existing page iframe
        //
        var href = Navigation.NormalizeURL(param_link.href);

        Navigation.Navigate(href, param_hide_menu);
      } else {
        // Display in requested window
        //
        Connect_Window.open(param_link.href, param_link.target);
      }

      // Prevent default link behavior
      //
      result = false;
    }
  }

  return result;
};

Navigation.NormalizeURL = function (param_url) {
  var url, hash, query_string, url_handler_object;

  url = param_url;
  hash = '';
  query_string = '';
  url_handler_object = {};

  var has_query_string = url.indexOf('?') > -1;
  var has_hash_string = url.indexOf('#') > -1;

  if (has_query_string) {
    var query_mark_position = url.indexOf('?');
    var hash_mark_position = url.indexOf('#');
    var query_string_start = query_mark_position;
    var query_string_end = (has_hash_string && hash_mark_position > query_mark_position) ? hash_mark_position : url.length;

    query_string = url.substring(query_string_start, query_string_end);
    url = url.replace(query_string, '');
  }

  if (has_hash_string) {
    var query_mark_position = url.indexOf('?');
    var hash_mark_position = url.indexOf('#');
    var hash_start = hash_mark_position;
    var hash_end = (has_query_string && query_mark_position > hash_mark_position) ? query_mark_position : url.length;

    hash = url.substring(hash_start, hash_end);
    url = url.replace(hash, '');
  }

  url_handler_object = Navigation.CreateHandlerObject(hash);

  url = url + query_string + Navigation.CreateHash(url_handler_object);

  return url;
};

Navigation.GetDocumentHrefFromContext = function (param_hash_value) {
  var context_and_topic, href;


  context_and_topic = param_hash_value.split('/');
  href = '';

  if (context_and_topic.length === 1) {
    var topic, context_ids, topic_id, topic_anchor;

    topic = context_and_topic[0];

    // Resolve context by selecting by ID iteratively
    //
    if (topic.length > 0) {
      context_ids = Parcels.context_ids;

      for (var context in context_ids) {
        var context_id = context_ids[context];

        if (context_id !== undefined) {
          var topic_id, topic_anchor;

          topic_id = 'topic:' + context_id + ':' + topic;
          topic_anchor = Connect_Window.document.getElementById(topic_id);

          if (topic_anchor !== null) {
            // Found topic!
            //
            href = topic_anchor.href;

            break;
          }
        }
      }
    }
  } else if (context_and_topic.length === 2) {
    var context, topic;

    context = context_and_topic[0];
    topic = context_and_topic[1];

    // Resolve context by selecting ID using topic and context
    //
    if (context.length > 0 && topic.length > 0 && typeof Parcels.context_ids[context] === 'string') {
      var parcel_id, topic_id, topic_anchor;

      parcel_id = Parcels.context_ids[context];
      topic_id = 'topic:' + parcel_id + ':' + topic;
      topic_anchor = Connect_Window.document.getElementById(topic_id);

      if (topic_anchor !== null) {
        // Found topic!
        //
        href = topic_anchor.href;
      }
    }
  }

  return href;
};

Navigation.GetDocumentHrefFromPage = function (param_hash_value) {
  var href, page_base_relative_url;

  href = '';

  page_base_relative_url = param_hash_value;

  // Ignore top-level files
  //
  if (page_base_relative_url.indexOf('/') > -1 ||
    page_base_relative_url.indexOf('%2f') > -1 ||
    page_base_relative_url.indexOf('%2F') > -1) {
    // Build secure URI
    //
    page_base_relative_url = page_base_relative_url.replace(/[\\<>:;"]|%5C|%3C|%3E|%3A|%3B|%22/gi, '');
  }

  href = Navigation.base_url + page_base_relative_url;

  return href;
};

Navigation.GetHashFromURL = function (param_url) {
  var url, hash, has_query_string, has_hash_string, query_mark_position, hash_mark_position,
    query_string_start, query_string_end, hash_start, hash_end, query_string;

  hash = '';
  url = param_url || '';
  has_query_string = url.indexOf('?') > -1;
  has_hash_string = url.indexOf('#') > -1;

  if (!has_hash_string) {
    return hash;
  }

  if (has_query_string) {
    query_mark_position = url.indexOf('?');
    hash_mark_position = url.indexOf('#');
    query_string_start = query_mark_position;
    query_string_end = (has_hash_string && hash_mark_position > query_mark_position) ? hash_mark_position : url.length;

    query_string = url.substring(query_string_start, query_string_end);
    url = url.replace(query_string, '');
  }

  query_mark_position = url.indexOf('?');
  hash_mark_position = url.indexOf('#');
  hash_start = hash_mark_position;
  hash_end = (has_query_string && query_mark_position > hash_mark_position) ? query_mark_position : url.length;

  hash = url.substring(hash_start, hash_end);

  return hash;
};

Navigation.GetDocumentHrefFromURL = function (param_url) {
  var href, url, hash, handler_object;

  href = '';
  url = Navigation.NormalizeURL(param_url);
  hash = Navigation.GetHashFromURL(url);
  handler_object = Navigation.CreateHandlerObject(hash);

  if (handler_object['context'] !== undefined) {
    href = Navigation.GetDocumentHrefFromContext(handler_object['context']);
  } else if (handler_object['page'] !== undefined) {
    href = Navigation.GetDocumentHrefFromPage(handler_object['page']);
  }

  if (href) {
    return href;
  } else {
    return url;
  }
};

Navigation.GetPrevNext = function (param_prevnext) {
  var result;

  if (Navigation.page_info) {
    result = Navigation.page_info[param_prevnext];
    if (result === undefined) {
      // Spanning parcels?
      //
      if (Navigation.link_bridge.Get(param_prevnext, Navigation.page_info.id) !== null) {
        result = Navigation.link_bridge.Get(param_prevnext, Navigation.page_info.id);
      }
    }
  }

  return result;
};

Navigation.GotoPrevNext = function (param_prevnext) {
  var link_href;

  link_href = Navigation.GetPrevNext(param_prevnext);

  if (link_href !== undefined) {
    link_href = Navigation.NormalizeURL(link_href);

    Navigation.Navigate(link_href, true);
  }
};

Navigation.UpdatePrevNext = function () {
  var enable_button, prevnext_link, search_enabled;

  // Update prev/next
  //
  search_enabled = Connect.SearchEnabled();
  prevnext_link = Navigation.GetPrevNext('Prev');
  enable_button = prevnext_link !== undefined && !search_enabled;
  Connect.EnableDisableButton('ww_behavior_prev', 'ww_skin_prev', enable_button);
  prevnext_link = Navigation.GetPrevNext('Next');
  enable_button = prevnext_link !== undefined && !search_enabled;
  Connect.EnableDisableButton('ww_behavior_next', 'ww_skin_next', enable_button);
};

// initialize Navigation properties
Navigation.base_url = function () {
  var url_header, base_pathname;

  base_pathname = Connect_Window.location.pathname;

  base_pathname = base_pathname.substring(0, base_pathname.lastIndexOf('/') + 1);

  url_header = Connect_Window.location.href;

  if (url_header.indexOf('#') > 0) {
    url_header = url_header.substring(0, url_header.indexOf('#'));
  }

  if (base_pathname.length > 0) {
    url_header = url_header.substring(0, url_header.lastIndexOf(base_pathname));
  }

  return url_header + base_pathname;
}();

Navigation.connect_page_url = function () {
  var url_header, pathname;

  url_header = Connect_Window.location.href;
  pathname = Connect_Window.location.pathname;

  if (url_header.indexOf('#') > 0) {
    url_header = url_header.substring(0, url_header.indexOf('#'));
  }

  if (pathname.length > 0) {
    url_header = url_header.substring(0, url_header.lastIndexOf(pathname));
  }

  return url_header + Connect_Window.location.pathname;
}();

Navigation.default_page_url = Navigation.base_url + 'connect/splash.html';
Navigation.not_found_page_url = Navigation.base_url + 'connect/not-found.html';
Navigation.splash_page_url = Navigation.base_url + 'connect/splash.html';
Navigation.search_page_url = Navigation.base_url + 'connect/search.html';

Navigation.AddPageURL(Navigation.splash_page_url);
Navigation.AddPageURL(Navigation.search_page_url);
Navigation.AddPageURL(Navigation.not_found_page_url);

Navigation.hash = Connect_Window.location.hash;
Navigation.url_handler_object = Navigation.CreateHandlerObject(Navigation.hash);

Navigation.link_bridge = {
  Next: {},
  Prev: {},
  HREFs: { 'splash': Navigation.splash_page_url },

  Update: function () {
    var previous_last_page_link, parcel_id, first_page_div, last_page_div, first_page_link, last_page_link, firstPageID, lastPageID, lastLinkID;

    // Reset info
    //
    this.Next = {};
    this.Prev = {};
    this.HREFs = { 'splash': Navigation.splash_page_url };

    // Update "bridge" links
    //
    previous_last_page_link = null;
    for (var i = 0; i < Parcels.ids.length; i += 1) {
      parcel_id = Parcels.ids[i];

      first_page_div = Connect_Window.document.getElementById('page:' + parcel_id + ':first');
      last_page_div = Connect_Window.document.getElementById('page:' + parcel_id + ':last');
      if (first_page_div !== null && last_page_div !== null) {
        first_page_link = Browser.FirstChildElementWithTagName(first_page_div, 'a');
        last_page_link = Browser.FirstChildElementWithTagName(last_page_div, 'a');

        firstPageID = first_page_link.id.replace(/\:first$/, '');
        lastPageID = last_page_link.id.replace(/\:last$/, '');

        // Associate previous/next and handle no splash
        //
        if (previous_last_page_link === null) {
          if (Connect.show_first_document) {
            Navigation.default_page_url = first_page_link.href;
          } else {
            this.Prev[firstPageID] = 'splash';
          }
          this.Next['splash'] = firstPageID;
        } else {
          lastLinkID = previous_last_page_link.id.replace(/\:last$/, '');
          this.Prev[firstPageID] = lastLinkID;
          this.Next[lastLinkID] = firstPageID;
        }

        // Map ids to URIs
        //
        this.HREFs[firstPageID] = first_page_link.href;
        this.HREFs[lastPageID] = last_page_link.href;

        previous_last_page_link = last_page_link;
      }
    }
  },

  GetPrev: function (param_page_id) {
    var result;

    result = null;

    if (this.Prev[param_page_id] !== undefined) {
      result = this.HREFs[this.Prev[param_page_id]];
    }

    return result;
  },

  GetNext: function (param_page_id) {
    var result;

    result = null;

    if (this.Next[param_page_id] !== undefined) {
      result = this.HREFs[this.Next[param_page_id]];
    }

    return result;
  },

  Get: function (param_type, param_page_id) {
    var result, type_as_lowercase;

    result = null;

    type_as_lowercase = param_type.toLowerCase();
    if (type_as_lowercase === 'prev') {
      result = this.GetPrev(param_page_id);
    } else if (type_as_lowercase === 'next') {
      result = this.GetNext(param_page_id);
    }

    return result;
  }
};

var Connect = {
  loading: false,
  first_page_loaded: false,
  page_cargo: {}
};

Connect.OnLoadAction = function () {
  var back_to_top_link;

  Connect.show_first_document = GLOBAL_SHOW_FIRST_DOCUMENT;
  Connect.not_found_page_enabled = GLOBAL_NOT_FOUND_PAGE_ENABLED;
  Connect.layout_initialized = false;
  Connect.layout_wide = false;
  Connect.layout_tall = false;
  Connect.adjust_for_content_size_inprogress = false;
  Connect.ignore_page_load = false;
  Connect.navigation_width = parseFloat(window.getComputedStyle(document.getElementById("menu_frame"), null)["width"]);
  Connect.navigation_minimum_page_width = GLOBAL_NAVIGATION_MIN_PAGE_WIDTH;
  Connect.minimum_page_height = 400;
  Connect.lightbox_large_images = GLOBAL_LIGHTBOX_LARGE_IMAGES;
  Connect.disqus_id = GLOBAL_DISQUS_ID;
  Connect.email = GLOBAL_EMAIL;
  Connect.email_message = GLOBAL_EMAIL_MESSAGE;
  Connect.footer_end_of_layout = GLOBAL_FOOTER_END_OF_LAYOUT;
  Connect.toc_class_states = {};
  Connect.toc_selected_entry_key = undefined;
  Connect.toc_cleanup_folders = true;
  Connect.search_input = null;
  Connect.search_query = '';
  Connect.search_title = GLOBAL_SEARCH_TITLE;
  Connect.search_scope_all_label = GLOBAL_SEARCH_SCOPE_ALL_LABEL;
  Connect.search_synonyms = '';
  Connect.search_query_minimum_length = GLOBAL_SEARCH_QUERY_MIN_LENGTH;
  Connect.progressive_search_enabled = GLOBAL_PROGRESSIVE_SEARCH_ENABLED;
  Connect.last_logged_search_term = '';
  Connect.button_behavior_expression = new RegExp('ww_behavior_[a-z]+', 'g');
  Connect.buttons = {};
  Connect.button_behaviors = {
    'ww_behavior_home': Connect.Button_Home,
    'ww_behavior_toc': Connect.Button_TOC,
    'ww_behavior_index': Connect.Button_Index,
    'ww_behavior_search': Connect.Button_Search,
    'ww_behavior_globe': Connect.Button_Globe,
    'ww_behavior_prev': Connect.Button_Previous,
    'ww_behavior_next': Connect.Button_Next,
    'ww_behavior_email': Connect.Button_Email,
    'ww_behavior_print': Connect.Button_Print,
    'ww_behavior_pdf': Connect.Button_PDF,
    'ww_behavior_logo_link_home': Connect.Button_Home,
    'ww_behavior_logo_link_external': Connect.Button_External,
    'ww_behavior_menu': Connect.Button_Menu_Toggle,
    'ww_behavior_back_to_top': Connect.BackToTopLink
  };

  Connect.button_degradation_order = [/*'ww_behavior_globe', 'ww_behavior_home'*/]; // not sure if we want this anymore
  Connect.page_first_scroll = true;
  Connect.globe_enabled = false;
  Connect.google_analytics_enabled = Connect.AnalyticsEnabled();
  Connect.browser_name = Browser.DetermineBrowserName();

  // Cache <div>s
  //
  Connect.layout_div = Connect_Window.document.getElementById('layout_div');
  Connect.toolbar_div = Connect_Window.document.getElementById('toolbar_div');
  Connect.presentation_div = Connect_Window.document.getElementById('presentation_div');
  Connect.container_div = Connect_Window.document.getElementById('container_div');
  Connect.menu_backdrop = Connect_Window.document.getElementById('menu_backdrop');
  Connect.menu_frame_div = Connect_Window.document.getElementById('menu_frame');
  Connect.page_div = Connect_Window.document.getElementById('page_div');
  Connect.page_iframe = Connect_Window.document.getElementById('page_iframe');
  Connect.popup_div = Connect_Window.document.getElementById('popup_div');
  Connect.popup_iframe = Connect_Window.document.getElementById('popup_iframe');
  Connect.panels_div = Connect_Window.document.getElementById('panels');
  Connect.nav_buttons_div = Connect_Window.document.getElementById('nav_buttons_div');
  Connect.toc_div = Connect_Window.document.getElementById('toc');
  Connect.toc_content_div = Connect_Window.document.getElementById('toc_content');
  Connect.index_div = Connect_Window.document.getElementById('index');
  Connect.index_content_div = Connect_Window.document.getElementById('index_content');
  Connect.search_div = Connect_Window.document.getElementById('search_div');
  Connect.search_content_div = Connect_Window.document.getElementById('search_content');
  Connect.search_iframe = Connect_Window.document.getElementById('search_iframe');
  Connect.search_input = Connect_Window.document.getElementById('search_input');
  Connect.header_div = Connect_Window.document.getElementById('header_div');
  Connect.footer_div = Connect_Window.document.getElementById('footer_div');
  Connect.page_loading_div = Connect_Window.document.getElementById('page_loading');

  // Menu
  //
  Connect.Menu = new Menu_Object(Connect_Window, Connect);
  Connect.sidebar_behavior = undefined;

  if (Connect.menu_backdrop) {
    Connect.menu_backdrop.onclick = Connect.Menu.Hide;
  }

  // Search Scope
  //
  Connect.scope_enabled = typeof Scope !== 'undefined';
  if (Connect.scope_enabled) {
    Connect.search_scope_selector = document.getElementById('search_scope');
    Connect.search_scope_selector.onclick = Scope.ToggleDropDown;
  }

  // Progressive Search
  //
  Connect.search_input.oninput = function () {
    Connect.search_query = Connect.search_input.value;
    if (Connect.progressive_search_enabled) {
      if (Connect.search_query.length >= Connect.search_query_minimum_length ||
        (Connect.search_query.length === 0 && Connect.SearchEnabled())) {
        Navigation.HandleSearchURL();
      }
    }
  };

  // Set up search reporting for Analytics
  //
  if (Connect.google_analytics_enabled) {
    Connect.search_input.onblur = function () {
      var search_input_value;

      search_input_value = Connect.search_input.value;

      if (search_input_value.length >= Connect.search_query_minimum_length &&
        search_input_value !== Connect.last_logged_search_term) {
        Connect.last_logged_search_term = search_input_value;
        Connect.ProcessAnalyticsEvent('search');
      }
    };
  }

  // Scroll Events
  //
  Connect.container_div.onscroll = function () {
    Connect.Menu.CalculateMenuSize();
    Connect.HandleScrollForBackToTop();
  };

  // Determine scrolling support
  //
  Connect.scrolling_supported = Browser.ScrollingSupported();
  if (Connect.scrolling_supported) {
    Connect_Window.document.body.className = Browser.AddClass(Connect_Window.document.body.className, 'scrolling_supported');
  }

  // Size content <div>
  //
  Connect_Window.onresize = Connect.OnResize;
  if (Connect_Window.addEventListener !== undefined) {
    Connect_Window.addEventListener('orientationchange', Connect.OnResize, false);
  }

  // Lightbox
  //
  Connect.Lightbox = new Lightbox_Object(Connect);

  // Touch enabled?
  //
  if (Browser.TouchEnabled(Connect_Window)) {
    // Adjust CSS rules for touch devices
    //
    Browser.DisableCSSHoverSelectors(Connect_Window);
  }

  // Hook up back to top
  //
  Connect.back_to_top_element = Connect_Window.document.getElementById('back_to_top');
  if (Connect.back_to_top_element !== null) {
    Connect.back_to_top_element.onclick = Connect.BackToTop;

    back_to_top_link = Browser.FirstChildElementWithTagName(Connect.back_to_top_element, 'a');
    if (back_to_top_link !== null && Browser.ContainsClass(back_to_top_link.className, 'ww_behavior_back_to_top')) {
      back_to_top_link.onclick = Connect.BackToTopLink;
    }
  }

  // Setup for listening
  //
  Connect.dispatch_listen = undefined;
  Message.Listen(Connect_Window, Connect.Listen);

  // Search
  //
  if (Connect.search_iframe) {
    Connect.search_iframe.onload = Connect.LoadSearch;
  }

  // Page
  //
  if (Connect.page_iframe) {
    Connect.page_iframe.onload = Connect.LoadPage;
  }

  // Popup
  //
  if (Connect.popup_div) {
    Connect.popup_info = {
      href: '',
      is_focused_on_link: false,
      is_focused_on_popup: false,
      link_x: 0,
      link_y: 0,
      link_height: 0,
      link_width: 0,
      page_height: 0
    }

    Connect.popup_div.addEventListener('mouseenter', function () {
      Connect.popup_info.is_focused_on_popup = true;
    })
    Connect.popup_div.addEventListener('mouseleave', function () {
      Connect.HidePopup()
    })
  }

  if (Connect.popup_iframe) {
    Connect.popup_iframe.onload = Connect.LoadPopup;
  }

  // Load Toolbar
  //
  Connect.LoadToolbar();

  // Load parcels
  //
  Parcels.Load();
};

Connect.OnLoad = function () {
  if (!Browser.BrowserSupported()) {
    Connect.DisplayUnsupportedBrowserView();
    return;
  }

  if (!Connect.loading) {
    Connect.loading = true;
    Connect.OnLoadAction();
  }
};

Connect.CalculateLayoutWide = function () {
  var result, browser_widthheight;

  browser_widthheight = Browser.GetBrowserWidthHeight(Connect_Window);
  result = browser_widthheight.width >= Connect.navigation_minimum_page_width;

  return result;
};

Connect.CalculateLayoutTall = function () {
  var result, browser_widthheight;

  browser_widthheight = Browser.GetBrowserWidthHeight(Connect_Window);

  result = (browser_widthheight.height >= Connect.minimum_page_height) || (browser_widthheight.height > browser_widthheight.width);

  return result;
};

Connect.AdjustLayoutForBrowserSize = function () {
  var previous_layout_wide, previous_layout_tall, layout_changed,
    toolbar_buttons, left_button, right_button, toolbar_button;

  // Adjust navigation based on available space
  //
  previous_layout_wide = Connect.layout_wide;
  previous_layout_tall = Connect.layout_tall;
  Connect.layout_wide = Connect.CalculateLayoutWide();
  Connect.layout_tall = !Connect.layout_wide && Connect.CalculateLayoutTall();
  layout_changed = !Connect.layout_initialized || Connect.layout_wide !== previous_layout_wide || Connect.layout_tall !== previous_layout_tall;

  // If calc() not supported fallback to mobile narrow mode.
  //
  if (!Browser.CalcSupported()) {
    Connect.layout_wide = false;
    Connect.layout_tall = true;
  }

  // Layout changed?
  //
  if (layout_changed) {
    if (Connect.layout_wide) {
      // Layout
      //
      Connect.layout_div.className = 'layout_wide';
    } else {
      if (Connect.layout_tall) {
        // Layout
        //
        Connect.layout_div.className = 'layout_narrow layout_tall';
      } else {
        // Layout
        //
        Connect.layout_div.className = 'layout_narrow';
      }
    }
  }

  // Update toolbar buttons
  //
  toolbar_buttons = Connect.toolbar_div.getElementsByTagName('span');
  for (var i = 0; i < toolbar_buttons.length; i += 1) {
    toolbar_button = toolbar_buttons[i];

    if (Browser.ContainsClass(toolbar_button.className, 'ww_skin_toolbar_button_left') ||
      Browser.ContainsClass(toolbar_button.className, 'ww_skin_toolbar_button_center') ||
      Browser.ContainsClass(toolbar_button.className, 'ww_skin_toolbar_button_right')) {
      if (left_button === undefined) {
        left_button = toolbar_button;
      }
      right_button = toolbar_button;
    }
  }
  if (left_button !== undefined) {
    if (Connect.layout_wide) {
      left_button.className = Browser.AddClass(left_button.className, 'ww_skin_toolbar_left_background');
    } else {
      left_button.className = Browser.RemoveClass(left_button.className, 'ww_skin_toolbar_left_background');
    }
  }
  if (right_button !== undefined) {
    if (Connect.layout_wide) {
      right_button.className = Browser.AddClass(right_button.className, 'ww_skin_toolbar_right_background');
    } else {
      right_button.className = Browser.RemoveClass(right_button.className, 'ww_skin_toolbar_right_background');
    }
  }

  if (Connect.sidebar_behavior !== undefined) {
    Connect.button_behaviors[Connect.sidebar_behavior]();
  }
  // Initialized layout
  //
  Connect.layout_initialized = true;
};

Connect.LoadPage = function () {
  var data;

  data = {
    'action': 'page_load'
  };

  Message.Post(Connect.page_iframe.contentWindow, data, Connect_Window);
};

Connect.LoadSearch = function () {
  var data;

  data = {
    'action': 'search_load'
  };

  Message.Post(Connect.search_iframe.contentWindow, data, Connect_Window);
};

Connect.LoadPopup = function () {
  var data;

  data = {
    'action': 'popup_load'
  };

  Message.Post(Connect.popup_iframe.contentWindow, data, Connect_Window);
}

Connect.LoadToolbar = function () {
  var buttons_to_remove, button_to_remove, ie_match;

  // Intercept toolbar links
  //
  buttons_to_remove = [];
  Browser.ApplyToElementsWithQuerySelector(
    'body a[class*=ww_behavior]',
    function (param_link) {
      var match, button_key, button_span, keep;

      param_link.onclick = Connect.ToolbarLink;

      // Track buttons
      //
      match = param_link.className.match(Connect.button_behavior_expression);
      if (match !== null) {
        button_key = match[0];
        button_span = Browser.FindParentWithTagName(param_link, 'span');
        if (button_span !== null) {
          // Keep button?
          //
          keep = true;
          if (Connect_Window.document.location.protocol === 'file:') {
            if (button_key === 'ww_behavior_globe') {
              keep = false;
            }
          }

          // Process button
          //
          if (keep) {
            Connect.buttons[button_key] = button_span;

            // Initialize sidebar behavior
            //
            if ((Connect.sidebar_behavior === undefined) && ((button_key === 'ww_behavior_toc') ||
              (button_key === 'ww_behavior_index'))) {
              Connect.sidebar_behavior = button_key;
            }
          } else {
            buttons_to_remove[buttons_to_remove.length] = button_span;
          }
        }
      }
    }
  );

  // Remove buttons
  //
  while (buttons_to_remove.length > 0) {
    button_to_remove = buttons_to_remove.shift();
    if (button_to_remove.parentNode !== undefined && button_to_remove.parentNode !== null) {
      button_to_remove.parentNode.removeChild(button_to_remove);
    }
  }

  // Handle toolbar search
  //
  ie_match = Connect_Window.navigator.userAgent.match(/MSIE (\d+)\.\d+;/);
  if (ie_match === null || ie_match.length > 1 && parseInt(ie_match[1], 10) > 7) {
    // Use toolbar search form
    //
    Browser.ApplyToChildElementsWithTagName(
      Connect.toolbar_div,
      'form',
      function (param_form) {
        if (Browser.ContainsClass(param_form.className, 'ww_skin_search_form')) {
          param_form.onsubmit = function () {
            if (Connect.search_input.value !== Connect.last_logged_search_term) {
              Connect.last_logged_search_term = Connect.search_input.value;
              Connect.ProcessAnalyticsEvent('search');
            }

            if (Connect.SearchEnabled()) {
              Connect.HandleSearch();
            }
            else {
              Connect.Button_Search();
            }

            return false;
          };
        }
      }
    );
    Browser.ApplyToChildElementsWithTagName(
      Connect.toolbar_div,
      'input',
      function (param_input) {
        if (Browser.ContainsClass(param_input.className, 'ww_skin_search_input')) {
          Connect.search_input = param_input;
        }
      }
    );
  } else {
    // Eliminate toolbar search form for IE
    //
    Browser.ApplyToChildElementsWithTagName(
      Connect.toolbar_div,
      'form',
      function (param_form) {
        var parent_element, button_span;

        // Promote button to form peer
        //
        parent_element = param_form.parentNode;
        button_span = Connect.buttons['ww_behavior_search'];
        if (button_span !== undefined) {
          parent_element.insertBefore(button_span, param_form);
        }

        // Remove search form
        //
        parent_element.removeChild(param_form);
      }
    );
    Browser.ApplyToChildElementsWithTagName(
      Connect.toolbar_div,
      'input',
      function (param_input) {
        var parent_element;

        parent_element = param_input.parentNode;
        parent_element.removeChild(param_input);
      }
    );
  }
};

Connect.HandleToolbarButtonForBrowserSize = function (param_i, param_show) {
  var done, button_behavior, toolbar_button, browser_widthheight,
    toolbar_table_element, toolbar_table_widthheight;

  done = false;

  // Possible button to show/hide
  //
  button_behavior = Connect.button_degradation_order[param_i];
  toolbar_button = Connect.buttons[button_behavior];
  if (toolbar_button !== undefined) {
    // Show/hide
    //
    if (param_show) {
      toolbar_button.style.display = 'inline-block';
    } else {
      toolbar_button.style.display = 'none';
    }

    // Keep change?
    //
    browser_widthheight = Browser.GetBrowserWidthHeight(Connect_Window);
    toolbar_table_element = Browser.FirstChildElementWithTagName(Connect.toolbar_div, 'table');
    toolbar_table_widthheight = Browser.GetElementWidthHeight(toolbar_table_element);
    if (param_show) {
      if (toolbar_table_widthheight.width > browser_widthheight.width + 1) {
        // Revert change
        //
        toolbar_button.style.display = 'none';
        done = true;
      }
    } else {
      if (toolbar_table_widthheight.width <= browser_widthheight.width + 1) {
        // Met the goal size
        //
        done = true;
      }
    }
  }

  return done;
};

Connect.AdjustToolbarForBrowserSize = function () {
  var browser_widthheight, toolbar_table_element,
    toolbar_table_widthheight, show, done;

  // Show/hide non-critical toolbar buttons based on available space
  //
  browser_widthheight = Browser.GetBrowserWidthHeight(Connect_Window);
  toolbar_table_element = Browser.FirstChildElementWithTagName(Connect.toolbar_div, 'table');
  toolbar_table_widthheight = Browser.GetElementWidthHeight(toolbar_table_element);
  show = (toolbar_table_widthheight.width <= browser_widthheight.width + 1);

  if (show) {
    // Show buttons in reverse order
    //
    for (var i = Connect.button_degradation_order.length - 1; i >= 0; i -= 1) {
      done = Connect.HandleToolbarButtonForBrowserSize(i, show);
      if (done) {
        break;
      }
    }
  } else {
    // Hide buttons in default order
    //
    for (var i = 0; i < Connect.button_degradation_order.length; i += 1) {
      done = Connect.HandleToolbarButtonForBrowserSize(i, show);
      if (done) {
        break;
      }
    }
  }
};

Connect.ResizePage = function () {
  if (Navigation.page_info && Navigation.page_info.dimensions && Navigation.page_info.dimensions.height) {
    var height = String(Navigation.page_info.dimensions.height) + 'px';

    if (Connect.page_div.style.height !== height) {
      Connect.page_div.style.height = height;
    }
  }

  Connect.OnResize();
};

Connect.OnResize = function () {
  if (Connect.SearchEnabled()) {
    Connect.AdjustForSearchContentSize();
  }
  Connect.AdjustLayoutForBrowserSize();
  Connect.AdjustToolbarForBrowserSize();
  Connect.Menu.CalculateMenuSize();
};

Connect.LocateTOCEntry = function () {
  var result, page_id, possible_toc_entry_id, possible_toc_link, toc_page_element;

  result = null;

  // See if page exists in TOC
  //
  if (Navigation.page_info) {
    page_id = Navigation.page_info.id;

    // Page ID defined?
    //
    if (typeof page_id === 'string' && page_id.length > 0) {
      // Try instant lookup with document hash
      //
      if (Navigation.page_info.hash.length > 1 && Navigation.page_info.hash.charAt(0) === '#') {
        possible_toc_entry_id = page_id + ':' + Navigation.page_info.hash.substring(1);
        possible_toc_link = Connect_Window.document.getElementById(possible_toc_entry_id);
        if (possible_toc_link !== null) {
          // TOC link located!
          //
          result = Browser.FindParentWithTagName(possible_toc_link, 'li');
        }
      }

      // Result found?
      //
      if (result === null) {
        // Check for page ID in TOC
        //
        toc_page_element = Connect_Window.document.getElementById(page_id);
        if (toc_page_element !== null) {
          // Found page!
          //
          result = Browser.FindParentWithTagName(toc_page_element, 'li');
        }
      }
    }
  }

  return result;
};

Connect.DetermineTOCLevel = function (param_container_element, param_ul) {
  var level, current_node;

  // Determine initial level
  //
  level = 0;
  if (param_ul !== param_container_element) {
    level = 1;
  }

  // Determine level
  //
  current_node = param_ul.parentNode;
  while (current_node !== param_container_element) {
    if (current_node.nodeName.toLowerCase() === 'ul') {
      level += 1;
    }

    current_node = current_node.parentNode;
  }

  return level;
};

Connect.ConfigureTOCLevels = function (param_container_element, param_level_offset) {
  var toc_layout_div;

  // Configure TOC levels
  //
  Browser.ApplyToChildElementsWithTagName(
    param_container_element,
    'ul',
    function (param_ul) {
      var level, class_name;

      // Determine level
      //
      level = param_level_offset + Connect.DetermineTOCLevel(param_container_element, param_ul);

      // Initialize open/close
      //
      class_name = 'ww_skin_toc_level ww_skin_toc_level_' + level;
      if ((level === 1) || (Browser.ContainsClass(param_ul.className, 'ww_skin_toc_container_open'))) {
        class_name += ' ww_skin_toc_container_open';
      } else {
        class_name += ' ww_skin_toc_container_closed';
      }

      // Update class name
      //
      param_ul.className = class_name;
    });

  // Initialize open or closed based on entry state
  //
  toc_layout_div = Browser.FirstChildElementWithTagName(param_container_element, 'div');
  if (toc_layout_div !== null) {
    if (Connect.TOCFolder_IsOpen(toc_layout_div)) {
      Connect.TOCFolder_Open(toc_layout_div);
    } else {
      Connect.TOCFolder_Close(toc_layout_div);
    }
  }

  // Track folder clicks
  //
  Browser.ApplyToChildElementsWithTagName(
    param_container_element,
    'div',
    function (param_div) {
      if (Browser.ContainsClass(param_div.className, 'ww_skin_toc_entry')) {
        param_div.onclick = Connect.TOCEntryClickHandler;

        Browser.ApplyToChildElementsWithTagName(
          param_div,
          'span',
          function (param_span) {
            if (Browser.ContainsClass(param_span.className, 'ww_skin_toc_dropdown')) {
              param_span.onclick = Connect.TOCDropdownClickHandler;
            }
          });
      }
    });
};

Connect.ConfigureTabs = function (param_container_element) {
  Browser.ApplyToElementsWithQuerySelector(
    'div[class*=ww_skin_toolbar_tab]',
    function (param_tab) {
      var group_title = param_tab.firstElementChild.innerHTML;

      if (Parcels.current_parcels[group_title] || Parcels.current_parcels['_all_']) {
        // Tab title matches group title of a current parcel or all parcels are allowed.
        //
      } else if (Parcels.all_parcels.indexOf(group_title) === -1) {
        // This Tab is not from a parcel, must be custom tab.
        //
      }
      else {
        param_tab.style.display = 'none';
      }

      // Track tab clicks
      //
      param_tab.onclick = Connect.TabClickHandler;
    }
  );
};

Connect.TabClickHandler = function (param_event) {
  var event, parent_div, result;

  // Access event
  //
  event = param_event || window.event;

  // Cancel event bubbling
  //
  event.cancelBubble = true;
  if (event.stopPropagation) {
    event.stopPropagation();
  } else {
    event.cancelBubble = true;
  }

  Connect.ProcessAnalyticsEvent('toolbar_tab_click');

  // Process event
  //
  result = Connect.TabLinkProcessor(param_event);

  return result;
};

Connect.TabLinkProcessor = function (param_event) {
  var tabs, current_tab, updated_className, result;

  // Gather all of the tabs
  //
  tabs = [];
  Browser.ApplyToElementsWithQuerySelector(
    'div[class*=ww_skin_toolbar_tab]',
    function (param_tab) {
      tabs.push(param_tab);
    }
  );

  // Set 'selected' Tab to this tab and make all other tabs not 'selected'
  // This is only necessary if the page is not part of the help page_urls
  //
  while (tabs.length > 0) {
    current_tab = tabs.shift();
    if (current_tab == param_event.currentTarget) {
      // Make this tab the 'selected' tab
      //
      updated_className = Browser.AddClass(current_tab.className, 'ww_skin_toolbar_tab_selected');
    }
    else {
      // Make sure this tab is not the 'selected' tab
      //
      updated_className = Browser.RemoveClass(current_tab.className, 'ww_skin_toolbar_tab_selected');
    }

    current_tab.className = updated_className;
  }

  // Navigate to the link
  //
  result = Navigation.InterceptLink(param_event.target, true);

  return result;
};

Connect.TabUpdateSelected = function () {
  Browser.ApplyToElementsWithQuerySelector(
    'div[class*=ww_skin_toolbar_tab]',
    function (param_tab) {
      var child_link, url, updated_className;

      child_link = Browser.FirstChildElementWithTagName(param_tab, 'a');

      if (child_link.href) {
        if (!child_link.target || child_link.target === 'connect_page') {
          url = Navigation.GetDocumentHrefFromURL(child_link.href);

          if (Browser.SameDocument(url, Navigation.page_info.href)) {
            updated_className = Browser.AddClass(param_tab.className, 'ww_skin_toolbar_tab_selected');
          }
          else {
            updated_className = Browser.RemoveClass(param_tab.className, 'ww_skin_toolbar_tab_selected');
          }

          param_tab.className = updated_className;
        }
      }
    }
  );
};

Connect.UpdateBackToTop = function (param_top) {
  if (Connect.back_to_top_element !== null) {
    if (param_top > 80) {
      Connect.back_to_top_element.className = Browser.AddClass(Connect.back_to_top_element.className, 'back_to_top_show');
    } else {
      Connect.back_to_top_element.className = Browser.RemoveClass(Connect.back_to_top_element.className, 'back_to_top_show');
    }
  }
};

Connect.HandleScrollForBackToTop = function () {
  var scroll_position;

  if (Connect.page_first_scroll) {
    Connect.page_first_scroll = false;
    Connect.ProcessAnalyticsEvent('page_first_scroll');
  }

  scroll_position = parseFloat(Connect.container_div.scrollTop);
  Connect.UpdateBackToTop(scroll_position);
};

Connect.BackToTop = function () {
  // Report click event
  //
  Connect.ProcessAnalyticsEvent('page_button_back_to_top_click');

  // Scroll page to desired position
  //
  Connect.ScrollTo(0, 0);
};

Connect.BackToTopLink = function (param_event) {
  var event, result;

  // Access event
  //
  event = param_event || window.event;

  // Cancel event bubbling
  //
  event.cancelBubble = true;
  if (event.stopPropagation) {
    event.stopPropagation();
  } else {
    event.cancelBubble = true;
  }

  // Back to top
  //
  Connect.BackToTop();

  // Prevent default link behavior
  //
  result = false;

  return result;
};

Connect.ToolbarLink = function (param_event) {
  var event, result;

  // Access event
  //
  event = param_event || window.event;

  // Cancel event bubbling
  //
  event.cancelBubble = true;
  if (event.stopPropagation) {
    event.stopPropagation();
  } else {
    event.cancelBubble = true;
  }

  if (Connect.scope_enabled) {
    Scope.CloseDropDown();
  }

  // Process event
  //
  result = Connect.HandleToolbarLink(this);

  return result;
};

Connect.TOCFindFirstValidLinkElement = function (param_li_element) {
  var valid_link_element, div_element, link_element, ul_element, li_element;

  // Initialize return value
  //
  valid_link_element = null;

  // Check existing entry
  //
  div_element = Browser.FirstChildElementWithTagName(param_li_element, 'div');
  if (div_element !== null) {
    link_element = Browser.FirstChildElementWithTagName(div_element, 'a');
    if ((link_element !== null) && (link_element.href !== '')) {
      valid_link_element = link_element;
    }
  }

  // Anything found?
  //
  if (valid_link_element === null) {
    // Check nested list
    //
    ul_element = Browser.FirstChildElementWithTagName(param_li_element, 'ul');
    if (ul_element !== null) {
      li_element = Browser.FirstChildElementWithTagName(ul_element, 'li');
      if (li_element !== null) {
        valid_link_element = Connect.TOCFindFirstValidLinkElement(li_element);
      }

      // Try next entry?
      //
      if (valid_link_element === null) {
        li_element = Browser.NextSiblingElementWithTagName(li_element, 'li');
        while ((valid_link_element === null) && (li_element !== null)) {
          valid_link_element = Connect.TOCFindFirstValidLinkElement(li_element);
          li_element = Browser.NextSiblingElementWithTagName(li_element, 'li');
        }
      }
    }
  }

  return valid_link_element;
};

Connect.TOCLinkProcessor = function (param_link) {
  var result;

  result = true;

  // Process link
  //
  if (param_link !== null && param_link.href !== '') {
    if (param_link.className.length === 0 &&
      Browser.ContainsClass(param_link.parentNode.className, 'ww_skin_toc_folder')) {
      // Unloaded parcel TOC link
      //
      result = false;
    } else {
      result = Navigation.InterceptLink(param_link, true);
      if (result === false) {
        // Clean up folders?
        //
        if (Connect.layout_wide) {
          // Keep the menu active!
          //
          Connect.toc_cleanup_folders = false;
        }
      }
    }
  }

  return result;
};

Connect.TOCEntryClickHandler = function (param_event) {
  var result, event, child_link, toc_li_element;

  result = true;

  // Access event
  //
  event = param_event || window.event;

  // Cancel event bubbling
  //
  event.cancelBubble = true;
  if (event.stopPropagation) {
    event.stopPropagation();
  } else {
    event.cancelBubble = true;
  }

  // Clicked folder?
  //
  child_link = null;
  if (Browser.ContainsClass(this.className, 'ww_skin_toc_folder')) {
    // Toggle open/closed
    //
    Connect.TOCFolder_Toggle(this);

    // Opened folder?
    //
    if (Connect.TOCFolder_IsOpen(this)) {
      // Locate valid child link?
      //
      toc_li_element = Browser.FindParentWithTagName(this, 'li');
      if (toc_li_element !== null) {
        child_link = Connect.TOCFindFirstValidLinkElement(toc_li_element);
      }
    }

    result = false;
  } else {
    // Access child link
    //
    child_link = Browser.FirstChildElementWithTagName(this, 'a');
  }

  Connect.ProcessAnalyticsEvent('menu_click_toc');

  // Process child link
  //
  result = Connect.TOCLinkProcessor(child_link);

  return result;
};

Connect.TOCDropdownClickHandler = function (param_event) {
  var result, event, parent_div;

  result = true;

  // Access event
  //
  event = param_event || window.event;

  // Cancel event bubbling
  //
  event.cancelBubble = true;
  if (event.stopPropagation) {
    event.stopPropagation();
  } else {
    event.cancelBubble = true;
  }

  // Clicked folder?
  //
  parent_div = Browser.FirstAncestorElementContainingClass(this, 'ww_skin_toc_folder');

  if (parent_div !== null) {
    // Toggle open/closed
    //
    Connect.TOCFolder_Toggle(parent_div);

    result = false;
  }

  return result;
};

Connect.TOCLinkClickHandler = function (param_event) {
  var event, parent_div, result;

  // Access event
  //
  event = param_event || window.event;

  // Cancel event bubbling
  //
  event.cancelBubble = true;
  if (event.stopPropagation) {
    event.stopPropagation();
  } else {
    event.cancelBubble = true;
  }

  // Expand if closed folder
  //
  parent_div = Browser.FindParentWithTagName(this, 'div');
  if ((parent_div !== null) && (Browser.ContainsClass(parent_div.className, 'ww_skin_toc_folder'))) {
    Connect.TOCFolder_Open(parent_div);
  }

  Connect.ProcessAnalyticsEvent('menu_click_toc');

  // Process event
  //
  result = Connect.TOCLinkProcessor(this);

  return result;
};

Connect.DisplayTOC = function () {
  // #toc/
  // TOC enabled?
  //
  if (Connect.toc_div !== null) {
    // Display TOC
    //
    Connect.Menu.Show();
    if (Connect.sidebar_behavior !== 'ww_behavior_toc') {
      Connect.sidebar_behavior = 'ww_behavior_toc';
      Connect.Button_TOC();
    }
  }
};

Connect.TOC_ElementKey = function (param_element) {
  var element_key, element_in_path, position, sibling;

  // Build key
  //
  element_key = '';
  element_in_path = param_element;
  while ((element_in_path !== undefined) && (element_in_path !== null) && ((typeof element_in_path.id !== 'string') || (element_in_path.id.length === 0))) {
    position = 0;
    sibling = element_in_path;
    while (sibling !== null) {
      position += 1;
      sibling = sibling.previousSibling;
    }
    element_key = element_in_path.nodeName + ':' + position + ':' + element_key;
    element_in_path = element_in_path.parentNode;
  }
  if ((element_in_path !== undefined) && (element_in_path !== null)) {
    element_key = element_in_path.id + ':' + element_key;
  }

  return element_key;
};

Connect.TOC_RecordClassState = function (param_element) {
  var element_key;

  // Track original class info if enabled
  //
  if (Connect.toc_class_states !== null) {
    // Build key
    //
    element_key = Connect.TOC_ElementKey(param_element);

    // Already tracking?
    //
    if (typeof Connect.toc_class_states[element_key] !== 'object') {
      Connect.toc_class_states[element_key] = { 'element': param_element, 'className': param_element.className };
    }
  }
};

Connect.TOC_RestoreClassStates = function (param_folder_exceptions) {
  var element_key, preserved_toc_class_states, entry_state;

  if (Connect.toc_class_states !== null) {
    preserved_toc_class_states = {};
    for (element_key in Connect.toc_class_states) {
      if (typeof Connect.toc_class_states[element_key] === 'object') {
        entry_state = Connect.toc_class_states[element_key];
        entry_state.element.className = entry_state.className;

        // Keep folder open?
        //
        if (Browser.ContainsClass(entry_state.className, 'ww_skin_toc_folder')) {
          if ((param_folder_exceptions !== undefined) && (typeof param_folder_exceptions[element_key] === 'boolean')) {
            // Keep folder open
            //
            preserved_toc_class_states[element_key] = entry_state;
          } else {
            // Collapse folder
            //
            Connect.TOCFolder_Close(entry_state.element);
          }
        }
      }
    }

    // Reset tracked states
    //
    Connect.toc_class_states = preserved_toc_class_states;
  }
};

Connect.TOCFolder_IsOpen = function (param_entry_div) {
  var result, child_span;

  // Initialize return value
  //
  result = false;

  if (Browser.ContainsClass(param_entry_div.className, 'ww_skin_toc_folder')) {
    child_span = param_entry_div.querySelector('span.ww_skin_toc_dropdown_open');

    if (child_span !== null) {
      result = true;
    }
  }

  return result;
};

Connect.TOCFolder_Open = function (param_entry_div) {
  var child_span, sibling_ul;

  if (Browser.ContainsClass(param_entry_div.className, 'ww_skin_toc_folder')) {
    Connect.TOC_RecordClassState(param_entry_div);

    child_span = param_entry_div.querySelector('span.ww_skin_toc_dropdown_closed');
    if (child_span !== null) {
      child_span.className = Browser.ReplaceClass(child_span.className, 'ww_skin_toc_dropdown_closed', 'ww_skin_toc_dropdown_open');
    }
    sibling_ul = Browser.NextSiblingElementWithTagName(param_entry_div, 'ul');
    if (sibling_ul !== null) {
      sibling_ul.className = Browser.ReplaceClass(sibling_ul.className, 'ww_skin_toc_container_closed', 'ww_skin_toc_container_open');
    }
  }
};

Connect.TOCFolder_Close = function (param_entry_div) {
  var child_span, sibling_ul;

  if (Browser.ContainsClass(param_entry_div.className, 'ww_skin_toc_folder')) {
    Connect.TOC_RecordClassState(param_entry_div);

    child_span = param_entry_div.querySelector('span.ww_skin_toc_dropdown_open');
    if (child_span !== null) {
      child_span.className = Browser.ReplaceClass(child_span.className, 'ww_skin_toc_dropdown_open', 'ww_skin_toc_dropdown_closed');
    }
    sibling_ul = Browser.NextSiblingElementWithTagName(param_entry_div, 'ul');
    if (sibling_ul !== null) {
      sibling_ul.className = Browser.ReplaceClass(sibling_ul.className, 'ww_skin_toc_container_open', 'ww_skin_toc_container_closed');
    }
  }
};

Connect.TOCFolder_Toggle = function (param_entry_div) {
  if (Browser.ContainsClass(param_entry_div.className, 'ww_skin_toc_folder')) {
    if (Connect.TOCFolder_IsOpen(param_entry_div)) {
      Connect.TOCFolder_Close(param_entry_div);
    } else {
      Connect.TOCFolder_Open(param_entry_div);
    }
    Connect.Menu.CalculateMenuSize();
  }
};

Connect.DisplayIndex = function () {
  // #index/
  // Index enabled?
  //
  if (Connect.index_div !== null) {
    // Display index
    //
    Connect.Menu.Show();
    if (Connect.sidebar_behavior !== 'ww_behavior_index') {
      Connect.sidebar_behavior = 'ww_behavior_index';
      Connect.Button_Index();
    }
  }
};

Connect.HandleToolbarLink = function (param_link) {
  var result, behavior;

  result = true;

  if (typeof param_link.className === 'string') {
    // Determine handlers for button
    //
    for (behavior in Connect.button_behaviors) {
      if (typeof Connect.button_behaviors[behavior] === 'function') {
        if (Browser.ContainsClass(param_link.className, behavior)) {
          Connect.button_behaviors[behavior](param_link);
          result = false;
          break;
        }
      }
    }
  }

  return result;
};

Connect.PositionPopup = function () {
  var page_div_rect = Connect.page_div.getBoundingClientRect();
  var popup_rect = Connect.popup_div.getBoundingClientRect();

  var popup_left = Connect.popup_info.link_x;
  var popup_top = Connect.popup_info.link_y + Connect.popup_info.link_height;

  if (popup_top + popup_rect.height > page_div_rect.height) {
    popup_top = Connect.popup_info.link_y - Connect.popup_info.link_height - popup_rect.height;

    if (popup_top < 0) {
      popup_top = 0;
    }
  }

  if (popup_left + popup_rect.width > page_div_rect.width) {
    popup_left = Connect.popup_info.link_x + Connect.popup_info.link_width - (popup_rect.width / 2);

    if (popup_left + popup_rect.width > page_div_rect.width) {
      popup_left = Connect.popup_info.link_x + Connect.popup_info.link_width - popup_rect.width;
    }

    if (popup_left < 0) {
      popup_left = 0;
    }
  }

  // Apply the calculated position
  Connect.popup_div.style.left = popup_left + 'px';
  Connect.popup_div.style.top = popup_top + 'px';
}

Connect.ShowPopup = function () {
  Connect.popup_div.style.overflowY = 'auto';
  Connect.popup_div.style.zIndex = 1000;
  Connect.popup_div.style.opacity = 1;
}

Connect.HidePopup = function () {
  Connect.popup_info.is_focused_on_popup = false;
  Connect.popup_div.style.opacity = 0;
  Connect.popup_div.style.zIndex = -1000;
  Connect.popup_div.style.overflowY = 'scroll';
}

Connect.AnalyticsEnabled = function () {
  var analytics_enabled, location_host, default_url, trimmed_default_url, regexRemoveProtocol, regexRemovePath;

  analytics_enabled = false;

  if (typeof Analytics !== 'undefined') {
    location_host = Connect_Window.location.host;
    default_url = Browser.DecodeURIComponent(Analytics.ga_default_url);
    regexRemoveProtocol = RegExp(/(\w+:)(\/\/|\\\\)/);
    regexRemovePath = RegExp(/\/.*$/);
    trimmed_default_url = default_url.replace(regexRemoveProtocol, '');
    trimmed_default_url = trimmed_default_url.replace(regexRemovePath, '');

    if (default_url === '') {
      analytics_enabled = true;
    } else {
      analytics_enabled = (location_host.indexOf(trimmed_default_url) === -1) ? false : true;
    }
  }

  return analytics_enabled;
};

Connect.ProcessAnalyticsEventTopic = function (param_context, param_topic) {
  if (Connect.google_analytics_enabled) {
    try {
      Connect.PreLoadDataForAnalyticsTopic(param_context, param_topic);
      Analytics.CaptureEvent();
    }
    catch (ignore) {
      //do nothing
    }
  }
};

Connect.ProcessAnalyticsEvent = function (param_event_type) {
  if (Connect.google_analytics_enabled) {
    try {
      Connect.PreLoadDataForAnalytics(param_event_type);
      Analytics.CaptureEvent();
    }
    catch (ignore) {
      //do nothing
    }
  }
};

Connect.PreLoadDataForAnalyticsTopic = function (param_context, param_topic) {
  var page_location, page_path, page_title;

  page_location = document.location.href;
  page_path = document.location.pathname + document.location.search + '#context/' + param_context + '/' + param_topic;
  page_title = Navigation.page_info.title;

  Analytics.event_type = 'topic_lookup';
  Analytics.event_data['title'] = page_title;
  Analytics.event_data['context'] = param_context;
  Analytics.event_data['topic'] = param_topic;
  Analytics.event_data['location'] = page_location;
  Analytics.event_data['path'] = page_path;
};

Connect.PreLoadDataForAnalytics = function (param_event_type) {
  var page_title, page_location, page_hash, page_path, search_query, url_handler_page_hash;

  Analytics.event_type = param_event_type;

  // Get window location hash if not on a content page
  //
  url_handler_page_hash = Navigation.url_handler_object['page'];
  if (url_handler_page_hash === undefined) {
    page_hash = Connect_Window.location.hash;
  } else {
    page_hash = Browser.DecodeURIComponent('#page/' + url_handler_page_hash);
  }

  page_location = document.location.href;
  page_path = document.location.pathname + document.location.search + page_hash;
  page_title = Navigation.page_info.title;

  if (Connect.page_cargo.search_query !== undefined) {  // Search from result page
    search_query = Connect.page_cargo.search_query;
  } else if (Connect.search_input.value !== undefined) { // Search from toolbar
    search_query = Connect.search_input.value;
  }

  Analytics.event_data['title'] = page_title;
  Analytics.event_data['location'] = page_location;
  Analytics.event_data['path'] = page_path;
  Analytics.event_data['query'] = search_query;
};

Connect.Socialize = function () {
  var data;

  // Socialize
  //
  data = {
    'action': 'page_socialize',
    'disqus_id': Connect.disqus_id
  };
  Message.Post(Connect.page_iframe.contentWindow, data, Connect_Window);
};

Connect.Globalize = function () {
  var data;

  // Google Translation
  //
  if (Connect.globe_enabled) {
    data = {
      'action': 'page_globalize'
    };
    Message.Post(Connect.page_iframe.contentWindow, data, Connect_Window);
  }
};

Connect.SearchQueryHighlight = function () {
  var data;

  data = {
    'action': 'page_search_query_highlight',
    'search_query': Connect.page_cargo.search_query,
    'search_synonyms': Connect.page_cargo.search_synonyms,
    'search_minimum_word_length': Connect.page_cargo.search_minimum_word_length,
    'search_stop_words': Connect.page_cargo.search_stop_words
  };
  Message.Post(Connect.page_iframe.contentWindow, data, Connect_Window);
};

Connect.AdjustForSearchContentSize = function () {
  var data;

  data = {
    'action': 'search_get_page_size',
    'stage': 'height'
  };
  Message.Post(Connect.search_iframe.contentWindow, data, Connect_Window);
};

Connect.EnableDisableButton = function (param_button_behavior, param_ccs_class_prefix, param_enable) {
  var button_span, updated_className;

  button_span = Connect.buttons[param_button_behavior];
  if (button_span !== undefined) {
    // Update class name
    //
    updated_className = button_span.className;
    updated_className = Browser.RemoveClass(updated_className, 'ww_skin_toolbar_button_enabled');
    updated_className = Browser.RemoveClass(updated_className, 'ww_skin_toolbar_button_disabled');
    if (param_enable) {
      // Enable
      //
      updated_className = Browser.AddClass(updated_className, 'ww_skin_toolbar_button_enabled');
    } else {
      // Disable
      //
      updated_className = Browser.AddClass(updated_className, 'ww_skin_toolbar_button_disabled');
    }
    button_span.className = updated_className;
  }
};

Connect.Listen = function (param_event) {
  // Initialize listen dispatcher
  //
  if (Connect.dispatch_listen === undefined) {
    Connect.dispatch_listen = {
      'page_load_data': function (param_data) {
        Navigation.page_info = param_data;
        delete Navigation.page_info['action'];

        Connect.OnDocumentLoad();

        var data = {
          action: 'page_load_data_complete'
        };

        Message.Post(Connect.page_iframe.contentWindow, data, Connect_Window);
      },
      'page_load_scroll': function (param_data) {
        var top, data;

        top = param_data.top;

        Connect.ScrollTo(0, top);

        data = {
          'action': 'page_load_scroll_complete'
        };

        Message.Post(Connect.page_iframe.contentWindow, data, Connect_Window);
      },
      'page_load_complete': function (param_data) {
        if (!Connect.first_page_loaded) {
          var body_className;

          // loaded our first page
          // we can take off the 'preload' class
          // so we can get CSS transitions
          body_className = Browser.RemoveClass(Connect_Window.document.body.className, 'preload');
          Connect_Window.document.body.className = body_className;
          Connect.first_page_loaded = true;
        }
        Connect.TabUpdateSelected();
      },
      'page_unload': function (param_data) {
        Navigation.page_info = null;

        Connect.OnDocumentUnload();
      },
      'page_bookkeeping': function (param_data) {
        // Document bookkeeping
        //
        if (param_data.href !== undefined) {
          Navigation.page_info.href = param_data.href;
        }
        if (param_data.hash !== undefined) {
          Navigation.page_info.hash = param_data.hash;
        }

        Navigation.DocumentBookkeeping(true);
      },
      'page_scroll_view': function (param_data) {
        var top, browser_widthheight;

        // Determine final scroll position and scroll
        //
        top = param_data.top;

        Connect.ScrollTo(0, top);
      },
      'page_size': function (param_data) {
        if (Navigation.page_info) {
          var has_dimensions, dimensions_changed;

          has_dimensions = !!Navigation.page_info.dimensions;

          if (has_dimensions) {
            dimensions_changed =
              Navigation.page_info.dimensions.height !== param_data.dimensions.height ||
              Navigation.page_info.dimensions.width !== param_data.dimensions.width;

            if (dimensions_changed) {
              Navigation.page_info.dimensions = param_data.dimensions;

              Connect.ResizePage();
            }
          }
        }
      },
      'page_report_pdf_click': function (param_data) {
        // Report click event
        //
        Connect.ProcessAnalyticsEvent('page_button_pdf_click');
      },
      'popup_load_data': function (param_data) {
        Connect.popup_info.page_height = param_data.dimensions.height;
        Connect.popup_iframe.style.height = Connect.popup_info.page_height + 'px';

        Connect.PositionPopup()

        var data = {
          'action': 'popup_update_anchors',
          'target': Connect_Window.name,
          'base_url': Navigation.base_url,
          'parcel_prefixes': Parcels.prefixes
        };
        Message.Post(Connect.popup_iframe.contentWindow, data, Connect_Window);

        Connect.ShowPopup()
      },
      'popup_link_mouseenter': function (param_data) {
        var popup_href = Navigation.base_url + param_data.href;

        Connect.HidePopup()

        Connect.popup_info = {
          href: popup_href,
          is_focused_on_link: true,
          is_focused_on_popup: false,
          link_x: param_data.x,
          link_y: param_data.y,
          link_height: param_data.height,
          link_width: param_data.width
        }

        Connect.popup_div.scrollTop = 0;
        Connect.popup_div.scrollLeft = 0;
        Connect.popup_iframe.src = popup_href
      },
      'popup_link_mouseleave': function (param_data) {
        Connect.popup_info.is_focused_on_link = false;
      },
      'popup_link_mouseleave_timeout': function (param_data) {
        var dont_hide_popup = Connect.popup_info.is_focused_on_link || Connect.popup_info.is_focused_on_popup

        if (!dont_hide_popup) {
          Connect.HidePopup()
        }
      },
      'back_to_top': function (param_data) {
        Connect.BackToTop();
      },
      'handle_toolbar_link': function (param_data) {
        // Invoke toolbar link
        //
        Connect.button_behaviors[param_data.behavior]();
      },
      'display_link': function (param_data) {
        var href, target, is_connect_navigation;

        href = param_data.href;
        target = param_data.target;
        is_connect_navigation = !target || target === '_self' || target === 'connect_page';

        if (is_connect_navigation) {
          href = Navigation.NormalizeURL(href);

          Navigation.Navigate(href, false);
        } else {
          Connect_Window.open(href, target);
        }
      },
      'display_image': function (param_data) {
        Connect.DisplayFullsizeImage(param_data);
      },
      'search_page_load_data': function (param_data) {
        var data;

        // Record page info
        //
        Connect.search_page_info = param_data;
        delete Connect.search_page_info['action'];

        data = {
          'action': 'search_connect_info',
          'target': Connect_Window.name,
          'base_url': Navigation.base_url,
          'parcel_prefixes': Parcels.prefixes,
          'parcel_sx': Parcels.search,
          'query': Connect.search_query
        };

        if (Connect.scope_enabled) {
          var search_scope_selection_titles_string;

          search_scope_selection_titles_string = Scope.GetSearchScopeSelectionTitlesString();

          data['search_scopes'] = Scope.search_scopes;
          data['search_scope_map'] = Scope.search_scope_map;
          data['search_scope_selections'] = Scope.search_scope_selections;
          data['search_scope_selection_titles'] = search_scope_selection_titles_string;
        }

        // Send search file list
        //
        Message.Post(Connect.search_iframe.contentWindow, data, Connect_Window);
      },
      'search_ready': function (param_data) {
        var data;

        // Search panel displayed?
        //
        if (Connect.search_div.parentNode !== Connect.panels_div) {
          // Execute search
          //
          data = {
            'action': 'search_execute',
            'query': Connect.search_query
          };
          Message.Post(Connect.search_iframe.contentWindow, data, Connect_Window);
        }
      },
      'search_complete': function (param_data) {
        // Update dimensions
        //
        Connect.search_page_info.dimensions = param_data.dimensions;

        // Adjust layout for search content
        //
        Connect.AdjustForSearchContentSize();
      },
      'search_page_size': function (param_data) {
        var data;

        if (Connect.search_page_info) {
          var has_dimensions, dimensions_changed;

          has_dimensions = !!Connect.search_page_info.dimensions;

          if (has_dimensions) {
            // Update dimensions
            //
            Connect.search_page_info.dimensions = param_data.dimensions;

            // Set content height
            //
            Connect.search_div.style.height = String(Connect.search_page_info.dimensions.height) + 'px';

            // Workaround Google Chrome refresh issue
            //
            Connect.search_iframe.style.height = '';
            Connect.search_iframe.style.height = Connect.search_page_info.dimensions.height;

            Connect.Menu.CalculateMenuSize();
          }
        }
      },
      'search_display_link': function (param_data) {
        // Track search words
        //
        Connect.page_cargo.search_href = param_data.href;
        Connect.page_cargo.search_title = param_data.title;
        Connect.page_cargo.search_query = Connect.search_query;
        Connect.page_cargo.search_synonyms = Connect.search_synonyms;
        Connect.page_cargo.search_minimum_word_length = param_data.minimum_word_length;
        Connect.page_cargo.search_stop_words = param_data.stop_words;
        // add page_cargo.pathname

        // Display specified page
        //
        if (param_data.href !== undefined) {
          var href = Navigation.NormalizeURL(param_data.href);

          Navigation.Navigate(href, true);
        }
      },
      'page_clicked': function (param_data) {
        if (Connect.scope_enabled) {
          Scope.CloseDropDown();
        }

        Connect.ProcessAnalyticsEvent('page_click');
      },
      'search_page_clicked': function (param_data) {
        if (Connect.scope_enabled) {
          Scope.CloseDropDown();
        }
      },
      'page_helpful_button_click': function (param_data) {
        switch (param_data.helpful) {
          case 'yes':
            Connect.ProcessAnalyticsEvent('page_helpful_button_click_yes');
            break;
          case 'no':
            Connect.ProcessAnalyticsEvent('page_helpful_button_click_no');
            break;
        }
      },
      'search_helpful_button_click': function (param_data) {
        switch (param_data.helpful) {
          case 'yes':
            Connect.ProcessAnalyticsEvent('search_helpful_button_click_yes');
            break;
          case 'no':
            Connect.ProcessAnalyticsEvent('search_helpful_button_click_no');
            break;
        }
      },
      'parcel_load': function (param_data) {
        var parcel = Parcels.entries[param_data.id];

        if (parcel) {
          parcel.content = param_data.content;
          parcel.done();
        }
      },
      'index_load': function (param_data) {
        var index_object = Index.index_objects[param_data.id];

        if (index_object) {
          index_object.content = param_data.content;
          index_object.done();
        }
      }
    };
  }

  // Dispatch event
  //
  try {
    Connect.dispatch_listen[param_event.data.action](param_event.data);
  } catch (ignore) {
    // Keep on rolling
    //
  }
};

Connect.UpdateTitle = function () {
  var title, page_document;

  // Determine title
  //
  title = '';
  if (Connect.SearchEnabled()) {
    // Make the search title custom from a Target Setting
    //
    title = Connect.search_title;
    if (Connect.search_query !== undefined && Connect.search_query.length > 0) {
      title += ': ' + Connect.search_query;
    }
  } else if (Navigation.page_info) {
    title = Navigation.page_info.title;
  } else {
    page_document = Browser.GetDocument(Connect.page_iframe);
    if (page_document !== undefined) {
      title = page_document.title;
    }
  }

  // Set title
  //
  Connect.SetTitle(title);
};

Connect.SetTitle = function (param_title) {
  // Update window title
  //
  Connect_Window.document.title = param_title;
};

Connect.OnDocumentLoad = function () {
  var enable_button;

  // Document bookkeeping
  //
  Navigation.DocumentBookkeeping(false);

  // Update title
  //
  Connect.UpdateTitle();

  // Update home
  //
  enable_button = !Navigation.page_info || !Browser.SameDocument(Navigation.default_page_url, Navigation.page_info.href) || Connect.SearchEnabled();
  Connect.EnableDisableButton('ww_behavior_home', 'ww_skin_home', enable_button);

  // Update prev/next
  //
  Navigation.UpdatePrevNext();

  // Socialize and Globalize
  //
  Connect.Socialize();
  Connect.Globalize();

  // if we have document dimensions, resize
  //
  if (Navigation.page_info && Navigation.page_info.dimensions) {
    Connect.ResizePage();
  }
};

Connect.OnDocumentUnload = function () {
  Connect.page_first_scroll = true;

  Connect.UpdateTitle();
};

Connect.DisplayFullsizeImage = function (param_image_data) {
  var display_in_lightbox, browser_widthheight, fullsize_image;

  // Always display images in lightbox?
  //
  display_in_lightbox = Connect.lightbox_large_images;
  if (!display_in_lightbox) {
    // Retrieve width/height info
    //
    browser_widthheight = Browser.GetBrowserWidthHeight(Connect_Window);

    // Enough room for lightbox?
    //
    if (((param_image_data.width + Connect.lightbox_min_pixel_margin) < browser_widthheight.width) && ((param_image_data.height + Connect.lightbox_min_pixel_margin) < browser_widthheight.height)) {
      display_in_lightbox = true;
    }
  }

  // Display in lightbox?
  //
  if (display_in_lightbox) {
    // Create image to display
    //
    fullsize_image = Connect_Window.document.createElement('img');
    Browser.SetAttribute(fullsize_image, 'src', param_image_data.src);
    fullsize_image.onclick = function (e) {
      // Prevent the lightbox from closing if the image is clicked
      //
      e.stopPropagation();
    };

    // Display lightbox
    //
    Connect.Lightbox.Display(
      function (param_lightbox_frame, param_lightbox_content) {
        param_lightbox_content.innerHTML = '';
        param_lightbox_content.appendChild(fullsize_image);
      },
      function (param_lightbox_frame, param_lightbox_content) {
        param_lightbox_content.removeChild(fullsize_image);
      }
    );
  } else {
    // Replace displayed document
    //
    var href = Navigation.NormalizeURL(param_image_data.href);

    Navigation.Navigate(href, false);
  }
};

Connect.ScrollToMenuElement = function (param_element) {
  var browser_widthheight, menu_height, element_scroll_position,
    menu_75_height, menu_50_height, target_scroll_top,
    menu_frame_scroll_position, index_active, toc_active, menu_scroll_element;

  index_active = document.querySelector("#menu_content #index_content") !== null;
  toc_active = document.querySelector("#menu_content #toc_content") !== null;

  if (index_active) {
    menu_scroll_element = Connect.index_content_div;
  } else if (toc_active) {
    menu_scroll_element = Connect.toc_content_div;
  }

  if (menu_scroll_element !== undefined) {
    // Narrow or wide layout?
    //
    if ((Connect.layout_wide) || (Connect.layout_tall)) {
      // Scroll to element position
      //
      browser_widthheight = Browser.GetBrowserWidthHeight(Connect_Window);
      menu_height = browser_widthheight.height;

      element_scroll_position = Browser.GetElementScrollPosition(param_element, menu_scroll_element);
      menu_75_height = Math.floor(menu_height * 0.75);
      menu_50_height = Math.floor(menu_height * 0.5);
      if ((element_scroll_position.top >= menu_scroll_element.scrollTop) &&
        (element_scroll_position.top <= (menu_scroll_element.scrollTop + menu_75_height))) {
        // Do nothing
        //
        target_scroll_top = menu_scroll_element.scrollTop;
      } else {
        if (element_scroll_position.top < menu_75_height) {
          target_scroll_top = 0;
        } else {
          target_scroll_top = element_scroll_position.top - menu_50_height;
        }
      }
      menu_scroll_element.scrollTop = target_scroll_top;
    } else {
      menu_frame_scroll_position = Browser.GetElementScrollPosition(menu_scroll_element);
      element_scroll_position = Browser.GetElementScrollPosition(param_element);

      Connect.ScrollTo(
        menu_frame_scroll_position.left + element_scroll_position.left,
        menu_frame_scroll_position.top + element_scroll_position.top
      );
    }
  }
};

Connect.SyncTOC = function (param_cleanup_folders) {
  var entry_state, toc_entry, entry_div, folder_exceptions,
    parent_ul, parent_entry_div, button_span, is_entry_first_child, ul_previous_sibling;

  // Clear highlight
  //
  if (Connect.toc_selected_entry_key !== undefined) {
    entry_state = Connect.toc_class_states[Connect.toc_selected_entry_key];
    if (entry_state !== undefined) {
      entry_state.element.className = entry_state.className;
    }

    Connect.toc_selected_entry_key = undefined;
  }

  // Locate TOC entry
  //
  toc_entry = Connect.LocateTOCEntry();

  // Expand TOC for context
  //
  if (toc_entry !== null) {
    // Highlight entry
    //
    entry_div = Browser.FirstChildElementWithTagName(toc_entry, 'div');
    if (entry_div !== null) {
      // Clean up folders?
      //
      if (param_cleanup_folders) {
        folder_exceptions = {};
        if (Browser.ContainsClass(entry_div.className, 'ww_skin_toc_folder')) {
          folder_exceptions[Connect.TOC_ElementKey(entry_div)] = true;
        }
        parent_ul = Browser.FindParentWithTagName(entry_div, 'ul');
        while (parent_ul !== null) {
          parent_entry_div = Browser.PreviousSiblingElementWithTagName(parent_ul, 'div');
          if (parent_entry_div !== null) {
            if (Browser.ContainsClass(parent_entry_div.className, 'ww_skin_toc_folder')) {
              folder_exceptions[Connect.TOC_ElementKey(parent_entry_div)] = true;
            }
          }

          parent_ul = Browser.FindParentWithTagName(parent_ul, 'ul');
        }
        Connect.TOC_RestoreClassStates(folder_exceptions);
      }

      // Highlight
      //
      // Is the TOC entry hidden?
      //
      if (Browser.ContainsClass(toc_entry.className, 'ww_skin_toc_entry_hidden')) {
        // Attempt to highlight parent TOC entry
        //
        parent_ul = Browser.FindParentWithTagName(toc_entry, 'ul');
        is_entry_first_child = parent_ul.firstChild === toc_entry;
        if (is_entry_first_child) {
          ul_previous_sibling = parent_ul.previousElementSibling;

          // Is the previous sibling a TOC entry?
          if (Browser.ContainsClass(ul_previous_sibling.className, 'ww_skin_toc_entry')) {
            Connect.TOC_RecordClassState(ul_previous_sibling);
            ul_previous_sibling.className = Browser.AddClass(ul_previous_sibling.className, 'ww_skin_toc_entry_selected');
            Connect.toc_selected_entry_key = Connect.TOC_ElementKey(ul_previous_sibling);
          }
        }
      } else {
        Connect.TOC_RecordClassState(entry_div);
        entry_div.className = Browser.AddClass(entry_div.className, 'ww_skin_toc_entry_selected');
        Connect.toc_selected_entry_key = Connect.TOC_ElementKey(entry_div);
      }

      // Expand entry and parents
      //
      Connect.TOCFolder_Open(entry_div);
      parent_ul = Browser.FindParentWithTagName(entry_div, 'ul');
      while (parent_ul !== null) {
        parent_entry_div = Browser.PreviousSiblingElementWithTagName(parent_ul, 'div');
        if (parent_entry_div !== null) {
          Connect.TOCFolder_Open(parent_entry_div);
        }

        parent_ul = Browser.FindParentWithTagName(parent_ul, 'ul');
      }

      // Scroll to TOC position if TOC displayed
      //
      button_span = Connect.buttons['ww_behavior_toc'];
      if (button_span && Connect.Menu.menu_mode_visible === 'toc') {
        Connect.ScrollToMenuElement(toc_entry);
      }
    }
  }
};

Connect.Button_Home = function () {
  if (!Connect.ButtonDisabled(Connect.buttons['ww_behavior_home'])) {
    // Go to default page
    //
    var href = Navigation.NormalizeURL(Navigation.default_page_url);

    Navigation.Navigate(href, true);

    Connect.ProcessAnalyticsEvent('toolbar_button_home_click');
  }
};

Connect.Button_External = function (param_link) {
  if (param_link !== null) {
    var link_href;

    link_href = param_link.href;
    // Follow Link
    //
    if (link_href !== undefined && link_href !== '#') {
      window.open(link_href, '_blank');
    }
  }
};

Connect.Button_TOC = function () {
  var toc_button_span;

  toc_button_span = Connect.buttons['ww_behavior_toc'];

  if (Connect.Menu.Enabled && Connect.Menu.menu_mode_visible !== 'toc') {
    var index_button_span;

    index_button_span = Connect.buttons['ww_behavior_index'];

    // Move the Index back to the panels div
    //
    Connect.panels_div.appendChild(Connect.index_div);

    if (index_button_span !== undefined) {
      index_button_span.className = Browser.RemoveClass(index_button_span.className, 'ww_skin_menu_nav_selected');
    }

    // Show
    //
    Connect.Menu.Display(
      function (param_window, param_menu_content) {
        // Highlight toolbar button
        //
        if (toc_button_span !== undefined) {
          toc_button_span.className = Browser.AddClass(toc_button_span.className, 'ww_skin_menu_nav_selected');
        }

        // Sync TOC
        //
        Connect.SyncTOC(Connect.toc_cleanup_folders);

        // On Stage
        //
        if (Connect.buttons['ww_behavior_toc'] !== undefined && Connect.buttons['ww_behavior_index']) {
          param_menu_content.appendChild(Connect.nav_buttons_div);
        }

        param_menu_content.appendChild(Connect.toc_div);

        // Retry Sync TOC if necessary
        // (come back to this... do we need?)
        //
        Connect_Window.setTimeout(function () {
          Connect.SyncTOC(Connect.toc_cleanup_folders);
        }, 10);
      },
      function (param_window, param_menu_content) {
        // Backstage
        //
        Connect.panels_div.appendChild(Connect.toc_div);

        // Update title
        //
        Connect.UpdateTitle();

        // Restore class info
        //
        Connect.TOC_RestoreClassStates();

        // Highlight toolbar button
        //
        if (button_span !== undefined) {
          button_span.className = Browser.ReplaceClass(button_span.className, 'ww_skin_toolbar_background_selected', 'ww_skin_toolbar_background_default');
        }
      });
    Connect.sidebar_behavior = 'ww_behavior_toc';
    Connect.Menu.menu_mode_visible = 'toc';
  } else {
    // Do nothing
    //
  }
};

Connect.Button_Index = function () {
  var index_button_span;

  index_button_span = Connect.buttons['ww_behavior_index'];

  if (Connect.Menu.Enabled && Connect.Menu.menu_mode_visible !== 'index') {

    var toc_button_span;

    toc_button_span = Connect.buttons['ww_behavior_toc'];

    // Move the TOC back to the panels div
    //
    Connect.panels_div.appendChild(Connect.toc_div);

    if (toc_button_span !== undefined) {
      toc_button_span.className = Browser.RemoveClass(toc_button_span.className, 'ww_skin_menu_nav_selected');
    }

    // Show
    //
    Connect.Menu.Display(
      function (param_window, param_menu_content) {

        // Highlight toolbar button
        //
        if (index_button_span !== undefined) {
          index_button_span.className = Browser.AddClass(index_button_span.className, 'ww_skin_menu_nav_selected');
        }

        if (Connect.buttons['ww_behavior_toc'] !== undefined && Connect.buttons['ww_behavior_index']) {
          param_menu_content.appendChild(Connect.nav_buttons_div);
        }

        // On Stage
        //
        if (!Index.loaded) {
          if (!Index.loading) {
            // Initiate index load
            //
            Index.loading = true;
            Connect.index_content_div.innerHTML = '';
            Connect_Window.setTimeout(Index.Load);
          }
        } else {
          // Show index
          //
          param_menu_content.appendChild(Connect.index_div);
        }
      },
      function (param_window, param_menu_content) {
        // Backstage
        //
        Connect.panels_div.appendChild(Connect.index_div);

        // Update title
        //
        Connect.UpdateTitle();

        // Highlight toolbar button
        //
        if (button_span !== undefined) {
          button_span.className = Browser.ReplaceClass(button_span.className, 'ww_skin_toolbar_background_selected', 'ww_skin_toolbar_background_default');
        }
      });
    Connect.sidebar_behavior = 'ww_behavior_index';
    Connect.Menu.menu_mode_visible = 'index';
  } else {
    // Do nothing
    //
  }
};

Connect.Button_Search = function () {
  var search_enabled;

  search_enabled = Connect.SearchEnabled();

  if (!search_enabled) {
    // Do the search
    //
    Navigation.HandleSearchURL();
    Connect.ShowSearchPage();
    Connect.ProcessAnalyticsEvent('toolbar_button_search_click');
  } else {
    // Go back to the content page
    //
    Navigation.BackToCurrentPage();
    Connect.HideSearchPage();
    Connect.ProcessAnalyticsEvent('toolbar_button_search_cancel_click');
  }
};

Connect.Button_Globe = function () {
  var button_span, page_document;

  // Menu visible in mobile?
  //
  if (Connect.Menu.Enabled && Connect.Menu.Visible() && !Connect.layout_wide) {
    // Hide
    //
    Connect.Menu.Hide();
  }

  // Enabled?
  //
  button_span = Connect.buttons['ww_behavior_globe'];
  if (!Connect.globe_enabled) {
    // Highlight toolbar button
    //
    if (button_span !== undefined) {
      button_span.className = Browser.ReplaceClass(button_span.className, 'ww_skin_toolbar_background_default', 'ww_skin_toolbar_background_selected');
    }

    // Globalize
    //
    Connect.globe_enabled = true;
    Connect_Window.setTimeout(Connect.Globalize);
  } else {
    // Disable globalization
    //
    Connect.globe_enabled = false;
    page_document = Browser.GetDocument(Connect.page_iframe);
    if (page_document !== undefined) {
      Connect_Window.setTimeout(function () {
        page_document.location.reload();
      });
    }

    // Highlight toolbar button
    //
    if (button_span !== undefined) {
      button_span.className = Browser.ReplaceClass(button_span.className, 'ww_skin_toolbar_background_selected', 'ww_skin_toolbar_background_default');
    }
  }
  Connect.ProcessAnalyticsEvent('toolbar_button_translate_click');
};

Connect.Button_Menu_Toggle = function () {
  var menu_opened, menu_closed, menu_initial, layout_narrow;

  menu_opened = Browser.ContainsClass(Connect.presentation_div.className, 'menu_open');
  menu_closed = Browser.ContainsClass(Connect.presentation_div.className, 'menu_closed');
  menu_initial = Browser.ContainsClass(Connect.presentation_div.className, 'menu_initial');
  layout_narrow = Browser.ContainsClass(Connect.layout_div.className, 'layout_narrow');

  menu_opened = menu_opened && !(menu_initial && layout_narrow);

  if (menu_opened) {
    Connect.Menu.Hide();
  }
  else if (menu_closed) {
    Connect.Menu.Show();
  }
  else {
    Connect.Menu.Show();
  }
  Connect.ProcessAnalyticsEvent('toolbar_button_menu_click');
};

Connect.Button_Previous = function () {
  if (!Connect.ButtonDisabled(Connect.buttons['ww_behavior_prev'])) {
    // Menu visible in mobile?
    //
    if (Connect.Menu.Enabled && Connect.Menu.Visible() && !Connect.layout_wide) {
      // Hide
      //
      Connect.Menu.Hide();
    }

    Navigation.GotoPrevNext('Prev');

    Connect.ProcessAnalyticsEvent('toolbar_button_prev_click');
  }
};

Connect.Button_Next = function () {
  if (!Connect.ButtonDisabled(Connect.buttons['ww_behavior_next'])) {
    // Menu visible in mobile?
    //
    if (Connect.Menu.Enabled && Connect.Menu.Visible() && !Connect.layout_wide) {
      // Hide
      //
      Connect.Menu.Hide();
    }

    Navigation.GotoPrevNext('Next');

    Connect.ProcessAnalyticsEvent('toolbar_button_next_click');
  }
};

Connect.Button_Email = function () {
  var message, mailto;

  // Menu visible in mobile?
  //
  if (Connect.Menu.Enabled && Connect.Menu.Visible() && !Connect.layout_wide) {
    // Hide
    //
    Connect.Menu.Hide();
  }

  if ((Connect.email.length > 0) && (Connect.email_message.length > 0)) {
    message = Connect.email_message.replace('$Location;', Connect_Window.location.href);
    if (Connect_Window.navigator.userAgent.indexOf('MSIE') !== -1) {
      message = message.replace('#', '%23');
    }
    mailto =
      'mailto:' +
      Connect.email +
      '?subject=' +
      Browser.EncodeURIComponentIfNotEncoded(message) +
      '&body=' +
      Browser.EncodeURIComponentIfNotEncoded(message);

    Connect_Window.open(mailto, '_blank');
  }
};

Connect.Button_Print = function () {
  var page_window, data;

  // Report click event
  //
  Connect.ProcessAnalyticsEvent('page_button_print_click');

  // Try direct method
  //
  try {
    page_window = Connect.page_iframe.contentWindow || Connect_Window.frames['connect_page'];
    if ((page_window !== undefined) && (page_window !== null)) {
      page_window.print();
    }
  } catch (ignore) {
    // Try page action
    //
    data = {
      'action': 'ww_behavior_print'
    };
    Message.Post(Connect.page_iframe.contentWindow, data, Connect_Window);
  }
};

Connect.Button_PDF = function () {
  var data;

  // Try page action
  //
  data = {
    'action': 'ww_behavior_pdf'
  };
  Message.Post(Connect.page_iframe.contentWindow, data, Connect_Window);
};

Connect.ScrollTo = function (x, y) {
  Connect.container_div.scrollLeft = x;
  Connect.container_div.scrollTop = y;
};

Connect.SearchEnabled = function () {
  var search_enabled;

  search_enabled = Browser.ContainsClass(presentation_div.className, 'search_enabled');

  return search_enabled;
};

Connect.ShowSearchPage = function () {
  Connect.presentation_div.className = Browser.AddClass(Connect.presentation_div.className, 'search_enabled');

  Connect.EnableDisableButton('ww_behavior_prev', 'ww_skin_prev', false);
  Connect.EnableDisableButton('ww_behavior_next', 'ww_skin_next', false);
  Connect.EnableDisableButton('ww_behavior_home', 'ww_skin_home', true);

  Connect.Menu.CalculateMenuSize();
};

Connect.HideSearchPage = function () {
  Connect.presentation_div.className = Browser.RemoveClass(Connect.presentation_div.className, 'search_enabled');

  Navigation.UpdatePrevNext();
  Connect.Menu.CalculateMenuSize();
};

Connect.HandleSearch = function () {
  if (Connect.search_query !== undefined) {
    var data, search_query, search_enabled;

    search_query = Connect.search_query;
    search_enabled = Connect.SearchEnabled();

    if (search_query.length > 0 && !search_enabled) {
      // Show the page if not visible.
      Connect.ShowSearchPage();
    }

    Connect.search_query = search_query;

    data = {
      'action': 'search_connect_info',
      'target': Connect_Window.name,
      'base_url': Navigation.base_url,
      'parcel_prefixes': Parcels.prefixes,
      'parcel_sx': Parcels.search,
      'query': Connect.search_query
    };

    if (Connect.scope_enabled) {
      var search_scope_selection_titles_string;

      search_scope_selection_titles_string = Scope.GetSearchScopeSelectionTitlesString();

      data['search_scopes'] = Scope.search_scopes;
      data['search_scope_map'] = Scope.search_scope_map;
      data['search_scope_selections'] = Scope.search_scope_selections;
      data['search_scope_selection_titles'] = search_scope_selection_titles_string;
    }

    Message.Post(Connect.search_iframe.contentWindow, data, Connect_Window);
  }

  Connect.UpdateTitle();
};

Connect.ButtonDisabled = function (param_button) {
  var is_disabled;

  // Be permissive with this one because we only want to stop certain behavior
  //
  is_disabled = false;

  if (param_button && typeof param_button === 'object') {
    is_disabled = Browser.ContainsClass(param_button.className, 'ww_skin_toolbar_button_disabled');
  }

  return is_disabled;
};

Connect.DisplayUnsupportedBrowserView = function () {
  var body, unsupported_browser_element;

  body = document.body;
  unsupported_browser_element = document.getElementById('unsupported_browser').outerHTML;

  body.innerHTML = unsupported_browser_element;
};

Connect.ShowPageLoading = function () {
  if (Connect.page_loading_div) {
    Connect.page_loading_div.style.display = 'flex';
  }
};

Connect.HidePageLoading = function () {
  if (Connect.page_loading_div) {
    Connect.page_loading_div.style.display = 'none';
  }
};

window.onclick = function (param_event) {
  if (Connect.scope_enabled) {
    var is_child_of_options, is_child_of_selector;

    is_child_of_selector = Browser.IsChildOfNode(param_event.target, document.getElementById('search_scope'));
    is_child_of_options = Browser.IsChildOfNode(param_event.target, document.getElementById('search_scope_options'));

    if (!is_child_of_selector && !is_child_of_options) {
      Scope.CloseDropDown();
    }
  }
};

// Start running as soon as possible
//
if (window.addEventListener !== undefined) {
  window.document.addEventListener('DOMContentLoaded', Connect.OnLoad, false);
}
