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

package com.google.dart.tools.ui.internal.testing;

import com.google.dart.tools.core.DartCore;
import com.google.dart.tools.core.model.CompilationUnit;
import com.google.dart.tools.core.model.DartElement;
import com.google.dart.tools.core.model.DartLibrary;
import com.google.dart.tools.core.model.DartModelException;
import com.google.dart.tools.ui.DartToolsPlugin;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceChangeEvent;
import org.eclipse.core.resources.IResourceChangeListener;
import org.eclipse.core.resources.IResourceVisitor;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.swt.widgets.Display;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * A tree content provider for the Tests view.
 */
class TestsContentProvider implements ITreeContentProvider, IResourceChangeListener {
  private static final IResource[] NO_CHILDREN = new IResource[0];

//  private IProject project;
  private Viewer viewer;

  TestsContentProvider(IProject project) {
//    this.project = project;

    ResourcesPlugin.getWorkspace().addResourceChangeListener(this);
  }

  @Override
  public void dispose() {
    ResourcesPlugin.getWorkspace().removeResourceChangeListener(this);
  }

  @Override
  public Object[] getChildren(Object element) {
    try {
      if (element instanceof IProject) {
        IProject project = (IProject) element;

        return getChildDartFiles(project);
      } else if (element instanceof IFile) {
        IFile file = (IFile) element;

        return getTestsElementsFor(file).toArray();
      }
    } catch (CoreException ce) {
      // fall through

    }

    return NO_CHILDREN;
  }

  @Override
  public Object[] getElements(Object inputElement) {
    return getChildren(inputElement);
  }

  @Override
  public Object getParent(Object element) {
    if (element instanceof IResource) {
      return ((IResource) element).getProject();
    } else if (element instanceof DartUnitElement) {
      DartUnitElement dartElement = (DartUnitElement) element;

      if (dartElement.getParent() != null) {
        return dartElement.getParent();
      } else {
        return dartElement.getDartFile();
      }
    } else {
      return null;
    }
  }

  @Override
  public boolean hasChildren(Object element) {
    return getChildren(element).length > 0;
  }

  @Override
  public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {
    this.viewer = viewer;
  }

  @Override
  public void resourceChanged(IResourceChangeEvent event) {
    // TODO: filter on project

    Display.getDefault().asyncExec(new Runnable() {
      @Override
      public void run() {
        if (viewer != null && !viewer.getControl().isDisposed()) {
          viewer.refresh();
        }
      }
    });
  }

  protected boolean isFiltered(IContainer container) {
    return !DartCore.isAnalyzed(container);
  }

  private void collectElements(CompilationUnit cu, List<DartUnitElement> elements) {
    // TODO Auto-generated method stub
    // 

  }

  private IFile[] getChildDartFiles(IProject project) throws CoreException {
    final List<IFile> files = new ArrayList<IFile>();

    project.accept(new IResourceVisitor() {
      @Override
      public boolean visit(IResource resource) throws CoreException {
        if (resource instanceof IContainer) {
          return !isFiltered((IContainer) resource);
        } else if (resource instanceof IFile) {
          IFile file = (IFile) resource;

          if (DartCore.isDartLikeFileName(file.getName())) {
            files.add(file);
          }

          return true;
        } else {

          return false;
        }
      }
    });

    return files.toArray(new IFile[files.size()]);
  }

  private List<DartUnitElement> getTestsElementsFor(IFile file) {
    DartElement modelElement = DartCore.create(file);

    if (modelElement instanceof CompilationUnit) {
      List<DartUnitElement> elements = new ArrayList<DartUnitElement>();

      // unittest : typedef void TestFunction();
      // unittest : void group(String description, void body())

      // unittest : void test(String spec, TestFunction body)
      // unittest : void solo_test(String spec, TestFunction body)

      CompilationUnit cu = (CompilationUnit) modelElement;

      try {
        if (imports(cu, "unittest")) {
          // TODO:
          System.out.println(modelElement.getElementName() + " imports unittest");

          collectElements(cu, elements);
        }
      } catch (DartModelException e) {
        DartToolsPlugin.log(e);
      }

      return elements;
    } else {
      return Collections.emptyList();
    }
  }

  private boolean imports(CompilationUnit cu, String libraryName) throws DartModelException {
    return imports(cu.getLibrary(), libraryName, new HashSet<DartLibrary>());
  }

  private boolean imports(DartLibrary library, String libraryName, Set<DartLibrary> visited)
      throws DartModelException {
    if (visited.contains(library)) {
      return false;
    }

    if (libraryName.equals(library.getDisplayName())) {
      return true;
    }

    visited.add(library);

    for (DartLibrary lib : library.getImportedLibraries()) {
      if (imports(lib, libraryName, visited)) {
        return true;
      }
    }

    return false;
  }

}
