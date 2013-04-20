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
package com.google.dart.tools.ui.internal.actions;

import com.google.common.collect.Sets;
import com.google.dart.tools.core.DartCore;
import com.google.dart.tools.core.DartCoreDebug;
import com.google.dart.tools.core.model.CompilationUnit;
import com.google.dart.tools.core.model.DartElement;
import com.google.dart.tools.core.model.DartProject;
import com.google.dart.tools.internal.corext.refactoring.RefactoringExecutionStarter_OLD;
import com.google.dart.tools.internal.corext.refactoring.util.Messages;
import com.google.dart.tools.ui.DartToolsPlugin;
import com.google.dart.tools.ui.DartUI;
import com.google.dart.tools.ui.actions.ActionMessages;
import com.google.dart.tools.ui.actions.InstrumentedSelectionDispatchAction;
import com.google.dart.tools.ui.cleanup.ICleanUp;
import com.google.dart.tools.ui.instrumentation.UIInstrumentationBuilder;
import com.google.dart.tools.ui.internal.cleanup.CleanUpRefactoringWizard;
import com.google.dart.tools.ui.internal.text.editor.DartEditor;
import com.google.dart.tools.ui.internal.util.DartModelUtil;
import com.google.dart.tools.ui.internal.util.ElementValidator;
import com.google.dart.tools.ui.internal.viewsupport.BasicElementLabels;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.MultiStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.dialogs.ErrorDialog;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.text.ITextSelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.swt.widgets.Event;
import org.eclipse.ui.IWorkbenchSite;

import java.lang.reflect.InvocationTargetException;
import java.util.Collection;
import java.util.Collections;
import java.util.Set;

public class CleanUpAction extends InstrumentedSelectionDispatchAction {

  private static CompilationUnit getCompilationUnit(DartEditor editor) {
    DartElement element = DartUI.getEditorInputDartElement(editor.getEditorInput());
    if (!(element instanceof CompilationUnit)) {
      return null;
    }
    return (CompilationUnit) element;
  }

  private DartEditor editor;

  public CleanUpAction(DartEditor editor) {
    this(editor.getEditorSite());
    this.editor = editor;
    setEnabled(getCompilationUnit(editor) != null);
  }

  public CleanUpAction(IWorkbenchSite site) {
    super(site);
    setText(getActionName());
  }

  public CompilationUnit[] getCompilationUnits(IStructuredSelection selection) {
    Set<DartElement> result = Sets.newHashSet();
    for (Object element : selection.toArray()) {
      collectCompilationUnits(element, result);
    }
    CompilationUnit[] units = result.toArray(new CompilationUnit[result.size()]);
    units = DartModelUtil.getExistingCompilationUnits(units);
    units = DartModelUtil.getUniqueCompilationUnits(units);
    units = DartModelUtil.getNotPackageCompilationUnits(units);
    return units;
  }

  @Override
  public void selectionChanged(IStructuredSelection selection) {
    setEnabled(isEnabled(selection));
  }

  @Override
  public void selectionChanged(ITextSelection selection) {
    setEnabled(getCompilationUnit(editor) != null);
  }

  @Override
  protected void doRun(IStructuredSelection selection, Event event,
      UIInstrumentationBuilder instrumentation) {
    CompilationUnit[] cus = getCompilationUnits(selection);

    instrumentation.metric("CompilationUnits-Count", cus.length);
    //before
    instrumentation.record(cus, "Before");

    if (cus.length == 0) {
      instrumentation.metric("Problem", "No compilation Units");
      MessageDialog.openInformation(
          getShell(),
          getActionName(),
          ActionMessages.CleanUpAction_EmptySelection_description);
    } else if (cus.length == 1) {
      run(cus[0], instrumentation);
    } else {
      runOnMultiple(cus, instrumentation);
    }

    //Add marker to make back-end processing of before and after easier
    instrumentation.metric("CleanUp", "Complete");
    instrumentation.record(cus, "After");
  }

