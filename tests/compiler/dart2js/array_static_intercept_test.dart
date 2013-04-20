// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/expect.dart";
import 'compiler_helper.dart';

const String TEST_ONE = r"""
foo(a) {
  a.add(42);
  a.removeLast();
  return a.length;
}
""";

main() {
  String generated = compile(TEST_ONE, entry: 'foo');
  Expect.isTrue(generated.contains(r'.add$1('));
  Expect.isTrue(generated.contains(r'.removeLast$0('));
  Expect.isTrue(generated.contains(r'.get$length('));
}
