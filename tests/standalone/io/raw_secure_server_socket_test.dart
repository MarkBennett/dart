// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
// VMOptions=
// VMOptions=--short_socket_read
// VMOptions=--short_socket_write
// VMOptions=--short_socket_read --short_socket_write

import "package:expect/expect.dart";
import "dart:async";
import "dart:io";
import "dart:isolate";

const HOST_NAME = "localhost";
const CERTIFICATE = "localhost_cert";

void testSimpleBind() {
  ReceivePort port = new ReceivePort();
  RawSecureServerSocket.bind(HOST_NAME, 0, 5, CERTIFICATE).then((s) {
    Expect.isTrue(s.port > 0);
    s.close();
    port.close();
  });
}

void testInvalidBind() {
  int count = 0;
  ReceivePort port = new ReceivePort();
  port.receive((_, __) { count++; if (count == 3) port.close(); });

  // Bind to a unknown DNS name.
  RawSecureServerSocket.bind("ko.faar.__hest__", 0, 5, CERTIFICATE).then((_) {
    Expect.fail("Failure expected");
  }).catchError((error) {
    Expect.isTrue(error is SocketIOException);
    port.toSendPort().send(1);
  });

  // Bind to an unavaliable IP-address.
  RawSecureServerSocket.bind("8.8.8.8", 0, 5, CERTIFICATE).then((_) {
    Expect.fail("Failure expected");
  }).catchError((error) {
    Expect.isTrue(error is SocketIOException);
    port.toSendPort().send(1);
  });

  // Bind to a port already in use.
  // Either an error or a successful bind is allowed.
  // Windows platforms allow multiple binding to the same socket, with
  // unpredictable results.
  RawSecureServerSocket.bind(HOST_NAME, 0, 5, CERTIFICATE).then((s) {
    RawSecureServerSocket.bind(HOST_NAME,
                               s.port,
                               5,
                               CERTIFICATE).then((t) {
      Expect.equals('windows', Platform.operatingSystem);
      Expect.equals(s.port, t.port);
      s.close();
      t.close();
      port.toSendPort().send(1);
    })
    .catchError((error) {
      Expect.notEquals('windows', Platform.operatingSystem);
      Expect.isTrue(error is SocketIOException);
      s.close();
      port.toSendPort().send(1);
    });
  });
}

void testSimpleConnect(String certificate) {
  ReceivePort port = new ReceivePort();
  RawSecureServerSocket.bind(HOST_NAME, 0, 5, certificate).then((server) {
    var clientEndFuture = RawSecureSocket.connect(HOST_NAME, server.port);
    server.listen((serverEnd) {
      clientEndFuture.then((clientEnd) {
        clientEnd.shutdown(SocketDirection.SEND);
        serverEnd.shutdown(SocketDirection.SEND);
        server.close();
        port.close();
      });
    });
  });
}

void testSimpleConnectFail(String certificate) {
  ReceivePort port = new ReceivePort();
  RawSecureServerSocket.bind(HOST_NAME, 0, 5, certificate).then((server) {
    var clientEndFuture = RawSecureSocket.connect(HOST_NAME, server.port)
      .then((clientEnd) {
        Expect.fail("No client connection expected.");
      })
      .catchError((error) {
        Expect.isTrue(error is SocketIOException);
      });
    server.listen((serverEnd) {
      Expect.fail("No server connection expected.");
    },
    onError: (error) {
      Expect.isTrue(error is SocketIOException);
      clientEndFuture.then((_) => port.close());
    });
  });
}

void testServerListenAfterConnect() {
  ReceivePort port = new ReceivePort();
  RawSecureServerSocket.bind(HOST_NAME, 0, 5, CERTIFICATE).then((server) {
    Expect.isTrue(server.port > 0);
    var clientEndFuture = RawSecureSocket.connect(HOST_NAME, server.port);
    new Timer(const Duration(milliseconds: 500), () {
      server.listen((serverEnd) {
        clientEndFuture.then((clientEnd) {
          clientEnd.shutdown(SocketDirection.SEND);
          serverEnd.shutdown(SocketDirection.SEND);
          server.close();
          port.close();
        });
      });
    });
  });
}

