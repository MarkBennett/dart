// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.google.dart.compiler.end2end;

import com.google.dart.compiler.end2end.inc.IncrementalCompilation2Test;
import com.google.dart.compiler.end2end.inc.IncrementalCompilationTest;
import com.google.dart.compiler.end2end.inc.IncrementalCompilationWithPrefixTest;

import junit.extensions.TestSetup;
import junit.framework.Test;
import junit.framework.TestSuite;

public class End2EndTests extends TestSetup {

  public End2EndTests(TestSuite test) {
    super(test);
  }

  public static Test suite() {
    TestSuite suite = new TestSuite("Dart end-to-end test suite.");
    suite.addTestSuite(IncrementalCompilationTest.class);
    suite.addTestSuite(IncrementalCompilation2Test.class);
    suite.addTestSuite(IncrementalCompilationWithPrefixTest.class);
    return new End2EndTests(suite);
  }
}
