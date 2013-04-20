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
package com.google.dart.tools.ui.internal.text.correction;

import com.google.dart.compiler.ast.DartUnit;
import com.google.dart.tools.core.model.CompilationUnit;
import com.google.dart.tools.core.model.DartElement;
import com.google.dart.tools.ui.DartPluginImages;
import com.google.dart.tools.ui.DartUI;
import com.google.dart.tools.ui.PreferenceConstants;
import com.google.dart.tools.ui.internal.text.editor.ASTProvider;
import com.google.dart.tools.ui.internal.viewsupport.ISelectionListenerWithAST;
import com.google.dart.tools.ui.internal.viewsupport.SelectionListenerWithASTManager;
import com.google.dart.tools.ui.text.dart.IInvocationContext;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.ITextSelection;
import org.eclipse.jface.text.ITextViewer;
import org.eclipse.jface.text.Position;
import org.eclipse.jface.text.source.Annotation;
import org.eclipse.jface.text.source.IAnnotationAccessExtension;
import org.eclipse.jface.text.source.IAnnotationModel;
import org.eclipse.jface.text.source.IAnnotationPresentation;
import org.eclipse.jface.text.source.ImageUtilities;
import org.eclipse.jface.util.IPropertyChangeListener;
import org.eclipse.jface.util.PropertyChangeEvent;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Canvas;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.editors.text.EditorsUI;
import org.eclipse.ui.texteditor.AnnotationPreference;
import org.eclipse.ui.texteditor.ITextEditor;

import java.util.ConcurrentModificationException;
import java.util.Iterator;

/**
 * @coverage dart.editor.ui.correction
 */
public class QuickAssistLightBulbUpdater_OLD {

  public static class AssistAnnotation extends Annotation implements IAnnotationPresentation {

    //XXX: To be fully correct this should be a non-static fields in QuickAssistLightBulbUpdater
    private static final int LAYER;

    static {
      Annotation annotation = new Annotation("org.eclipse.jdt.ui.warning", false, null); //$NON-NLS-1$
      AnnotationPreference preference = EditorsUI.getAnnotationPreferenceLookup().getAnnotationPreference(
          annotation);
      if (preference != null) {
        LAYER = preference.getPresentationLayer() - 1;
      } else {
        LAYER = IAnnotationAccessExtension.DEFAULT_LAYER;
      }

    }

    private Image fImage;

    public AssistAnnotation() {
    }

    @Override
    public int getLayer() {
      return LAYER;
    }

    @Override
    public void paint(GC gc, Canvas canvas, Rectangle r) {
      ImageUtilities.drawImage(getImage(), gc, canvas, r, SWT.CENTER, SWT.TOP);
    }

    private Image getImage() {
      if (fImage == null) {
        fImage = DartPluginImages.get(DartPluginImages.IMG_OBJS_QUICK_ASSIST);
      }
      return fImage;
    }

  }

  private final Annotation fAnnotation;
  private boolean fIsAnnotationShown;
  private final ITextEditor fEditor;
  private final ITextViewer fViewer;

  private ISelectionListenerWithAST fListener;
  private IPropertyChangeListener fPropertyChangeListener;

  public QuickAssistLightBulbUpdater_OLD(ITextEditor part, ITextViewer viewer) {
    fEditor = part;
    fViewer = viewer;
    fAnnotation = new AssistAnnotation();
    fIsAnnotationShown = false;
    fPropertyChangeListener = null;
  }

  public void install() {
    if (isSetInPreferences()) {
      installSelectionListener();
    }
    if (fPropertyChangeListener == null) {
      fPropertyChangeListener = new IPropertyChangeListener() {
        @Override
        public void propertyChange(PropertyChangeEvent event) {
          doPropertyChanged(event.getProperty());
        }
      };
      PreferenceConstants.getPreferenceStore().addPropertyChangeListener(fPropertyChangeListener);
    }
  }

  public boolean isSetInPreferences() {
    return PreferenceConstants.getPreferenceStore().getBoolean(
        PreferenceConstants.EDITOR_QUICKASSIST_LIGHTBULB);
  }

  public void uninstall() {
    uninstallSelectionListener();
    if (fPropertyChangeListener != null) {
      PreferenceConstants.getPreferenceStore().removePropertyChangeListener(fPropertyChangeListener);
      fPropertyChangeListener = null;
    }
  }

