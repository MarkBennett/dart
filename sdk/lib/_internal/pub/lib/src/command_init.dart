// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library command_init;

import 'command.dart';
import 'log.dart' as log;

// Handles the `init` pub command.
class InitCommand extends PubCommand {
  String get description => "Initializes a new project in the current directory.";
  String get usage => 'pub init';
  bool get requiresEntrypoint => false;

  Future onRun() {
    log.message("TODO: Initialize a project");
  }
}
