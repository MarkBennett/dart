#!/usr/bin/env dart
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library utf8_tests;
import 'dunit.dart';
import '../../../lib/utf/utf.dart';

void main() {
  TestSuite suite = new TestSuite();
  suite.registerTestClass(new Utf8Tests());
  suite.run();
}

class Utf8Tests extends TestClass {
  static const String testEnglishPhrase =
      "The quick brown fox jumps over the lazy dog.";

  static const List<int> testEnglishUtf8 = const<int> [
      0x54, 0x68, 0x65, 0x20, 0x71, 0x75, 0x69, 0x63,
      0x6b, 0x20, 0x62, 0x72, 0x6f, 0x77, 0x6e, 0x20,
      0x66, 0x6f, 0x78, 0x20, 0x6a, 0x75, 0x6d, 0x70,
      0x73, 0x20, 0x6f, 0x76, 0x65, 0x72, 0x20, 0x74,
      0x68, 0x65, 0x20, 0x6c, 0x61, 0x7a, 0x79, 0x20,
      0x64, 0x6f, 0x67, 0x2e];

  static const String testDanishPhrase = "Quizdeltagerne spiste jordbær med " +
      "fløde mens cirkusklovnen Wolther spillede på xylofon.";

  static const List<int> testDanishUtf8 = const<int>[
      0x51, 0x75, 0x69, 0x7a, 0x64, 0x65, 0x6c, 0x74,
      0x61, 0x67, 0x65, 0x72, 0x6e, 0x65, 0x20, 0x73,
      0x70, 0x69, 0x73, 0x74, 0x65, 0x20, 0x6a, 0x6f,
      0x72, 0x64, 0x62, 0xc3, 0xa6, 0x72, 0x20, 0x6d,
      0x65, 0x64, 0x20, 0x66, 0x6c, 0xc3, 0xb8, 0x64,
      0x65, 0x20, 0x6d, 0x65, 0x6e, 0x73, 0x20, 0x63,
      0x69, 0x72, 0x6b, 0x75, 0x73, 0x6b, 0x6c, 0x6f,
      0x76, 0x6e, 0x65, 0x6e, 0x20, 0x57, 0x6f, 0x6c,
      0x74, 0x68, 0x65, 0x72, 0x20, 0x73, 0x70, 0x69,
      0x6c, 0x6c, 0x65, 0x64, 0x65, 0x20, 0x70, 0xc3,
      0xa5, 0x20, 0x78, 0x79, 0x6c, 0x6f, 0x66, 0x6f,
      0x6e, 0x2e];

  // unusual formatting due to strange editor interaction w/ text direction.
  static const String
      testHebrewPhrase = "דג סקרן שט בים מאוכזב ולפתע מצא לו חברה איך הקליטה";

  static const List<int> testHebrewUtf8 = const<int>[
      0xd7, 0x93, 0xd7, 0x92, 0x20, 0xd7, 0xa1, 0xd7,
      0xa7, 0xd7, 0xa8, 0xd7, 0x9f, 0x20, 0xd7, 0xa9,
      0xd7, 0x98, 0x20, 0xd7, 0x91, 0xd7, 0x99, 0xd7,
      0x9d, 0x20, 0xd7, 0x9e, 0xd7, 0x90, 0xd7, 0x95,
      0xd7, 0x9b, 0xd7, 0x96, 0xd7, 0x91, 0x20, 0xd7,
      0x95, 0xd7, 0x9c, 0xd7, 0xa4, 0xd7, 0xaa, 0xd7,
      0xa2, 0x20, 0xd7, 0x9e, 0xd7, 0xa6, 0xd7, 0x90,
      0x20, 0xd7, 0x9c, 0xd7, 0x95, 0x20, 0xd7, 0x97,
      0xd7, 0x91, 0xd7, 0xa8, 0xd7, 0x94, 0x20, 0xd7,
      0x90, 0xd7, 0x99, 0xd7, 0x9a, 0x20, 0xd7, 0x94,
      0xd7, 0xa7, 0xd7, 0x9c, 0xd7, 0x99, 0xd7, 0x98,
      0xd7, 0x94];

  static const String testRussianPhrase = "Съешь же ещё этих мягких " +
      "французских булок да выпей чаю";

