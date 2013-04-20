// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/expect.dart";
import 'native_metadata.dart';

typedef void Callback0();
typedef void Callback1(arg1);
typedef void Callback2(arg1, arg2);

@Native("*A")
class A {
  @native foo0(Callback0 closure);
  @native foo1(Callback1 closure, arg1);
  @native foo2(Callback2 closure, arg1, arg2);
}

@native makeA();

@Native("""
function A() {}
A.prototype.foo0 = function(closure) { return closure(); };
A.prototype.foo1 = function(closure, arg1) { return closure(arg1); };
A.prototype.foo2 = function(closure, arg1, arg2) {
  return closure(arg1, arg2);
};
makeA = function(){return new A;};
""")
void setup();


main() {
  setup();
  var a = makeA();
  Expect.equals(42, a.foo0(() => 42));
  Expect.equals(43, a.foo1((arg1) => arg1, 43));
  Expect.equals(44, a.foo2((arg1, arg2) => arg1 + arg2, 21, 23));

  A aa = a;
  Expect.equals(42, aa.foo0(() => 42));
  Expect.equals(43, aa.foo1((arg1) => arg1, 43));
  Expect.equals(44, aa.foo2((arg1, arg2) => arg1 + arg2, 21, 23));
}
