// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/expect.dart";
import "dart:async";
import "dart:math";

part "../../../sdk/lib/io/io_sink.dart";
part "../../../sdk/lib/io/http.dart";
part "../../../sdk/lib/io/http_impl.dart";
part "../../../sdk/lib/io/http_parser.dart";
part "../../../sdk/lib/io/http_utils.dart";
part "../../../sdk/lib/io/socket.dart";

void testParseHttpDate() {
  DateTime date;
  date = new DateTime.utc(1999, DateTime.JUNE, 11, 18, 46, 53, 0);
  Expect.equals(date, _HttpUtils.parseDate("Fri, 11 Jun 1999 18:46:53 GMT"));
  Expect.equals(date, _HttpUtils.parseDate("Friday, 11-Jun-1999 18:46:53 GMT"));
  Expect.equals(date, _HttpUtils.parseDate("Fri Jun 11 18:46:53 1999"));

  date = new DateTime.utc(1970, DateTime.JANUARY, 1, 0, 0, 0, 0);
  Expect.equals(date, _HttpUtils.parseDate("Thu, 1 Jan 1970 00:00:00 GMT"));
  Expect.equals(date,
                _HttpUtils.parseDate("Thursday, 1-Jan-1970 00:00:00 GMT"));
  Expect.equals(date, _HttpUtils.parseDate("Thu Jan  1 00:00:00 1970"));

  date = new DateTime.utc(2012, DateTime.MARCH, 5, 23, 59, 59, 0);
  Expect.equals(date, _HttpUtils.parseDate("Mon, 5 Mar 2012 23:59:59 GMT"));
  Expect.equals(date, _HttpUtils.parseDate("Monday, 5-Mar-2012 23:59:59 GMT"));
  Expect.equals(date, _HttpUtils.parseDate("Mon Mar  5 23:59:59 2012"));
}

void testFormatParseHttpDate() {
  test(int year,
       int month,
       int day,
       int hours,
       int minutes,
       int seconds,
       String expectedFormatted) {
    DateTime date;
    String formatted;
    date = new DateTime.utc(year, month, day, hours, minutes, seconds, 0);
    formatted = _HttpUtils.formatDate(date);
    Expect.equals(expectedFormatted, formatted);
    Expect.equals(date, _HttpUtils.parseDate(formatted));
  }

  test(1999, DateTime.JUNE, 11, 18, 46, 53, "Fri, 11 Jun 1999 18:46:53 GMT");
  test(1970, DateTime.JANUARY, 1, 0, 0, 0, "Thu, 1 Jan 1970 00:00:00 GMT");
  test(2012, DateTime.MARCH, 5, 23, 59, 59, "Mon, 5 Mar 2012 23:59:59 GMT");
}

void testParseHttpDateFailures() {
  Expect.throws(() {
    _HttpUtils.parseDate("");
  });
  String valid = "Mon, 5 Mar 2012 23:59:59 GMT";
  for (int i = 1; i < valid.length - 1; i++) {
    String tmp = valid.substring(0, i);
    Expect.throws(() {
      _HttpUtils.parseDate(tmp);
    });
    Expect.throws(() {
      _HttpUtils.parseDate(" $tmp");
    });
    Expect.throws(() {
      _HttpUtils.parseDate(" $tmp ");
    });
    Expect.throws(() {
      _HttpUtils.parseDate("$tmp ");
    });
  }
  Expect.throws(() {
    _HttpUtils.parseDate(" $valid");
  });
  Expect.throws(() {
    _HttpUtils.parseDate(" $valid ");
  });
  Expect.throws(() {
    _HttpUtils.parseDate("$valid ");
  });
}

void testParseHttpCookieDate() {
  Expect.throws(() => _HttpUtils.parseCookieDate(""));

  test(int year,
       int month,
       int day,
       int hours,
       int minutes,
       int seconds,
       String formatted) {
    DateTime date = new DateTime.utc(year, month, day, hours, minutes, seconds, 0);
    Expect.equals(date, _HttpUtils.parseCookieDate(formatted));
  }

  test(2012, DateTime.JUNE, 19, 14, 15, 01, "tue, 19-jun-12 14:15:01 gmt");
  test(2021, DateTime.JUNE, 09, 10, 18, 14, "Wed, 09-Jun-2021 10:18:14 GMT");
  test(2021, DateTime.JANUARY, 13, 22, 23, 01, "Wed, 13-Jan-2021 22:23:01 GMT");
  test(2013, DateTime.JANUARY, 15, 21, 47, 38, "Tue, 15-Jan-2013 21:47:38 GMT");
  test(1970, DateTime.JANUARY, 01, 00, 00, 01, "Thu, 01-Jan-1970 00:00:01 GMT");
}

void main() {
  testParseHttpDate();
  testFormatParseHttpDate();
  testParseHttpDateFailures();
  testParseHttpCookieDate();
}
