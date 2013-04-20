// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// Dart test program for testing static const fields.
// This test should fail because fields a and c are static const fields
// and they are missing initializers.

class A {
  const A() : n = 5;
  final n;
  static const a;
  static const b = 3 + 5;
  static const c;
}

class StaticFinalFieldNegativeTest {
  static testMain() {
    var a = new A();
  }
}

main() {
  StaticFinalFieldNegativeTest.testMain();
}
