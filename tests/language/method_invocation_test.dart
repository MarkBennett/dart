// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/expect.dart";

// Testing method invocation.
// Currently testing only NoSuchMethodError.

class A {
  A() {}
  int foo() {
    return 1;
  }
}

class MethodInvocationTest {
  static void testNullReceiver() {
    A a = new A();
    Expect.equals(1, a.foo());
    a = null;
    bool exceptionCaught = false;
    try {
      a.foo();
    } on NoSuchMethodError catch (e) {
      exceptionCaught = true;
    }
    Expect.equals(true, exceptionCaught);
  }

  static void testMain() {
    testNullReceiver();
  }
}

main() {
  MethodInvocationTest.testMain();
}
