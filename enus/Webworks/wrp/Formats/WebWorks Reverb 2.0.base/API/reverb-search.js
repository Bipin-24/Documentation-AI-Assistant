// Copyright (c) 2010-2016 Quadralay Corporation.  All rights reserved.
//
// ePublisher 2016.1
//
// Validated with JSLint <http://www.jslint.com/>
//

function GetKeysFromSet(param_set) {
    if(typeof param_set.keys != "undefined")
        return Array.from(param_set.keys());
    else{
        var result = new Array();
        param_set.forEach(function (value1, value2, set) {
            result.push(value1);
        });
        return result;
    }
}

window.onload = function() {
    var storage;
    var search_localstorage = window.localStorage['wwreverbsearch'];
    if (search_localstorage == undefined) {
      storage = GetUrlValues();
    }
    else {
      storage = JSON.parse(search_localstorage);
      delete window.localStorage['wwreverbsearch'];
    }
    
    if (storage !== undefined && storage !== "") {
        if (storage.wwr_a == 'search_display_link') {
            Search.SearchQueryHighlight(storage.wwr_q, storage.wwr_rws, storage.wwr_s, storage.wwr_mwl, storage.wwr_sw);
        }
    }
};

function GetUrlValues(){
    var GET = {};
    var SearchString = window.location.search.substring(1);
    var VariableArray = SearchString.split('&');
    for(var i = 0; i < VariableArray.length; i++){
        if (VariableArray[i] === "") // check for trailing & with no param
            continue;
        var KeyValuePair = VariableArray[i].split('=');

        GET[decodeURIComponent(KeyValuePair[0])] = decodeURIComponent(KeyValuePair[1] || "");
    }
    return GET;
}

// Search
//
var Search = {
    'window': window,
    'control': undefined,
    'loading': false,
    'query': '',
    'perform_with_delay_timeout': null,
    'connect_info': null
};

Search.SearchQueryHighlight = function (param_search_query, param_require_whitespace, param_search_synonyms, param_search_minimum_word_length, param_search_stop_words) {
    'use strict';

    var expressions, html_elements;

    // Remove highlights
    //
    Highlight.RemoveFromDocument(Search.window.document, 'search-result-highlight');

    // Highlight words
    //
    if (param_search_query !== undefined) {
        // Convert search query into expressions
        //
        expressions = SearchClient.SearchQueryToExpressions(param_search_query, param_search_synonyms, param_search_minimum_word_length, param_search_stop_words);

        // Apply highlights
        //
        Highlight.ApplyToDocument(Search.window.document, 'search-result-highlight', expressions, param_require_whitespace == true);
    }
};


// Highlights
//
var Highlight = {};

Highlight.ApplyToDocument = function (param_document, param_css_class, param_expressions, param_require_whitespace, param_handle_highlight) {
    'use strict';

    Browser.ApplyToTree(param_document.body, Highlight.TreeRecusionFilter,
        Highlight.TreeProcessTextNodesFilter,
        function (param_node) {
            var applied;

            applied = Highlight.Apply(param_document, param_css_class, param_expressions, param_require_whitespace, param_node);
            if ((applied) && (param_handle_highlight !== undefined)) {
                param_handle_highlight(param_node.parentNode);
            }
        });
};

Highlight.TreeProcessTextNodesFilter = function (param_node) {
    'use strict';

    var result = false;

    // Keep text nodes
    //
    if (param_node.nodeType === 3) {
        result = true;
    }

    return result;
};

Highlight.RemoveFromDocument = function (param_document, param_css_class) {
    'use strict';

    // Remove highlights
    //
    Browser.ApplyToTree(param_document.body, Highlight.TreeRecusionFilter,
        function (param_node) {
            var result;

            result = Highlight.TreeProcessHighlightSpansFilter(param_css_class, param_node);

            return result;
        },
        function (param_node) {
            Highlight.Remove(param_document, param_node);
        });
};

