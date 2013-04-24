#!/usr/bin/env dart
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/**
 * A main program that takes as input a source Dart file and a number
 * of JSON files representing translations of messages from the corresponding
 * Dart file. See extract_to_json.dart and make_hardcoded_translation.dart.
 *
 * This produces a series of files named
 * "messages_<locale>.dart" containing messages for a particular locale
 * and a main import file named "messages_all.dart" which has imports all of
 * them and provides an initializeMessages function.
 */
library generate_from_json;

import 'dart:io';
import 'package:intl/extract_messages.dart';
import 'package:intl/src/intl_message.dart';
import 'extract_to_json.dart';
import 'package:intl/generate_localized.dart';
import 'dart:json' as json;
import 'package:pathos/path.dart' as path;
import 'package:args/args.dart';

/**
 * Keeps track of all the messages we have processed so far, keyed by message
 * name.
 */
Map<String, IntlMessage> messages;

main() {
  var targetDir;
  var args = new Options().arguments;
  var parser = new ArgParser();
  parser.addFlag("suppress-warnings", defaultsTo: false,
      callback: (x) => suppressWarnings = x);
  parser.addOption("output-dir", defaultsTo: '.',
      callback: (x) => targetDir = x);
  parser.addOption("generated-file-prefix", defaultsTo: '',
      callback: (x) => generatedFilePrefix = x);
  parser.parse(args);
  if (args.length == 0) {
    print('Usage: generate_from_json [--output-dir=<dir>]'
        ' [generated-file-prefix=<prefix>] file1.dart file2.dart ...'
        ' outputFile.json');
    exit(0);
  }

  var dartFiles = args.where((x) => x.endsWith("dart")).toList();
  var jsonFiles = args.where((x) => x.endsWith(".json")).toList();

  // We're re-parsing the original files to find the corresponding messages,
  // so if there are warnings extracting the messages, suppress them.
  suppressWarnings = true;
  var allMessages = dartFiles.map((each) => parseFile(new File(each)));

  messages = new Map();
  for (var eachMap in allMessages) {
    eachMap.forEach((key, value) => messages[key] = value);
  }
  for (var arg in jsonFiles) {
    var file = new File(arg);
    generateLocaleFile(file, targetDir);
  }

  var mainImportFile = new File(path.join(targetDir,
      '${generatedFilePrefix}messages_all.dart'));
  mainImportFile.writeAsStringSync(generateMainImportFile());
}

/**
 * Create the file of generated code for a particular locale. We read the json
 * data and create [BasicTranslatedMessage] instances from everything,
 * excluding only the special _locale attribute that we use to indicate the
 * locale.
 */
void generateLocaleFile(File file, String targetDir) {
  var src = file.readAsStringSync();
  var data = json.parse(src);
  var locale = data["_locale"];
  allLocales.add(locale);

  var translations = [];
  data.forEach((key, value) {
    if (key[0] != "_") {
      translations.add(new BasicTranslatedMessage(key, value));
    }
  });
  generateIndividualMessageFile(locale, translations, targetDir);
}

/**
 * A TranslatedMessage that just uses the name as the id and knows how to look
 * up its original message in our [messages].
 */
class BasicTranslatedMessage extends TranslatedMessage {
  BasicTranslatedMessage(String name, String translated) :
      super(name, translated);

  IntlMessage get originalMessage =>
      (super.originalMessage == null) ? _findOriginal() : super.originalMessage;

  // We know that our [id] is the name of the message, which is used as the
  //key in [messages].
  IntlMessage _findOriginal() => originalMessage = messages[id];
}