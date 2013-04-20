// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
// Utility script to check that arguments are correctly passed from
// one dart process to another using the dart:io process interface.
import "dart:math";
import "dart:io";

class Expect {
  static void isTrue(x) {
    if (!x) {
      throw new Error("Not true");
    }
  }

  static void equals(x, y) {
    if (x != y) {
      throw new Error("Not equal");
    }
  }
}

main() {
  var options = new Options();
  Expect.isTrue(options.script.endsWith('process_check_arguments_script.dart'));
  var expected_num_args = int.parse(options.arguments[0]);
  var contains_quote = int.parse(options.arguments[1]);
  Expect.equals(expected_num_args, options.arguments.length);
  for (var i = 2; i < options.arguments.length; i++) {
    Expect.isTrue((contains_quote == 0) || options.arguments[i].contains('"'));
  }
}