Highlight.TreeRecusionFilter = function (param_node) {
    'use strict';

    var result = false;

    // Recurse on content elements
    //
    if ((param_node.nodeType === 1) && (param_node.nodeName.toLowerCase() !== 'header') && (param_node.nodeName.toLowerCase() !== 'footer')) {
        result = true;
    }

    return result;
};

Highlight.TreeProcessHighlightSpansFilter = function (param_css_class, param_node) {
    'use strict';

    var result = false;

    // Find highlight spans
    //
    if ((param_node.nodeType === 1) && (param_node.nodeName.toLowerCase() === 'span') && (param_node.className === param_css_class)) {
        result = true;
    }

    return result;
};

Highlight.Apply = function (param_document, param_css_class, param_expressions, param_require_whitespace, param_node) {
    'use strict';

    var locations, result, location, highlight_node, span_element;

    locations = Highlight.MatchExpressions(param_expressions, param_require_whitespace, param_node.nodeValue);
    locations = Highlight.FilterOverlaps(locations);
    result = (locations.length > 0);
    while (locations.length > 0) {
        location = locations.pop();

        if ((location[0] + location[1]) < param_node.nodeValue.length) {
            param_node.splitText(location[0] + location[1]);
        }
        highlight_node = param_node.splitText(location[0]);
        span_element = param_document.createElement('span');
        //span_element.className = param_css_class;
        span_element.style.backgroundColor = "yellow";
        param_node.parentNode.insertBefore(span_element, highlight_node);
        span_element.appendChild(highlight_node);
    }

    return result;
};

Highlight.FilterOverlaps = function (param_locations){
    'use strict';

    var locations_sorted_by_start, locations_sorted_by_end, result, currentInterval, peek, i;
    
    if(param_locations.length <= 1)
        return param_locations;
    
    locations_sorted_by_start = Highlight.sortArrayOfArrayByPos(param_locations, function(a){return a[0];});
    
    result = new Array();
    result.push(locations_sorted_by_start[0]);
    
    for(i=1; i < locations_sorted_by_start.length; i++){
        currentInterval = locations_sorted_by_start[i];
        peek = result[result.length - 1];
        
        //No Overlap - we only consider this part because the elements are sorted
        if(currentInterval[0] > peek[0] + peek[1] - 1){
            result.push(currentInterval);
        }else{
            //Overlap found the start of the currentInterval is inside the peek interval. We have 2 cases here:
            //Case 1- currentInterval is contained in peek (start and end of currentInterval are inside peek interval)
            //Case 2- currentInterval ends beyond peek end
            //The only case we want to take into consideration is case 2
            if(currentInterval[0] + currentInterval[1] - 1 > peek[0] + peek[1] - 1){
                peek[1] = currentInterval[0] + currentInterval[1] - peek[0];
                result[result.length - 1] = peek;
            }  
        }
    }
    return result;
};

Highlight.sortArrayOfArrayByPos = function (param_locations, param_function){
    'use strict';
    
    param_locations.sort(function(a, b){return param_function(a) - param_function(b);});
    
    return param_locations;
};

Highlight.Remove = function (param_document, param_node) {
    'use strict';

    var parent, previous, next, text, text_node;

    // Remove highlights
    //
    parent = param_node.parentNode;
    previous = param_node.previousSibling;
    next = param_node.nextSibling;
    text = '';
    if ((previous !== null) && (previous.nodeType === 3)) {
        text += previous.nodeValue;
        parent.removeChild(previous);
    }
    if ((param_node.childNodes.length > 0) && (param_node.childNodes[0].nodeType === 3)) {
        text += param_node.childNodes[0].nodeValue;
    }
    if ((next !== null) && (next.nodeType === 3)) {
        text += next.nodeValue;
        parent.removeChild(next);
    }
    text_node = param_document.createTextNode(text);
    parent.insertBefore(text_node, param_node);
    parent.removeChild(param_node);
};

