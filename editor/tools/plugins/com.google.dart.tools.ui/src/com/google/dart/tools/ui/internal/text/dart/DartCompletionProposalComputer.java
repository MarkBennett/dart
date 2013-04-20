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
package com.google.dart.tools.ui.internal.text.dart;

import com.google.dart.tools.core.DartCoreDebug;
import com.google.dart.tools.core.completion.CompletionProposal;
import com.google.dart.tools.core.internal.completion.AnalysisUtil;
import com.google.dart.tools.core.model.CompilationUnit;
import com.google.dart.tools.core.model.DartModelException;
import com.google.dart.tools.ui.Messages;
import com.google.dart.tools.ui.PreferenceConstants;
import com.google.dart.tools.ui.internal.text.functions.DartHeuristicScanner;
import com.google.dart.tools.ui.internal.text.functions.Symbols;
import com.google.dart.tools.ui.text.dart.CompletionProposalCollector;
import com.google.dart.tools.ui.text.dart.ContentAssistInvocationContext;
import com.google.dart.tools.ui.text.dart.DartContentAssistInvocationContext;
import com.google.dart.tools.ui.text.dart.IDartCompletionProposalComputer;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.OperationCanceledException;
import org.eclipse.jface.dialogs.ErrorDialog;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.ITextViewer;
import org.eclipse.jface.text.contentassist.ICompletionProposal;
import org.eclipse.jface.text.contentassist.IContextInformation;
import org.eclipse.jface.text.contentassist.IContextInformationExtension;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.IWorkbenchCommandConstants;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.keys.IBindingService;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;

/**
 * Computes Java completion proposals and context infos.
 */
public class DartCompletionProposalComputer implements IDartCompletionProposalComputer {

  private static final class ContextInformationWrapper implements IContextInformation,
      IContextInformationExtension {

    private final IContextInformation fContextInformation;
    private int fPosition;

    public ContextInformationWrapper(IContextInformation contextInformation) {
      fContextInformation = contextInformation;
    }

    @Override
    public boolean equals(Object object) {
      if (object instanceof ContextInformationWrapper) {
        return fContextInformation.equals(((ContextInformationWrapper) object).fContextInformation);
      } else {
        return fContextInformation.equals(object);
      }
    }

    @Override
    public String getContextDisplayString() {
      return fContextInformation.getContextDisplayString();
    }

    @Override
    public int getContextInformationPosition() {
      return fPosition;
    }

    @Override
    public Image getImage() {
      return fContextInformation.getImage();
    }

    @Override
    public String getInformationDisplayString() {
      return fContextInformation.getInformationDisplayString();
    }

    @Override
    public int hashCode() {
      return fContextInformation.hashCode();
    }

    public void setContextInformationPosition(int position) {
      fPosition = position;
    }
  }

  private static final long JAVA_CODE_ASSIST_TIMEOUT = Long.getLong(
      "org.eclipse.jdt.ui.codeAssistTimeout", 5000).longValue(); // ms //$NON-NLS-1$

  private String fErrorMessage;

  private final IProgressMonitor fTimeoutProgressMonitor;

  public DartCompletionProposalComputer() {
    fTimeoutProgressMonitor = createTimeoutProgressMonitor(JAVA_CODE_ASSIST_TIMEOUT);
  }

  @Override
  public List<ICompletionProposal> computeCompletionProposals(
      ContentAssistInvocationContext context, IProgressMonitor monitor) {
    if (context instanceof DartContentAssistInvocationContext) {
      DartContentAssistInvocationContext dartContext = (DartContentAssistInvocationContext) context;
      if (DartCoreDebug.ENABLE_NEW_ANALYSIS) {
        return internalCreateCompletionProposals(context.getInvocationOffset(), dartContext);
      } else {
        return internalComputeCompletionProposals(context.getInvocationOffset(), dartContext);
      }
    }
    return Collections.emptyList();
  }

  @Override
  public List<IContextInformation> computeContextInformation(
      ContentAssistInvocationContext context, IProgressMonitor monitor) {
    if (context instanceof DartContentAssistInvocationContext) {
      DartContentAssistInvocationContext javaContext = (DartContentAssistInvocationContext) context;

      int contextInformationPosition = guessContextInformationPosition(javaContext);
      List<IContextInformation> result = addContextInformations(
          javaContext,
          contextInformationPosition);
      return result;
    }
    return Collections.emptyList();
  }

