// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:expect/expect.dart";
import '../../../sdk/lib/_internal/compiler/implementation/mirrors/mirrors.dart';
import '../../../sdk/lib/_internal/compiler/implementation/mirrors/mirrors_util.dart';
import '../../../sdk/lib/_internal/compiler/implementation/mirrors/dart2js_mirror.dart';
import '../../../sdk/lib/_internal/compiler/implementation/filenames.dart'
       show currentDirectory, nativeToUriPath;
import '../../../sdk/lib/_internal/compiler/implementation/source_file_provider.dart';

import 'dart:io';
import 'dart:uri';

const Uri DART_MIRRORS_URI =
  const Uri.fromComponents(scheme: 'dart', path: 'mirrors');

int count(Iterable iterable) {
  var count = 0;
  for (var element in iterable) {
    count++;
  }
  return count;
}

bool containsType(TypeMirror expected, Iterable<TypeMirror> iterable) {
  for (var element in iterable) {
    if (element.originalDeclaration == expected.originalDeclaration) {
      return true;
    }
  }
  return false;
}

DeclarationMirror findMirror(Iterable<DeclarationMirror> list, String name) {
  for (DeclarationMirror mirror in list) {
    if (mirror.simpleName == name) {
      return mirror;
    }
  }
  return null;
}

main() {
  Uri scriptUri =
      currentDirectory.resolve(nativeToUriPath(new Options().script));
  Uri libUri = scriptUri.resolve('../../../sdk/');
  Uri inputUri = scriptUri.resolve('mirrors_helper.dart');
  var provider = new SourceFileProvider();
  var diagnosticHandler =
        new FormattingDiagnosticHandler(provider).diagnosticHandler;
  var result = analyze([inputUri], libUri, null,
                       provider.readStringFromUri, diagnosticHandler,
                       <String>['--preserve-comments']);
  result.then((MirrorSystem mirrors) {
    test(mirrors);
  });
}

void test(MirrorSystem mirrors) {
  Expect.isNotNull(mirrors, "No mirror system returned from compilation");

  var libraries = mirrors.libraries;
  Expect.isNotNull(libraries, "No libraries map returned");
  Expect.isFalse(libraries.isEmpty, "Empty libraries map returned");

  var helperLibrary = findMirror(libraries.values, "mirrors_helper");
  Expect.isNotNull(helperLibrary, "Library 'mirrors_helper' not found");
  Expect.stringEquals("mirrors_helper", helperLibrary.simpleName,
    "Unexpected library simple name");
  Expect.stringEquals("mirrors_helper", helperLibrary.qualifiedName,
    "Unexpected library qualified name");
  Expect.equals(helperLibrary, mirrors.findLibrary('mirrors_helper').single);

  var helperLibraryLocation = helperLibrary.location;
  Expect.isNotNull(helperLibraryLocation);
  Expect.equals(271, helperLibraryLocation.offset, "Unexpected offset");
  Expect.equals(23, helperLibraryLocation.length, "Unexpected length");
  Expect.equals(9, helperLibraryLocation.line, "Unexpected line");
  Expect.equals(1, helperLibraryLocation.column, "Unexpected column");


  var classes = helperLibrary.classes;
  Expect.isNotNull(classes, "No classes map returned");
  Expect.isFalse(classes.isEmpty, "Empty classes map returned");

  testFoo(mirrors, helperLibrary, classes);
  testBar(mirrors, helperLibrary, classes);
  testBaz(mirrors, helperLibrary, classes);
  // TODO(johnniwinther): Add test of class [Boz] and typedef [Func].
  // TODO(johnniwinther): Add tests of type argument substitution, which
  // is not currently implemented in dart2js.
  // TODO(johnniwinther): Add tests of Location and Source.
  testPrivate(mirrors, helperLibrary, classes);
  // TODO(johnniwinther): Add thorough tests of [LibraryMirror.functions],
  // [LibraryMirror.getters], [LibraryMirror.setters], [LibraryMirror.members],
  // and [LibraryMirror.variable].
  Expect.isNotNull(helperLibrary.functions);
  Expect.isNotNull(helperLibrary.members);
  Expect.isNotNull(helperLibrary.getters);
  Expect.isNotNull(helperLibrary.setters);
  Expect.isNotNull(helperLibrary.variables);
}

