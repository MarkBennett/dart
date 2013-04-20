// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/expect.dart";
import 'compiler_helper.dart';

const String TEST_ONE = r"""
foo(int a, int b, bool param2) {
  for (int i = 0; i < 1; i++) {
    var x = a + 5;  // '+' is now GVNed.
    if (param2) {
      print(a + b);
    } else {
      print(a + b);
    }
  }
}
""";

main() {
  String generated = compile(TEST_ONE, entry: 'foo');
  RegExp regexp = new RegExp('a \\+ b');
  Iterator matches = regexp.allMatches(generated).iterator;
  Expect.isTrue(matches.moveNext());
  Expect.isFalse(matches.moveNext());
}
