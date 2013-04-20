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
package com.google.dart.tools.core.internal.model;

import com.google.common.base.Joiner;
import com.google.common.io.Files;
import com.google.common.io.InputSupplier;
import com.google.dart.compiler.DefaultLibrarySource;
import com.google.dart.compiler.LibrarySource;
import com.google.dart.compiler.PackageLibraryManager;
import com.google.dart.compiler.UrlLibrarySource;
import com.google.dart.tools.core.DartCore;
import com.google.dart.tools.core.internal.util.ResourceUtil;
import com.google.dart.tools.core.model.CompilationUnit;
import com.google.dart.tools.core.model.DartElement;
import com.google.dart.tools.core.model.DartLibrary;
import com.google.dart.tools.core.model.DartModelException;
import com.google.dart.tools.core.model.DartProject;
import com.google.dart.tools.core.test.util.TestProject;
import com.google.dart.tools.core.test.util.TestUtilities;

import junit.framework.TestCase;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRunnable;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;

import static org.fest.assertions.Assertions.assertThat;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

public class DartLibraryImplTest extends TestCase {
  private static File tempDir = null;

  private static void createTempFile(File file, final String content) throws IOException {
    assertTrue(file.getParentFile().exists());
    Files.copy(new InputSupplier<InputStream>() {
      @Override
      public InputStream getInput() throws IOException {
        return new ByteArrayInputStream(content.getBytes());
      }
    }, file);
    file.deleteOnExit();
  }

  private static File getTempDir() throws IOException {
    if (tempDir == null) {
      tempDir = ResourcesPlugin.getWorkspace().getRoot().getLocation().append(
          DartLibraryImplTest.class.getSimpleName() + ".tmp").toFile();
      makeTempDir(tempDir);
    }
    return tempDir;
  }

  private static void makeTempDir(File dir) {
    assertFalse(dir.exists());
    assertTrue(dir.mkdir());
    dir.deleteOnExit();
  }

  private DartLibraryImpl dartLibEmpty;
  private DartLibraryImpl dartLib1;
  private DartLibraryImpl dartLib2;
  private DartLibraryImpl dartLib3;
  private DartLibraryImpl dartLib3Alt;
  private DartLibraryImpl dartLib4;
  private DartLibraryImpl dartLib5;
  private DartLibraryImpl dartLib5a;
  private DartLibraryImpl dartLib6;
  private DartLibraryImpl dartLibExternal;

  private final Map<DartLibraryImpl, Collection<DartElement>> libraryChildrenWithCachedInfos = new HashMap<DartLibraryImpl, Collection<DartElement>>();

  public void test_DartLibraryImpl_close() throws Exception {
    File libraryFile = TestUtilities.getPluginRelativePath(
        "com.google.dart.tools.core_test",
        new Path("test_data/Geometry/geometry.dart")).toFile();
    final DartLibrary library = DartCore.openLibrary(libraryFile, null);
    assertNotNull(library);
    IProject project = ((DartProject) library.getParent()).getProject();
    ResourcesPlugin.getWorkspace().run(new IWorkspaceRunnable() {
      @Override
      public void run(IProgressMonitor monitor) throws CoreException {
        library.delete(monitor);
      }
    }, null);
    assertFalse(project.exists());
  }

  /**
   * Test that two different handles with the same project and file are equal
   */
  public void test_DartLibraryImpl_equals_lib1() throws Exception {
    DartLibraryImpl lib1a = getDartLib1();
    IProject proj = lib1a.getResource().getProject();
    DartProjectImpl dartProj = new DartProjectImpl(getDartModel(), proj);
    DartLibraryImpl lib1b = new DartLibraryImpl(dartProj, proj.getFile("lib1.dart"));
    assertEquals(lib1a, lib1b);
  }

  public void test_DartLibraryImpl_equals_lib1NotLib2() throws Exception {
    if (getDartLib1().equals(getDartLib2())) {
      fail();
    }
  }

  public void test_DartLibraryImpl_equals_lib1NotLibExternal() throws Exception {
    if (getDartLib1().equals(getDartLibExternal())) {
      fail();
    }
  }

  /**
   * Test that a handle "in the workspace" and a handle "not in the workspace" but pointing to the
   * same file on disk are equal
   */
  public void test_DartLibraryImpl_equals_lib3Alt() throws Exception {
    assertEquals(getDartLib3(), getDartLib3Alt());
  }

  /**
   * Test equals and sanity check that the core library can be accessed
   */
  public void test_DartLibraryImpl_equals_libCore() throws Exception {
    LibrarySource libSrc = getDartLibCore().getLibrarySourceFile();
    assertEquals(getDartLibCore(), new DartLibraryImpl(libSrc));
  }

  public void test_DartLibraryImpl_equals_libDomWebkit() throws Exception {
    // TODO (danrubel) uncomment to ensure webkit dom is bundled
    //LibrarySource libSrc = getDartLibDomWebkit().getLibrarySourceFile();
    //assertEquals(getDartLibDomWebkit(), new DartLibraryImpl(libSrc));
  }

  public void test_DartLibraryImpl_equals_libExternal() throws Exception {
    DartLibraryImpl lib = getDartLibExternal();
    File libDir = new File(getTempDir(), "libExternal");
    assertEquals(lib, new DartLibraryImpl(new File(libDir, "libExternal.dart")));
  }

