// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/expect.dart";

// When attempting to call a nonexistent constructor, check that a
// NoSuchMethodError is thrown.

foo() {
  throw 'hest';
}

class A {
  A.foo(var x) {}
}

main() {
  int i = 0;
  new A.foo(42);
  try {
    new A.bar(foo());  // Arguments are not evaluated with NoSuchMethodError.
  } on NoSuchMethodError catch (e) {  // Not 'on String catch ...'
    i = 1;
  }
  Expect.equals(1, i);
  try {
    new A();
  } on NoSuchMethodError catch (e) {
    i = 2;
  }
  Expect.equals(2, i);
}