Highlight.MatchExpression = function (param_expression, param_require_whitespace, param_string) {
    'use strict';

    var result, working_regexp, working_string, offset, match;

    result = [];

    // Find matches within the string in order
    //
    if (param_require_whitespace) {
        working_regexp = new RegExp('\\s' + param_expression + '\\s', 'i');
        working_string = ' ' + param_string + ' ';
    } else {
        working_regexp = new RegExp(param_expression, 'i');
        working_string = param_string;
    }
    offset = 0;
    match = working_regexp.exec(working_string);
    while (match !== null) {
        // Record location of this match
        //
        result.push([offset + match.index, match[0].length - ((param_require_whitespace) ? 2 : 0)]);

        // Advance
        //
        offset += match.index + match[0].length - ((param_require_whitespace) ? 1 : 0);
        working_regexp.lastIndex = 0;
        if (offset < working_string.length) {
            match = working_regexp.exec(working_string.substring(offset));
        } else {
            match = null;
        }
    }

    return result;
};

Highlight.MatchExpressions = function (param_expressions, param_require_whitespace, param_string) {
    'use strict';

    var result, match_locations, expression, index, alpha_locations, beta_locations, gamma_locations, start_index, alpha_location, beta_location, gamma_location;

    // Find all match locations
    //
    match_locations = [];
    for (index = 0; index < param_expressions.length; index += 1) {
        expression = param_expressions[index];

        match_locations[index] = Highlight.MatchExpression(expression, param_require_whitespace, param_string);
    }

    // Combine match locations
    //
    while (match_locations.length > 1) {
        alpha_locations = match_locations.pop();
        beta_locations = match_locations.pop();

        gamma_locations = [];
        start_index = -1;
        alpha_location = undefined;
        beta_location = undefined;
        while ((alpha_locations.length > 0) || (beta_locations.length > 0) || (alpha_location !== undefined) || (beta_location !== undefined)) {
            // Locate next location pair
            //
            while ((alpha_location === undefined) && (alpha_locations.length > 0)) {
                alpha_location = alpha_locations.shift();
                if (alpha_location[0] < start_index) {
                    alpha_location = undefined;
                }
            }
            while ((beta_location === undefined) && (beta_locations.length > 0)) {
                beta_location = beta_locations.shift();
                if (beta_location[0] < start_index) {
                    beta_location = undefined;
                }
            }

            // Pick a location
            //
            gamma_location = undefined;
            if ((alpha_location !== undefined) && (beta_location !== undefined)) {
                // Check start index
                //
                if (alpha_location[0] < beta_location[0]) {
                    // Use alpha
                    //
                    gamma_location = alpha_location;
                    alpha_location = undefined;
                } else if (alpha_location[0] > beta_location[0]) {
                    // Use beta
                    //
                    gamma_location = beta_location;
                    beta_location = undefined;
                } else {
                    // Check lengths (longer match wins)
                    //
                    if (alpha_location[1] > beta_location[1]) {
                        // Use alpha
                        //
                        gamma_location = alpha_location;
                        alpha_location = undefined;
                    } else if (alpha_location[1] < beta_location[1]) {
                        // Use beta
                        //
                        gamma_location = beta_location;
                        beta_location = undefined;
                    } else {
                        // Same location
                        //
                        gamma_location = alpha_location;
                        alpha_location = undefined;
                        beta_location = undefined;
                    }
                }
            } else {
                // Use the one that exists
                //
                if (alpha_location !== undefined) {
                    // Use alpha
                    //
                    gamma_location = alpha_location;
                    alpha_location = undefined;
                } else {
                    // Use beta
                    //
                    gamma_location = beta_location;
                    beta_location = undefined;
                }
            }

            // Track selected location
            //
            if (gamma_location !== undefined) {
                gamma_locations.push(gamma_location);
                start_index = gamma_location[0] + gamma_location[1];
            }
        }

        match_locations.push(gamma_locations);
    }

    result = match_locations[0];

    return result;
};