  /**
   * Test for {@link DartLibrary#findTopLevelElement(String)}.
   */
  public void test_DartLibraryImpl_findTopLevelElement() throws Exception {
    TestProject testProject = new TestProject("Test");
    try {
      testProject.setUnitContent(
          "Test1.dart",
          Joiner.on("\n").join(
              "// filler filler filler filler filler filler filler filler filler filler",
              "testB() {}",
              ""));
      testProject.setUnitContent(
          "Test2.dart",
          Joiner.on("\n").join(
              "// filler filler filler filler filler filler filler filler filler filler",
              "const TEST_C = 0;",
              ""));
      IResource libResource = testProject.setUnitContent(
          "Test.dart",
          Joiner.on("\n").join(
              "// filler filler filler filler filler filler filler filler filler filler",
              "#library('test');",
              "#source('Test1.dart');",
              "#source('Test2.dart');",
              "class A {}",
              "")).getResource();
      DartLibrary library = testProject.getDartProject().getDartLibrary(libResource);
      assertNotNull(library.findTopLevelElement("A"));
      assertNotNull(library.findTopLevelElement("testB"));
      assertNotNull(library.findTopLevelElement("TEST_C"));
      assertNull(library.findTopLevelElement("NoSuchElement"));
    } finally {
      testProject.dispose();
    }
  }

  /**
   * Test for {@link DartLibrary#findType(String)}.
   */
  public void test_DartLibraryImpl_findType() throws Exception {
    TestProject testProject = new TestProject("Test");
    try {
      testProject.setUnitContent(
          "Test1.dart",
          Joiner.on("\n").join(
              "// filler filler filler filler filler filler filler filler filler filler",
              "class B {}",
              ""));
      testProject.setUnitContent(
          "Test2.dart",
          Joiner.on("\n").join(
              "// filler filler filler filler filler filler filler filler filler filler",
              "class C {}",
              ""));
      IResource libResource = testProject.setUnitContent(
          "Test.dart",
          Joiner.on("\n").join(
              "// filler filler filler filler filler filler filler filler filler filler",
              "#library('test');",
              "#source('Test1.dart');",
              "#source('Test2.dart');",
              "class A {}",
              "")).getResource();
      DartLibrary library = testProject.getDartProject().getDartLibrary(libResource);
      assertNotNull(library.findType("A"));
      assertNotNull(library.findType("B"));
      assertNotNull(library.findType("C"));
      assertNull(library.findType("NoSuchType"));
    } finally {
      testProject.dispose();
    }
  }

  /**
   * Test for {@link DartLibrary#findTypeInScope(String)}.
   */
  public void test_DartLibraryImpl_findTypeInScope() throws Exception {
    TestProject testProject = new TestProject("Test");
    try {
      IResource libResourceA = testProject.setUnitContent(
          "TestA.dart",
          Joiner.on("\n").join(
              "// filler filler filler filler filler filler filler filler filler filler",
              "#library('A');",
              "class A1 {}",
              "class _A2 {}",
              "")).getResource();
      IResource libResourceB = testProject.setUnitContent(
          "TestB.dart",
          Joiner.on("\n").join(
              "// filler filler filler filler filler filler filler filler filler filler",
              "#library('B');",
              "#import('TestA.dart');",
              "class B1 {}",
              "class _B2 {}",
              "")).getResource();
      // using "libraryA" we can find all types of "A"
      {
        DartLibrary libraryA = testProject.getDartProject().getDartLibrary(libResourceA);
        assertNotNull(libraryA.findTypeInScope("A1"));
        assertNotNull(libraryA.findTypeInScope("_A2"));
        assertNull(libraryA.findTypeInScope("B1"));
      }
      // using "libraryB" we can find all types of "B" and non-private classes of "A"
      {
        DartLibrary libraryB = testProject.getDartProject().getDartLibrary(libResourceB);
        assertNotNull(libraryB.findTypeInScope("B1"));
        assertNotNull(libraryB.findTypeInScope("_B2"));
        assertNotNull(libraryB.findTypeInScope("A1"));
        assertNull(libraryB.findTypeInScope("_A2"));
      }
      // from dart:core
      {
        DartLibrary libraryA = testProject.getDartProject().getDartLibrary(libResourceA);
        assertNotNull(libraryA.findTypeInScope("num"));
        assertNotNull(libraryA.findTypeInScope("String"));
      }
    } finally {
      testProject.dispose();
    }
  }

  /**
   * Test for {@link DartLibrary#findTypeInScope(String)}.
   */
  public void test_DartLibraryImpl_findTypeInScope_nonTransitive() throws Exception {
    TestProject testProject = new TestProject("Test");
    try {
      testProject.setUnitContent(
          "TestA.dart",
          Joiner.on("\n").join(
              "// filler filler filler filler filler filler filler filler filler filler",
              "#library('A');",
              "class A {}",
              "")).getResource();
      testProject.setUnitContent(
          "TestB.dart",
          Joiner.on("\n").join(
              "// filler filler filler filler filler filler filler filler filler filler",
              "#library('B');",
              "#import('TestA.dart');",
              "class B {}",
              "")).getResource();
      IResource libResourceC = testProject.setUnitContent(
          "TestC.dart",
          Joiner.on("\n").join(
              "// filler filler filler filler filler filler filler filler filler filler",
              "#library('C');",
              "#import('TestB.dart');",
              "class C {}",
              "")).getResource();
      // using "libraryC" we can find types of "C", "B", but not "A"
      DartLibrary libraryC = testProject.getDartProject().getDartLibrary(libResourceC);
      assertNotNull(libraryC.findTypeInScope("C"));
      assertNotNull(libraryC.findTypeInScope("B"));
      assertNull(libraryC.findTypeInScope("A"));
    } finally {
      testProject.dispose();
    }
  }

