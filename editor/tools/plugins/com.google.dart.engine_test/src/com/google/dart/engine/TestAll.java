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
package com.google.dart.engine;

import junit.framework.Test;
import junit.framework.TestSuite;

public class TestAll {
  public static Test suite() {
    TestSuite suite = new ExtendedTestSuite("Tests in " + TestAll.class.getPackage().getName());
    suite.addTestSuite(AnalysisEngineTest.class);
    suite.addTest(com.google.dart.engine.ast.TestAll.suite());
    suite.addTest(com.google.dart.engine.constant.TestAll.suite());
    suite.addTest(com.google.dart.engine.error.TestAll.suite());
    suite.addTest(com.google.dart.engine.html.TestAll.suite());
    suite.addTest(com.google.dart.engine.index.TestAll.suite());
    suite.addTest(com.google.dart.engine.internal.TestAll.suite());
    suite.addTest(com.google.dart.engine.parser.TestAll.suite());
    suite.addTest(com.google.dart.engine.resolver.TestAll.suite());
    suite.addTest(com.google.dart.engine.scanner.TestAll.suite());
    suite.addTest(com.google.dart.engine.sdk.TestAll.suite());
    suite.addTest(com.google.dart.engine.search.TestAll.suite());
    suite.addTest(com.google.dart.engine.source.TestAll.suite());
    suite.addTest(com.google.dart.engine.utilities.TestAll.suite());
    return suite;
  }
}
