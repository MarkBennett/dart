// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
package com.google.dart.compiler.resolver;

import com.google.dart.compiler.CompilerTestCase;
import com.google.dart.compiler.DartCompilationError;
import com.google.dart.compiler.ast.DartFunctionTypeAlias;
import com.google.dart.compiler.ast.DartThisExpression;
import com.google.dart.compiler.ast.DartTypeParameter;
import com.google.dart.compiler.ast.DartUnit;
import com.google.dart.compiler.common.ErrorExpectation;
import com.google.dart.compiler.testing.TestCompilerContext;
import com.google.dart.compiler.type.Type;

import static com.google.dart.compiler.common.ErrorExpectation.assertErrors;
import static com.google.dart.compiler.common.ErrorExpectation.errEx;

import java.util.ArrayList;
import java.util.List;

public class NegativeResolverTest extends CompilerTestCase {
  List<DartCompilationError> errors = new ArrayList<DartCompilationError>();

  /**
   * Parses given Dart source, runs {@link Resolver} and checks that expected errors were generated.
   */
  public void checkSourceErrors(String source, ErrorExpectation... expectedErrors) {
    DartUnit unit = parseUnit("Test.dart", source);
    resolve(unit);
    assertErrors(errors, expectedErrors);
  }

  public void checkSourceErrorsAsSystemLibrary(String source, ErrorExpectation... expectedErrors) {
    DartUnit unit = parseUnitAsSystemLibrary("Test.dart", source);
    resolve(unit);
    assertErrors(errors, expectedErrors);
  }


  /**
   * Parses given Dart file, runs {@link Resolver} and checks that expected errors were generated.
   */
  public void checkFileErrors(String source, ErrorExpectation... expectedErrors) {
    DartUnit unit = parseUnit(source);
    resolve(unit);
    assertErrors(errors, expectedErrors);
  }

  public void checkNumErrors(String fileName, int expectedErrorCount) {
    DartUnit unit = parseUnit(fileName);
    resolve(unit);
    if (errors.size() != expectedErrorCount) {
      fail(String.format(
          "Expected %s errors, but got %s: %s",
          expectedErrorCount,
          errors.size(),
          errors));
    }
  }

  private void resolve(DartUnit unit) {
    unit.getTopLevelNodes().add(ResolverTestCase.makeClass("bool", null));
    unit.getTopLevelNodes().add(ResolverTestCase.makeClass("num", null));
    unit.getTopLevelNodes().add(ResolverTestCase.makeClass("double", null));
    unit.getTopLevelNodes().add(ResolverTestCase.makeClass("int", null));
    unit.getTopLevelNodes().add(ResolverTestCase.makeClass("Object", null));
    unit.getTopLevelNodes().add(ResolverTestCase.makeClass("Null", null));
    unit.getTopLevelNodes().add(ResolverTestCase.makeClass("String", null));
    unit.getTopLevelNodes().add(ResolverTestCase.makeClass("Function", null));
    unit.getTopLevelNodes().add(ResolverTestCase.makeInterface("List", "T"));
    unit.getTopLevelNodes().add(ResolverTestCase.makeInterface("Map", "K", "V"));
    ResolverTestCase.resolve(unit, getContext());
  }

  public void testInitializer1() {
    checkNumErrors("Initializer1NegativeTest.dart", 1);
  }

  public void testInitializer2() {
    checkNumErrors("Initializer2NegativeTest.dart", 1);
  }

  public void testInitializer3() {
    checkNumErrors("Initializer3NegativeTest.dart", 1);
  }

  public void testInitializer4() {
    checkNumErrors("Initializer4NegativeTest.dart", 1);
  }

  public void testInitializer5() {
    checkNumErrors("Initializer5NegativeTest.dart", 1);
  }

  public void testInitializer6() {
    checkNumErrors("Initializer6NegativeTest.dart", 1);
  }

