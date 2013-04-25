// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// Dart core library.

// VM implementation of int.

patch class int {

  static bool _isWhitespace(int codePoint) {
    return
      (codePoint == 32) || // Space.
      ((9 <= codePoint) && (codePoint <= 13)); // CR, LF, TAB, etc.
  }

  static int _tryParseSmi(String str) {
    if (str.isEmpty) return null;
    var ix = 0;
    var endIx = str.length - 1;
    // Find first and last non-whitespace.
    while (ix <= endIx) {
      if (!_isWhitespace(str.codeUnitAt(ix))) break;
      ix++;
    }
    if (endIx < ix) {
      return null;  // Empty.
    }
    while (endIx > ix) {
      if (!_isWhitespace(str.codeUnitAt(endIx))) break;
      endIx--;
    }

    var isNegative = false;
    var c = str.codeUnitAt(ix);
    // Check for leading '+' or '-'.
    if ((c == 0x2b) || (c == 0x2d)) {
      ix++;
      isNegative = (c == 0x2d);
      if (ix > endIx) {
        return null;  // Empty.
      }
    }
    if ((endIx - ix) >= 9) {
      return null;  // May not fit into a Smi.
    }
    var result = 0;
    for (int i = ix; i <= endIx; i++) {
      var c = str.codeUnitAt(i) - 0x30;
      if ((c > 9) || (c < 0)) {
        return null;
      }
      result = result * 10 + c;
    }
    return isNegative ? -result : result;
  }

  static int _parse(String str) {
    int res = _tryParseSmi(str);
    if (res == null) {
      res = _native_parse(str);
    }
    return res;
  }

  static int _native_parse(String str) native "Integer_parse";

  static int _throwFormatException(String source) {
    throw new FormatException(source);
  }

  /* patch */ static int parse(String source,
                               { int radix,
                                 int onError(String str) }) {
    if ((radix == null) && (onError == null)) return _parse(source);
    return _slowParse(source, radix, onError);
  }

  static int _slowParse(String source, int radix, int onError(String str)) {
    if (source is! String) throw new ArgumentError(source);
    if (radix == null) {
      assert(onError != null);
      try {
        return _parse(source);
      } on FormatException {
        return onError(source);
      }
    }
    if (radix is! int) throw new ArgumentError("Radix is not an integer");
    if (radix < 2 || radix > 36) {
      throw new RangeError("Radix $radix not in range 2..36");
    }
    if (onError == null) {
      onError = _throwFormatException;
    }
    // Remove leading and trailing white space.
    source = source.trim();
    if (source.isEmpty) return onError(source);

    bool negative = false;
    int result = 0;

    // The value 99 is used to represent a non-digit. It is too large to be
    // a digit value in any of the used bases.
    const NA = 99;
    const List<int> digits = const <int>[
      00, 01, 02, 03, 04, 05, 06, 07, 08, 09, NA, NA, NA, NA, NA, NA,  // 0x30
      NA, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,  // 0x40
      25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, NA, NA, NA, NA, NA,  // 0x50
      NA, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,  // 0x60
      25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, NA, NA, NA, NA, NA,  // 0x70
    ];

    int i = 0;
    int code = source.codeUnitAt(i);
    if (code == 0x2d || code == 0x2b) { // Starts with a plus or minus-sign.
      negative = (code == 0x2d);
      if (source.length == 1) return onError(source);
      i = 1;
      code = source.codeUnitAt(i);
    }
    do {
      if (code < 0x30 || code > 0x7f) return onError(source);
      int digit = digits[code - 0x30];
      if (digit >= radix) return onError(source);
      result = result * radix + digit;
      i++;
      if (i == source.length) break;
      code = source.codeUnitAt(i);
    } while (true);
    return negative ? -result : result;
  }
}
