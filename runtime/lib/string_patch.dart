// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

patch class String {
  /* patch */ factory String.fromCharCodes(Iterable<int> charCodes) {
    return _StringBase.createFromCharCodes(charCodes);
  }
}


/**
 * [_StringBase] contains common methods used by concrete String
 * implementations, e.g., _OneByteString.
 */
class _StringBase {

  factory _StringBase._uninstantiable() {
    throw new UnsupportedError(
        "_StringBase can't be instaniated");
  }

  int get hashCode native "String_getHashCode";

  /**
   *  Create the most efficient string representation for specified
   *  [codePoints].
   */
  static String createFromCharCodes(Iterable<int> charCodes) {
    // TODO(srdjan): Also skip copying of typed arrays.
    if (charCodes is! _ObjectArray &&
        charCodes is! _GrowableObjectArray &&
        charCodes is! _ImmutableArray) {
      charCodes = new List<int>.from(charCodes, growable: false);
    }

    return _createFromCodePoints(charCodes);
  }

  static String _createFromCodePoints(List<int> codePoints)
      native "StringBase_createFromCodePoints";

  String operator [](int index) native "String_charAt";

  int codeUnitAt(int index) native "String_codeUnitAt";

  int get length native "String_getLength";

  bool get isEmpty {
    return this.length == 0;
  }

  String operator +(String other) native "String_concat";

  String concat(String other) => this + other;

