// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library client_shared;

import 'dart:html';
import 'dropdown.dart';
import '../../classify.dart';
import '../dartdoc/nav.dart';


// Code shared between the different client-side libraries.

// The names of the library and type that this page documents.
String currentLibrary = null;
String currentType = null;

// What we need to prefix relative URLs with to get them to work.
String prefix = '';

void setup() {
  setupLocation();
  setupShortcuts();
  enableCodeBlocks();
  enableShowHideInherited();
}

void setupLocation() {
  // Figure out where we are.
  final body = document.query('body');
  currentLibrary = body.dataset['library'];
  currentType = body.dataset['type'];
  prefix = (currentType != null) ? '../' : '';
}

/**
 * Finds all code blocks and makes them toggleable. Syntax highlights each
 * code block the first time it's shown.
 */
enableCodeBlocks() {
  for (var elem in document.queryAll('.method, .field')) {
    var showCode = elem.query('.show-code');

    // Skip it if we don't have a code link. Will happen if source code is
    // disabled.
    if (showCode == null) continue;

    var preList = elem.queryAll('pre.source');

    showCode.onClick.listen((e) {
      for (final pre in preList) {
        if (pre.classes.contains('expanded')) {
          pre.classes.remove('expanded');
        } else {
          // Syntax highlight.
          if (!pre.classes.contains('formatted')) {
            pre.innerHtml = classifySource(pre.text);
            pre.classes.add('formatted');
          };
          pre.classes.add('expanded');
        }
      }
    });
  }
}

/**
 * Enables show/hide functionality for inherited members and comments.
 */
void enableShowHideInherited() {
  var showInherited = document.query('#show-inherited');
  if (showInherited == null) return;
  showInherited.dataset.putIfAbsent('show-inherited', () => 'block');
  showInherited.onClick.listen((e) {
    String display = showInherited.dataset['show-inherited'];
    if (display == 'block') {
      display = 'none';
      showInherited.innerHtml = 'Show inherited';
    } else {
      display = 'block';
      showInherited.innerHtml = 'Hide inherited';
    }
    showInherited.dataset['show-inherited'] = display;
    for (var elem in document.queryAll('.inherited')) {
      elem.style.display = display;
    }
  });

}

/** Turns [name] into something that's safe to use as a file name. */
String sanitize(String name) => name.replaceAll(':', '_').replaceAll('/', '_');

String getTypeName(Map typeInfo) =>
    typeInfo.containsKey('args')
        ? '${typeInfo[NAME]}&lt;${typeInfo[NAME]}&gt;'
        : typeInfo[NAME];

String getLibraryUrl(String libraryName) =>
    '$prefix${sanitize(libraryName)}.html';

String getTypeUrl(String libraryName, Map typeInfo) =>
    '$prefix${sanitize(libraryName)}/${sanitize(typeInfo[NAME])}.html';

String getLibraryMemberUrl(String libraryName, Map memberInfo) =>
    '$prefix${sanitize(libraryName)}.html#${getMemberAnchor(memberInfo)}';

String getTypeMemberUrl(String libraryName, String typeName, Map memberInfo) =>
    '$prefix${sanitize(libraryName)}/${sanitize(typeName)}.html#'
    '${getMemberAnchor(memberInfo)}';

String getMemberAnchor(Map memberInfo) => memberInfo.containsKey(LINK_NAME)
    ? memberInfo[LINK_NAME] : memberInfo[NAME];
