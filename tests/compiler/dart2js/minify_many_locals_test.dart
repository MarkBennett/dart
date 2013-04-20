// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// Test that parameters keep their names in the output.

import "package:expect/expect.dart";
import 'compiler_helper.dart';

main() {
  var buffer = new StringBuffer();
  buffer.write("var foo(");
  for (int i = 0; i < 2000; i++) {
    buffer.write("x$i, ");
  }
  buffer.write("x) { int i = ");
  for (int i = 0; i < 2000; i++) {
    buffer.write("x$i+");
  }
  buffer.write("2000; return i; }");
  var generated = compile(buffer.toString(), entry: 'foo', minify: true);
  RegExp re = new RegExp(r"\(a,b,c");
  Expect.isTrue(re.hasMatch(generated));

  re = new RegExp(r"x,y,z,A,B,C");
  Expect.isTrue(re.hasMatch(generated));
  
  re = new RegExp(r"Y,Z,a0,a1,a2,a3,a4,a5,a6");
  Expect.isTrue(re.hasMatch(generated));

  re = new RegExp(r"g8,g9,h0,h1");
  Expect.isTrue(re.hasMatch(generated));

  re = new RegExp(r"Z8,Z9,aa0,aa1,aa2");
  Expect.isTrue(re.hasMatch(generated));

  re = new RegExp(r"aa9,ab0,ab1");
  Expect.isTrue(re.hasMatch(generated));

  re = new RegExp(r"aZ9,ba0,ba1");
  Expect.isTrue(re.hasMatch(generated));
}