  public void test_DartLibraryImpl_getChildren_lib1() throws Exception {
    assertDartLib1Children(getDartLib1(), true);
//    getDartLib1().getDartProject().close();
//    try {
//      assertInfoCleared(getDartLib1(), true);
//      assertDartLib1Children(getDartLib1(), false);
//    } finally {
//      // force #getDartLib1() to reopen library
//      dartLib1 = null;
//      getDartLib1();
//    }
//    assertDartLib1Children(getDartLib1(), true);
  }

  public void test_DartLibraryImpl_getChildren_lib2() throws Exception {
    DartElement[] children = getDartLib2().getChildren();
    assertContainsCompUnit(children, "lib2.dart", false, false);
    assertEquals(1, children.length);
  }

  /**
   * Assert that lib3's info has been discarded when project is closed and again when it has been
   * reopened
   */
  public void test_DartLibraryImpl_getChildren_lib3() throws Exception {
    assertDartLib3Children(getDartLib3(), true);
    getDartLib3().getDartProject().close();
    try {
      assertInfoCleared(getDartLib3(), false);
      assertDartLib3Children(getDartLib3(), false);
    } finally {
      // force #getDartLib3() to reopen library
      dartLib3 = null;
      getDartLib3();
    }
    assertDartLib3Children(getDartLib3(), true);
  }

  /**
   * Assert that lib3's info has been discarded when project is closed and again when it has been
   * reopened
   */
  public void test_DartLibraryImpl_getChildren_lib3Alt() throws Exception {
    assertDartLib3Children(getDartLib3Alt(), true);
  }

  public void test_DartLibraryImpl_getChildren_libCore() throws Exception {
    DartElement[] children = getDartLibCore().getChildren();
    assertContainsCompUnit(children, "core.dart", false, false);
    assertContainsCompUnit(children, "object.dart", false, false);
    assertContainsCompUnit(children, "list.dart", false, false);
    assertTrue(children.length > 20);
  }

  public void test_DartLibraryImpl_getChildren_libEmpty() throws Exception {
    DartElement[] children = getDartLibEmpty().getChildren();
    assertContainsCompUnit(children, "empty.dart", false, false);
    assertEquals(1, children.length);
  }

  public void test_DartLibraryImpl_getChildren_libExternal() throws Exception {
    DartElement[] children = getDartLibExternal().getChildren();
    assertContainsCompUnit(children, "libExternal.dart", false, false);
    assertContainsCompUnit(children, "ALib5MissingClass.dart", false, false);
    assertEquals(2, children.length);
  }

  public void test_DartLibraryImpl_getChildren_libHtml() throws Exception {
    DartElement[] children = getDartLibHtml().getChildren();
    assertContainsCompUnit(children, "html_dartium.dart", false, false);
    assertTrue(children.length > 0);
  }

  public void test_DartLibraryImpl_getChildren_libJson() throws Exception {
    DartElement[] children = getDartLibJson().getChildren();
    assertContainsCompUnit(children, "json.dart", false, false);
  }

  public void test_DartLibraryImpl_getCompilationUnits_lib1() throws Exception {
    assertEquals(2, getDartLib1().getCompilationUnits().length);
  }

  public void test_DartLibraryImpl_getCompilationUnits_lib2() throws Exception {
    assertEquals(1, getDartLib2().getCompilationUnits().length);
  }

  public void test_DartLibraryImpl_getCompilationUnits_libEmpty() throws Exception {
    assertEquals(1, getDartLibEmpty().getCompilationUnits().length);
  }

  public void test_DartLibraryImpl_getCompilationUnits_libExternal() throws Exception {
    assertEquals(2, getDartLibExternal().getCompilationUnits().length);
  }

  public void test_DartLibraryImpl_getCompilationUnits_libHtml() throws Exception {
    assertTrue(getDartLibHtml().getCompilationUnits().length > 0);
  }

  /**
   * Test for {@link DartLibrary#getCompilationUnitsInScope()}.
   */
  public void test_DartLibraryImpl_getCompilationUnitsInScope() throws Exception {
    TestProject testProject = new TestProject("Test");
    try {
      CompilationUnit unitA = testProject.setUnitContent(
          "TestA.dart",
          Joiner.on("\n").join(
              "// filler filler filler filler filler filler filler filler filler filler",
              "#library('A');",
              ""));
      CompilationUnit unitB = testProject.setUnitContent(
          "TestB.dart",
          Joiner.on("\n").join(
              "// filler filler filler filler filler filler filler filler filler filler",
              "#library('B');",
              "#import('TestA.dart');",
              ""));
      IResource resourceA = unitA.getResource();
      IResource resourceB = unitB.getResource();
      // "libraryA" has only units of "A"
      {
        DartLibrary libraryA = testProject.getDartProject().getDartLibrary(resourceA);
        List<CompilationUnit> units = libraryA.getCompilationUnitsInScope();
        assertThat(units).containsOnly(unitA);
      }
      // "libraryB" has units of "A" and "B"
      {
        DartLibrary libraryB = testProject.getDartProject().getDartLibrary(resourceB);
        List<CompilationUnit> units = libraryB.getCompilationUnitsInScope();
        assertThat(units).containsOnly(unitA, unitB);
      }
    } finally {
      testProject.dispose();
    }
  }

