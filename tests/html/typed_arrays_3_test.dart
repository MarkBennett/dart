// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library TypedArrays3Test;
import '../../pkg/unittest/lib/unittest.dart';
import '../../pkg/unittest/lib/html_config.dart';
import 'dart:html';

main() {
  useHtmlConfiguration();

  // Only perform tests if ArrayBuffer is supported.
  if (!Platform.supportsTypedData) {
    return;
  }

  test('setElementsTest_dynamic', () {
      var a1 = new Int8Array(1024);

      a1.setElements([0x50,0x60,0x70], 4);

      var a2 = new Uint32Array.fromBuffer(a1.buffer);
      expect(a2[0], 0x00000000);
      expect(a2[1], 0x00706050);

      a2.setElements([0x01020304], 2);
      expect(a1[8], 0x04);
      expect(a1[11], 0x01);
  });

  test('setElementsTest_typed', () {
      Int8Array a1 = new Int8Array(1024);

      a1.setElements([0x50,0x60,0x70], 4);

      Uint32Array a2 = new Uint32Array.fromBuffer(a1.buffer);
      expect(a2[0], 0x00000000);
      expect(a2[1], 0x00706050);

      a2.setElements([0x01020304], 2);
      expect(a1[8], 0x04);
      expect(a1[11], 0x01);
  });
}
