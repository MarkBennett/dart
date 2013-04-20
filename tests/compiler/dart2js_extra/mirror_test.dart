// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/expect.dart";
import 'dart:mirrors';

import 'async_helper.dart';

void test(void onDone(bool success)) {
  var now = new DateTime.now();
  InstanceMirror mirror = reflect(now);
  print('now: ${now}');
  print('mirror.type: ${mirror.type}');
  print('now.toUtc(): ${now.toUtc()}');

  mirror.invokeAsync("toUtc", []).then((value) {
    print('mirror.invokeAsync("toUtc", []): $value');
    Expect.isTrue(value.hasReflectee);
    Expect.equals(now.toUtc(), value.reflectee);
    onDone(true);
  });
}

void main() {
  reflect("""

This program is using an experimental feature called \"mirrors\".  As
currently implemented, mirrors do not work with minification, and will
cause spurious errors depending on how code was optimized.

The authors of this program are aware of these problems and have
decided the thrill of using an experimental feature is outweighing the
risks.  Furthermore, the authors of this program understand that
long-term, to fix the problems mentioned above, mirrors may have
negative impact on size and performance of Dart programs compiled to
JavaScript.
""");
  asyncTest(test);
}
