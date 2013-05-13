// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:json' as json;

import 'package:scheduled_test/scheduled_test.dart';

import '../descriptor.dart' as d;
import '../test_pub.dart';

main() {
  initConfig();

  integration("compiles dart.js next to entrypoints", () {
    serve([
      d.dir('packages', [
        d.file('browser.json', json.stringify({'versions': ['1.0.0']})),
        d.dir('browser', [
          d.dir('versions', [
            d.file('1.0.0.yaml', yaml(packageMap("browser", "1.0.0"))),
            d.tar('1.0.0.tar.gz', [
              d.file('pubspec.yaml', yaml(packageMap("browser", "1.0.0"))),
              d.dir('lib', [
                d.file('dart.js', 'contents of dart.js')
              ])
            ])
          ])
        ])
      ])
    ]);

    d.dir(appPath, [
      d.appPubspec([dependencyMap("browser", "1.0.0")]),
      d.dir('web', [
        d.file('file.dart', 'void main() => print("hello");'),
        d.dir('subdir', [
          d.file('subfile.dart', 'void main() => print("subhello");')
        ])
      ])
    ]).create();

    schedulePub(args: ["install"],
        output: new RegExp(r"Dependencies installed!$"));

    schedulePub(args: ["deploy"],
        output: '''
Finding entrypoints...
Copying   web/                    => deploy/
Compiling web/file.dart           => deploy/file.dart.js
Compiling web/file.dart           => deploy/file.dart
Copying   package:browser/dart.js => deploy/packages/browser/dart.js
Compiling web/subdir/subfile.dart => deploy/subdir/subfile.dart.js
Compiling web/subdir/subfile.dart => deploy/subdir/subfile.dart
Copying   package:browser/dart.js => deploy/subdir/packages/browser/dart.js
''',
        exitCode: 0);

    d.dir(appPath, [
      d.dir('deploy', [
        d.matcherFile('file.dart.js', isNot(isEmpty)),
        d.matcherFile('file.dart', isNot(isEmpty)),
        d.dir('packages', [d.dir('browser', [
          d.file('dart.js', 'contents of dart.js')
        ])]),
        d.dir('subdir', [
          d.dir('packages', [d.dir('browser', [
            d.file('dart.js', 'contents of dart.js')
          ])]),
          d.matcherFile('subfile.dart.js', isNot(isEmpty)),
          d.matcherFile('subfile.dart', isNot(isEmpty))
        ])
      ])
    ]).validate();
  });
}
