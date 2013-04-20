/*
 * Copyright (c) 2011, the Dart project authors.
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
package com.google.dart.tools.ui.internal.text.functions;

import com.google.dart.tools.ui.internal.text.dart.hover.SourceViewerInformationControl;
import com.google.dart.tools.ui.text.DartPartitions;

import org.eclipse.core.runtime.Assert;
import org.eclipse.jface.resource.JFaceResources;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.ITextViewerExtension;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Shell;

/**
 * Specialized source viewer information control used to display quick diff hovers.
 */
class ChangeHoverInformationControl extends SourceViewerInformationControl {

  /** The font name for the viewer font - the same as the java editor's. */
  private static final String SYMBOLIC_FONT_NAME = "com.google.dart.tools.ui.editors.textfont"; //$NON-NLS-1$

  /**
   * The maximum width of the control, set in <code>setSizeConstraints(int, int)</code>.
   */
  int fMaxWidth = Integer.MAX_VALUE;
  /**
   * The maximum height of the control, set in <code>setSizeConstraints(int, int)</code>.
   */
  int fMaxHeight = Integer.MAX_VALUE;

  /**
   * The partition type to be used as the starting partition type by the partition scanner.
   */
  private String fPartition;
  /** The horizontal scroll index. */
  private int fHorizontalScrollPixel;

  /**
   * Creates a new information control.
   * 
   * @param parent the shell that is the parent of this hover / control
   * @param shellStyle the additional styles for the shell
   * @param style the additional styles for the styled text widget
   * @param partition the initial partition type to be used for the underlying viewer
   * @param statusFieldText the text to be used in the optional status field or <code>null</code> if
   *          the status field should be hidden
   */
  public ChangeHoverInformationControl(Shell parent, int shellStyle, int style, String partition,
      String statusFieldText) {
    super(parent, shellStyle, style, statusFieldText);
    setViewerFont();
    setStartingPartitionType(partition);
  }

  /*
   * @see org.eclipse.jface.text.IInformationControl#computeSizeHint()
   */
  @Override
  public Point computeSizeHint() {
    Point size = super.computeSizeHint();
    size.x = Math.min(size.x, fMaxWidth);
    size.y = Math.min(size.y, fMaxHeight);
    return size;
  }

  /*
   * @see com.google.dart.tools.ui.functions.java.hover.SourceViewerInformationControl
   * #hasContents()
   */
  @Override
  public boolean hasContents() {
    return super.hasContents() && fMaxWidth > 0;
  }

  /**
   * Sets the horizontal scroll index in pixels.
   * 
   * @param scrollIndex the new horizontal scroll index
   */
  public void setHorizontalScrollPixel(int scrollIndex) {
    scrollIndex = Math.max(0, scrollIndex);
    fHorizontalScrollPixel = scrollIndex;
  }

  /*
   * @see org.eclipse.jface.text.IInformationControl#setInformation(java.lang.String)
   */
  @Override
  public void setInformation(String content) {
    super.setInformation(content);
    IDocument doc = getViewer().getDocument();
    if (doc == null) {
      return;
    }

    // ensure that we can scroll enough
    ensureScrollable();

    String start = null;
    if (DartPartitions.DART_DOC.equals(fPartition)) {
      start = "/**" + doc.getLegalLineDelimiters()[0]; //$NON-NLS-1$
    } else if (DartPartitions.DART_MULTI_LINE_COMMENT.equals(fPartition)) {
      start = "/*" + doc.getLegalLineDelimiters()[0]; //$NON-NLS-1$
    }
    if (start != null) {
      try {
        doc.replace(0, 0, start);
        int startLen = start.length();
        getViewer().setDocument(doc, startLen, doc.getLength() - startLen);
      } catch (BadLocationException e) {
        // impossible
        Assert.isTrue(false);
      }
    }

    getViewer().getTextWidget().setHorizontalPixel(fHorizontalScrollPixel);
  }

  /*
   * @see org.eclipse.jface.text.IInformationControl#setSizeConstraints(int, int)
   */
  @Override
  public void setSizeConstraints(int maxWidth, int maxHeight) {
    fMaxWidth = maxWidth;
    fMaxHeight = maxHeight;
  }

  /**
   * Sets the initial partition for the underlying source viewer.
   * 
   * @param partition the partition type
   */
  public void setStartingPartitionType(String partition) {
    if (partition == null) {
      fPartition = IDocument.DEFAULT_CONTENT_TYPE;
    } else {
      fPartition = partition;
    }
  }

  /**
   * Ensures that the control can be scrolled at least to <code>fHorizontalScrollPixel</code> and
   * adjusts <code>fMaxWidth</code> accordingly.
   */
  private void ensureScrollable() {
    IDocument doc = getViewer().getDocument();
    if (doc == null) {
      return;
    }

    StyledText widget = getViewer().getTextWidget();
    if (widget == null || widget.isDisposed()) {
      return;
    }

    int last = doc.getNumberOfLines() - 1;
    GC gc = new GC(widget);
    gc.setFont(widget.getFont());
    int maxWidth = 0;
    String content = new String();

    try {
      for (int i = 0; i <= last; i++) {
        IRegion line;
        line = doc.getLineInformation(i);
        content = doc.get(line.getOffset(), line.getLength());
        int width = gc.textExtent(content).x;
        if (width > maxWidth) {
          maxWidth = width;
        }
      }
    } catch (BadLocationException e) {
      return;
    } finally {
      gc.dispose();
    }

    // limit the size of the window to the maximum width minus scrolling,
    // but never more than the configured max size (viewport size).
    fMaxWidth = Math.max(0, Math.min(fMaxWidth, maxWidth - fHorizontalScrollPixel + 8));
  }

  /**
   * Sets the font for this viewer sustaining selection and scroll position.
   */
  private void setViewerFont() {
    Font font = JFaceResources.getFont(SYMBOLIC_FONT_NAME);

    if (getViewer().getDocument() != null) {

      Point selection = getViewer().getSelectedRange();
      int topIndex = getViewer().getTopIndex();

      StyledText styledText = getViewer().getTextWidget();
      Control parent = styledText;
      if (getViewer() instanceof ITextViewerExtension) {
        ITextViewerExtension extension = (ITextViewerExtension) getViewer();
        parent = extension.getControl();
      }

      parent.setRedraw(false);

      styledText.setFont(font);

      getViewer().setSelectedRange(selection.x, selection.y);
      getViewer().setTopIndex(topIndex);

      if (parent instanceof Composite) {
        Composite composite = (Composite) parent;
        composite.layout(true);
      }

      parent.setRedraw(true);

    } else {
      StyledText styledText = getViewer().getTextWidget();
      styledText.setFont(font);
    }
  }
}
