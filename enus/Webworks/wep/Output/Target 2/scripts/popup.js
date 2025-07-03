// Copyright (c) 2010-2024 Quadralay Corporation.  All rights reserved.
//
// ePublisher 2024.1
//

// Popup
//
var Popup = {
  window: window,
  loading: true,
  height: 0
};

Popup.KnownParcelURL = function (param_url) {
  'use strict';

  var result;

  result = Parcel_KnownParcelURL(Popup.connect_info.parcel_prefixes, param_url);

  return result;
};

Popup.HandleInterceptLink = function (param_link) {
  'use strict';

  var result, data;

  if ((param_link.href !== undefined) && (param_link.href !== null) && (param_link.href !== '')) {
    data = {
      'action': 'display_link',
      'href': param_link.href,
      'target': param_link.target
    };
    Message.Post(Popup.window.parent, data, Popup.window);

    // Prevent default link behavior
    //
    result = false;
  }

  return result;
};

Popup.InterceptLink = function (param_event) {
  'use strict';

  var result;

  // Process event
  //
  result = Popup.HandleInterceptLink(this);

  return result;
};

Popup.UpdateAnchors = function (param_document) {
  'use strict';

  var index, link, subject, message, mailto, decoded_href;

  if (Popup.anchors_updated === undefined) {
    Popup.anchors_updated = true;

    for (index = param_document.links.length - 1; index >= 0; index -= 1) {
      var is_web_link, is_same_hierarchy, is_email_link, is_toggle_link, is_parcel_link,
        is_external_link, is_preserved_link;

      link = param_document.links[index];

      var is_web_link = new RegExp(/^http[s]?:/).test(link.attributes.href.value);
      var is_same_hierarchy = Browser.SameHierarchy(Popup.connect_info.base_url, link.href);
      var is_parcel_link = is_same_hierarchy && Popup.KnownParcelURL(link.href);
      var is_external_link = is_web_link || !is_same_hierarchy;
      var is_preserved_link = !is_web_link && Popup.preserve_unknown_file_links;

      // Assign link click handler and update target attribute
      //
      if (is_parcel_link) {
        link.onclick = Popup.InterceptLink;
      }

      else if (is_external_link || is_preserved_link) {
        if (!link.target) {
          // Replace current window
          //
          link.target = Popup.connect_info.target;
        }
      }

      else {
        Browser.RemoveAttribute(link, 'href', '');
      }
    }
  }
};

Popup.Listen = function (param_event) {
  'use strict';

  if (Popup.dispatch === undefined) {
    Popup.dispatch = {
      'popup_load': function (param_data) {
        Popup.Load();
      },
      'popup_update_anchors': function (param_data) {
        Popup.connect_info = param_data;
        Popup.UpdateAnchors(Popup.window.document);
      }
    };
  }

  try {
    // Dispatch
    //
    Popup.dispatch[param_event.data.action](param_event.data);
  } catch (ignore) {
    // Keep on rolling
    //
  }
};

Popup.Load = function () {
  'use strict';

  var data;

  if (document.getElementById('preserve_unknown_file_links')) {
    Popup.preserve_unknown_file_links = document.getElementById('preserve_unknown_file_links').value === 'true';
  } else {
    Popup.preserve_unknown_file_links = false;
  }

  // Notify parent
  //
  data = {
    'action': 'popup_load_data',
    'dimensions': Browser.GetWindowContentWidthHeight(Popup.window),
    'title': Popup.window.document.title,
    'href': Popup.window.document.location.href
  };
  Message.Post(Popup.window.parent, data, Popup.window);
};

// Google Translate Initialization
//
function googleTranslateElementInit() {
  new google.translate.TranslateElement({
    pageLanguage: '',
    includedLanguages: 'en,es,fr,de,ja,it,ko,pt,pt-PT,ru,sv,zh-CN,zh-TW,da,cs,et,fi,hr,hu,lt,nl,no,pl,tr,ar,bg,el,lv,ro,sk,sl,ga,mt,uk,id,th,vi,ms,km,tl,ca',
    autoDisplay: true
  }, 'google_translate_element');
}

// Setup for listening
//
Message.Listen(Popup.window, function (param_event) {
  Popup.Listen(param_event);
});
