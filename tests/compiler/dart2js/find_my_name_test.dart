// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/expect.dart";
import "../../../sdk/lib/_internal/compiler/implementation/elements/elements.dart";
import "mock_compiler.dart";
import "parser_helper.dart";

main() {
  MockCompiler compiler = new MockCompiler();

  String code = '''
class Foo {
  operator+(other) => null;
}
''';

  ClassElement foo = parseUnit(code, compiler, compiler.mainApp).head;
  foo.parseNode(compiler);
  for (Element e in foo.localMembers) {
    Expect.equals(code.indexOf(e.name.slowToString()), e.position().charOffset);
  }
}