  @Override
  public String getErrorMessage() {
    return fErrorMessage;
  }

  @Override
  public void sessionEnded() {
    fErrorMessage = null;
  }

  @Override
  public void sessionStarted() {
  }

  /**
   * Creates the collector used to get proposals from core.
   * 
   * @param context the context
   * @return the collector
   */
  protected CompletionProposalCollector createCollector(DartContentAssistInvocationContext context) {
    if (PreferenceConstants.getPreferenceStore().getBoolean(
        PreferenceConstants.CODEASSIST_FILL_ARGUMENT_NAMES)) {
      return new FillArgumentNamesCompletionProposalCollector(context);
    } else {
      return new CompletionProposalCollector(context.getCompilationUnit(), true);
    }
  }

  protected int guessContextInformationPosition(ContentAssistInvocationContext context) {
    return context.getInvocationOffset();
  }

  protected final int guessMethodContextInformationPosition(ContentAssistInvocationContext context) {
    final int contextPosition = context.getInvocationOffset();

    IDocument document = context.getDocument();
    DartHeuristicScanner scanner = new DartHeuristicScanner(document);
    int bound = Math.max(-1, contextPosition - 200);

    // try the innermost scope of parentheses that looks like a method call
    int pos = contextPosition - 1;
    do {
      int paren = scanner.findOpeningPeer(pos, bound, '(', ')');
      if (paren == DartHeuristicScanner.NOT_FOUND) {
        break;
      }
      int token = scanner.previousToken(paren - 1, bound);
      // next token must be a method name (identifier) or the closing angle of a
      // constructor call of a parameterized type.
      if (token == Symbols.TokenIDENT || token == Symbols.TokenGREATERTHAN) {
        return paren + 1;
      }
      pos = paren - 1;
    } while (true);

    return contextPosition;
  }

  private List<IContextInformation> addContextInformations(
      DartContentAssistInvocationContext context, int offset) {
    List<ICompletionProposal> proposals = internalComputeCompletionProposals(offset, context);
    List<IContextInformation> result = new ArrayList<IContextInformation>(proposals.size());
    List<IContextInformation> anonymousResult = new ArrayList<IContextInformation>(proposals.size());

    for (Iterator<ICompletionProposal> it = proposals.iterator(); it.hasNext();) {
      ICompletionProposal proposal = it.next();
      IContextInformation contextInformation = proposal.getContextInformation();
      if (contextInformation != null) {
        ContextInformationWrapper wrapper = new ContextInformationWrapper(contextInformation);
        wrapper.setContextInformationPosition(offset);
        result.add(wrapper);
      }
    }

    if (result.size() == 0) {
      return anonymousResult;
    }
    return result;

  }

  /**
   * Returns a new progress monitor that get cancelled after the given timeout.
   * 
   * @param timeout the timeout in ms
   * @return the progress monitor
   */
  private IProgressMonitor createTimeoutProgressMonitor(final long timeout) {
    return new IProgressMonitor() {

      private long fEndTime;

      @Override
      public void beginTask(String name, int totalWork) {
        fEndTime = System.currentTimeMillis() + timeout;
      }

      @Override
      public void done() {
      }

      @Override
      public void internalWorked(double work) {
      }

      @Override
      public boolean isCanceled() {
        return fEndTime <= System.currentTimeMillis();
      }

      @Override
      public void setCanceled(boolean value) {
      }

      @Override
      public void setTaskName(String name) {
      }

      @Override
      public void subTask(String name) {
      }

      @Override
      public void worked(int work) {
      }
    };
  }

  /**
   * Returns the array with favorite static members.
   * 
   * @return the <code>String</code> array with with favorite static members
   */
  private String[] getFavoriteStaticMembers() {
    String serializedFavorites = PreferenceConstants.getPreferenceStore().getString(
        PreferenceConstants.CODEASSIST_FAVORITE_STATIC_MEMBERS);
    if (serializedFavorites != null && serializedFavorites.length() > 0) {
      return serializedFavorites.split(";"); //$NON-NLS-1$
    }
    return new String[0];
  }

