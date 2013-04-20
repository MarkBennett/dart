// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/expect.dart";
import 'native_metadata.dart';

@Native("*A")
class A {
  bar() => 42;
  noSuchMethod(x,y) => "native($x:$y)";
}

@Native("*B")
class B {
  baz() => 42;
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
  Expect.equals("native(foo:[1, 2])", a.foo(1, 2));
  Expect.equals("native(baz:[3, 4, 5])", a.baz(3, 4, 5));
}
