function OnLoad() {
  'use strict';

  var parameters, parts, anchor, index, part, context, topic, reverb_parameters;

  // Process URL parameters
  //
  parts = [];
  parameters = '';
  if (window.location.href.indexOf('?') !== -1) {
    parts = window.location.href.split('?');
    parameters = parts[1];
    if (parameters.indexOf('#') !== -1) {
      parts = parameters.split('#');
      parameters = parts[0];
      anchor = parts[1];
    }
  } else if (window.location.href.indexOf('#') !== -1) {
    parts = window.location.href.split('#');
    parameters = parts[1];
    if (parts.length > 2) {
      anchor = parts[2];
    }
  }

  // Sanitize parameters
  //
  parameters = parameters.replace(/[\\<>:;"']|%5C|%3C|%3E|%3A|%3B|%22|%27/gi, '');

  // Parse parameters for context and topic
  //
  reverb_parameters = '';
  if (parameters.indexOf('&') !== -1) {
    parts = parameters.split('&');

    for (index = 0; index < parts.length; index += 1) {
      part = parts[index];

      if (part.indexOf('context=') === 0) {
        context = part.substring(8);
      } else if (part.indexOf('topic=') === 0) {
        topic = part.substring(6);
      }
    }

    if (context !== undefined && topic !== undefined) {
      reverb_parameters = '#context/' + context + '/' + topic;
    }
  } else if (parameters.indexOf('tab=search') !== -1) {
    reverb_parameters = '#search/';
  }

  // Redirect
  //
  window.setTimeout(function () {
    if (document.body.getAttribute('data-redirect')) {
      var redirect_url = document.body.getAttribute('data-redirect');

      window.location.replace(redirect_url + reverb_parameters);
    }
  }, 1);
}