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

import com.google.common.collect.Lists;
import com.google.dart.compiler.ErrorCode;
import com.google.dart.tools.core.DartCoreDebug;
import com.google.dart.tools.core.model.CompilationUnit;
import com.google.dart.tools.internal.corext.refactoring.util.Messages;
import com.google.dart.tools.ui.DartToolsPlugin;
import com.google.dart.tools.ui.DartUI;
import com.google.dart.tools.ui.internal.text.correction.proposals.ChangeCorrectionProposal;
import com.google.dart.tools.ui.internal.text.correction.proposals.MarkerResolutionProposal;
import com.google.dart.tools.ui.internal.text.editor.DartEditor;
import com.google.dart.tools.ui.internal.text.editor.IJavaAnnotation;
import com.google.dart.tools.ui.text.dart.CompletionProposalComparator;
import com.google.dart.tools.ui.text.dart.IDartCompletionProposal;
import com.google.dart.tools.ui.text.dart.IInvocationContext;
import com.google.dart.tools.ui.text.dart.IProblemLocation;
import com.google.dart.tools.ui.text.dart.IQuickAssistProcessor;
import com.google.dart.tools.ui.text.dart.IQuickFixProcessor;

import org.eclipse.core.resources.IMarker;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.ISafeRunnable;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.MultiStatus;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.SafeRunner;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.text.Position;
import org.eclipse.jface.text.contentassist.ContentAssistEvent;
import org.eclipse.jface.text.contentassist.ICompletionListener;
import org.eclipse.jface.text.contentassist.ICompletionProposal;
import org.eclipse.jface.text.quickassist.IQuickAssistInvocationContext;
import org.eclipse.jface.text.source.Annotation;
import org.eclipse.jface.text.source.IAnnotationModel;
import org.eclipse.jface.text.source.ISourceViewer;
import org.eclipse.ltk.core.refactoring.NullChange;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IMarkerHelpRegistry;
import org.eclipse.ui.IMarkerResolution;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.ide.IDE;
import org.eclipse.ui.keys.IBindingService;
import org.eclipse.ui.texteditor.ITextEditorActionDefinitionIds;
import org.eclipse.ui.texteditor.SimpleMarkerAnnotation;

import java.util.Arrays;
import java.util.Collection;
import java.util.List;

/**
 * @coverage dart.editor.ui.correction
 */
