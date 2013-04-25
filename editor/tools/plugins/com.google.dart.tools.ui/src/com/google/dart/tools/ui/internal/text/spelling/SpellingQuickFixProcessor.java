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
package com.google.dart.tools.ui.internal.text.spelling;

import com.google.dart.compiler.ErrorCode;
import com.google.dart.tools.core.buffer.Buffer;
import com.google.dart.tools.core.model.CompilationUnit;
import com.google.dart.tools.ui.internal.text.completion.DartCompletionProposal;
import com.google.dart.tools.ui.text.dart.IDartCompletionProposal;
import com.google.dart.tools.ui.text.dart.IInvocationContext;
import com.google.dart.tools.ui.text.dart.IProblemLocation;
import com.google.dart.tools.ui.text.dart.IQuickFixProcessor;
import com.google.dart.tools.ui.text.editor.tmp.JavaScriptCore;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Platform;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.Document;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.Region;
import org.eclipse.jface.text.contentassist.ICompletionProposal;
import org.eclipse.jface.text.contentassist.IContextInformation;
import org.eclipse.jface.text.quickassist.IQuickAssistInvocationContext;
import org.eclipse.jface.text.source.ISourceViewer;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Point;
import org.eclipse.ui.editors.text.EditorsUI;
import org.eclipse.ui.texteditor.spelling.ISpellingProblemCollector;
import org.eclipse.ui.texteditor.spelling.SpellingAnnotation;
import org.eclipse.ui.texteditor.spelling.SpellingContext;
import org.eclipse.ui.texteditor.spelling.SpellingProblem;

import java.util.ArrayList;
import java.util.List;

/**
 * Provides a Dart IQuickFixProcessor for SpellingAnnotations
 */
public class SpellingQuickFixProcessor implements IQuickFixProcessor {
  static class DocumentAdapter extends Document {

    private Buffer buffer;

    public DocumentAdapter(Buffer buffer) {
      super(buffer.getContents());
      this.buffer = buffer;
    }

    @Override
    public void replace(int offset, int length, String text) throws BadLocationException {
      super.replace(offset, length, text);
      this.buffer.replace(offset, length, text);
    }

    @Override
    public void set(String text) {
      super.set(text);
      this.buffer.setContents(text);
    }

  }

  static final class SpellingProblemCollector implements ISpellingProblemCollector {
    IQuickAssistInvocationContext fContext = null;

    private List<SpellingProposal> fProposals = new ArrayList<SpellingProposal>();

    SpellingProblemCollector(final IInvocationContext context) {
      fContext = new IQuickAssistInvocationContext() {
        @Override
        public int getLength() {
          return context.getSelectionLength();
        }

        @Override
        public int getOffset() {
          return context.getSelectionOffset();
        }

        @Override
        public ISourceViewer getSourceViewer() {
          return null;
        }
      };
    }

    @Override
    public void accept(SpellingProblem problem) {
      ICompletionProposal[] proposals = problem.getProposals(fContext);
      for (int i = 0; i < proposals.length; i++) {
        fProposals.add(new SpellingProposal(proposals[i]));
      }
    }

    @Override
    public void beginCollecting() {
      fProposals.clear();
    }

    @Override
    public void endCollecting() {
    }

    DartCompletionProposal[] getProposals() {
      return fProposals.toArray(new DartCompletionProposal[fProposals.size()]);
    }
  }

  private static class SpellingProposal implements IDartCompletionProposal {
    ICompletionProposal fProposal;

    SpellingProposal(ICompletionProposal spellingProposal) {
      super();
      fProposal = spellingProposal;
    }

    @Override
    public void apply(IDocument document) {
      fProposal.apply(document);
    }

    @Override
    public String getAdditionalProposalInfo() {
      return fProposal.getAdditionalProposalInfo();
    }

    @Override
    public IContextInformation getContextInformation() {
      return fProposal.getContextInformation();
    }

    @Override
    public String getDisplayString() {
      return fProposal.getDisplayString();
    }

    @Override
    public Image getImage() {
      return fProposal.getImage();
    }

    @Override
    public int getRelevance() {
      return 50;
    }

    @Override
    public Point getSelection(IDocument document) {
      return fProposal.getSelection(document);
    }
  }

  public SpellingQuickFixProcessor() {
  }

  @Override
  public DartCompletionProposal[] getCorrections(IInvocationContext context,
      IProblemLocation[] locations) throws CoreException {
    List<Region> regions = new ArrayList<Region>();
    for (int i = 0; i < locations.length; i++) {
      if (locations[i].getMarkerType() == SpellingAnnotation.TYPE) {
        regions.add(new Region(locations[i].getOffset(), locations[i].getLength()));
      }
    }
    SpellingProblemCollector collector = new SpellingProblemCollector(context);
    if (!regions.isEmpty()) {
      SpellingContext spellingContext = new SpellingContext();
      spellingContext.setContentType(Platform.getContentTypeManager().getContentType(
          JavaScriptCore.JAVA_SOURCE_CONTENT_TYPE));
      EditorsUI.getSpellingService().check(
          new DocumentAdapter(context.getOldCompilationUnit().getBuffer()),
          regions.toArray(new IRegion[regions.size()]),
          spellingContext,
          collector,
          new NullProgressMonitor());
    }
    return collector.getProposals();
  }

  @Override
  public boolean hasCorrections(CompilationUnit unit, ErrorCode problemId) {
    return false;
  }

}
