// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library utf8_test;
import "package:expect/expect.dart";
import 'dart:utf';

String decode(List<int> bytes) => decodeUtf8(bytes);

main() {
  // Google favorite: "Îñţérñåţîöñåļîžåţîờñ".
  String string = decode([0xc3, 0x8e, 0xc3, 0xb1, 0xc5, 0xa3, 0xc3, 0xa9, 0x72,
                          0xc3, 0xb1, 0xc3, 0xa5, 0xc5, 0xa3, 0xc3, 0xae, 0xc3,
                          0xb6, 0xc3, 0xb1, 0xc3, 0xa5, 0xc4, 0xbc, 0xc3, 0xae,
                          0xc5, 0xbe, 0xc3, 0xa5, 0xc5, 0xa3, 0xc3, 0xae, 0xe1,
                          0xbb, 0x9d, 0xc3, 0xb1]);
  Expect.stringEquals("Îñţérñåţîöñåļîžåţîờñ", string);

  // Blueberry porridge in Danish: "blåbærgrød".
  string = decode([0x62, 0x6c, 0xc3, 0xa5, 0x62, 0xc3, 0xa6, 0x72, 0x67, 0x72,
                   0xc3, 0xb8, 0x64]);
  Expect.stringEquals("blåbærgrød", string);

  // "சிவா அணாமாைல", that is "Siva Annamalai" in Tamil.
  string = decode([0xe0, 0xae, 0x9a, 0xe0, 0xae, 0xbf, 0xe0, 0xae, 0xb5, 0xe0,
                   0xae, 0xbe, 0x20, 0xe0, 0xae, 0x85, 0xe0, 0xae, 0xa3, 0xe0,
                   0xae, 0xbe, 0xe0, 0xae, 0xae, 0xe0, 0xae, 0xbe, 0xe0, 0xaf,
                   0x88, 0xe0, 0xae, 0xb2]);
  Expect.stringEquals("சிவா அணாமாைல", string);

  // "िसवा अणामालै", that is "Siva Annamalai" in Devanagari.
  string = decode([0xe0, 0xa4, 0xbf, 0xe0, 0xa4, 0xb8, 0xe0, 0xa4, 0xb5, 0xe0,
                   0xa4, 0xbe, 0x20, 0xe0, 0xa4, 0x85, 0xe0, 0xa4, 0xa3, 0xe0,
                   0xa4, 0xbe, 0xe0, 0xa4, 0xae, 0xe0, 0xa4, 0xbe, 0xe0, 0xa4,
                   0xb2, 0xe0, 0xa5, 0x88]);
  Expect.stringEquals("िसवा अणामालै", string);

  // DESERET CAPITAL LETTER BEE, unicode 0x10412(0xD801+0xDC12)
  // UTF-8: F0 90 90 92
  string = decode([0xf0, 0x90, 0x90, 0x92]);
  Expect.equals(string.length, 2);
  Expect.equals("𐐒".length, 2);
  Expect.stringEquals("𐐒", string);

  // TODO(ahe): Add tests of bad input.
}
