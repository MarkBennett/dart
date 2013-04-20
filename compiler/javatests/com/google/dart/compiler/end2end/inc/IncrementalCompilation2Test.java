// Copyright (c) 2012, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
package com.google.dart.compiler.end2end.inc;

import com.google.common.base.Joiner;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;
import com.google.dart.compiler.CompilerTestCase;
import com.google.dart.compiler.DartCompilationError;
import com.google.dart.compiler.DartCompiler;
import com.google.dart.compiler.DartCompilerErrorCode;
import com.google.dart.compiler.DartCompilerListener;
import com.google.dart.compiler.DartSource;
import com.google.dart.compiler.DefaultCompilerConfiguration;
import com.google.dart.compiler.LibrarySource;
import com.google.dart.compiler.MockArtifactProvider;
import com.google.dart.compiler.PackageLibraryManager;
import com.google.dart.compiler.Source;
import com.google.dart.compiler.UrlSource;
import com.google.dart.compiler.ast.DartUnit;
import com.google.dart.compiler.ast.LibraryUnit;
import com.google.dart.compiler.common.ErrorExpectation;
import com.google.dart.compiler.resolver.ResolverErrorCode;
import com.google.dart.compiler.resolver.TypeErrorCode;
import com.google.dart.compiler.type.TypeQuality;

import static com.google.dart.compiler.DartCompiler.EXTENSION_DEPS;
import static com.google.dart.compiler.DartCompiler.EXTENSION_TIMESTAMP;
import static com.google.dart.compiler.common.ErrorExpectation.assertErrors;
import static com.google.dart.compiler.common.ErrorExpectation.errEx;

import junit.framework.AssertionFailedError;

import java.io.IOException;
import java.io.Reader;
import java.io.Writer;
import java.net.URI;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentSkipListSet;

// TODO(zundel): update this test not to rely on code generation
public class IncrementalCompilation2Test extends CompilerTestCase {
  private static final String APP = "Application.dart";

  private static class IncMockArtifactProvider extends MockArtifactProvider {
    Set<String> reads = new ConcurrentSkipListSet<String>();
    Set<String> writes = new ConcurrentSkipListSet<String>();

    @Override
    public Reader getArtifactReader(Source source, String part, String extension) {
      reads.add(source.getName() + "/" + extension);
      return super.getArtifactReader(source, part, extension);
    }

    @Override
    public Writer getArtifactWriter(Source source, String part, String extension) {
      writes.add(source.getName() + "/" + extension);
      return super.getArtifactWriter(source, part, extension);
    }

    void resetReadsAndWrites() {
      reads.clear();
      writes.clear();
    }
  }

  private DefaultCompilerConfiguration config;
  private IncMockArtifactProvider provider;
  private MemoryLibrarySource appSource;
  private final List<DartCompilationError> errors = Lists.newArrayList();
  private final Map<String, DartUnit> units = Maps.newHashMap();

