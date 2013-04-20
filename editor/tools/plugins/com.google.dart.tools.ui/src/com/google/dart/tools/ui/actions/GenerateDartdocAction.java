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

package com.google.dart.tools.ui.actions;

import com.google.dart.engine.element.Element;
import com.google.dart.engine.element.LibraryElement;
import com.google.dart.tools.core.DartCore;
import com.google.dart.tools.core.DartCoreDebug;
import com.google.dart.tools.core.analysis.model.ProjectManager;
import com.google.dart.tools.core.dartdoc.DartdocGenerator;
import com.google.dart.tools.core.model.DartElement;
import com.google.dart.tools.core.model.DartLibrary;
import com.google.dart.tools.core.model.DartModelException;
import com.google.dart.tools.ui.ImportedDartLibraryContainer;
import com.google.dart.tools.ui.instrumentation.UIInstrumentationBuilder;
import com.google.dart.tools.ui.internal.util.ExternalBrowserUtil;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.OperationCanceledException;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.osgi.util.NLS;
import org.eclipse.swt.widgets.Event;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IEditorReference;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.IPartListener;
import org.eclipse.ui.ISelectionListener;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.actions.ActionFactory.IWorkbenchAction;

/**
 * An action to create Dart documentation for some library.
 * 
 * @see GenerateJavascriptAction
 */