  /**
   * Test for {@link DartLibrary#getCompilationUnitsTransitively()}.
   */
  public void test_DartLibraryImpl_getCompilationUnitsTransitively() throws Exception {
    TestProject testProject = new TestProject("Test");
    try {
      CompilationUnit unitC = testProject.setUnitContent(
          "TestC.dart",
          Joiner.on("\n").join(
              "// filler filler filler filler filler filler filler filler filler filler",
              "#library('C');",
              ""));
      CompilationUnit unitB = testProject.setUnitContent(
          "TestB.dart",
          Joiner.on("\n").join(
              "// filler filler filler filler filler filler filler filler filler filler",
              "#library('B');",
              "#import('TestC.dart');",
              ""));
      CompilationUnit unitA = testProject.setUnitContent(
          "TestA.dart",
          Joiner.on("\n").join(
              "// filler filler filler filler filler filler filler filler filler filler",
              "#library('A');",
              "#import('TestB.dart');",
              ""));
      IResource resourceA = unitA.getResource();
      IResource resourceB = unitB.getResource();
      IResource resourceC = unitC.getResource();
      // "libraryA" has units "A", "B", and "C"
      {
        DartLibrary libraryA = testProject.getDartProject().getDartLibrary(resourceA);
        List<CompilationUnit> units = libraryA.getCompilationUnitsTransitively();
        assertThat(units).containsOnly(unitA, unitB, unitC);
      }
      // "libraryB" has units "B" and "C"
      {
        DartLibrary libraryB = testProject.getDartProject().getDartLibrary(resourceB);
        List<CompilationUnit> units = libraryB.getCompilationUnitsTransitively();
        assertThat(units).containsOnly(unitB, unitC);
      }
      // "libraryC" has unit "C"
      {
        DartLibrary libraryC = testProject.getDartProject().getDartLibrary(resourceC);
        List<CompilationUnit> units = libraryC.getCompilationUnitsTransitively();
        assertThat(units).containsOnly(unitC);
      }
    } finally {
      testProject.dispose();
    }
  }

  public void test_DartLibraryImpl_getCorrespondingResource() {
    // TODO Implement this
  }

  public void test_DartLibraryImpl_getDisplayName_html() throws Exception {
    assertEquals("dart:html", getDartLibHtml().getDisplayName());
  }

  public void test_DartLibraryImpl_getDisplayName_lib1() throws Exception {
    assertEquals("lib1", getDartLib1().getDisplayName());
  }

  public void test_DartLibraryImpl_getElementName_lib1() throws Exception {
    // expected:<file:[E:\tmp\build_root\tmp\build\workspace-test\]DartLibraryImplTest....>
    // but was: <file:[/E:/tmp/build_root/tmp/build/workspace-test/]DartLibraryImplTest....>

    assertEquals(
        getTempDirPath().append("lib1").append("lib1.dart").toFile().toURI().toString(),
        getDartLib1().getElementName());
  }

  public void test_DartLibraryImpl_getElementName_lib2() throws Exception {
    assertEquals(
        getTempDirPath().append("lib2").append("lib2.dart").toFile().toURI().toString(),
        getDartLib2().getElementName());
  }

  public void test_DartLibraryImpl_getElementName_lib3() throws Exception {
    assertEquals(
        getTempDirPath().append("lib3").append("lib3.dart").toFile().toURI().toString(),
        getDartLib3().getElementName());
  }

  public void test_DartLibraryImpl_getElementName_libCore() throws Exception {
    assertEquals("dart:core", getDartLibCore().getElementName());
  }

  public void test_DartLibraryImpl_getElementName_libEmpty() throws Exception {
    assertEquals(
        getTempDirPath().append("empty").append("empty.dart").toFile().toURI().toString(),
        getDartLibEmpty().getElementName());
  }

  public void test_DartLibraryImpl_getElementName_libExternal() throws Exception {
    assertEquals(
        getTempDirPath().append("libExternal").append("libExternal.dart").toFile().toURI().toString(),
        getDartLibExternal().getElementName());
  }

  public void test_DartLibraryImpl_getElementName_libHtml() throws Exception {
    assertEquals("dart:html", getDartLibHtml().getElementName());
  }

  public void test_DartLibraryImpl_getHandleMemento_lib1() throws Exception {
    assertHandleMemento(getDartLib1());
  }

  public void test_DartLibraryImpl_getHandleMemento_lib2() throws Exception {
    assertHandleMemento(getDartLib2());
  }

  public void test_DartLibraryImpl_getHandleMemento_lib3() throws Exception {
    assertHandleMemento(getDartLib3());
    getDartLib3().getDartProject().close();
    try {
      assertHandleMemento(getDartLib3());
    } finally {
      // force #getDartLib3() to reopen library
      dartLib3 = null;
      getDartLib3();
    }
    assertHandleMemento(getDartLib3());
  }

  public void test_DartLibraryImpl_getHandleMemento_lib3Alt() throws Exception {
    assertHandleMemento(getDartLib3Alt());
    getDartLib3().getDartProject().close();
    try {
      assertHandleMemento(getDartLib3Alt());
    } finally {
      // force #getDartLib3() to reopen library
      dartLib3 = null;
      getDartLib3();
    }
    assertHandleMemento(getDartLib3Alt());
  }

