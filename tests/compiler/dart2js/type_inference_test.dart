// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/expect.dart";
import 'compiler_helper.dart';

const String TEST_ONE = r"""
sum(a, b) {
  var c = 0;
  for (var d = a; d < b; d += 1) c = c + d;
  return c;
}
""";

const String TEST_TWO = r"""
foo(int a) {
  return -a;
}
""";

const String TEST_TWO_WITH_BAILOUT = r"""
foo(int a) {
  for (int b = 0; b < 1; b++) {
    a = -a;
  }
  return a;
}
""";

const String TEST_THREE = r"""
foo(a) {
  print([]); // Force a list to be instantiated.
  for (int b = 0; b < 10; b++) print(a[b]);
}
""";

const String TEST_FOUR = r"""
foo(a) {
  print([]); // Force a list to be instantiated.
  print(a[0]); // Force a type guard.
  while (true) print(a.length);
}
""";

const String TEST_FIVE = r"""
foo(a) {
  a[0] = 1;
  print(a[1]);
}
""";

const String TEST_FIVE_WITH_BAILOUT = r"""
foo(a) {
  print([]); // Force a list to be instantiated.
  for (int i = 0; i < 1; i++) {
    a[0] = 1;
    print(a[1]);
  }
}
""";

const String TEST_SIX = r"""
foo(a) {
  print([]); // Force a list to be instantiated.
  print(a[0]);
  while (true) {
    a[0] = a[1];
  }
}
""";

main() {
  compileAndMatchFuzzy(TEST_ONE, 'sum', "x \\+= x");
  compileAndMatchFuzzy(TEST_ONE, 'sum', 'typeof x !== "number"');

  var generated = compile(TEST_TWO, entry: 'foo');
  RegExp regexp = new RegExp(getNumberTypeCheck('a'));
  Expect.isTrue(!regexp.hasMatch(generated));

  regexp = new RegExp('-a');
  Expect.isTrue(!regexp.hasMatch(generated));

  generated = compile(TEST_TWO_WITH_BAILOUT, entry: 'foo');
  regexp = new RegExp(getNumberTypeCheck('a'));
  Expect.isTrue(regexp.hasMatch(generated));

  regexp = new RegExp('-a');
  Expect.isTrue(regexp.hasMatch(generated));

  generated = compile(TEST_THREE, entry: 'foo');
  regexp = new RegExp("a[$anyIdentifier]");
  Expect.isTrue(regexp.hasMatch(generated));

  generated = compile(TEST_FOUR, entry: 'foo');
  regexp = new RegExp("a.length");
  Expect.isTrue(regexp.hasMatch(generated));

  generated = compile(TEST_FIVE, entry: 'foo');
  regexp = new RegExp('a.constructor !== Array');
  Expect.isTrue(!regexp.hasMatch(generated));
  Expect.isTrue(generated.contains('index'));
  Expect.isTrue(generated.contains('indexSet'));

  generated = compile(TEST_FIVE_WITH_BAILOUT, entry: 'foo');
  regexp = new RegExp('a.constructor !== Array');
  Expect.isTrue(regexp.hasMatch(generated));
  Expect.isTrue(!generated.contains('index'));
  Expect.isTrue(!generated.contains('indexSet'));

  generated = compile(TEST_SIX, entry: 'foo');
  regexp = new RegExp('a.constructor !== Array');
  Expect.isTrue(regexp.hasMatch(generated));
  Expect.isTrue(!generated.contains('index'));
  Expect.isTrue(!generated.contains('indexSet'));
}
