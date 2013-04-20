// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library ManyGenericInstanceofTest.dart;
import "package:expect/expect.dart";
part "generic_instanceof.dart";

class ManyGenericInstanceofTest {
  static testMain() {
    for (int i = 0; i < 5000; i++) {
      GenericInstanceof.testMain();
    }
  }
}

main() {
  ManyGenericInstanceofTest.testMain();
}