  @Override
  protected void doRun(ITextSelection selection, Event event,
      UIInstrumentationBuilder instrumentation) {
    CompilationUnit cu = getCompilationUnit(editor);
    if (cu != null) {
      instrumentation.record(cu);
      run(cu, instrumentation);
      instrumentation.metric("CleanUp", "Complete");
      instrumentation.record(cu);
    } else {
      instrumentation.metric("Problem", "CompilationUnit was null");
    }
  }

  /**
   * @return the name of this action, not <b>null</b>
   */
  protected String getActionName() {
    return "Clean Up Source...";
  }

  /**
   * @return the {@link ICleanUp}s to be performed.
   */
  protected ICleanUp[] getCleanUps(CompilationUnit[] units) {
    return new ICleanUp[] {};
  }

  protected void performRefactoring(CompilationUnit[] units, ICleanUp[] cleanUps)
      throws InvocationTargetException {
    RefactoringExecutionStarter_OLD.startCleanupRefactoring(
        units,
        cleanUps,
        false,
        getShell(),
        showWizard(),
        getActionName());
  }

  /**
   * @return <code>true</code> if this instance of {@link CleanUpAction} should show
   *         {@link CleanUpRefactoringWizard} to choose set of {@link ICleanUp}s to run.
   */
  protected boolean showWizard() {
    return true;
  }

//  private void collectCompilationUnits(IPackageFragment pack, Collection<DartElement> result)
//      throws DartModelException {
//    result.addAll(Arrays.asList(pack.getCompilationUnits()));
//  }
//
//  private void collectCompilationUnits(IPackageFragmentRoot root, Collection<DartElement> result)
//      throws DartModelException {
//    if (root.getKind() == IPackageFragmentRoot.K_SOURCE) {
//      DartElement[] children = root.getChildren();
//      for (int i = 0; i < children.length; i++) {
//        collectCompilationUnits((IPackageFragment) children[i], result);
//      }
//    }
//  }

  private void collectCompilationUnits(Object element, Collection<DartElement> result) {
    try {
      // IFolder cannot be DartElement
      if (element instanceof IFolder) {
        IFolder folder = (IFolder) element;
        for (IResource member : folder.members()) {
          collectCompilationUnits(member, result);
        }
        return;
      }
      // may be some DartElement
      DartElement elem = null;
      if (element instanceof DartElement) {
        elem = (DartElement) element;
      }
      if (element instanceof IFile) {
        IFile file = (IFile) element;
        elem = DartCore.create(file);
      }
      if (element instanceof IProject) {
        IProject folder = (IProject) element;
        elem = DartCore.create(folder);
      }
      if (elem != null) {
        switch (elem.getElementType()) {
          case DartElement.COMPILATION_UNIT:
            result.add(elem);
            break;
          case DartElement.DART_PROJECT:
            DartProject dartProject = (DartProject) elem;
            CompilationUnit[] units = DartModelUtil.getAllCompilationUnits(new DartElement[] {dartProject});
            Collections.addAll(result, units);
            break;
        }
      }
    } catch (CoreException e) {
      if (DartModelUtil.isExceptionToBeLogged(e)) {
        DartToolsPlugin.log(e);
      }
    }
  }