// Testing class Foo:
//
// class Foo {
//
// }
void testFoo(MirrorSystem system, LibraryMirror helperLibrary,
             Map<String,TypeMirror> classes) {
  var fooClass = classes["Foo"];
  Expect.isNotNull(fooClass, "Type 'Foo' not found");
  Expect.isTrue(fooClass is ClassMirror,
                "Unexpected mirror type returned");
  Expect.stringEquals("Foo", fooClass.simpleName,
                      "Unexpected type simple name");
  Expect.stringEquals("mirrors_helper.Foo", fooClass.qualifiedName,
                      "Unexpected type qualified name");

  Expect.equals(helperLibrary, fooClass.library,
                "Unexpected library returned from type");

  Expect.isFalse(fooClass.isObject, "Class is Object");
  Expect.isFalse(fooClass.isDynamic, "Class is dynamic");
  Expect.isFalse(fooClass.isVoid, "Class is void");
  Expect.isFalse(fooClass.isTypeVariable, "Class is a type variable");
  Expect.isFalse(fooClass.isTypedef, "Class is a typedef");
  Expect.isFalse(fooClass.isFunction, "Class is a function");

  Expect.isTrue(fooClass.isOriginalDeclaration);
  Expect.equals(fooClass, fooClass.originalDeclaration);

  Expect.isTrue(fooClass.isClass, "Class is not class");
  Expect.isFalse(fooClass.isAbstract);
  Expect.isFalse(fooClass.isInterface, "Class is interface");
  Expect.isFalse(fooClass.isPrivate, "Class is private");

  var objectType = fooClass.superclass;
  Expect.isNotNull(objectType, "Superclass is null");
  Expect.isTrue(objectType.isObject, "Object is not Object");
  Expect.isFalse(objectType.isOriginalDeclaration);
  Expect.isTrue(containsType(fooClass,
                             computeSubdeclarations(objectType)),
                "Class is not subclass of superclass");

  var fooInterfaces = fooClass.superinterfaces;
  Expect.isNotNull(fooInterfaces, "Interfaces map is null");
  Expect.isTrue(fooInterfaces.isEmpty, "Interfaces map is not empty");

  var fooSubdeclarations = computeSubdeclarations(fooClass);
  Expect.equals(1, count(fooSubdeclarations), "Unexpected subtype count");
  for (var fooSubdeclaration in fooSubdeclarations) {
    Expect.equals(fooClass, fooSubdeclaration.superclass.originalDeclaration);
  }

  Expect.throws(() => fooClass.typeArguments,
                (exception) => true,
                "Class has type arguments");
  var fooClassTypeVariables = fooClass.typeVariables;
  Expect.isNotNull(fooClassTypeVariables, "Type variable list is null");
  Expect.isTrue(fooClassTypeVariables.isEmpty,
                "Type variable list is not empty");

  Expect.isNull(fooClass.defaultFactory);

  var fooClassMembers = fooClass.members;
  Expect.isNotNull(fooClassMembers, "Declared members map is null");
  Expect.isTrue(fooClassMembers.isEmpty, "Declared members map is unempty");

  var fooClassConstructors = fooClass.constructors;
  Expect.isNotNull(fooClassConstructors, "Constructors map is null");
  Expect.isTrue(fooClassConstructors.isEmpty,
                "Constructors map is unempty");

  // TODO(johnniwinther): Add thorough tests of [ClassMirror.functions],
  // [ClassMirror.getters], [ClassMirror.setters], [ClassMirror.members],
  // and [ClassMirror.variable].
  Expect.isNotNull(fooClass.functions);
  Expect.isNotNull(fooClass.members);
  Expect.isNotNull(fooClass.getters);
  Expect.isNotNull(fooClass.setters);
  Expect.isNotNull(fooClass.variables);

  //////////////////////////////////////////////////////////////////////////////
  // Metadata tests
  //////////////////////////////////////////////////////////////////////////////

  var metadataList = fooClass.metadata;
  Expect.isNotNull(metadataList);
  Expect.equals(16, metadataList.length);
  var metadataListIndex = 0;
  var metadata;

  var dartMirrorsLibrary = system.libraries[DART_MIRRORS_URI];
  Expect.isNotNull(dartMirrorsLibrary);
  var commentType = dartMirrorsLibrary.classes['Comment'];
  Expect.isNotNull(commentType);

  // /// Singleline doc comment.
  metadata = metadataList[metadataListIndex++];
  Expect.isTrue(metadata is InstanceMirror);
  Expect.isFalse(metadata.hasReflectee);
  Expect.throws(() => metadata.reflectee, (_) => true);
  Expect.isTrue(metadata is CommentInstanceMirror);
  Expect.equals(commentType.originalDeclaration, metadata.type);
  Expect.isTrue(metadata.isDocComment);
  Expect.stringEquals(
      "/// Singleline doc comment.", metadata.text);
  Expect.stringEquals(
      "Singleline doc comment.", metadata.trimmedText);

  // @Metadata
  metadata = metadataList[metadataListIndex++];
  Expect.isTrue(metadata is InstanceMirror);
  Expect.isFalse(metadata.hasReflectee);
  Expect.throws(() => metadata.reflectee, (_) => true);
  Expect.isTrue(metadata is TypeInstanceMirror);
  var metadataType = metadata.representedType;
  Expect.isNotNull(metadataType);
  Expect.stringEquals('Metadata', metadataType.simpleName);

  // // This is intentionally the type literal.
  metadata = metadataList[metadataListIndex++];
  Expect.isTrue(metadata is InstanceMirror);
  Expect.isFalse(metadata.hasReflectee);
  Expect.throws(() => metadata.reflectee, (_) => true);
  Expect.isTrue(metadata is CommentInstanceMirror);
  Expect.equals(commentType.originalDeclaration, metadata.type);
  Expect.isFalse(metadata.isDocComment);
  Expect.stringEquals(
      "// This is intentionally the type literal.", metadata.text);
  Expect.stringEquals(
      "This is intentionally the type literal.", metadata.trimmedText);

  // Singleline comment 1.
  metadata = metadataList[metadataListIndex++];
  Expect.isTrue(metadata is InstanceMirror);
  Expect.isFalse(metadata.hasReflectee);
  Expect.throws(() => metadata.reflectee, (_) => true);
  Expect.isTrue(metadata is CommentInstanceMirror);
  Expect.equals(commentType.originalDeclaration, metadata.type);
  Expect.isFalse(metadata.isDocComment);
  Expect.stringEquals(
      "// Singleline comment 1.", metadata.text);
  Expect.stringEquals(
      "Singleline comment 1.", metadata.trimmedText);

  // Singleline comment 2.
  metadata = metadataList[metadataListIndex++];
  Expect.isTrue(metadata is InstanceMirror);
  Expect.isFalse(metadata.hasReflectee);
  Expect.throws(() => metadata.reflectee, (_) => true);
  Expect.isTrue(metadata is CommentInstanceMirror);
  Expect.equals(commentType.originalDeclaration, metadata.type);
  Expect.isFalse(metadata.isDocComment);
  Expect.stringEquals(
      "// Singleline comment 2.", metadata.text);
  Expect.stringEquals(
      "Singleline comment 2.", metadata.trimmedText);

  // @Metadata(null)
  metadata = metadataList[metadataListIndex++];
  Expect.isTrue(metadata is InstanceMirror);
  Expect.isFalse(metadata.hasReflectee);
  Expect.throws(() => metadata.reflectee, (_) => true);
  Expect.equals(metadataType.originalDeclaration, metadata.type);
  InstanceMirror data = metadata.getField('data');
  Expect.isNotNull(data);
  Expect.isTrue(data.hasReflectee);
  Expect.isNull(data.reflectee);

  // @Metadata(true)
  metadata = metadataList[metadataListIndex++];
  Expect.isTrue(metadata is InstanceMirror);
  Expect.isFalse(metadata.hasReflectee);
  Expect.throws(() => metadata.reflectee, (_) => true);
  Expect.equals(metadataType.originalDeclaration, metadata.type);
  data = metadata.getField('data');
  Expect.isNotNull(data);
  Expect.isTrue(data.hasReflectee);
  Expect.isTrue(data.reflectee);

  // @Metadata(false)
  metadata = metadataList[metadataListIndex++];
  Expect.isTrue(metadata is InstanceMirror);
  Expect.isFalse(metadata.hasReflectee);
  Expect.throws(() => metadata.reflectee, (_) => true);
  Expect.equals(metadataType.originalDeclaration, metadata.type);
  data = metadata.getField('data');
  Expect.isNotNull(data);
  Expect.isTrue(data.hasReflectee);
  Expect.isFalse(data.reflectee);

  // @Metadata(0)
  metadata = metadataList[metadataListIndex++];
  Expect.isTrue(metadata is InstanceMirror);
  Expect.isFalse(metadata.hasReflectee);
  Expect.throws(() => metadata.reflectee, (_) => true);
  Expect.equals(metadataType.originalDeclaration, metadata.type);
  data = metadata.getField('data');
  Expect.isNotNull(data);
  Expect.isTrue(data.hasReflectee);
  Expect.equals(0, data.reflectee);

  // @Metadata(1.5)
  metadata = metadataList[metadataListIndex++];
  Expect.isTrue(metadata is InstanceMirror);
  Expect.isFalse(metadata.hasReflectee);
  Expect.throws(() => metadata.reflectee, (_) => true);
  Expect.equals(metadataType.originalDeclaration, metadata.type);
  data = metadata.getField('data');
  Expect.isNotNull(data);
  Expect.isTrue(data.hasReflectee);
  Expect.equals(1.5, data.reflectee);

  // @Metadata("Foo")
  metadata = metadataList[metadataListIndex++];
  Expect.isTrue(metadata is InstanceMirror);
  Expect.isFalse(metadata.hasReflectee);
  Expect.throws(() => metadata.reflectee, (_) => true);
  Expect.equals(metadataType.originalDeclaration, metadata.type);
  data = metadata.getField('data');
  Expect.isNotNull(data);
  Expect.isTrue(data.hasReflectee);
  Expect.stringEquals("Foo", data.reflectee);

  // @Metadata(const ["Foo"])
  metadata = metadataList[metadataListIndex++];
  Expect.isTrue(metadata is InstanceMirror);
  Expect.isFalse(metadata.hasReflectee);
  Expect.throws(() => metadata.reflectee, (_) => true);
  Expect.equals(metadataType.originalDeclaration, metadata.type);
  data = metadata.getField('data');
  Expect.isTrue(data is ListInstanceMirror);
  Expect.isFalse(data.hasReflectee);
  Expect.throws(() => data.reflectee, (_) => true);
  ListInstanceMirror listData = data;
  Expect.equals(1, listData.length);
  InstanceMirror element = listData[0];
  Expect.isNotNull(element);
  Expect.isTrue(element.hasReflectee);
  Expect.stringEquals("Foo", element.reflectee);

  // @Metadata(/* Inline comment */ const {'foo':"Foo"})
  metadata = metadataList[metadataListIndex++];
  Expect.isTrue(metadata is InstanceMirror);
  Expect.isFalse(metadata.hasReflectee);
  Expect.throws(() => metadata.reflectee, (_) => true);
  Expect.equals(metadataType.originalDeclaration, metadata.type);
  data = metadata.getField('data');
  Expect.isTrue(data is MapInstanceMirror);
  Expect.isFalse(data.hasReflectee);
  Expect.throws(() => data.reflectee, (_) => true);
  MapInstanceMirror mapData = data;
  Expect.equals(1, mapData.length);
  var it = mapData.keys.iterator;
  Expect.isTrue(it.moveNext());
  Expect.stringEquals('foo', it.current);
  element = mapData['foo'];
  Expect.isNotNull(element);
  Expect.isTrue(element.hasReflectee);
  Expect.stringEquals("Foo", element.reflectee);
  Expect.isNull(mapData['bar']);

  // @metadata
  metadata = metadataList[metadataListIndex++];
  Expect.isTrue(metadata is InstanceMirror);
  Expect.isFalse(metadata.hasReflectee);
  Expect.throws(() => metadata.reflectee, (_) => true);
  Expect.equals(metadataType.originalDeclaration, metadata.type);
  data = metadata.getField('data');
  Expect.isNotNull(data);
  Expect.isTrue(data.hasReflectee);
  Expect.isNull(data.reflectee);

  // /** Multiline doc comment. */
  metadata = metadataList[metadataListIndex++];
  Expect.isTrue(metadata is InstanceMirror);
  Expect.isFalse(metadata.hasReflectee);
  Expect.throws(() => metadata.reflectee, (_) => true);
  Expect.isTrue(metadata is CommentInstanceMirror);
  Expect.equals(commentType.originalDeclaration, metadata.type);
  Expect.isTrue(metadata.isDocComment);
  Expect.stringEquals(
      "/** Multiline doc comment. */", metadata.text);
  Expect.stringEquals(
      "Multiline doc comment. ", metadata.trimmedText);

  // /* Multiline comment. */
  metadata = metadataList[metadataListIndex++];
  Expect.isTrue(metadata is InstanceMirror);
  Expect.isFalse(metadata.hasReflectee);
  Expect.throws(() => metadata.reflectee, (_) => true);
  Expect.isTrue(metadata is CommentInstanceMirror);
  Expect.equals(commentType.originalDeclaration, metadata.type);
  Expect.isFalse(metadata.isDocComment);
  Expect.stringEquals(
      "/* Multiline comment. */", metadata.text);
  Expect.stringEquals(
      "Multiline comment. ", metadata.trimmedText);

  Expect.equals(metadataList.length, metadataListIndex);

  //////////////////////////////////////////////////////////////////////////////
  // Location test
  //////////////////////////////////////////////////////////////////////////////

  var fooClassLocation = fooClass.location;
  Expect.isNotNull(fooClassLocation);
  // Expect the location to start with the first metadata, not including the
  // leading comment.
  Expect.equals(376, fooClassLocation.offset, "Unexpected offset");
  // Expect the location to end with the class body.
  Expect.equals(332, fooClassLocation.length, "Unexpected length");
  Expect.equals(18, fooClassLocation.line, "Unexpected line");
  Expect.equals(1, fooClassLocation.column, "Unexpected column");

}

