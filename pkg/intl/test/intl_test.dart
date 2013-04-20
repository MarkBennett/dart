// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library intl_test;

import 'package:intl/intl.dart';
import 'package:unittest/unittest.dart';
import 'package:intl/date_symbol_data_local.dart';

main() {
  test("Locale setting doesn't verify the core locale", () {
      var de = new Intl('de_DE');
      expect(de.locale, equals('de_DE'));
  });

  test('DateFormat creation does verify the locale', (){
    // TODO(alanknight): We need to make the locale verification be on a per
    // usage basis rather than once for the entire Intl object. The set of
    // locales covered for messages may be different from that for date
    // formatting.
    initializeDateFormatting('de_DE', null).then((_) {
      var de = new Intl('de_DE');
      var format = de.date().add_d();
      expect(format.locale, equals('de'));
     });
  });

  test("Canonicalizing locales", () {
    expect(Intl.canonicalizedLocale('en-us'), 'en_US');
    expect(Intl.canonicalizedLocale('en_us'), 'en_US');
    expect(Intl.canonicalizedLocale('en_US'), 'en_US');
    expect(Intl.canonicalizedLocale('xx-yyy'), 'xx_YYY');
    expect(Intl.canonicalizedLocale('xx_YYY'), 'xx_YYY');
    expect(Intl.canonicalizedLocale('C'), 'en_ISO');
  });
}
