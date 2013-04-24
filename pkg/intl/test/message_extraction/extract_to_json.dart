#!/usr/bin/env dart
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/**
 * This script uses the extract_messages.dart library to find the Intl.message
 * calls in the target dart files and produces intl_messages.json containing the
 * information on those messages. It uses the analyzer-experimental parser
 * to find the information.
 *
 * This is intended to test the basic functioning of extracting messages and
 * serve as an example for how a program to extract them to a translation
 * file format could work. In the tests, this file is then run through a
 * simulated translation and the results of that are used to generate code. See
 * message_extraction_test.dart
 *
 * If the environment variable INTL_MESSAGE_OUTPUT is set then it will use
 * that as the output directory, otherwise it will use the working directory.
 */
library extract_to_json;

import 'dart:io';
import 'package:intl/extract_messages.dart';
import 'dart:json' as json;
import 'package:pathos/path.dart' as path;
import 'package:intl/src/intl_message.dart';
import 'package:args/args.dart';

main() {
  var args = new Options().arguments;
  var targetDir;
  var parser = new ArgParser();
  parser.addFlag("suppress-warnings", defaultsTo: false,
      callback: (x) => suppressWarnings = x);

  void setTargetDir(value) => targetDir = value;

  parser.addOption("output-dir", defaultsTo: '.', callback: setTargetDir);
  parser.parse(args);
  if (args.length == 0) {
    print('Usage: extract_to_json [--output-dir=<dir>] [files.dart]');
    print('Accepts Dart files and produces intl_messages.json');
    exit(0);
  }
  var allMessages = [];
  for (var arg in args.where((x) => x.contains(".dart"))) {
    var messages = parseFile(new File(arg));
    messages.forEach((k, v) => allMessages.add(toJson(v)));
  }
  var file = new File(path.join(targetDir, 'intl_messages.json'));
  file.writeAsStringSync(json.stringify(allMessages));
}

/**
 * This is a placeholder for transforming a parameter substitution from
 * the translation file format into a Dart interpolation. In our case we
 * store it to the file in Dart interpolation syntax, so the transformation
 * is trivial.
 */
String leaveTheInterpolationsInDartForm(IntlMessage msg, chunk) =>
    (chunk is String) ? chunk : "\$${msg.arguments[chunk]}";

/**
 * Convert the [IntlMessage] to a trivial JSON format.
 */
Map toJson(IntlMessage message) {
  return {
    "name" : message.name,
    "description" : message.description,
    "message" : message.fullMessage(leaveTheInterpolationsInDartForm),
    "examples" : message.examples,
    "arguments" : message.arguments
  };
}