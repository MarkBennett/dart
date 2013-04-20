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
package com.google.dart.tools.ui.internal.search;

import com.google.dart.compiler.ast.DartIdentifier;
import com.google.dart.compiler.ast.DartNode;
import com.google.dart.compiler.ast.DartPropertyAccess;
import com.google.dart.tools.core.internal.search.listener.GatheringSearchListener;
import com.google.dart.tools.core.model.DartClassTypeAlias;
import com.google.dart.tools.core.model.DartElement;
import com.google.dart.tools.core.model.DartFunction;
import com.google.dart.tools.core.model.DartFunctionTypeAlias;
import com.google.dart.tools.core.model.DartImport;
import com.google.dart.tools.core.model.DartModelException;
import com.google.dart.tools.core.model.DartVariableDeclaration;
import com.google.dart.tools.core.model.Field;
import com.google.dart.tools.core.model.Method;
import com.google.dart.tools.core.model.SourceRange;
import com.google.dart.tools.core.model.SourceReference;
import com.google.dart.tools.core.model.Type;
import com.google.dart.tools.core.model.TypeMember;
import com.google.dart.tools.core.search.MatchQuality;
import com.google.dart.tools.core.search.SearchEngine;
import com.google.dart.tools.core.search.SearchEngineFactory;
import com.google.dart.tools.core.search.SearchException;
import com.google.dart.tools.core.search.SearchFilter;
import com.google.dart.tools.core.search.SearchListener;
import com.google.dart.tools.core.search.SearchMatch;
import com.google.dart.tools.core.search.SearchPattern;
import com.google.dart.tools.core.search.SearchPatternFactory;
import com.google.dart.tools.core.search.SearchScope;
import com.google.dart.tools.internal.corext.refactoring.rename.MemberDeclarationsReferences;
import com.google.dart.tools.internal.corext.refactoring.rename.RenameAnalyzeUtil;
import com.google.dart.tools.search.internal.ui.text.BasicElementLabels;
import com.google.dart.tools.search.internal.ui.text.SearchResultUpdater;
import com.google.dart.tools.search.ui.ISearchQuery;
import com.google.dart.tools.search.ui.ISearchResult;
import com.google.dart.tools.search.ui.text.AbstractTextSearchResult;
import com.google.dart.tools.ui.DartElementLabels;
import com.google.dart.tools.ui.DartPluginImages;
import com.google.dart.tools.ui.DartToolsPlugin;
import com.google.dart.tools.ui.Messages;
import com.google.dart.tools.ui.search.ElementQuerySpecification;
import com.google.dart.tools.ui.search.NodeQuerySpecification;
import com.google.dart.tools.ui.search.PatternQuerySpecification;
import com.google.dart.tools.ui.search.QuerySpecification;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.resource.ImageDescriptor;

import java.util.ArrayList;
import java.util.List;

/**
 * Represents a particular Dart search query (for example,
 * "find all references to method 'foo' in workspace"). Running the query adds results to an
 * {@link ISearchResult} instance, accessed by calling {@link #getSearchResult()}.
 */
@SuppressWarnings("restriction")
public class DartSearchQuery implements ISearchQuery {

  public static class SearchResultCollector implements SearchListener {

    private AbstractTextSearchResult search;

    public SearchResultCollector(AbstractTextSearchResult search) {
      super();
      this.search = search;
    }

    @Override
    public void matchFound(SearchMatch match) {
      DartElement element = match.getElement();
      SourceRange range = match.getSourceRange();
      search.addMatch(new DartElementMatch(
          element,
          0 /* match.getRule() */,
          range.getOffset(),
          range.getLength(),
          match.getQuality().ordinal() /* accuracy */,
          false /* isReadAccess */,
          false /* isWriteAccess */,
          false,
          false));
    }

    @Override
    public void searchComplete() {
      // Ignored
    }
  }

  public static class UniqueResultFilter implements SearchFilter {
    private List<SearchMatch> allMatches = new ArrayList<SearchMatch>();
    private SearchFilter filter;

    public UniqueResultFilter(SearchFilter filter) {
      this.filter = filter;
    }

    @Override
    public boolean passes(SearchMatch match) {
      for (SearchMatch m : allMatches) {
        if (m.getElement().equals(match.getElement())
            && m.getSourceRange().equals(match.getSourceRange())) {
          // Filter out multiple matches that can occur when multiple, untyped declarations
          // potentially match the same reference.
          return false;
        }
      }
      allMatches.add(match);
      return filter == null ? true : filter.passes(match);
    }
  };