  private boolean isEnabled(IStructuredSelection selection) {

    //TODO (pquitslund): add support for the new analysis engine
    if (DartCoreDebug.ENABLE_NEW_ANALYSIS) {
      return false;
    }

    // TODO(scheglov) always enabled?
    CompilationUnit[] cus = getCompilationUnits(selection);
    return cus.length != 0;
//    for (int i = 0; i < selected.length; i++) {
//      try {
//        if (selected[i] instanceof DartElement) {
//          DartElement elem = (DartElement) selected[i];
//          if (elem.exists()) {
//            switch (elem.getElementType()) {
//              case DartElement.TYPE:
//                return elem.getParent().getElementType() == DartElement.COMPILATION_UNIT; // for browsing perspective
//              case DartElement.COMPILATION_UNIT:
//                return true;
//              case DartElement.IMPORT_CONTAINER:
//                return true;
//              case DartElement.PACKAGE_FRAGMENT:
//              case DartElement.PACKAGE_FRAGMENT_ROOT:
//                IPackageFragmentRoot root = (IPackageFragmentRoot) elem.getAncestor(DartElement.PACKAGE_FRAGMENT_ROOT);
//                return (root.getKind() == IPackageFragmentRoot.K_SOURCE);
//              case DartElement.JAVA_PROJECT:
//                // https://bugs.eclipse.org/bugs/show_bug.cgi?id=65638
//                return true;
//            }
//          }
//        } else if (selected[i] instanceof LogicalPackage) {
//          return true;
//        } else if (selected[i] instanceof IWorkingSet) {
//          IWorkingSet workingSet = (IWorkingSet) selected[i];
//          return IWorkingSetIDs.JAVA.equals(workingSet.getId());
//        }
//      } catch (DartModelException e) {
//        if (!e.isDoesNotExist()) {
//          DartToolsPlugin.log(e);
//        }
//      }
//    }
//    return false;
  }

  private void run(CompilationUnit cu, UIInstrumentationBuilder instrumentation) {

    if (!ActionUtil.isEditable(editor, getShell(), cu)) {
      instrumentation.metric("Problem", "CompilationUnit was not editable");
      return;
    }

    ICleanUp[] cleanUps = getCleanUps(new CompilationUnit[] {cu});
    if (cleanUps == null) {
      instrumentation.metric("Problem", "CleanUps was null");
      return;
    }

    if (!ElementValidator.check(cu, getShell(), getActionName(), editor != null)) {
      instrumentation.metric("Problem", "ElementValidator failed");
      return;
    }

    try {
      performRefactoring(new CompilationUnit[] {cu}, cleanUps);
    } catch (InvocationTargetException e) {
      DartToolsPlugin.log(e);
      if (e.getCause() instanceof CoreException) {
        showUnexpectedError((CoreException) e.getCause());
      }
    }
  }

  private void runOnMultiple(CompilationUnit[] cus, UIInstrumentationBuilder instrumentation) {

    ICleanUp[] cleanUps = getCleanUps(cus);
    if (cleanUps == null) {
      instrumentation.metric("Problem", "CleanUps was null");
      return;
    }

    MultiStatus status = new MultiStatus(
        DartUI.ID_PLUGIN,
        IStatus.OK,
        ActionMessages.CleanUpAction_MultiStateErrorTitle,
        null);
    for (int i = 0; i < cus.length; i++) {
      CompilationUnit cu = cus[i];

      if (!ActionUtil.isOnBuildPath(cu)) {

        String cuLocation = BasicElementLabels.getPathLabel(cu.getPath(), false);
        String message = Messages.format(
            ActionMessages.CleanUpAction_CUNotOnBuildpathMessage,
            cuLocation);
        status.add(new Status(IStatus.INFO, DartUI.ID_PLUGIN, IStatus.ERROR, message, null));

        instrumentation.metric("Problem", "CompilationUnit Not on BuildPath");
        instrumentation.data("CU-Name", cu.getElementName()).data("CU-Location", cuLocation);
      }
    }
    if (!status.isOK()) {
      instrumentation.metric("Problem", "Status not OK");
      ErrorDialog.openError(getShell(), getActionName(), null, status);
      return;
    }

    try {
      performRefactoring(cus, cleanUps);
    } catch (InvocationTargetException e) {
      DartToolsPlugin.log(e);
      if (e.getCause() instanceof CoreException) {
        showUnexpectedError((CoreException) e.getCause());
      }
    }
  }

  private void showUnexpectedError(CoreException e) {
    String message2 = Messages.format(
        ActionMessages.CleanUpAction_UnexpectedErrorMessage,
        e.getStatus().getMessage());
    IStatus status = new Status(IStatus.ERROR, DartUI.ID_PLUGIN, IStatus.ERROR, message2, null);
    ErrorDialog.openError(getShell(), getActionName(), null, status);
  }

}
