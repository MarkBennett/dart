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
package com.google.dart.engine.formatter;

import com.google.dart.engine.ExtendedTestSuite;
import com.google.dart.engine.formatter.edit.EditRecorderTest;
import com.google.dart.engine.formatter.edit.StringEditOperationTest;

import junit.framework.Test;
import junit.framework.TestSuite;

import java.io.IOException;

public class TestAll {

  public static Test suite() throws IOException {
    TestSuite suite = new ExtendedTestSuite("Tests in " + TestAll.class.getPackage().getName());
    suite.addTestSuite(StringEditOperationTest.class);
    suite.addTestSuite(EditRecorderTest.class);
    suite.addTest(CodeFormatterTest.suite());
    return suite;
  }

}