  static const List<int> testRussianUtf8 = const<int>[
      0xd0, 0xa1, 0xd1, 0x8a, 0xd0, 0xb5, 0xd1, 0x88,
      0xd1, 0x8c, 0x20, 0xd0, 0xb6, 0xd0, 0xb5, 0x20,
      0xd0, 0xb5, 0xd1, 0x89, 0xd1, 0x91, 0x20, 0xd1,
      0x8d, 0xd1, 0x82, 0xd0, 0xb8, 0xd1, 0x85, 0x20,
      0xd0, 0xbc, 0xd1, 0x8f, 0xd0, 0xb3, 0xd0, 0xba,
      0xd0, 0xb8, 0xd1, 0x85, 0x20, 0xd1, 0x84, 0xd1,
      0x80, 0xd0, 0xb0, 0xd0, 0xbd, 0xd1, 0x86, 0xd1,
      0x83, 0xd0, 0xb7, 0xd1, 0x81, 0xd0, 0xba, 0xd0,
      0xb8, 0xd1, 0x85, 0x20, 0xd0, 0xb1, 0xd1, 0x83,
      0xd0, 0xbb, 0xd0, 0xbe, 0xd0, 0xba, 0x20, 0xd0,
      0xb4, 0xd0, 0xb0, 0x20, 0xd0, 0xb2, 0xd1, 0x8b,
      0xd0, 0xbf, 0xd0, 0xb5, 0xd0, 0xb9, 0x20, 0xd1,
      0x87, 0xd0, 0xb0, 0xd1, 0x8e];

  static const String testGreekPhrase = "Γαζέες καὶ μυρτιὲς δὲν θὰ βρῶ πιὰ " +
      "στὸ χρυσαφὶ ξέφωτο";

  static const List<int> testGreekUtf8 = const<int>[
      0xce, 0x93, 0xce, 0xb1, 0xce, 0xb6, 0xce, 0xad,
      0xce, 0xb5, 0xcf, 0x82, 0x20, 0xce, 0xba, 0xce,
      0xb1, 0xe1, 0xbd, 0xb6, 0x20, 0xce, 0xbc, 0xcf,
      0x85, 0xcf, 0x81, 0xcf, 0x84, 0xce, 0xb9, 0xe1,
      0xbd, 0xb2, 0xcf, 0x82, 0x20, 0xce, 0xb4, 0xe1,
      0xbd, 0xb2, 0xce, 0xbd, 0x20, 0xce, 0xb8, 0xe1,
      0xbd, 0xb0, 0x20, 0xce, 0xb2, 0xcf, 0x81, 0xe1,
      0xbf, 0xb6, 0x20, 0xcf, 0x80, 0xce, 0xb9, 0xe1,
      0xbd, 0xb0, 0x20, 0xcf, 0x83, 0xcf, 0x84, 0xe1,
      0xbd, 0xb8, 0x20, 0xcf, 0x87, 0xcf, 0x81, 0xcf,
      0x85, 0xcf, 0x83, 0xce, 0xb1, 0xcf, 0x86, 0xe1,
      0xbd, 0xb6, 0x20, 0xce, 0xbe, 0xce, 0xad, 0xcf,
      0x86, 0xcf, 0x89, 0xcf, 0x84, 0xce, 0xbf];

  static const String testKatakanaPhrase = """
イロハニホヘト チリヌルヲ ワカヨタレソ ツネナラム
ウヰノオクヤマ ケフコエテ アサキユメミシ ヱヒモセスン""";

