// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library part_of_test;

import "package:expect/expect.dart";
import 'dart:uri';
import 'mock_compiler.dart';
import '../../../sdk/lib/_internal/compiler/implementation/dart2jslib.dart'
    show MessageKind;

final libraryUri = new Uri('test:library.dart');
const String LIBRARY_SOURCE = '''
library foo;
part 'part.dart';
''';

final partUri = new Uri('test:part.dart');
const String PART_SOURCE = '''
part of bar;
''';

void main() {
  var compiler = new MockCompiler();
  compiler.registerSource(libraryUri, LIBRARY_SOURCE);
  compiler.registerSource(partUri, PART_SOURCE);

  compiler.libraryLoader.loadLibrary(libraryUri, null, libraryUri);
  print('errors: ${compiler.errors}');
  print('warnings: ${compiler.warnings}');
  Expect.isTrue(compiler.errors.isEmpty);
  Expect.equals(1, compiler.warnings.length);
  Expect.equals(MessageKind.LIBRARY_NAME_MISMATCH,
                compiler.warnings[0].message.kind);
  Expect.equals('foo',
      compiler.warnings[0].message.arguments['libraryName'].toString());
}
