// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
// Dart test program for checking implemention of MirrorSystem when
// inspecting the current isolate.
//
// VMOptions=--enable_type_checks

library isolate_mirror_local_test;

import "package:expect/expect.dart";
import 'dart:async';
import 'dart:isolate';
import 'dart:mirrors';

ReceivePort exit_port;
Set expectedTests;

void testDone(String test) {
  if (!expectedTests.contains(test)) {
    throw "Unexpected test name '$test'";
  }
  expectedTests.remove(test);
  if (expectedTests.isEmpty) {
    // All tests are done.
    exit_port.close();
  }
}

int global_var = 0;
final int final_global_var = 0;

// Top-level getter and setter.
int get myVar { return 5; }
void set myVar(x) {}

// This function will be invoked reflectively.
int function(int x) {
  global_var = x;
  return x + 1;
}

typedef void FuncType(String a);

FuncType myFunc = null;

_stringCompare(String a, String b) => a.compareTo(b);
sort(list) => list.sort(_stringCompare);

String buildMethodString(MethodMirror func) {
  var result = '${MirrorSystem.getName(func.simpleName)} '
      'return(${MirrorSystem.getName(func.returnType.simpleName)})';
  if (func.isPrivate) {
    result = '$result private';
  }
  if (func.isTopLevel) {
    result = '$result toplevel';
  }
  if (func.isStatic) {
    result = '$result static';
  }
  if (func.isAbstract) {
    result = '$result abstract';
  }
  if (func.isRegularMethod) {
    result = '$result method';
  }
  if (func.isGetter) {
    result = '$result getter';
  }
  if (func.isSetter) {
    result = '$result setter';
  }
  if (func.isConstructor) {
    result = '$result constructor';
  }
  if (func.isConstConstructor) {
    result = '$result const';
  }
  if (func.isGenerativeConstructor) {
    result = '$result generative';
  }
  if (func.isRedirectingConstructor) {
    result = '$result redirecting';
  }
  if (func.isFactoryConstructor) {
    result = '$result factory';
  }
  return result;
}

String buildVariableString(VariableMirror variable) {
  var result = '${MirrorSystem.getName(variable.simpleName)} '
      'type(${MirrorSystem.getName(variable.type.simpleName)})';
  if (variable.isPrivate) {
    result = '$result private';
  }
  if (variable.isTopLevel) {
    result = '$result toplevel';
  }
  if (variable.isStatic) {
    result = '$result static';
  }
  if (variable.isFinal) {
    result = '$result final';
  }
  return result;
}