  @SuppressWarnings("deprecation")
  private List<ICompletionProposal> internalComputeCompletionProposals(int offset,
      DartContentAssistInvocationContext context) {
    CompilationUnit unit = context.getCompilationUnit();
    if (unit == null) {
      return Collections.emptyList();
    }

    ITextViewer viewer = context.getViewer();

    CompletionProposalCollector collector = createCollector(context);
    collector.setInvocationContext(context);

    // Allow completions for unresolved types - since 3.3
    collector.setAllowsRequiredProposals(
        CompletionProposal.FIELD_REF,
        CompletionProposal.TYPE_REF,
        true);
    collector.setAllowsRequiredProposals(
        CompletionProposal.FIELD_REF,
        CompletionProposal.TYPE_IMPORT,
        true);
    collector.setAllowsRequiredProposals(
        CompletionProposal.FIELD_REF,
        CompletionProposal.FIELD_IMPORT,
        true);

    collector.setAllowsRequiredProposals(
        CompletionProposal.METHOD_REF,
        CompletionProposal.TYPE_REF,
        true);
    collector.setAllowsRequiredProposals(
        CompletionProposal.METHOD_REF,
        CompletionProposal.TYPE_IMPORT,
        true);
    collector.setAllowsRequiredProposals(
        CompletionProposal.METHOD_REF,
        CompletionProposal.METHOD_IMPORT,
        true);

    collector.setAllowsRequiredProposals(
        CompletionProposal.CONSTRUCTOR_INVOCATION,
        CompletionProposal.TYPE_REF,
        true);

    collector.setAllowsRequiredProposals(
        CompletionProposal.ANONYMOUS_CLASS_CONSTRUCTOR_INVOCATION,
        CompletionProposal.TYPE_REF,
        true);
    collector.setAllowsRequiredProposals(
        CompletionProposal.ANONYMOUS_CLASS_DECLARATION,
        CompletionProposal.TYPE_REF,
        true);

    collector.setAllowsRequiredProposals(
        CompletionProposal.TYPE_REF,
        CompletionProposal.TYPE_REF,
        true);

    collector.setAllowsRequiredProposals(
        CompletionProposal.TYPE_IMPORT,
        CompletionProposal.TYPE_IMPORT,
        true);

    // Set the favorite list to propose static members - since 3.3
    collector.setFavoriteReferences(getFavoriteStaticMembers());

    try {
      Point selection = viewer.getSelectedRange();
      if (selection.y > 0) {
        collector.setReplacementLength(selection.y);
      }
      unit.codeComplete(offset, collector, fTimeoutProgressMonitor);
    } catch (OperationCanceledException x) {
      IBindingService bindingSvc = (IBindingService) PlatformUI.getWorkbench().getAdapter(
          IBindingService.class);
      String keyBinding = bindingSvc.getBestActiveBindingFormattedFor(IWorkbenchCommandConstants.EDIT_CONTENT_ASSIST);
      fErrorMessage = Messages.format(
          DartTextMessages.CompletionProcessor_error_javaCompletion_took_too_long_message,
          keyBinding);
    } catch (DartModelException x) {
      Shell shell = viewer.getTextWidget().getShell();
      if (x.isDoesNotExist()) {
        MessageDialog.openInformation(
            shell,
            DartTextMessages.CompletionProcessor_error_notOnBuildPath_title,
            DartTextMessages.CompletionProcessor_error_notOnBuildPath_message);
      } else {
        ErrorDialog.openError(
            shell,
            DartTextMessages.CompletionProcessor_error_accessing_title,
            DartTextMessages.CompletionProcessor_error_accessing_message,
            x.getStatus());
      }
    }

    ICompletionProposal[] javaProposals = collector.getDartCompletionProposals();
    int contextInformationOffset = guessMethodContextInformationPosition(context);
    if (contextInformationOffset != offset) {
      for (int i = 0; i < javaProposals.length; i++) {
        if (javaProposals[i] instanceof DartMethodCompletionProposal) {
          DartMethodCompletionProposal jmcp = (DartMethodCompletionProposal) javaProposals[i];
          jmcp.setContextInformationPosition(contextInformationOffset);
        }
      }
    }

    List<ICompletionProposal> proposals = new ArrayList<ICompletionProposal>(
        Arrays.asList(javaProposals));
    if (proposals.size() == 0) {
      String error = collector.getErrorMessage();
      if (error.length() > 0) {
        fErrorMessage = error;
      }
    }
    return proposals;
  }

