/*
 * Copyright (c) 2013, the Dart project authors.
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
package com.google.dart.engine.element;

import com.google.dart.engine.EngineTestCase;

import static com.google.dart.engine.element.ElementFactory.classElement;

public class ElementKindTest extends EngineTestCase {
  public void test_of_nonNull() {
    assertSame(ElementKind.CLASS, ElementKind.of(classElement("A")));
  }

  public void test_of_null() {
    assertSame(ElementKind.ERROR, ElementKind.of(null));
  }
}
