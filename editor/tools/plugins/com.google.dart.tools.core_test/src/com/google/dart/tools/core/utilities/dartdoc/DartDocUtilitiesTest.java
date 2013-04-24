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
package com.google.dart.tools.core.utilities.dartdoc;

import com.google.dart.engine.ast.ASTNode;
import com.google.dart.engine.ast.CompilationUnit;
import com.google.dart.engine.ast.visitor.ElementLocator;
import com.google.dart.engine.ast.visitor.NodeLocator;
import com.google.dart.engine.element.Element;
import com.google.dart.engine.element.LibraryElement;
import com.google.dart.engine.resolver.ResolverTestCase;
import com.google.dart.engine.source.Source;

public class DartDocUtilitiesTest extends ResolverTestCase {

  public void test_class_doc() throws Exception {
    ASTNode id = findNodeIn("A", createSource(//
        "/// My class",
        "class A { }"));
    Element element = ElementLocator.locate(id);
    assertEquals("My class\n", DartDocUtilities.getDartDocAsHtml(element));
  }

  public void test_class_doc_2() throws Exception {
    ASTNode id = findNodeIn("A", createSource(//
        "/**",
        " * My class",
        " */",
        "class A { }"));
    Element element = ElementLocator.locate(id);
    assertEquals("My class\n", DartDocUtilities.getDartDocAsHtml(element));
  }

  public void test_class_doc_none() throws Exception {
    ASTNode id = findNodeIn("A", "class A { }");
    Element element = ElementLocator.locate(id);
    assertEquals(null, DartDocUtilities.getDartDocAsHtml(element));
  }

  public void test_class_param__bound_text_summary() throws Exception {
    ASTNode id = findNodeIn("A", "class Z<A extends List> { }");
    Element element = ElementLocator.locate(id);
    assertEquals("<A extends List>", DartDocUtilities.getTextSummary(element));
  }

  public void test_class_param_text_summary() throws Exception {
    ASTNode id = findNodeIn("A", "class Z<A> { }");
    Element element = ElementLocator.locate(id);
    assertEquals("<A>", DartDocUtilities.getTextSummary(element));
  }

  public void test_class_param_text_summary_2() throws Exception {
    ASTNode id = findNodeIn("'foo'", createSource(//
        "x(String s){}",
        "main() { x('foo'); }"));
    Element element = ElementLocator.locate(id);
    assertEquals(null, DartDocUtilities.getTextSummary(element));
  }

  public void test_class_text_summary() throws Exception {
    ASTNode id = findNodeIn("A", "class A { }");
    Element element = ElementLocator.locate(id);
    assertEquals("A", DartDocUtilities.getTextSummary(element));
  }

  public void test_cons_named_text_summary() throws Exception {
    ASTNode id = findNodeIn("A.named", createSource(//
        "class A { ",
        "  A.named(String x){}",
        "}"));
    Element element = ElementLocator.locate(id);
    assertEquals("A.named(String x)", DartDocUtilities.getTextSummary(element));
  }

  public void test_cons_text_summary() throws Exception {
    ASTNode id = findNodeIn("A(", createSource(//
        "class A { ",
        "  A(String x){}",
        "}"));
    Element element = ElementLocator.locate(id);
    assertEquals("A(String x)", DartDocUtilities.getTextSummary(element));
  }

  public void test_method_doc() throws Exception {
    ASTNode id = findNodeIn("x", createSource(//
        "/// My method",
        "int x => 42;"));
    Element element = ElementLocator.locate(id);
    assertEquals("My method\n", DartDocUtilities.getDartDocAsHtml(element));
  }

  public void test_method_named_doc() throws Exception {
    ASTNode id = findNodeIn("x", "void x({String named}) {}");
    Element element = ElementLocator.locate(id);
    assertEquals("void x({String named})", DartDocUtilities.getTextSummary(element));
  }

  public void test_method_named_doc_2() throws Exception {
    ASTNode id = findNodeIn("x", "void x(int unnamed, {String named}) {}");
    Element element = ElementLocator.locate(id);
    assertEquals("void x(int unnamed, {String named})", DartDocUtilities.getTextSummary(element));
  }

  public void test_method_optional_doc() throws Exception {
    ASTNode id = findNodeIn("x", "void x([bool opt = false, bool opt2 = true]) {}");
    Element element = ElementLocator.locate(id);
    assertEquals("void x([bool opt, bool opt2])", DartDocUtilities.getTextSummary(element));
  }

  public void test_param_text_summary() throws Exception {
    ASTNode id = findNodeIn("x", createSource(//
        "class A { ",
        "  A(String x){}",
        "}"));
    Element element = ElementLocator.locate(id);
    assertEquals("String x", DartDocUtilities.getTextSummary(element));
  }

  public void test_var_text() throws Exception {
    ASTNode id = findNodeIn("x", "int x;\n");
    Element element = ElementLocator.locate(id);
    assertEquals("int x", DartDocUtilities.getTextSummary(element));
  }

  private ASTNode findNodeIn(String nodePattern, String... lines) throws Exception {
    String contents = createSource(lines);
    CompilationUnit cu = resolve(contents);
    int start = contents.indexOf(nodePattern);
    int end = start + nodePattern.length();
    return new NodeLocator(start, end).searchWithin(cu);
  }

  private CompilationUnit resolve(String... lines) throws Exception {
    Source source = addSource(createSource(lines));
    LibraryElement library = resolve(source);
    assertNoErrors();
    verify(source);
    return getAnalysisContext().resolveCompilationUnit(source, library);
  }

}
