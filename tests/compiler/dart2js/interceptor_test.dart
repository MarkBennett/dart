// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/expect.dart";
import 'compiler_helper.dart';

const String TEST_ONE = r"""
  foo(a) {
    // Make sure there is a bailout version.
    foo(a);
    // This will make a one shot interceptor that will be optimized in
    // the non-bailout version because we know a is a number.
    return (a + 42).toString;
  }
""";

const String TEST_TWO = r"""
  foo(a) {
    var myVariableName = a + 42;
    print(myVariableName);
    print(myVariableName);
  }
""";

const String TEST_THREE = r"""
  class A {
    var length;
  }
  foo(a) {
    print([]); // Make sure the array class is instantiated.
    return new A().length + a.length;
  }
""";

main() {
  var generated = compile(TEST_ONE, entry: 'foo');
  // Check that the one shot interceptor got converted to a direct
  // call to the interceptor object.
  Expect.isTrue(generated.contains('JSNumber_methods.get\$toString(a + 42);'));

  // Check that one-shot interceptors preserve variable names, see
  // https://code.google.com/p/dart/issues/detail?id=8106.
  generated = compile(TEST_TWO, entry: 'foo');
  Expect.isTrue(generated.contains(r'$.$add$n(a, 42)'));
  Expect.isTrue(generated.contains('myVariableName'));

  // Check that an intercepted getter that does not need to be
  // intercepted, is turned into a regular getter call or field
  // access.
  generated = compile(TEST_THREE, entry: 'foo');
  Expect.isFalse(generated.contains(r'a.get$length()'));
  Expect.isTrue(generated.contains(r'$.A$().length'));
  Expect.isTrue(generated.contains(r'$.get$length$a(a)'));
}