void testRootLibraryMirror(LibraryMirror lib_mirror) {
  Expect.equals(const Symbol('isolate_mirror_local_test'),
                lib_mirror.simpleName);
  Expect.equals(const Symbol('isolate_mirror_local_test'),
                lib_mirror.qualifiedName);
  Expect.equals(null, lib_mirror.owner);
  Expect.isFalse(lib_mirror.isPrivate);
  Expect.isTrue(lib_mirror.uri.path.contains('isolate_mirror_local_test.dart'));
  // TODO(ahe): toString() test disabled for now as Symbols are 100% opaque.
  // Expect.equals("LibraryMirror on 'isolate_mirror_local_test'",
  //               lib_mirror.toString());

  // Test library invocation by calling function(123).
  Expect.equals(0, global_var);
  lib_mirror.invokeAsync(const Symbol('function'), [123]).then(
      (InstanceMirror retval) {
        Expect.equals(123, global_var);
        Expect.equals(const Symbol('int'), retval.type.simpleName);
        Expect.isTrue(retval.hasReflectee);
        Expect.equals(124, retval.reflectee);
        testDone('testRootLibraryMirror');
      });

  // Check that the members map is complete.
  List keys = lib_mirror.members.keys.map(MirrorSystem.getName).toList();
  sort(keys);
  Expect.equals('['
                'FuncType, '
                'GenericClass, '
                'MyClass, '
                'MyException, '
                'MyInterface, '
                'MySuperClass, '
                '_stringCompare, '
                'buildMethodString, '
                'buildVariableString, '
                'exit_port, '
                'expectedTests, '
                'final_global_var, '
                'function, '
                'global_var, '
                'main, '
                'methodWithError, '
                'methodWithException, '
                'myFunc, '
                'myVar, '
                'myVar=, '
                'sort, '
                'testBoolInstanceMirror, '
                'testCustomInstanceMirror, '
                'testDone, '
                'testIntegerInstanceMirror, '
                'testLibrariesMap, '
                'testMirrorErrors, '
                'testMirrorSystem, '
                'testNullInstanceMirror, '
                'testRootLibraryMirror, '
                'testStringInstanceMirror]',
                '$keys');

  // Check that the classes map is complete.
  keys = lib_mirror.classes.keys.map(MirrorSystem.getName).toList();
  sort(keys);
  Expect.equals('['
                'FuncType, '
                'GenericClass, '
                'MyClass, '
                'MyException, '
                'MyInterface, '
                'MySuperClass]',
                '$keys');

  // Check that the functions map is complete.
  keys = lib_mirror.functions.keys.map(MirrorSystem.getName).toList();
  sort(keys);
  Expect.equals('['
                '_stringCompare, '
                'buildMethodString, '
                'buildVariableString, '
                'function, '
                'main, '
                'methodWithError, '
                'methodWithException, '
                'myVar, '
                'myVar=, '
                'sort, '
                'testBoolInstanceMirror, '
                'testCustomInstanceMirror, '
                'testDone, '
                'testIntegerInstanceMirror, '
                'testLibrariesMap, '
                'testMirrorErrors, '
                'testMirrorSystem, '
                'testNullInstanceMirror, '
                'testRootLibraryMirror, '
                'testStringInstanceMirror]',
                '$keys');

  // Check that the getters map is complete.
  keys = lib_mirror.getters.keys.map(MirrorSystem.getName).toList();
  sort(keys);
  Expect.equals('[myVar]', '$keys');

  // Check that the setters map is complete.
  keys = lib_mirror.setters.keys.map(MirrorSystem.getName).toList();
  sort(keys);
  Expect.equals('[myVar=]', '$keys');

  // Check that the variables map is complete.
  keys = lib_mirror.variables.keys.map(MirrorSystem.getName).toList();
  sort(keys);
  Expect.equals('['
                'exit_port, '
                'expectedTests, '
                'final_global_var, '
                'global_var, '
                'myFunc]',
                '$keys');

  ClassMirror cls_mirror = lib_mirror.members[const Symbol('MyClass')];
  ClassMirror generic_cls_mirror =
      lib_mirror.members[const Symbol('GenericClass')];

  // Test function mirrors.
  MethodMirror func = lib_mirror.members[const Symbol('function')];
  Expect.isTrue(func is MethodMirror);
  Expect.equals('function return(int) toplevel static method',
                buildMethodString(func));

  func = lib_mirror.members[const Symbol('myVar')];
  Expect.isTrue(func is MethodMirror);
  Expect.equals('myVar return(int) toplevel static getter',
                buildMethodString(func));

  func = lib_mirror.members[const Symbol('myVar=')];
  Expect.isTrue(func is MethodMirror);
  Expect.equals('myVar= return(void) toplevel static setter',
                buildMethodString(func));

  func = cls_mirror.members[const Symbol('method')];
  Expect.isTrue(func is MethodMirror);
  Expect.equals('method return(int) method', buildMethodString(func));

  func = cls_mirror.constructors[const Symbol('MyClass')];
  Expect.isTrue(func is MethodMirror);
  Expect.equals('MyClass return(MyClass) constructor', buildMethodString(func));

  func = cls_mirror.constructors[const Symbol('MyClass.named')];
  Expect.isTrue(func is MethodMirror);
  Expect.equals('MyClass.named return(MyClass) constructor',
                buildMethodString(func));

  func = generic_cls_mirror.members[const Symbol('method')];
  Expect.isTrue(func is MethodMirror);
  Expect.equals('method return(T) method', buildMethodString(func));

  // Test variable mirrors.
  VariableMirror variable = lib_mirror.members[const Symbol('global_var')];
  Expect.isTrue(variable is VariableMirror);
  Expect.equals('global_var type(int) toplevel static',
                buildVariableString(variable));

  variable = lib_mirror.members[const Symbol('final_global_var')];
  Expect.isTrue(variable is VariableMirror);
  Expect.equals('final_global_var type(int) toplevel static final',
                buildVariableString(variable));

  variable = cls_mirror.members[const Symbol('value')];
  Expect.isTrue(variable is VariableMirror);
  Expect.equals('value type(dynamic) final', buildVariableString(variable));

  // Test type variable mirrors.
  var type_var = generic_cls_mirror.members[const Symbol('method')].returnType;
  Expect.isTrue(type_var is TypeVariableMirror);
  Expect.equals(const Symbol('GenericClass'), type_var.owner.simpleName);
  Expect.equals(const Symbol('Object'), type_var.upperBound.simpleName);

  // Test typedef mirrors.
  var typedef_mirror = lib_mirror.members[const Symbol('myFunc')].type;
  Expect.isTrue(typedef_mirror is TypedefMirror);
  Expect.equals(const Symbol('isolate_mirror_local_test'),
                typedef_mirror.owner.simpleName);

  // Test function type mirrors.
  var func_cls_mirror = typedef_mirror.referent;
  Expect.isTrue(func_cls_mirror is FunctionTypeMirror);
  // Expect.equals('void (dart.core.String)', func_cls_mirror.simpleName);
  Expect.equals(const Symbol('void'), func_cls_mirror.returnType.simpleName);
}

