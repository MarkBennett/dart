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
package com.google.dart.engine.resolver;

import com.google.dart.engine.element.ClassElement;
import com.google.dart.engine.element.CompilationUnitElement;
import com.google.dart.engine.element.LibraryElement;
import com.google.dart.engine.error.StaticTypeWarningCode;
import com.google.dart.engine.source.Source;

public class SimpleResolverTest extends ResolverTestCase {
  public void fail_staticInvocation() throws Exception {
    Source source = addSource(createSource(//
        "class A {",
        "  static int get g => (a,b) => 0;",
        "}",
        "class B {",
        "  f() {",
        "    A.g(1,0);",
        "  }",
        "}"));
    resolve(source);
    assertNoErrors();
    verify(source);
  }

  public void test_class_definesCall() throws Exception {
    Source source = addSource(createSource(//
        "class A {",
        "  int call(int x) { return x; }",
        "}",
        "int f(A a) {",
        "  return a(0);",
        "}"));
    resolve(source);
    assertNoErrors();
    verify(source);
  }

  public void test_class_extends_implements() throws Exception {
    Source source = addSource(createSource(//
        "class A extends B implements C {}",
        "class B {}",
        "class C {}"));
    resolve(source);
    assertNoErrors();
    verify(source);
  }

  public void test_commentReference_class() throws Exception {
    Source source = addSource(createSource(//
        "f() {}",
        "/** [A] [new A] [A.n] [new A.n] [m] [f] */",
        "class A {",
        "  A() {}",
        "  A.n() {}",
        "  m() {}",
        "}"));
    resolve(source);
    assertNoErrors();
    verify(source);
  }

  public void test_commentReference_parameter() throws Exception {
    Source source = addSource(createSource(//
        "class A {",
        "  A() {}",
        "  A.n() {}",
        "  /** [e] [f] */",
        "  m(e, f()) {}",
        "}"));
    resolve(source);
    assertNoErrors();
    verify(source);
  }

  public void test_commentReference_singleLine() throws Exception {
    Source source = addSource(createSource(//
        "/// [A]",
        "class A {}"));
    resolve(source);
    assertNoErrors();
    verify(source);
  }

  public void test_empty() throws Exception {
    Source source = addSource("");
    resolve(source);
    assertNoErrors();
    verify(source);
  }

  public void test_extractedMethodAsConstant() throws Exception {
    Source source = addSource(createSource(//
        "abstract class Comparable<T> {",
        "  int compareTo(T other);",
        "  static int compare(Comparable a, Comparable b) => a.compareTo(b);",
        "}",
        "class A {",
        "  void sort([compare = Comparable.compare]) {}",
        "}"));
    resolve(source);
    assertNoErrors();
    verify(source);
  }

  public void test_fieldFormalParameter() throws Exception {
    Source source = addSource(createSource(//
        "class A {",
        "  int x;",
        "  A(this.x) {}",
        "}"));
    resolve(source);
    assertNoErrors();
    verify(source);
  }

  public void test_forEachLoops_nonConflicting() throws Exception {
    Source source = addSource(createSource(//
        "f() {",
        "  List list = [1,2,3];",
        "  for (int x in list) {}",
        "  for (int x in list) {}",
        "}"));
    resolve(source);
    assertNoErrors();
    verify(source);
  }

  public void test_forLoops_nonConflicting() throws Exception {
    Source source = addSource(createSource(//
        "f() {",
        "  for (int i = 0; i < 3; i++) {",
        "  }",
        "  for (int i = 0; i < 3; i++) {",
        "  }",
        "}"));
    resolve(source);
    assertNoErrors();
    verify(source);
  }

  public void test_functionTypeAlias() throws Exception {
    Source source = addSource(createSource(//
        "typedef bool P(e);",
        "class A {",
        "  P p;",
        "  m(e) {",
        "    if (p(e)) {}",
        "  }",
        "}"));
    resolve(source);
    assertNoErrors();
    verify(source);
  }

  public void test_getterAndSetterWithDifferentTypes() throws Exception {
    Source source = addSource(createSource(//
        "class A {",
        "  int get f => 0;",
        "  void set f(String s) {}",
        "}",
        "g (A a) {",
        "  a.f = a.f.toString();",
        "}"));
    resolve(source);
    assertNoErrors();
    verify(source);
  }

  public void test_hasReferenceToSuper() throws Exception {
    Source source = addSource(createSource(//
        "class A {}",
        "class B {toString() => super.toString()}"));
    LibraryElement library = resolve(source);
    assertNotNull(library);
    CompilationUnitElement unit = library.getDefiningCompilationUnit();
    assertNotNull(unit);
    ClassElement[] classes = unit.getTypes();
    assertLength(2, classes);
    assertFalse(classes[0].hasReferenceToSuper());
    assertTrue(classes[1].hasReferenceToSuper());
    assertNoErrors();
    verify(source);
  }

