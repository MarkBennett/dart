// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/expect.dart";

test1(bool passed, {a: 42}) {
  if (passed) {
    Expect.equals(54, a);
    Expect.isTrue(?a);
  } else {
    Expect.equals(42, a);
    Expect.isFalse(?a);
  }
  Expect.isTrue(?passed);
}

test2() {
  var closure = (passed, {a: 42}) {
    if (passed) {
      Expect.equals(54, a);
      Expect.isTrue(?a);
    } else {
      Expect.equals(42, a);
      Expect.isFalse(?a);
    }
    Expect.isTrue(?passed);
  };
  closure(true, a:54);
  closure(false);
}

class A {
  test3(bool passed, {a: 42}) {
    if (passed) {
      Expect.equals(54, a);
      Expect.isTrue(?a);
    } else {
      Expect.equals(42, a);
      Expect.isFalse(?a);
    }
    Expect.isTrue(?passed);
  }
}


test4(bool passed, {a}) {
  if (passed) {
    Expect.equals(54, a);
    Expect.isTrue(?a);
  } else {
    Expect.equals(null, a);
    Expect.isFalse(?a);
  }
  Expect.isTrue(?passed);
}

int inscrutable(int x) => x == 0 ? 0 : x | inscrutable(x & (x - 1));

main() {
  test1(true, a:54);
  test1(false);
  test2();
  new A().test3(true, a:54);
  new A().test3(false);

  var things = [test1, test2, new A().test3];

  var closure = things[inscrutable(0)];
  closure(true, a:54);
  closure(false);

  closure = things[inscrutable(1)];
  closure();

  closure = things[inscrutable(2)];
  closure(true, a:54);
  closure(false);

  test4(true, a:54);
  test4(false);
}
