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
package com.google.dart.tools.internal.corext.refactoring.rename;

import com.google.dart.compiler.util.apache.FileUtils;
import com.google.dart.tools.core.DartCore;
import com.google.dart.tools.internal.corext.refactoring.util.ExecutionUtils;
import com.google.dart.tools.internal.corext.refactoring.util.RunnableObjectEx;
import com.google.dart.tools.ui.internal.refactoring.RefactoringMessages;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IProjectDescription;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.OperationCanceledException;
import org.eclipse.ltk.core.refactoring.Change;
import org.eclipse.ltk.core.refactoring.RefactoringStatus;
import org.eclipse.ltk.core.refactoring.participants.CheckConditionsContext;
import org.eclipse.ltk.core.refactoring.participants.RenameArguments;
import org.eclipse.ltk.core.refactoring.participants.RenameParticipant;
import org.eclipse.ltk.core.refactoring.resource.ResourceChange;

import java.io.File;

/**
 * {@link RenameParticipant} for renaming {@link IProject} folder on disk.
 * 
 * @coverage dart.editor.ui.refactoring.core
 */
public class RenameProjectParticipant extends RenameParticipant {

  private static final class RenameProjectFolderChange extends ResourceChange {
    private final IProject project;
    private final String newName;

    public RenameProjectFolderChange(IProject project, String newName) {
      this.project = project;
      this.newName = newName;
    }

    @Override
    public String getName() {
      return "Rename project folder on disk";
    }

    @Override
    public Change perform(IProgressMonitor pm) throws CoreException {
      try {
        // "project" was already renamed at this point
        IProject project = ResourcesPlugin.getWorkspace().getRoot().getProject(newName);
        IProjectDescription description = project.getDescription();
        // prepare locations
        File currentFile = FileUtils.toFile(description.getLocationURI().toURL());
        File newFile = new File(currentFile.getParentFile(), newName);
        // point project to this new folder
        {
          description.setLocationURI(newFile.toURI());
          project.move(description, IResource.FORCE | IResource.SHALLOW, pm);
        }
        // rename folder on disk
        currentFile.renameTo(newFile);
      } catch (Throwable e) {
        DartCore.logError(e);
        return null;
      }
      return null;
    }

    @Override
    protected IResource getModifiedResource() {
      return project;
    }
  }

  private IProject project;

  @Override
  public RefactoringStatus checkConditions(IProgressMonitor pm, CheckConditionsContext context)
      throws OperationCanceledException {
    return new RefactoringStatus();
  }

  @Override
  public Change createChange(final IProgressMonitor pm) throws CoreException,
      OperationCanceledException {
    return ExecutionUtils.runObjectCore(new RunnableObjectEx<Change>() {
      @Override
      public Change runObject() throws Exception {
        return createChangeEx(pm);
      }
    });
  }

  @Override
  public String getName() {
    return RefactoringMessages.RenameResourceParticipant_name;
  }

  @Override
  protected boolean initialize(Object element) {
    if (element instanceof IProject) {
      project = (IProject) element;
      return true;
    }
    return false;
  }

  /**
   * Implementation of {@link #createChange(IProgressMonitor)} which can throw any exception.
   */
  private Change createChangeEx(IProgressMonitor pm) throws Exception {
    RenameArguments arguments = getArguments();
    return new RenameProjectFolderChange(project, arguments.getNewName());
  }

}