  static const List<int> testKatakanaUtf8 = const<int>[
      0xe3, 0x82, 0xa4, 0xe3, 0x83, 0xad, 0xe3, 0x83,
      0x8f, 0xe3, 0x83, 0x8b, 0xe3, 0x83, 0x9b, 0xe3,
      0x83, 0x98, 0xe3, 0x83, 0x88, 0x20, 0xe3, 0x83,
      0x81, 0xe3, 0x83, 0xaa, 0xe3, 0x83, 0x8c, 0xe3,
      0x83, 0xab, 0xe3, 0x83, 0xb2, 0x20, 0xe3, 0x83,
      0xaf, 0xe3, 0x82, 0xab, 0xe3, 0x83, 0xa8, 0xe3,
      0x82, 0xbf, 0xe3, 0x83, 0xac, 0xe3, 0x82, 0xbd,
      0x20, 0xe3, 0x83, 0x84, 0xe3, 0x83, 0x8d, 0xe3,
      0x83, 0x8a, 0xe3, 0x83, 0xa9, 0xe3, 0x83, 0xa0,
      0x0a, 0xe3, 0x82, 0xa6, 0xe3, 0x83, 0xb0, 0xe3,
      0x83, 0x8e, 0xe3, 0x82, 0xaa, 0xe3, 0x82, 0xaf,
      0xe3, 0x83, 0xa4, 0xe3, 0x83, 0x9e, 0x20, 0xe3,
      0x82, 0xb1, 0xe3, 0x83, 0x95, 0xe3, 0x82, 0xb3,
      0xe3, 0x82, 0xa8, 0xe3, 0x83, 0x86, 0x20, 0xe3,
      0x82, 0xa2, 0xe3, 0x82, 0xb5, 0xe3, 0x82, 0xad,
      0xe3, 0x83, 0xa6, 0xe3, 0x83, 0xa1, 0xe3, 0x83,
      0x9f, 0xe3, 0x82, 0xb7, 0x20, 0xe3, 0x83, 0xb1,
      0xe3, 0x83, 0x92, 0xe3, 0x83, 0xa2, 0xe3, 0x82,
      0xbb, 0xe3, 0x82, 0xb9, 0xe3, 0x83, 0xb3];

  void registerTests(TestSuite suite) {
    register("Utf8Tests.testUtf8bytesToCodepoints", testUtf8bytesToCodepoints,
        suite);
    register("Utf8Tests.testUtf8BytesToString", testUtf8BytesToString, suite);
    register("Utf8Tests.testEncodeToUtf8", testEncodeToUtf8, suite);
    register("Utf8Tests.testIterableMethods", testIterableMethods, suite);
  }

  void testEncodeToUtf8() {
    Expect.listEquals(testEnglishUtf8, encodeUtf8(testEnglishPhrase),
        "english to utf8");

    Expect.listEquals(testDanishUtf8, encodeUtf8(testDanishPhrase),
        "encode danish to utf8");

    Expect.listEquals(testHebrewUtf8, encodeUtf8(testHebrewPhrase),
        "Hebrew to utf8");

    Expect.listEquals(testRussianUtf8, encodeUtf8(testRussianPhrase),
        "Russian to utf8");

    Expect.listEquals(testGreekUtf8, encodeUtf8(testGreekPhrase),
        "Greek to utf8");

    Expect.listEquals(testKatakanaUtf8, encodeUtf8(testKatakanaPhrase),
        "Katakana to utf8");
  }