  String toString() {
    return this;
  }

  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if ((other is !String) ||
        (this.length != other.length)) {
      // TODO(5413632): Compare hash codes when both are present.
      return false;
    }
    return this.compareTo(other) == 0;
  }

  int compareTo(String other) {
    int thisLength = this.length;
    int otherLength = other.length;
    int len = (thisLength < otherLength) ? thisLength : otherLength;
    for (int i = 0; i < len; i++) {
      int thisCodePoint = this.codeUnitAt(i);
      int otherCodePoint = other.codeUnitAt(i);
      if (thisCodePoint < otherCodePoint) {
        return -1;
      }
      if (thisCodePoint > otherCodePoint) {
        return 1;
      }
    }
    if (thisLength < otherLength) return -1;
    if (thisLength > otherLength) return 1;
    return 0;
  }

  bool _substringMatches(int start, String other) {
    if (other.isEmpty) return true;
    if ((start < 0) || (start >= this.length)) {
      return false;
    }
    final int len = other.length;
    if ((start + len) > this.length) {
      return false;
    }
    for (int i = 0; i < len; i++) {
      if (this.codeUnitAt(i + start) != other.codeUnitAt(i)) {
        return false;
      }
    }
    return true;
  }

  bool endsWith(String other) {
    return _substringMatches(this.length - other.length, other);
  }

  bool startsWith(String other) {
    return _substringMatches(0, other);
  }

  int indexOf(String other, [int start = 0]) {
    if (other.isEmpty) {
      return start < this.length ? start : this.length;
    }
    if ((start < 0) || (start >= this.length)) {
      return -1;
    }
    int len = this.length - other.length + 1;
    for (int index = start; index < len; index++) {
      if (_substringMatches(index, other)) {
        return index;
      }
    }
    return -1;
  }

  int lastIndexOf(String other, [int start = null]) {
    if (start == null) start = length - 1;
    if (other.isEmpty) {
      return min(this.length, start);
    }
    if (start >= this.length) {
      start = this.length - 1;
    }
    for (int index = start; index >= 0; index--) {
      if (_substringMatches(index, other)) {
        return index;
      }
    }
    return -1;
  }

  String substring(int startIndex, [int endIndex]) {
    if (endIndex == null) endIndex = this.length;

    if ((startIndex < 0) || (startIndex > this.length)) {
      throw new RangeError.value(startIndex);
    }
    if ((endIndex < 0) || (endIndex > this.length)) {
      throw new RangeError.value(endIndex);
    }
    if (startIndex > endIndex) {
      throw new RangeError.value(startIndex);
    }
    return _substringUnchecked(startIndex, endIndex);
  }

  String _substringUnchecked(int startIndex, int endIndex) {
    assert(endIndex != null);
    assert((startIndex >= 0) && (startIndex <= this.length));
    assert((endIndex >= 0) && (endIndex <= this.length));
    assert(startIndex <= endIndex);

    if (startIndex == endIndex) {
      return "";
    }
    if ((startIndex + 1) == endIndex) {
      return this[startIndex];
    }
    return _substringUncheckedNative(startIndex, endIndex);
  }

  String _substringUncheckedNative(int startIndex, int endIndex)
      native "StringBase_substringUnchecked";

  String trim() {
    final int len = this.length;
    int first = 0;
    for (; first < len; first++) {
      if (!_isWhitespace(this.codeUnitAt(first))) {
        break;
      }
    }
    if (len == first) {
      // String contains only whitespaces.
      return "";
    }
    int last = len - 1;
    for (; last >= first; last--) {
      if (!_isWhitespace(this.codeUnitAt(last))) {
        break;
      }
    }
    if ((first == 0) && (last == (len - 1))) {
      // Returns this string if it does not have leading or trailing
      // whitespaces.
      return this;
    } else {
      return _substringUnchecked(first, last + 1);
    }
  }

  bool contains(Pattern pattern, [int startIndex = 0]) {
    if (pattern is String) {
      return indexOf(pattern, startIndex) >= 0;
    }
    return pattern.allMatches(this.substring(startIndex)).iterator.moveNext();
  }

  String replaceFirst(Pattern pattern, String replacement) {
    if (pattern is! Pattern) {
      throw new ArgumentError("${pattern} is not a Pattern");
    }
    if (replacement is! String) {
      throw new ArgumentError("${replacement} is not a String");
    }
    StringBuffer buffer = new StringBuffer();
    int startIndex = 0;
    Iterator iterator = pattern.allMatches(this).iterator;
    if (iterator.moveNext()) {
      Match match = iterator.current;
      buffer..write(this.substring(startIndex, match.start))
            ..write(replacement);
      startIndex = match.end;
    }
    return (buffer..write(this.substring(startIndex))).toString();
  }

  String replaceAll(Pattern pattern, String replacement) {
    if (pattern is! Pattern) {
      throw new ArgumentError("${pattern} is not a Pattern");
    }
    if (replacement is! String) {
      throw new ArgumentError(
          "${replacement} is not a String or Match->String function");
    }
    StringBuffer buffer = new StringBuffer();
    int startIndex = 0;
    for (Match match in pattern.allMatches(this)) {
      buffer..write(this.substring(startIndex, match.start))
            ..write(replacement);
      startIndex = match.end;
    }
    return (buffer..write(this.substring(startIndex))).toString();
  }

  String replaceAllMapped(Pattern pattern, String replace(Match match)) {
    return splitMapJoin(pattern, onMatch: replace);
  }

  static String _matchString(Match match) => match[0];
  static String _stringIdentity(String string) => string;

  String _splitMapJoinEmptyString(String onMatch(Match match),
                                  String onNonMatch(String nonMatch)) {
    // Pattern is the empty string.
    StringBuffer buffer = new StringBuffer();
    int length = this.length;
    int i = 0;
    buffer.write(onNonMatch(""));
    while (i < length) {
      buffer.write(onMatch(new _StringMatch(i, this, "")));
      // Special case to avoid splitting a surrogate pair.
      int code = this.codeUnitAt(i);
      if ((code & ~0x3FF) == 0xD800 && length > i + 1) {
        // Leading surrogate;
        code = this.codeUnitAt(i + 1);
        if ((code & ~0x3FF) == 0xDC00) {
          // Matching trailing surrogate.
          buffer.write(onNonMatch(this.substring(i, i + 2)));
          i += 2;
          continue;
        }
      }
      buffer.write(onNonMatch(this[i]));
      i++;
    }
    buffer.write(onMatch(new _StringMatch(i, this, "")));
    buffer.write(onNonMatch(""));
    return buffer.toString();
  }

  String splitMapJoin(Pattern pattern,
                      {String onMatch(Match match),
                       String onNonMatch(String nonMatch)}) {
    if (pattern is! Pattern) {
      throw new ArgumentError("${pattern} is not a Pattern");
    }
    if (onMatch == null) onMatch = _matchString;
    if (onNonMatch == null) onNonMatch = _stringIdentity;
    if (pattern is String) {
      String stringPattern = pattern;
      if (stringPattern.isEmpty) {
        return _splitMapJoinEmptyString(onMatch, onNonMatch);
      }
    }
    StringBuffer buffer = new StringBuffer();
    int startIndex = 0;
    for (Match match in pattern.allMatches(this)) {
      buffer.write(onNonMatch(this.substring(startIndex, match.start)));
      buffer.write(onMatch(match).toString());
      startIndex = match.end;
    }
    buffer.write(onNonMatch(this.substring(startIndex)));
    return buffer.toString();
  }


  /**
   * Convert all objects in [values] to strings and concat them
   * into a result string.
   */
  static String _interpolate(List values) {
    int numValues = values.length;
    _ObjectArray stringList = new List(numValues);
    for (int i = 0; i < numValues; i++) {
      stringList[i] = values[i].toString();
    }
    return _concatAll(stringList);
  }

  Iterable<Match> allMatches(String str) {
    List<Match> result = new List<Match>();
    int length = str.length;
    int patternLength = this.length;
    int startIndex = 0;
    while (true) {
      int position = str.indexOf(this, startIndex);
      if (position == -1) {
        break;
      }
      result.add(new _StringMatch(position, str, this));
      int endIndex = position + patternLength;
      if (endIndex == length) {
        break;
      } else if (position == endIndex) {
        ++startIndex;  // empty match, advance and restart
      } else {
        startIndex = endIndex;
      }
    }
    return result;
  }

  List<String> split(Pattern pattern) {
    if ((pattern is String) && pattern.isEmpty) {
      List<String> result = new List<String>(length);
      for (int i = 0; i < length; i++) {
        result[i] = this[i];
      }
      return result;
    }
    int length = this.length;
    Iterator iterator = pattern.allMatches(this).iterator;
    if (length == 0 && iterator.moveNext()) {
      // A matched empty string input returns the empty list.
      return <String>[];
    }
    List<String> result = new List<String>();
    int startIndex = 0;
    int previousIndex = 0;
    while (true) {
      if (startIndex == length || !iterator.moveNext()) {
        result.add(this._substringUnchecked(previousIndex, length));
        break;
      }
      Match match = iterator.current;
      if (match.start == length) {
        result.add(this._substringUnchecked(previousIndex, length));
        break;
      }
      int endIndex = match.end;
      if (startIndex == endIndex && endIndex == previousIndex) {
        ++startIndex;  // empty match, advance and restart
        continue;
      }
      result.add(this._substringUnchecked(previousIndex, match.start));
      startIndex = previousIndex = endIndex;
    }
    return result;
  }

  List<int> get codeUnits => new _CodeUnits(this);

  Runes get runes => new Runes(this);

  String toUpperCase() native "String_toUpperCase";

  String toLowerCase() native "String_toLowerCase";

  // Implementations of Strings methods follow below.
  static String join(Iterable<String> strings, String separator) {
    bool first = true;
    List<String> stringsList = <String>[];
    for (String string in strings) {
      if (first) {
        first = false;
      } else {
        stringsList.add(separator);
      }

      if (string is! String) {
        throw new ArgumentError(Error.safeToString(string));
      }
      stringsList.add(string);
    }
    return concatAll(stringsList);
  }

  static String concatAll(Iterable<String> strings) {
    _ObjectArray stringsArray;
    if (strings is _ObjectArray) {
      stringsArray = strings;
      for (int i = 0; i < strings.length; i++) {
        if (strings[i] is! String) throw new ArgumentError(strings[i]);
      }
    } else {
      int len = strings.length;
      stringsArray = new _ObjectArray(len);
      int i = 0;
      for (String string in strings) {
        if (string is! String) throw new ArgumentError(string);
        stringsArray[i++] = string;
      }
    }
    return _concatAll(stringsArray);
  }

  static String _concatAll(_ObjectArray<String> strings)
      native "Strings_concatAll";
}