  private ISearchResult result;
  private final QuerySpecification patternData;

  public DartSearchQuery(QuerySpecification data) {
    if (data == null) {
      throw new IllegalArgumentException("data must not be null"); //$NON-NLS-1$
    }
    patternData = data;
  }

  @Override
  public boolean canRerun() {
    return true;
  }

//  private int getMatchMode(String pattern) {
//    if (pattern.indexOf('*') != -1 || pattern.indexOf('?') != -1) {
//      return SearchPattern.R_PATTERN_MATCH;
//    } else if (SearchUtils.isCamelCasePattern(pattern)) {
//      return SearchPattern.R_CAMELCASE_MATCH;
//    }
//    return SearchPattern.R_EXACT_MATCH;
//  }

  @Override
  public boolean canRunInBackground() {
    return true;
  }

  @Override
  public String getLabel() {
    return SearchMessages.DartSearchQuery_label;
  }

  public String getResultLabel(int nMatches) {
    return getSearchPatternDescription() + " - " + getMatchCountString(nMatches);
//TODO (pquitslund): add filter specific message label
//    int limitTo= getMaskedLimitTo();
//    if (nMatches == 1) {
//      String[] args= { getSearchPatternDescription(), fPatternData.getScopeDescription() };
//      switch (limitTo) {
//        case IJavaSearchConstants.IMPLEMENTORS:
//          return Messages.format(SearchMessages.JavaSearchOperation_singularImplementorsPostfix, args);
//        case IJavaSearchConstants.DECLARATIONS:
//          return Messages.format(SearchMessages.JavaSearchOperation_singularDeclarationsPostfix, args);
//        case IJavaSearchConstants.REFERENCES:
//          return Messages.format(SearchMessages.JavaSearchOperation_singularReferencesPostfix, args);
//        case IJavaSearchConstants.ALL_OCCURRENCES:
//          return Messages.format(SearchMessages.JavaSearchOperation_singularOccurrencesPostfix, args);
//        case IJavaSearchConstants.READ_ACCESSES:
//          return Messages.format(SearchMessages.JavaSearchOperation_singularReadReferencesPostfix, args);
//        case IJavaSearchConstants.WRITE_ACCESSES:
//          return Messages.format(SearchMessages.JavaSearchOperation_singularWriteReferencesPostfix, args);
//        default:
//          String matchLocations= MatchLocations.getMatchLocationDescription(limitTo, 3);
//          return Messages.format(SearchMessages.JavaSearchQuery_singularReferencesWithMatchLocations, new Object[] { args[0], args[1], matchLocations });
//      }
//    } else {
//      Object[] args= { getSearchPatternDescription(), new Integer(nMatches), fPatternData.getScopeDescription() };
//      switch (limitTo) {
//        case IJavaSearchConstants.IMPLEMENTORS:
//          return Messages.format(SearchMessages.JavaSearchOperation_pluralImplementorsPostfix, args);
//        case IJavaSearchConstants.DECLARATIONS:
//          return Messages.format(SearchMessages.JavaSearchOperation_pluralDeclarationsPostfix, args);
//        case IJavaSearchConstants.REFERENCES:
//          return Messages.format(SearchMessages.JavaSearchOperation_pluralReferencesPostfix, args);
//        case IJavaSearchConstants.ALL_OCCURRENCES:
//          return Messages.format(SearchMessages.JavaSearchOperation_pluralOccurrencesPostfix, args);
//        case IJavaSearchConstants.READ_ACCESSES:
//          return Messages.format(SearchMessages.JavaSearchOperation_pluralReadReferencesPostfix, args);
//        case IJavaSearchConstants.WRITE_ACCESSES:
//          return Messages.format(SearchMessages.JavaSearchOperation_pluralWriteReferencesPostfix, args);
//        default:
//          String matchLocations= MatchLocations.getMatchLocationDescription(limitTo, 3);
//          return Messages.format(SearchMessages.JavaSearchQuery_pluralReferencesWithMatchLocations, new Object[] { args[0], args[1], args[2], matchLocations });
//      }
//    }
  }