  protected void doPropertyChanged(String property) {
    if (property.equals(PreferenceConstants.EDITOR_QUICKASSIST_LIGHTBULB)) {
      if (isSetInPreferences()) {
        CompilationUnit cu = getCompilationUnit();
        if (cu != null) {
          installSelectionListener();
          Point point = fViewer.getSelectedRange();
          DartUnit astRoot = ASTProvider.getASTProvider().getAST(
              cu,
              ASTProvider.WAIT_ACTIVE_ONLY,
              null);
          if (astRoot != null) {
            doSelectionChanged(point.x, point.y, astRoot);
          }
        }
      } else {
        uninstallSelectionListener();
      }
    }
  }

  /*
   * Needs to be called synchronized
   */
  private void calculateLightBulb(IAnnotationModel model, IInvocationContext context) {
    boolean needsAnnotation = DartCorrectionProcessor_OLD.hasAssists(context);
    if (fIsAnnotationShown) {
      model.removeAnnotation(fAnnotation);
    }
    if (needsAnnotation) {
      model.addAnnotation(
          fAnnotation,
          new Position(context.getSelectionOffset(), context.getSelectionLength()));
    }
    fIsAnnotationShown = needsAnnotation;
  }

  private void doSelectionChanged(int offset, int length, DartUnit astRoot) {

    final IAnnotationModel model = getAnnotationModel();
    final CompilationUnit cu = getCompilationUnit();
    if (model == null || cu == null) {
      return;
    }

    final AssistContext context = new AssistContext(cu, offset, length);
    context.setASTRoot(astRoot);

    boolean hasQuickFix = hasQuickFixLightBulb(model, context.getSelectionOffset());
    if (hasQuickFix) {
      removeLightBulb(model);
      return; // there is already a quick fix light bulb at the new location
    }

    calculateLightBulb(model, context);
  }

  private IAnnotationModel getAnnotationModel() {
    return DartUI.getDocumentProvider().getAnnotationModel(fEditor.getEditorInput());
  }

  private CompilationUnit getCompilationUnit() {
    DartElement elem = DartUI.getEditorInputDartElement(fEditor.getEditorInput());
    if (elem instanceof CompilationUnit) {
      return (CompilationUnit) elem;
    }
    return null;
  }

  private IDocument getDocument() {
    return DartUI.getDocumentProvider().getDocument(fEditor.getEditorInput());
  }

  /**
   * Tests if there is already a quick fix light bulb on the current line
   */
  private boolean hasQuickFixLightBulb(IAnnotationModel model, int offset) {
    try {
      IDocument document = getDocument();
      if (document == null) {
        return false;
      }

      // we access a document and annotation model from within a job
      // since these are only read accesses, we won't hurt anyone else if
      // this goes boink

      // may throw an IndexOutOfBoundsException upon concurrent document modification
      int currLine = document.getLineOfOffset(offset);

      // this iterator is not protected, it may throw ConcurrentModificationExceptions
      @SuppressWarnings("unchecked")
      Iterator<Annotation> iter = model.getAnnotationIterator();
      while (iter.hasNext()) {
        Annotation annot = iter.next();
        if (DartCorrectionProcessor_OLD.isQuickFixableType(annot)) {
          // may throw an IndexOutOfBoundsException upon concurrent annotation model changes
          Position pos = model.getPosition(annot);
          if (pos != null) {
            // may throw an IndexOutOfBoundsException upon concurrent document modification
            int startLine = document.getLineOfOffset(pos.getOffset());
            if (startLine == currLine && DartCorrectionProcessor_OLD.hasCorrections(annot)) {
              return true;
            }
          }
        }
      }
    } catch (BadLocationException e) {
      // ignore
    } catch (IndexOutOfBoundsException e) {
      // concurrent modification - too bad, ignore
    } catch (ConcurrentModificationException e) {
      // concurrent modification - too bad, ignore
    }
    return false;
  }

  private void installSelectionListener() {
    fListener = new ISelectionListenerWithAST() {
      @Override
      public void selectionChanged(IEditorPart part, ITextSelection selection, DartUnit astRoot) {
        doSelectionChanged(selection.getOffset(), selection.getLength(), astRoot);
      }
    };
    SelectionListenerWithASTManager.getDefault().addListener(fEditor, fListener);
  }

  private void removeLightBulb(IAnnotationModel model) {
    synchronized (this) {
      if (fIsAnnotationShown) {
        model.removeAnnotation(fAnnotation);
        fIsAnnotationShown = false;
      }
    }
  }

  private void uninstallSelectionListener() {
    if (fListener != null) {
      SelectionListenerWithASTManager.getDefault().removeListener(fEditor, fListener);
      fListener = null;
    }
    IAnnotationModel model = getAnnotationModel();
    if (model != null) {
      removeLightBulb(model);
    }
  }

}
