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

package com.google.dart.tools.debug.ui.launch;

import com.google.dart.compiler.util.apache.StringUtils;
import com.google.dart.tools.debug.core.DartLaunchConfigWrapper;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.OperationCanceledException;
import org.eclipse.debug.core.ILaunchConfiguration;
import org.eclipse.debug.core.ILaunchConfigurationWorkingCopy;
import org.eclipse.ltk.core.refactoring.Change;
import org.eclipse.ltk.core.refactoring.NullChange;
import org.eclipse.ltk.core.refactoring.RefactoringStatus;
import org.eclipse.ltk.core.refactoring.participants.CheckConditionsContext;
import org.eclipse.ltk.core.refactoring.participants.RenameParticipant;

/**
 * A class to handle renaming Dart launches.
 */
public class LaunchesRenameResourceParticipant extends RenameParticipant {

  private static class UpdateConfigurationHtml extends NullChange {
    private final ILaunchConfiguration configuration;
    private final String newName;

    public UpdateConfigurationHtml(ILaunchConfiguration configuration, String newName) {
      super("Update HTML file in launch configuration: " + configuration.getName());
      this.configuration = configuration;
      this.newName = newName;
    }

    @Override
    public Change perform(IProgressMonitor pm) throws CoreException {
      ILaunchConfigurationWorkingCopy wc = configuration.getWorkingCopy();
      DartLaunchConfigWrapper wcWrapper = new DartLaunchConfigWrapper(wc);
      String oldPath = wcWrapper.getApplicationName();
      // set new path
      String newPath = StringUtils.substringBeforeLast(oldPath, "/") + "/" + newName;
      wcWrapper.setApplicationName(newPath);
      wc.doSave();
      // return undo
      String oldName = StringUtils.substringAfterLast(oldPath, "/");
      return new UpdateConfigurationHtml(configuration, oldName);
    }
  }

  private IFile file;

  @Override
  public RefactoringStatus checkConditions(IProgressMonitor pm, CheckConditionsContext context)
      throws OperationCanceledException {
    return null;
  }

  @Override
  public Change createChange(IProgressMonitor pm) throws CoreException, OperationCanceledException {
    // TODO(scheglov) implement for new engine
    return null;
  }

  @Override
  public String getName() {
    return "Update HTML files in launch configurations";
  }

  @Override
  protected boolean initialize(Object element) {
    // TODO(scheglov) implement for new engine
    return false;
  }

}