// Testing abstract class Bar:
//
// abstract class Bar<E> {
//
// }
void testBar(MirrorSystem system, LibraryMirror helperLibrary,
             Map<String,TypeMirror> classes) {
  var barClass = classes["Bar"];
  Expect.isNotNull(barClass, "Type 'Bar' not found");
  Expect.isTrue(barClass is ClassMirror,
               "Unexpected mirror type returned");
  Expect.stringEquals("Bar", barClass.simpleName,
                      "Unexpected type simple name");
  Expect.stringEquals("mirrors_helper.Bar", barClass.qualifiedName,
                      "Unexpected type qualified name");

  Expect.equals(helperLibrary, barClass.library,
                "Unexpected library returned from type");

  Expect.isFalse(barClass.isObject, "Interface is Object");
  Expect.isFalse(barClass.isDynamic, "Interface is dynamic");
  Expect.isFalse(barClass.isVoid, "Interface is void");
  Expect.isFalse(barClass.isTypeVariable, "Interface is a type variable");
  Expect.isFalse(barClass.isTypedef, "Interface is a typedef");
  Expect.isFalse(barClass.isFunction, "Interface is a function");

  Expect.isTrue(barClass.isOriginalDeclaration);
  Expect.equals(barClass, barClass.originalDeclaration);

  Expect.isTrue(barClass.isClass);
  Expect.isTrue(barClass.isAbstract);
  Expect.isFalse(barClass.isInterface);
  Expect.isFalse(barClass.isPrivate, "Interface is private");

  var objectType = barClass.superclass;
  Expect.isNotNull(objectType, "Superclass is null");
  Expect.isTrue(objectType.isObject, "Object is not Object");
  Expect.isFalse(objectType.isOriginalDeclaration);
  Expect.isTrue(containsType(barClass,
                             computeSubdeclarations(objectType)),
                "Class is not subclass of superclass");

  var barInterfaces = barClass.superinterfaces;
  Expect.isNotNull(barInterfaces, "Interfaces map is null");
  Expect.isTrue(barInterfaces.isEmpty, "Interfaces map is not empty");

  var barSubdeclarations = computeSubdeclarations(barClass);
  Expect.equals(1, count(barSubdeclarations), "Unexpected subtype count");
  for (var barSubdeclaration in barSubdeclarations) {
    Expect.isTrue(containsType(barClass,
                               barSubdeclaration.superinterfaces),
                  "Interface is not superinterface of subclass");
  }

  Expect.throws(() => barClass.typeArguments,
              (exception) => true,
              "Interface has type arguments");
  var barInterfaceTypeVariables = barClass.typeVariables;
  Expect.isNotNull(barInterfaceTypeVariables, "Type variable list is null");
  Expect.isFalse(barInterfaceTypeVariables.isEmpty,
                 "Type variable list is empty");
  Expect.equals(barInterfaceTypeVariables.length, 1,
                "Unexpected number of type variables");

  var barE = barInterfaceTypeVariables[0];
  Expect.isNotNull(barE, "Type variable is null");
  Expect.isTrue(barE.isTypeVariable, "Type variable is not type variable");

  Expect.isNull(barClass.defaultFactory);

  var barInterfaceMembers = barClass.members;
  Expect.isNotNull(barInterfaceMembers, "Declared members map is null");
  Expect.isTrue(barInterfaceMembers.isEmpty,
                "Declared members map is unempty");

  var barInterfaceConstructors = barClass.constructors;
  Expect.isNotNull(barInterfaceConstructors, "Constructors map is null");
  Expect.isTrue(barInterfaceConstructors.isEmpty,
                "Constructors map is unempty");

  var metadata = barClass.metadata;
  Expect.isNotNull(metadata);
  Expect.equals(0, metadata.length);
}