  public void test_DartLibraryImpl_getHandleMemento_libExternal() throws Exception {
    assertHandleMemento(getDartLibExternal());
  }

  public void test_DartLibraryImpl_getHandleMemento_libHtml() throws Exception {
    assertHandleMemento(getDartLibHtml());
  }

  public void test_DartLibraryImpl_getImportedLibraries_lib1() throws Exception {
    DartLibrary[] importedLibraries = getDartLib1().getImportedLibraries();
    assertContainsLibImpl(importedLibraries, "dart:html");
    assertEquals(1, importedLibraries.length);
  }

  public void test_DartLibraryImpl_getImportedLibraries_lib2() throws Exception {
    assertDartLib2ImportedLibraries();
    getDartLib2().getDartProject().close();
    try {
      assertDartLib2ImportedLibraries();
    } finally {
      // force #getDartLib2() to reopen library
      dartLib2 = null;
      getDartLib2();
    }
    assertDartLib2ImportedLibraries();
  }

  public void test_DartLibraryImpl_getImportedLibraries_lib3() throws Exception {
    assertDartLib3ImportedLibraries();
    getDartLib3().getDartProject().close();
    try {
      assertDartLib3ImportedLibraries();
    } finally {
      // force #getDartLib3() to reopen library
      dartLib3 = null;
      getDartLib3();
    }
    assertDartLib3ImportedLibraries();
  }

  public void test_DartLibraryImpl_getImportedLibraries_libCore() throws Exception {
    DartLibrary[] importedLibraries = getDartLibCore().getImportedLibraries();
    assertNotNull(importedLibraries);
//    assertEquals(1, importedLibraries.length);
//    assertEquals("dart:collection", importedLibraries[0].getElementName());
  }

  public void test_DartLibraryImpl_getImportedLibraries_libEmpty() throws Exception {
    DartLibrary[] importedLibraries = getDartLibEmpty().getImportedLibraries();
    assertEquals(0, importedLibraries.length);
  }

  public void test_DartLibraryImpl_getImportedLibraries_libExternal() throws Exception {
    DartLibrary[] importedLibraries = getDartLibExternal().getImportedLibraries();
    assertContainsLibImpl(importedLibraries, "/empty/empty.dart");
    assertEquals(1, importedLibraries.length);
  }

  public void test_DartLibraryImpl_getImportedLibraries_libHtml() throws Exception {
    DartLibrary[] importedLibraries = getDartLibHtml().getImportedLibraries();
    assertNotNull(importedLibraries);
//    assertEquals(4, importedLibraries.length);
//    assertEquals("dart:isolate", importedLibraries[0].getElementName());
//    assertEquals("dart:json", importedLibraries[1].getElementName());
//    assertEquals("dart:svg", importedLibraries[2].getElementName());
  }

  /**
   * Test for {@link DartLibrary#getLibraryDirectiveName()}.
   */
  public void test_DartLibraryImpl_getLibraryDirectiveName_new() throws Exception {
    TestProject testProject = new TestProject("Test");
    try {
      IResource libResource = testProject.setUnitContent(
          "Test.dart",
          Joiner.on("\n").join(
              "// filler filler filler filler filler filler filler filler filler filler",
              "library test.lib.name;",
              "")).getResource();
      DartLibrary library = testProject.getDartProject().getDartLibrary(libResource);
      assertEquals("test.lib.name", library.getLibraryDirectiveName());
    } finally {
      testProject.dispose();
    }
  }

  /**
   * Test for {@link DartLibrary#getLibraryDirectiveName()}.
   */
  public void test_DartLibraryImpl_getLibraryDirectiveName_old() throws Exception {
    TestProject testProject = new TestProject("Test");
    try {
      IResource libResource = testProject.setUnitContent(
          "Test.dart",
          Joiner.on("\n").join(
              "// filler filler filler filler filler filler filler filler filler filler",
              "#library('test.lib.name');",
              "")).getResource();
      DartLibrary library = testProject.getDartProject().getDartLibrary(libResource);
      assertEquals("test.lib.name", library.getLibraryDirectiveName());
    } finally {
      testProject.dispose();
    }
  }

  public void test_DartLibraryImpl_hasMain_lib1() throws Exception {
    DartLibraryImpl lib = getDartLib1();
    assertEquals(true, lib.hasMain());
  }

  public void test_DartLibraryImpl_hasMain_lib2() throws Exception {
    DartLibraryImpl lib = getDartLib2();
    assertEquals(false, lib.hasMain());
  }

  public void test_DartLibraryImpl_hasMain_lib3() throws Exception {
    DartLibraryImpl lib = getDartLib3();
    assertEquals(false, lib.hasMain());
//    DartCoreTestLog.getLog().assertEntries(IStatus.ERROR);
  }

  public void test_DartLibraryImpl_hasMain_libEmpty() throws Exception {
    DartLibraryImpl lib = getDartLibEmpty();
    assertEquals(false, lib.hasMain());
  }

  public void test_DartLibraryImpl_importsBrowserLibrary_lib1() throws Exception {
    DartLibraryImpl lib = getDartLib1();
    assertEquals(true, lib.isOrImportsBrowserLibrary());
  }

  public void test_DartLibraryImpl_importsBrowserLibrary_lib2() throws Exception {
    DartLibraryImpl lib = getDartLib2();
    assertEquals(true, lib.isOrImportsBrowserLibrary());
  }

