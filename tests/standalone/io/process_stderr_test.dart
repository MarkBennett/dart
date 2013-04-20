// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
// Process test program to test process communication.
//
// VMOptions=
// VMOptions=--short_socket_read
// VMOptions=--short_socket_write
// VMOptions=--short_socket_read --short_socket_write

import "package:expect/expect.dart";
import 'dart:async';
import 'dart:io';
import 'dart:math';

import "process_test_util.dart";

void test(Future<Process> future, int expectedExitCode) {
  future.then((process) {
    process.exitCode.then((exitCode) {
      Expect.equals(expectedExitCode, exitCode);
    });

    List<int> data = "ABCDEFGHI\n".codeUnits;
    final int dataSize = data.length;

    int received = 0;
    List<int> buffer = [];

    void readData(data) {
      buffer.addAll(data);
      for (int i = received;
           i < min(data.length, buffer.length) - 1;
           i++) {
        Expect.equals(data[i], buffer[i]);
      }
      received = buffer.length;
      if (received >= dataSize) {
        // We expect an extra character on windows due to carriage return.
        if (13 == buffer[dataSize - 1] && dataSize + 1 == received) {
          Expect.equals(13, buffer[dataSize - 1]);
          Expect.equals(10, buffer[dataSize]);
          buffer.removeLast();
        }
      }
    }

    process.stdout.listen((_) {});
    process.stdin.add(data);
    process.stdin.close();
    process.stderr.listen(readData);
  });
}

main() {
  // Run the test using the process_test binary.
  test(Process.start(getProcessTestFileName(),
                     const ["1", "1", "99", "0"]), 99);

  // Run the test using the dart binary with an echo script.
  // The test runner can be run from either the root or from runtime.
  var scriptFile = new File("tests/standalone/io/process_std_io_script.dart");
  if (!scriptFile.existsSync()) {
    scriptFile = new File("../tests/standalone/io/process_std_io_script.dart");
  }
  Expect.isTrue(scriptFile.existsSync());
  test(Process.start(new Options().executable, [scriptFile.path, "1"]), 0);
}
