// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library command_version;

import 'dart:async';
import 'pub.dart';

/// Handles the `version` pub command. 
class VersionCommand extends PubCommand {
  String get description => 'Print pub version.';
  String get usage => 'pub version';
  bool get requiresEntrypoint => false;

  Future onRun() {
    printVersion();
  }
}