  public void test_DartLibraryImpl_importsBrowserLibrary_lib3() throws Exception {
    DartLibraryImpl lib = getDartLib3();
    assertEquals(false, lib.isOrImportsBrowserLibrary());
  }

  public void test_DartLibraryImpl_importsBrowserLibrary_libEmpty() throws Exception {
    DartLibraryImpl lib = getDartLibEmpty();
    assertEquals(false, lib.isOrImportsBrowserLibrary());
  }

  public void test_DartLibraryImpl_isBrowserApplication_lib1() throws Exception {
    DartLibraryImpl lib = getDartLib1();
    assertEquals(true, lib.isBrowserApplication());
  }

  public void test_DartLibraryImpl_isBrowserApplication_lib2() throws Exception {
    DartLibraryImpl lib = getDartLib2();
    assertEquals(false, lib.isBrowserApplication());
  }

  public void test_DartLibraryImpl_isBrowserApplication_lib3() throws Exception {
    DartLibraryImpl lib = getDartLib3();
    assertEquals(false, lib.isBrowserApplication());
//    DartCoreTestLog.getLog().assertEntries(IStatus.ERROR);
  }

  public void test_DartLibraryImpl_isBrowserApplication_lib4() throws Exception {
    DartLibraryImpl lib = getDartLib4();
    assertEquals(false, lib.isBrowserApplication());
  }

  public void test_DartLibraryImpl_isBrowserApplication_lib5() throws Exception {
    DartLibraryImpl lib = getDartLib5();
    assertEquals(true, lib.isBrowserApplication());
  }

  public void test_DartLibraryImpl_isBrowserApplication_lib6() throws Exception {
    DartLibraryImpl lib = getDartLib6();
    assertEquals(false, lib.isBrowserApplication());
  }

  public void test_DartLibraryImpl_isBrowserApplication_libEmpty() throws Exception {
    DartLibraryImpl lib = getDartLibEmpty();
    assertEquals(false, lib.isBrowserApplication());
  }

  public void test_DartLibraryImpl_isTopLevel() throws Exception {
    assertFalse(getDartLibEmpty().isTopLevel());
  }

  public void test_DartLibraryImpl_newLibrarySourceFile() throws Exception {
    DartLibraryImpl library = getDartLibExternal();
    assertTrue(library.getLibrarySourceFile().getUri().toString().startsWith("file:/"));
  }

  public void test_DartLibraryImpl_nonExistantBundledLib() throws Exception {
    String memento = "= {file:/some/path/to/missing_bundled_lib.dart";
    DartLibraryImpl actual = (DartLibraryImpl) DartCore.create(memento);
    assertNotNull(actual);
  }

  public void test_DartLibraryImpl_nonExistantCompUnitAndBundledLib() throws Exception {
    String memento = "= {file:/some/path/to/missing_bundled_lib.dart!src/NonExistingClass.dart";
    ExternalCompilationUnitImpl actual = (ExternalCompilationUnitImpl) DartCore.create(memento);
    assertNotNull(actual);
  }

  public void test_DartLibraryImpl_setTopLevel() throws Exception {
    DartLibraryImpl library = getDartLibEmpty();
    library.setTopLevel(true);
    assertTrue(library.isTopLevel());
    library.setTopLevel(false);
    assertFalse(library.isTopLevel());
  }

  public void xtest_DartLibraryImpl_isUnreferenced_imported() throws Exception {
    //
    // This test is currently broken because the libraries used are not included in a library.
    //
    DartLibraryImpl library = getDartLib2();
    DartLibraryImpl importedLibrary = getDartLibEmpty();
    assertTrue(importedLibrary.isUnreferenced());
    library.setTopLevel(true);
    assertFalse(importedLibrary.isUnreferenced());
    library.setTopLevel(false);
    assertTrue(importedLibrary.isUnreferenced());
  }

  public void xtest_DartLibraryImpl_isUnreferenced_topLevel() throws Exception {
    //
    // This test is currently broken because the libraries used are not included in a library.
    //
    DartLibraryImpl library = getDartLibEmpty();
    assertTrue(library.isUnreferenced());
    library.setTopLevel(true);
    assertFalse(library.isUnreferenced());
    library.setTopLevel(false);
    assertTrue(library.isUnreferenced());
  }

  @Override
  protected void setUp() throws Exception {
    super.setUp();
    TestUtilities.processAllDeltaChanges();
  }

  @Override
  protected void tearDown() throws Exception {
    TestUtilities.processAllDeltaChanges();
    super.tearDown();
  }

  private CompilationUnitImpl assertContainsCompUnit(DartElement[] elements, String elemPath,
      boolean inWorkspace, boolean exists) throws DartModelException {
    for (DartElement elem : elements) {
      if (elem instanceof CompilationUnitImpl && elem.getElementName().endsWith(elemPath)) {
        CompilationUnitImpl unit = (CompilationUnitImpl) elem;
        assertHandleMemento(unit);

        if (!exists) {
          return unit;
        }

        // This call causes info to be cached
        String source = unit.getSource();
        unit.getElementInfo();
        assertInfoCached(unit);

        assertNotNull(source);
        assertTrue(source.length() > 10);
        if (inWorkspace) {
          assertNotNull(unit.getResource());
        } else {
          assertNull(unit.getResource());
        }
        return unit;
      }
    }
    failContains(elements, CompilationUnitImpl.class, elemPath);
    return null;
  }

