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
package com.google.dart.tools.ui.internal.refactoring.reorg;

import com.google.dart.tools.ui.DartPluginImages;
import com.google.dart.tools.ui.internal.refactoring.RefactoringMessages;
import com.google.dart.tools.ui.internal.text.DartHelpContextIds;

import org.eclipse.ltk.core.refactoring.Refactoring;

/**
 * @coverage dart.editor.ui.refactoring.ui
 */
public class RenameFieldWizard extends RenameRefactoringWizard {

  public RenameFieldWizard(Refactoring refactoring) {
    super(
        refactoring,
        RefactoringMessages.RenameFieldWizard_defaultPageTitle,
        RefactoringMessages.RenameFieldWizard_inputPage_description,
        DartPluginImages.DESC_WIZBAN_REFACTOR_FIELD,
        DartHelpContextIds.RENAME_FIELD_WIZARD_PAGE);
  }
}
