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
package com.google.dart.tools.ui.internal.refactoring;

import com.google.dart.tools.internal.corext.refactoring.code.ExtractMethodRefactoring_I;
import com.google.dart.tools.ui.DartToolsPlugin;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.ltk.core.refactoring.Change;
import org.eclipse.ltk.core.refactoring.Refactoring;
import org.eclipse.ltk.ui.refactoring.RefactoringWizard;

public class ExtractMethodWizard extends RefactoringWizard {

  static final String DIALOG_SETTING_SECTION = "ExtractMethodWizard"; //$NON-NLS-1$

  public ExtractMethodWizard(ExtractMethodRefactoring_I ref) {
    super((Refactoring) ref, DIALOG_BASED_USER_INTERFACE | PREVIEW_EXPAND_FIRST_NODE);
    setDefaultPageTitle(RefactoringMessages.ExtractMethodWizard_extract_method);
    setDialogSettings(DartToolsPlugin.getDefault().getDialogSettings());
  }

  public Change createChange() {
    // creating the change is cheap. So we don't need to show progress.
    try {
      return getRefactoring().createChange(new NullProgressMonitor());
    } catch (CoreException e) {
      DartToolsPlugin.log(e);
      return null;
    }
  }

  @Override
  protected void addUserInputPages() {
    addPage(new ExtractMethodInputPage());
  }
}