// Browser
//
var Browser = {};

Browser.ApplyToTree = function (param_element, param_recursion_filter, param_processing_filter, param_action) {
    'use strict';

    var index, child_node, queue;

    queue = [];
    for (index = 0; index < param_element.childNodes.length; index += 1) {
        child_node = param_element.childNodes[index];

        // Depth first processing
        //
        if (param_recursion_filter(child_node)) {
            // Recurse!
            //
            Browser.ApplyToTree(child_node, param_recursion_filter, param_processing_filter, param_action);
        }

        // Process?
        //
        if (param_processing_filter(child_node)) {
            // Add to queue
            //
            queue.push(child_node);
        }
    }

    // Process queue
    //
    for (index = 0; index < queue.length; index += 1) {
        child_node = queue[index];
        param_action(child_node);
    }
};


// SearchClient
//
var SearchClient = {};

SearchClient.ParseWordsAndPhrases = function (param_input) {
    'use strict';

    var wordSplits, results, stringWithSpace, currentPhrase, currentWord, wordIndex, startQuotes;

    wordSplits = [];
    results = [];
    stringWithSpace = 'x x';
    currentPhrase = '';
    currentWord = '';
    wordIndex = 0;
    startQuotes = false;

    if (param_input.length > 0) {
        wordSplits = param_input.split(stringWithSpace.substring(1, 2));
        for (wordIndex = 0; wordIndex < wordSplits.length; wordIndex += 1) {
            currentWord = wordSplits[wordIndex];
            if (currentWord.length > 0) {
                // Determine if words are in a phrase by detecting start and end quotes.
                // Add complete phrase or isolated word to results list.
                // 'p' indicates a phrase (group of words).
                // 'w' indicates a word
                // 'l' indicates a word that is last in the search query.
                //
                if (startQuotes) {
                    if (currentWord.charAt(0) === '"') {
                        startQuotes = false;

                        results[results.length] = [];
                        results[results.length-1].push(currentPhrase);
                        results[results.length-1].push('p');

                        currentPhrase = '';
                    }
                    else {
                        if (currentPhrase.length > 0) {
                            currentPhrase += ' ' + currentWord;
                        }
                        else {
                            currentPhrase = currentWord;
                        }
                    }
                }
                else {
                    if (currentWord.charAt(0) === '"') {
                        startQuotes = true;
                    }
                    else {
                        results[results.length] = [];
                        results[results.length-1].push(currentWord);
                        if (wordIndex === (wordSplits.length - 1)) {
                            results[results.length-1].push('l');
                        } else {
                            results[results.length-1].push('w');
                        }
                    }
                }
            }
        }
    }

    return results;
};

SearchClient.SearchReplace = function (param_string, param_search_string, param_replace_string) {
    'use strict';

    var  result, index;

    result = param_string;

    if ((param_search_string.length > 0) && (result.length > 0)) {
        index = result.indexOf(param_search_string, 0);
        while (index !== -1) {
            result = result.substring(0, index) + param_replace_string + result.substring(index + param_search_string.length, result.length);
            index += param_replace_string.length;

            index = result.indexOf(param_search_string, index);
        }
    }

    return result;
};

SearchClient.EscapeRegExg = function (param_string) {
    'use strict';

    var result;

    // Initialize result
    //
    result = param_string;

    // Escape special characters
    // \ . ? + - ^ $ | ( ) [ ] { }
    //
    result = SearchClient.SearchReplace(result, '\\', '\\\\');
    result = SearchClient.SearchReplace(result, '.', '\\.');
    result = SearchClient.SearchReplace(result, '?', '\\?');
    result = SearchClient.SearchReplace(result, '+', '\\+');
    result = SearchClient.SearchReplace(result, '-', '\\-');
    result = SearchClient.SearchReplace(result, '^', '\\^');
    result = SearchClient.SearchReplace(result, '$', '\\$');
    result = SearchClient.SearchReplace(result, '|', '\\|');
    result = SearchClient.SearchReplace(result, '(', '\\(');
    result = SearchClient.SearchReplace(result, ')', '\\)');
    result = SearchClient.SearchReplace(result, '[', '\\[');
    result = SearchClient.SearchReplace(result, ']', '\\]');
    result = SearchClient.SearchReplace(result, '{', '\\{');
    result = SearchClient.SearchReplace(result, '}', '\\}');
    result = SearchClient.SearchReplace(result, '*', '\\*');

    // Windows IE 4.0 is brain dead
    //
    result = SearchClient.SearchReplace(result, '/', '[/]');

    return result;
};

