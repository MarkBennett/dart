// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:expect/expect.dart';
import 'memory_source_file_helper.dart';

import '../../../sdk/lib/_internal/compiler/compiler.dart'
       show Diagnostic;

main() {
  Uri script = currentDirectory.resolve(nativeToUriPath(new Options().script));
  Uri libraryRoot = script.resolve('../../../sdk/');
  Uri packageRoot = script.resolve('./packages/');

  MemorySourceFileProvider.MEMORY_SOURCE_FILES = MEMORY_SOURCE_FILES;
  var provider = new MemorySourceFileProvider();
  int warningCount = 0;
  int errorCount = 0;
  void diagnosticHandler(Uri uri, int begin, int end,
                         String message, Diagnostic kind) {
    if (kind == Diagnostic.VERBOSE_INFO) {
      return;
    }
    if (kind == Diagnostic.ERROR) {
      errorCount++;
    } else if (kind == Diagnostic.WARNING) {
      warningCount++;
    } else {
      throw 'unexpected diagnostic $kind: $message';
    }
  }

  Compiler compiler = new Compiler(provider.readStringFromUri,
                                   (name, extension) => null,
                                   diagnosticHandler,
                                   libraryRoot,
                                   packageRoot,
                                   ['--analyze-only']);
  compiler.run(new Uri('memory:main.dart'));
  Expect.isTrue(compiler.compilationFailed);
  Expect.equals(5, errorCount);
  Expect.equals(1, warningCount);
}

const Map MEMORY_SOURCE_FILES = const {
  'main.dart': """
main() {
  for (var x, y in []) {
  }

  for (var x = 10 in []) {
  }

  for (x.y in []) { // Also causes a warning "x unresolved".
  }

  for ((){}() in []) {
  }

  for (1 in []) {
  }
}
"""
};
