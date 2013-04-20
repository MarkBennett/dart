// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:expect/expect.dart';
import
    '../../../sdk/lib/_internal/compiler/implementation/types/types.dart'
    show TypeMask;

import 'compiler_helper.dart';
import 'parser_helper.dart';

// Test that if (x == y) where we know nothing about x and y will get optimized
// to if ($.$eq(x, y)) and not
// to if ($.$eq(x, y) == true)
// This is an optimization based on seeing that all the relational operators,
// ==, <, >, <=, >= only have implementations that return bool.

const String TEST = """
int inscrutable(int x) => x == 0 ? 0 : x | inscrutable(x & (x - 1));

class A {
  A(this.foo);
  int foo;
  operator==(other) {
    // Make the source size and AST size bigger so that it is not analyzed
    // first.
    1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+1+11+1+1+1+11+1+1+11+1+1;
    return this.foo == other.foo;
  }
}

class B extends A {
  B(int foo, this.bar) : super(foo);
  int bar;
  operator==(other) {
    if (other.bar != bar) return false;
    return other.foo == foo;
  }
}

main() {
  var both = [new A(inscrutable(0) == 0 ? 42 : "fish"),
              new B(0, inscrutable(0) == 0 ? 2 : "horse")];
  if (both[1] == both[0]) {
    print("hestfisk");
  }
}
""";

void main() {
  String generated = compileAll(TEST);
  if (!generated.contains(r'if ($.$eq(both[1], both[0]))')) {
    print(generated);
    Expect.fail("missing elision of '=== true'");
  }
}
