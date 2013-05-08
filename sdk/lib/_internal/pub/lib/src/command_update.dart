// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library command_update;

import 'dart:async';

import 'package:args/args.dart';

import 'command.dart';
import 'entrypoint.dart';
import 'log.dart' as log;

/// Handles the `update` pub command.
class UpdateCommand extends PubCommand {
  String get description =>
    "Update the current package's dependencies to the latest versions.";

  String get usage => 'pub update [dependencies...]';

  ArgParser get commandParser {
    return new ArgParser()
        ..addFlag('offline',
            help: 'Use cached packages instead of accessing the network.');
  }

  bool get isOffline => commandOptions['offline'];

  Future onRun() {
    var future;
    if (commandOptions.rest.isEmpty) {
      future = entrypoint.updateAllDependencies();
    } else {
      future = entrypoint.updateDependencies(commandOptions.rest);
    }

    return future.then((_) {
      log.message("Dependencies updated!");
      if (isOffline) {
        log.warning("Warning: Updating when offline may not update you to the "
                    "latest versions of your dependencies.");
      }
    });
  }
}
