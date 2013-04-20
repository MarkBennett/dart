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

import com.google.dart.engine.services.assist.AssistContext;
import com.google.dart.tools.ui.instrumentation.UIInstrumentationBuilder;
import com.google.dart.tools.ui.internal.refactoring.RefactoringMessages;
import com.google.dart.tools.ui.internal.text.DartHelpContextIds;
import com.google.dart.tools.ui.internal.text.editor.DartEditor;
import com.google.dart.tools.ui.internal.text.editor.DartSelection;

import org.eclipse.jface.action.Action;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.swt.widgets.Event;
import org.eclipse.ui.PlatformUI;

/**
 * {@link Action} to inline local variable, method, function.
 */
public class InlineAction extends AbstractDartSelectionAction {
  private final InlineLocalAction inlineLocal;
  private final InlineMethodAction inlineMethod;

  public InlineAction(DartEditor editor) {
    super(editor);
    inlineLocal = new InlineLocalAction(editor);
    inlineMethod = new InlineMethodAction(editor);
  }

  @Override
  public void selectionChanged(SelectionChangedEvent event) {
    inlineLocal.selectionChanged(event);
    inlineMethod.selectionChanged(event);
    setEnabled(computeEnabledState());
  }

  @Override
  protected void doRun(DartSelection selection, Event event,
      UIInstrumentationBuilder instrumentation) {
    AssistContext context = getContextAfterBuild(selection);
    if (context == null) {
      return;
    }
    // try to inline
    if (inlineLocal.isEnabled() && inlineLocal.tryInline(context, getShell())) {
      return;
    }
    if (inlineMethod.isEnabled() && inlineMethod.tryInline(context, getShell())) {
      return;
    }
    // complain
    instrumentation.metric("Problem", "No valid selection, showing dialog");
    MessageDialog.openInformation(
        getShell(),
        RefactoringMessages.InlineAction_dialog_title,
        RefactoringMessages.InlineAction_select);
  }

  @Override
  protected void init() {
    setText(RefactoringMessages.InlineAction_Inline);
    PlatformUI.getWorkbench().getHelpSystem().setHelp(this, DartHelpContextIds.INLINE_ACTION);
  }

  private boolean computeEnabledState() {
    return inlineLocal.isEnabled() || inlineMethod.isEnabled();
  }
}