// This test creates a server and a client connects. The client then
// writes and the server echos. When the server has finished its echo
// it half-closes. When the client gets the close event is closes
// fully.
//
// The test can be run in different configurations based on
// the boolean arguments:
//
// listenSecure
// When this argument is true a secure server is used. When this is false
// a non-secure server is used and the connections are secured after beeing
// connected.
//
// connectSecure
// When this argument is true a secure client connection is used. When this
// is false a non-secure client connection is used and the connection is
// secured after being connected.
//
// handshakeBeforeSecure
// When this argument is true some initial clear text handshake is done
// between client and server before the connection is secured. This argument
// only makes sense when both listenSecure and connectSecure are false.
//
// postponeSecure
// When this argument is false the securing of the server end will
// happen as soon as the last byte of the handshake before securing
// has been written. When this argument is true the securing of the
// server will not happen until the first TLS handshake data has been
// received from the client. This argument only takes effect when
// handshakeBeforeSecure is true.
void testSimpleReadWrite(bool listenSecure,
                         bool connectSecure,
                         bool handshakeBeforeSecure,
                         [bool postponeSecure = false]) {
  if (handshakeBeforeSecure == true &&
      (listenSecure == true || connectSecure == true)) {
    Expect.fail("Invalid arguments to testSimpleReadWrite");
  }

  ReceivePort port = new ReceivePort();

  const messageSize = 1000;
  const handshakeMessageSize = 100;

  List<int> createTestData() {
    List<int> data = new List<int>(messageSize);
    for (int i = 0; i < messageSize; i++) {
      data[i] = i & 0xff;
    }
    return data;
  }

  List<int> createHandshakeTestData() {
    List<int> data = new List<int>(handshakeMessageSize);
    for (int i = 0; i < handshakeMessageSize; i++) {
      data[i] = i & 0xff;
    }
    return data;
  }

  void verifyTestData(List<int> data) {
    Expect.equals(messageSize, data.length);
    List<int> expected = createTestData();
    for (int i = 0; i < messageSize; i++) {
      Expect.equals(expected[i], data[i]);
    }
  }

  void verifyHandshakeTestData(List<int> data) {
    Expect.equals(handshakeMessageSize, data.length);
    List<int> expected = createHandshakeTestData();
    for (int i = 0; i < handshakeMessageSize; i++) {
      Expect.equals(expected[i], data[i]);
    }
  }

  Future runServer(RawSocket client) {
    var completer = new Completer();
    int bytesRead = 0;
    int bytesWritten = 0;
    List<int> data = new List<int>(messageSize);
    client.writeEventsEnabled = false;
    var subscription;
    subscription = client.listen((event) {
      switch (event) {
        case RawSocketEvent.READ:
          Expect.isTrue(bytesWritten == 0);
          Expect.isTrue(client.available() > 0);
          var buffer = client.read();
          if (buffer != null) {
            data.setRange(bytesRead, bytesRead + buffer.length, buffer);
            bytesRead += buffer.length;
            for (var value in buffer) {
              Expect.isTrue(value is int);
              Expect.isTrue(value < 256 && value >= 0);
            }
          }
          if (bytesRead == data.length) {
            verifyTestData(data);
            client.writeEventsEnabled = true;
          }
          break;
        case RawSocketEvent.WRITE:
          Expect.isFalse(client.writeEventsEnabled);
          Expect.equals(bytesRead, data.length);
          for (int i = bytesWritten; i < data.length; ++i) {
            Expect.isTrue(data[i] is int);
            Expect.isTrue(data[i] < 256 && data[i] >= 0);
          }
          bytesWritten += client.write(
              data, bytesWritten, data.length - bytesWritten);
          if (bytesWritten < data.length) {
            client.writeEventsEnabled = true;
          }
          if (bytesWritten == data.length) {
            client.shutdown(SocketDirection.SEND);
          }
          break;
        case RawSocketEvent.READ_CLOSED:
          completer.complete(null);
          break;
        default: throw "Unexpected event $event";
      }
    });
    return completer.future;
  }

  Future<RawSocket> runClient(RawSocket socket) {
    var completer = new Completer();
    int bytesRead = 0;
    int bytesWritten = 0;
    List<int> dataSent = createTestData();
    List<int> dataReceived = new List<int>(dataSent.length);
    socket.listen((event) {
      switch (event) {
        case RawSocketEvent.READ:
          Expect.isTrue(socket.available() > 0);
          var buffer = socket.read();
          if (buffer != null) {
            dataReceived.setRange(bytesRead, bytesRead + buffer.length, buffer);
            bytesRead += buffer.length;
          }
          break;
        case RawSocketEvent.WRITE:
          Expect.isTrue(bytesRead == 0);
          Expect.isFalse(socket.writeEventsEnabled);
          bytesWritten += socket.write(
              dataSent, bytesWritten, dataSent.length - bytesWritten);
          if (bytesWritten < dataSent.length) {
            socket.writeEventsEnabled = true;
          }
          break;
        case RawSocketEvent.READ_CLOSED:
          verifyTestData(dataReceived);
          completer.complete(socket);
          break;
        default: throw "Unexpected event $event";
      }
    });
    return completer.future;
  }

  Future runServerHandshake(RawSocket client) {
    var completer = new Completer();
    int bytesRead = 0;
    int bytesWritten = 0;
    List<int> data = new List<int>(handshakeMessageSize);
    client.writeEventsEnabled = false;
    var subscription;
    subscription = client.listen((event) {
      switch (event) {
        case RawSocketEvent.READ:
          if (bytesRead < data.length) {
            Expect.isTrue(bytesWritten == 0);
          }
          Expect.isTrue(client.available() > 0);
          var buffer = client.read();
          if (buffer != null) {
            if (bytesRead == data.length) {
              // Read first part of TLS handshake from client.
              Expect.isTrue(postponeSecure);
              completer.complete([subscription, buffer]);
              client.readEventsEnabled = false;
              return;
            }
            data.setRange(bytesRead, bytesRead + buffer.length, buffer);
            bytesRead += buffer.length;
            for (var value in buffer) {
              Expect.isTrue(value is int);
              Expect.isTrue(value < 256 && value >= 0);
            }
          }
          if (bytesRead == data.length) {
            verifyHandshakeTestData(data);
            client.writeEventsEnabled = true;
          }
        if (bytesRead > data.length) print("XXX");
          break;
        case RawSocketEvent.WRITE:
          Expect.isFalse(client.writeEventsEnabled);
          Expect.equals(bytesRead, data.length);
          for (int i = bytesWritten; i < data.length; ++i) {
            Expect.isTrue(data[i] is int);
            Expect.isTrue(data[i] < 256 && data[i] >= 0);
          }
          bytesWritten += client.write(
              data, bytesWritten, data.length - bytesWritten);
          if (bytesWritten < data.length) {
            client.writeEventsEnabled = true;
          }
          if (bytesWritten == data.length) {
            if (!postponeSecure) {
              completer.complete([subscription, null]);
            }
          }
          break;
        case RawSocketEvent.READ_CLOSED:
          Expect.fail("Unexpected close");
          break;
        default: throw "Unexpected event $event";
      }
    });
    return completer.future;
  }

  Future<RawSocket> runClientHandshake(RawSocket socket) {
    var completer = new Completer();
    int bytesRead = 0;
    int bytesWritten = 0;
    List<int> dataSent = createHandshakeTestData();
    List<int> dataReceived = new List<int>(dataSent.length);
    var subscription;
    subscription = socket.listen((event) {
      switch (event) {
        case RawSocketEvent.READ:
          Expect.isTrue(socket.available() > 0);
          var buffer = socket.read();
          if (buffer != null) {
            dataReceived.setRange(bytesRead, bytesRead + buffer.length, buffer);
            bytesRead += buffer.length;
            if (bytesRead == dataSent.length) {
              verifyHandshakeTestData(dataReceived);
              completer.complete(subscription);
            }
          }
          break;
        case RawSocketEvent.WRITE:
          Expect.isTrue(bytesRead == 0);
          Expect.isFalse(socket.writeEventsEnabled);
          bytesWritten += socket.write(
              dataSent, bytesWritten, dataSent.length - bytesWritten);
          if (bytesWritten < dataSent.length) {
            socket.writeEventsEnabled = true;
          }
          break;
        case RawSocketEvent.READ_CLOSED:
          Expect.fail("Unexpected close");
          break;
        default: throw "Unexpected event $event";
      }
    });
    return completer.future;
  }

  Future<RawSecureSocket> connectClient(int port) {
    if (connectSecure) {
      return RawSecureSocket.connect(HOST_NAME, port);
    } else if (!handshakeBeforeSecure) {
      return RawSocket.connect(HOST_NAME, port).then((socket) {
        return RawSecureSocket.secure(socket);
      });
    } else {
      return RawSocket.connect(HOST_NAME, port).then((socket) {
        return runClientHandshake(socket).then((subscription) {
            return RawSecureSocket.secure(socket, subscription: subscription);
        });
      });
    }
  }

  serverReady(server) {
    server.listen((client) {
      if (listenSecure) {
        runServer(client).then((_) => server.close());
      } else if (!handshakeBeforeSecure) {
        RawSecureSocket.secureServer(client, CERTIFICATE).then((client) {
          runServer(client).then((_) => server.close());
        });
      } else {
        runServerHandshake(client).then((secure) {
            RawSecureSocket.secureServer(
                client,
                CERTIFICATE,
                subscription: secure[0],
                carryOverData: secure[1]).then((client) {
            runServer(client).then((_) => server.close());
          });
        });
      }
    });

    connectClient(server.port).then(runClient).then((socket) {
      socket.close();
      port.close();
    });
  }

  if (listenSecure) {
    RawSecureServerSocket.bind(
        HOST_NAME, 0, 5, CERTIFICATE).then(serverReady);
  } else {
    RawServerSocket.bind(HOST_NAME, 0, 5).then(serverReady);
  }
}

main() {
  Path scriptDir = new Path(new Options().script).directoryPath;
  Path certificateDatabase = scriptDir.append('pkcert');
  SecureSocket.initialize(database: certificateDatabase.toNativePath(),
                          password: 'dartdart',
                          useBuiltinRoots: false);
  testSimpleBind();
  testInvalidBind();
  testSimpleConnect(CERTIFICATE);
  testSimpleConnect("CN=localhost");
  testSimpleConnectFail("not_a_nickname");
  testSimpleConnectFail("CN=notARealDistinguishedName");
  testServerListenAfterConnect();
  testSimpleReadWrite(true, true, false);
  testSimpleReadWrite(true, false, false);
  testSimpleReadWrite(false, true, false);
  testSimpleReadWrite(false, false, false);
  testSimpleReadWrite(false, false, true, true);
  testSimpleReadWrite(false, false, true, false);
}