void testLibrariesMap(Map libraries) {
  // Just look for a couple of well-known libs.
  LibraryMirror core_lib = libraries[const Symbol('dart.core')];
  Expect.isTrue(core_lib is LibraryMirror);

  LibraryMirror mirror_lib = libraries[const Symbol('dart.mirrors')];
  Expect.isTrue(mirror_lib is LibraryMirror);

  // Lookup an interface from a library and make sure it is sane.
  ClassMirror list_intf = core_lib.members[const Symbol('List')];
  Expect.isTrue(list_intf is ClassMirror);
  Expect.equals(const Symbol('List'), list_intf.simpleName);
  Expect.equals(const Symbol('dart.core.List'), list_intf.qualifiedName);
  Expect.isFalse(list_intf.isPrivate);
  Expect.equals(const Symbol('Object'), list_intf.superclass.simpleName);
  Expect.equals(const Symbol('dart.core'), list_intf.owner.simpleName);
  Expect.isTrue(list_intf.isClass);
  Expect.equals(const Symbol('Iterable'),
                list_intf.superinterfaces[0].simpleName);
  // TODO(ahe): toString() test disabled for now as Symbols are 100% opaque.
  // Expect.equals("ClassMirror on 'List'", list_intf.toString());

  // Lookup a class from a library and make sure it is sane.
  ClassMirror oom_cls = core_lib.members[const Symbol('OutOfMemoryError')];
  Expect.isTrue(oom_cls is ClassMirror);
  Expect.equals(const Symbol('OutOfMemoryError'), oom_cls.simpleName);
  Expect.equals(const Symbol('dart.core.OutOfMemoryError'),
                oom_cls.qualifiedName);
  Expect.isFalse(oom_cls.isPrivate);
  Expect.equals(const Symbol('Object'), oom_cls.superclass.simpleName);
  Expect.isTrue(oom_cls.defaultFactory == null);
  Expect.equals(const Symbol('dart.core'), oom_cls.owner.simpleName);
  Expect.isTrue(oom_cls.isClass);
  Expect.equals(const Symbol('Error'), oom_cls.superinterfaces[0].simpleName);
  // TODO(ahe): toString() test disabled for now as Symbols are 100% opaque.
  // Expect.equals("ClassMirror on 'OutOfMemoryError'",
  //               oom_cls.toString());
  testDone('testLibrariesMap');
}

