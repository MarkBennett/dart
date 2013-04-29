// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
// Directory listing test.


import "dart:io";
import "dart:isolate";

import "package:expect/expect.dart";

testChangeDirectory() {
  var port = new ReceivePort();
  new Directory("").createTemp().then((temp) {
    var initialCurrent = Directory.current;
    Directory.current = temp;
    var newCurrent = Directory.current;
    new File("111").createSync();
    var dir = new Directory(newCurrent.path + Platform.pathSeparator + "222");
    dir.createSync();
    Directory.current = dir;
    new File("333").createSync();
    Expect.isTrue(new File("333").existsSync());
    Expect.isTrue(new File("../111").existsSync());
    Directory.current = "..";
    Expect.isTrue(new File("111").existsSync());
    Expect.isTrue(new File("222/333").existsSync());
    Directory.current = initialCurrent;
    temp.deleteSync(recursive: true);
    port.close();
  });
}


testChangeDirectoryIllegalArguments() {
  Expect.throws(() => Directory.current = 1, (e) => e is ArgumentError);
  Expect.throws(() => Directory.current = 111111111111111111111111111111111111,
                (e) => e is ArgumentError);
  Expect.throws(() => Directory.current = true, (e) => e is ArgumentError);
  Expect.throws(() => Directory.current = [], (e) => e is ArgumentError);
  Expect.throws(() => Directory.current = new File("xxx"),
                (e) => e is ArgumentError);
}


main() {
  testChangeDirectory();
  testChangeDirectoryIllegalArguments();
}
