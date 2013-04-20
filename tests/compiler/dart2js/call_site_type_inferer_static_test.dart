// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/expect.dart";
import "../../../sdk/lib/_internal/compiler/implementation/js_backend/js_backend.dart";
import "../../../sdk/lib/_internal/compiler/implementation/ssa/ssa.dart";

import 'compiler_helper.dart';
import 'parser_helper.dart';

void compileAndFind(String code,
                    String functionName,
                    bool disableInlining,
                    check(compiler, element)) {
  Uri uri = new Uri.fromComponents(scheme: 'source');
  var compiler = compilerFor(code, uri);
  compiler.disableInlining = disableInlining;
  compiler.runCompiler(uri);
  var fun = findElement(compiler, functionName);
  return check(compiler, fun);
}

// The 'f' function has an 'if' to make it non-inlinable.
const String TEST_ONE = r"""
  f(p) { if (p == null) return p; return p; }
  main() { f("s"); }
""";

const String TEST_TWO = r"""
  f(p) { if (p == null) return p; return p; }
  main() { f(1); }
""";

const String TEST_THREE = r"""
  f(p) { if (p == null) return p; return p; }
  main() { f(1); f(2); }
""";

const String TEST_FOUR = r"""
  f(p) { if (p == null) return p; return p; }
  main() { f(1.1); }
""";

const String TEST_FIVE = r"""
  f(p) { if (p == null) return p; return p; }
  main() { f(1); f(2.2); }
""";

const String TEST_SIX = r"""
  f(p) { if (p == null) return p; return p; }
  main() { f(1.1); f(2); }
""";

const String TEST_SEVEN = r"""
  f(p) { if (p == null) return p; return p; }
  main() { f(1); f("s"); }
""";

const String TEST_EIGHT = r"""
  f(p1, p2) { if (p1 == null) return p1; return p2; }
  main() { f(1, 2); f(1, "s"); }
""";

const String TEST_NINE = r"""
  f(p1, p2) { if (p1 == null) return p1; return p2; }
  main() { f("s", 2); f(1, "s"); }
""";

const String TEST_TEN = r"""
  f(p) { if (p == null) return p; return p; }
  g(p) { if (p== null) return null; return p(1); }
  main() { f(1); g(f); }
""";

void doTest(String test,
            bool enableInlining,
            List<Function> expectedTypes) {
  compileAndFind(
    test,
    'f',
    enableInlining,
    (compiler, x) {
      HTypeList types = compiler.backend.optimisticParameterTypes(x, null);
      if (expectedTypes != null) {
        Expect.isFalse(types.allUnknown);
        Expect.listEquals(expectedTypes.map((f) => f(compiler)).toList(),
                          types.types);
      } else {
        Expect.isTrue(types.allUnknown);
      }
  });
}

void runTest(String test, [List<Function> expectedTypes]) {
  doTest(test, false, expectedTypes);
  doTest(test, true, expectedTypes);
}

void test() {
  subclassOfInterceptor(compiler) =>
      findHType(compiler, 'Interceptor', 'nonNullSubclass');

  runTest(TEST_ONE, [(compiler) => HType.STRING]);
  runTest(TEST_TWO, [(compiler) => HType.INTEGER]);
  runTest(TEST_THREE, [(compiler) => HType.INTEGER]);
  runTest(TEST_FOUR, [(compiler) => HType.DOUBLE]);
  runTest(TEST_FIVE, [(compiler) => HType.NUMBER]);
  runTest(TEST_SIX, [(compiler) => HType.NUMBER]);
  runTest(TEST_SEVEN, [subclassOfInterceptor]);
  runTest(TEST_EIGHT, [(compiler) => HType.INTEGER, subclassOfInterceptor]);
  runTest(TEST_NINE, [subclassOfInterceptor, subclassOfInterceptor]);
  runTest(TEST_TEN);
}

void main() {
  test();
}
