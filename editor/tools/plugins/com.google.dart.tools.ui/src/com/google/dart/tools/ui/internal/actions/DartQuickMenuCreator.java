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

import com.google.dart.tools.ui.internal.text.editor.DartEditor;
import com.google.dart.tools.ui.internal.text.functions.DartWordFinder;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.commands.IHandler;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.ITextSelection;
import org.eclipse.jface.text.ITextViewerExtension5;
import org.eclipse.jface.text.Region;
import org.eclipse.jface.text.source.ISourceViewer;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.graphics.Point;
import org.eclipse.ui.actions.QuickMenuCreator;

/**
 * Dart editor aware quick menu creator. In the given editor, the menu will be aligned with the word
 * at the current offset.
 */
public abstract class DartQuickMenuCreator extends QuickMenuCreator {

  private final DartEditor fEditor;

  /**
   * @param editor a {@link DartEditor}, or <code>null</code> if none
   */
  public DartQuickMenuCreator(DartEditor editor) {
    fEditor = editor;
  }

  @Override
  protected Point computeMenuLocation(StyledText text) {
    if (fEditor == null || text != fEditor.getViewer().getTextWidget())
      return super.computeMenuLocation(text);
    return computeWordStart();
  }

  private Point computeWordStart() {
    ITextSelection selection = (ITextSelection) fEditor.getSelectionProvider().getSelection();
    IRegion textRegion = DartWordFinder.findWord(
        fEditor.getViewer().getDocument(),
        selection.getOffset());
    if (textRegion == null)
      return null;

    IRegion widgetRegion = modelRange2WidgetRange(textRegion);
    if (widgetRegion == null)
      return null;

    int start = widgetRegion.getOffset();

    StyledText styledText = fEditor.getViewer().getTextWidget();
    Point result = styledText.getLocationAtOffset(start);
    result.y += styledText.getLineHeight(start);

    if (!styledText.getClientArea().contains(result))
      return null;
    return result;
  }

  private IRegion modelRange2WidgetRange(IRegion region) {
    ISourceViewer viewer = fEditor.getViewer();
    if (viewer instanceof ITextViewerExtension5) {
      ITextViewerExtension5 extension = (ITextViewerExtension5) viewer;
      return extension.modelRange2WidgetRange(region);
    }

    IRegion visibleRegion = viewer.getVisibleRegion();
    int start = region.getOffset() - visibleRegion.getOffset();
    int end = start + region.getLength();
    if (end > visibleRegion.getLength())
      end = visibleRegion.getLength();

    return new Region(start, end - start);
  }

  /**
   * Returns a handler that can create and open the quick menu.
   * 
   * @return a handler that can create and open the quick menu
   */
  public IHandler createHandler() {
    return new AbstractHandler() {
      public Object execute(ExecutionEvent event) throws ExecutionException {
        createMenu();
        return null;
      }
    };
  }

}
