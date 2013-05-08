// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library command_install;

import 'dart:async';

import 'package:args/args.dart';

import 'command.dart';
import 'entrypoint.dart';
import 'log.dart' as log;

/// Handles the `install` pub command.
class InstallCommand extends PubCommand {
  String get description => "Install the current package's dependencies.";
  String get usage => "pub install";

  ArgParser get commandParser {
    return new ArgParser()
        ..addFlag('offline',
            help: 'Use cached packages instead of accessing the network.');
  }

  bool get isOffline => commandOptions['offline'];

  Future onRun() {
    return entrypoint.installDependencies()
        .then((_) => log.message("Dependencies installed!"));
  }
}