public class GenerateDartdocAction extends InstrumentedAction implements IWorkbenchAction,
    ISelectionListener, IPartListener {

  class DeployOptimizedJob extends InstrumentedJob {
    private IFile file;

    public DeployOptimizedJob(IWorkbenchPage page, IFile file) {
      super(ActionMessages.GenerateDartdocAction_jobTitle);

      this.file = file;

      // Synchronize on the workspace root to catch any builds that are in progress.
      setRule(ResourcesPlugin.getWorkspace().getRoot());

      // Make sure we display a progress dialog if we do block.
      setUser(true);
    }

    @Override
    protected IStatus doRun(IProgressMonitor monitor, UIInstrumentationBuilder instrumentation) {
      try {
        monitor.beginTask(
            ActionMessages.GenerateDartdocAction_Compiling + file.getName(),
            IProgressMonitor.UNKNOWN);

        DartdocGenerator.generateDartdoc(file, monitor, DartCore.getConsole());

        return Status.OK_STATUS;
      } catch (OperationCanceledException exception) {

        instrumentation.metric("Problem", "User cancelled generation");
        // The user cancelled.
        DartCore.getConsole().println("Generation cancelled.");

        return Status.CANCEL_STATUS;
      } catch (Exception exception) {

        instrumentation.metric("Problem-Exception", exception.getClass().toString());
        instrumentation.data("Problem-Exception", exception.toString());

        DartCore.getConsole().println(
            NLS.bind(ActionMessages.GenerateDartdocAction_FailException, exception.toString()));

        return Status.CANCEL_STATUS;
      } finally {
        if (OPEN_BROWSER_AFTER_GENERATION) {
          String url = "file://"
              + DartdocGenerator.getDocsIndexPath(file.getLocation()).toOSString();

          instrumentation.metric("DartDocOpenInBrowser", "Opening");
          instrumentation.data("DartDocOpenInBrowser", url);

          ExternalBrowserUtil.openInExternalBrowser(url);
        }

        monitor.done();
      }
    }
  }

  private final static boolean OPEN_BROWSER_AFTER_GENERATION = false;

  private IWorkbenchWindow window;

  private Object selectedObject;

  public GenerateDartdocAction(IWorkbenchWindow window) {
    this.window = window;

    setText(ActionMessages.GenerateDartdocAction_title);
    setActionDefinitionId("com.google.dart.tools.ui.generateDartdoc");
    setDescription(ActionMessages.GenerateDartdocAction_description);
    setToolTipText(ActionMessages.GenerateDartdocAction_tooltip);
    //setImageDescriptor(DartToolsPlugin.getImageDescriptor("icons/full/dart16/library_opt.png"));
    window.getPartService().addPartListener(this);
    window.getSelectionService().addSelectionListener(this);
  }

  @Override
  public void dispose() {

  }

  @Override
  public void doRun(Event event, UIInstrumentationBuilder instrumentation) {
    deployOptimized(window.getActivePage(), instrumentation);
  }

  @Override
  public void partActivated(IWorkbenchPart part) {
    if (part instanceof IEditorPart) {
      handleEditorActivated((IEditorPart) part);
    }
  }

  @Override
  public void partBroughtToTop(IWorkbenchPart part) {

  }

  @Override
  public void partClosed(IWorkbenchPart part) {

  }

  @Override
  public void partDeactivated(IWorkbenchPart part) {

  }

  @Override
  public void partOpened(IWorkbenchPart part) {

  }

  @Override
  public void selectionChanged(IWorkbenchPart part, ISelection selection) {
    if (selection instanceof IStructuredSelection) {
      handleSelectionChanged((IStructuredSelection) selection);
    }
  }

  private void deployOptimized(IWorkbenchPage page, UIInstrumentationBuilder instrumentation) {
    boolean isSaveNeeded = isSaveAllNeeded(page);

    instrumentation.metric("isSaveNeeded", String.valueOf(isSaveNeeded));

    if (isSaveNeeded) {
      if (!saveDirtyEditors(page)) {
        instrumentation.metric("Problem", "User cancelled launch");
        // The user cancelled the launch.
        return;
      }
    }

    IFile libraryFile = getCurrentLibrary();

    if (libraryFile == null) {
      instrumentation.metric("Problem", "No library selected");
      MessageDialog.openError(
          window.getShell(),
          ActionMessages.GenerateDartdocAction_unableToLaunch,
          ActionMessages.GenerateDartdocAction_noneSelected);
    } else {
      DeployOptimizedJob job = new DeployOptimizedJob(page, libraryFile);
      job.schedule(isSaveNeeded ? 100 : 0);
    }
  }

  private IFile getCurrentLibrary() {
    if (DartCoreDebug.ENABLE_NEW_ANALYSIS) {
      LibraryElement library = getCurrentLibrary_newModel();

      if (library != null) {
        ProjectManager manager = DartCore.getProjectManager();

        return (IFile) manager.getResource(library.getDefiningCompilationUnit().getSource());
      }
    } else {
      DartLibrary library = getCurrentLibrary_oldModel();

      if (library != null) {
        try {
          return (IFile) library.getDefiningCompilationUnit().getCorrespondingResource();
        } catch (DartModelException e) {

        }
      }
    }

    return null;
  }

  private LibraryElement getCurrentLibrary_newModel() {
    ProjectManager manager = DartCore.getProjectManager();

    IResource resource = null;
    Element element = null;

    if (selectedObject == null) {
      IWorkbenchPage page = window.getActivePage();

      if (page != null) {
        IEditorPart part = page.getActiveEditor();

        if (part != null) {
          selectedObject = part.getEditorInput().getAdapter(IResource.class);
        }
      }
    }

    if (selectedObject instanceof IResource) {
      resource = (IResource) selectedObject;
    }

    if (resource instanceof IFile) {
      element = manager.getLibraryElement((IFile) resource);
    }

    if (selectedObject instanceof Element) {
      element = (Element) selectedObject;
    }

    if (element != null) {
      return element.getLibrary();
    }

    return null;
  }

  @Deprecated
  private DartLibrary getCurrentLibrary_oldModel() {
    IResource resource = null;
    DartElement element = null;

    if (selectedObject == null) {
      IWorkbenchPage page = window.getActivePage();

      if (page != null) {
        IEditorPart part = page.getActiveEditor();

        if (part != null) {
          selectedObject = part.getEditorInput().getAdapter(IResource.class);
        }
      }
    }

    if (selectedObject instanceof IResource) {
      resource = (IResource) selectedObject;
    }

    if (resource != null) {
      element = DartCore.create(resource);
    }

    if (selectedObject instanceof DartElement) {
      element = (DartElement) selectedObject;
    }

    if (selectedObject instanceof ImportedDartLibraryContainer) {
      element = ((ImportedDartLibraryContainer) selectedObject).getDartLibrary();
    }

    if (element == null) {
      return null;
    } else {
      // DartElement in a library
      DartLibrary library = element.getAncestor(DartLibrary.class);

      return library;
    }
  }

  private void handleEditorActivated(IEditorPart editorPart) {
    if (editorPart.getEditorInput() instanceof IFileEditorInput) {
      IFileEditorInput input = (IFileEditorInput) editorPart.getEditorInput();

      handleSelectionChanged(new StructuredSelection(input.getFile()));
    }
  }

  private void handleSelectionChanged(IStructuredSelection selection) {
    if (selection != null && !selection.isEmpty()) {
      selectedObject = selection.getFirstElement();
    } else {
      selectedObject = null;
    }
  }

  private boolean isSaveAllNeeded(IWorkbenchPage page) {
    IEditorReference[] editors = page.getEditorReferences();
    for (int i = 0; i < editors.length; i++) {
      IEditorReference ed = editors[i];
      if (ed.isDirty()) {
        return true;
      }
    }
    return false;
  }

  private boolean saveDirtyEditors(IWorkbenchPage page) {
    return page.saveAllEditors(false);
  }

}
