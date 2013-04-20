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
package com.google.dart.tools.ui.internal.text.editor;

import com.google.dart.tools.core.DartCore;
import com.google.dart.tools.ui.DartUI;
import com.google.dart.tools.ui.PreferenceConstants;
import com.google.dart.tools.ui.internal.text.comment.CommentFormattingContext;
import com.google.dart.tools.ui.internal.text.functions.SmartBackspaceManager;
import com.google.dart.tools.ui.text.DartPartitions;
import com.google.dart.tools.ui.text.DartSourceViewerConfiguration;
import com.google.dart.tools.ui.text.IDartColorConstants;

import org.eclipse.core.runtime.Assert;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.preference.PreferenceConverter;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.ITextPresentationListener;
import org.eclipse.jface.text.ITypedRegion;
import org.eclipse.jface.text.Region;
import org.eclipse.jface.text.TextUtilities;
import org.eclipse.jface.text.formatter.FormattingContextProperties;
import org.eclipse.jface.text.formatter.IFormattingContext;
import org.eclipse.jface.text.information.IInformationPresenter;
import org.eclipse.jface.text.reconciler.IReconciler;
import org.eclipse.jface.text.source.IOverviewRuler;
import org.eclipse.jface.text.source.IVerticalRuler;
import org.eclipse.jface.text.source.IVerticalRulerColumn;
import org.eclipse.jface.text.source.SourceViewerConfiguration;
import org.eclipse.jface.text.source.projection.ProjectionViewer;
import org.eclipse.jface.util.IPropertyChangeListener;
import org.eclipse.jface.util.PropertyChangeEvent;
import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.BidiSegmentEvent;
import org.eclipse.swt.custom.BidiSegmentListener;
import org.eclipse.swt.custom.StyleRange;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.texteditor.AbstractDecoratedTextEditorPreferenceConstants;
import org.eclipse.ui.texteditor.AbstractTextEditor;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DartSourceViewer extends ProjectionViewer implements IPropertyChangeListener {

  /**
   * Text operation code for requesting the outline for the current input.
   */
  public static final int SHOW_OUTLINE = 51;

  /**
   * Text operation code for requesting the outline for the element at the current position.
   */
  public static final int OPEN_STRUCTURE = 52;

  /**
   * Text operation code for requesting the hierarchy for the current input.
   */
  public static final int SHOW_HIERARCHY = 53;

  /**
   * Returns a segmentation of the line of the given document appropriate for BIDI rendering. The
   * default implementation returns only the string literals of a java code line as segments.
   * 
   * @param document the document
   * @param lineOffset the offset of the line
   * @return the line's BIDI segmentation
   * @throws BadLocationException in case lineOffset is not valid in document
   */
  protected static int[] getBidiLineSegments(IDocument document, int lineOffset)
      throws BadLocationException {

    if (document == null) {
      return null;
    }

    IRegion line = document.getLineInformationOfOffset(lineOffset);
    ITypedRegion[] linePartitioning = TextUtilities.computePartitioning(
        document,
        DartPartitions.DART_PARTITIONING,
        lineOffset,
        line.getLength(),
        false);

    List<ITypedRegion> segmentation = new ArrayList<ITypedRegion>();
    for (int i = 0; i < linePartitioning.length; i++) {
      if (DartPartitions.DART_STRING.equals(linePartitioning[i].getType())) {
        segmentation.add(linePartitioning[i]);
      }
    }

    if (segmentation.size() == 0) {
      return null;
    }

    int size = segmentation.size();
    int[] segments = new int[size * 2 + 1];

    int j = 0;
    for (int i = 0; i < size; i++) {
      ITypedRegion segment = segmentation.get(i);

      if (i == 0) {
        segments[j++] = 0;
      }

      int offset = segment.getOffset() - lineOffset;
      if (offset > segments[j - 1]) {
        segments[j++] = offset;
      }

      if (offset + segment.getLength() >= line.getLength()) {
        break;
      }

      segments[j++] = offset + segment.getLength();
    }

    if (j < segments.length) {
      int[] result = new int[j];
      System.arraycopy(segments, 0, result, 0, j);
      segments = result;
    }

    return segments;
  }

  private IInformationPresenter fOutlinePresenter;
  private IInformationPresenter fStructurePresenter;

  private IInformationPresenter fHierarchyPresenter;
  /**
   * This viewer's foreground color.
   */
  private Color fForegroundColor;
  /**
   * The viewer's background color.
   */
  private Color fBackgroundColor;
  /**
   * This viewer's selection foreground color.
   */
  private Color fSelectionForegroundColor;
  /**
   * The viewer's selection background color.
   */
  private Color fSelectionBackgroundColor;
  /**
   * The preference store.
   */
  private IPreferenceStore fPreferenceStore;
  /**
   * Is this source viewer configured?
   */
  private boolean fIsConfigured;

  /**
   * The backspace manager of this viewer.
   */
  private SmartBackspaceManager fBackspaceManager;

  /**
   * Whether to delay setting the visual document until the projection has been computed.
   * <p>
   * Added for performance optimization.
   * </p>
   * 
   * @see #prepareDelayedProjection()
   */
  private boolean fIsSetVisibleDocumentDelayed = false;
  private List<IVerticalRulerColumn> rulers = new ArrayList<IVerticalRulerColumn>();

  public DartSourceViewer(Composite parent, IVerticalRuler verticalRuler,
      IOverviewRuler overviewRuler, boolean showAnnotationsOverview, int styles,
      IPreferenceStore store) {
    super(parent, verticalRuler, overviewRuler, showAnnotationsOverview, styles);
    setPreferenceStore(store);
  }

  /**
   * Sets the viewer's background color to the given control's background color. The background
   * color is <em>only</em> set if it's visibly distinct from the default Dart source text color.
   * 
   * @param control the control with the default background color
   */
  public void adaptBackgroundColor(Control control) {
    Color defaultColor = control.getBackground();
    float[] defaultBgHSB = defaultColor.getRGB().getHSB();

    Color javaDefaultColor = DartUI.getColorManager().getColor(IDartColorConstants.JAVA_DEFAULT);
    RGB javaDefaultRGB = javaDefaultColor != null ? javaDefaultColor.getRGB() : new RGB(
        255,
        255,
        255);
    float[] javaDefaultHSB = javaDefaultRGB.getHSB();

    if (Math.abs(defaultBgHSB[2] - javaDefaultHSB[2]) >= 0.5f) {
      getTextWidget().setBackground(defaultColor);
      if (fBackgroundColor != null) {
        fBackgroundColor.dispose();
        fBackgroundColor = null;
      }
    }
  }

  @Override
  public void addVerticalRulerColumn(IVerticalRulerColumn column) {
    super.addVerticalRulerColumn(column);
    rulers.add(column);
    column.getControl().setBackground(getTextWidget().getBackground());
  }

  /*
   * @see ITextOperationTarget#canDoOperation(int)
   */
  @Override
  public boolean canDoOperation(int operation) {
    if (operation == SHOW_OUTLINE) {
      return fOutlinePresenter != null;
    }
    if (operation == OPEN_STRUCTURE) {
      return fStructurePresenter != null;
    }
    if (operation == SHOW_HIERARCHY) {
      return fHierarchyPresenter != null;
    }

    return super.canDoOperation(operation);
  }

  /*
   * @see ISourceViewer#configure(SourceViewerConfiguration)
   */
  @Override
  public void configure(SourceViewerConfiguration configuration) {
    /*
     * Prevent access to colors disposed in unconfigure(), see:
     * https://bugs.eclipse.org/bugs/show_bug.cgi?id=53641
     * https://bugs.eclipse.org/bugs/show_bug.cgi?id=86177
     */
    StyledText textWidget = getTextWidget();
    if (textWidget != null && !textWidget.isDisposed()) {
      Color foregroundColor = textWidget.getForeground();
      if (foregroundColor != null && foregroundColor.isDisposed()) {
        textWidget.setForeground(null);
      }
      Color backgroundColor = textWidget.getBackground();
      if (backgroundColor != null && backgroundColor.isDisposed()) {
        textWidget.setBackground(null);
      }
    }

    super.configure(configuration);
    if (configuration instanceof DartSourceViewerConfiguration) {
      DartSourceViewerConfiguration javaSVCconfiguration = (DartSourceViewerConfiguration) configuration;
      fOutlinePresenter = javaSVCconfiguration.getOutlinePresenter(this, false);
      if (fOutlinePresenter != null) {
        fOutlinePresenter.install(this);
      }

      fStructurePresenter = javaSVCconfiguration.getOutlinePresenter(this, true);
      if (fStructurePresenter != null) {
        fStructurePresenter.install(this);
      }

      fHierarchyPresenter = javaSVCconfiguration.getHierarchyPresenter(this, true);
      if (fHierarchyPresenter != null) {
        fHierarchyPresenter.install(this);
      }

    }

    if (fPreferenceStore != null) {
      fPreferenceStore.addPropertyChangeListener(this);
      initializeViewerColors();
    }

    fIsConfigured = true;
  }

  /*
   * @see org.eclipse.jface.text.source.SourceViewer#createFormattingContext()
   */
  @SuppressWarnings({"unchecked", "rawtypes"})
  @Override
  public IFormattingContext createFormattingContext() {
    // it's ok to use instance preferences here as subclasses replace
    // with project dependent versions (see
    // CompilationUnitEditor.AdaptedSourceViewer)
    IFormattingContext context = new CommentFormattingContext();
    Map map = new HashMap(DartCore.getOptions());
    context.setProperty(FormattingContextProperties.CONTEXT_PREFERENCES, map);

    return context;
  }

  /*
   * @see ITextOperationTarget#doOperation(int)
   */
  @Override
  public void doOperation(int operation) {
    if (getTextWidget() == null) {
      return;
    }

    switch (operation) {
      case SHOW_OUTLINE:
        if (fOutlinePresenter != null) {
          fOutlinePresenter.showInformation();
        }
        return;
      case OPEN_STRUCTURE:
        if (fStructurePresenter != null) {
          fStructurePresenter.showInformation();
        }
        return;
      case SHOW_HIERARCHY:
        if (fHierarchyPresenter != null) {
          fHierarchyPresenter.showInformation();
        }
        return;
    }

    super.doOperation(operation);
  }

  /**
   * Returns the backspace manager for this viewer.
   * 
   * @return the backspace manager for this viewer, or <code>null</code> if there is none
   */
  public SmartBackspaceManager getBackspaceManager() {
    return fBackspaceManager;
  }

  /**
   * Prepends the text presentation listener at the beginning of the viewer's list of text
   * presentation listeners. If the listener is already registered with the viewer this call moves
   * the listener to the beginning of the list.
   * 
   * @param listener the text presentation listener
   */
  @SuppressWarnings("unchecked")
  public void prependTextPresentationListener(ITextPresentationListener listener) {

    Assert.isNotNull(listener);

    if (fTextPresentationListeners == null) {
      fTextPresentationListeners = new ArrayList<ITextPresentationListener>();
    }

    fTextPresentationListeners.remove(listener);
    fTextPresentationListeners.add(0, listener);
  }

  /*
   * @see org.eclipse.jface.util.IPropertyChangeListener#propertyChange(org.eclipse
   * .jface.util.PropertyChangeEvent)
   */
  @Override
  public void propertyChange(PropertyChangeEvent event) {
    String property = event.getProperty();
    if (AbstractTextEditor.PREFERENCE_COLOR_FOREGROUND.equals(property)
        || AbstractTextEditor.PREFERENCE_COLOR_FOREGROUND_SYSTEM_DEFAULT.equals(property)
        || AbstractTextEditor.PREFERENCE_COLOR_BACKGROUND.equals(property)
        || AbstractTextEditor.PREFERENCE_COLOR_BACKGROUND_SYSTEM_DEFAULT.equals(property)
        || AbstractDecoratedTextEditorPreferenceConstants.EDITOR_SELECTION_FOREGROUND_COLOR.equals(property)
        || AbstractDecoratedTextEditorPreferenceConstants.EDITOR_SELECTION_FOREGROUND_DEFAULT_COLOR.equals(property)
        || AbstractDecoratedTextEditorPreferenceConstants.EDITOR_SELECTION_BACKGROUND_COLOR.equals(property)
        || AbstractDecoratedTextEditorPreferenceConstants.EDITOR_SELECTION_BACKGROUND_DEFAULT_COLOR.equals(property)) {
      initializeViewerColors();
    }
  }

  /*
   * @see org.eclipse.jface.text.source.SourceViewer#rememberSelection()
   */
  @Override
  public Point rememberSelection() {
    return super.rememberSelection();
  }

  @Override
  public void removeVerticalRulerColumn(IVerticalRulerColumn column) {
    super.removeVerticalRulerColumn(column);
    rulers.remove(column);
  }

  /*
   * @see org.eclipse.jface.text.ITextViewer#resetVisibleRegion()
   */
  @Override
  public void resetVisibleRegion() {
    super.resetVisibleRegion();
    // re-enable folding if ProjectionViewer failed to due so
    if (fPreferenceStore != null
        && fPreferenceStore.getBoolean(PreferenceConstants.EDITOR_FOLDING_ENABLED)
        && !isProjectionMode()) {
      enableProjection();
    }
  }

  /*
   * @see org.eclipse.jface.text.source.SourceViewer#restoreSelection()
   */
  @Override
  public void restoreSelection() {
    super.restoreSelection();
  }

  /**
   * Sets the preference store on this viewer.
   * 
   * @param store the preference store
   */
  public void setPreferenceStore(IPreferenceStore store) {
    if (fIsConfigured && fPreferenceStore != null) {
      fPreferenceStore.removePropertyChangeListener(this);
    }

    fPreferenceStore = store;

    if (fIsConfigured && fPreferenceStore != null) {
      fPreferenceStore.addPropertyChangeListener(this);
      initializeViewerColors();
    }
  }

  /*
   * @see org.eclipse.jface.text.source.ISourceViewerExtension2#unconfigure()
   */
  @Override
  public void unconfigure() {
    if (fOutlinePresenter != null) {
      fOutlinePresenter.uninstall();
      fOutlinePresenter = null;
    }
    if (fStructurePresenter != null) {
      fStructurePresenter.uninstall();
      fStructurePresenter = null;
    }
    if (fHierarchyPresenter != null) {
      fHierarchyPresenter.uninstall();
      fHierarchyPresenter = null;
    }
    if (fForegroundColor != null) {
      fForegroundColor.dispose();
      fForegroundColor = null;
    }
    if (fBackgroundColor != null) {
      fBackgroundColor.dispose();
      fBackgroundColor = null;
    }

    if (fPreferenceStore != null) {
      fPreferenceStore.removePropertyChangeListener(this);
    }

    super.unconfigure();

    fIsConfigured = false;
  }

  /*
   * @see org.eclipse.jface.text.source.SourceViewer#createControl(org.eclipse.swt
   * .widgets.Composite, int)
   */
  @Override
  protected void createControl(Composite parent, int styles) {

    // Use LEFT_TO_RIGHT unless otherwise specified.
    if ((styles & SWT.RIGHT_TO_LEFT) == 0 && (styles & SWT.LEFT_TO_RIGHT) == 0) {
      styles |= SWT.LEFT_TO_RIGHT;
    }

    super.createControl(parent, styles);

    fBackspaceManager = new SmartBackspaceManager();
    fBackspaceManager.install(this);

    StyledText text = getTextWidget();
    text.addBidiSegmentListener(new BidiSegmentListener() {
      @Override
      public void lineGetSegments(BidiSegmentEvent event) {
        if (redraws()) {
          event.segments = getBidiLineSegments(event.lineOffset, event.lineText);
        }
      }
    });
  }

  /**
   * Returns a segmentation of the given line appropriate for BIDI rendering. The default
   * implementation returns only the string literals of a java code line as segments.
   * 
   * @param widgetLineOffset the offset of the line
   * @param line the content of the line
   * @return the line's BIDI segmentation
   */
  protected int[] getBidiLineSegments(int widgetLineOffset, String line) {
    if (line != null && line.length() > 0) {
      int lineOffset = widgetOffset2ModelOffset(widgetLineOffset);
      try {
        return getBidiLineSegments(getDocument(), lineOffset);
      } catch (BadLocationException x) {
        return null; // don't segment line in this case
      }
    }
    return null;
  }

  /*
   * @see org.eclipse.jface.text.source.SourceViewer#handleDispose()
   */
  @Override
  protected void handleDispose() {
    if (fBackspaceManager != null) {
      fBackspaceManager.uninstall();
      fBackspaceManager = null;
    }

    super.handleDispose();
  }

  protected void initializeViewerColors() {
    if (fPreferenceStore != null) {

      StyledText styledText = getTextWidget();

      // ----------- foreground color --------------------
      Color color = fPreferenceStore.getBoolean(AbstractTextEditor.PREFERENCE_COLOR_FOREGROUND_SYSTEM_DEFAULT)
          ? null : createColor(
              fPreferenceStore,
              AbstractTextEditor.PREFERENCE_COLOR_FOREGROUND,
              styledText.getDisplay());
      styledText.setForeground(color);

      if (fForegroundColor != null) {
        fForegroundColor.dispose();
      }

      fForegroundColor = color;

      // ---------- background color ----------------------
      color = fPreferenceStore.getBoolean(AbstractTextEditor.PREFERENCE_COLOR_BACKGROUND_SYSTEM_DEFAULT)
          ? null : createColor(
              fPreferenceStore,
              AbstractTextEditor.PREFERENCE_COLOR_BACKGROUND,
              styledText.getDisplay());
      styledText.setBackground(color);
      for (IVerticalRulerColumn column : rulers) {
        if (!column.getControl().isDisposed()) {
          column.getControl().setBackground(color);
        }
      }

      if (fBackgroundColor != null) {
        fBackgroundColor.dispose();
      }

      fBackgroundColor = color;

      // ----------- selection foreground color --------------------
      color = fPreferenceStore.getBoolean(AbstractDecoratedTextEditorPreferenceConstants.EDITOR_SELECTION_FOREGROUND_DEFAULT_COLOR)
          ? null : createColor(
              fPreferenceStore,
              AbstractDecoratedTextEditorPreferenceConstants.EDITOR_SELECTION_FOREGROUND_COLOR,
              styledText.getDisplay());
      styledText.setSelectionForeground(color);

      if (fSelectionForegroundColor != null) {
        fSelectionForegroundColor.dispose();
      }

      fSelectionForegroundColor = color;

      // ---------- selection background color ----------------------
      color = fPreferenceStore.getBoolean(AbstractDecoratedTextEditorPreferenceConstants.EDITOR_SELECTION_BACKGROUND_DEFAULT_COLOR)
          ? null : createColor(
              fPreferenceStore,
              AbstractDecoratedTextEditorPreferenceConstants.EDITOR_SELECTION_BACKGROUND_COLOR,
              styledText.getDisplay());
      styledText.setSelectionBackground(color);

      if (fSelectionBackgroundColor != null) {
        fSelectionBackgroundColor.dispose();
      }

      fSelectionBackgroundColor = color;
    }
  }

  /**
   * {@inheritDoc}
   * <p>
   * Performance optimization: since we know at this place that none of the clients expects the
   * given range to be untouched we reuse the given range as return value.
   * </p>
   */
  @Override
  protected StyleRange modelStyleRange2WidgetStyleRange(StyleRange range) {
    IRegion region = modelRange2WidgetRange(new Region(range.start, range.length));
    if (region != null) {
      // don't clone the style range, but simply reuse it.
      range.start = region.getOffset();
      range.length = region.getLength();
      return range;
    }
    return null;
  }

  /**
   * {@inheritDoc}
   * <p>
   * This is a performance optimization to reduce the computation of the text presentation triggered
   * by {@link #setVisibleDocument(IDocument)}
   * </p>
   * 
   * @see #prepareDelayedProjection()
   */
  @Override
  protected void setVisibleDocument(IDocument document) {
    if (fIsSetVisibleDocumentDelayed) {
      fIsSetVisibleDocumentDelayed = false;
      IDocument previous = getVisibleDocument();
      enableProjection(); // will set the visible document if anything is folded
      IDocument current = getVisibleDocument();
      // if the visible document was not replaced, continue as usual
      if (current != null && current != previous) {
        return;
      }
    }

    super.setVisibleDocument(document);
  }

  /**
   * Returns the reconciler.
   * 
   * @return the reconciler or <code>null</code> if not set
   */
  IReconciler getReconciler() {
    return fReconciler;
  }

  /**
   * Delays setting the visual document until after the projection has been computed. This method
   * must only be called before the document is set on the viewer.
   * <p>
   * This is a performance optimization to reduce the computation of the text presentation triggered
   * by <code>setVisibleDocument(IDocument)</code>.
   * </p>
   * 
   * @see #setVisibleDocument(IDocument)
   */
  void prepareDelayedProjection() {
    Assert.isTrue(!fIsSetVisibleDocumentDelayed);
    fIsSetVisibleDocumentDelayed = true;
  }

  /**
   * Sets the given reconciler.
   * 
   * @param reconciler the reconciler
   */
  void setReconciler(IReconciler reconciler) {
    fReconciler = reconciler;
  }

  /**
   * Creates a color from the information stored in the given preference store. Returns
   * <code>null</code> if there is no such information available.
   * 
   * @param store the store to read from
   * @param key the key used for the lookup in the preference store
   * @param display the display used create the color
   * @return the created color according to the specification in the preference store
   */
  private Color createColor(IPreferenceStore store, String key, Display display) {

    RGB rgb = null;

    if (store.contains(key)) {

      if (store.isDefault(key)) {
        rgb = PreferenceConverter.getDefaultColor(store, key);
      } else {
        rgb = PreferenceConverter.getColor(store, key);
      }

      if (rgb != null) {
        return new Color(display, rgb);
      }
    }

    return null;
  }
}
