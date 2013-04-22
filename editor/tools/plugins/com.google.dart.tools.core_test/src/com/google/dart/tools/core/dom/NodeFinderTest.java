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
package com.google.dart.tools.core.dom;

import com.google.common.base.Joiner;
import com.google.common.collect.Lists;
import com.google.dart.compiler.DartCompilationError;
import com.google.dart.compiler.ast.DartIdentifier;
import com.google.dart.compiler.ast.DartNode;
import com.google.dart.compiler.ast.DartUnit;
import com.google.dart.tools.core.model.CompilationUnit;
import com.google.dart.tools.core.test.util.TestProject;
import com.google.dart.tools.core.utilities.compiler.DartCompilerUtilities;

import junit.framework.TestCase;

import static org.fest.assertions.Assertions.assertThat;

import java.util.List;

public class NodeFinderTest extends TestCase {
  private static String makeSource(String... lines) {
    return Joiner.on("\n").join(lines);
  }

  private String source;

  private TestProject testProject;

  public void test_constructor_named_onName() throws Exception {
    source = makeSource(
        "// filler filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  A.named() {",
        "  }",
        "}",
        "");
    DartNode node = findSelectedNode("amed() {");
    assertThat(node).isInstanceOf(DartIdentifier.class);
    assertEquals("named", ((DartIdentifier) node).getName());
  }

  public void test_constructor_named_onType() throws Exception {
    source = makeSource(
        "// filler filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  A.named() {",
        "  }",
        "}",
        "");
    DartNode node = findSelectedNode("A.named() {");
    assertThat(node).isInstanceOf(DartIdentifier.class);
    assertEquals("A", ((DartIdentifier) node).getName());
  }

  public void test_localVariable_onName() throws Exception {
    source = makeSource(
        "// filler filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  foo() {",
        "    var test = 1;",
        "  }",
        "}",
        "");
    DartNode node = findSelectedNode("est =");
    // selected node should be "test"
    assertThat(node).isInstanceOf(DartIdentifier.class);
    assertEquals("test", ((DartIdentifier) node).getName());
  }

  public void test_method_onName() throws Exception {
    source = makeSource(
        "// filler filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  test() {",
        "  }",
        "}",
        "");
    DartNode node = findSelectedNode("est() {");
    // selected node should be "test"
    assertThat(node).isInstanceOf(DartIdentifier.class);
    assertEquals("test", ((DartIdentifier) node).getName());
  }

  @Override
  protected void setUp() throws Exception {
    super.setUp();
    testProject = new TestProject();
  }

  @Override
  protected void tearDown() throws Exception {
    testProject.dispose();
    testProject = null;
    source = null;
    super.tearDown();
  }

  /**
   * @return the {@link DartNode} under position of "pattern".
   */
  private DartNode findSelectedNode(String pattern) throws Exception {
    CompilationUnit unitModel = testProject.setUnitContent("Test.dart", source);
    // prepare position
    int pos = unitModel.getSource().indexOf(pattern);
    assertThat(pos).isNotEqualTo(-1);
    // prepare DartUnit
    DartUnit unitNode;
    {
      List<DartCompilationError> errors = Lists.newArrayList();
      unitNode = DartCompilerUtilities.resolveUnit(unitModel, errors);
      // we don't want errors
      if (!errors.isEmpty()) {
        fail("Parse/resolve errors: " + errors);
      }
    }
    // find selected node
    return NodeFinder.perform(unitNode, pos, 0);
  }
}
