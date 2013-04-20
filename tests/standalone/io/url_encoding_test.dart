// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/expect.dart";
import "dart:async";
import "dart:utf";

part '../../../sdk/lib/io/io_sink.dart';
part "../../../sdk/lib/io/http.dart";
part "../../../sdk/lib/io/http_impl.dart";
part "../../../sdk/lib/io/http_parser.dart";
part "../../../sdk/lib/io/http_utils.dart";
part "../../../sdk/lib/io/socket.dart";

void testParseEncodedString() {
  String encodedString = 'foo+bar%20foobar%25%26';
  Expect.equals(_HttpUtils.decodeUrlEncodedString(encodedString),
                'foo bar foobar%&');
  encodedString = 'A+%2B+B';
  Expect.equals(_HttpUtils.decodeUrlEncodedString(encodedString),
                'A + B');
}

void testParseQueryString() {
  // The query string includes escaped "?"s, "&"s, "%"s and "="s.
  // These should not affect the splitting of the string.
  String queryString =
      '%3F=%3D&foo=bar&%26=%25&sqrt2=%E2%88%9A2&name=Franti%C5%A1ek';
  Map<String, String> map = _HttpUtils.splitQueryString(queryString);
  for (String key in map.keys) {
    Expect.equals(map[key], { '&'     : '%',
                              'foo'   : 'bar',
                              '?'     : '=',
                              'sqrt2' : '\u221A2',
                              'name'  : 'Franti\u0161ek'}[key]);
  }
  Expect.setEquals(map.keys.toSet(), ['&', '?', 'foo', 'sqrt2', 'name']);
}

void main() {
  testParseEncodedString();
  testParseQueryString();
}