  void testUtf8bytesToCodepoints() {
    Expect.listEquals([954, 972, 963, 956, 949],
        utf8ToCodepoints([0xce, 0xba, 0xcf, 0x8c, 0xcf,
        0x83, 0xce, 0xbc, 0xce, 0xb5]), "κόσμε");

    // boundary conditions: First possible sequence of a certain length
    Expect.listEquals([], utf8ToCodepoints([]), "no input");
    Expect.listEquals([0x0], utf8ToCodepoints([0x0]), "0");
    Expect.listEquals([0x80], utf8ToCodepoints([0xc2, 0x80]), "80");
    Expect.listEquals([0x800],
        utf8ToCodepoints([0xe0, 0xa0, 0x80]), "800");
    Expect.listEquals([0x10000],
        utf8ToCodepoints([0xf0, 0x90, 0x80, 0x80]), "10000");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xf8, 0x88, 0x80, 0x80, 0x80]), "200000");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xfc, 0x84, 0x80, 0x80, 0x80, 0x80]),
        "4000000");

    // boundary conditions: Last possible sequence of a certain length
    Expect.listEquals([0x7f], utf8ToCodepoints([0x7f]), "7f");
    Expect.listEquals([0x7ff], utf8ToCodepoints([0xdf, 0xbf]), "7ff");
    Expect.listEquals([0xffff],
        utf8ToCodepoints([0xef, 0xbf, 0xbf]), "ffff");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xf7, 0xbf, 0xbf, 0xbf]), "1fffff");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xfb, 0xbf, 0xbf, 0xbf, 0xbf]), "3ffffff");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xfd, 0xbf, 0xbf, 0xbf, 0xbf, 0xbf]),
        "4000000");

    // other boundary conditions
    Expect.listEquals([0xd7ff],
        utf8ToCodepoints([0xed, 0x9f, 0xbf]), "d7ff");
    Expect.listEquals([0xe000],
        utf8ToCodepoints([0xee, 0x80, 0x80]), "e000");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xef, 0xbf, 0xbd]), "fffd");
    Expect.listEquals([0x10ffff],
        utf8ToCodepoints([0xf4, 0x8f, 0xbf, 0xbf]), "10ffff");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xf4, 0x90, 0x80, 0x80]), "110000");

    // unexpected continuation bytes
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0x80]), "80 => replacement character");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xbf]), "bf => replacement character");

    List<int> allContinuationBytes = <int>[];
    List<int> matchingReplacementChars = <int>[];
    for (int i = 0x80; i < 0xc0; i++) {
      allContinuationBytes.add(i);
      matchingReplacementChars.add(UNICODE_REPLACEMENT_CHARACTER_CODEPOINT);
    }
    Expect.listEquals(matchingReplacementChars,
        utf8ToCodepoints(allContinuationBytes),
        "80 - bf => replacement character x 64");

    List<int> allFirstTwoByteSeq = <int>[];
    matchingReplacementChars = <int>[];
    for (int i = 0xc0; i < 0xe0; i++) {
      allFirstTwoByteSeq.addAll([i, 0x20]);
      matchingReplacementChars.addAll(
          [UNICODE_REPLACEMENT_CHARACTER_CODEPOINT]);
    }
    Expect.listEquals(matchingReplacementChars,
        utf8ToCodepoints(allFirstTwoByteSeq),
        "c0 - df + space => replacement character + space x 32");

    List<int> allFirstThreeByteSeq = <int>[];
    matchingReplacementChars = <int>[];
    for (int i = 0xe0; i < 0xf0; i++) {
      allFirstThreeByteSeq.addAll([i, 0x20]);
      matchingReplacementChars.addAll(
          [UNICODE_REPLACEMENT_CHARACTER_CODEPOINT]);
    }
    Expect.listEquals(matchingReplacementChars,
        utf8ToCodepoints(allFirstThreeByteSeq),
        "e0 - ef + space => replacement character x 16");

    List<int> allFirstFourByteSeq = <int>[];
    matchingReplacementChars = <int>[];
    for (int i = 0xf0; i < 0xf8; i++) {
      allFirstFourByteSeq.addAll([i, 0x20]);
      matchingReplacementChars.addAll(
          [UNICODE_REPLACEMENT_CHARACTER_CODEPOINT]);
    }
    Expect.listEquals(matchingReplacementChars,
        utf8ToCodepoints(allFirstFourByteSeq),
        "f0 - f7 + space => replacement character x 8");

    List<int> allFirstFiveByteSeq = <int>[];
    matchingReplacementChars = <int>[];
    for (int i = 0xf8; i < 0xfc; i++) {
      allFirstFiveByteSeq.addAll([i, 0x20]);
      matchingReplacementChars.addAll(
          [UNICODE_REPLACEMENT_CHARACTER_CODEPOINT]);
    }
    Expect.listEquals(matchingReplacementChars,
        utf8ToCodepoints(allFirstFiveByteSeq),
        "f8 - fb + space => replacement character x 4");

    List<int> allFirstSixByteSeq = <int>[];
    matchingReplacementChars = <int>[];
    for (int i = 0xfc; i < 0xfe; i++) {
      allFirstSixByteSeq.addAll([i, 0x20]);
      matchingReplacementChars.addAll(
          [UNICODE_REPLACEMENT_CHARACTER_CODEPOINT]);
    }
    Expect.listEquals(matchingReplacementChars,
        utf8ToCodepoints(allFirstSixByteSeq),
        "fc - fd + space => replacement character x 2");

    // Sequences with last continuation byte missing
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xc2]),
        "2-byte sequence with last byte missing");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xe0, 0x80]),
        "3-byte sequence with last byte missing");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xf0, 0x80, 0x80]),
        "4-byte sequence with last byte missing");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xf8, 0x88, 0x80, 0x80]),
        "5-byte sequence with last byte missing");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xfc, 0x80, 0x80, 0x80, 0x80]),
        "6-byte sequence with last byte missing");

    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xdf]),
        "2-byte sequence with last byte missing (hi)");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xef, 0xbf]),
        "3-byte sequence with last byte missing (hi)");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xf7, 0xbf, 0xbf]),
        "4-byte sequence with last byte missing (hi)");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xfb, 0xbf, 0xbf, 0xbf]),
        "5-byte sequence with last byte missing (hi)");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xfd, 0xbf, 0xbf, 0xbf, 0xbf]),
        "6-byte sequence with last byte missing (hi)");

    // Concatenation of incomplete sequences
    Expect.listEquals(
        [ UNICODE_REPLACEMENT_CHARACTER_CODEPOINT,
          UNICODE_REPLACEMENT_CHARACTER_CODEPOINT,
          UNICODE_REPLACEMENT_CHARACTER_CODEPOINT,
          UNICODE_REPLACEMENT_CHARACTER_CODEPOINT,
          UNICODE_REPLACEMENT_CHARACTER_CODEPOINT,
          UNICODE_REPLACEMENT_CHARACTER_CODEPOINT,
          UNICODE_REPLACEMENT_CHARACTER_CODEPOINT,
          UNICODE_REPLACEMENT_CHARACTER_CODEPOINT,
          UNICODE_REPLACEMENT_CHARACTER_CODEPOINT,
          UNICODE_REPLACEMENT_CHARACTER_CODEPOINT ],
        utf8ToCodepoints(
            [ 0xc2,
              0xe0, 0x80,
              0xf0, 0x80, 0x80,
              0xf8, 0x88, 0x80, 0x80,
              0xfc, 0x80, 0x80, 0x80, 0x80,
              0xdf,
              0xef, 0xbf,
              0xf7, 0xbf, 0xbf,
              0xfb, 0xbf, 0xbf, 0xbf,
              0xfd, 0xbf, 0xbf, 0xbf, 0xbf ]),
            "Concatenation of incomplete sequences");

    // Impossible bytes
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xfe]), "fe");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xff]), "ff");
    Expect.listEquals([
        UNICODE_REPLACEMENT_CHARACTER_CODEPOINT,
        UNICODE_REPLACEMENT_CHARACTER_CODEPOINT,
        UNICODE_REPLACEMENT_CHARACTER_CODEPOINT,
        UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xfe, 0xfe, 0xff, 0xff]), "fe fe ff ff");

    // Overlong sequences
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xc0, 0xaf]), "c0 af");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xe0, 0x80, 0xaf]), "e0 80 af");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xf0, 0x80, 0x80, 0xaf]), "f0 80 80 af");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xf8, 0x80, 0x80, 0x80, 0xaf]), "f8 80 80 80 af");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xfc, 0x80, 0x80, 0x80, 0x80, 0xaf]),
        "fc 80 80 80 80 af");

    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xc1, 0xbf]), "c1 bf");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xe0, 0x9f, 0xbf]), "e0 9f bf");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xf0, 0x8f, 0xbf, 0xbf]), "f0 8f bf bf");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xf8, 0x87, 0xbf, 0xbf, 0xbf]), "f8 87 bf bf bf");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xfc, 0x83, 0xbf, 0xbf, 0xbf, 0xbf]),
        "fc 83 bf bf bf bf");

    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xc0, 0x80]), "c0 80");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xe0, 0x80, 0x80]), "e0 80 80");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xf0, 0x80, 0x80, 0x80]), "f0 80 80 80");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xf8, 0x80, 0x80, 0x80, 0x80]), "f8 80 80 80 80");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xfc, 0x80, 0x80, 0x80, 0x80, 0x80]),
        "fc 80 80 80 80 80");

    // Illegal code positions
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xed, 0xa0, 0x80]), "U+D800");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xed, 0xad, 0xbf]), "U+DB7F");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xed, 0xae, 0x80]), "U+DB80");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xed, 0xaf, 0xbf]), "U+DBFF");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xed, 0xb0, 0x80]), "U+DC00");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xed, 0xbe, 0x80]), "U+DF80");
    Expect.listEquals([UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xed, 0xbf, 0xbf]), "U+DFFF");

    // Paired UTF-16 surrogates
    Expect.listEquals([
        UNICODE_REPLACEMENT_CHARACTER_CODEPOINT,
        UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xed, 0xa0, 0x80, 0xed, 0xb0, 0x80]),
        "U+D800 U+DC00");
    Expect.listEquals([
        UNICODE_REPLACEMENT_CHARACTER_CODEPOINT,
        UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xed, 0xa0, 0x80, 0xed, 0xbf, 0xbf]),
        "U+D800 U+DFFF");
    Expect.listEquals([
        UNICODE_REPLACEMENT_CHARACTER_CODEPOINT,
        UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xed, 0xad, 0xbf, 0xed, 0xb0, 0x80]),
        "U+DB7F U+DC00");
    Expect.listEquals([
        UNICODE_REPLACEMENT_CHARACTER_CODEPOINT,
        UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xed, 0xad, 0xbf, 0xed, 0xbf, 0xbf]),
        "U+DB7F U+DFFF");
    Expect.listEquals([
        UNICODE_REPLACEMENT_CHARACTER_CODEPOINT,
        UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xed, 0xae, 0x80, 0xed, 0xb0, 0x80]),
        "U+DB80 U+DC00");
    Expect.listEquals([
        UNICODE_REPLACEMENT_CHARACTER_CODEPOINT,
        UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xed, 0xae, 0x80, 0xed, 0xbf, 0xbf]),
        "U+DB80 U+DFFF");
    Expect.listEquals([
        UNICODE_REPLACEMENT_CHARACTER_CODEPOINT,
        UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xed, 0xaf, 0xbf, 0xed, 0xb0, 0x80]),
        "U+DBFF U+DC00");
    Expect.listEquals([
        UNICODE_REPLACEMENT_CHARACTER_CODEPOINT,
        UNICODE_REPLACEMENT_CHARACTER_CODEPOINT],
        utf8ToCodepoints([0xed, 0xaf, 0xbf, 0xed, 0xbf, 0xbf]),
        "U+DBFF U+DFFF");

    // Other illegal code positions (???)
    Expect.listEquals([0xfffe], utf8ToCodepoints([0xef, 0xbf, 0xbe]),
        "U+FFFE");
    Expect.listEquals([0xffff], utf8ToCodepoints([0xef, 0xbf, 0xbf]),
        "U+FFFF");
  }

  void testUtf8BytesToString() {
    Expect.stringEquals(testEnglishPhrase,
        decodeUtf8(testEnglishUtf8), "English");

    Expect.stringEquals(testDanishPhrase,
        decodeUtf8(testDanishUtf8), "Danish");

    Expect.stringEquals(testHebrewPhrase,
        decodeUtf8(testHebrewUtf8), "Hebrew");

    Expect.stringEquals(testRussianPhrase,
        decodeUtf8(testRussianUtf8), "Russian");

    Expect.stringEquals(testGreekPhrase,
        decodeUtf8(testGreekUtf8), "Greek");

    Expect.stringEquals(testKatakanaPhrase,
        decodeUtf8(testKatakanaUtf8), "Katakana");
  }

  void testIterableMethods() {
    IterableUtf8Decoder englishDecoder = decodeUtf8AsIterable(testEnglishUtf8);
    // get the first character
    Expect.equals(testEnglishUtf8[0], englishDecoder.first);
    // get the whole translation using the Iterable interface
    Expect.stringEquals(testEnglishPhrase,
        new String.fromCharCodes(new List<int>.from(englishDecoder)));

    IterableUtf8Decoder kataDecoder = decodeUtf8AsIterable(testKatakanaUtf8);
    // get the first character
    Expect.equals(testKatakanaPhrase.codeUnits[0], kataDecoder.first);
    // get the whole translation using the Iterable interface
    Expect.stringEquals(testKatakanaPhrase,
        new String.fromCharCodes(new List<int>.from(kataDecoder)));
  }
}
