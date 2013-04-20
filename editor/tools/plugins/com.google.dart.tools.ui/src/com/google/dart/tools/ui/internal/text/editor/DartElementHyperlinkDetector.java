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
package com.google.dart.tools.ui.internal.text.editor;

import com.google.dart.compiler.ast.DartUnit;
import com.google.dart.engine.ast.ASTNode;
import com.google.dart.engine.ast.ClassDeclaration;
import com.google.dart.engine.ast.Directive;
import com.google.dart.engine.ast.visitor.ElementLocator;
import com.google.dart.engine.ast.visitor.NodeLocator;
import com.google.dart.engine.element.Element;
import com.google.dart.tools.core.DartCoreDebug;
import com.google.dart.tools.core.model.CompilationUnit;
import com.google.dart.tools.core.model.DartElement;
import com.google.dart.tools.core.utilities.ast.DartElementLocator;
import com.google.dart.tools.core.utilities.performance.PerformanceManager;
import com.google.dart.tools.ui.DartToolsPlugin;
import com.google.dart.tools.ui.actions.InstrumentedSelectionDispatchAction;
import com.google.dart.tools.ui.actions.OpenAction;
import com.google.dart.tools.ui.actions.OpenAction_OLD;

import org.eclipse.core.resources.IResource;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.ITextViewer;
import org.eclipse.jface.text.Region;
import org.eclipse.jface.text.hyperlink.AbstractHyperlinkDetector;
import org.eclipse.jface.text.hyperlink.IHyperlink;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.texteditor.ITextEditor;

/**
 * Dart element hyperlink detector.
 */
public class DartElementHyperlinkDetector extends AbstractHyperlinkDetector {
  /**
   * The id of the detect hyperlinks operation.
   */
  private static final String DETECT_LINKS_ID = DartToolsPlugin.PLUGIN_ID + ".hyperlinkDetection";

  @Override
  public final IHyperlink[] detectHyperlinks(ITextViewer textViewer, IRegion region,
      boolean canShowMultipleHyperlinks) {
    PerformanceManager.Timer timer = PerformanceManager.getInstance().start(DETECT_LINKS_ID);
    try {
      return internalDetectHyperlinks(textViewer, region, canShowMultipleHyperlinks);
    } finally {
      timer.end();
    }
  }

  private IHyperlink[] internalDetectHyperlinks(ITextViewer textViewer, IRegion region,
      boolean canShowMultipleHyperlinks) {
    DartEditor editor = (DartEditor) getAdapter(ITextEditor.class);
    if (region == null || !(editor instanceof DartEditor)) {
      return null;
    }

    IAction openAction = editor.getAction("OpenEditor"); //$NON-NLS-1$
    if (!(openAction instanceof InstrumentedSelectionDispatchAction)) {
      return null;
    }

    if (!DartCoreDebug.ENABLE_NEW_ANALYSIS) {
      return legacyInternalDetectHyperlinks(editor, region, canShowMultipleHyperlinks, openAction);
    }

    com.google.dart.engine.ast.CompilationUnit cu = editor.getInputUnit();

    int offset = region.getOffset();

    ASTNode node = new NodeLocator(offset, offset + region.getLength()).searchWithin(cu);
    if (node == null || node instanceof com.google.dart.engine.ast.CompilationUnit
        || node instanceof Directive || node instanceof ClassDeclaration) {
      return null;
    }

    Element element = ElementLocator.locate(node);

    if (element != null) {
      IRegion wordRegion = new Region(node.getOffset(), node.getLength());
      return new IHyperlink[] {new DartElementHyperlink(element, wordRegion, new OpenAction(editor))};
    }

    return null;

  }

  // To be removed when the analysis engine is live
  private IHyperlink[] legacyInternalDetectHyperlinks(ITextEditor textEditor, IRegion region,
      boolean canShowMultipleHyperlinks, IAction openAction) {
    int offset = region.getOffset();

    CompilationUnit input = (CompilationUnit) EditorUtility.getEditorInputDartElement(
        textEditor,
        false);
    if (input == null) {
      return null;
    }
    //
    // Search the AST for the word region to determine if it is a candidate for a link.
    //
    DartEditor dartEditor = (DartEditor) textEditor;
    DartUnit ast = dartEditor.getAST();
    if (ast != null) {
      final DartElementLocator locator = new DartElementLocator(input, offset, offset); //start, end);
      DartElement foundElement = locator.searchWithin(ast);
      if (foundElement != null) {

        // don't link to non-existent resources (dartbug.com/2308)
        if (foundElement instanceof CompilationUnit) {
          IResource resource = foundElement.getResource();
          if ((resource == null || !resource.exists()) && !foundElement.isInSdk()) {
            return null;
          }
        }

        IRegion wordRegion = locator.getWordRegion();
        final IRegion candidateRegion = locator.getCandidateRegion();
        if (candidateRegion != null && wordRegion != null) {
          return new IHyperlink[] {new DartElementHyperlink(
              foundElement,
              wordRegion,
              new OpenAction_OLD(dartEditor) {
                @Override
                protected void selectInEditor(IEditorPart part, DartElement element) {
                  EditorUtility.revealInEditor(
                      part,
                      candidateRegion.getOffset(),
                      candidateRegion.getLength());
                }
              })};
        }
        if (wordRegion != null) {
          return new IHyperlink[] {new DartElementHyperlink(
              foundElement,
              wordRegion,
              (OpenAction_OLD) openAction)};
        }
      }
    }
    return null;
  }
}
