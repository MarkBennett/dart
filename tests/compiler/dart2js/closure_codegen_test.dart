// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// Test that parameters keep their names in the output.

import "package:expect/expect.dart";
import 'compiler_helper.dart';
import 'parser_helper.dart';

const String TEST_INVOCATION0 = r"""
main() {
  var o = null;
  o();
}
""";

const String TEST_INVOCATION1 = r"""
main() {
  var o = null;
  o(1);
}
""";

const String TEST_INVOCATION2 = r"""
main() {
  var o = null;
  o(1, 2);
}
""";

const String TEST_BAILOUT = r"""
class A {
  var x;
  foo() {
    var f = function g() { return 499;  };
    return 499 + x + f();
  }
}

main() { new A().foo(); }
""";

closureInvocation() {
  String generated = compile(TEST_INVOCATION0);
  Expect.isTrue(generated.contains(r".call$0()"));
  generated = compile(TEST_INVOCATION1);
  Expect.isTrue(generated.contains(r".call$1(1)"));
  generated = compile(TEST_INVOCATION2);
  Expect.isTrue(generated.contains(r".call$2(1, 2)"));
}

// Make sure that the bailout version does not introduce a second version of
// the closure.
closureBailout() {
  String generated = compileAll(TEST_BAILOUT);
  RegExp regexp = new RegExp(r'call\$0: function');
  Iterator<Match> matches = regexp.allMatches(generated).iterator;
  checkNumberOfMatches(matches, 1);
}

main() {
  closureInvocation();
  closureBailout();
}
