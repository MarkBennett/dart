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

package com.google.dart.tools.ui.web.json;

import com.google.dart.tools.ui.web.utils.WebEditorReconcilingStrategy;

import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.TextAttribute;
import org.eclipse.jface.text.contentassist.ContentAssistant;
import org.eclipse.jface.text.contentassist.IContentAssistant;
import org.eclipse.jface.text.hyperlink.IHyperlinkDetector;
import org.eclipse.jface.text.hyperlink.URLHyperlinkDetector;
import org.eclipse.jface.text.presentation.IPresentationReconciler;
import org.eclipse.jface.text.presentation.PresentationReconciler;
import org.eclipse.jface.text.reconciler.IReconciler;
import org.eclipse.jface.text.reconciler.MonoReconciler;
import org.eclipse.jface.text.rules.DefaultDamagerRepairer;
import org.eclipse.jface.text.rules.ITokenScanner;
import org.eclipse.jface.text.rules.Token;
import org.eclipse.jface.text.source.ISourceViewer;
import org.eclipse.jface.text.source.SourceViewerConfiguration;

/**
 * The SourceViewerConfiguration for the json editor.
 */
public class JsonSourceViewerConfiguration extends SourceViewerConfiguration {
  private JsonEditor editor;
  private JsonScanner scanner;
  private JsonCommentScanner commentScanner;
  private JsonStringScanner stringScanner;
  private MonoReconciler reconciler;

  public JsonSourceViewerConfiguration(JsonEditor editor) {
    this.editor = editor;
  }

  @Override
  public String[] getConfiguredContentTypes(ISourceViewer sourceViewer) {
    return new String[] {
        IDocument.DEFAULT_CONTENT_TYPE, JsonPartitionScanner.JSON_COMMENT,
        JsonPartitionScanner.JSON_STRING};
  }

  @Override
  public IContentAssistant getContentAssistant(ISourceViewer sourceViewer) {
    if (editor.isManifestEditor()) {
      ContentAssistant assistant = new ContentAssistant();

      assistant.enableAutoInsert(true);
      assistant.setContentAssistProcessor(
          new JsonContentAssistProcessor(),
          JsonPartitionScanner.JSON_STRING);

      return assistant;
    } else {
      return super.getContentAssistant(sourceViewer);
    }
  }

  @Override
  public IHyperlinkDetector[] getHyperlinkDetectors(ISourceViewer sourceViewer) {
    if (sourceViewer == null) {
      return null;
    }

    return new IHyperlinkDetector[] {new URLHyperlinkDetector(), new JsonHyperlinkDetector(editor)};
  }

  @Override
  public String[] getIndentPrefixes(ISourceViewer sourceViewer, String contentType) {
    return new String[] {"  ", ""};
  }

  @Override
  public IPresentationReconciler getPresentationReconciler(ISourceViewer sourceViewer) {
    PresentationReconciler reconciler = new PresentationReconciler();

    DefaultDamagerRepairer dr = new DefaultDamagerRepairer(getScanner());
    reconciler.setDamager(dr, IDocument.DEFAULT_CONTENT_TYPE);
    reconciler.setRepairer(dr, IDocument.DEFAULT_CONTENT_TYPE);

    DefaultDamagerRepairer ndr = new DefaultDamagerRepairer(getCommentScanner());
    reconciler.setDamager(ndr, JsonPartitionScanner.JSON_COMMENT);
    reconciler.setRepairer(ndr, JsonPartitionScanner.JSON_COMMENT);

    ndr = new DefaultDamagerRepairer(getStringScanner());
    reconciler.setDamager(ndr, JsonPartitionScanner.JSON_STRING);
    reconciler.setRepairer(ndr, JsonPartitionScanner.JSON_STRING);

    return reconciler;
  }

  @Override
  public IReconciler getReconciler(ISourceViewer sourceViewer) {
    if (reconciler == null && sourceViewer != null) {
      reconciler = new MonoReconciler(new WebEditorReconcilingStrategy(editor), false);
      reconciler.setDelay(500);
    }

    return reconciler;
  }

  @Override
  public int getTabWidth(ISourceViewer sourceViewer) {
    return 2;
  }

  protected JsonScanner getScanner() {
    if (scanner == null) {
      scanner = new JsonScanner(editor);
      scanner.setDefaultReturnToken(new Token(new TextAttribute(null)));
    }
    return scanner;
  }

  private ITokenScanner getCommentScanner() {
    if (commentScanner == null) {
      commentScanner = new JsonCommentScanner();
    }

    return commentScanner;
  }

  private ITokenScanner getStringScanner() {
    if (stringScanner == null) {
      stringScanner = new JsonStringScanner(editor);
    }

    return stringScanner;
  }

}
