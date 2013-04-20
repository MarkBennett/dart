// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/expect.dart";

// Test to ensure that an abstract getter is not mistaken for a field.

class Foo {
  get i;  // Abstract.
}

class Bar {
}

noMethod(e) => e is NoSuchMethodError;

checkIt(f) {
  Expect.throws(() { f.i = 'hi'; }, noMethod);
  Expect.throws(() { print(f.i); }, noMethod);
  Expect.throws(() { print(f.i()); }, noMethod);
}

main() {
  checkIt(new Foo());
  checkIt(new Bar());
}
