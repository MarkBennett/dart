// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:isolate';

const ANY = InternetAddressType.ANY;

void testIPv6toIPv6() {
  InternetAddress.lookup("::0", type: ANY).then((serverAddr) {
    InternetAddress.lookup("::1", type: ANY).then((clientAddr) {
        ServerSocket.bind(serverAddr.first, 0).then((server) {
        server.listen((socket) {
          socket.destroy();
          server.close();
        });
        Socket.connect(clientAddr.first, server.port).then((socket) {
          socket.destroy();
        });
      });
    });
  });
}

void testIPv4toIPv6() {
  InternetAddress.lookup("::0", type: ANY).then((serverAddr) {
      ServerSocket.bind(serverAddr.first, 0).then((server) {
      server.listen((socket) {
        socket.destroy();
        server.close();
      });
      Socket.connect("127.0.0.1", server.port).then((socket) {
        socket.destroy();
      });
    });
  });
}

void testIPv6toIPv4() {
  InternetAddress.lookup("::1", type: ANY).then((clientAddr) {
      ServerSocket.bind("127.0.0.1", 0).then((server) {
      server.listen((socket) {
        throw "Unexpected socket";
      });
      Socket.connect(clientAddr.first, server.port).catchError((e) {
        server.close();
      });
    });
  });
}

void testIPv4toIPv4() {
  ServerSocket.bind("127.0.0.1", 0).then((server) {
    server.listen((socket) {
      socket.destroy();
      server.close();
    });
    Socket.connect("127.0.0.1", server.port).then((socket) {
      socket.destroy();
    });
  });
}

void testIPv6Lookup() {
  var port = new ReceivePort();
  InternetAddress.lookup("::0", type: ANY).then((list) {
    if (list.length < 0) throw "no address";
    for (var entry in list) {
      if (entry.type != InternetAddressType.IP_V6) {
        throw "Wrong IP type";
      }
    }
    port.close();
  });
}

void testIPv4Lookup() {
  var port = new ReceivePort();
  InternetAddress.lookup("127.0.0.1").then((list) {
    if (list.length < 0) throw "no addresse";
    for (var entry in list) {
      if (entry.type != InternetAddressType.IP_V4) {
        throw "Wrong IP type";
      }
    }
    port.close();
  });
}

void testIPv4toIPv6_IPV6Only() {
  InternetAddress.lookup("::0", type: ANY)
      .then((serverAddr) {
        ServerSocket.bind(serverAddr.first, 0, v6Only: true)
            .then((server) {
              server.listen((socket) {
                throw "Unexpcted socket";
              });
              Socket.connect("127.0.0.1", server.port).catchError((error) {
                server.close();
              });
            });
      });
}

void main() {
  testIPv6toIPv6();
  testIPv4toIPv6();
  testIPv6toIPv4();
  testIPv4toIPv4();
  testIPv6Lookup();
  testIPv4Lookup();

  testIPv4toIPv6_IPV6Only();
}
