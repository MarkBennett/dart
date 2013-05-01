// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
// VMOptions=
// VMOptions=--short_socket_read
// VMOptions=--short_socket_write
// VMOptions=--short_socket_read --short_socket_write

import 'package:expect/expect.dart';
import 'dart:io';
import 'dart:typed_data';

void testServerCompress() {
  void test(List<int> data) {
    HttpServer.bind("127.0.0.1", 0).then((server) {
      server.listen((request) {
        request.response.add(data);
        request.response.close();
      });
      var client = new HttpClient();
      client.get("127.0.0.1", server.port, "/")
          .then((request) {
            request.headers.set(HttpHeaders.ACCEPT_ENCODING, "gzip,deflate");
            return request.close();
          })
          .then((response) {
            Expect.equals("gzip",
                          response.headers.value(HttpHeaders.CONTENT_ENCODING));
            response
                .fold([], (list, b) {
                  list.addAll(b);
                  return list;
                }).then((list) {
                  Expect.listEquals(data, list);
                  server.close();
                  client.close();
                });
          });
    });
  }
  test("My raw server provided data".codeUnits);
  var longBuffer = new Uint8List(1024 * 1024);
  for (int i = 0; i < longBuffer.length; i++) {
    longBuffer[i] = i & 0xFF;
  }
  test(longBuffer);
}

void testAcceptEncodingHeader() {
  void test(String encoding, bool valid) {
    HttpServer.bind("127.0.0.1", 0).then((server) {
      server.listen((request) {
        request.response.write("data");
        request.response.close();
      });
      var client = new HttpClient();
      client.get("127.0.0.1", server.port, "/")
          .then((request) {
            request.headers.set(HttpHeaders.ACCEPT_ENCODING, encoding);
            return request.close();
          })
          .then((response) {
            Expect.equals(
              valid,
              ("gzip" == response.headers.value(HttpHeaders.CONTENT_ENCODING)));
            response.listen(
                (_) {},
                onDone: () {
                  server.close();
                  client.close();
                });
          });
    });
  }
  test('gzip', true);
  test('deflate', false);
  test('gzip, deflate', true);
  test('gzip ,deflate', true);
  test('gzip  ,  deflate', true);
  test('deflate,gzip', true);
  test('deflate, gzip', true);
  test('deflate ,gzip', true);
  test('deflate  ,  gzip', true);
  test('abc,deflate  ,  gzip,def,,,ghi  ,jkl', true);
  test('xgzip', false);
  test('gzipx;', false);
}

void main() {
  testServerCompress();
  testAcceptEncodingHeader();
}
