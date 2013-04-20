// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class Object {
  var x;
  int foo() {
    return 42;
  }
  bar(int x, int y, z) { }
}

class Baz extends Kuk implements A, B, C {
  static final y = 12, z = 42;
  static final Foo moms = 42, kuks = 42;
  final Kuk hest;
  static var foo;

  const Baz();
  const Baz.named() : this.foo = 1;
  factory prefix.A.foo() {
  }

  /* Try a few
   * syntactic constructs. */
  void baz() {
    if (42) if (42) 42; else throw 42;
    switch (42) { case 42: return 42; default: break;}
    switch (42) {
    L1: case 42:
          L2: for(;;) {}
          return 42;
        default:
          break;
    }
    switch (42) {
        case 42:
          L2: for(;;) {}
          return 42;
    L3: case 43:
        case 44:
        case 45:
        default:
          break;
    }
    switch (42) {
        case 42:
          L2: for(;;) {}
          return 42;
    L3: case 43:
          break;
    L4: case 44:
          continue L3;
        case 45:
          break;
    }
    try { } catch (e) { }
    L0: while (false) try { } catch (e) { } finally { break L0; }
    int kongy(x,y) { return 42; }  // This is a comment.

    42 is Baz;
    42 is Bar<Foo, Foo>;
    42 is !Baz;
    42 is !Bar<Foo, Foo>;
  }

  int bar(args) {
    kongy(args);
    kongy(1, args);
  }

  int hest(a) {
    for (var i = 0; i < a.length; i++) {
      a.b.c.f().g[i] += foo(i);
      int kuk = 42;
      (kuk);
      id(x) { return x; }
      int id(x) { return x; }
      Box<int, double> id(x) { return x; }
      var f = () { };
      assert(x == 12);
      id((x) {});
      a < b;
      int x = a < b;
      id(() {});
    }
  }

  Baz.superOnly(x, y, z) : super(x, y, z) {}
  Baz.superAndInit(x, y, z) : super(x, y, z), this.y = 2 {}
  Baz.superAndInits(x, y, z) : super(x, y, z), this.y = 2, this.x = 4 {}

  // Try all kinds of formal parameters.
  void fisk(final a,
            b,
            var c,
            int d,
            e(),
            void f(),
            Map<int, double> g,
            Map<int, double> h()) {}

  Baz(x, y, z) : super(x, y, z) {}
}

abstract class Foo implements D, E {
  bar();
}

// Test bounds on type parameters
abstract class Bar<K extends Foo, V> implements Foo {
}

abstract class Bar<K extends Foo, V extends Foo> implements Foo {
}

abstract class Bar<K, V extends Foo> implements Foo {
}