class _OneByteString extends _StringBase implements String {
  factory _OneByteString._uninstantiable() {
    throw new UnsupportedError(
        "_OneByteString can only be allocated by the VM");
  }

  int get hashCode native "String_getHashCode";

  // Checks for one-byte whitespaces only.
  // TODO(srdjan): Investigate if 0x85 (NEL) and 0xA0 (NBSP) are valid
  // whitespaces for one byte strings.
  bool _isWhitespace(int codePoint) {
    return
      (codePoint == 32) || // Space.
      ((9 <= codePoint) && (codePoint <= 13)); // CR, LF, TAB, etc.
  }

  String _substringUncheckedNative(int startIndex, int endIndex)
      native "OneByteString_substringUnchecked";

  List<String> _splitWithCharCode(int charCode)
      native "OneByteString_splitWithCharCode";

  List<String> split(Pattern pattern) {
    if ((pattern is _OneByteString) && (pattern.length == 1)) {
      return _splitWithCharCode(pattern.codeUnitAt(0));
    }
    return super.split(pattern);
  }
}


class _TwoByteString extends _StringBase implements String {
  factory _TwoByteString._uninstantiable() {
    throw new UnsupportedError(
        "_TwoByteString can only be allocated by the VM");
  }

  // Checks for one-byte whitespaces only.
  // TODO(srdjan): Investigate if 0x85 (NEL) and 0xA0 (NBSP) are valid
  // whitespaces. Add checking for multi-byte whitespace codepoints.
  bool _isWhitespace(int codePoint) {
    return
      (codePoint == 32) || // Space.
      ((9 <= codePoint) && (codePoint <= 13)); // CR, LF, TAB, etc.
  }
}


