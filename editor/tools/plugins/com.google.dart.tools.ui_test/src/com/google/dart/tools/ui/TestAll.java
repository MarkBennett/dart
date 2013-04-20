/*
 * Copyright (c) 2012, the Dart project authors.
 * 
 * Licensed under the Eclipse Public License v1.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 * 
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */
package com.google.dart.tools.ui;

import junit.framework.Test;
import junit.framework.TestSuite;

public class TestAll {

  public static Test refactoringCleanupSuite() {
    TestSuite suite = new TestSuite("Tests in " + TestAll.class.getPackage().getName());
    suite.addTest(com.google.dart.tools.ui.refactoring.TestAll.suite());
    suite.addTest(com.google.dart.tools.ui.cleanup.TestAll.suite());
    return suite;
  }

  public static Test suite() {
    TestSuite suite = new TestSuite("Tests in " + TestAll.class.getPackage().getName());
    suite.addTestSuite(DartUiTest.class);
    suite.addTest(com.google.dart.tools.ui.internal.TestAll.suite());
    suite.addTest(com.google.dart.tools.ui.actions.TestAll.suite());
    suite.addTest(com.google.dart.tools.ui.cleanup.TestAll.suite());
    suite.addTest(com.google.dart.tools.ui.correction.TestAll.suite());
    suite.addTest(com.google.dart.tools.ui.feedback.TestAll.suite());
    suite.addTest(com.google.dart.tools.ui.instrumentation.TestAll.suite());
    suite.addTest(com.google.dart.tools.ui.refactoring.TestAll.suite());
    return suite;
  }
}
