#!/usr/bin/env dart
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "dart:io";
import "dart:async" show getAttachedStackTrace;
import "release/version.dart";

void main() {
  Path scriptPath = new Path(new Options().script).directoryPath;
  Version version = new Version(scriptPath.append("VERSION"));
  Future f = version.getVersion();
  f.then((currentVersion) {
    print(currentVersion);
  }).catchError((e) {
    print("Could not create version number, failed with: $e");
    var trace = getAttachedStackTrace(e);
    if (trace != null) print("StackTrace: $trace");
    return true;
  });
}