  public void test_importWithPrefix() throws Exception {
    addSource("/two.dart", createSource(//
        "library two;",
        "f(int x) {",
        "  return x * x;",
        "}"));
    Source source = addSource("/one.dart", createSource(//
        "library one;",
        "import 'two.dart' as _two;",
        "main() {",
        "  _two.f(0);",
        "}"));
    resolve(source);
    assertNoErrors();
    verify(source);
  }

  public void test_indexExpression_typeParameters() throws Exception {
    Source source = addSource(createSource(//
        "f() {",
        "  List<int> a;",
        "  a[0];",
        "  List<List<int>> b;",
        "  b[0][0];",
        "  List<List<List<int>>> c;",
        "  c[0][0][0];",
        "}"));
    resolve(source);
    assertNoErrors();
    verify(source);
  }

  public void test_indexExpression_typeParameters_invalidAssignmentWarning() throws Exception {
    Source source = addSource(createSource(//
        "f() {",
        "  List<List<int>> b;",
        "  b[0][0] = 'hi';",
        "}"));
    resolve(source);
    assertErrors(StaticTypeWarningCode.INVALID_ASSIGNMENT);
    verify(source);
  }

  public void test_invoke_dynamicThroughGetter() throws Exception {
    Source source = addSource(createSource(//
        "class A {",
        "  List get X => [() => 0];",
        "  m(A a) {",
        "    X.last;",
        "  }",
        "}"));
    resolve(source);
    assertNoErrors();
    verify(source);
  }

  public void test_isValidMixin_badSuperclass() throws Exception {
    Source source = addSource(createSource(//
        "class A extends B {}",
        "class B {}"));
    LibraryElement library = resolve(source);
    assertNotNull(library);
    CompilationUnitElement unit = library.getDefiningCompilationUnit();
    assertNotNull(unit);
    ClassElement[] classes = unit.getTypes();
    assertLength(2, classes);
    assertFalse(classes[0].isValidMixin());
    assertNoErrors();
    verify(source);
  }

  public void test_isValidMixin_constructor() throws Exception {
    Source source = addSource(createSource(//
        "class A {",
        "  A() {}",
        "}"));
    LibraryElement library = resolve(source);
    assertNotNull(library);
    CompilationUnitElement unit = library.getDefiningCompilationUnit();
    assertNotNull(unit);
    ClassElement[] classes = unit.getTypes();
    assertLength(1, classes);
    assertFalse(classes[0].isValidMixin());
    assertNoErrors();
    verify(source);
  }

  public void test_isValidMixin_super() throws Exception {
    Source source = addSource(createSource(//
        "class A {",
        "  toString() {",
        "    return super.toString();",
        "  }",
        "}"));
    LibraryElement library = resolve(source);
    assertNotNull(library);
    CompilationUnitElement unit = library.getDefiningCompilationUnit();
    assertNotNull(unit);
    ClassElement[] classes = unit.getTypes();
    assertLength(1, classes);
    assertFalse(classes[0].isValidMixin());
    assertNoErrors();
    verify(source);
  }

  public void test_isValidMixin_valid() throws Exception {
    Source source = addSource(createSource(//
    "class A {}"));
    LibraryElement library = resolve(source);
    assertNotNull(library);
    CompilationUnitElement unit = library.getDefiningCompilationUnit();
    assertNotNull(unit);
    ClassElement[] classes = unit.getTypes();
    assertLength(1, classes);
    assertTrue(classes[0].isValidMixin());
    assertNoErrors();
    verify(source);
  }

  public void test_method_fromSuperclassMixin() throws Exception {
    Source source = addSource(createSource(//
        "class A {",
        "  void m1() {}",
        "}",
        "class B with A {",
        "}",
        "class C extends B {",
        "}",
        "f(C c) {",
        "  c.m1()",
        "}"));
    resolve(source);
    assertNoErrors();
    verify(source);
  }

  public void test_methodCascades() throws Exception {
    Source source = addSource(createSource(//
        "class A {",
        "  void m1() {}",
        "  void m2() {}",
        "  void m() {",
        "    A a = new A();",
        "    a..m1()",
        "     ..m2();",
        "  }",
        "}"));
    resolve(source);
    assertNoErrors();
    verify(source);
  }

  public void test_methodCascades_withSetter() throws Exception {
    Source source = addSource(createSource(//
        "class A {",
        "  String name;",
        "  void m1() {}",
        "  void m2() {}",
        "  void m() {",
        "    A a = new A();",
        "    a..m1()",
        "     ..name = 'name'",
        "     ..m2();",
        "  }",
        "}"));
    resolve(source);
    // failing with error code: INVOCATION_OF_NON_FUNCTION
    assertNoErrors();
    verify(source);
  }

  public void test_resolveAgainstNull() throws Exception {
    Source source = addSource(createSource(//
        "f(var p) {",
        "  return null == p;",
        "}"));
    resolve(source);
    assertNoErrors();
    verify(source);
  }
}
