// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Dart test program for testing that isolates can spawn other isolates.

library NestedSpawnTest;
import 'dart:isolate';
import '../../pkg/unittest/lib/unittest.dart';

void isolateA() {
  port.receive((msg, replyTo) {
    expect(msg, "launch nested!");
    SendPort p = spawnFunction(isolateB);
    p.call("alive?").then((msg) {
      expect(msg, "and kicking");
      replyTo.send(499, null);
      port.close();
    });
  });
}

void isolateB() {
  port.receive((msg, replyTo) {
    expect(msg, "alive?");
    replyTo.send("and kicking", null);
    port.close();
  });
}


main() {
  test("spawned isolates can spawn nested isolates", () {
    SendPort port = spawnFunction(isolateA);
    port.call("launch nested!").then(expectAsync1((msg) {
      expect(msg, 499);
    }));
  });
}