class _FourByteString extends _StringBase implements String {
  factory _FourByteString._uninstantiable() {
    throw new UnsupportedError(
        "_FourByteString can only be allocated by the VM");
  }

  // Checks for one-byte whitespaces only.
  // TODO(srdjan): Investigate if 0x85 (NEL) and 0xA0 (NBSP) are valid
  // whitespaces. Add checking for multi-byte whitespace codepoints.
  bool _isWhitespace(int codePoint) {
    return
      (codePoint == 32) || // Space.
      ((9 <= codePoint) && (codePoint <= 13)); // CR, LF, TAB, etc.
  }
}


class _ExternalOneByteString extends _StringBase implements String {
  factory _ExternalOneByteString._uninstantiable() {
    throw new UnsupportedError(
        "_ExternalOneByteString can only be allocated by the VM");
  }

  // Checks for one-byte whitespaces only.
  // TODO(srdjan): Investigate if 0x85 (NEL) and 0xA0 (NBSP) are valid
  // whitespaces for one byte strings.
  bool _isWhitespace(int codePoint) {
    return
      (codePoint == 32) || // Space.
      ((9 <= codePoint) && (codePoint <= 13)); // CR, LF, TAB, etc.
  }
}


class _ExternalTwoByteString extends _StringBase implements String {
  factory _ExternalTwoByteString._uninstantiable() {
    throw new UnsupportedError(
        "_ExternalTwoByteString can only be allocated by the VM");
  }

  // Checks for one-byte whitespaces only.
  // TODO(srdjan): Investigate if 0x85 (NEL) and 0xA0 (NBSP) are valid
  // whitespaces. Add checking for multi-byte whitespace codepoints.
  bool _isWhitespace(int codePoint) {
    return
      (codePoint == 32) || // Space.
      ((9 <= codePoint) && (codePoint <= 13)); // CR, LF, TAB, etc.
  }
}


class _ExternalFourByteString extends _StringBase implements String {
  factory _ExternalFourByteString._uninstantiable() {
    throw new UnsupportedError(
        "ExternalFourByteString can only be allocated by the VM");
  }

  // Checks for one-byte whitespaces only.
  // TODO(srdjan): Investigate if 0x85 (NEL) and 0xA0 (NBSP) are valid
  // whitespaces. Add checking for multi-byte whitespace codepoints.
  bool _isWhitespace(int codePoint) {
    return
      (codePoint == 32) || // Space.
      ((9 <= codePoint) && (codePoint <= 13)); // CR, LF, TAB, etc.
  }
}


class _StringMatch implements Match {
  const _StringMatch(int this.start,
                     String this.str,
                     String this.pattern);

  int get end => start + pattern.length;
  String operator[](int g) => group(g);
  int get groupCount => 0;

  String group(int group) {
    if (group != 0) {
      throw new RangeError.value(group);
    }
    return pattern;
  }

  List<String> groups(List<int> groups) {
    List<String> result = new List<String>();
    for (int g in groups) {
      result.add(group(g));
    }
    return result;
  }

  final int start;
  final String str;
  final String pattern;
}

/**
 * An [Iterable] of the UTF-16 code units of a [String] in index order.
 */
class _CodeUnits extends Object with ListMixin<int>,
                                     UnmodifiableListMixin<int> {
  /** The string that this is the code units of. */
  String _string;

  _CodeUnits(this._string);

  int get length => _string.length;
  int operator[](int i) => _string.codeUnitAt(i);
}