  @Override
  public ISearchResult getSearchResult() {
    if (result == null) {
      DartSearchResult result = new DartSearchResult(this);
      new SearchResultUpdater(result);
      this.result = result;
    }
    return result;
  }

//  private int getMaskedLimitTo() {
//    return fPatternData.getLimitTo() & ~(IJavaSearchConstants.IGNORE_RETURN_TYPE | IJavaSearchConstants.IGNORE_DECLARING_TYPE);
//  }

  @Override
  public IStatus run(IProgressMonitor monitor) {
    final DartSearchResult textResult = (DartSearchResult) getSearchResult();
    textResult.removeAll();
    SearchEngine engine = SearchEngineFactory.createSearchEngine();

//  try {
//  int totalTicks= 1000;
//TODO (pquitslund): add search participant support
//  IProject[] projects= JavaSearchScopeFactory.getInstance().getProjects(fPatternData.getScope());
//  final SearchParticipantRecord[] participantDescriptors= SearchParticipantsExtensionPoint.getInstance().getSearchParticipants(projects);
//  final int[] ticks= new int[participantDescriptors.length];
//  for (int i= 0; i < participantDescriptors.length; i++) {
//    final int iPrime= i;
//    ISafeRunnable runnable= new ISafeRunnable() {
//      public void handleException(Throwable exception) {
//        ticks[iPrime]= 0;
//        String message= SearchMessages.JavaSearchQuery_error_participant_estimate;
//        DartToolsPlugin.log(new Status(IStatus.ERROR, DartToolsPlugin.getPluginId(), 0, message, exception));
//      }
//
//      public void run() throws Exception {
//        ticks[iPrime]= participantDescriptors[iPrime].getParticipant().estimateTicks(fPatternData);
//      }
//    };
//
//    SafeRunner.run(runnable);
//    totalTicks+= ticks[i];
//  }

    SearchResultCollector collector = new SearchResultCollector(textResult);
    SearchScope scope = patternData.getScope();

    if (patternData.hasElement()) {
      DartElement element = ((ElementQuerySpecification) patternData).getElement();
      if (!element.exists()) {
        String patternString = DartElementLabels.getElementLabel(
            element,
            DartElementLabels.ALL_DEFAULT);
        return new Status(IStatus.ERROR, DartToolsPlugin.getPluginId(), 0, Messages.format(
            SearchMessages.DartSearchQuery_error_element_does_not_exist,
            patternString), null);
      }

      try {
        if (patternData.isReferencesSearch()) {
          searchForReferences(engine, element, scope, null, collector, monitor);
        }
        if (patternData.isDeclarationsSearch()) {
          searchForDeclarations(engine, element, scope, null, collector, monitor);
        }
        if (patternData.isOverridesSearch()) {
          searchForOverrides(engine, element, scope, null, collector, monitor);
        }
      } catch (SearchException e) {
        DartToolsPlugin.log(e);
        // TODO: do we need to update the UI as well? Or schedule another search?
      } catch (CoreException ex) {
        DartToolsPlugin.log(ex);
      }

    } else if (patternData.hasNode()) {

      DartNode node = ((NodeQuerySpecification) patternData).getNode();
      if (node instanceof DartIdentifier) {
        DartIdentifier id = (DartIdentifier) node;

        try {
          if (patternData.isReferencesSearch()) {
            searchForReferences(engine, id, scope, null, collector, monitor);
          }
          if (patternData.isDeclarationsSearch()) {
            searchForDeclarations(engine, id, scope, null, collector, monitor);
          }
        } catch (SearchException e) {
          DartToolsPlugin.log(e);
        } catch (CoreException ex) {
          DartToolsPlugin.log(ex);
        }
      }
    }

//      engine.search(pattern, new SearchParticipant[] { SearchEngine.getDefaultSearchParticipant() }, fPatternData.getScope(), collector, mainSearchPM);
//TODO (pquitslund): add search participant support
//      for (int i= 0; i < participantDescriptors.length; i++) {
//        final ISearchRequestor requestor= new SearchRequestor(participantDescriptors[i].getParticipant(), textResult);
//        final IProgressMonitor participantPM= new SubProgressMonitor(monitor, ticks[i]);
//
//        final int iPrime= i;
//        ISafeRunnable runnable= new ISafeRunnable() {
//          public void handleException(Throwable exception) {
//            participantDescriptors[iPrime].getDescriptor().disable();
//            String message= SearchMessages.JavaSearchQuery_error_participant_search;
//            DartToolsPlugin.log(new Status(IStatus.ERROR, DartToolsPlugin.getPluginId(), 0, message, exception));
//          }
//
//          public void run() throws Exception {
//
//            final IQueryParticipant participant= participantDescriptors[iPrime].getParticipant();
//            final PerformanceStats stats= PerformanceStats.getStats(PERF_SEARCH_PARTICIPANT, participant);
//            stats.startRun();
//
//            participant.search(requestor, fPatternData, participantPM);
//
//            stats.endRun();
//          }
//        };

//        SafeRunner.run(runnable);
//      }

//    } catch (CoreException e) {
//      return e.getStatus();
//    }

    String message = Messages.format(
        SearchMessages.DartSearchQuery_status_ok_message,
        String.valueOf(textResult.getMatchCount()));
    return new Status(IStatus.OK, DartToolsPlugin.getPluginId(), 0, message, null);
  }

