/*
 * Copyright (c) 2013, the Dart project authors.
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
import com.google.dart.engine.element.ElementKind;
import com.google.dart.engine.services.assist.AssistContext;
import com.google.dart.engine.services.refactoring.InlineMethodRefactoring;
import com.google.dart.engine.services.refactoring.RefactoringFactory;
import com.google.dart.tools.internal.corext.refactoring.code.InlineMethodRefactoring_I;
import com.google.dart.tools.ui.DartToolsPlugin;
import com.google.dart.tools.ui.internal.refactoring.InlineMethodWizard;
import com.google.dart.tools.ui.internal.refactoring.RefactoringMessages;
import com.google.dart.tools.ui.internal.refactoring.RefactoringSaveHelper;
import com.google.dart.tools.ui.internal.refactoring.ServiceInlineMethodRefactoring;
import com.google.dart.tools.ui.internal.refactoring.actions.RefactoringStarter;
import com.google.dart.tools.ui.internal.text.DartHelpContextIds;
import com.google.dart.tools.ui.internal.text.editor.DartEditor;
import com.google.dart.tools.ui.internal.text.editor.DartSelection;

import org.eclipse.jface.action.Action;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.PlatformUI;

/**
 * {@link Action} for "Inline Method" refactoring.
 */
public class InlineMethodAction extends AbstractDartSelectionAction {
  public InlineMethodAction(DartEditor editor) {
    super(editor);
  }

  @Override
  public void selectionChanged(DartSelection selection) {
    Element element = getSelectionElement(selection);
    if (element == null) {
      setEnabled(false);
      return;
    }
    ElementKind elementKind = element.getKind();
    setEnabled(elementKind == ElementKind.METHOD || elementKind == ElementKind.FUNCTION);
  }

  @Override
  protected void init() {
    setText(RefactoringMessages.InlineLocalAction_label);
    PlatformUI.getWorkbench().getHelpSystem().setHelp(this, DartHelpContextIds.INLINE_ACTION);
  }

  boolean tryInline(AssistContext context, Shell shell) {
    try {
      InlineMethodRefactoring refactoring = RefactoringFactory.createInlineMethodRefactoring(context);
      InlineMethodRefactoring_I ltkRefactoring = new ServiceInlineMethodRefactoring(refactoring);
      new RefactoringStarter().activate(
          new InlineMethodWizard(ltkRefactoring),
          shell,
          RefactoringMessages.InlineMethodAction_dialog_title,
          RefactoringSaveHelper.SAVE_ALL);
      return true;
    } catch (Throwable e) {
      DartToolsPlugin.log(e);
      return false;
    }
  }
}
