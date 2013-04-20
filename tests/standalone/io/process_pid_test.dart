// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
// Process test program to test process communication.

import "package:expect/expect.dart";
import "dart:async";
import "dart:io";
import "dart:isolate";

main() {
  var port = new ReceivePort();
  Expect.isTrue(pid > 0);
  var futures = [];
  futures.add(Process.start(new Options().executable,['--version']));
  futures.add(Process.run(new Options().executable,['--version']));
  Future.wait(futures).then((results) {
    Expect.isTrue(results[0].pid > 0);
    Expect.isTrue(results[1].pid > 0);
    Expect.equals(0, results[1].exitCode);
    results[0].exitCode.then((exitCode) {
      Expect.equals(0, exitCode);
      port.close();
    });
  });
}