void testMirrorSystem(MirrorSystem mirrors) {
  Expect.isTrue(mirrors.isolate.debugName.contains('main'));
  testRootLibraryMirror(mirrors.isolate.rootLibrary);
  testLibrariesMap(mirrors.libraries);
  Expect.equals(const Symbol('void'), mirrors.voidType.simpleName);
  Expect.equals(const Symbol('dynamic'), mirrors.dynamicType.simpleName);
  testDone('testMirrorSystem');
}

void testIntegerInstanceMirror(InstanceMirror mirror) {
  Expect.equals(const Symbol('int'), mirror.type.simpleName);
  Expect.isTrue(mirror.hasReflectee);
  Expect.equals(1001, mirror.reflectee);
  Expect.equals("InstanceMirror on <1001>", mirror.toString());

  // Invoke (mirror + mirror).
  mirror.invokeAsync(const Symbol('+'), [ mirror ]).then(
      (InstanceMirror retval) {
        Expect.equals(const Symbol('int'), retval.type.simpleName);
        Expect.isTrue(retval.hasReflectee);
        Expect.equals(2002, retval.reflectee);
        testDone('testIntegerInstanceMirror');
      });
}

void testStringInstanceMirror(InstanceMirror mirror) {
  Expect.equals(const Symbol('String'), mirror.type.simpleName);
  Expect.isTrue(mirror.hasReflectee);
  Expect.equals('This\nis\na\nString', mirror.reflectee);
  Expect.equals("InstanceMirror on <'This\\nis\\na\\nString'>",
                mirror.toString());

  // Invoke mirror[0].
  mirror.invokeAsync(const Symbol('[]'), [ 0 ]).then(
      (InstanceMirror retval) {
        Expect.equals(const Symbol('String'), retval.type.simpleName);
        Expect.isTrue(retval.hasReflectee);
        Expect.equals('T', retval.reflectee);
        testDone('testStringInstanceMirror');
      });
}

void testBoolInstanceMirror(InstanceMirror mirror) {
  Expect.equals(const Symbol('bool'), mirror.type.simpleName);
  Expect.isTrue(mirror.hasReflectee);
  Expect.equals(true, mirror.reflectee);
  Expect.equals("InstanceMirror on <true>", mirror.toString());
  testDone('testBoolInstanceMirror');
}

void testNullInstanceMirror(InstanceMirror mirror) {
  // TODO(turnidge): This is returning the wrong class.  Fix it.
  Expect.equals(const Symbol('Object'), mirror.type.simpleName);
  Expect.isTrue(mirror.hasReflectee);
  Expect.equals(null, mirror.reflectee);
  Expect.equals("InstanceMirror on <null>", mirror.toString());
  testDone('testNullInstanceMirror');
}

class MySuperClass {
}

class MyInterface {
}

class MyClass extends MySuperClass implements MyInterface {
  MyClass(this.value) {}
  MyClass.named() {}

  final value;

  int method(int arg) {
    return arg + value;
  }
}

class GenericClass<T> {
  T method(int arg) {
    return null;
  }
}