// Testing class Baz:
//
// class Baz<E,F extends Foo> implements Bar<E> {
//   Baz();
//   const Baz.named();
//   factory Baz.factory() => new Baz<E,F>();
//
//   static method1(e) {}
//   void method2(E e, [F f = null]) {}
//   Baz<E,F> method3(E func1(F f), Func<E,F> func2) => null;
//
//   bool operator==(Object other) => false;
//   int operator -() => 0;
// }
void testBaz(MirrorSystem system, LibraryMirror helperLibrary,
             Map<String,TypeMirror> classes) {
  var bazClass = classes["Baz"];
  Expect.isNotNull(bazClass, "Type 'Baz' not found");
  Expect.isTrue(bazClass is ClassMirror,
                "Unexpected mirror type returned");
  Expect.stringEquals("Baz", bazClass.simpleName,
                      "Unexpected type simple name");
  Expect.stringEquals("mirrors_helper.Baz", bazClass.qualifiedName,
                      "Unexpected type qualified name");

  Expect.equals(helperLibrary, bazClass.library,
                "Unexpected library returned from type");

  Expect.isFalse(bazClass.isObject, "Class is Object");
  Expect.isFalse(bazClass.isDynamic, "Class is dynamic");
  Expect.isFalse(bazClass.isVoid, "Class is void");
  Expect.isFalse(bazClass.isTypeVariable, "Class is a type variable");
  Expect.isFalse(bazClass.isTypedef, "Class is a typedef");
  Expect.isFalse(bazClass.isFunction, "Class is a function");

  Expect.isTrue(bazClass.isOriginalDeclaration);
  Expect.equals(bazClass, bazClass.originalDeclaration);

  Expect.isTrue(bazClass.isClass, "Class is not class");
  Expect.isFalse(bazClass.isAbstract);
  Expect.isFalse(bazClass.isInterface, "Class is interface");
  Expect.isFalse(bazClass.isPrivate, "Class is private");

  var objectType = bazClass.superclass;
  Expect.isNotNull(objectType, "Superclass is null");
  Expect.isTrue(objectType.isObject, "Object is not Object");
  Expect.isFalse(objectType.isOriginalDeclaration);
  Expect.isTrue(containsType(bazClass,
                             computeSubdeclarations(objectType)),
                "Class is not subclass of superclass");

  var bazInterfaces = bazClass.superinterfaces;
  Expect.isNotNull(bazInterfaces, "Interfaces map is null");
  Expect.isTrue(!bazInterfaces.isEmpty, "Interfaces map is empty");
  for (var bazInterface in bazInterfaces) {
    Expect.isTrue(containsType(bazClass,
                               computeSubdeclarations(objectType)),
                  "Class is not subclass of superinterface");
  }

  var bazSubdeclarations = computeSubdeclarations(bazClass);
  Expect.equals(0, count(bazSubdeclarations), "Unexpected subtype count");

  var barInterface = findMirror(bazInterfaces, "Bar");
  Expect.isNotNull(barInterface, "Interface bar is missing");
  Expect.isFalse(barInterface.isOriginalDeclaration);
  var barInterfaceTypeArguments = barInterface.typeArguments;
  Expect.isNotNull(barInterfaceTypeArguments, "Type arguments are missing");
  Expect.equals(1, barInterfaceTypeArguments.length,
                "Type arguments is empty");

  Expect.throws(() => bazClass.typeArguments,
                (exception) => true,
                "Class has type arguments");
  var bazClassTypeVariables = bazClass.typeVariables;
  Expect.isNotNull(bazClassTypeVariables, "Type variable list is null");
  Expect.equals(2, bazClassTypeVariables.length,
                "Type variable list is not empty");

  var bazE = bazClassTypeVariables[0];
  Expect.isNotNull(bazE, "Type variable is null");
  Expect.stringEquals('E', bazE.simpleName, "Unexpected simpleName");
  Expect.stringEquals('mirrors_helper.Baz.E', bazE.qualifiedName,
                      "Unexpected qualifiedName");
  Expect.equals(bazClass, bazE.declarer,
                "Unexpected type variable declarer");
  var bazEbound = bazE.upperBound;
  Expect.isNotNull(bazEbound);
  Expect.isFalse(bazEbound.isOriginalDeclaration);
  Expect.isTrue(bazEbound.isObject, "Bound is not object");

  var bazF = bazClassTypeVariables[1];
  Expect.isNotNull(bazF, "Type variable is null");
  Expect.stringEquals('F', bazF.simpleName, "Unexpected simpleName");
  Expect.stringEquals('mirrors_helper.Baz.F', bazF.qualifiedName,
                      "Unexpected qualifiedName");
  Expect.equals(bazClass, bazF.declarer);
  var bazFbound = bazF.upperBound;
  Expect.isNotNull(bazFbound);
  Expect.isFalse(bazFbound.isOriginalDeclaration);
  Expect.stringEquals("mirrors_helper.Foo", bazFbound.qualifiedName,
                      "Bound is not Foo");

  Expect.isNull(bazClass.defaultFactory);

  var bazClassMembers = bazClass.members;
  Expect.isNotNull(bazClassMembers, "Declared members map is null");
  Expect.equals(8, bazClassMembers.length,
                "Unexpected number of declared members");

  ////////////////////////////////////////////////////////////////////////////
  // static method1(e) {}
  ////////////////////////////////////////////////////////////////////////////
  var method1 = bazClassMembers["method1"];
  Expect.isNotNull(method1, "method1 not found");
  Expect.stringEquals('method1', method1.simpleName,
                      "Unexpected method simpleName");
  Expect.stringEquals('mirrors_helper.Baz.method1', method1.qualifiedName,
                      "Unexpected method qualifiedName");
  Expect.equals(method1.owner, bazClass);
  Expect.isFalse(method1.isTopLevel);
  Expect.isFalse(method1.isConstructor);
  Expect.isFalse(method1.isVariable);
  Expect.isTrue(method1.isMethod);
  Expect.isFalse(method1.isPrivate);
  Expect.isTrue(method1.isStatic);
  Expect.isTrue(method1 is MethodMirror);
  Expect.isTrue(method1.isRegularMethod);
  Expect.isFalse(method1.isConstConstructor);
  Expect.isFalse(method1.isGenerativeConstructor);
  Expect.isFalse(method1.isRedirectingConstructor);
  Expect.isFalse(method1.isFactoryConstructor);
  Expect.isNull(method1.constructorName);
  Expect.isFalse(method1.isGetter);
  Expect.isFalse(method1.isSetter);
  Expect.isFalse(method1.isOperator);

  var dynamicType = method1.returnType;
  Expect.isNotNull(dynamicType, "Return type was null");
  Expect.isFalse(dynamicType.isObject, "dynamic is Object");
  Expect.isTrue(dynamicType.isDynamic, "dynamic is not dynamic");
  Expect.isFalse(dynamicType.isVoid, "dynamic is void");
  Expect.isFalse(dynamicType.isTypeVariable, "dynamic is a type variable");
  Expect.isFalse(dynamicType.isTypedef, "dynamic is a typedef");
  Expect.isFalse(dynamicType.isFunction, "dynamic is a function");

  var method1Parameters = method1.parameters;
  Expect.isNotNull(method1Parameters, "Method parameters is null");
  Expect.equals(1, method1Parameters.length, "Unexpected parameter count");
  var method1Parameter1 = method1Parameters[0];
  Expect.isNotNull(method1Parameter1, "Parameter is null");
  Expect.equals(dynamicType, method1Parameter1.type);
  Expect.stringEquals("e", method1Parameter1.simpleName,
                      "Unexpected parameter simpleName");
  Expect.stringEquals("mirrors_helper.Baz.method1#e",
                      method1Parameter1.qualifiedName,
                      "Unexpected parameter qualifiedName");
  Expect.isFalse(method1Parameter1.hasDefaultValue,
    "Parameter has default value");
  Expect.isNull(method1Parameter1.defaultValue,
    "Parameter default value is non-null");
  Expect.isFalse(method1Parameter1.isOptional, "Parameter is optional");

  ////////////////////////////////////////////////////////////////////////////
  // static void method2(E e, [F f = null]) {}
  ////////////////////////////////////////////////////////////////////////////
  var method2 = bazClassMembers["method2"];
  Expect.isNotNull(method2, "method2 not found");
  Expect.stringEquals('method2', method2.simpleName,
                      "Unexpected method simpleName");
  Expect.stringEquals('mirrors_helper.Baz.method2', method2.qualifiedName,
                      "Unexpected method qualifiedName");
  Expect.equals(method2.owner, bazClass);
  Expect.isFalse(method2.isTopLevel);
  Expect.isFalse(method2.isConstructor);
  Expect.isFalse(method2.isVariable);
  Expect.isTrue(method2.isMethod);
  Expect.isFalse(method2.isPrivate);
  Expect.isFalse(method2.isStatic);
  Expect.isTrue(method2 is MethodMirror);
  Expect.isTrue(method2.isRegularMethod);
  Expect.isFalse(method2.isConstConstructor);
  Expect.isFalse(method2.isGenerativeConstructor);
  Expect.isFalse(method2.isRedirectingConstructor);
  Expect.isFalse(method2.isFactoryConstructor);
  Expect.isNull(method2.constructorName);
  Expect.isFalse(method2.isGetter);
  Expect.isFalse(method2.isSetter);
  Expect.isFalse(method2.isOperator);

  var voidType = method2.returnType;
  Expect.isNotNull(voidType, "Return type was null");
  Expect.isFalse(voidType.isObject, "void is Object");
  Expect.isFalse(voidType.isDynamic, "void is dynamic");
  Expect.isTrue(voidType.isVoid, "void is not void");
  Expect.isFalse(voidType.isTypeVariable, "void is a type variable");
  Expect.isFalse(voidType.isTypedef, "void is a typedef");
  Expect.isFalse(voidType.isFunction, "void is a function");

  var method2Parameters = method2.parameters;
  Expect.isNotNull(method2Parameters, "Method parameters is null");
  Expect.equals(2, method2Parameters.length, "Unexpected parameter count");
  var method2Parameter1 = method2Parameters[0];
  Expect.isNotNull(method2Parameter1, "Parameter is null");
  Expect.equals(bazE, method2Parameter1.type);
  Expect.stringEquals("e", method2Parameter1.simpleName,
                      "Unexpected parameter simpleName");
  Expect.stringEquals("mirrors_helper.Baz.method2#e",
                      method2Parameter1.qualifiedName,
                      "Unexpected parameter qualifiedName");
  Expect.isFalse(method2Parameter1.hasDefaultValue,
                      "Parameter has default value");
  Expect.isNull(method2Parameter1.defaultValue,
                "Parameter default value is non-null");
  Expect.isFalse(method2Parameter1.isOptional, "Parameter is optional");
  var method2Parameter2 = method2Parameters[1];
  Expect.isNotNull(method2Parameter2, "Parameter is null");
  Expect.equals(bazF, method2Parameter2.type);
  Expect.stringEquals("f", method2Parameter2.simpleName,
                      "Unexpected parameter simpleName");
  Expect.stringEquals("mirrors_helper.Baz.method2#f",
                      method2Parameter2.qualifiedName,
                      "Unexpected parameter qualifiedName");
  Expect.isTrue(method2Parameter2.hasDefaultValue,
                 "Parameter has default value");
  Expect.stringEquals("null", method2Parameter2.defaultValue,
                      "Parameter default value is non-null");
  Expect.isTrue(method2Parameter2.isOptional, "Parameter is not optional");

  ////////////////////////////////////////////////////////////////////////////
  // Baz<E,F> method3(E func1(F f), Func<E,F> func2) => null;
  ////////////////////////////////////////////////////////////////////////////
  var method3 = bazClassMembers["method3"];
  Expect.isNotNull(method3, "method3 not found");
  Expect.stringEquals('method3', method3.simpleName,
                      "Unexpected method simpleName");
  Expect.stringEquals('mirrors_helper.Baz.method3', method3.qualifiedName,
                      "Unexpected method qualifiedName");
  Expect.equals(method3.owner, bazClass);
  Expect.isFalse(method3.isTopLevel);
  Expect.isFalse(method3.isConstructor);
  Expect.isFalse(method3.isVariable);
  Expect.isTrue(method3.isMethod);
  Expect.isFalse(method3.isPrivate);
  Expect.isFalse(method3.isStatic);
  Expect.isTrue(method3 is MethodMirror);
  Expect.isTrue(method3.isRegularMethod);
  Expect.isFalse(method3.isConstConstructor);
  Expect.isFalse(method3.isGenerativeConstructor);
  Expect.isFalse(method3.isRedirectingConstructor);
  Expect.isFalse(method3.isFactoryConstructor);
  Expect.isNull(method3.constructorName);
  Expect.isFalse(method3.isGetter);
  Expect.isFalse(method3.isSetter);
  Expect.isFalse(method3.isOperator);

  var method3ReturnType = method3.returnType;
  Expect.isNotNull(method3ReturnType, "Return type is null");
  Expect.isTrue(method3ReturnType is ClassMirror,
                "Return type is not interface");
  Expect.equals(bazClass, method3ReturnType.originalDeclaration);
  // TODO(johnniwinther): Test type arguments of [method3ReturnType].

  var method3Parameters = method3.parameters;
  Expect.isNotNull(method3Parameters, "Method parameters is null");
  Expect.equals(2, method3Parameters.length, "Unexpected parameter count");
  var method3Parameter1 = method3Parameters[0];
  Expect.isNotNull(method3Parameter1, "Parameter is null");
  var method3Parameter1type = method3Parameter1.type;
  Expect.isNotNull(method3Parameter1type, "Parameter type of 'func1' is null");
  Expect.isTrue(method3Parameter1type is FunctionTypeMirror,
                "Parameter type of 'func1' is not a function");
  Expect.equals(bazE, method3Parameter1type.returnType,
                "Return type of 'func1' is not a E");
  Expect.isNotNull(method3Parameter1type.parameters,
                   "Parameters of 'func1' is null");
  Expect.equals(1, method3Parameter1type.parameters.length,
                "Unexpected parameter count of 'func1'");
  Expect.equals(bazE, method3Parameter1type.returnType,
                "Return type of 'func1' is not a E");
  Expect.isNotNull(method3Parameter1type.parameters[0],
                "Parameter 1 of 'func1' is null");
  Expect.stringEquals('f', method3Parameter1type.parameters[0].simpleName,
                "Unexpected name parameter 1 of 'func1'");
  Expect.equals(bazF, method3Parameter1type.parameters[0].type,
                "Argument type of 'func1' is not a F");
  Expect.stringEquals("func1", method3Parameter1.simpleName,
                      "Unexpected parameter simpleName");
  Expect.stringEquals("mirrors_helper.Baz.method3#func1",
                      method3Parameter1.qualifiedName,
                      "Unexpected parameter qualifiedName");
  Expect.isFalse(method3Parameter1.hasDefaultValue,
                 "Parameter has default value");
  Expect.isNull(method3Parameter1.defaultValue,
                "Parameter default value is non-null");
  Expect.isFalse(method3Parameter1.isOptional, "Parameter is optional");

  var method3Parameter2 = method3Parameters[1];
  Expect.isNotNull(method3Parameter2, "Parameter is null");
  var funcTypedef = method3Parameter2.type;
  Expect.isNotNull(funcTypedef, "Parameter type is null");
  Expect.stringEquals("Func", funcTypedef.simpleName,
                      "Unexpected simpleName");
  Expect.stringEquals("mirrors_helper.Func", funcTypedef.qualifiedName,
                      "Unexpected simpleName");
  Expect.isFalse(funcTypedef.isObject, "Typedef is Object");
  Expect.isFalse(funcTypedef.isDynamic, "Typedef is dynamic");
  Expect.isFalse(funcTypedef.isVoid, "Typedef is void");
  Expect.isFalse(funcTypedef.isTypeVariable, "Typedef is a type variable");
  Expect.isTrue(funcTypedef.isTypedef, "Typedef is not a typedef");
  Expect.isFalse(funcTypedef.isFunction, "Typedef is a function");

  Expect.equals(helperLibrary, funcTypedef.library,
                "Unexpected typedef library");
  Expect.isNull(funcTypedef.superclass, "Non-null superclass on typedef");
  Expect.isNotNull(funcTypedef.superinterfaces);
  Expect.isTrue(funcTypedef.superinterfaces.isEmpty);
  Expect.isNotNull(funcTypedef.members);
  Expect.isTrue(funcTypedef.members.isEmpty);

  // TODO(johnniwinther): Returned typedef should not be the original
  // declaration:
  Expect.isTrue(funcTypedef.isOriginalDeclaration);
  Expect.isFalse(funcTypedef.isClass, "Typedef is class");
  Expect.isFalse(funcTypedef.isInterface, "Typedef is interface");
  Expect.isFalse(funcTypedef.isPrivate, "Typedef is private");
  Expect.isNull(funcTypedef.defaultFactory);
  // TODO(johnniwinther): Should not throw an exception since the type should
  // not be the original declaration.
  Expect.throws(() => funcTypedef.typeArguments,
                (exception) => true,
                "Typedef has type arguments");
  var funcTypedefTypeVariables = funcTypedef.typeVariables;
  Expect.isNotNull(funcTypedefTypeVariables);
  Expect.equals(2, funcTypedefTypeVariables.length);

  var funcTypedefDefinition = funcTypedef.value;
  Expect.isNotNull(funcTypedefDefinition);
  Expect.isTrue(funcTypedefDefinition is FunctionTypeMirror);

  Expect.stringEquals("func2", method3Parameter2.simpleName,
                      "Unexpected parameter simpleName");
  Expect.stringEquals("mirrors_helper.Baz.method3#func2",
                      method3Parameter2.qualifiedName,
                      "Unexpected parameter qualifiedName");
  Expect.isFalse(method3Parameter2.hasDefaultValue,
                 "Parameter 'func2' has default value: "
                 "${method3Parameter2.defaultValue}");
  Expect.isNull(method3Parameter2.defaultValue,
                "Parameter default value is non-null");
  Expect.isFalse(method3Parameter2.isOptional, "Parameter is optional");

  ////////////////////////////////////////////////////////////////////////////
  // bool operator==(Object other) => false;
  ////////////////////////////////////////////////////////////////////////////
  var operator_eq = bazClassMembers['=='];
  Expect.isNotNull(operator_eq, "operator == not found");
  Expect.stringEquals('==', operator_eq.simpleName,
                      "Unexpected method simpleName");
  Expect.stringEquals('operator ==', displayName(operator_eq));
  Expect.stringEquals('mirrors_helper.Baz.==',
                      operator_eq.qualifiedName,
                      "Unexpected method qualifiedName");
  Expect.equals(operator_eq.owner, bazClass);
  Expect.isFalse(operator_eq.isTopLevel);
  Expect.isFalse(operator_eq.isConstructor);
  Expect.isFalse(operator_eq.isVariable);
  Expect.isTrue(operator_eq.isMethod);
  Expect.isFalse(operator_eq.isPrivate);
  Expect.isFalse(operator_eq.isStatic);
  Expect.isTrue(operator_eq is MethodMirror);
  Expect.isTrue(operator_eq.isRegularMethod);
  Expect.isFalse(operator_eq.isConstConstructor);
  Expect.isFalse(operator_eq.isGenerativeConstructor);
  Expect.isFalse(operator_eq.isRedirectingConstructor);
  Expect.isFalse(operator_eq.isFactoryConstructor);
  Expect.isNull(operator_eq.constructorName);
  Expect.isFalse(operator_eq.isGetter);
  Expect.isFalse(operator_eq.isSetter);
  Expect.isTrue(operator_eq.isOperator);
  Expect.stringEquals('==', operatorName(operator_eq));

  ////////////////////////////////////////////////////////////////////////////
  // int operator -() => 0;
  ////////////////////////////////////////////////////////////////////////////
  var operator_negate = bazClassMembers[Mirror.UNARY_MINUS];
  Expect.isNotNull(operator_negate, "operator < not found");
  Expect.stringEquals(Mirror.UNARY_MINUS, operator_negate.simpleName,
                      "Unexpected method simpleName");
  Expect.stringEquals('operator -', displayName(operator_negate));
  Expect.stringEquals('mirrors_helper.Baz.${Mirror.UNARY_MINUS}',
                      operator_negate.qualifiedName,
                      "Unexpected method qualifiedName");
  Expect.equals(operator_negate.owner, bazClass);
  Expect.isFalse(operator_negate.isTopLevel);
  Expect.isFalse(operator_negate.isConstructor);
  Expect.isFalse(operator_negate.isVariable);
  Expect.isTrue(operator_negate.isMethod);
  Expect.isFalse(operator_negate.isPrivate);
  Expect.isFalse(operator_negate.isStatic);
  Expect.isTrue(operator_negate is MethodMirror);
  Expect.isTrue(operator_negate.isRegularMethod);
  Expect.isFalse(operator_negate.isConstConstructor);
  Expect.isFalse(operator_negate.isGenerativeConstructor);
  Expect.isFalse(operator_negate.isRedirectingConstructor);
  Expect.isFalse(operator_negate.isFactoryConstructor);
  Expect.isNull(operator_negate.constructorName);
  Expect.isFalse(operator_negate.isGetter);
  Expect.isFalse(operator_negate.isSetter);
  Expect.isTrue(operator_negate.isOperator);
  Expect.stringEquals('-', operatorName(operator_negate));


  var bazClassConstructors = bazClass.constructors;
  Expect.isNotNull(bazClassConstructors, "Constructors map is null");
  Expect.equals(3, bazClassConstructors.length,
                "Unexpected number of constructors");

  ////////////////////////////////////////////////////////////////////////////
  //   Baz();
  ////////////////////////////////////////////////////////////////////////////
  var bazClassNonameConstructor = bazClassConstructors['Baz'];
  Expect.isNotNull(bazClassNonameConstructor);
  Expect.isTrue(bazClassNonameConstructor is MethodMirror);
  Expect.isTrue(bazClassNonameConstructor.isConstructor);
  Expect.isFalse(bazClassNonameConstructor.isRegularMethod);
  Expect.isFalse(bazClassNonameConstructor.isConstConstructor);
  Expect.isTrue(bazClassNonameConstructor.isGenerativeConstructor);
  Expect.isFalse(bazClassNonameConstructor.isRedirectingConstructor);
  Expect.isFalse(bazClassNonameConstructor.isFactoryConstructor);
  Expect.stringEquals('Baz', bazClassNonameConstructor.simpleName);
  Expect.stringEquals('Baz', displayName(bazClassNonameConstructor));
  Expect.stringEquals('mirrors_helper.Baz.Baz',
      bazClassNonameConstructor.qualifiedName);
  Expect.stringEquals('', bazClassNonameConstructor.constructorName);

  ////////////////////////////////////////////////////////////////////////////
  //   const Baz.named();
  ////////////////////////////////////////////////////////////////////////////
  var bazClassNamedConstructor = bazClassConstructors['Baz.named'];
  Expect.isNotNull(bazClassNamedConstructor);
  Expect.isTrue(bazClassNamedConstructor is MethodMirror);
  Expect.isTrue(bazClassNamedConstructor.isConstructor);
  Expect.isFalse(bazClassNamedConstructor.isRegularMethod);
  Expect.isTrue(bazClassNamedConstructor.isConstConstructor);
  Expect.isFalse(bazClassNamedConstructor.isGenerativeConstructor);
  Expect.isFalse(bazClassNamedConstructor.isRedirectingConstructor);
  Expect.isFalse(bazClassNamedConstructor.isFactoryConstructor);
  Expect.stringEquals('Baz.named', bazClassNamedConstructor.simpleName);
  Expect.stringEquals('Baz.named', displayName(bazClassNamedConstructor));
  Expect.stringEquals('mirrors_helper.Baz.Baz.named',
      bazClassNamedConstructor.qualifiedName);
  Expect.stringEquals('named', bazClassNamedConstructor.constructorName);

  ////////////////////////////////////////////////////////////////////////////
  //   factory Baz.factory() => new Baz<E,F>();
  ////////////////////////////////////////////////////////////////////////////
  var bazClassFactoryConstructor = bazClassConstructors['Baz.factory'];
  Expect.isNotNull(bazClassFactoryConstructor);
  Expect.isTrue(bazClassFactoryConstructor is MethodMirror);
  Expect.isTrue(bazClassFactoryConstructor.isConstructor);
  Expect.isFalse(bazClassFactoryConstructor.isRegularMethod);
  Expect.isFalse(bazClassFactoryConstructor.isConstConstructor);
  Expect.isFalse(bazClassFactoryConstructor.isGenerativeConstructor);
  Expect.isFalse(bazClassFactoryConstructor.isRedirectingConstructor);
  Expect.isTrue(bazClassFactoryConstructor.isFactoryConstructor);
  Expect.stringEquals('Baz.factory', bazClassFactoryConstructor.simpleName);
  Expect.stringEquals('Baz.factory', displayName(bazClassFactoryConstructor));
  Expect.stringEquals('mirrors_helper.Baz.Baz.factory',
      bazClassFactoryConstructor.qualifiedName);
  Expect.stringEquals('factory', bazClassFactoryConstructor.constructorName);

  // TODO(johnniwinther): Add more tests of constructors.
  // TODO(johnniwinther): Add a test for unnamed factory methods.

  var metadata = bazClass.metadata;
  Expect.isNotNull(metadata);
  Expect.equals(0, metadata.length);
}