  ImageDescriptor getImageDescriptor() {
    return DartPluginImages.DESC_OBJS_SEARCH_REF;
    //TODO (pquitslund): support different image descriptors for different kinds of search
//    int limitTo= getMaskedLimitTo();
//    if (limitTo == IJavaSearchConstants.IMPLEMENTORS || limitTo == IJavaSearchConstants.DECLARATIONS)
//      return DartPluginImages.DESC_OBJS_SEARCH_DECL;
//    else
//      return DartPluginImages.DESC_OBJS_SEARCH_REF;
  }

  QuerySpecification getSpecification() {
    return patternData;
  }

  private void addResult(String name, DartElement element, SearchListener listener)
      throws DartModelException {
    SourceRange range = null;
    switch (element.getElementType()) {
      case DartElement.FIELD:
      case DartElement.METHOD:
        SourceReference method = (SourceReference) element;
        range = method.getNameRange();
        break;
      default:
        return;
    }
    SearchMatch match = new SearchMatch(MatchQuality.EXACT, element, range);
    listener.matchFound(match);
  }

  private String getMatchCountString(int nMatches) {
    return nMatches + " match" + (nMatches != 1 ? "es" : "") + " in the workspace";
  }

  private String getSearchPatternDescription() {
    if (patternData.hasElement()) {
      DartElement element = ((ElementQuerySpecification) patternData).getElement();
      return DartElementLabels.getElementLabel(element, DartElementLabels.ALL_DEFAULT
          | DartElementLabels.ALL_FULLY_QUALIFIED | DartElementLabels.USE_RESOLVED);
    } else if (patternData.hasNode()) {
      // TODO(messick): Make this better, if needed.
      DartNode node = ((NodeQuerySpecification) patternData).getNode();
      if (node instanceof DartIdentifier) {
        return ((DartIdentifier) node).getName();
      } else {
        return node.getObjectIdentifier();
      }
    }
    return BasicElementLabels.getFilePattern(((PatternQuerySpecification) patternData).getPattern());
  }

  private void searchForDeclarations(SearchEngine engine, DartElement element, SearchScope scope,
      SearchFilter filter, SearchResultCollector listener, IProgressMonitor monitor)
      throws CoreException, SearchException {
    switch (element.getElementType()) {
      case DartElement.CLASS_TYPE_ALIAS:
      case DartElement.FUNCTION_TYPE_ALIAS:
      case DartElement.FUNCTION:
      case DartElement.IMPORT:
      case DartElement.TYPE:
      case DartElement.TYPE_PARAMETER:
      case DartElement.VARIABLE: {
        SourceRange range = ((SourceReference) element).getSourceRange();
        SearchMatch match = new SearchMatch(MatchQuality.EXACT, element, range);
        if (filter == null || filter.passes(match)) {
          listener.matchFound(match);
        }
        break;
      }
      case DartElement.FIELD:
      case DartElement.METHOD: {
        // There's no way to tell which hierarchy an untyped reference might refer to, so find all declarations.
        DartIdentifier identifier = new DartIdentifier(element.getElementName());
        searchForDeclarations(engine, identifier, scope, filter, listener, monitor);
        break;
      }
      default:
        throw new UnsupportedOperationException("unsupported search type: " + element.getClass()); //$NON-NLS-1$
    }
  }

