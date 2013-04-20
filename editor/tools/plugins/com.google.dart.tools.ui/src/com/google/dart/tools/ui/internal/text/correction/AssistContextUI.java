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

package com.google.dart.tools.ui.internal.text.correction;

import com.google.dart.engine.services.assist.AssistContext;
import com.google.dart.tools.ui.internal.text.editor.DartEditor;

/**
 * Container with {@link AssistContext} and UI information.
 */
public class AssistContextUI {
  private final AssistContext context;
  private final DartEditor editor;

  public AssistContextUI(AssistContext context, DartEditor editor) {
    this.context = context;
    this.editor = editor;
  }

  public AssistContext getContext() {
    return context;
  }

  public DartEditor getEditor() {
    return editor;
  }
}