void testCustomInstanceMirror(InstanceMirror mirror) {
  Expect.isTrue(mirror.hasReflectee);
  bool saw_exception = false;
  try {
    mirror.reflectee;
  } on MirrorException catch (me) {
    saw_exception = true;
  }
  Expect.isFalse(saw_exception);
  // TODO(ahe): toString() test disabled for now as Symbols are 100% opaque.
  // Expect.equals("InstanceMirror on instance of 'MyClass'",
  //               mirror.toString());

  ClassMirror cls = mirror.type;
  Expect.isTrue(cls is ClassMirror);
  Expect.equals(const Symbol('MyClass'), cls.simpleName);
  Expect.equals(const Symbol('MySuperClass'), cls.superclass.simpleName);
  Expect.isTrue(cls.defaultFactory == null);
  Expect.equals(const Symbol('isolate_mirror_local_test'), cls.owner.simpleName);
  Expect.isTrue(cls.isClass);
  Expect.equals(const Symbol('MyInterface'), cls.superinterfaces[0].simpleName);
  // TODO(ahe): toString() test disabled for now as Symbols are 100% opaque.
  // Expect.equals("ClassMirror on 'MyClass'", cls.toString());

  // Invoke mirror.method(1000).
  mirror.invokeAsync(const Symbol('method'), [ 1000 ]).then(
      (InstanceMirror retval) {
        Expect.equals(const Symbol('int'), retval.type.simpleName);
        Expect.isTrue(retval.hasReflectee);
        Expect.equals(1017, retval.reflectee);
        testDone('testCustomInstanceMirror');
      });

}

class MyException implements Exception {
  MyException(this._message);
  final String _message;
  String toString() { return 'MyException: $_message'; }
}

void methodWithException() {
  throw new MyException("from methodWithException");
}

void methodWithError() {
  // We get a parse error when we try to run this function.
  +++;
}

void testMirrorErrors(MirrorSystem mirrors) {
  LibraryMirror lib_mirror = mirrors.isolate.rootLibrary;

  lib_mirror.invokeAsync(const Symbol('methodWithException'), [])
    .then((InstanceMirror retval) {
      // Should not reach here.
      Expect.isTrue(false);
    })
    .catchError((error) {
        Expect.isTrue(error is MirroredUncaughtExceptionError);
        Expect.equals(const Symbol('MyException'),
                      error.exception_mirror.type.simpleName);
        Expect.equals('MyException: from methodWithException',
                      error.exception_string);
        Expect.isTrue(error.stacktrace.toString().contains(
            'isolate_mirror_local_test.dart'));
        testDone('testMirrorErrors1');
      });

  lib_mirror.invokeAsync(const Symbol('methodWithError'), [])
    .then((InstanceMirror retval) {
      // Should not reach here.
      Expect.isTrue(false);
    })
    .catchError((error) {
      Expect.isTrue(error is MirroredCompilationError);
      Expect.isTrue(error.message.contains('unexpected token'));
      testDone('testMirrorErrors2');
    });

  // TODO(turnidge): When we call a method that doesn't exist, we
  // should probably call noSuchMethod().  I'm adding this test to
  // document the current behavior in the meantime.
  lib_mirror.invokeAsync(const Symbol('methodNotFound'), [])
    .then((InstanceMirror retval) {
      // Should not reach here.
      Expect.isTrue(false);
    })
    .catchError((error) {
      Expect.isTrue(error is MirroredCompilationError);
      Expect.isTrue(error.message.contains(
          "did not find top-level function 'methodNotFound'"));
      testDone('testMirrorErrors3');
    });
}

void main() {
  // When all of the expected tests complete, the exit_port is closed,
  // allowing the program to terminate.
  exit_port = new ReceivePort();
  expectedTests = new Set<String>.from(['testRootLibraryMirror',
                                        'testLibrariesMap',
                                        'testMirrorSystem',
                                        'testIntegerInstanceMirror',
                                        'testStringInstanceMirror',
                                        'testBoolInstanceMirror',
                                        'testNullInstanceMirror',
                                        'testCustomInstanceMirror',
                                        'testMirrorErrors1',
                                        'testMirrorErrors2',
                                        'testMirrorErrors3']);

  // Test that an isolate can reflect on itself.
  mirrorSystemOf(exit_port.toSendPort()).then(testMirrorSystem);

  testIntegerInstanceMirror(reflect(1001));
  testStringInstanceMirror(reflect('This\nis\na\nString'));
  testBoolInstanceMirror(reflect(true));
  testNullInstanceMirror(reflect(null));
  testCustomInstanceMirror(reflect(new MyClass(17)));
  testMirrorErrors(currentMirrorSystem());
}