  @Override
  protected void setUp() throws Exception {
    config = new DefaultCompilerConfiguration() {
      @Override
      public boolean incremental() {
        return true;
      }
    };
    provider = new IncMockArtifactProvider();
    appSource = new MemoryLibrarySource(APP);
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library application;",
            "part 'A.dart';",
            "part 'B.dart';",
            "part 'C.dart';",
            ""));
    appSource.setContent("A.dart", "part of application;");
    appSource.setContent("B.dart", "part of application;");
    appSource.setContent("C.dart", "part of application;");
  }

  @Override
  protected void tearDown() {
    config = null;
    provider = null;
    appSource = null;
    errors.clear();
    units.clear();
  }

  /**
   * "not_hole" is referenced using "super" qualifier, so is not affected by declaring top-level
   * field with same name.
   */
  public void test_useQualifiedFieldReference_ignoreTopLevelDeclaration() {
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "class A {",
            "  int not_hole;",
            "}",
            ""));
    appSource.setContent(
        "C.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "class B extends A {",
            "  int bar() {",
            "    return super.not_hole;", // qualified reference
            "  }",
            "}",
            ""));
    compile();
    assertErrors(errors);
    // Update units and compile.
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "int not_hole;",
            ""));
    compile();
    // TODO(scheglov) Fix this after 1159
    //assertErrors(errors, errEx(ResolverErrorCode.DUPLICATE_LOCAL_VARIABLE_WARNING, -1, 7, 20));
    // B should be compiled because it now conflicts with A.
    // C should not be compiled, because it reference "not_hole" field, not top-level variable.
    didWrite("A.dart", EXTENSION_TIMESTAMP);
    didWrite("B.dart", EXTENSION_TIMESTAMP);
    didNotWrite("C.dart", EXTENSION_TIMESTAMP);
    assertAppBuilt();
  }

  /**
   * Referenced "hole" identifier can not be resolved, but when we declare it in A, then B should be
   * recompiled and error message disappear.
   */
  public void test_useUnresolvedField_recompileOnTopLevelDeclaration() {
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "class A {",
            "  int foo() {",
            "    return hole;", // no such field
            "  }",
            "}",
            ""));
    compile();
    assertErrors(errors, errEx(TypeErrorCode.CANNOT_BE_RESOLVED, 5, 12, 4));
    // Update units and compile.
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "int hole;",
            ""));
    compile();
    // A and B should be compiled.
    didWrite("A.dart", EXTENSION_TIMESTAMP);
    didWrite("B.dart", EXTENSION_TIMESTAMP);
    assertAppBuilt();
    // "hole" was filled with top-level field.
    assertErrors(errors);
  }

  /**
   * Test for "hole" feature. If we use unqualified invocation and add/remove top-level method, this
   * should cause compilation of invocation unit.
   */
  public void test_isMethodHole_useUnqualifiedInvocation() throws Exception {
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "class A {",
            "  foo() {}",
            "}",
            ""));
    appSource.setContent(
        "C.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "class B extends A {",
            "  int bar() {",
            "    foo();", // unqualified invocation
            "  }",
            "}",
            ""));
    compile();
    assertErrors(errors);
    // Declare top-level foo(), now invocation of foo() in B should be bound to this top-level.
    {
      appSource.setContent(
          "A.dart",
          makeCode(
              "// filler filler filler filler filler filler filler filler filler filler filler",
              "part of application;",
              "foo() {}",
              ""));
      compile();
      // B should be compiled because it also declares foo(), so produces "shadow" conflict.
      // C should be compiled because it has unqualified invocation which was declared in A.
      didWrite("A.dart", EXTENSION_TIMESTAMP);
      didWrite("B.dart", EXTENSION_TIMESTAMP);
      didWrite("C.dart", EXTENSION_TIMESTAMP);
      assertAppBuilt();
    }
    // Wait, because analysis is so fast that may be A will have same time as old artifact.
    Thread.sleep(5);
    // Remove top-level foo(), so invocation of foo() in B should be bound to the super class.
    {
      appSource.setContent("A.dart", "part of application;");
      compile();
      // B should be compiled because it also declares foo(), so produces "shadow" conflict.
      // C should be compiled because it has unqualified invocation which was declared in A.
      didWrite("A.dart", EXTENSION_TIMESTAMP);
      didWrite("B.dart", EXTENSION_TIMESTAMP);
      didWrite("C.dart", EXTENSION_TIMESTAMP);
    }
  }

  /**
   * Test for "hole" feature. If we use qualified invocation and add/remove top-level method, this
   * should not cause compilation of invocation unit.
   */
  public void test_notMethodHole_useQualifiedInvocation() {
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "class A {",
            "  foo() {}",
            "}",
            ""));
    appSource.setContent(
        "C.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "class B extends A {",
            "  int bar() {",
            "    super.foo();", // qualified invocation
            "  }",
            "}",
            ""));
    compile();
    assertErrors(errors);
    // Declare top-level foo(), but it is ignored.
    {
      appSource.setContent(
          "A.dart",
          makeCode(
              "// filler filler filler filler filler filler filler filler filler filler filler",
              "part of application;",
              "foo() {}",
              ""));
      compile();
      // B should be compiled because it also declares foo(), so produces "shadow" conflict.
      // C should not be compiled because.
      didWrite("A.dart", EXTENSION_TIMESTAMP);
      didWrite("B.dart", EXTENSION_TIMESTAMP);
      didNotWrite("C.dart", EXTENSION_TIMESTAMP);
      assertAppBuilt();
    }
  }

  /**
   * Test for "hole" feature. If we use unqualified access and add/remove top-level field, this
   * should cause compilation of invocation unit.
   */
  public void test_fieldHole_useUnqualifiedAccess() throws Exception {
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "class A {",
            "  var foo;",
            "}",
            ""));
    appSource.setContent(
        "C.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "class B extends A {",
            "  int bar() {",
            "    foo = 0;", // unqualified access
            "  }",
            "}",
            ""));
    compile();
    assertErrors(errors);
    // Declare top-level "foo", now access to "foo" in B should be bound to this top-level.
    {
      appSource.setContent(
          "A.dart",
          makeCode(
              "// filler filler filler filler filler filler filler filler filler filler filler",
              "part of application;",
              "var foo;",
              ""));
      compile();
      // B should be compiled because it also declares "foo", so produces "shadow" conflict.
      // C should be compiled because it has unqualified invocation which was declared in A.
      didWrite("A.dart", EXTENSION_TIMESTAMP);
      didWrite("B.dart", EXTENSION_TIMESTAMP);
      didWrite("C.dart", EXTENSION_TIMESTAMP);
      assertAppBuilt();
    }
    // Wait, because analysis is so fast that may be A will have same time as old artifact.
    Thread.sleep(5);
    // Remove top-level "foo", so access to "foo" in B should be bound to the super class.
    {
      appSource.setContent("A.dart", "part of application;");
      compile();
      // B should be compiled because it also declares "foo", so produces "shadow" conflict.
      // C should be compiled because it has unqualified access which was declared in A.
      didWrite("A.dart", EXTENSION_TIMESTAMP);
      didWrite("B.dart", EXTENSION_TIMESTAMP);
      didWrite("C.dart", EXTENSION_TIMESTAMP);
    }
  }

  /**
   * Test for "hole" feature. If we use qualified access and add/remove top-level field, this should
   * not cause compilation of invocation unit.
   */
  public void test_fieldHole_useQualifiedAccess() {
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "class A {",
            "  var foo;",
            "}",
            ""));
    appSource.setContent(
        "C.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "class B extends A {",
            "  int bar() {",
            "    super.foo = 0;", // qualified access
            "  }",
            "}",
            ""));
    compile();
    assertErrors(errors);
    // Declare top-level "foo", but it is ignored.
    {
      appSource.setContent(
          "A.dart",
          makeCode(
              "// filler filler filler filler filler filler filler filler filler filler filler",
              "part of application;",
              "var foo;",
              ""));
      compile();
      // B should be compiled because it also declares "foo", so produces "shadow" conflict.
      // C should not be compiled because it has qualified access to "foo".
      didWrite("A.dart", EXTENSION_TIMESTAMP);
      didWrite("B.dart", EXTENSION_TIMESTAMP);
      didNotWrite("C.dart", EXTENSION_TIMESTAMP);
      assertAppBuilt();
    }
  }

  public void test_declareTopLevel_conflictWithLocalVariable() {
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "methodB() {",
            "  var symbolDependency_foo;",
            "}"));
    compile();
    assertErrors(errors);
    // Update units and compile.
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "var symbolDependency_foo;"));
    compile();
    // Now there is top-level declarations conflict between A and B.
    // So, B should be compiled.
    didWrite("B.dart", EXTENSION_TIMESTAMP);
    // But application should be build.
    assertAppBuilt();
  }

  public void test_undeclareTopLevel_conflictWithLocalVariable() {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "var duplicate;"));
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "bar() {",
            "  var duplicate;",
            "}"));
    compile();
    // Update units and compile.
    appSource.setContent("A.dart", "part of application;");
    compile();
    // Top-level declaration in A was removed, so no conflict.
    // So:
    // ... B should be recompiled.
    didWrite("B.dart", EXTENSION_TIMESTAMP);
    // ... but application should be rebuild.
    assertAppBuilt();
  }

  /**
   * Removes A, so changes set of top level units and forces compilation.
   */
  public void test_removeOneSource() {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "var duplicate;"));
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "bar() {",
            "  var duplicate;",
            "}"));
    compile();
    // Exclude A and compile.
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library app;",
            "part 'B.dart';",
            ""));
    compile();
    // Now there is top-level declarations conflict between A and B.
    // So:
    // ... B should be recompiled.
    didWrite("B.dart", EXTENSION_TIMESTAMP);
    // ... but application should be rebuild.
    didWrite(APP, EXTENSION_DEPS);
  }

  public void test_declareField_conflictWithLocalVariable() {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "class A {",
            "}",
            ""));
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "class B extends A {",
            "  foo() {",
            "    var bar;",
            "  }",
            "}",
            ""));
    compile();
    assertErrors(errors);
    // Update units and compile.
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "class A {",
            "  var bar;",
            "}",
            ""));
    compile();
    // B depends on A class, so compiled.
    didWrite("B.dart", EXTENSION_TIMESTAMP);
    assertAppBuilt();
  }

  public void test_declareTopLevelVariable_conflictOtherTopLevelVariable() {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "var conflict;",
            ""));
    compile();
    assertErrors(errors);
    // Update units and compile.
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "var conflict;",
            ""));
    compile();
    // A symbols intersect with new B symbols, so we compile A too.
    // Both A and B have errors.
    assertErrors(
        errors,
        errEx("A.dart", ResolverErrorCode.DUPLICATE_TOP_LEVEL_DECLARATION, 3, 5, 8),
        errEx("B.dart", ResolverErrorCode.DUPLICATE_TOP_LEVEL_DECLARATION, 3, 5, 8));
  }

  /**
   * Test that invalid "import" is reported as any other error between "unitAboutToCompile" and
   * "unitCompiled".
   */
  public void test_reportMissingImport() throws Exception {
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library app;",
            "import 'dart:noSuchLib.dart';",
            ""));
    // Remember errors only between unitAboutToCompile/unitCompiled.
    errors.clear();
    DartCompilerListener listener = new DartCompilerListener.Empty() {
      boolean isCompiling = false;

      @Override
      public void unitAboutToCompile(DartSource source, boolean diet) {
        isCompiling = true;
      }

      @Override
      public void onError(DartCompilationError event) {
        if (isCompiling) {
          errors.add(event);
        }
      }

      @Override
      public void unitCompiled(DartUnit unit) {
        isCompiling = false;
      }
    };
    DartCompiler.compileLib(appSource, config, provider, listener);
    // Check that errors where reported (and in correct time).
    assertErrors(errors, errEx(DartCompilerErrorCode.MISSING_SOURCE, 3, 1, 29));
  }

  /**
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=6859
   */
  public void test_reportMissingImport_dart() throws Exception {
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library app;",
            "import 'dart:mirrors as mirrors';",
            ""));
    compile();
    // Check that errors where reported (and in correct time).
    assertErrors(errors, errEx(DartCompilerErrorCode.MISSING_SOURCE, 3, 1, 33));
  }

  /**
   * Test that same prefix can be used to import several libraries.
   */
  public void test_samePrefix_severalLibraries() throws Exception {
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library application;",
            "import 'A.dart' as p;",
            "import 'B.dart' as p;",
            "f() {",
            "  p.a = 1;",
            "  p.b = 2;",
            "}",
            ""));
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library A;",
            "var a;",
            ""));
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library B;",
            "var b;",
            ""));
    // do compile, no errors expected
    compile();
    assertErrors(errors);
  }

  /**
   * Checks that it is a compile-time error when a library directly imports two other libraries that
   * have the same library name.
   */
  public void test_importTwoLibraries_withSameName() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library duplicate_name;",
            ""));
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library duplicate_name;",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.app;",
            "import 'A.dart';",
            "import 'B.dart';",
            "main() {",
            "}",
            ""));
    compile();
    assertErrors(
        errors,
        errEx(APP, DartCompilerErrorCode.DUPLICATE_IMPORTED_LIBRARY_NAME, 4, 1, 16));
  }

  /**
   * Checks valid library definitions with metadata.
   */
  public void test_importLibrary_withMetaBeforeLibraryDirective() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "@meta library A;",
            "const int meta = 1;",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.app;",
            "import 'A.dart';",
            ""));
    compile();
    assertErrors(errors);
  }

  /**
   * Checks that it is not an error to use a multi-line string literal as a URI in a part directive.
   * Even with leading whitespace since it's getting trimmed. Even with Windows \r\n style.
   */
  public void test_importLibrary_multiLineStringUri() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library A;",
            "var foo;",
            ""));
    appSource.setContent(
        APP,
        Joiner.on("\r\n").join(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library app;",
            "import '''",
            "A.dart''';",
            "main() {",
            " foo;",
            "}",
            ""));
    compile();
    assertErrors(errors);
  }

  /**
   * Checks that it is a compile-time error when the library being exported does not have a library
   * definition.
   */
  public void test_exportLibrary_withoutLibraryDirective() throws Exception {
    appSource.setContent("A.dart", "");
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.app;",
            "export 'A.dart';",
            ""));
    compile();
    assertErrors(
        errors,
        errEx(APP, DartCompilerErrorCode.MISSING_LIBRARY_DIRECTIVE_EXPORT, 3, 1, 16));
  }

  /**
   * Enabled in 0.13
   */
  public void test_exportLibrary_fromScript() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library A;",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library myScript;",
            "export 'A.dart';",
            "main() {",
            "}",
            ""));
    compile();
    assertErrors(errors);
  }

  /**
   * It is neither an error nor a warning if N is introduced by two or more imports but never
   * referred to.
   */
  public void test_importConflict_notUsed() throws Exception {
    prepare_importConflictAB();
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.app;",
            "import 'A.dart';",
            "import 'B.dart';",
            "main() {",
            "}",
            ""));
    compile();
    assertErrors(errors);
  }

  public void test_importConflict_used_asTypeAnnotation() throws Exception {
    prepare_importConflictAB();
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.app;",
            "import 'A.dart';",
            "import 'B.dart';",
            "typedef Test MyTypeDef(Test p);",
            "Test myFunction(Test p) {",
            "  Test test;",
            "}",
            ""));
    compile();
    assertErrors(
        errors,
        errEx(APP, ResolverErrorCode.DUPLICATE_IMPORTED_NAME_TYPE, 5, 24, 4),
        errEx(APP, ResolverErrorCode.DUPLICATE_IMPORTED_NAME_TYPE, 5, 9, 4),
        errEx(APP, ResolverErrorCode.DUPLICATE_IMPORTED_NAME_TYPE, 6, 17, 4),
        errEx(APP, ResolverErrorCode.DUPLICATE_IMPORTED_NAME_TYPE, 6, 1, 4),
        errEx(APP, ResolverErrorCode.DUPLICATE_IMPORTED_NAME_TYPE, 7, 3, 4));
  }

  public void test_importConflict_used_notTypeAnnotation_1() throws Exception {
    prepare_importConflictAB();
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.app;",
            "import 'A.dart';",
            "import 'B.dart';",
            "class A extends Test {}",
            "main() {",
            "}",
            ""));
    compile();
    assertErrors(
        errors,
        errEx(APP, ResolverErrorCode.DUPLICATE_IMPORTED_NAME, 5, 17, 4));
  }

  public void test_importConflict_used_notTypeAnnotation_2() throws Exception {
    prepare_importConflictAB();
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.app;",
            "import 'A.dart';",
            "import 'B.dart';",
            "main() {",
            "  Test();",
            "  Test.FOO;",
            "  Test = 0;",
            "  0 is Test;",
            "}",
            ""));
    compile();
    assertErrors(
        errors,
        errEx(APP, ResolverErrorCode.DUPLICATE_IMPORTED_NAME, 6, 3, 4),
        errEx(APP, ResolverErrorCode.DUPLICATE_IMPORTED_NAME, 7, 3, 4),
        errEx(APP, ResolverErrorCode.DUPLICATE_IMPORTED_NAME, 8, 3, 4),
        errEx(APP, ResolverErrorCode.DUPLICATE_IMPORTED_NAME, 9, 8, 4));
  }

  public void test_importConflict_used_notTypeAnnotation_3() throws Exception {
    prepare_importConflictAB();
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.app;",
            "import 'A.dart' hide Test;",
            "import 'B.dart';",
            "class A extends Test {}",
            "main() {",
            "}",
            ""));
    compile();
    assertErrors(errors);
  }

  public void test_importConflict_used_inCommentRef() throws Exception {
    prepare_importConflictAB();
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.app;",
            "import 'A.dart';",
            "import 'B.dart';",
            "/** [Test] */",
            "main() {",
            "}",
            ""));
    compile();
    assertErrors(errors);
  }

  /**
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=6824
   */
  public void test_exportConflict() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library lib_a;",
            "class Test {}",
            ""));
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library lib_b;",
            "class Test {}",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.app;",
            "export 'A.dart';",
            "export 'B.dart';",
            ""));
    compile();
    assertErrors(errors, errEx(APP, ResolverErrorCode.DUPLICATE_EXPORTED_NAME, 4, 1, 16));
  }

  private void prepare_importConflictAB() {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library lib_a;",
            "class Test {}",
            ""));
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library lib_b;",
            "class Test {}",
            ""));
  }

  /**
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=5735
   */
  public void test_importConflict_hideNoPrefix_importAgainWithPrefix() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library lib_a;",
            "var E = 2.7;",
            ""));
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library lib_b;",
            "export 'A.dart' show E;",
            "var E = 'E';",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.app;",
            "import 'B.dart';",
            "import 'A.dart' as M show E;",
            "main() {",
            "  print(E);",
            "  print(M.E);",
            "}",
            ""));
    compile();
    assertErrors(errors);
  }

  public void test_reportMissingSource() throws Exception {
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library app;",
            "part 'noSuchUnit.dart';",
            ""));
    compile();
    // Check that errors where reported (and in correct time).
    assertErrors(errors, errEx(DartCompilerErrorCode.MISSING_SOURCE, 3, 1, 23));
  }

  public void test_reportMissingSource_withSchema_file() throws Exception {
    URI uri = new URI("file:noSuchSource.dart");
    Source source = new UrlSource(uri) {
      @Override
      public String getName() {
        return null;
      }
    };
    // should not cause exception
    assertFalse(source.exists());
  }

  public void test_reportMissingSource_withSchema_dart() throws Exception {
    URI uri = new URI("dart:noSuchSource");
    Source source = new UrlSource(uri, new PackageLibraryManager()) {
      @Override
      public String getName() {
        return null;
      }
    };
    // should not cause exception
    assertFalse(source.exists());
  }
  /**
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=3532
   */
  public void test_includeSameUnitTwice() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library application;",
            "part 'A.dart';",
            "part 'A.dart';",
            ""));
    // do compile, no errors expected
    compile();
    assertErrors(errors, errEx(DartCompilerErrorCode.UNIT_WAS_ALREADY_INCLUDED, 4, 1, 14));
  }

  /**
   * There was bug that we added <code>null</code> into {@link LibraryUnit#getImports()}. Here trick
   * is that we reference "existing" {@link Source}, which can not be read.
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=2693
   */
  public void test_ignoreNullLibrary() throws Exception {
    appSource.setContent("canNotRead.dart", MemoryLibrarySource.IO_EXCEPTION_CONTENT);
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library app;",
            "import 'canNotRead.dart';",
            ""));
    // use same config as Editor - resolve despite of errors
    config = new DefaultCompilerConfiguration() {
      @Override
      public boolean resolveDespiteParseErrors() {
        return true;
      }
    };
    // Ignore errors, but we should not get exceptions.
    compile();
  }

  /**
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=4072
   */
  public void test_inaccessibleMethod_fromOtherLibrary_static() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library A;",
            "class A {",
            "  static _privateStatic() {}",
            "}",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library application;",
            "import 'A.dart';",
            "main() {",
            "  A._privateStatic();",
            "}",
            ""));
    // do compile, check errors
    compile();
    assertErrors(
        errors,
        errEx(ResolverErrorCode.ILLEGAL_ACCESS_TO_PRIVATE, 5, 5, 14));
  }

  /**
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=4072
   */
  public void test_inaccessibleMethod_fromOtherLibrary_instance() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library A;",
            "class A {",
            "  _privateInstance() {}",
            "}",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library application;",
            "import 'A.dart';",
            "main() {",
            "  A a = new A();",
            "  a._privateInstance();",
            "}",
            ""));
    // do compile, check errors
    compile();
    assertErrors(
        errors,
        errEx(TypeErrorCode.ILLEGAL_ACCESS_TO_PRIVATE, 6, 5, 16));
  }

  /**
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=3266
   */
  public void test_inaccessibleSuperMethod_fromOtherLibrary() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library A;",
            "class A {",
            "  _method() {}",
            "}",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library application;",
            "import 'A.dart';",
            "class B extends A {",
            "  test1() {",
            "    _method();",
            "  }",
            "  test2() {",
            "    super._method();",
            "  }",
            "}",
            ""));
    // do compile, check errors
    compile();
    assertErrors(
        errors,
        errEx(ResolverErrorCode.CANNOT_ACCESS_METHOD, 6, 5, 7),
        errEx(ResolverErrorCode.CANNOT_ACCESS_METHOD, 9, 11, 7));
  }

  /**
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=6822
   */
  public void test_useImportPrefix_asVariableName() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library A;",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library application;",
            "import 'A.dart' as prf;",
            "main() {",
            "  var prf;",
            "}",
            ""));
    // do compile, no errors expected
    compile();
    assertErrors(errors);
  }

  /**
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=3340
   */
  public void test_useImportPrefix_asTopLevelFieldName() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library A;",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library application;",
            "import 'A.dart' as prf;",
            "var prf;",
            "main() {",
            "}",
            ""));
    // do compile, no errors expected
    compile();
    assertErrors(errors, errEx(ResolverErrorCode.CANNOT_HIDE_IMPORT_PREFIX, 4, 5, 3));
  }

  public void test_newLibrarySyntax_show() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.A;",
            "class TypeA {}",
            "class TypeB {}",
            "class TypeC {}",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.app;",
            "import 'A.dart' as libA show TypeA, TypeB;",
            "main() {",
            "  libA.TypeA v1;",
            "  libA.TypeB v2;",
            "  libA.TypeC v3;",
            "}",
            ""));
    // TypeC not listed in "show"
    compile();
    assertErrors(errors, errEx(TypeErrorCode.NO_SUCH_TYPE, 7, 3, 10));
  }

  public void test_newLibrarySyntax_hide() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.A;",
            "class TypeA {}",
            "class TypeB {}",
            "class TypeC {}",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.app;",
            "import 'A.dart' as libA hide TypeC;",
            "main() {",
            "  libA.TypeA v1;",
            "  libA.TypeB v2;",
            "  libA.TypeC v3;",
            "}",
            ""));
    // TypeC is listed in "hide"
    compile();
    assertErrors(errors, errEx(TypeErrorCode.NO_SUCH_TYPE, 7, 3, 10));
  }

  public void test_newLibrarySyntax_export_show() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.A;",
            "class TypeAA {}",
            "class TypeAB {}",
            "class TypeAC {}",
            ""));
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.B;",
            "export 'A.dart' show TypeAA, TypeAB;",
            "class TypeBA {}",
            "class TypeBB {}",
            "class TypeBC {}",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.app;",
            "import 'B.dart' as libB hide TypeAA, TypeBB;",
            "main() {",
            "  libB.TypeAA aa;",
            "  libB.TypeAB ab;",
            "  libB.TypeAC ac;",
            "  libB.TypeBA ba;",
            "  libB.TypeBB bb;",
            "  libB.TypeBC bc;",
            "}",
            ""));
    compile();
    assertErrors(
        errors,
        errEx(TypeErrorCode.NO_SUCH_TYPE, 5, 3, 11),
        errEx(TypeErrorCode.NO_SUCH_TYPE, 7, 3, 11),
        errEx(TypeErrorCode.NO_SUCH_TYPE, 9, 3, 11));
    assertTrue(errors.toString().contains("libB.TypeAA"));
    assertTrue(errors.toString().contains("libB.TypeAC"));
    assertTrue(errors.toString().contains("libB.TypeBB"));
  }

  public void test_newLibrarySyntax_export2() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library libA;",
            "class SourceString {}",
            ""));
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library libB;",
            "import 'C.dart';",
            "export 'A.dart' show SourceString;",
            ""));
    appSource.setContent(
        "C.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library libC;",
            "import 'B.dart';",
            "foo() {",
            "  SourceString s;",
            "}",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library app;",
            "import 'B.dart';",
            ""));
    compile();
    assertErrors(errors);
  }

  public void test_newLibrarySyntax_export3() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library libA;",
            "class SourceString {}",
            ""));
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library libB;",
            "export 'C.dart';",
            "export 'A.dart' show SourceString;",
            ""));
    appSource.setContent(
        "C.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library libC;",
            "import 'B.dart';",
            "foo() {",
            "  SourceString s;",
            "}",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library app;",
            "import 'B.dart';",
            ""));
    compile();
    assertErrors(errors);
  }

  public void test_newLibrarySyntax_export4() throws Exception {
    appSource.setContent(
        "p1.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library lib1;",
            "export 'p3.dart';",
            ""));
    appSource.setContent(
        "p2.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library lib2;",
            "export 'p3.dart';",
            ""));
    appSource.setContent(
        "p3.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library lib3;",
            "class MyClass {}",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library app;",
            "import 'p1.dart' hide MyClass;",
            "import 'p2.dart';",
            "MyClass topLevelField;",
            ""));
    compile();
    assertErrors(errors);
  }

  public void test_newLibrarySyntax_export_hide() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.A;",
            "class TypeAA {}",
            "class TypeAB {}",
            "class TypeAC {}",
            ""));
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.B;",
            "export 'A.dart' hide TypeAC;",
            "class TypeBA {}",
            "class TypeBB {}",
            "class TypeBC {}",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.app;",
            "import 'B.dart' as libB hide TypeAA, TypeBB;",
            "main() {",
            "  libB.TypeAA aa;",
            "  libB.TypeAB ab;",
            "  libB.TypeAC ac;",
            "  libB.TypeBA ba;",
            "  libB.TypeBB bb;",
            "  libB.TypeBC bc;",
            "}",
            ""));
    compile();
    assertErrors(
        errors,
        errEx(TypeErrorCode.NO_SUCH_TYPE, 5, 3, 11),
        errEx(TypeErrorCode.NO_SUCH_TYPE, 7, 3, 11),
        errEx(TypeErrorCode.NO_SUCH_TYPE, 9, 3, 11));
    assertTrue(errors.toString().contains("libB.TypeAA"));
    assertTrue(errors.toString().contains("libB.TypeAC"));
    assertTrue(errors.toString().contains("libB.TypeBB"));
  }

  public void test_newLibrarySyntax_noExport() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.A;",
            "class TypeAA {}",
            "class TypeAB {}",
            "class TypeAC {}",
            ""));
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.B;",
            "import 'A.dart' as libA;",
            "class TypeBA {}",
            "class TypeBB {}",
            "class TypeBC {}",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.app;",
            "import 'B.dart' as libB;",
            "main() {",
            "  libB.TypeAA aa;",
            "  libB.TypeAB ab;",
            "  libB.TypeAC ac;",
            "  libB.TypeBA ba;",
            "  libB.TypeBB bb;",
            "  libB.TypeBC bc;",
            "}",
            ""));
    compile();
    assertErrors(
        errors,
        errEx(TypeErrorCode.NO_SUCH_TYPE, 5, 3, 11),
        errEx(TypeErrorCode.NO_SUCH_TYPE, 6, 3, 11),
        errEx(TypeErrorCode.NO_SUCH_TYPE, 7, 3, 11));
    assertTrue(errors.toString().contains("libB.TypeAA"));
    assertTrue(errors.toString().contains("libB.TypeAB"));
    assertTrue(errors.toString().contains("libB.TypeAC"));
  }

  /**
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=7598
   */
  public void test_newLibrarySyntax_export_withMetadata() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.A;",
            "var a = 0;",
            ""));
    appSource.setContent(
        "B.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.B;",
            "@meta export 'A.dart';",
            "const meta = 'meta!';",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library test.app;",
            "import 'B.dart';",
            "main() {",
            "  print(a);",
            "}",
            ""));
    compile();
    assertErrors(errors);
  }

  /**
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=4238
   */
  public void test_typesPropagation_html_query() throws Exception {
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library application;",
            "import 'dart:html';",
            "main() {",
            "  var v1 = query('a');",
            "  var v2 = query('A');",
            "  var v3 = query('body:active');",
            "  var v4 = query('button[foo=\"bar\"]');",
            "  var v5 = query('div.class');",
            "  var v6 = query('input#id');",
            "  var v7 = query('select#id');",
            "  // invocation of method",
            "  var m1 = document.query('div');",
            "  // unsupported currently",
            "  var b1 = query('noSuchTag');",
            "  var b2 = query('DART_EDITOR_NO_SUCH_TYPE');",
            "  var b3 = query('body div');",
            "}",
            ""));
    // do compile, no errors expected
    compile();
    assertErrors(errors);
    // validate types
    DartUnit unit = units.get(APP);
    assertNotNull(unit);
    assertInferredElementTypeString(unit, "v1", "AnchorElement", TypeQuality.INFERRED);
    assertInferredElementTypeString(unit, "v2", "AnchorElement", TypeQuality.INFERRED);
    assertInferredElementTypeString(unit, "v3", "BodyElement", TypeQuality.INFERRED);
    assertInferredElementTypeString(unit, "v4", "ButtonElement", TypeQuality.INFERRED);
    assertInferredElementTypeString(unit, "v5", "DivElement", TypeQuality.INFERRED);
    assertInferredElementTypeString(unit, "v6", "InputElement", TypeQuality.INFERRED);
    assertInferredElementTypeString(unit, "v7", "SelectElement", TypeQuality.INFERRED);
    // invocation of method
    assertInferredElementTypeString(unit, "m1", "DivElement", TypeQuality.INFERRED);
    // bad cases, or unsupported now
    assertInferredElementTypeString(unit, "b1", "Element", TypeQuality.INFERRED);
    assertInferredElementTypeString(unit, "b2", "Element", TypeQuality.INFERRED);
    assertInferredElementTypeString(unit, "b3", "Element", TypeQuality.INFERRED);
  }

  /**
   * Libraries "dart:io" and "dart:html" can not be used together in single application.
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=3839
   */
  public void test_consoleWebMix() throws Exception {
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library application;",
            "import 'dart:io';",
            "import 'dart:html';",
            ""));
    // do compiled
    compile();
    // find expected error
    boolean found = false;
    for (DartCompilationError error : errors) {
      found |= error.getErrorCode() == DartCompilerErrorCode.CONSOLE_WEB_MIX;
    }
    assertTrue(found);
  }

  /**
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=3531
   * <p>
   * Revised 2012-12-12 - specification has no rule about import prefix and built-in identifier.
   */
  public void test_builtInIdentifier_asImportPrefix() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library A;",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library application;",
            "import 'A.dart' as abstract;",
            "import 'A.dart' as as;",
            "import 'A.dart' as dynamic;",
            "import 'A.dart' as export;",
            "import 'A.dart' as external;",
            "import 'A.dart' as factory;",
            "import 'A.dart' as get;",
            "import 'A.dart' as implements;",
            "import 'A.dart' as import;",
            "import 'A.dart' as library;",
            "import 'A.dart' as operator;",
            "import 'A.dart' as part;",
            "import 'A.dart' as set;",
            "import 'A.dart' as static;",
            "import 'A.dart' as typedef;",
            "main() {",
            "  var prf;",
            "}",
            ""));
    // do compile, no errors expected
    compile();
    assertEquals(0, errors.size());
  }

  public void test_implicitlyImportCore() throws Exception {
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library application;",
            "import 'dart:core';",
            ""));
    compile();
    ErrorExpectation.assertErrors(errors);
  }

  /**
   * Investigation of failing "language/ct_const4_test".
   */
  public void test_useConstFromLib() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library A;",
            "final B = 1;",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library application;",
            "import 'A.dart' as mylib;",
            "final A = mylib.B;",
            ""));
    // do compile, no errors expected
    compile();
    assertErrors(errors);
  }

  /**
   * Part should have one and only one directive - "part of".
   */
  public void test_partDirectives_otherThenPartOf() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library A;",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library application;",
            "part 'A.dart';",
            ""));
    // do compile
    compile();
    assertErrors(errors, errEx(DartCompilerErrorCode.ILLEGAL_DIRECTIVES_IN_SOURCED_UNIT, 2, 1, 10));
  }

  /**
   * Part should have one and only one directive - "part of".
   */
  public void test_partDirectives_otherThenPartOf2() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of application;",
            "part 'A.dart';",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library application;",
            "part 'A.dart';",
            ""));
    // do compile
    compile();
    assertErrors(errors, errEx(DartCompilerErrorCode.ILLEGAL_DIRECTIVES_IN_SOURCED_UNIT, 2, 1, 20));
  }

  /**
   * Part should have one and only one directive - "part of".
   */
  public void test_partDirectives_noPartOf() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library application;",
            "part 'A.dart';",
            ""));
    // do compile
    compile();
    assertErrors(errors, errEx(DartCompilerErrorCode.MISSING_PART_OF_DIRECTIVE, -1, -1, 0));
  }

  /**
   * Part should have one and only one directive - "part of".
   */
  public void test_partDirectives_wrongNameInPartOf() throws Exception {
    appSource.setContent(
        "A.dart",
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "part of Z;",
            ""));
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library application;",
            "part 'A.dart';",
            ""));
    // do compile
    compile();
    assertErrors(
        errors,
        errEx(DartCompilerErrorCode.WRONG_PART_OF_NAME, 2, 1, 10),
        errEx(TypeErrorCode.CANNOT_BE_RESOLVED, 2, 9, 1));
  }

  /**
   * Internals of Dart use "dart-ext:" import scheme, and these libraries are allowed to use
   * "native". New import syntax.
   */
  public void test_useNative_withDartExt_new() throws Exception {
    appSource.setContent(
        APP,
        makeCode(
            "// filler filler filler filler filler filler filler filler filler filler filler",
            "library A;",
            "import 'dart-ext:test_extension';",
            "class A {",
            "  static int ifNull(a, b) native 'TestExtension_IfNull';",
            "}",
            ""));
    // do compile, no errors expected
    compile();
    assertErrors(errors);
  }

  /**
   * <p>
   * http://code.google.com/p/dart/issues/detail?id=6077
   */
  public void test_dartMirrors_notFullyImplemented() throws Exception {
    appSource.setContent(
        APP,
        makeCode("// filler filler filler filler filler filler filler filler filler filler filler",
            "import 'dart:mirrors';"));
    // do compile, no errors expected
    compile();
    assertErrors(errors, errEx(DartCompilerErrorCode.MIRRORS_NOT_FULLY_IMPLEMENTED, 2, 1, 22));
  }

  private void assertAppBuilt() {
    didWrite(APP, EXTENSION_DEPS);
  }

  private void compile() {
    compile(appSource);
  }

  private void compile(LibrarySource lib) {
    try {
      provider.resetReadsAndWrites();
      errors.clear();
      DartCompilerListener listener = new DartCompilerListener.Empty() {
        Set<URI> compilingUris = Sets.newHashSet();

        @Override
        public void unitAboutToCompile(DartSource source, boolean diet) {
          compilingUris.add(source.getUri());
        }

        @Override
        public void onError(DartCompilationError event) {
          // ignore deprecated
          if (event.getErrorCode() == TypeErrorCode.DEPRECATED_ELEMENT) {
            return;
          }
          // Remember errors only between unitAboutToCompile/unitCompiled.
          Source source = event.getSource();
          if (source != null && compilingUris.contains(source.getUri())) {
            errors.add(event);
          }
        }

        @Override
        public void unitCompiled(DartUnit unit) {
          compilingUris.remove(unit.getSourceInfo().getSource().getUri());
          units.put(unit.getSourceName(), unit);
        }
      };
      DartCompiler.compileLib(lib, config, provider, listener);
    } catch (IOException e) {
      throw new AssertionFailedError("Unexpected IOException: " + e.getMessage());
    }
  }

  private void didWrite(String sourceName, String extension) {
    String spec = sourceName + "/" + extension;
    assertTrue("Expected write: " + spec, provider.writes.contains(spec));
  }

  private void didNotWrite(String sourceName, String extension) {
    String spec = sourceName + "/" + extension;
    assertFalse("Didn't expect write: " + spec, provider.writes.contains(spec));
  }
}