SearchClient.WordToRegExpPattern = function (param_word) {
    'use strict';

    var result;

    // Escape special characters
    //
    result = SearchClient.EscapeRegExg(param_word);

    // Add ^ and $ to force whole string match
    //
    result = '^' + result + '$';

    return result;
};

SearchClient.SearchQueryToExpressions = function (param_search_query, param_all_synonyms, param_minimum_word_length, param_stop_words) {
    'use strict';

    var result, prefix_expression, suffix_expression, words_and_phrases, index, expression, words, word;

    result = [];
    if (param_search_query !== undefined) {
        words_and_phrases = SearchClient.ParseSearchWords(param_search_query.toLowerCase(), param_minimum_word_length, param_stop_words);
        words = words_and_phrases['words'];
        words = SearchClient.AddSynonyms(words, param_all_synonyms);
        for (index = 0; index < words.length; index += 1) {
            word = words[index][0];

            // Avoid highlighting everything
            //
            if (word !== '*') {
                expression = SearchClient.EscapeRegExg(word);
                expression = SearchClient.SearchReplace(expression, '.*', '\\S*');
                result.push(expression);
            }
        }
    }

    return result;
};

SearchClient.AddSynonyms = function (param_words_and_phrases, param_all_synonyms) {
    'use strict';

    var resultWords, resultPhrases, index, word_or_phrase, word_as_regex_pattern, word_as_regex, synonym;

    resultWords = new Set();
    resultPhrases = new Set();
    
    for (index = 0; index < param_words_and_phrases.length; index += 1) {
        word_or_phrase = param_words_and_phrases[index][0];
        if(param_words_and_phrases[index][1] == 'p'){
            //Phrase
            SearchClient.phraseGeneration(word_or_phrase.split(" "), 0, param_all_synonyms).map(function(phrase) {return resultPhrases.add([phrase, 'p']);});
        }else{
            //Word
            word_as_regex_pattern = SearchClient.WordToRegExpPattern(word_or_phrase);
            word_as_regex_pattern = word_as_regex_pattern.substring(0, word_as_regex_pattern.length - 1) + '.*$';
            word_as_regex = new window.RegExp(word_as_regex_pattern);
            for(synonym in param_all_synonyms)
                if(word_as_regex.test(synonym))
                    param_all_synonyms[synonym].map(function(word) {return resultWords.add([word, 'w']);});
        }
    }

    return param_words_and_phrases.concat(GetKeysFromSet(resultWords)).concat(GetKeysFromSet(resultPhrases));
};

SearchClient.phraseGeneration = function (param_phrase, param_phrase_index, param_synonyms){
    'use strict';
    
    if(param_phrase_index >= param_phrase.length)
        return [];
    
    var result, synonym, original_word, index, synonyms_array;
    
    result = [];
    
    synonyms_array = param_synonyms[param_phrase[param_phrase_index]];
    if(synonyms_array !== undefined && synonyms_array.length > 0){
        result = result.concat(SearchClient.phraseGeneration(param_phrase, param_phrase_index + 1, param_synonyms));
        for(index = 0; index < synonyms_array.length; index++){
            synonym = synonyms_array[index];
            original_word = param_phrase[param_phrase_index];
            param_phrase[param_phrase_index] = synonym;
            result.push(param_phrase.join(" "));
            result = result.concat(SearchClient.phraseGeneration(param_phrase, param_phrase_index + 1, param_synonyms));
            param_phrase[param_phrase_index] = original_word;
        }
    }
     else
         result = result.concat(SearchClient.phraseGeneration(param_phrase, param_phrase_index + 1, param_synonyms));
    
    return result;
};

