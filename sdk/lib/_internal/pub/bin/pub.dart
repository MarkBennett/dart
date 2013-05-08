// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:args/args.dart';
import 'package:pathos/path.dart' as path;

import '../lib/src/command.dart';
import '../lib/src/exit_codes.dart' as exit_codes;
import '../lib/src/io.dart';
import '../lib/src/log.dart' as log;
import '../lib/src/sdk.dart' as sdk;
import '../lib/src/system_cache.dart';
import '../lib/src/utils.dart';

/// The parser for arguments that are global to Pub rather than specific to a
/// single command.
ArgParser get pubArgParser {
  var parser = new ArgParser();
  parser.addFlag('help', abbr: 'h', negatable: false,
      help: 'Print this usage information.');
  parser.addFlag('version', negatable: false,
      help: 'Print pub version.');
  parser.addFlag('trace',
       help: 'Print debugging information when an error occurs.');
  parser.addOption('verbosity',
      help: 'Control output verbosity.',
      allowed: ['normal', 'io', 'solver', 'all'],
      allowedHelp: {
        'normal': 'Show errors, warnings, and user messages.',
        'io':     'Also show IO operations.',
        'solver': 'Show steps during version resolution.',
        'all':    'Show all output including internal tracing messages.'
      });
  parser.addFlag('verbose', abbr: 'v', negatable: false,
      help: 'Shortcut for "--verbosity=all".');
  return parser;
}

void main() {
  var globalOptions;
  try {
    globalOptions = pubArgParser.parse(new Options().arguments);
  } on FormatException catch (e) {
    log.error(e.message);
    log.error('Run "pub help" to see available options.');
    exit(exit_codes.USAGE);
  }

  if (globalOptions['version']) {
    log.message('Pub ${sdk.version}');
    return;
  }

  if (globalOptions['help'] || globalOptions.rest.isEmpty) {
    printUsage();
    return;
  }

  if (globalOptions['trace']) {
    log.recordTranscript();
  }

  switch (globalOptions['verbosity']) {
    case 'normal': log.showNormal(); break;
    case 'io': log.showIO(); break;
    case 'solver': log.showSolver(); break;
    case 'all': log.showAll(); break;
    default:
      // No specific verbosity given, so check for the shortcut.
      if (globalOptions['verbose']) {
        log.showAll();
      } else {
        log.showNormal();
      }
      break;
  }

  var cacheDir;
  if (Platform.environment.containsKey('PUB_CACHE')) {
    cacheDir = Platform.environment['PUB_CACHE'];
  } else if (Platform.operatingSystem == 'windows') {
    var appData = Platform.environment['APPDATA'];
    cacheDir = path.join(appData, 'Pub', 'Cache');
  } else {
    cacheDir = '${Platform.environment['HOME']}/.pub-cache';
  }

  validatePlatform().then((_) {
    // Select the command.
    var command = PubCommand.commands[globalOptions.rest[0]];
    if (command == null) {
      log.error('Could not find a command named "${globalOptions.rest[0]}".');
      log.error('Run "pub help" to see available commands.');
      exit(exit_codes.USAGE);
      return;
    }

    var commandArgs = globalOptions.rest.sublist(1);
    command.run(cacheDir, globalOptions, commandArgs);
  });
}

/// Checks that pub is running on a supported platform. If it isn't, it prints
/// an error message and exits. Completes when the validation is done.
Future validatePlatform() {
  return new Future.sync(() {
    if (Platform.operatingSystem != 'windows') return;

    return runProcess('ver', []).then((result) {
      if (result.stdout.join('\n').contains('XP')) {
        log.error('Sorry, but pub is not supported on Windows XP.');
        exit(exit_codes.USAGE);
      }
    });
  });
}

/// Displays usage information for the app.
void printUsage([String description = 'Pub is a package manager for Dart.']) {
  // Build up a buffer so it shows up as a single log entry.
  var buffer = new StringBuffer();
  buffer.write(description);
  buffer.write('\n\n');
  buffer.write('Usage: pub command [arguments]\n\n');
  buffer.write('Global options:\n');
  buffer.write('${pubArgParser.getUsage()}\n\n');

  // Show the commands sorted.
  buffer.write('Available commands:\n');

  // TODO(rnystrom): A sorted map would be nice.
  int length = 0;
  var names = <String>[];
  for (var command in PubCommand.commands.keys) {
    // Hide aliases.
    if (PubCommand.commands[command].aliases.indexOf(command) >= 0) continue;
    length = math.max(length, command.length);
    names.add(command);
  }

  names.sort((a, b) => a.compareTo(b));

  for (var name in names) {
    buffer.write('  ${padRight(name, length)}   '
        '${PubCommand.commands[name].description}\n');
  }

  buffer.write('\n');
  buffer.write(
      'Use "pub help [command]" for more information about a command.');
  log.message(buffer.toString());
}