  // This method will replace internalComputeCompletionProposals()
  @SuppressWarnings("deprecation")
  private List<ICompletionProposal> internalCreateCompletionProposals(int offset,
      DartContentAssistInvocationContext context) {
    CompletionProposalCollector collector = createCollector(context);
    collector.setInvocationContext(context);

    collector.setAllowsRequiredProposals(
        CompletionProposal.FIELD_REF,
        CompletionProposal.TYPE_REF,
        true);
    collector.setAllowsRequiredProposals(
        CompletionProposal.FIELD_REF,
        CompletionProposal.TYPE_IMPORT,
        true);
    collector.setAllowsRequiredProposals(
        CompletionProposal.FIELD_REF,
        CompletionProposal.FIELD_IMPORT,
        true);

    collector.setAllowsRequiredProposals(
        CompletionProposal.METHOD_REF,
        CompletionProposal.TYPE_REF,
        true);
    collector.setAllowsRequiredProposals(
        CompletionProposal.METHOD_REF,
        CompletionProposal.TYPE_IMPORT,
        true);
    collector.setAllowsRequiredProposals(
        CompletionProposal.METHOD_REF,
        CompletionProposal.METHOD_IMPORT,
        true);

    collector.setAllowsRequiredProposals(
        CompletionProposal.CONSTRUCTOR_INVOCATION,
        CompletionProposal.TYPE_REF,
        true);

    collector.setAllowsRequiredProposals(
        CompletionProposal.ANONYMOUS_CLASS_CONSTRUCTOR_INVOCATION,
        CompletionProposal.TYPE_REF,
        true);
    collector.setAllowsRequiredProposals(
        CompletionProposal.ANONYMOUS_CLASS_DECLARATION,
        CompletionProposal.TYPE_REF,
        true);

    collector.setAllowsRequiredProposals(
        CompletionProposal.TYPE_REF,
        CompletionProposal.TYPE_REF,
        true);

    collector.setAllowsRequiredProposals(
        CompletionProposal.TYPE_IMPORT,
        CompletionProposal.TYPE_IMPORT,
        true);

    collector.setFavoriteReferences(getFavoriteStaticMembers());

    try {
      com.google.dart.engine.services.completion.CompletionEngine engine;
      com.google.dart.engine.services.completion.CompletionFactory factory;
      AnalysisUtil util = new AnalysisUtil();
      util.setRequestor(collector);
      factory = new com.google.dart.engine.services.completion.CompletionFactory();
      engine = new com.google.dart.engine.services.completion.CompletionEngine(util, factory);
      engine.complete(context.getAssistContext());
    } catch (OperationCanceledException x) {
      IBindingService bindingSvc = (IBindingService) PlatformUI.getWorkbench().getAdapter(
          IBindingService.class);
      String keyBinding = bindingSvc.getBestActiveBindingFormattedFor(IWorkbenchCommandConstants.EDIT_CONTENT_ASSIST);
      fErrorMessage = Messages.format(
          DartTextMessages.CompletionProcessor_error_javaCompletion_took_too_long_message,
          keyBinding);
    }

    ICompletionProposal[] javaProposals = collector.getDartCompletionProposals();
    int contextInformationOffset = guessMethodContextInformationPosition(context);
    if (contextInformationOffset != offset) {
      for (int i = 0; i < javaProposals.length; i++) {
        if (javaProposals[i] instanceof DartMethodCompletionProposal) {
          DartMethodCompletionProposal jmcp = (DartMethodCompletionProposal) javaProposals[i];
          jmcp.setContextInformationPosition(contextInformationOffset);
        }
      }
    }

    List<ICompletionProposal> proposals = new ArrayList<ICompletionProposal>(
        Arrays.asList(javaProposals));
    if (proposals.size() == 0) {
      String error = collector.getErrorMessage();
      if (error.length() > 0) {
        fErrorMessage = error;
      }
    }
    return proposals;
  }
}
