// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/expect.dart";
import "dart:io";
import "dart:uri";
import "dart:isolate";
import "dart:async";

void testGoogleUrl() {
  ReceivePort keepAlive = new ReceivePort();
  HttpClient client = new HttpClient();
  client.getUrl(Uri.parse('https://www.google.com'))
      .then((request) => request.close())
      .then((response) => Expect.fail("Unexpected successful connection"))
      .catchError((error) {
        Expect.isTrue(error is SocketIOException);
        keepAlive.close();
        client.close();
      });
}

void InitializeSSL() {
  // If the built-in root certificates aren't loaded, the connection
  // should signal an error.  Even when an external database is loaded,
  // they should not be loaded.
  Path scriptDir = new Path(new Options().script).directoryPath;
  Path certificateDatabase = scriptDir.append('pkcert');
  SecureSocket.initialize(database: certificateDatabase.toNativePath(),
                          password: 'dartdart',
                          useBuiltinRoots: false);
}

void main() {
  InitializeSSL();
  testGoogleUrl();
}
