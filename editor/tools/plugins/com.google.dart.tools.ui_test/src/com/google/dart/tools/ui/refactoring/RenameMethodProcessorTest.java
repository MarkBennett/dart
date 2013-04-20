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
package com.google.dart.tools.ui.refactoring;

import com.google.dart.tools.core.model.CompilationUnit;
import com.google.dart.tools.core.model.Method;
import com.google.dart.tools.internal.corext.refactoring.rename.RenameFieldProcessor;
import com.google.dart.tools.internal.corext.refactoring.rename.RenameMethodProcessor;
import com.google.dart.tools.ui.internal.refactoring.RenameSupport_OLD;

import org.eclipse.ltk.core.refactoring.RefactoringStatus;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;

import static org.fest.assertions.Assertions.assertThat;

/**
 * Test for {@link RenameMethodProcessor}.
 */
public final class RenameMethodProcessorTest extends RefactoringTest {
  /**
   * Uses {@link RenameSupport_OLD} to rename {@link Method}.
   */
  private static void renameMethod(Method method, String newName) throws Exception {
    RenameSupport_OLD renameSupport = RenameSupport_OLD.create(method, newName);
    IWorkbenchWindow workbenchWindow = PlatformUI.getWorkbench().getActiveWorkbenchWindow();
    renameSupport.perform(workbenchWindow.getShell(), workbenchWindow);
  }

