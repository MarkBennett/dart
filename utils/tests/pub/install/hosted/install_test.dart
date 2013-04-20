// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library pub_tests;

import 'dart:io';

import '../../descriptor.dart' as d;
import '../../test_pub.dart';

main() {
  initConfig();
  integration('installs a package from a pub server', () {
    servePackages([packageMap("foo", "1.2.3")]);

    d.appDir([dependencyMap("foo", "1.2.3")]).create();

    schedulePub(args: ['install'],
        output: new RegExp("Dependencies installed!\$"));

    d.cacheDir({"foo": "1.2.3"}).validate();
    d.packagesDir({"foo": "1.2.3"}).validate();
  });

  integration('URL encodes the package name', () {
    servePackages([]);

    d.appDir([dependencyMap("bad name!", "1.2.3")]).create();

    schedulePub(args: ['install'],
        error: new RegExp('Could not find package "bad name!" at '
                          'http://localhost:'),
        exitCode: 1);
  });
}