  private DartLibraryImpl assertContainsLibImpl(DartElement[] elements, String elemPath) {
    String suffix = getClass().getSimpleName() + elemPath;
    for (DartElement elem : elements) {
      if (elem instanceof DartLibraryImpl) {
        String libName = elem.getElementName();
        DartLibraryImpl lib = (DartLibraryImpl) elem;
        LibrarySource libSrc = lib.getLibrarySourceFile();
        if (libSrc instanceof UrlLibrarySource) {
          if (libName.endsWith(elemPath)) {
            return (DartLibraryImpl) elem;
          }
        } else if (libName.endsWith(suffix)) {
          return (DartLibraryImpl) elem;
        }
      }
    }
    failContains(elements, DartLibraryImpl.class, suffix);
    return null;
  }

  private void assertDartLib1Children(DartLibraryImpl lib, boolean inWorkspace) throws Exception {
    DartElement[] children = lib.getChildren();
    assertContainsCompUnit(children, "lib1.dart", inWorkspace, true);
    assertContainsCompUnit(children, "SomeClass.dart", inWorkspace, true);
    assertEquals(2, children.length);
  }

  private void assertDartLib2ImportedLibraries() throws Exception {
    DartLibrary[] importedLibraries = getDartLib2().getImportedLibraries();
    assertContainsLibImpl(importedLibraries, "/lib1/lib1.dart");
    assertContainsLibImpl(importedLibraries, "/lib3/lib3.dart");
    assertContainsLibImpl(importedLibraries, "/libExternal/libExternal.dart");
    assertContainsLibImpl(importedLibraries, "/empty/empty.dart");
    assertEquals(4, importedLibraries.length);
  }

  private void assertDartLib3Children(DartLibraryImpl lib, boolean inWorkspace)
      throws DartModelException {

    // This call should cache the library info
    DartElement[] children = lib.getChildren();
    assertInfoCached(lib);

    assertContainsCompUnit(children, "lib3.dart", inWorkspace, false);
    assertContainsCompUnit(children, "AnotherMissingClass.dart", inWorkspace, false);
    assertEquals(2, children.length);
  }

  private void assertDartLib3ImportedLibraries() throws Exception {
    DartLibrary[] importedLibraries = getDartLib3().getImportedLibraries();
    assertContainsLibImpl(importedLibraries, "/empty/empty.dart");
    assertEquals(1, importedLibraries.length);
  }

  /**
   * Assert that a handle memento can be generated from the specified "expected" library and that
   * Dart element recreated from the handle memento equals the "expected" library.
   */
  private void assertHandleMemento(DartElementImpl expected) {
    String memento = expected.getHandleMemento();
    assertNotNull(memento);
    DartElement actual = DartCore.create(memento);
    assertEquals(expected, actual);
  }

  /**
   * Record the specified element as having info cached.
   */
  private void assertInfoCached(DartElement elem) {
    DartModelManager manager = DartModelManager.getInstance();
    if (manager.getInfo(elem) == null) {
      fail("Expected info to be cached for " + elem);
    }
    DartElement parent = elem.getParent();
    if (parent instanceof DartLibraryImpl) {
      DartLibraryImpl lib = (DartLibraryImpl) parent;
      Collection<DartElement> children = libraryChildrenWithCachedInfos.get(lib);
      if (children == null) {
        children = new HashSet<DartElement>();
        libraryChildrenWithCachedInfos.put(lib, children);
      }
      children.add(elem);
    }
  }

  /**
   * Assert that the info for the specified library and all children of that library have been
   * cleared.
   * 
   * @param lib the library (not <code>null</code>)
   */
  private void assertInfoCleared(DartLibraryImpl lib, boolean expectChildInfo) {
    DartModelManager manager = DartModelManager.getInstance();
    if (manager.getInfo(lib) != null) {
      fail("Expected info to be cleared for " + lib);
    }
    Collection<DartElement> children = libraryChildrenWithCachedInfos.remove(lib);
    if (expectChildInfo) {
      if (children == null) {
        fail("No child infos were cached");
      }
      for (DartElement child : children) {
        if (child instanceof CompilationUnitImpl) {
          if (manager.getInfo(child) != null) {
            fail("Expected info to be cleared for " + child);
          }
        }
      }
    }
  }

  private void failContains(DartElement[] elements, Class<?> elemClass, String elemPath) {
    StringBuilder message = new StringBuilder(1000);
    message.append("Failed to find instance of \n" + elemClass + " with path " + elemPath + " in [");
    for (DartElement elem : elements) {
      message.append("\n  ");
      if (elem == null) {
        message.append("null");
      } else {
        message.append(elem.getClass().getName() + " named " + elem.getElementName());
      }
    }
    message.append("\n]");
    fail(message.toString());
  }

  private DartLibraryImpl getBundledLib(String bundledLibName) throws Exception {
    PackageLibraryManager libMgr = PackageLibraryManagerProvider.getPackageLibraryManager();
    URI libUri = new URI(bundledLibName);
    return new DartLibraryImpl(new UrlLibrarySource(libUri, libMgr));
  }

  private DartLibraryImpl getDartLib1() throws Exception {
    if (dartLib1 == null) {
      dartLib1 = getOrCreateDartLib(
          "lib1",
          new DartLibrary[] {getDartLibHtml()},
          "SomeClass",
          "class SomeClass { } main() { }");
    }
    return dartLib1;
  }