public class DartCorrectionProcessor_OLD implements
    org.eclipse.jface.text.quickassist.IQuickAssistProcessor {

//  private void f() {}
//  private int fff;

  private static class SafeAssistCollector extends SafeCorrectionProcessorAccess {
    private final IInvocationContext fContext;
    private final IProblemLocation[] fLocations;
    private final Collection<IDartCompletionProposal> fProposals;

    public SafeAssistCollector(IInvocationContext context, IProblemLocation[] locations,
        Collection<IDartCompletionProposal> proposals) {
      fContext = context;
      fLocations = locations;
      fProposals = proposals;
    }

    @Override
    public void safeRun(ContributedProcessorDescriptor desc) throws Exception {
      IQuickAssistProcessor curr = (IQuickAssistProcessor) desc.getProcessor(
          fContext.getOldCompilationUnit(),
          IQuickAssistProcessor.class);
      if (curr != null) {
        IDartCompletionProposal[] res = curr.getAssists(fContext, fLocations);
        if (res != null) {
          for (int k = 0; k < res.length; k++) {
            fProposals.add(res[k]);
          }
        }
      }
    }
  }
  private static class SafeCorrectionCollector extends SafeCorrectionProcessorAccess {
    private final IInvocationContext fContext;
    private final Collection<IDartCompletionProposal> fProposals;
    private IProblemLocation[] fLocations;

    public SafeCorrectionCollector(IInvocationContext context,
        Collection<IDartCompletionProposal> proposals) {
      fContext = context;
      fProposals = proposals;
    }

    @Override
    public void safeRun(ContributedProcessorDescriptor desc) throws Exception {
      IQuickFixProcessor curr = (IQuickFixProcessor) desc.getProcessor(
          fContext.getOldCompilationUnit(),
          IQuickFixProcessor.class);
      if (curr != null) {
        IDartCompletionProposal[] res = curr.getCorrections(fContext, fLocations);
        if (res != null) {
          for (int k = 0; k < res.length; k++) {
            fProposals.add(res[k]);
          }
        }
      }
    }

    public void setProblemLocations(IProblemLocation[] locations) {
      fLocations = locations;
    }
  }

  private static abstract class SafeCorrectionProcessorAccess implements ISafeRunnable {
    private MultiStatus fMulti = null;
    private ContributedProcessorDescriptor fDescriptor;

    public IStatus getStatus() {
      if (fMulti == null) {
        return Status.OK_STATUS;
      }
      return fMulti;
    }

    @Override
    public void handleException(Throwable exception) {
      if (fMulti == null) {
        fMulti = new MultiStatus(
            DartUI.ID_PLUGIN,
            IStatus.OK,
            CorrectionMessages.JavaCorrectionProcessor_error_status,
            null);
      }
      fMulti.merge(new Status(
          IStatus.ERROR,
          DartUI.ID_PLUGIN,
          IStatus.ERROR,
          CorrectionMessages.JavaCorrectionProcessor_error_status,
          exception));
    }

    public void process(ContributedProcessorDescriptor desc) {
      fDescriptor = desc;
      SafeRunner.run(this);
    }

    public void process(List<ContributedProcessorDescriptor> desc) {
      for (ContributedProcessorDescriptor descriptor : desc) {
        fDescriptor = descriptor;
        SafeRunner.run(this);
      }
    }

    @Override
    public void run() throws Exception {
      safeRun(fDescriptor);
    }

    protected abstract void safeRun(ContributedProcessorDescriptor processor) throws Exception;

  }

  private static class SafeHasAssist extends SafeCorrectionProcessorAccess {
    private final IInvocationContext fContext;
    private boolean fHasAssists;

    public SafeHasAssist(IInvocationContext context) {
      fContext = context;
      fHasAssists = false;
    }

    public boolean hasAssists() {
      return fHasAssists;
    }

    @Override
    public void safeRun(ContributedProcessorDescriptor desc) throws Exception {
      IQuickAssistProcessor processor = (IQuickAssistProcessor) desc.getProcessor(
          fContext.getOldCompilationUnit(),
          IQuickAssistProcessor.class);
      if (processor != null && processor.hasAssists(fContext)) {
        fHasAssists = true;
      }
    }
  }

  private static class SafeHasCorrections extends SafeCorrectionProcessorAccess {
    private final CompilationUnit fCu;
    private final ErrorCode fProblemId;
    private boolean fHasCorrections;

    public SafeHasCorrections(CompilationUnit cu, ErrorCode problemId) {
      fCu = cu;
      fProblemId = problemId;
      fHasCorrections = false;
    }

    public boolean hasCorrections() {
      return fHasCorrections;
    }

    @Override
    public void safeRun(ContributedProcessorDescriptor desc) throws Exception {
      IQuickFixProcessor processor = (IQuickFixProcessor) desc.getProcessor(
          fCu,
          IQuickFixProcessor.class);
      if (processor != null && processor.hasCorrections(fCu, fProblemId)) {
        fHasCorrections = true;
      }
    }
  }

  private static final String QUICKFIX_PROCESSOR_CONTRIBUTION_ID = "quickFixProcessors"; //$NON-NLS-1$

  private static final String QUICKASSIST_PROCESSOR_CONTRIBUTION_ID = "quickAssistProcessors"; //$NON-NLS-1$

  private static List<ContributedProcessorDescriptor> fgContributedAssistProcessors = null;

  private static List<ContributedProcessorDescriptor> fgContributedCorrectionProcessors = null;

  public static IStatus collectAssists(IInvocationContext context, IProblemLocation[] locations,
      Collection<IDartCompletionProposal> proposals) {
    List<ContributedProcessorDescriptor> processors = getAssistProcessors();
    SafeAssistCollector collector = new SafeAssistCollector(context, locations, proposals);
    collector.process(processors);

    return collector.getStatus();
  }

  public static IStatus collectCorrections(IInvocationContext context,
      IProblemLocation[] locations, Collection<IDartCompletionProposal> proposals) {
    List<ContributedProcessorDescriptor> processors = getCorrectionProcessors();
    SafeCorrectionCollector collector = new SafeCorrectionCollector(context, proposals);
    for (ContributedProcessorDescriptor curr : processors) {
      IProblemLocation[] handled = getHandledProblems(locations, curr);
      if (handled != null) {
        collector.setProblemLocations(handled);
        collector.process(curr);
      }
    }
    return collector.getStatus();
  }

  public static IStatus collectProposals(IInvocationContext context, IAnnotationModel model,
      Annotation[] annotations, boolean addQuickFixes, boolean addQuickAssists,
      Collection<IDartCompletionProposal> proposals) {
    List<ProblemLocation_OLD> problems = Lists.newArrayList();

    // collect problem locations and corrections from marker annotations
    for (int i = 0; i < annotations.length; i++) {
      Annotation curr = annotations[i];
      ProblemLocation_OLD problemLocation = null;
      if (curr instanceof IJavaAnnotation) {
        problemLocation = getProblemLocation((IJavaAnnotation) curr, model);
        if (problemLocation != null) {
          problems.add(problemLocation);
        }
      }
      if (problemLocation == null && addQuickFixes && curr instanceof SimpleMarkerAnnotation) {
        collectMarkerProposals((SimpleMarkerAnnotation) curr, proposals);
      }
    }
    MultiStatus resStatus = null;

    IProblemLocation[] problemLocations = problems.toArray(new IProblemLocation[problems.size()]);
    if (addQuickFixes) {
      IStatus status = collectCorrections(context, problemLocations, proposals);
      if (!status.isOK()) {
        resStatus = new MultiStatus(
            DartUI.ID_PLUGIN,
            IStatus.ERROR,
            CorrectionMessages.JavaCorrectionProcessor_error_quickfix_message,
            null);
        resStatus.add(status);
      }
    }

    if (addQuickAssists) {
      IStatus status = collectAssists(context, problemLocations, proposals);
      if (!status.isOK()) {
        if (resStatus == null) {
          resStatus = new MultiStatus(
              DartUI.ID_PLUGIN,
              IStatus.ERROR,
              CorrectionMessages.JavaCorrectionProcessor_error_quickassist_message,
              null);
        }
        resStatus.add(status);
      }
    }
    if (resStatus != null) {
      return resStatus;
    }
    return Status.OK_STATUS;
  }

  public static boolean hasAssists(IInvocationContext context) {
    List<ContributedProcessorDescriptor> processors = getAssistProcessors();
    SafeHasAssist collector = new SafeHasAssist(context);

    for (ContributedProcessorDescriptor processor : processors) {
      collector.process(processor);
      if (collector.hasAssists()) {
        return true;
      }
    }
    return false;
  }

  public static boolean hasCorrections(Annotation annotation) {

    //TODO (pquitslund): add new world support for corrections
    if (DartCoreDebug.ENABLE_NEW_ANALYSIS) {
      return false;
    }

    if (annotation instanceof IJavaAnnotation) {
      IJavaAnnotation dartAnnotation = (IJavaAnnotation) annotation;
      ErrorCode problemId = dartAnnotation.getId();
      if (problemId != null) {
        CompilationUnit cu = dartAnnotation.getCompilationUnit();
        if (cu != null) {
          return hasCorrections(cu, problemId, dartAnnotation.getMarkerType());
        }
      }
    }
    if (annotation instanceof SimpleMarkerAnnotation) {
      return hasCorrections(((SimpleMarkerAnnotation) annotation).getMarker());
    }
    return false;
  }

  public static boolean hasCorrections(CompilationUnit cu, ErrorCode problemId, String markerType) {
    List<ContributedProcessorDescriptor> processors = getCorrectionProcessors();
    SafeHasCorrections collector = new SafeHasCorrections(cu, problemId);
    for (ContributedProcessorDescriptor processorDescriptor : processors) {
      if (processorDescriptor.canHandleMarkerType(markerType)) {
        collector.process(processorDescriptor);
        if (collector.hasCorrections()) {
          return true;
        }
      }
    }
    return false;
  }

  public static boolean isQuickFixableType(Annotation annotation) {
    return (annotation instanceof IJavaAnnotation || annotation instanceof SimpleMarkerAnnotation)
        && !annotation.isMarkedDeleted();
  }

  private static void collectMarkerProposals(SimpleMarkerAnnotation annotation,
      Collection<IDartCompletionProposal> proposals) {
    IMarker marker = annotation.getMarker();
    IMarkerResolution[] res = IDE.getMarkerHelpRegistry().getResolutions(marker);
    if (res.length > 0) {
      for (int i = 0; i < res.length; i++) {
        proposals.add(new MarkerResolutionProposal(res[i], marker));
      }
    }
  }

  private static List<ContributedProcessorDescriptor> getAssistProcessors() {
    if (fgContributedAssistProcessors == null) {
      fgContributedAssistProcessors = getProcessorDescriptors(
          QUICKASSIST_PROCESSOR_CONTRIBUTION_ID,
          false);
    }
    return fgContributedAssistProcessors;
  }

  private static List<ContributedProcessorDescriptor> getCorrectionProcessors() {
    if (fgContributedCorrectionProcessors == null) {
      fgContributedCorrectionProcessors = getProcessorDescriptors(
          QUICKFIX_PROCESSOR_CONTRIBUTION_ID,
          true);
    }
    return fgContributedCorrectionProcessors;
  }

  private static IProblemLocation[] getHandledProblems(IProblemLocation[] locations,
      ContributedProcessorDescriptor processor) {
    // implementation tries to avoid creating a new array
    boolean allHandled = true;
    List<IProblemLocation> res = null;
    for (int i = 0; i < locations.length; i++) {
      IProblemLocation curr = locations[i];
      if (processor.canHandleMarkerType(curr.getMarkerType())) {
        if (!allHandled) { // first handled problem
          if (res == null) {
            res = Lists.newArrayListWithCapacity(locations.length - i);
          }
          res.add(curr);
        }
      } else if (allHandled) {
        if (i > 0) { // first non handled problem
          res = Lists.newArrayListWithCapacity(locations.length - i);
          for (int k = 0; k < i; k++) {
            res.add(locations[k]);
          }
        }
        allHandled = false;
      }
    }
    if (allHandled) {
      return locations;
    }
    if (res == null) {
      return null;
    }
    return res.toArray(new IProblemLocation[res.size()]);
  }

  private static ProblemLocation_OLD getProblemLocation(IJavaAnnotation dartAnnotation,
      IAnnotationModel model) {
    ErrorCode problemId = dartAnnotation.getId();
    if (problemId != null) {
      Position pos = model.getPosition((Annotation) dartAnnotation);
      if (pos != null) {
        // Dart problems all handled by the quick assist processors
        return new ProblemLocation_OLD(pos.getOffset(), pos.getLength(), dartAnnotation);
      }
    }
    return null;
  }

  private static List<ContributedProcessorDescriptor> getProcessorDescriptors(
      String contributionId, boolean testMarkerTypes) {
    IConfigurationElement[] elements = Platform.getExtensionRegistry().getConfigurationElementsFor(
        DartUI.ID_PLUGIN,
        contributionId);
    List<ContributedProcessorDescriptor> res = Lists.newArrayList();

    for (IConfigurationElement element : elements) {
      ContributedProcessorDescriptor desc = new ContributedProcessorDescriptor(
          element,
          testMarkerTypes);
      IStatus status = desc.checkSyntax();
      if (status.isOK()) {
        res.add(desc);
      } else {
        DartToolsPlugin.log(status);
      }
    }
    return res;
  }

  private static boolean hasCorrections(IMarker marker) {
    if (marker == null || !marker.exists()) {
      return false;
    }

    IMarkerHelpRegistry registry = IDE.getMarkerHelpRegistry();
    return registry != null && registry.hasResolutions(marker);
  }

  private DartCorrectionAssistant_OLD fAssistant;

  private String fErrorMessage;

  public DartCorrectionProcessor_OLD(DartCorrectionAssistant_OLD assistant) {
    fAssistant = assistant;
    fAssistant.addCompletionListener(new ICompletionListener() {

      @Override
      public void assistSessionEnded(ContentAssistEvent event) {
        fAssistant.setStatusLineVisible(false);
      }

      @Override
      public void assistSessionStarted(ContentAssistEvent event) {
        fAssistant.setStatusLineVisible(true);
        fAssistant.setStatusMessage(getJumpHintStatusLineMessage());
      }

      @Override
      public void selectionChanged(ICompletionProposal proposal, boolean smartToggle) {
        // TODO(scheglov) restore this later
//        if (proposal instanceof IStatusLineProposal) {
//          IStatusLineProposal statusLineProposal = (IStatusLineProposal) proposal;
//          String message = statusLineProposal.getStatusMessage();
//          if (message != null) {
//            fAssistant.setStatusMessage(message);
//            return;
//          }
//        }
        fAssistant.setStatusMessage(getJumpHintStatusLineMessage());
      }

      private String getJumpHintStatusLineMessage() {
        if (fAssistant.isUpdatedOffset()) {
          String key = getQuickAssistBinding();
          if (key == null) {
            return CorrectionMessages.JavaCorrectionProcessor_go_to_original_using_menu;
          } else {
            return Messages.format(
                CorrectionMessages.JavaCorrectionProcessor_go_to_original_using_key,
                key);
          }
        } else if (fAssistant.isProblemLocationAvailable()) {
          String key = getQuickAssistBinding();
          if (key == null) {
            return CorrectionMessages.JavaCorrectionProcessor_go_to_closest_using_menu;
          } else {
            return Messages.format(
                CorrectionMessages.JavaCorrectionProcessor_go_to_closest_using_key,
                key);
          }
        } else {
          return ""; //$NON-NLS-1$
        }
      }

      private String getQuickAssistBinding() {
        final IBindingService bindingSvc = (IBindingService) PlatformUI.getWorkbench().getAdapter(
            IBindingService.class);
        return bindingSvc.getBestActiveBindingFormattedFor(ITextEditorActionDefinitionIds.QUICK_ASSIST);
      }
    });
  }

  @Override
  public boolean canAssist(IQuickAssistInvocationContext invocationContext) {
    if (invocationContext instanceof IInvocationContext) {
      return hasAssists((IInvocationContext) invocationContext);
    }
    return false;
  }

  @Override
  public boolean canFix(Annotation annotation) {
    return hasCorrections(annotation);
  }

  @Override
  public ICompletionProposal[] computeQuickAssistProposals(
      IQuickAssistInvocationContext quickAssistContext) {
    ISourceViewer viewer = quickAssistContext.getSourceViewer();
    int documentOffset = quickAssistContext.getOffset();

    IEditorPart part = fAssistant.getEditor();
    IAnnotationModel model = DartUI.getDocumentProvider().getAnnotationModel(part.getEditorInput());

    AssistContext context = null;
    if (DartCoreDebug.ENABLE_NEW_ANALYSIS) {
      com.google.dart.engine.services.assist.AssistContext enginecontext = ((DartEditor) part).getAssistContext();
      if (enginecontext != null) {
        context = new AssistContext(part, viewer, enginecontext);
      }
    } else {
      CompilationUnit cu = DartUI.getWorkingCopyManager().getWorkingCopy(part.getEditorInput());
      if (cu != null) {
        int length = viewer != null ? viewer.getSelectedRange().y : 0;
        context = new AssistContext(cu, viewer, part, documentOffset, length);
      }
    }
    if (context == null) {
      return new ICompletionProposal[0];
    }

    Annotation[] annotations = fAssistant.getAnnotationsAtOffset();

    fErrorMessage = null;

    ICompletionProposal[] res = null;
    if (model != null && context != null && annotations != null) {
      List<IDartCompletionProposal> proposals = Lists.newArrayList();
      IStatus status = collectProposals(
          context,
          model,
          annotations,
          true,
          !fAssistant.isUpdatedOffset(),
          proposals);
      res = proposals.toArray(new ICompletionProposal[proposals.size()]);
      if (!status.isOK()) {
        fErrorMessage = status.getMessage();
        DartToolsPlugin.log(status);
      }
    }

    if (res == null || res.length == 0) {
      return new ICompletionProposal[] {new ChangeCorrectionProposal(
          CorrectionMessages.NoCorrectionProposal_description,
          new NullChange(""), 0, null)}; //$NON-NLS-1$
    }
    if (res.length > 1) {
      Arrays.sort(res, new CompletionProposalComparator());
    }
    return res;
  }

  /*
   * @see IContentAssistProcessor#getErrorMessage()
   */
  @Override
  public String getErrorMessage() {
    return fErrorMessage;
  }

}
