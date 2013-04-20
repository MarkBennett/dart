// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library run_async_test;

import "package:expect/expect.dart";
import 'dart:async';
import '../../../pkg/unittest/lib/unittest.dart';

main() {
  test("run async timer after async test", () {
    // Check that Timers don't run before the async callbacks.
    bool timerCallbackExecuted = false;

    runAsync(expectAsync0(() {
      Expect.isFalse(timerCallbackExecuted);
    }));

    Timer.run(expectAsync0(() { timerCallbackExecuted = true; }));

    runAsync(expectAsync0(() {
      Expect.isFalse(timerCallbackExecuted);
    }));

    runAsync(expectAsync0(() {
      // Busy loop.
      var sum = 1;
      var sw = new Stopwatch()..start();
      while (sw.elapsedMilliseconds < 5) {
        sum++;
      }
      if (sum == 0) throw "bad";  // Just to use the result.
      runAsync(expectAsync0(() {
        Expect.isFalse(timerCallbackExecuted);
      }));
    }));

    runAsync(expectAsync0(() {
      Expect.isFalse(timerCallbackExecuted);
    }));
  });
}