SearchClient.ParseSearchWords = function (param_search_words_string, param_minimum_word_length, param_stop_words) {
    'use strict';

  var result_words, preliminary_phrases, wordsAndPhrases, wordsAndPhrasesIndex, wordOrPhrase, words, wordsIndex, word, result_phrases, phraseIndex, preliminary_phrase, result, word_entry, search_words_string, is_word_last_word;

    result_words = [];
    preliminary_phrases = [];

    // Remove last unbalanced quote (incomplete phrase)
    //
    const unbalanced_quote_regex = /^(?:[^"]*"[^"]*")*[^"]*"[^"]*$/;
    var RemoveUnbalancedQuote = function (param_query) {
        if (unbalanced_quote_regex.test(param_query)) {
            var last_quote_index = param_query.lastIndexOf('"');

            result = param_query.slice(0, last_quote_index) + param_query.slice(last_quote_index + 1);
        }
        else {
            result = param_query;
        }

        return result;
    }
    search_words_string = RemoveUnbalancedQuote(param_search_words_string);

    // Add search words to hash
    //
    search_words_string = SearchClient.ApplyWordBreaks(search_words_string);
    wordsAndPhrases = SearchClient.ParseWordsAndPhrases(search_words_string);
    for (wordsAndPhrasesIndex = 0; wordsAndPhrasesIndex < wordsAndPhrases.length; wordsAndPhrasesIndex += 1) {
        is_word_last_word = wordsAndPhrases[wordsAndPhrasesIndex][1] === 'l';
        wordOrPhrase = wordsAndPhrases[wordsAndPhrasesIndex][0];
        words = wordOrPhrase.split(' ');

        // Phrase?
        //
        if (words.length > 1) {
            preliminary_phrases[preliminary_phrases.length] = [];
        }

        // Process words
        //
        for (wordsIndex = 0; wordsIndex < words.length; wordsIndex += 1) {
            word = words[wordsIndex];

            // Skip words below the minimum word length
            //
            if ((word.length > 0) && (word.length >= param_minimum_word_length)) {
                // Skip stop words when not processing the last word (which has implicit wildcard)
                //
                if (param_stop_words[word] === undefined || is_word_last_word) {
                    // Add to search words list
                    //
                    word_entry = [word, wordsAndPhrases[wordsAndPhrasesIndex][1]];
                    result_words.push(word_entry);

                    // Add to phrase words list (if necessary)
                    //
                    if (words.length > 1) {
                        preliminary_phrases[preliminary_phrases.length - 1].push(word);
                    }
                }
            }
        }
    }

    // Ensure all phrases contain multiple words
    //
    result_phrases = [];
    for (phraseIndex = 0; phraseIndex < preliminary_phrases.length; phraseIndex += 1) {
        preliminary_phrase = preliminary_phrases[phraseIndex];

        if (preliminary_phrase.length > 1) {
            result_phrases.push(preliminary_phrase);
        }
    }

    result = { 'words': result_words, 'phrases': result_phrases };

    return result;
};

SearchClient.ApplyWordBreaks = function (param_string) {
    'use strict';

    var result, index, insert_break;

    result = '';

    // Apply Unicode rules for word breaking
    // These rules taken from http://www.unicode.org/unicode/reports/tr29/
    //
    for (index = 0; index < param_string.length; index += 1) {
        // Break?
        //
        insert_break = Unicode.CheckBreakAtIndex(param_string, index);
        if (insert_break) {
            result += ' ' + param_string.charAt(index);
        } else {
            result += param_string.charAt(index);
        }
    }

    return result;
};