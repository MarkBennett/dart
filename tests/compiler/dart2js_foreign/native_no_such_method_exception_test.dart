// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/expect.dart";
import 'native_metadata.dart';

@Native("*A")
class A {
  bar() => 42;
}

@Native("*B")
class B {
  foo() => 42;
}

@native makeA();

@Native("""
  function A() {}
  makeA = function() { return new A; }
""")
setup();

main() {
  setup();
  var a = makeA();
  a.bar();
  var exception;
  try {
    a.foo();
  } on NoSuchMethodError catch (e) {
    exception = e;
  }
  Expect.isNotNull(exception);
}
