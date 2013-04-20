// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/expect.dart";
import 'compiler_helper.dart';

const String TEST_ONE = r"""
foo(String a) {
  // Make sure the string class is registered.
  var c = 'foo';
  // index into the parameter and move into a loop to make sure we'll get a
  // type guard.
  for (int i = 0; i < 1; i++) {
    print(a[0] + c);
  }
  return a.length;
}
""";

const String TEST_TWO = r"""
foo() {
  return "foo".length;
}
""";

const String TEST_THREE = r"""
foo() {
  return r"foo".length;
}
""";

const String TEST_FOUR = r"""
foo() {
  return new List().add(2);
}
""";

main() {
  String generated = compile(TEST_ONE, entry: 'foo');
  Expect.isTrue(generated.contains("a.length"));

  generated = compile(TEST_TWO, entry: 'foo');
  Expect.isTrue(generated.contains("return 3;"));

  generated = compile(TEST_THREE, entry: 'foo');
  Expect.isTrue(generated.contains("return 3;"));

  generated = compile(TEST_FOUR, entry: 'foo');
  Expect.isTrue(generated.contains("push(2);"));
}