  private DartLibraryImpl getDartLib2() throws Exception {
    if (dartLib2 == null) {
      dartLib2 = getOrCreateDartLib("lib2", new DartLibrary[] {
          getDartLibEmpty(), getDartLib1(), getDartLib3(), getDartLibExternal()}, null, null);
    }
    return dartLib2;
  }

  private DartLibraryImpl getDartLib3() throws Exception {
    if (dartLib3 == null) {
      dartLib3 = getOrCreateDartLib(
          "lib3",
          new DartLibrary[] {getDartLibEmpty()},
          "AnotherMissingClass",
          null);
    }
    return dartLib3;
  }

  private DartLibraryImpl getDartLib3Alt() throws Exception {
    if (dartLib3Alt == null) {
      IProject proj = getDartLib3().getResource().getProject();
      File libFile = proj.getFile("lib3.dart").getLocation().toFile();
      dartLib3Alt = new DartLibraryImpl(libFile);
    }
    return dartLib3Alt;
  }

  private DartLibraryImpl getDartLib4() throws Exception {
    if (dartLib4 == null) {
      dartLib4 = getOrCreateDartLib(
          "lib4",
          new DartLibrary[] {getDartLibHtml()},
          "SomeClass",
          "class SomeClass { }");
    }
    return dartLib4;
  }

  private DartLibraryImpl getDartLib5() throws Exception {
    if (dartLib5 == null) {
      dartLib5 = getOrCreateDartLib(
          "lib5",
          new DartLibrary[] {getDartLib5a()},
          "SomeClass",
          "class SomeClass { } main() { }");
    }
    return dartLib5;
  }

  private DartLibraryImpl getDartLib5a() throws Exception {
    if (dartLib5a == null) {
      dartLib5a = getOrCreateDartLib(
          "lib5a",
          new DartLibrary[] {getDartLibHtml()},
          "SomeClass2",
          "class SomeClass2 { }");
    }
    return dartLib5a;
  }

  private DartLibraryImpl getDartLib6() throws Exception {
    if (dartLib6 == null) {
      dartLib6 = getOrCreateDartLib(
          "lib6",
          new DartLibrary[] {getDartLib3()},
          "SomeClass",
          "class SomeClass { } main() { }");
    }
    return dartLib6;
  }

  private DartLibraryImpl getDartLibCore() throws Exception {
    return getBundledLib("dart:core");
  }

  private DartLibraryImpl getDartLibEmpty() throws Exception {
    if (dartLibEmpty == null) {
      dartLibEmpty = getOrCreateDartLib("empty", null, null, null);
    }
    return dartLibEmpty;
  }

  private DartLibraryImpl getDartLibExternal() throws Exception {
    if (dartLibExternal == null) {
      File libFile = getOrCreateLibFile(
          "libExternal",
          new DartLibrary[] {getDartLibEmpty()},
          "ALib5MissingClass",
          null);
      dartLibExternal = new DartLibraryImpl(libFile);
    }
    return dartLibExternal;
  }

  private DartLibraryImpl getDartLibHtml() throws Exception {
    return getBundledLib("dart:html");
  }

  private DartLibraryImpl getDartLibJson() throws Exception {
    return getBundledLib("dart:json");
  }

  private DartModelImpl getDartModel() {
    return DartModelManager.getInstance().getDartModel();
  }

  private DartLibraryImpl getOrCreateDartLib(String libName, DartLibrary[] importLibs,
      String className, String fileContent) throws IOException, DartModelException {
    File libFile = getOrCreateLibFile(libName, importLibs, className, fileContent);
    TestUtilities.processAllDeltaChanges();
    IResource libRes = ResourceUtil.getResource(libFile);
    if (libRes != null) {
      DartElement elem = DartCore.create(libRes);
      if (elem instanceof CompilationUnitImpl) {
        elem = ((CompilationUnitImpl) elem).getLibrary();
      }
      if (elem instanceof DartLibraryImpl) {
        return (DartLibraryImpl) elem;
      }
    }
    return (DartLibraryImpl) DartCore.openLibrary(libFile, new NullProgressMonitor());
  }

  private File getOrCreateLibFile(String libName, DartLibrary[] importLibs, String className,
      String fileContent) throws IOException {
    File libDir = new File(getTempDir(), libName);
    File libFile = new File(libDir, libName + ".dart");
    if (!libFile.exists()) {
      List<File> importFiles = new ArrayList<File>();
      if (importLibs != null) {
        for (DartLibrary lib : importLibs) {
          String libPath = lib.getElementName();
          if (libPath.startsWith("file:")) {
            libPath = libPath.substring(5);
          }
          importFiles.add(new File(libPath));
        }
      }
      List<File> sourceFiles = new ArrayList<File>();
      if (className != null) {
        sourceFiles.add(new File(libDir, className + ".dart"));
      }
      final String content = DefaultLibrarySource.generateSource(
          libName,
          libFile,
          importFiles,
          sourceFiles,
          null);
      makeTempDir(libDir);
      createTempFile(libFile, content);
      if (fileContent != null) {
        File classFile = new File(libDir, className + ".dart");
        createTempFile(classFile, fileContent);
      }
    }
    return libFile;
  }

  private IPath getTempDirPath() throws IOException {
    return Path.fromOSString(getTempDir().getAbsolutePath());
  }

}