  public void testArrayLiteralNegativeTest() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  main() {",
            "    List<int, int> ints = [1];",
            "  }",
            "}"),
        errEx(TypeErrorCode.WRONG_NUMBER_OF_TYPE_ARGUMENTS, 4, 5, 14));
  }

  public void testMapLiteralNegativeTest() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  main() {",
            "    Map<String, int, int> map = {'foo':1};",
            "  }",
            "}"),
        errEx(TypeErrorCode.WRONG_NUMBER_OF_TYPE_ARGUMENTS, 4, 5, 21));
  }

  /**
   * We should not fail in case of using {@link DartThisExpression} outside of method.
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=662
   */
  public void test_thisExpression_inTopLevelVariable() {
    checkSourceErrors("var foo = this;", errEx(ResolverErrorCode.THIS_ON_TOP_LEVEL, 1, 11, 4));
  }

  public void test_thisExpression_inTopLevelMethod() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "foo() {",
            "  return this;",
            "}"),
        errEx(ResolverErrorCode.THIS_ON_TOP_LEVEL, 3, 10, 4));
  }

  public void test_thisExpression_outsideOfMethod() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  var foo = this;",
            "}"),
        errEx(ResolverErrorCode.THIS_OUTSIDE_OF_METHOD, 3, 13, 4));
  }

  public void test_thisExpression_inStaticMethod() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  static foo() {",
            "    return this;",
            "  }",
            "}"),
        errEx(ResolverErrorCode.THIS_IN_STATIC_METHOD, 4, 12, 4));
  }

  public void test_thisExpression_inFactoryMethod() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  factory A() {",
            "    return this;",
            "  }",
            "}"),
        errEx(ResolverErrorCode.THIS_IN_FACTORY_CONSTRUCTOR, 4, 12, 4));
  }

  /**
   * We should not fail in case of using {@link DartThisExpression} outside of method.
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=662
   */
  public void test_superExpression_inTopLevelVariable() {
    checkSourceErrors(
        "var foo = super.foo();",
        errEx(ResolverErrorCode.SUPER_ON_TOP_LEVEL, 1, 11, 5));
  }

  public void test_superExpression_inTopLevelMethod() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "foo() {",
            "  return super.foo();",
            "}"),
        errEx(ResolverErrorCode.SUPER_ON_TOP_LEVEL, 3, 10, 5));
  }

  public void test_superExpression_outsideOfMethod() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  var foo = super.foo();",
            "}"),
        errEx(ResolverErrorCode.SUPER_OUTSIDE_OF_METHOD, 3, 13, 5));
  }

  public void test_superExpression_inStaticMethod() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  static foo() {",
            "    return super.foo();",
            "  }",
            "}"),
        errEx(ResolverErrorCode.SUPER_IN_STATIC_METHOD, 4, 12, 5));
  }

  public void test_superExpression_inFactoryMethod() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  factory A() {",
            "    return super.foo();",
            "  }",
            "}"),
        errEx(ResolverErrorCode.SUPER_IN_FACTORY_CONSTRUCTOR, 4, 12, 5));
  }

  public void testNameConflict_field_field() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  var foo;",
            "  var foo;",
            "}"),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 3, 7, 3),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 4, 7, 3));
  }

  public void testCall1() {
    checkNumErrors("StaticInstanceCallNegativeTest.dart", 1);
  }

  /**
   * Class can implement class, this causes implementation of an implicit interface.
   */
  public void test_classImplementsClass() {
    checkSourceErrors(makeCode(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {}",
        "class B implements A {",
        "}"));
  }

  public void tesClassImplementsUnknownInterfaceNegativeTest() {
    checkNumErrors("ClassImplementsUnknownInterfaceNegativeTest.dart", 1);
  }

  public void testConstSuperNegativeTest1() {
    checkNumErrors("ConstSuperNegativeTest1.dart", 0);
  }

  public void testConstSuperNegativeTest2() {
    checkNumErrors("ConstSuperNegativeTest2.dart", 1);
  }

  public void testConstSuperTest() {
    checkNumErrors("ConstSuperTest.dart", 0);
  }

  public void testParameterInitializerNegativeTest1() {
    checkNumErrors("ParameterInitializerNegativeTest1.dart", 1);
  }

  public void testParameterInitializerNegativeTest2() {
    checkNumErrors("ParameterInitializerNegativeTest2.dart", 1);
  }

  public void testParameterInitializerNegativeTest3() {
    checkNumErrors("ParameterInitializerNegativeTest3.dart", 1);
  }

  public void testStaticToInstanceInvocationNegativeTest1() {
    checkNumErrors("StaticToInstanceInvocationNegativeTest1.dart", 1);
  }

  public void testConstVariableInitializationNegativeTest1() {
    checkNumErrors("ConstVariableInitializationNegativeTest1.dart", 1);
  }

  public void testConstVariableInitializationNegativeTest2() {
    checkNumErrors("ConstVariableInitializationNegativeTest2.dart", 1);
  }

  public void test_nameShadow_topLevel_method_class() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "foo() {}",
            "class foo {}"),
        errEx(ResolverErrorCode.DUPLICATE_TOP_LEVEL_DECLARATION, 2, 1, 3),
        errEx(ResolverErrorCode.DUPLICATE_TOP_LEVEL_DECLARATION, 3, 7, 3));
    assertEquals(
        "duplicate top-level declaration class 'foo' at Test.dart line:3 col:7",
        errors.get(0).getMessage());
    assertEquals(
        "duplicate top-level declaration top-level function 'foo' at Test.dart line:2 col:1",
        errors.get(1).getMessage());
  }

  public void test_nameShadow_topLevel_getterSetter_class() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "get foo {}",
            "set bar(x) {}",
            "class foo {}",
            "class bar{}"),
        errEx(ResolverErrorCode.DUPLICATE_TOP_LEVEL_DECLARATION, 2, 5, 3),
        errEx(ResolverErrorCode.DUPLICATE_TOP_LEVEL_DECLARATION, 4, 7, 3));
  }

  public void test_nameShadow_topLevel_class_getterSetter() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class foo {}",
            "class bar {}",
            "get foo {}",
            "set bar(x) {}"),
        errEx(ResolverErrorCode.DUPLICATE_TOP_LEVEL_DECLARATION, 2, 7, 3),
        errEx(ResolverErrorCode.DUPLICATE_TOP_LEVEL_DECLARATION, 4, 5, 3));
    assertEquals(
        "duplicate top-level declaration top-level variable 'foo' at Test.dart line:4 col:5",
        errors.get(0).getMessage());
    assertEquals(
        "duplicate top-level declaration class 'foo' at Test.dart line:2 col:7",
        errors.get(1).getMessage());
  }

  public void test_nameShadow_topLevel_getter_setter() {
    checkSourceErrors(makeCode(
        "// filler filler filler filler filler filler filler filler filler filler",
        "get bar {}",
        "set bar(x) {}"));
  }

  public void test_nameShadow_topLevel_setter_getter() {
    checkSourceErrors(makeCode(
        "// filler filler filler filler filler filler filler filler filler filler",
        "set bar(x) {}",
        "get bar {}"));
  }
  
  public void test_nameShadow_topLevel_setter_variable() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "set bar(x) {}",
            "var bar;"),
        errEx(ResolverErrorCode.DUPLICATE_TOP_LEVEL_DECLARATION, 2, 5, 3),
        errEx(ResolverErrorCode.DUPLICATE_TOP_LEVEL_DECLARATION, 3, 5, 3));
  }

  public void test_nameShadow_topLevel_variable_setter() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "var bar;",
            "set bar(x) {}"),
        errEx(ResolverErrorCode.DUPLICATE_TOP_LEVEL_DECLARATION, 2, 5, 3),
        errEx(ResolverErrorCode.DUPLICATE_TOP_LEVEL_DECLARATION, 3, 5, 3));
  }

  public void test_nameShadow_topLevel_getters() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "get bar {}",
            "get bar {}"),
        errEx(ResolverErrorCode.DUPLICATE_TOP_LEVEL_DECLARATION, 2, 5, 3),
        errEx(ResolverErrorCode.DUPLICATE_TOP_LEVEL_DECLARATION, 3, 5, 3));
    assertEquals(
        "duplicate top-level declaration top-level variable 'bar' at Test.dart line:3 col:5",
        errors.get(0).getMessage());
    assertEquals(
        "duplicate top-level declaration top-level variable 'bar' at Test.dart line:2 col:5",
        errors.get(1).getMessage());
  }

  public void test_nameShadow_topLevel_setters() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "set bar(x) {}",
            "set bar(x) {}"),
        errEx(ResolverErrorCode.DUPLICATE_TOP_LEVEL_DECLARATION, 2, 5, 3),
        errEx(ResolverErrorCode.DUPLICATE_TOP_LEVEL_DECLARATION, 3, 5, 3));
    assertEquals(
        "duplicate top-level declaration top-level variable 'setter bar' at Test.dart line:3 col:5",
        errors.get(0).getMessage());
    assertEquals(
        "duplicate top-level declaration top-level variable 'setter bar' at Test.dart line:2 col:5",
        errors.get(1).getMessage());
  }

  public void test_nameShadow_topLevel_variables() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "var foo;",
            "var bar;",
            "var foo;"),
        errEx(ResolverErrorCode.DUPLICATE_TOP_LEVEL_DECLARATION, 2, 5, 3),
        errEx(ResolverErrorCode.DUPLICATE_TOP_LEVEL_DECLARATION, 4, 5, 3));
    assertEquals(
        "duplicate top-level declaration top-level variable 'foo' at Test.dart line:4 col:5",
        errors.get(0).getMessage());
    assertEquals(
        "duplicate top-level declaration top-level variable 'foo' at Test.dart line:2 col:5",
        errors.get(1).getMessage());
  }

  /**
   * Multiple unnamed constructor definitions.
   */
  public void test_nameShadow_unnamedConstructors() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  A(x) {}",
            "  A(x,y) {}",
            "}"),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 3, 3, 1),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 4, 3, 1));
    {
      String message = errors.get(0).getMessage();
      assertTrue(message, message.contains("'A'"));
    }
    {
      String message = errors.get(1).getMessage();
      assertTrue(message, message.contains("'A'"));
    }
  }

  /**
   * Multiple unnamed constructor definitions. Make sure modifiers works as expected.
   */
  public void test_nameShadow_unnamedConstructors_constModifier() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  A(x) {}",
            "  const A(x,y) {}",
            "}"),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 3, 3, 1),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 4, 9, 1),
        errEx(ResolverErrorCode.CONST_CONSTRUCTOR_CANNOT_HAVE_BODY, 4, 9, 1));
    {
      String message = errors.get(0).getMessage();
      assertTrue(message, message.contains("'A'"));
    }
  }

  /**
   * Named constructor shadows another named constructor.
   */
  public void test_nameShadow_namedConstructors() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  A.foo() {}",
            "  A.foo() {}",
            "}"),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 3, 3, 5),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 4, 3, 5));
    {
      String message = errors.get(0).getMessage();
      assertTrue(message, message.contains("'A.foo'"));
    }
    {
      String message = errors.get(1).getMessage();
      assertTrue(message, message.contains("'A.foo'"));
    }
  }

  /**
   * Method shadows another method.
   */
  public void test_nameShadow_methods() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  foo() {}",
            "  foo() {}",
            "}"),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 3, 3, 3),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 4, 3, 3));
  }

  /**
   * Field shadows method.
   */
  public void test_nameShadow_method_field() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  foo() {}",
            "  var foo;",
            "}"),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 4, 7, 3),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 3, 3, 3));
  }

  /**
   * Static method shadows instance method.
   */
  public void test_nameShadow_method_staticMethod() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  foo(x) {}",
            "  static foo(a,b) {}",
            "}"),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 3, 3, 3),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 4, 10, 3));
  }

  /**
   * Field shadows another field.
   */
  public void test_nameShadow_fields() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  var _a;",
            "  var _a = 2;",
            "}"),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 3, 7, 2),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 4, 7, 2));
  }

  public void test_nameShadow_variables_sameBlock() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  foo() {",
            "    var a;",
            "    var a = 2;",
            "  }",
            "}"),
        errEx(ResolverErrorCode.DUPLICATE_LOCAL_VARIABLE_ERROR, 5, 9, 1));
  }

  /**
   * Here we have two local variables: one in "main" and one in the scope on "block". However
   * variables are declared in lexical scopes, i.e. in "block", so using it before declaration is
   * error.
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=2382
   */
  public void test_useVariable_beforeDeclaration_inLexicalScope() throws Exception {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "main() {",
            "  var x;",
            "  {",
            "    x = 1;",
            "    var x;",
            "  }",
            "}",
            ""),
        errEx(ResolverErrorCode.USING_LOCAL_VARIABLE_BEFORE_DECLARATION, 5, 5, 1));
  }

  public void test_nameShadow_methodParameters() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  foo(a, bb, a) {",
            "  }",
            "}"),
        errEx(ResolverErrorCode.DUPLICATE_PARAMETER, 3, 14, 1));
  }

  /**
   * In static method instance fields are out of scope, so it is OK to have parameter with same
   * name.
   */
  public void test_nameShadow_instanceField_staticMethodParameter() {
    checkSourceErrors(makeCode(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  var a;",
        "  static foo(a) {",
        "  }",
        "}"));
  }

  public void test_nameShadow_field_methodParameterThis() {
    checkSourceErrors(makeCode(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  final a;",
        "  const A(this.a);",
        "}"));
  }

  public void test_nameShadow_field_interfaceMethodParameter() {
    checkSourceErrors(makeCode(
        "// filler filler filler filler filler filler filler filler filler filler",
        "abstract class A {",
        "  var a;",
        "  foo(a);",
        "}"));
  }

  public void test_nameShadow_field_nativeMethodParameter() {
    checkSourceErrorsAsSystemLibrary(makeCode(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class A {",
        "  var a;",
        "  foo(a) native;",
        "}"));
  }

  public void test_nameShadow_classTypeVariables() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class C<A, BB, A> {",
            "}"),
        errEx(ResolverErrorCode.DUPLICATE_TYPE_VARIABLE, 2, 16, 1));
  }

  /**
   * Field shadows setter/getter.
   */
  public void test_nameShadow_setter_field() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  set foo(x) {}",
            "  get foo {}",
            "  var foo;",
            "}"),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 4, 7, 3),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 5, 7, 3));
  }

  /**
   * Setter shadows field.
   */
  public void test_nameShadow_field_setter() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  var foo;",
            "  set foo(x) {}",
            "}"),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 3, 7, 3),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 4, 7, 3));
  }

  /**
   * Method does not shadow setter, because "=" is implicitly appended to the setter name.
   */
  public void test_nameShadow_setter_method() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  set foo(x) {}",
            "  foo() {}",
            "}"));
  }

  /**
   * We should ignore if setter parameter has same name and name of the setter method.
   */
  public void test_nameShadow_setter_sameParameterName() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  set foo(foo) {}",
            "}"));
  }

  /**
   * Getter shadows field.
   */
  public void test_nameShadow_field_getter() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  var foo;",
            "  get foo {}",
            "}"),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 3, 7, 3),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 4, 7, 3));
  }

  /**
   * Getter shadows another getter.
   */
  public void test_nameShadow_getters() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  get foo {}",
            "  set foo(x) {}",
            "  get foo {}",
            "}"),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 3, 7, 3),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 5, 7, 3));
  }

  /**
   * Setter shadows another setter.
   */
  public void test_nameShadow_setters() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  set foo(x) {}",
            "  get foo {}",
            "  set foo(x) {}",
            "}"),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 3, 7, 3),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 5, 7, 3));
  }

  /**
   * Field shadows getter.
   */
  public void test_nameShadow_getter_field() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  get foo {}",
            "  var foo;",
            "}"),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 3, 7, 3),
        errEx(ResolverErrorCode.DUPLICATE_MEMBER, 4, 7, 3));
  }

  /**
   * Setter does not shadow method, because "=" is implicitly appended to the setter name.
   */
  public void test_nameShadow_method_setter() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  foo() {}",
            "  set foo(x) {}",
            "}"));
  }

  public void test_nameShadow_functionExpressionParameters() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  foo() {",
            "    fn(a, b, a) {};",
            "  }",
            "}"),
        errEx(ResolverErrorCode.DUPLICATE_PARAMETER, 4, 14, 1));
  }

  public void test_nameShadow_variable_functionExpressionNamed() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  foo() {",
            "    var a;",
            "    a() => 0;",
            "  }",
            "}"),
        errEx(ResolverErrorCode.DUPLICATE_FUNCTION_EXPRESSION, 5, 5, 1));
    {
      String message = errors.get(0).getMessage();
      assertEquals("Duplicate function expression 'a'", message);
    }
  }

  public void testUnresolvedSuperFieldNegativeTest() {
    checkNumErrors("UnresolvedSuperFieldNegativeTest.dart", 1);
  }

  public void testStaticSuperFieldNegativeTest() {
    checkNumErrors("StaticSuperFieldNegativeTest.dart", 1);
  }

  public void testStaticSuperGetterNegativeTest() {
    checkNumErrors("StaticSuperGetterNegativeTest.dart", 1);
  }

  public void testStaticSuperMethodNegativeTest() {
    checkNumErrors("StaticSuperMethodNegativeTest.dart", 1);
  }

  public void testCyclicRedirectedConstructorNegativeTest() {
    checkNumErrors("CyclicRedirectedConstructorNegativeTest.dart", 3);
  }

  public void testConstRedirectedConstructorNegativeTest() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  const A(x) : this.foo(x);",
            "  A.foo(this.x) { }",
            "  final x;",
            "}"),
        errEx(ResolverErrorCode.CONST_CONSTRUCTOR_MUST_CALL_CONST_SUPER, 3, 9, 1));
  }

  public void testConstConstructorNonFinalFieldsNegativeTest() {
    checkSourceErrors(
        makeCode(
            "class A extends B {",
            "  const A();",
            "  var x;",
            "  final y = 10;",
            "  set z(value) {}",
            "}",
            "class B implements C {",
            "  final bar;",
            "  var baz;",
            "}",
            "abstract class C {",
            "  var x;",
            "}"),
        errEx(ResolverErrorCode.CONST_CLASS_WITH_NONFINAL_FIELDS, 3, 7, 1),
        errEx(ResolverErrorCode.CONST_CLASS_WITH_INHERITED_NONFINAL_FIELDS, 9, 7, 3),
        errEx(ResolverErrorCode.FINAL_FIELD_MUST_BE_INITIALIZED, 8, 9, 3));
  }

  private TestCompilerContext getContext() {
    return new TestCompilerContext() {
      @Override
      public void onError(DartCompilationError event) {
        errors.add(event);
      }
    };
  }

  public void test_blackListed_dynamic() throws Exception {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A extends dynamic {",
            "}",
            "class B implements dynamic {",
            "}"),
        errEx(ResolverErrorCode.BLACK_LISTED_EXTENDS, 2, 17, 7),
        errEx(ResolverErrorCode.BLACK_LISTED_IMPLEMENTS, 4, 20, 7));
    assertEquals("'dynamic' can not be used as superclass", errors.get(0).getMessage());
    assertEquals("'dynamic' can not be used as superinterface", errors.get(1).getMessage());
  }

  public void test_blackListed_Function() throws Exception {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A extends Function {",
            "}",
            "class B implements Function {",
            "}"),
        errEx(ResolverErrorCode.BLACK_LISTED_EXTENDS, 2, 17, 8),
        errEx(ResolverErrorCode.BLACK_LISTED_IMPLEMENTS, 4, 20, 8));
  }

  public void test_blackListed_bool() throws Exception {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A extends bool {",
            "}",
            "class B implements bool {",
            "}"),
        errEx(ResolverErrorCode.BLACK_LISTED_EXTENDS, 2, 17, 4),
        errEx(ResolverErrorCode.BLACK_LISTED_IMPLEMENTS, 4, 20, 4));
    assertEquals("'bool' can not be used as superclass", errors.get(0).getMessage());
    assertEquals("'bool' can not be used as superinterface", errors.get(1).getMessage());
  }

  public void test_blackListed_int() throws Exception {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A extends int {",
            "}",
            "class B implements int {",
            "}"),
        errEx(ResolverErrorCode.BLACK_LISTED_EXTENDS, 2, 17, 3),
        errEx(ResolverErrorCode.BLACK_LISTED_IMPLEMENTS, 4, 20, 3));
  }

  public void test_blackListed_double() throws Exception {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A extends double {",
            "}",
            "class B implements double {",
            "}"),
        errEx(ResolverErrorCode.BLACK_LISTED_EXTENDS, 2, 17, 6),
        errEx(ResolverErrorCode.BLACK_LISTED_IMPLEMENTS, 4, 20, 6));
  }

  public void test_blackListed_num() throws Exception {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A extends num {",
            "}",
            "class B implements num {",
            "}"),
        errEx(ResolverErrorCode.BLACK_LISTED_EXTENDS, 2, 17, 3),
        errEx(ResolverErrorCode.BLACK_LISTED_IMPLEMENTS, 4, 20, 3));
  }

  public void test_blackListed_String() throws Exception {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A extends String {",
            "}",
            "class B implements String {",
            "}"),
        errEx(ResolverErrorCode.BLACK_LISTED_EXTENDS, 2, 17, 6),
        errEx(ResolverErrorCode.BLACK_LISTED_IMPLEMENTS, 4, 20, 6));
  }

  public void test_noSuchType_classImplements() throws Exception {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class MyClass implements Unknown {",
            "}"),
        errEx(ResolverErrorCode.NO_SUCH_TYPE, 2, 26, 7));
  }

  public void test_noSuchType_classImplementsTypeVariable() throws Exception {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class MyClass<E> implements E {",
            "}"),
        errEx(ResolverErrorCode.NOT_A_CLASS_OR_INTERFACE, 2, 29, 1));
  }

  public void test_explicitDynamicTypeArgument() throws Exception {
    checkSourceErrors(makeCode(
        "// filler filler filler filler filler filler filler filler filler filler",
        "class MyClass implements Map<Object, dynamic> {",
        "}"));
  }

  public void testAssignToFunc() {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "double func(a) {}",
            "main() {",
            "  func = null;",
            "}"),
        errEx(ResolverErrorCode.CANNOT_ASSIGN_TO_METHOD, 4, 3, 4));
  }

  public void testConstructorDuplicateInitializationTest() {
    checkSourceErrors(
        makeCode(
            "class A {",
            "  A.one(this.x) : this.x = 42;",
            "  A.two(y) : this.x = y, x = y;",
            "  var x;",
            "}"),
        errEx(ResolverErrorCode.DUPLICATE_INITIALIZATION, 2, 19, 11),
        errEx(ResolverErrorCode.DUPLICATE_INITIALIZATION, 3, 26, 5));
  }

  public void testInitializerReferenceToThis() throws Exception {
    checkSourceErrors(
        makeCode(
            "class A {",
            "  var x, y;",
            "  A.one(z) : x = z, y = this.x;",
            "  A.two(this.x) : y = (() { return this; });",
            "  A.three(this.x) : y = this.x;",
            "}"),
        errEx(ResolverErrorCode.THIS_IN_INITIALIZER_AS_EXPRESSION, 3, 25, 4),
        errEx(ResolverErrorCode.THIS_IN_INITIALIZER_AS_EXPRESSION, 4, 36, 4),
        errEx(ResolverErrorCode.THIS_IN_INITIALIZER_AS_EXPRESSION, 5, 25, 4));
  }

  public void test_resolvedTypeVariableBounds_inFunctionTypeAlias() throws Exception {
    DartUnit unit =
        parseUnit(
            getName(),
            makeCode(
                "// filler filler filler filler filler filler filler filler filler filler",
                "class A {}",
                "typedef T Foo<T extends A>();",
                ""));
    resolve(unit);
    DartFunctionTypeAlias func = (DartFunctionTypeAlias) unit.getTopLevelNodes().get(1);
    DartTypeParameter typeParameter = func.getTypeParameters().get(0);
    Type boundType = typeParameter.getBound().getType();
    assertEquals("A", boundType.getElement().getName());
  }
  
  /**
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=3986
   */
  public void test_memberWithNameOfClass() throws Exception {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  A() {}",
            "}",
            "class B {",
            "  var B;",
            "}",
            "class C {",
            "  void C() {}",
            "}",
            ""),
        errEx(ResolverErrorCode.MEMBER_WITH_NAME_OF_CLASS, 6, 7, 1),
        errEx(ResolverErrorCode.CONSTRUCTOR_CANNOT_HAVE_RETURN_TYPE, 9, 3, 4));
  }

  public void test_methodCannotBeResolved() throws Exception {
    checkSourceErrors(
        makeCode(
            "class A {",
            "}",
            "method() {",
            "  A.method();", // error
            "}"),
            errEx(ResolverErrorCode.CANNOT_RESOLVE_METHOD_IN_CLASS, 4, 5, 6));
  }

  /**
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=4090
   */
  public void test_forEachVariableIsNotVisibleInIterableExpression() throws Exception {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "List foo(var a) {}",
            "main() {",
            "  for (var y in foo(y)) {",
            "  }",
            "}"),
            errEx(TypeErrorCode.CANNOT_BE_RESOLVED, 4, 21, 1));
  }

  /**
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=4374
   */
  public void test_unaryOperatorForFinal_variable() throws Exception {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "main() {",
            "  final v = 0;",
            "  v++;",
            "  v--;",
            "  ++v;",
            "  --v;",
            "}"),
            errEx(ResolverErrorCode.CANNOT_ASSIGN_TO_FINAL, 4, 3, 1),
            errEx(ResolverErrorCode.CANNOT_ASSIGN_TO_FINAL, 5, 3, 1),
            errEx(ResolverErrorCode.CANNOT_ASSIGN_TO_FINAL, 6, 5, 1),
            errEx(ResolverErrorCode.CANNOT_ASSIGN_TO_FINAL, 7, 5, 1));
  }

  /**
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=4374
   */
  public void test_unaryOperatorForFinal_parameter() throws Exception {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "foo(final v) {",
            "  v++;",
            "  v--;",
            "  ++v;",
            "  --v;",
            "}"),
            errEx(ResolverErrorCode.CANNOT_ASSIGN_TO_FINAL, 3, 3, 1),
            errEx(ResolverErrorCode.CANNOT_ASSIGN_TO_FINAL, 4, 3, 1),
            errEx(ResolverErrorCode.CANNOT_ASSIGN_TO_FINAL, 5, 5, 1),
            errEx(ResolverErrorCode.CANNOT_ASSIGN_TO_FINAL, 6, 5, 1));
  }

  /**
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=4374
   */
  public void test_unaryOperatorForFinal_field() throws Exception {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  final v = 0;",
            "  foo() {",
            "    v++;",
            "    v--;",
            "    ++v;",
            "    --v;",
            "  }",
            "}"),
            errEx(ResolverErrorCode.CANNOT_ASSIGN_TO_FINAL, 5, 5, 1),
            errEx(ResolverErrorCode.CANNOT_ASSIGN_TO_FINAL, 6, 5, 1),
            errEx(ResolverErrorCode.CANNOT_ASSIGN_TO_FINAL, 7, 7, 1),
            errEx(ResolverErrorCode.CANNOT_ASSIGN_TO_FINAL, 8, 7, 1));
  }

  /**
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=5987
   */
  public void test_accessConstInstanceField_fromConstStaticField() throws Exception {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  const x = 499;",
            "  static const bar = x;",
            "}",
            ""),
        errEx(ResolverErrorCode.ILLEGAL_FIELD_ACCESS_FROM_STATIC, 4, 22, 1));
  }
  
  /**
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=6489
   */
  public void test_accessConstInstanceField_fromConstStaticMethod() throws Exception {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  const CONST = 26;",
            "  static int foo() {",
            "    return CONST;",
            "  }",
            "}",
            ""),
        errEx(ResolverErrorCode.ILLEGAL_FIELD_ACCESS_FROM_STATIC, 5, 12, 5));
  }

  /**
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=7633
   */
  public void test_accessInstanceField_fromConstFactory() throws Exception {
    checkSourceErrors(
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler",
            "class A {",
            "  var foo;",
            "  factory A() {",
            "    var v = foo;",
            "    return null;",
            "  }",
            "}",
            ""),
        errEx(ResolverErrorCode.ILLEGAL_FIELD_ACCESS_FROM_FACTORY, 5, 13, 3));
  }
}
