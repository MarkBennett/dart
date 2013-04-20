// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

patch class RegExp {
  /* patch */ factory RegExp(String pattern,
                             {bool multiLine: false,
                              bool caseSensitive: true}) {
    return new _JSSyntaxRegExp(pattern,
                               multiLine: multiLine,
                               caseSensitive: caseSensitive);
  }
}

class _JSRegExpMatch implements Match {
  _JSRegExpMatch(this.regexp, this.str, this._match);

  int get start => _start(0);
  int get end => _end(0);

  int _start(int groupIdx) {
    return _match[(groupIdx * MATCH_PAIR)];
  }

  int _end(int groupIdx) {
    return _match[(groupIdx * MATCH_PAIR) + 1];
  }

  String group(int groupIdx) {
    if (groupIdx < 0 || groupIdx > regexp._groupCount) {
      throw new RangeError.value(groupIdx);
    }
    int startIndex = _start(groupIdx);
    int endIndex = _end(groupIdx);
    if (startIndex == -1) {
      assert(endIndex == -1);
      return null;
    }
    return str._substringUnchecked(startIndex, endIndex);
  }

  String operator [](int groupIdx) {
    return this.group(groupIdx);
  }

  List<String> groups(List<int> groupsSpec) {
    var groupsList = new List<String>(groupsSpec.length);
    for (int i = 0; i < groupsSpec.length; i++) {
      groupsList[i] = group(groupsSpec[i]);
    }
    return groupsList;
  }

  int get groupCount => regexp._groupCount;

  String get pattern => regexp.pattern;

  final RegExp regexp;
  final String str;
  final List<int> _match;
  static const int MATCH_PAIR = 2;
}


class _JSSyntaxRegExp implements RegExp {
  factory _JSSyntaxRegExp(
      String pattern,
      {bool multiLine: false,
       bool caseSensitive: true}) native "JSSyntaxRegExp_factory";

  Match firstMatch(String str) {
    List match = _ExecuteMatch(str, 0);
    if (match == null) {
      return null;
    }
    return new _JSRegExpMatch(this, str, match);
  }

  Iterable<Match> allMatches(String str) {
    if (str is! String) throw new ArgumentError(str);
    List<Match> result = new List<Match>();
    int length = str.length;
    int startIndex = 0;
    while (true) {
      List match = _ExecuteMatch(str, startIndex);
      if (match == null) {
        break;
      }
      result.add(new _JSRegExpMatch(this, str, match));
      int endIndex = match[1];
      if (endIndex == length) {
        break;
      } else if (match[0] == endIndex) {
        ++startIndex;  // empty match, advance and restart
      } else {
        startIndex = endIndex;
      }
    }
    return result;
  }

  bool hasMatch(String str) {
    List match = _ExecuteMatch(str, 0);
    return (match == null) ? false : true;
  }

  String stringMatch(String str) {
    List match = _ExecuteMatch(str, 0);
    if (match == null) {
      return null;
    }
    return str._substringUnchecked(match[0], match[1]);
  }

  String get pattern native "JSSyntaxRegExp_getPattern";

  bool get isMultiLine native "JSSyntaxRegExp_getIsMultiLine";

  bool get isCaseSensitive native "JSSyntaxRegExp_getIsCaseSensitive";

  int get _groupCount native "JSSyntaxRegExp_getGroupCount";

  List _ExecuteMatch(String str, int start_index)
      native "JSSyntaxRegExp_ExecuteMatch";
}