  /**
   * Just for coverage of {@link RenameFieldProcessor} accessors.
   */
  public void test_accessors() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  test() {}",
        "}");
    Method method = findElement("test() {}");
    // do check
    RenameMethodProcessor processor = new RenameMethodProcessor(method);
    assertEquals(RenameMethodProcessor.IDENTIFIER, processor.getIdentifier());
    assertEquals("test", processor.getCurrentElementName());
  }

  public void test_badNewName_alreadyNamed() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  test() {}",
        "}");
    Method method = findElement("test() {");
    // try to rename
    String source = testUnit.getSource();
    try {
      renameMethod(method, "test");
      fail();
    } catch (InterruptedException e) {
    }
    // error should be displayed
    assertThat(openInformationMessages).isEmpty();
    assertThat(showStatusMessages).hasSize(1);
    assertEquals(RefactoringStatus.FATAL, showStatusSeverities.get(0).intValue());
    assertEquals("Choose another name.", showStatusMessages.get(0));
    // no source changes
    assertEquals(source, testUnit.getSource());
  }

  public void test_badNewName_enclosingTypeHasField() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  test() {}",
        "  int newName = 2;",
        "}");
    Method method = findElement("test() {}");
    // try to rename
    String source = testUnit.getSource();
    try {
      renameMethod(method, "newName");
      fail();
    } catch (InterruptedException e) {
    }
    // error should be displayed
    assertThat(openInformationMessages).isEmpty();
    assertThat(showStatusMessages).hasSize(1);
    assertEquals(RefactoringStatus.ERROR, showStatusSeverities.get(0).intValue());
    assertEquals(
        "Enclosing type 'A' in 'Test/Test.dart' already declares member with name 'newName'",
        showStatusMessages.get(0));
    // no source changes
    assertEquals(source, testUnit.getSource());
  }

  public void test_badNewName_enclosingTypeHasMethod() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  test() {}",
        "  newName() {}",
        "}");
    Method method = findElement("test() {}");
    // try to rename
    String source = testUnit.getSource();
    try {
      renameMethod(method, "newName");
      fail();
    } catch (InterruptedException e) {
    }
    // error should be displayed
    assertThat(openInformationMessages).isEmpty();
    assertThat(showStatusMessages).hasSize(1);
    assertEquals(RefactoringStatus.ERROR, showStatusSeverities.get(0).intValue());
    assertEquals(
        "Enclosing type 'A' in 'Test/Test.dart' already declares member with name 'newName'",
        showStatusMessages.get(0));
    // no source changes
    assertEquals(source, testUnit.getSource());
  }

  public void test_badNewName_shouldBeLowerCase() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  test() {}",
        "}");
    Method method = findElement("test() {}");
    // try to rename
    showStatusCancel = false;
    renameMethod(method, "NewName");
    // warning should be displayed
    assertThat(openInformationMessages).isEmpty();
    assertThat(showStatusMessages).hasSize(1);
    assertEquals(RefactoringStatus.WARNING, showStatusSeverities.get(0).intValue());
    assertEquals(
        "By convention, method names usually start with a lowercase letter",
        showStatusMessages.get(0));
    // status was warning, so rename was done
    assertTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  NewName() {}",
        "}");
  }

  public void test_methodCall() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  call() {}",
        "}");
    Method method = findElement("call() {}");
    // try to rename
    try {
      renameMethod(method, "newName");
      fail();
    } catch (InterruptedException e) {
    }
    // error should be displayed
    assertThat(openInformationMessages).isEmpty();
    assertThat(showStatusMessages).hasSize(1);
    assertEquals(RefactoringStatus.FATAL, showStatusSeverities.get(0).intValue());
    assertEquals("Method 'call' cannot be renamed", showStatusMessages.get(0));
  }

  public void test_OK_getter() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  int get test {",
        "    return 42;",
        "  }",
        "}",
        "f() {",
        "  A a = new A();",
        "  print(a.test);",
        "}",
        "");
    Method method = findElement("test {");
    // do rename
    renameMethod(method, "newName");
    assertTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  int get newName {",
        "    return 42;",
        "  }",
        "}",
        "f() {",
        "  A a = new A();",
        "  print(a.newName);",
        "}",
        "");
  }

  public void test_OK_inexactReferences() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  test() {}",
        "}",
        "f1(A a) {",
        "  a.test();",
        "}",
        "f2(a) {",
        "  a.test();",
        "}",
        "");
    Method method = findElement("test() {}");
    // do rename
    renameMethod(method, "newName");
    assertTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  newName() {}",
        "}",
        "f1(A a) {",
        "  a.newName();",
        "}",
        "f2(a) {",
        "  a.newName();",
        "}",
        "");
  }

  public void test_OK_multipleUnits_onReference() throws Exception {
    setUnitContent(
        "Test1.dart",
        formatLines(
            "// filler filler filler filler filler filler filler filler filler filler",
            "part of test;",
            "class A {",
            "  test(var p) {}",
            "  int bar = 2;",
            "  f1() {",
            "    test(3);",
            "    bar = 4;",
            "  }",
            "}"));
    setUnitContent(
        "Test2.dart",
        formatLines(
            "// filler filler filler filler filler filler filler filler filler filler",
            "part of test;",
            "f2() {",
            "  A a = new A();",
            "  a.test(5);",
            "}"));
    setUnitContent(
        "Test3.dart",
        formatLines(
            "// filler filler filler filler filler filler filler filler filler filler",
            "part of test;",
            "class B extends A {",
            "  f3() {",
            "    test(6);",
            "  }",
            "}"));
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "library test;",
        "part 'Test1.dart';",
        "part 'Test2.dart';",
        "part 'Test3.dart';");
    // get units, because they have not library
    CompilationUnit unit1 = testProject.getUnit("Test1.dart");
    CompilationUnit unit2 = testProject.getUnit("Test2.dart");
    CompilationUnit unit3 = testProject.getUnit("Test3.dart");
    // find Field to rename
    Method method = findElement(unit2, "test(5);");
    // do rename
    renameMethod(method, "newName");
    assertUnitContent(
        unit1,
        formatLines(
            "// filler filler filler filler filler filler filler filler filler filler",
            "part of test;",
            "class A {",
            "  newName(var p) {}",
            "  int bar = 2;",
            "  f1() {",
            "    newName(3);",
            "    bar = 4;",
            "  }",
            "}"));
    assertUnitContent(
        unit2,
        formatLines(
            "// filler filler filler filler filler filler filler filler filler filler",
            "part of test;",
            "f2() {",
            "  A a = new A();",
            "  a.newName(5);",
            "}"));
    assertUnitContent(
        unit3,
        formatLines(
            "// filler filler filler filler filler filler filler filler filler filler",
            "part of test;",
            "class B extends A {",
            "  f3() {",
            "    newName(6);",
            "  }",
            "}"));
  }

  public void test_OK_namedConstructor_newName() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  A.test() {}",
        "}",
        "class B extends A {",
        "  B() : super.test() {}",
        "}",
        "main() {",
        "  new A.test();",
        "}");
    Method method = findElement("test() {}");
    // do rename
    renameMethod(method, "newName");
    assertTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  A.newName() {}",
        "}",
        "class B extends A {",
        "  B() : super.newName() {}",
        "}",
        "main() {",
        "  new A.newName();",
        "}");
  }

  /**
   * When we rename method, it should be renamed in super-types and sub-types.
   */
  public void test_OK_renameHierarchy_onSubType() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  test() {}",
        "}",
        "class B extends A {",
        "}",
        "class C extends B {",
        "  test() {} // marker",
        "}",
        "f() {",
        "  A a = new A();",
        "  B b = new B();",
        "  C c = new C();",
        "  a.test();",
        "  b.test();",
        "  c.test();",
        "}",
        "");
    Method method = findElement("test() {} // marker");
    // do rename
    renameMethod(method, "newName");
    assertTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  newName() {}",
        "}",
        "class B extends A {",
        "}",
        "class C extends B {",
        "  newName() {} // marker",
        "}",
        "f() {",
        "  A a = new A();",
        "  B b = new B();",
        "  C c = new C();",
        "  a.newName();",
        "  b.newName();",
        "  c.newName();",
        "}",
        "");
  }

  /**
   * When we rename method, it should be renamed in super-types and sub-types.
   */
  public void test_OK_renameHierarchy_onSuperType() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  test() {} // marker",
        "}",
        "class B extends A {",
        "}",
        "class C extends B {",
        "  test() {}",
        "}",
        "f() {",
        "  A a = new A();",
        "  B b = new B();",
        "  C c = new C();",
        "  a.test();",
        "  b.test();",
        "  c.test();",
        "}",
        "");
    Method method = findElement("test() {} // marker");
    // do rename
    renameMethod(method, "newName");
    assertTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  newName() {} // marker",
        "}",
        "class B extends A {",
        "}",
        "class C extends B {",
        "  newName() {}",
        "}",
        "f() {",
        "  A a = new A();",
        "  B b = new B();",
        "  C c = new C();",
        "  a.newName();",
        "  b.newName();",
        "  c.newName();",
        "}",
        "");
  }

  public void test_OK_setter() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  void set test(x) {",
        "  }",
        "}",
        "f() {",
        "  A a = new A();",
        "  a.test = 42;",
        "}",
        "");
    Method method = findElement("test = 42;");
    // do rename
    renameMethod(method, "newName");
    assertTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  void set newName(x) {",
        "  }",
        "}",
        "f() {",
        "  A a = new A();",
        "  a.newName = 42;",
        "}",
        "");
  }

  public void test_OK_singleUnit_onDeclaration() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  test(var p) {}",
        "  int bar = 2;",
        "  f1() {",
        "    test(3);",
        "    bar = 4;",
        "  }",
        "}",
        "f2() {",
        "  A a = new A();",
        "  a.test(5);",
        "}",
        "class B extends A {",
        "  f3() {",
        "    test(6);",
        "  }",
        "}");
    Method method = findElement("test(var p) {}");
    // do rename
    renameMethod(method, "newName");
    assertTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  newName(var p) {}",
        "  int bar = 2;",
        "  f1() {",
        "    newName(3);",
        "    bar = 4;",
        "  }",
        "}",
        "f2() {",
        "  A a = new A();",
        "  a.newName(5);",
        "}",
        "class B extends A {",
        "  f3() {",
        "    newName(6);",
        "  }",
        "}");
  }

  public void test_OK_singleUnit_onReference() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  test(var p) {}",
        "  int bar = 2;",
        "  f1() {",
        "    test(3);",
        "    bar = 4;",
        "  }",
        "}",
        "f2() {",
        "  A a = new A();",
        "  a.test(5);",
        "}",
        "class B extends A {",
        "  f3() {",
        "    test(6);",
        "  }",
        "}");
    Method method = findElement("test(5);");
    // do rename
    renameMethod(method, "newName");
    assertTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  newName(var p) {}",
        "  int bar = 2;",
        "  f1() {",
        "    newName(3);",
        "    bar = 4;",
        "  }",
        "}",
        "f2() {",
        "  A a = new A();",
        "  a.newName(5);",
        "}",
        "class B extends A {",
        "  f3() {",
        "    newName(6);",
        "  }",
        "}");
  }

  public void test_OK_singleUnit_onReference_inSubClass() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  test() {}",
        "}",
        "class B extends A {",
        "  f() {",
        "    test();",
        "  }",
        "}");
    Method method = findElement("test();");
    // do rename
    renameMethod(method, "newName");
    assertTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  newName() {}",
        "}",
        "class B extends A {",
        "  f() {",
        "    newName();",
        "  }",
        "}");
  }

  public void test_OK_singleUnit_onReference_targetTypePropagated() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  test() {}",
        "}",
        "f2() {",
        "  var a = new A();",
        "  a.test();",
        "}",
        "");
    Method method = findElement("test();");
    // do rename
    renameMethod(method, "newName");
    assertTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  newName() {}",
        "}",
        "f2() {",
        "  var a = new A();",
        "  a.newName();",
        "}",
        "");
  }

  /**
   * We should be able to rename not only method invocations, but also method references.
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=4572
   */
  public void test_OK_staticReference() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  static test() {}",
        "}",
        "process(p) {}",
        "main() {",
        "  process(A.test);",
        "}",
        "");
    Method method = findElement("test() {");
    // do rename
    renameMethod(method, "newName");
    assertTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  static newName() {}",
        "}",
        "process(p) {}",
        "main() {",
        "  process(A.newName);",
        "}",
        "");
  }

  public void test_OK_updateComment_constructor() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "/** Create using [new A.test] constructor. */",
        "class A {",
        "  A.test() {}",
        "}",
        "");
    Method method = findElement("test() {}");
    // do rename
    renameMethod(method, "newName");
    assertTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "/** Create using [new A.newName] constructor. */",
        "class A {",
        "  A.newName() {}",
        "}",
        "");
  }

  public void test_OK_updateInComment_method() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "/** After creation call [test]. */",
        "class A {",
        "  test() {}",
        "}",
        "");
    Method method = findElement("test() {}");
    // do rename
    renameMethod(method, "newName");
    assertTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "/** After creation call [newName]. */",
        "class A {",
        "  newName() {}",
        "}",
        "");
  }

  public void test_postCondition_element_shadowedBy_localVariable() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  test() {}",
        "  foo() {",
        "    var newName;",
        "    test();",
        "  }",
        "}",
        "");
    Method method = findElement("test() {}");
    // try to rename
    String source = testUnit.getSource();
    try {
      renameMethod(method, "newName");
      fail();
    } catch (InterruptedException e) {
    }
    // error should be displayed
    assertThat(openInformationMessages).isEmpty();
    {
      assertThat(showStatusMessages).hasSize(2);
      // warning for variable declaration
      assertEquals(RefactoringStatus.WARNING, showStatusSeverities.get(0).intValue());
      assertEquals(
          "Declaration of renamed method will be shadowed by variable in method 'A.foo()' in file 'Test/Test.dart'",
          showStatusMessages.get(0));
      // error for field usage
      assertEquals(RefactoringStatus.ERROR, showStatusSeverities.get(1).intValue());
      assertEquals(
          "Usage of renamed method will be shadowed by variable in method 'A.foo()' in file 'Test/Test.dart'",
          showStatusMessages.get(1));
    }
    // no source changes
    assertEquals(source, testUnit.getSource());
  }

  public void test_postCondition_element_shadowedBy_subTypeMember() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  test() {}",
        "}",
        "class B extends A {",
        "}",
        "class C extends B {",
        "  newName() {}",
        "  f() {",
        "    test();",
        "  }",
        "}",
        "");
    Method method = findElement("test() {}");
    // try to rename
    String source = testUnit.getSource();
    try {
      renameMethod(method, "newName");
      fail();
    } catch (InterruptedException e) {
    }
    // error should be displayed
    assertThat(openInformationMessages).isEmpty();
    {
      assertThat(showStatusMessages).hasSize(2);
      // warning for sub-type method declaration
      assertEquals(RefactoringStatus.WARNING, showStatusSeverities.get(0).intValue());
      assertEquals(
          "Declaration of renamed method will be shadowed by method 'C.newName' in 'Test/Test.dart'",
          showStatusMessages.get(0));
      // error for field usage
      assertEquals(RefactoringStatus.ERROR, showStatusSeverities.get(1).intValue());
      assertEquals(
          "Usage of renamed method will be shadowed by method 'C.newName' in 'Test/Test.dart'",
          showStatusMessages.get(1));
    }
    // no source changes
    assertEquals(source, testUnit.getSource());
  }

  public void test_postCondition_element_shadowedBy_topLevel() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  test() {}",
        "}",
        "class B extends A {",
        "  f() {",
        "    test();",
        "  }",
        "}",
        "class newName {}",
        "");
    Method method = findElement("test() {}");
    // try to rename
    String source = testUnit.getSource();
    try {
      renameMethod(method, "newName");
      fail();
    } catch (InterruptedException e) {
    }
    // error should be displayed
    assertThat(openInformationMessages).isEmpty();
    {
      assertThat(showStatusMessages).hasSize(2);
      // warning for field declaration
      assertEquals(RefactoringStatus.WARNING, showStatusSeverities.get(0).intValue());
      assertEquals(
          "Declaration of type 'newName' in file 'Test/Test.dart' in library 'Test' will be shadowed by renamed method",
          showStatusMessages.get(0));
      // error for type usage
      assertEquals(RefactoringStatus.ERROR, showStatusSeverities.get(1).intValue());
      assertEquals(
          "Usage of method 'A.test' will be shadowed by top-level type 'newName' from 'Test/Test.dart' in library 'Test'",
          showStatusMessages.get(1));
    }
    // no source changes
    assertEquals(source, testUnit.getSource());
  }

  public void test_postCondition_element_shadows_superTypeMember() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  newName() {}",
        "}",
        "class B extends A {",
        "}",
        "class C extends B {",
        "  test() {}",
        "  f() {",
        "    newName();",
        "  }",
        "}",
        "");
    Method method = findElement("test() {}");
    // try to rename
    String source = testUnit.getSource();
    try {
      renameMethod(method, "newName");
      fail();
    } catch (InterruptedException e) {
    }
    // error should be displayed
    assertThat(openInformationMessages).isEmpty();
    {
      assertThat(showStatusMessages).hasSize(2);
      // warning for field declaration
      assertEquals(RefactoringStatus.WARNING, showStatusSeverities.get(0).intValue());
      assertEquals(
          "Declaration of method 'A.newName' in 'Test/Test.dart' will be shadowed by renamed method",
          showStatusMessages.get(0));
      // error for super-type member usage
      assertEquals(RefactoringStatus.ERROR, showStatusSeverities.get(1).intValue());
      assertEquals(
          "Usage of method 'A.newName' declared in 'Test/Test.dart' will be shadowed by renamed method",
          showStatusMessages.get(1));
    }
    // no source changes
    assertEquals(source, testUnit.getSource());
  }

  public void test_postCondition_element_shadows_topLevel() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  test() {}",
        "  f() {",
        "    new newName();",
        "  }",
        "}",
        "class newName {}",
        "");
    Method method = findElement("test() {}");
    // try to rename
    String source = testUnit.getSource();
    try {
      renameMethod(method, "newName");
      fail();
    } catch (InterruptedException e) {
    }
    // error should be displayed
    assertThat(openInformationMessages).isEmpty();
    {
      assertThat(showStatusMessages).hasSize(2);
      // warning for field declaration
      assertEquals(RefactoringStatus.WARNING, showStatusSeverities.get(0).intValue());
      assertEquals(
          "Declaration of type 'newName' in file 'Test/Test.dart' in library 'Test' will be shadowed by renamed method",
          showStatusMessages.get(0));
      // error for type usage
      assertEquals(RefactoringStatus.ERROR, showStatusSeverities.get(1).intValue());
      assertEquals(
          "Usage of type 'newName' in file 'Test/Test.dart' in library 'Test' will be shadowed by renamed method",
          showStatusMessages.get(1));
    }
    // no source changes
    assertEquals(source, testUnit.getSource());
  }

  public void test_preCondition_hasCompilationErrors() throws Exception {
    setTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  test(var p) {}",
        "  f1() {",
        "    test(0);",
        "  }",
        "}",
        "somethingBad");
    waitForErrorMarker(testUnit);
    Method method = findElement("test(var p) {");
    // try to rename
    showStatusCancel = false;
    renameMethod(method, "newName");
    // warning should be displayed
    assertThat(openInformationMessages).isEmpty();
    assertThat(showStatusMessages).hasSize(1);
    assertEquals(RefactoringStatus.WARNING, showStatusSeverities.get(0).intValue());
    assertEquals(
        "Code modification may not be accurate as affected resource 'Test/Test.dart' has compile errors.",
        showStatusMessages.get(0));
    // status was warning, so rename was done
    assertTestUnitContent(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  newName(var p) {}",
        "  f1() {",
        "    newName(0);",
        "  }",
        "}",
        "somethingBad");
  }
}
