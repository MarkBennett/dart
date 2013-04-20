// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library descriptor.nothing;

import 'dart:async';
import 'dart:io';

import 'package:pathos/path.dart' as path;

import '../../descriptor.dart';
import '../../scheduled_test.dart';
import '../utils.dart';

/// A descriptor that validates that no file exists with the given name.
/// Creating this descriptor is a no-op and loading from it is invalid.
class NothingDescriptor extends Descriptor {
  NothingDescriptor(String name)
      : super(name);

  Future create([String parent]) => new Future.value();

  Future validate([String parent]) => schedule(() => validateNow(parent),
      "validating '$name' doesn't exist");

  Future validateNow([String parent]) => new Future.sync(() {
    if (parent == null) parent = defaultRoot;
    var fullPath = path.join(parent, name);
    if (new File(fullPath).existsSync()) {
      throw "Expected nothing to exist at '$fullPath', but found a file.";
    } else if (new Directory(fullPath).existsSync()) {
      throw "Expected nothing to exist at '$fullPath', but found a "
          "directory.";
    } else {
      return;
    }
  });

  Stream<List<int>> load(String pathToLoad) => errorStream("Nothing "
      "descriptors don't support load().");

  Stream<List<int>> read() => errorStream("Nothing descriptors don't support "
      "read().");

  String describe() => "nothing at '$name'";
}