  private void searchForDeclarations(SearchEngine engine, DartIdentifier identifier,
      SearchScope scope, SearchFilter filter, SearchListener listener, IProgressMonitor monitor)
      throws CoreException, SearchException {
    // Index lacks relationships required to do direct search, so first get all classes.
    String name = identifier.getName();
    boolean isProperty = identifier.getParent() instanceof DartPropertyAccess;
    SearchPattern pattern = SearchPatternFactory.createWildcardPattern("*", false);
    List<SearchMatch> allMatches = engine.searchTypeDeclarations(scope, pattern, filter, monitor);
    // Then see if the type or a child of the type matches the given name.
    // We are NOT looking for local function or local variable declarations.
    for (SearchMatch typeMatch : allMatches) {
      DartElement type = typeMatch.getElement();
      if (!isProperty) {
        if (type.getElementName().equals(name)) {
          addResult(name, type, listener);
        }
      }
      for (DartElement child : type.getChildren()) {
        if (child.getElementName().equals(name)) {
          addResult(name, child, listener);
        }
      }
    }
  }

  private void searchForOverrides(SearchEngine engine, DartElement element, SearchScope scope,
      SearchFilter filter, SearchResultCollector listener, IProgressMonitor monitor)
      throws CoreException {
    switch (element.getElementType()) {
      case DartElement.CLASS_TYPE_ALIAS:
      case DartElement.FUNCTION_TYPE_ALIAS:
      case DartElement.FUNCTION:
      case DartElement.FIELD:
      case DartElement.IMPORT:
      case DartElement.TYPE:
      case DartElement.TYPE_PARAMETER:
      case DartElement.VARIABLE: {
        break;
      }
      case DartElement.METHOD: {
        MemberDeclarationsReferences memberInfo;
        memberInfo = RenameAnalyzeUtil.findDeclarationsReferences((Method) element, monitor);
        for (TypeMember member : memberInfo.declarations) {
          SearchMatch match = new SearchMatch(MatchQuality.EXACT, member, member.getSourceRange());
          listener.matchFound(match);
        }
        break;
      }
      default:
        throw new UnsupportedOperationException("unsupported search type: " + element.getClass()); //$NON-NLS-1$
    }
  }

  private void searchForReferences(SearchEngine engine, DartElement element, SearchScope scope,
      SearchFilter filter, SearchListener collector, IProgressMonitor monitor)
      throws SearchException {
    switch (element.getElementType()) {
      case DartElement.METHOD:
        engine.searchReferences((Method) element, scope, filter, collector, monitor);
        break;
      case DartElement.CLASS_TYPE_ALIAS:
        engine.searchReferences((DartClassTypeAlias) element, scope, filter, collector, monitor);
        break;
      case DartElement.FUNCTION_TYPE_ALIAS:
        engine.searchReferences((DartFunctionTypeAlias) element, scope, filter, collector, monitor);
        break;
      case DartElement.FIELD:
        engine.searchReferences((Field) element, scope, filter, collector, monitor);
        break;
      case DartElement.FUNCTION:
        engine.searchReferences((DartFunction) element, scope, filter, collector, monitor);
        break;
      case DartElement.TYPE:
        engine.searchReferences((Type) element, scope, filter, collector, monitor);
        break;
      case DartElement.IMPORT:
        engine.searchReferences((DartImport) element, scope, filter, collector, monitor);
        break;
      case DartElement.VARIABLE:
        engine.searchReferences(
            (DartVariableDeclaration) element,
            scope,
            filter,
            collector,
            monitor);
        break;
      default:
        throw new UnsupportedOperationException("unsupported search type: " + element.getClass()); //$NON-NLS-1$
    }
  }

  private void searchForReferences(SearchEngine engine, DartIdentifier identifier,
      SearchScope scope, final SearchFilter filter, SearchResultCollector collector,
      IProgressMonitor monitor) throws CoreException, SearchException {
    GatheringSearchListener listener = new GatheringSearchListener();
    // Transform the selected node to a collection of elements using the search engine.
    searchForDeclarations(engine, identifier, scope, filter, listener, monitor);
    // Search for references to each element.
    SearchFilter uniqueFilter = new UniqueResultFilter(filter);
    for (SearchMatch match : listener.getMatches()) {
      searchForReferences(engine, match.getElement(), scope, uniqueFilter, collector, monitor);
    }
  }
}