// class _PrivateClass {
//   var _privateField;
//   get _privateGetter => _privateField;
//   void set _privateSetter(value) => _privateField = value;
//   void _privateMethod() {}
//   _PrivateClass._privateConstructor();
//   factory _PrivateClass._privateFactoryConstructor() => new _PrivateClass();
// }
void testPrivate(MirrorSystem system, LibraryMirror helperLibrary,
                 Map<String,TypeMirror> classes) {
  var privateClass = classes['_PrivateClass'];
  Expect.isNotNull(privateClass);
  Expect.isTrue(privateClass is ClassMirror);
  Expect.isTrue(privateClass.isClass);
  Expect.isFalse(privateClass.isAbstract);
  Expect.isTrue(privateClass.isPrivate);

  var privateField = privateClass.members['_privateField'];
  Expect.isNotNull(privateField);
  Expect.isTrue(privateField is VariableMirror);
  Expect.isTrue(privateField.isPrivate);

  var privateGetter = privateClass.members['_privateGetter'];
  Expect.isNotNull(privateGetter);
  Expect.isTrue(privateGetter is MethodMirror);
  Expect.isTrue(privateGetter.isGetter);
  Expect.isTrue(privateGetter.isPrivate);
  Expect.isFalse(privateGetter.isRegularMethod);

  var privateSetter = privateClass.members['_privateSetter='];
  Expect.isNotNull(privateSetter);
  Expect.isTrue(privateSetter is MethodMirror);
  Expect.isTrue(privateSetter.isSetter);
  Expect.isTrue(privateSetter.isPrivate);
  Expect.isFalse(privateSetter.isRegularMethod);

  var privateMethod = privateClass.members['_privateMethod'];
  Expect.isNotNull(privateMethod);
  Expect.isTrue(privateMethod is MethodMirror);
  Expect.isTrue(privateMethod.isPrivate);
  Expect.isTrue(privateMethod.isRegularMethod);

  var privateConstructor =
      privateClass.members['_PrivateClass._privateConstructor'];
  Expect.isNotNull(privateConstructor);
  Expect.isTrue(privateConstructor is MethodMirror);
  Expect.isTrue(privateConstructor.isConstructor);
  Expect.isTrue(privateConstructor.isPrivate);
  Expect.isFalse(privateConstructor.isConstConstructor);
  Expect.isFalse(privateConstructor.isRedirectingConstructor);
  Expect.isTrue(privateConstructor.isGenerativeConstructor);
  Expect.isFalse(privateConstructor.isFactoryConstructor);

  var privateFactoryConstructor =
      privateClass.members['_PrivateClass._privateFactoryConstructor'];
  Expect.isNotNull(privateFactoryConstructor);
  Expect.isTrue(privateFactoryConstructor is MethodMirror);
  Expect.isTrue(privateFactoryConstructor.isConstructor);
  Expect.isTrue(privateFactoryConstructor.isPrivate);
  Expect.isFalse(privateFactoryConstructor.isConstConstructor);
  Expect.isFalse(privateFactoryConstructor.isRedirectingConstructor);
  Expect.isFalse(privateFactoryConstructor.isGenerativeConstructor);
  Expect.isTrue(privateFactoryConstructor.isFactoryConstructor);

  var metadata = privateClass.metadata;
  Expect.isNotNull(metadata);
  Expect.equals(0, metadata.length);
}
