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
package com.google.dart.engine.internal.context;

import com.google.dart.engine.AnalysisEngine;
import com.google.dart.engine.ast.ASTNode;
import com.google.dart.engine.ast.AnnotatedNode;
import com.google.dart.engine.ast.Comment;
import com.google.dart.engine.ast.CompilationUnit;
import com.google.dart.engine.ast.Directive;
import com.google.dart.engine.ast.LibraryDirective;
import com.google.dart.engine.ast.PartOfDirective;
import com.google.dart.engine.ast.visitor.NodeLocator;
import com.google.dart.engine.context.AnalysisContext;
import com.google.dart.engine.context.AnalysisErrorInfo;
import com.google.dart.engine.context.AnalysisException;
import com.google.dart.engine.context.ChangeNotice;
import com.google.dart.engine.context.ChangeSet;
import com.google.dart.engine.element.CompilationUnitElement;
import com.google.dart.engine.element.Element;
import com.google.dart.engine.element.ElementLocation;
import com.google.dart.engine.element.HtmlElement;
import com.google.dart.engine.element.LibraryElement;
import com.google.dart.engine.error.AnalysisError;
import com.google.dart.engine.error.AnalysisErrorListener;
import com.google.dart.engine.html.ast.HtmlUnit;
import com.google.dart.engine.html.ast.XmlAttributeNode;
import com.google.dart.engine.html.ast.XmlTagNode;
import com.google.dart.engine.html.ast.visitor.RecursiveXmlVisitor;
import com.google.dart.engine.html.parser.HtmlParseResult;
import com.google.dart.engine.html.parser.HtmlParser;
import com.google.dart.engine.html.scanner.HtmlScanResult;
import com.google.dart.engine.html.scanner.HtmlScanner;
import com.google.dart.engine.internal.builder.HtmlUnitBuilder;
import com.google.dart.engine.internal.cache.DartEntry;
import com.google.dart.engine.internal.cache.DartEntryImpl;
import com.google.dart.engine.internal.cache.HtmlEntry;
import com.google.dart.engine.internal.cache.HtmlEntryImpl;
import com.google.dart.engine.internal.cache.SourceEntry;
import com.google.dart.engine.internal.element.ElementImpl;
import com.google.dart.engine.internal.element.ElementLocationImpl;
import com.google.dart.engine.internal.error.ErrorReporter;
import com.google.dart.engine.internal.resolver.DeclarationResolver;
import com.google.dart.engine.internal.resolver.LibraryResolver;
import com.google.dart.engine.internal.resolver.ResolverVisitor;
import com.google.dart.engine.internal.resolver.TypeProvider;
import com.google.dart.engine.internal.resolver.TypeProviderImpl;
import com.google.dart.engine.internal.resolver.TypeResolverVisitor;
import com.google.dart.engine.internal.scope.Namespace;
import com.google.dart.engine.internal.scope.NamespaceBuilder;
import com.google.dart.engine.internal.verifier.ConstantVerifier;
import com.google.dart.engine.internal.verifier.ErrorVerifier;
import com.google.dart.engine.parser.Parser;
import com.google.dart.engine.scanner.CharBufferScanner;
import com.google.dart.engine.scanner.StringScanner;
import com.google.dart.engine.scanner.Token;
import com.google.dart.engine.sdk.DartSdk;
import com.google.dart.engine.source.Source;
import com.google.dart.engine.source.SourceContainer;
import com.google.dart.engine.source.SourceFactory;
import com.google.dart.engine.source.SourceKind;
import com.google.dart.engine.utilities.ast.ASTCloner;
import com.google.dart.engine.utilities.source.LineInfo;

import java.net.URI;
import java.nio.CharBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

/**
 * Instances of the class {@code AnalysisContextImpl} implement an {@link AnalysisContext analysis
 * context}.
 * 
 * @coverage dart.engine
 */
public class AnalysisContextImpl implements InternalAnalysisContext {
  /**
   * Instances of the class {@code ScanResult} represent the results of scanning a source.
   */
  private static class ScanResult {
    /**
     * The time at which the contents of the source were last set.
     */
    private long modificationTime;

    /**
     * The first token in the token stream.
     */
    private Token token;

    /**
     * The line start information that was produced.
     */
    private int[] lineStarts;

    /**
     * Initialize a newly created result object to be empty.
     */
    private ScanResult() {
      super();
    }
  }

  /**
   * The source factory used to create the sources that can be analyzed in this context.
   */
  private SourceFactory sourceFactory;

  /**
   * A table mapping the sources known to the context to the information known about the source.
   */
  private final HashMap<Source, SourceEntry> sourceMap = new HashMap<Source, SourceEntry>();

  /**
   * A table mapping sources to the change notices that are waiting to be returned related to that
   * source.
   */
  private HashMap<Source, ChangeNoticeImpl> pendingNotices = new HashMap<Source, ChangeNoticeImpl>();

  /**
   * A list containing the most recently accessed sources with the most recently used at the end of
   * the list. When more sources are added than the maximum allowed then the least recently used
   * source will be removed and will have it's cached AST structure flushed.
   */
  private ArrayList<Source> recentlyUsed = new ArrayList<Source>(MAX_CACHE_SIZE);

  /**
   * The object used to synchronize access to all of the caches.
   */
  private Object cacheLock = new Object();

  /**
   * The maximum number of sources for which data should be kept in the cache.
   */
  private static final int MAX_CACHE_SIZE = 64;

  /**
   * The name of the 'src' attribute in a HTML tag.
   */
  private static final String ATTRIBUTE_SRC = "src";

  /**
   * The name of the 'script' tag in an HTML file.
   */
  private static final String TAG_SCRIPT = "script";

  /**
   * The number of times that the flushing of information from the cache has been disabled without
   * being re-enabled.
   */
  private int cacheRemovalCount = 0;

  /**
   * Initialize a newly created analysis context.
   */
  public AnalysisContextImpl() {
    super();
  }

  @Override
  public void addSourceInfo(Source source, SourceEntry info) {
    sourceMap.put(source, info);
  }

  @Override
  public void applyChanges(ChangeSet changeSet) {
    if (changeSet.isEmpty()) {
      return;
    }
    synchronized (cacheLock) {
      //
      // First, compute the list of sources that have been removed.
      //
      ArrayList<Source> removedSources = new ArrayList<Source>(changeSet.getRemoved());
      for (SourceContainer container : changeSet.getRemovedContainers()) {
        addSourcesInContainer(removedSources, container);
      }
      //
      // Then determine which cached results are no longer valid.
      //
      boolean addedDartSource = false;
      for (Source source : changeSet.getAdded()) {
        if (sourceAvailable(source)) {
          addedDartSource = true;
        }
      }
      for (Source source : changeSet.getChanged()) {
        sourceChanged(source);
      }
      for (Source source : removedSources) {
        sourceRemoved(source);
      }
      if (addedDartSource) {
        // TODO(brianwilkerson) This is hugely inefficient, but we need to re-analyze any libraries
        // that might have been referencing the not-yet-existing source that was just added. Longer
        // term we need to keep track of which libraries are referencing non-existing sources and
        // only re-analyze those libraries.
        for (SourceEntry sourceEntry : sourceMap.values()) {
          if (sourceEntry instanceof DartEntry) {
            ((DartEntryImpl) sourceEntry).invalidateAllResolutionInformation();
          }
        }
      }
    }
  }

  @Override
  public String computeDocumentationComment(Element element) throws AnalysisException {
    if (element == null) {
      return null;
    }
    Source source = element.getSource();
    if (source == null) {
      return null;
    }
    final CharSequence[] contentHolder = new CharSequence[1];
    try {
      source.getContents(new Source.ContentReceiver() {
        @Override
        public void accept(CharBuffer contents, long modificationTime) {
          contentHolder[0] = contents;
        }

        @Override
        public void accept(String contents, long modificationTime) {
          contentHolder[0] = contents;
        }
      });
    } catch (Exception exception) {
      throw new AnalysisException("Could not get contents of " + source.getFullName(), exception);
    }
    if (contentHolder[0] == null) {
      return null;
    }
    CompilationUnit unit = parseCompilationUnit(source);
    if (unit == null) {
      return null;
    }
    NodeLocator locator = new NodeLocator(element.getNameOffset());
    ASTNode nameNode = locator.searchWithin(unit);
    while (nameNode != null) {
      if (nameNode instanceof AnnotatedNode) {
        Comment comment = ((AnnotatedNode) nameNode).getDocumentationComment();
        if (comment == null) {
          return null;
        }
        int offset = comment.getOffset();
        return contentHolder[0].subSequence(offset, offset + comment.getLength()).toString();
      }
      nameNode = nameNode.getParent();
    }
    return null;
  }

  @Override
  public AnalysisError[] computeErrors(Source source) throws AnalysisException {
    synchronized (cacheLock) {
      DartEntry dartEntry = getDartEntry(source);
      if (dartEntry == null) {
        return AnalysisError.NO_ERRORS;
      }
      CacheState parseErrorsState = dartEntry.getState(DartEntry.PARSE_ERRORS);
      if (parseErrorsState != CacheState.VALID && parseErrorsState != CacheState.ERROR) {
        parseCompilationUnit(source);
      }
      Source[] libraries = getLibrariesContaining(source);
      for (Source librarySource : libraries) {
        CacheState resolutionErrorsState = dartEntry.getState(
            DartEntry.RESOLUTION_ERRORS,
            librarySource);
        if (resolutionErrorsState != CacheState.VALID && resolutionErrorsState != CacheState.ERROR) {
          // TODO(brianwilkerson) Decide whether to resolve the source against all libraries or
          // whether to add a librarySource parameter to this method.
          // resolveCompilationUnit(source, librarySource);
        }
      }
      return dartEntry.getAllErrors();
    }
  }

  @Override
  public HtmlElement computeHtmlElement(Source source) throws AnalysisException {
    if (!AnalysisEngine.isHtmlFileName(source.getShortName())) {
      return null;
    }
    synchronized (cacheLock) {
      HtmlEntry htmlEntry = getHtmlEntry(source);
      if (htmlEntry == null) {
        return null;
      }
      HtmlElement element = htmlEntry.getValue(HtmlEntry.ELEMENT);
      if (element == null) {
        HtmlUnit unit = htmlEntry.getValue(HtmlEntry.RESOLVED_UNIT);
        if (unit == null) {
          unit = htmlEntry.getValue(HtmlEntry.PARSED_UNIT);
          if (unit == null) {
            unit = parseHtmlUnit(source);
          }
        }
        HtmlUnitBuilder builder = new HtmlUnitBuilder(this);
        element = builder.buildHtmlElement(source, unit);
        ((HtmlEntryImpl) htmlEntry).setValue(HtmlEntry.RESOLVED_UNIT, unit);
        ((HtmlEntryImpl) htmlEntry).setValue(HtmlEntry.ELEMENT, element);
      }
      return element;
    }
  }

  @Override
  public SourceKind computeKindOf(Source source) {
    synchronized (cacheLock) {
      SourceEntry sourceEntry = getSourceEntry(source);
      if (sourceEntry == null) {
        return SourceKind.UNKNOWN;
      } else if (sourceEntry instanceof DartEntry) {
        DartEntry dartEntry = (DartEntry) sourceEntry;
        CacheState sourceKindState = dartEntry.getState(DartEntry.SOURCE_KIND);
        if (sourceKindState != CacheState.VALID && sourceKindState != CacheState.ERROR) {
          internalComputeKindOf(source);
        }
      }
      return sourceEntry.getKind();
    }
  }

  @Override
  public LibraryElement computeLibraryElement(Source source) throws AnalysisException {
    if (!AnalysisEngine.isDartFileName(source.getShortName())) {
      return null;
    }
    synchronized (cacheLock) {
      DartEntry dartEntry = getDartEntry(source);
      if (dartEntry == null) {
        return null;
      }
      LibraryElement element = dartEntry.getValue(DartEntry.ELEMENT);
      if (element == null) {
        if (computeKindOf(source) != SourceKind.LIBRARY) {
          throw new AnalysisException("Cannot compute library element for non-library: "
              + source.getFullName());
        }
        LibraryResolver resolver = new LibraryResolver(this);
        try {
          element = resolver.resolveLibrary(source, true);
          if (element != null) {
            ((DartEntryImpl) dartEntry).setValue(DartEntry.ELEMENT, element);
          }
        } catch (AnalysisException exception) {
          AnalysisEngine.getInstance().getLogger().logError(
              "Could not resolve the library " + source.getFullName(),
              exception);
        }
      }
      return element;
    }
  }

  @Override
  public LineInfo computeLineInfo(Source source) throws AnalysisException {
    synchronized (cacheLock) {
      SourceEntry sourceEntry = getSourceEntry(source);
      if (sourceEntry == null) {
        return null;
      }
      LineInfo lineInfo = sourceEntry.getValue(SourceEntry.LINE_INFO);
      if (lineInfo == null) {
        if (sourceEntry instanceof HtmlEntry) {
          parseHtmlUnit(source);
          lineInfo = sourceEntry.getValue(SourceEntry.LINE_INFO);
        } else if (sourceEntry instanceof DartEntry) {
          parseCompilationUnit(source);
          lineInfo = sourceEntry.getValue(SourceEntry.LINE_INFO);
        }
      }
      return lineInfo;
    }
  }

  @Override
  public CompilationUnit computeResolvableCompilationUnit(Source source) throws AnalysisException {
    synchronized (cacheLock) {
      DartEntry dartEntry = getDartEntry(source);
      if (dartEntry == null) {
        return null;
      }
      CompilationUnit unit = dartEntry.getAnyParsedCompilationUnit();
      if (unit != null) {
        return (CompilationUnit) unit.accept(new ASTCloner());
      }
      unit = internalParseCompilationUnit(((DartEntryImpl) dartEntry), source);
      ((DartEntryImpl) dartEntry).setState(DartEntry.PARSED_UNIT, CacheState.FLUSHED);
      return unit;
    }
  }

  @Override
  public AnalysisContext extractContext(SourceContainer container) {
    return extractContextInto(
        container,
        (AnalysisContextImpl) AnalysisEngine.getInstance().createAnalysisContext());
  }

  @Override
  public InternalAnalysisContext extractContextInto(SourceContainer container,
      InternalAnalysisContext newContext) {
    ArrayList<Source> sourcesToRemove = new ArrayList<Source>();
    synchronized (cacheLock) {
      // Move sources in the specified directory to the new context
      for (Map.Entry<Source, SourceEntry> entry : sourceMap.entrySet()) {
        Source source = entry.getKey();
        if (container.contains(source)) {
          sourcesToRemove.add(source);
          newContext.addSourceInfo(source, entry.getValue().getWritableCopy());
        }
      }

      // TODO (danrubel): Either remove sources or adjust contract described in AnalysisContext.
      // Currently, callers assume that sources have been removed from this context

//      for (Source source : sourcesToRemove) {
//        // TODO(brianwilkerson) Determine whether the source should be removed (that is, whether
//        // there are no additional dependencies on the source), and if so remove all information
//        // about the source.
//        sourceMap.remove(source);
//        parseCache.remove(source);
//        publicNamespaceCache.remove(source);
//        libraryElementCache.remove(source);
//      }
    }

    return newContext;
  }

  @Override
  public Element getElement(ElementLocation location) {
    String[] components = ((ElementLocationImpl) location).getComponents();
    ElementImpl element;
    synchronized (cacheLock) {
      Source librarySource = sourceFactory.fromEncoding(components[0]);
      try {
        element = (ElementImpl) computeLibraryElement(librarySource);
      } catch (AnalysisException exception) {
        return null;
      }
    }
    for (int i = 1; i < components.length; i++) {
      if (element == null) {
        return null;
      }
      element = element.getChild(components[i]);
    }
    return element;
  }

  @Override
  public AnalysisErrorInfo getErrors(Source source) {
    synchronized (cacheLock) {
      SourceEntry sourceEntry = getSourceEntry(source);
      if (sourceEntry instanceof DartEntry) {
        DartEntry dartEntry = (DartEntry) sourceEntry;
        return new AnalysisErrorInfoImpl(
            dartEntry.getAllErrors(),
            dartEntry.getValue(SourceEntry.LINE_INFO));
      }
      return new AnalysisErrorInfoImpl(
          AnalysisError.NO_ERRORS,
          sourceEntry.getValue(SourceEntry.LINE_INFO));
    }
  }

  @Override
  public HtmlElement getHtmlElement(Source source) {
    synchronized (cacheLock) {
      SourceEntry sourceEntry = getSourceEntry(source);
      if (sourceEntry instanceof HtmlEntry) {
        return ((HtmlEntry) sourceEntry).getValue(HtmlEntry.ELEMENT);
      }
      return null;
    }
  }

  @Override
  public Source[] getHtmlFilesReferencing(Source source) {
    synchronized (cacheLock) {
      ArrayList<Source> htmlSources = new ArrayList<Source>();
      switch (getKindOf(source)) {
        case LIBRARY:
        default:
          for (Map.Entry<Source, SourceEntry> entry : sourceMap.entrySet()) {
            if (entry.getValue().getKind() == SourceKind.HTML) {
              Source[] referencedLibraries = ((HtmlEntry) entry.getValue()).getValue(HtmlEntry.REFERENCED_LIBRARIES);
              if (contains(referencedLibraries, source)) {
                htmlSources.add(entry.getKey());
              }
            }
          }
          break;
        case PART:
          Source[] librarySources = getLibrariesContaining(source);
          for (Map.Entry<Source, SourceEntry> entry : sourceMap.entrySet()) {
            if (entry.getValue().getKind() == SourceKind.HTML) {
              Source[] referencedLibraries = ((HtmlEntry) entry.getValue()).getValue(HtmlEntry.REFERENCED_LIBRARIES);
              if (containsAny(referencedLibraries, librarySources)) {
                htmlSources.add(entry.getKey());
              }
            }
          }
          break;
      }
      if (htmlSources.isEmpty()) {
        return Source.EMPTY_ARRAY;
      }
      return htmlSources.toArray(new Source[htmlSources.size()]);
    }
  }

  @Override
  public Source[] getHtmlSources() {
    return getSources(SourceKind.HTML);
  }

  @Override
  public SourceKind getKindOf(Source source) {
    synchronized (cacheLock) {
      SourceEntry sourceEntry = getSourceEntry(source);
      if (sourceEntry == null) {
        return SourceKind.UNKNOWN;
      }
      return sourceEntry.getKind();
    }
  }

  @Override
  public Source[] getLaunchableClientLibrarySources() {
    // TODO(brianwilkerson) This needs to filter out libraries that do not reference dart:html,
    // either directly or indirectly.
    ArrayList<Source> sources = new ArrayList<Source>();
    synchronized (cacheLock) {
      for (Map.Entry<Source, SourceEntry> entry : sourceMap.entrySet()) {
        Source source = entry.getKey();
        SourceEntry sourceEntry = entry.getValue();
        if (sourceEntry.getKind() == SourceKind.LIBRARY && !source.isInSystemLibrary()) {
          sources.add(source);
        }
      }
    }
    return sources.toArray(new Source[sources.size()]);
  }

  @Override
  public Source[] getLaunchableServerLibrarySources() {
    // TODO(brianwilkerson) This needs to filter out libraries that reference dart:html, either
    // directly or indirectly.
    ArrayList<Source> sources = new ArrayList<Source>();
    synchronized (cacheLock) {
      for (Map.Entry<Source, SourceEntry> entry : sourceMap.entrySet()) {
        Source source = entry.getKey();
        SourceEntry sourceEntry = entry.getValue();
        if (sourceEntry.getKind() == SourceKind.LIBRARY && !source.isInSystemLibrary()) {
          sources.add(source);
        }
      }
    }
    return sources.toArray(new Source[sources.size()]);
  }

  @Override
  public Source[] getLibrariesContaining(Source source) {
    synchronized (cacheLock) {
      ArrayList<Source> librarySources = new ArrayList<Source>();
      for (Map.Entry<Source, SourceEntry> entry : sourceMap.entrySet()) {
        if (entry.getValue().getKind() == SourceKind.LIBRARY) {
          if (contains(((DartEntry) entry.getValue()).getValue(DartEntry.INCLUDED_PARTS), source)) {
            librarySources.add(entry.getKey());
          }
        }
      }
      if (librarySources.isEmpty()) {
        return Source.EMPTY_ARRAY;
      }
      return librarySources.toArray(new Source[librarySources.size()]);
    }
  }

  @Override
  public LibraryElement getLibraryElement(Source source) {
    synchronized (cacheLock) {
      SourceEntry sourceEntry = getSourceEntry(source);
      if (sourceEntry instanceof DartEntry) {
        return ((DartEntry) sourceEntry).getValue(DartEntry.ELEMENT);
      }
      return null;
    }
  }

  @Override
  public Source[] getLibrarySources() {
    return getSources(SourceKind.LIBRARY);
  }

  @Override
  public LineInfo getLineInfo(Source source) {
    synchronized (cacheLock) {
      SourceEntry sourceEntry = getSourceEntry(source);
      if (sourceEntry != null) {
        return sourceEntry.getValue(SourceEntry.LINE_INFO);
      }
      return null;
    }
  }

  @Override
  public Namespace getPublicNamespace(LibraryElement library) {
    // TODO(brianwilkerson) Rename this to not start with 'get'. Note that this is not part of the
    // API of the interface.
    Source source = library.getDefiningCompilationUnit().getSource();
    synchronized (cacheLock) {
      DartEntry dartEntry = getDartEntry(source);
      if (dartEntry == null) {
        return null;
      }
      Namespace namespace = dartEntry.getValue(DartEntry.PUBLIC_NAMESPACE);
      if (namespace == null) {
        NamespaceBuilder builder = new NamespaceBuilder();
        namespace = builder.createPublicNamespace(library);
        ((DartEntryImpl) dartEntry).setValue(DartEntry.PUBLIC_NAMESPACE, namespace);
      }
      return namespace;
    }
  }

  @Override
  public Namespace getPublicNamespace(Source source) throws AnalysisException {
    // TODO(brianwilkerson) Rename this to not start with 'get'. Note that this is not part of the
    // API of the interface.
    synchronized (cacheLock) {
      DartEntry dartEntry = getDartEntry(source);
      if (dartEntry == null) {
        return null;
      }
      Namespace namespace = dartEntry.getValue(DartEntry.PUBLIC_NAMESPACE);
      if (namespace == null) {
        LibraryElement library = computeLibraryElement(source);
        if (library == null) {
          return null;
        }
        NamespaceBuilder builder = new NamespaceBuilder();
        namespace = builder.createPublicNamespace(library);
        ((DartEntryImpl) dartEntry).setValue(DartEntry.PUBLIC_NAMESPACE, namespace);
      }
      return namespace;
    }
  }

  @Override
  public CompilationUnit getResolvedCompilationUnit(Source unitSource, LibraryElement library) {
    if (library == null) {
      return null;
    }
    return getResolvedCompilationUnit(unitSource, library.getSource());
  }

  @Override
  public CompilationUnit getResolvedCompilationUnit(Source unitSource, Source librarySource) {
    synchronized (cacheLock) {
      accessed(unitSource);
      DartEntry dartEntry = getDartEntry(unitSource);
      if (dartEntry == null) {
        return null;
      }
      return dartEntry.getValue(DartEntry.RESOLVED_UNIT, librarySource);
    }
  }

  @Override
  public SourceFactory getSourceFactory() {
    return sourceFactory;
  }

  @Override
  public boolean isClientLibrary(Source librarySource) {
    SourceEntry sourceEntry = getSourceEntry(librarySource);
    if (sourceEntry instanceof DartEntry) {
      DartEntry dartEntry = (DartEntry) sourceEntry;
      CacheState isClientState = dartEntry.getState(DartEntry.IS_CLIENT);
      CacheState isLaunchableState = dartEntry.getState(DartEntry.IS_LAUNCHABLE);
      if (isClientState == CacheState.INVALID || isClientState == CacheState.ERROR
          || isLaunchableState == CacheState.INVALID || isLaunchableState == CacheState.ERROR) {
        return false;
      }
      return dartEntry.getValue(DartEntry.IS_CLIENT) && dartEntry.getValue(DartEntry.IS_LAUNCHABLE);
    }
    return false;
  }

  @Override
  public boolean isServerLibrary(Source librarySource) {
    SourceEntry sourceEntry = getSourceEntry(librarySource);
    if (sourceEntry instanceof DartEntry) {
      DartEntry dartEntry = (DartEntry) sourceEntry;
      CacheState isClientState = dartEntry.getState(DartEntry.IS_CLIENT);
      CacheState isLaunchableState = dartEntry.getState(DartEntry.IS_LAUNCHABLE);
      if (isClientState == CacheState.INVALID || isClientState == CacheState.ERROR
          || isLaunchableState == CacheState.INVALID || isLaunchableState == CacheState.ERROR) {
        return false;
      }
      return !dartEntry.getValue(DartEntry.IS_CLIENT)
          && dartEntry.getValue(DartEntry.IS_LAUNCHABLE);
    }
    return false;
  }

  @Override
  public void mergeContext(AnalysisContext context) {
    synchronized (cacheLock) {
      for (Map.Entry<Source, SourceEntry> entry : ((AnalysisContextImpl) context).sourceMap.entrySet()) {
        Source newSource = entry.getKey();
        SourceEntry existingEntry = getSourceEntry(newSource);
        if (existingEntry == null) {
          // TODO(brianwilkerson) Decide whether we really need to copy the info.
          sourceMap.put(newSource, entry.getValue().getWritableCopy());
        } else {
          // TODO(brianwilkerson) Decide whether/how to merge the entries.
        }
      }
    }
  }

  @Override
  public CompilationUnit parseCompilationUnit(Source source) throws AnalysisException {
    synchronized (cacheLock) {
      accessed(source);
      DartEntry dartEntry = getDartEntry(source);
      if (dartEntry == null) {
        return null;
      }
      CompilationUnit unit = dartEntry.getAnyParsedCompilationUnit();
      if (unit == null) {
        unit = internalParseCompilationUnit((DartEntryImpl) dartEntry, source);
      }
      return unit;
    }
  }

  @Override
  public HtmlUnit parseHtmlUnit(Source source) throws AnalysisException {
    synchronized (cacheLock) {
      accessed(source);
      HtmlEntry htmlEntry = getHtmlEntry(source);
      if (htmlEntry == null) {
        return null;
      }
      HtmlUnit unit = htmlEntry.getValue(HtmlEntry.RESOLVED_UNIT);
      if (unit == null) {
        unit = htmlEntry.getValue(HtmlEntry.PARSED_UNIT);
        if (unit == null) {
          HtmlParseResult result = new HtmlParser(source).parse(scanHtml(source));
          unit = result.getHtmlUnit();
          ((HtmlEntryImpl) htmlEntry).setValue(
              SourceEntry.LINE_INFO,
              new LineInfo(result.getLineStarts()));
          ((HtmlEntryImpl) htmlEntry).setValue(HtmlEntry.PARSED_UNIT, unit);
          ((HtmlEntryImpl) htmlEntry).setValue(
              HtmlEntry.REFERENCED_LIBRARIES,
              getLibrarySources(source, unit));
        }
      }
      return unit;
    }
  }

  @Override
  public ChangeNotice[] performAnalysisTask() {
    synchronized (cacheLock) {
      if (!performSingleAnalysisTask() && pendingNotices.isEmpty()) {
        return null;
      }
      if (pendingNotices.isEmpty()) {
        return ChangeNoticeImpl.EMPTY_ARRAY;
      }
      ChangeNotice[] notices = pendingNotices.values().toArray(
          new ChangeNotice[pendingNotices.size()]);
      pendingNotices.clear();
      return notices;
    }
  }

  @Override
  public void recordLibraryElements(Map<Source, LibraryElement> elementMap) {
    Source htmlSource = sourceFactory.forUri("dart:html"); // was DartSdk.DART_HTML
    synchronized (cacheLock) {
      for (Map.Entry<Source, LibraryElement> entry : elementMap.entrySet()) {
        Source librarySource = entry.getKey();
        LibraryElement library = entry.getValue();
        //
        // Cache the element in the library's info.
        //
        DartEntryImpl dartEntry = (DartEntryImpl) getDartEntry(librarySource);
        if (dartEntry != null) {
          dartEntry.setValue(DartEntry.ELEMENT, library);
          dartEntry.setValue(DartEntry.IS_LAUNCHABLE, library.getEntryPoint() != null);
          dartEntry.setValue(
              DartEntry.IS_CLIENT,
              isClient(library, htmlSource, new HashSet<LibraryElement>()));
          ArrayList<Source> unitSources = new ArrayList<Source>();
          unitSources.add(librarySource);
          for (CompilationUnitElement part : library.getParts()) {
            Source partSource = part.getSource();
            unitSources.add(partSource);
          }
          dartEntry.setValue(
              DartEntry.INCLUDED_PARTS,
              unitSources.toArray(new Source[unitSources.size()]));
        }
      }
    }
  }

  @Override
  public void recordResolutionErrors(Source source, Source librarySource, AnalysisError[] errors,
      LineInfo lineInfo) {
    synchronized (cacheLock) {
      DartEntryImpl dartEntry = (DartEntryImpl) getDartEntry(source);
      if (dartEntry != null) {
        dartEntry.setValue(SourceEntry.LINE_INFO, lineInfo);
        dartEntry.setValue(DartEntry.RESOLUTION_ERRORS, librarySource, errors);
      }
      getNotice(source).setErrors(dartEntry.getAllErrors(), lineInfo);
    }
  }

  @Override
  public void recordResolvedCompilationUnit(Source source, Source librarySource,
      CompilationUnit unit) {
    synchronized (cacheLock) {
      DartEntryImpl dartEntry = (DartEntryImpl) getDartEntry(source);
      if (dartEntry != null) {
        dartEntry.setValue(DartEntry.RESOLVED_UNIT, librarySource, unit);
        dartEntry.setState(DartEntry.PARSED_UNIT, CacheState.FLUSHED);
        getNotice(source).setCompilationUnit(unit);
      }
    }
  }

  @Override
  public CompilationUnit resolveCompilationUnit(Source source, LibraryElement library)
      throws AnalysisException {
    if (library == null) {
      return null;
    }
    return resolveCompilationUnit(source, library.getSource());
  }

  @Override
  public CompilationUnit resolveCompilationUnit(Source unitSource, Source librarySource)
      throws AnalysisException {
    synchronized (cacheLock) {
      accessed(unitSource);
      DartEntry dartEntry = getDartEntry(unitSource);
      if (dartEntry == null) {
        return null;
      }
      CompilationUnit unit = dartEntry.getValue(DartEntry.RESOLVED_UNIT, librarySource);
      if (unit == null) {
        disableCacheRemoval();
        try {
          LibraryElement libraryElement = computeLibraryElement(librarySource);
          unit = dartEntry.getValue(DartEntry.RESOLVED_UNIT, librarySource);
          if (unit == null && libraryElement != null) {
            Source coreLibrarySource = libraryElement.getContext().getSourceFactory().forUri(
                DartSdk.DART_CORE);
            LibraryElement coreElement = computeLibraryElement(coreLibrarySource);
            TypeProvider typeProvider = new TypeProviderImpl(coreElement);
            CompilationUnit unitAST = computeResolvableCompilationUnit(unitSource);
            //
            // Resolve names in declarations.
            //
            new DeclarationResolver().resolve(unitAST, find(libraryElement, unitSource));
            //
            // Resolve the type names.
            //
            RecordingErrorListener errorListener = new RecordingErrorListener();
            TypeResolverVisitor typeResolverVisitor = new TypeResolverVisitor(
                libraryElement,
                unitSource,
                typeProvider,
                errorListener);
            unitAST.accept(typeResolverVisitor);
            //
            // Resolve the rest of the structure
            //
            ResolverVisitor resolverVisitor = new ResolverVisitor(
                libraryElement,
                unitSource,
                typeProvider,
                errorListener);
            unitAST.accept(resolverVisitor);
            //
            // Perform additional error checking.
            //
            ErrorReporter errorReporter = new ErrorReporter(errorListener, unitSource);
            ErrorVerifier errorVerifier = new ErrorVerifier(
                errorReporter,
                libraryElement,
                typeProvider);
            unitAST.accept(errorVerifier);

            ConstantVerifier constantVerifier = new ConstantVerifier(errorReporter);
            unitAST.accept(constantVerifier);
            //
            // Capture the results.
            //
            unitAST.setResolutionErrors(errorListener.getErrors());
            ((DartEntryImpl) dartEntry).setValue(DartEntry.RESOLVED_UNIT, librarySource, unitAST);
            unit = unitAST;
          }
        } finally {
          enableCacheRemoval();
        }
      }
      return unit;
    }
  }

  @Override
  public HtmlUnit resolveHtmlUnit(Source unitSource) throws AnalysisException {
    synchronized (cacheLock) {
      accessed(unitSource);
      HtmlEntry htmlEntry = getHtmlEntry(unitSource);
      if (htmlEntry == null) {
        return null;
      }
      HtmlUnit unit = htmlEntry.getValue(HtmlEntry.RESOLVED_UNIT);
      if (unit == null) {
        disableCacheRemoval();
        try {
          computeHtmlElement(unitSource);
          unit = htmlEntry.getValue(HtmlEntry.RESOLVED_UNIT);
          if (unit == null) {
            // There is currently no difference between the parsed and resolved forms of an HTML
            // unit. This code needs to change if resolution ever modifies the AST.
            unit = parseHtmlUnit(unitSource);
          }
        } finally {
          enableCacheRemoval();
        }
      }
      return unit;
    }
  }

  @Override
  public void setContents(Source source, String contents) {
    synchronized (cacheLock) {
      sourceFactory.setContents(source, contents);
      sourceChanged(source);
    }
  }

  @Override
  public void setSourceFactory(SourceFactory factory) {
    if (sourceFactory == factory) {
      return;
    } else if (factory.getContext() != null) {
      throw new IllegalStateException("Source factories cannot be shared between contexts");
    }
    synchronized (cacheLock) {
      if (sourceFactory != null) {
        sourceFactory.setContext(null);
      }
      factory.setContext(this);
      sourceFactory = factory;
      for (SourceEntry sourceEntry : sourceMap.values()) {
        if (sourceEntry instanceof HtmlEntry) {
          ((HtmlEntryImpl) sourceEntry).setState(HtmlEntry.RESOLVED_UNIT, CacheState.INVALID);
        } else if (sourceEntry instanceof DartEntry) {
          ((DartEntryImpl) sourceEntry).invalidateAllResolutionInformation();
        }
      }
    }
  }

  @Override
  public Iterable<Source> sourcesToResolve(Source[] changedSources) {
    List<Source> librarySources = new ArrayList<Source>();
    for (Source source : changedSources) {
      if (computeKindOf(source) == SourceKind.LIBRARY) {
        librarySources.add(source);
      }
    }
    return librarySources;
  }

  /**
   * Record that the given source was just accessed for some unspecified purpose.
   * <p>
   * Note: This method must only be invoked while we are synchronized on {@link #cacheLock}.
   * 
   * @param source the source that was accessed
   */
  private void accessed(Source source) {
    if (recentlyUsed.contains(source)) {
      recentlyUsed.remove(source);
      recentlyUsed.add(source);
      return;
    }
    if (cacheRemovalCount == 0 && recentlyUsed.size() >= MAX_CACHE_SIZE) {
      Source removedSource = recentlyUsed.remove(0);
      SourceEntry sourceEntry = sourceMap.get(removedSource);
      if (sourceEntry instanceof HtmlEntry) {
        ((HtmlEntryImpl) sourceEntry).setState(HtmlEntry.PARSED_UNIT, CacheState.FLUSHED);
        ((HtmlEntryImpl) sourceEntry).setState(HtmlEntry.RESOLVED_UNIT, CacheState.FLUSHED);
      } else if (sourceEntry instanceof DartEntry) {
        ((DartEntryImpl) sourceEntry).setState(DartEntry.PARSED_UNIT, CacheState.FLUSHED);
        for (Source librarySource : getLibrariesContaining(source)) {
          ((DartEntryImpl) sourceEntry).setState(
              DartEntry.RESOLVED_UNIT,
              librarySource,
              CacheState.FLUSHED);
        }
      }
    }
    recentlyUsed.add(source);
  }

  /**
   * Add all of the sources contained in the given source container to the given list of sources.
   * <p>
   * Note: This method must only be invoked while we are synchronized on {@link #cacheLock}.
   * 
   * @param sources the list to which sources are to be added
   * @param container the source container containing the sources to be added to the list
   */
  private void addSourcesInContainer(ArrayList<Source> sources, SourceContainer container) {
    for (Source source : sourceMap.keySet()) {
      if (container.contains(source)) {
        sources.add(source);
      }
    }
  }

  /**
   * Return {@code true} if the given array of sources contains the given source.
   * 
   * @param sources the sources being searched
   * @param targetSource the source being searched for
   * @return {@code true} if the given source is in the array
   */
  private boolean contains(Source[] sources, Source targetSource) {
    for (Source source : sources) {
      if (source.equals(targetSource)) {
        return true;
      }
    }
    return false;
  }

  /**
   * Return {@code true} if the given array of sources contains any of the given target sources.
   * 
   * @param sources the sources being searched
   * @param targetSources the sources being searched for
   * @return {@code true} if any of the given target sources are in the array
   */
  private boolean containsAny(Source[] sources, Source[] targetSources) {
    for (Source targetSource : targetSources) {
      if (contains(sources, targetSource)) {
        return true;
      }
    }
    return false;
  }

  /**
   * Create a source information object suitable for the given source. Return the source information
   * object that was created, or {@code null} if the source should not be tracked by this context.
   * 
   * @param source the source for which an information object is being created
   * @return the source information object that was created
   */
  private SourceEntry createSourceEntry(Source source) {
    String name = source.getShortName();
    if (AnalysisEngine.isHtmlFileName(name)) {
      HtmlEntry htmlEntry = new HtmlEntryImpl();
      sourceMap.put(source, htmlEntry);
      return htmlEntry;
    } else if (AnalysisEngine.isDartFileName(name)) {
      DartEntry dartEntry = new DartEntryImpl();
      sourceMap.put(source, dartEntry);
      return dartEntry;
    }
    return null;
  }

  /**
   * Disable flushing information from the cache until {@link #enableCacheRemoval()} has been
   * called.
   */
  private void disableCacheRemoval() {
    cacheRemovalCount++;
  }

  /**
   * Re-enable flushing information from the cache.
   */
  private void enableCacheRemoval() {
    if (cacheRemovalCount > 0) {
      cacheRemovalCount--;
    }
    if (cacheRemovalCount == 0) {
      while (recentlyUsed.size() >= MAX_CACHE_SIZE) {
        Source removedSource = recentlyUsed.remove(0);
        SourceEntry sourceEntry = sourceMap.get(removedSource);
        if (sourceEntry instanceof HtmlEntry) {
          ((HtmlEntryImpl) sourceEntry).setState(HtmlEntry.PARSED_UNIT, CacheState.FLUSHED);
          ((HtmlEntryImpl) sourceEntry).setState(HtmlEntry.RESOLVED_UNIT, CacheState.FLUSHED);
        } else if (sourceEntry instanceof DartEntry) {
          ((DartEntryImpl) sourceEntry).setState(DartEntry.PARSED_UNIT, CacheState.FLUSHED);
          for (Source librarySource : getLibrariesContaining(removedSource)) {
            ((DartEntryImpl) sourceEntry).setState(
                DartEntry.RESOLVED_UNIT,
                librarySource,
                CacheState.FLUSHED);
          }
        }
      }
    }
  }

  /**
   * Search the compilation units that are part of the given library and return the element
   * representing the compilation unit with the given source. Return {@code null} if there is no
   * such compilation unit.
   * 
   * @param libraryElement the element representing the library being searched through
   * @param unitSource the source for the compilation unit whose element is to be returned
   * @return the element representing the compilation unit
   */
  private CompilationUnitElement find(LibraryElement libraryElement, Source unitSource) {
    CompilationUnitElement element = libraryElement.getDefiningCompilationUnit();
    if (element.getSource().equals(unitSource)) {
      return element;
    }
    for (CompilationUnitElement partElement : libraryElement.getParts()) {
      if (partElement.getSource().equals(unitSource)) {
        return partElement;
      }
    }
    return null;
  }

  /**
   * Return the compilation unit information associated with the given source, or {@code null} if
   * the source is not known to this context. This method should be used to access the compilation
   * unit information rather than accessing the compilation unit map directly because sources in the
   * SDK are implicitly part of every analysis context and are therefore only added to the map when
   * first accessed.
   * <p>
   * <b>Note:</b> This method must only be invoked while we are synchronized on {@link #cacheLock}.
   * 
   * @param source the source for which information is being sought
   * @return the compilation unit information associated with the given source
   */
  private DartEntry getDartEntry(Source source) {
    SourceEntry sourceEntry = getSourceEntry(source);
    if (sourceEntry == null) {
      sourceEntry = new DartEntryImpl();
      sourceMap.put(source, sourceEntry);
      return (DartEntry) sourceEntry;
    } else if (sourceEntry instanceof DartEntry) {
      return (DartEntry) sourceEntry;
    }
    return null;
  }

  /**
   * Return the HTML unit information associated with the given source, or {@code null} if the
   * source is not known to this context. This method should be used to access the HTML unit
   * information rather than accessing the HTML unit map directly because sources in the SDK are
   * implicitly part of every analysis context and are therefore only added to the map when first
   * accessed.
   * <p>
   * <b>Note:</b> This method must only be invoked while we are synchronized on {@link #cacheLock}.
   * 
   * @param source the source for which information is being sought
   * @return the HTML unit information associated with the given source
   */
  private HtmlEntry getHtmlEntry(Source source) {
    SourceEntry sourceEntry = getSourceEntry(source);
    if (sourceEntry == null) {
      sourceEntry = new HtmlEntryImpl();
      sourceMap.put(source, sourceEntry);
      return (HtmlEntry) sourceEntry;
    } else if (sourceEntry instanceof HtmlEntry) {
      return (HtmlEntry) sourceEntry;
    }
    return null;
  }

  /**
   * Return the sources of libraries that are referenced in the specified HTML file.
   * 
   * @param htmlSource the source of the HTML file being analyzed
   * @param htmlUnit the AST for the HTML file being analyzed
   * @return the sources of libraries that are referenced in the HTML file
   */
  private Source[] getLibrarySources(final Source htmlSource, HtmlUnit htmlUnit) {
    final ArrayList<Source> libraries = new ArrayList<Source>();
    htmlUnit.accept(new RecursiveXmlVisitor<Void>() {
      @Override
      public Void visitXmlTagNode(XmlTagNode node) {
        if (node.getTag().getLexeme().equalsIgnoreCase(TAG_SCRIPT)) {
          for (XmlAttributeNode attribute : node.getAttributes()) {
            if (attribute.getName().getLexeme().equalsIgnoreCase(ATTRIBUTE_SRC)) {
              try {
                URI uri = new URI(null, null, attribute.getText(), null);
                String fileName = uri.getPath();
                if (AnalysisEngine.isDartFileName(fileName)) {
                  Source librarySource = sourceFactory.resolveUri(htmlSource, fileName);
                  if (librarySource.exists()) {
                    libraries.add(librarySource);
                  }
                }
              } catch (Exception exception) {
                AnalysisEngine.getInstance().getLogger().logError(
                    "Invalid URL ('" + attribute.getText() + "') in script tag in '"
                        + htmlSource.getFullName() + "'",
                    exception);
              }
            }
          }
        }
        return super.visitXmlTagNode(node);
      }
    });
    if (libraries.isEmpty()) {
      return Source.EMPTY_ARRAY;
    }
    return libraries.toArray(new Source[libraries.size()]);
  }

  /**
   * Return a change notice for the given source, creating one if one does not already exist.
   * 
   * @param source the source for which changes are being reported
   * @return a change notice for the given source
   */
  private ChangeNoticeImpl getNotice(Source source) {
    ChangeNoticeImpl notice = pendingNotices.get(source);
    if (notice == null) {
      notice = new ChangeNoticeImpl(source);
      pendingNotices.put(source, notice);
    }
    return notice;
  }

  /**
   * Return the source information associated with the given source, or {@code null} if the source
   * is not known to this context. This method should be used to access the source information
   * rather than accessing the source map directly because sources in the SDK are implicitly part of
   * every analysis context and are therefore only added to the map when first accessed.
   * <p>
   * <b>Note:</b> This method must only be invoked while we are synchronized on {@link #cacheLock}.
   * 
   * @param source the source for which information is being sought
   * @return the source information associated with the given source
   */
  private SourceEntry getSourceEntry(Source source) {
    SourceEntry sourceEntry = sourceMap.get(source);
    if (sourceEntry == null) {
      sourceEntry = createSourceEntry(source);
    }
    return sourceEntry;
  }

  /**
   * Return an array containing all of the sources known to this context that have the given kind.
   * 
   * @param kind the kind of sources to be returned
   * @return all of the sources known to this context that have the given kind
   */
  private Source[] getSources(SourceKind kind) {
    ArrayList<Source> sources = new ArrayList<Source>();
    synchronized (cacheLock) {
      for (Map.Entry<Source, SourceEntry> entry : sourceMap.entrySet()) {
        if (entry.getValue().getKind() == kind) {
          sources.add(entry.getKey());
        }
      }
    }
    return sources.toArray(new Source[sources.size()]);
  }

  /**
   * Return {@code true} if the given compilation unit has a part-of directive but no library
   * directive.
   * 
   * @param unit the compilation unit being tested
   * @return {@code true} if the compilation unit has a part-of directive
   */
  private boolean hasPartOfDirective(CompilationUnit unit) {
    boolean hasPartOf = false;
    for (Directive directive : unit.getDirectives()) {
      if (directive instanceof PartOfDirective) {
        hasPartOf = true;
      } else if (directive instanceof LibraryDirective) {
        return false;
      }
    }
    return hasPartOf;
  }

  /**
   * Compute the kind of the given source. This method should only be invoked when the kind is not
   * already known.
   * 
   * @param source the source for which a kind is to be computed
   * @return the new source info that was created to represent the source
   */
  private DartEntry internalComputeKindOf(Source source) {
    try {
      accessed(source);
      RecordingErrorListener errorListener = new RecordingErrorListener();
      ScanResult scanResult = internalScan(source, errorListener);
      Parser parser = new Parser(source, errorListener);
      CompilationUnit unit = parser.parseCompilationUnit(scanResult.token);
      LineInfo lineInfo = new LineInfo(scanResult.lineStarts);
      AnalysisError[] errors = errorListener.getErrors(source);
      unit.setParsingErrors(errors);
      unit.setLineInfo(lineInfo);

      DartEntryImpl dartEntry = (DartEntryImpl) sourceMap.get(source);
      if (hasPartOfDirective(unit)) {
        dartEntry.setValue(DartEntry.SOURCE_KIND, SourceKind.PART);
      } else {
        dartEntry.setValue(DartEntry.SOURCE_KIND, SourceKind.LIBRARY);
      }
      dartEntry.setValue(SourceEntry.LINE_INFO, lineInfo);
      dartEntry.setValue(DartEntry.PARSED_UNIT, unit);
      dartEntry.setValue(DartEntry.PARSE_ERRORS, errors);
      return dartEntry;
    } catch (AnalysisException exception) {
      DartEntryImpl dartEntry = (DartEntryImpl) sourceMap.get(source);
      dartEntry.setState(DartEntry.SOURCE_KIND, CacheState.ERROR);
      dartEntry.setState(SourceEntry.LINE_INFO, CacheState.ERROR);
      dartEntry.setState(DartEntry.PARSED_UNIT, CacheState.ERROR);
      dartEntry.setState(DartEntry.PARSE_ERRORS, CacheState.ERROR);
      return dartEntry;
    }
  }

  private CompilationUnit internalParseCompilationUnit(DartEntryImpl dartEntry, Source source)
      throws AnalysisException {
    accessed(source);
    RecordingErrorListener errorListener = new RecordingErrorListener();
    ScanResult scanResult = internalScan(source, errorListener);
    Parser parser = new Parser(source, errorListener);
    CompilationUnit unit = parser.parseCompilationUnit(scanResult.token);
    LineInfo lineInfo = new LineInfo(scanResult.lineStarts);
    AnalysisError[] errors = errorListener.getErrors(source);
    unit.setParsingErrors(errors);
    unit.setLineInfo(lineInfo);
    if (dartEntry.getState(DartEntry.SOURCE_KIND) == CacheState.INVALID) {
      if (hasPartOfDirective(unit)) {
        dartEntry.setValue(DartEntry.SOURCE_KIND, SourceKind.PART);
      } else {
        dartEntry.setValue(DartEntry.SOURCE_KIND, SourceKind.LIBRARY);
      }
    }
    dartEntry.setValue(SourceEntry.LINE_INFO, lineInfo);
    dartEntry.setValue(DartEntry.PARSED_UNIT, unit);
    dartEntry.setValue(DartEntry.PARSE_ERRORS, errors);
    // TODO(brianwilkerson) Find out whether clients want notification when part of the errors are
    // available.
//    ChangeNoticeImpl notice = getNotice(source);
//    if (notice.getErrors() == null) {
//      notice.setErrors(errors, lineInfo);
//    }
    return unit;
  }

  private ScanResult internalScan(final Source source, final AnalysisErrorListener errorListener)
      throws AnalysisException {
    final ScanResult result = new ScanResult();
    Source.ContentReceiver receiver = new Source.ContentReceiver() {
      @Override
      public void accept(CharBuffer contents, long modificationTime) {
        CharBufferScanner scanner = new CharBufferScanner(source, contents, errorListener);
        result.modificationTime = modificationTime;
        result.token = scanner.tokenize();
        result.lineStarts = scanner.getLineStarts();
      }

      @Override
      public void accept(String contents, long modificationTime) {
        StringScanner scanner = new StringScanner(source, contents, errorListener);
        result.modificationTime = modificationTime;
        result.token = scanner.tokenize();
        result.lineStarts = scanner.getLineStarts();
      }
    };
    try {
      source.getContents(receiver);
    } catch (Exception exception) {
      throw new AnalysisException(exception);
    }
    return result;
  }

  /**
   * In response to a change to at least one of the compilation units in the given library,
   * invalidate any results that are dependent on the result of resolving that library.
   * 
   * @param librarySource the source of the library being invalidated
   * @param libraryEntry the cache entry for the library being invalidated
   */
  private void invalidateLibraryResolution(Source librarySource, DartEntryImpl libraryEntry) {
    // TODO(brianwilkerson) This could be optimized. There's no need to flush all of these caches if
    // the public namespace hasn't changed, which will be a fairly common case.
    if (libraryEntry != null) {
      for (Source unitSource : libraryEntry.getValue(DartEntry.INCLUDED_PARTS)) {
        DartEntryImpl partEntry = (DartEntryImpl) getDartEntry(unitSource);
        partEntry.invalidateAllResolutionInformation();
      }
      libraryEntry.invalidateAllResolutionInformation();
      libraryEntry.setState(DartEntry.INCLUDED_PARTS, CacheState.INVALID);
    }
  }

  /**
   * Return {@code true} if this library is, or depends on, dart:html.
   * 
   * @param library the library being tested
   * @param visitedLibraries a collection of the libraries that have been visited, used to prevent
   *          infinite recursion
   * @return {@code true} if this library is, or depends on, dart:html
   */
  private boolean isClient(LibraryElement library, Source htmlSource,
      HashSet<LibraryElement> visitedLibraries) {
    if (visitedLibraries.contains(library)) {
      return false;
    }
    if (library.getSource().equals(htmlSource)) {
      return true;
    }
    visitedLibraries.add(library);
    for (LibraryElement imported : library.getImportedLibraries()) {
      if (isClient(imported, htmlSource, visitedLibraries)) {
        return true;
      }
    }
    for (LibraryElement exported : library.getExportedLibraries()) {
      if (isClient(exported, htmlSource, visitedLibraries)) {
        return true;
      }
    }
    return false;
  }

  /**
   * Perform a single analysis task.
   * <p>
   * <b>Note:</b> This method must only be invoked while we are synchronized on {@link #cacheLock}.
   * 
   * @return {@code true} if work was done, implying that there might be more work to be done
   */
  private boolean performSingleAnalysisTask() {
    //
    // Look for a source that needs to be parsed.
    //
    for (Map.Entry<Source, SourceEntry> entry : sourceMap.entrySet()) {
      SourceEntry sourceEntry = entry.getValue();
      if (sourceEntry instanceof DartEntry) {
        DartEntry dartEntry = (DartEntry) sourceEntry;
        CacheState parsedUnitState = dartEntry.getState(DartEntry.PARSED_UNIT);
        if (parsedUnitState == CacheState.INVALID) {
          try {
            parseCompilationUnit(entry.getKey());
          } catch (AnalysisException exception) {
            ((DartEntryImpl) dartEntry).setState(DartEntry.PARSED_UNIT, CacheState.ERROR);
            AnalysisEngine.getInstance().getLogger().logError(
                "Could not parse " + entry.getKey().getFullName(),
                exception);
          }
          return true;
        }
      } else if (sourceEntry instanceof HtmlEntry) {
        HtmlEntry htmlEntry = (HtmlEntry) sourceEntry;
        CacheState parsedUnitState = htmlEntry.getState(HtmlEntry.PARSED_UNIT);
        if (parsedUnitState == CacheState.INVALID) {
          try {
            parseHtmlUnit(entry.getKey());
          } catch (AnalysisException exception) {
            ((HtmlEntryImpl) htmlEntry).setState(HtmlEntry.PARSED_UNIT, CacheState.ERROR);
            AnalysisEngine.getInstance().getLogger().logError(
                "Could not parse " + entry.getKey().getFullName(),
                exception);
          }
          return true;
        }
      }
    }
    //
    // Look for a library that needs to be resolved.
    //
    for (Map.Entry<Source, SourceEntry> entry : sourceMap.entrySet()) {
      SourceEntry sourceEntry = entry.getValue();
      if (sourceEntry instanceof DartEntry && sourceEntry.getKind() == SourceKind.LIBRARY) {
        DartEntry dartEntry = (DartEntry) sourceEntry;
        CacheState elementState = dartEntry.getState(DartEntry.ELEMENT);
        if (elementState == CacheState.INVALID) {
          try {
            computeLibraryElement(entry.getKey());
          } catch (AnalysisException exception) {
            ((DartEntryImpl) dartEntry).setState(DartEntry.ELEMENT, CacheState.ERROR);
            AnalysisEngine.getInstance().getLogger().logError(
                "Could not resolve " + entry.getKey().getFullName(),
                exception);
          }
          return true;
        }
      } else if (sourceEntry instanceof HtmlEntry) {
        HtmlEntry htmlEntry = (HtmlEntry) sourceEntry;
        CacheState resolvedUnitState = htmlEntry.getState(HtmlEntry.RESOLVED_UNIT);
        if (resolvedUnitState == CacheState.INVALID) {
          try {
            resolveHtmlUnit(entry.getKey());
          } catch (AnalysisException exception) {
            ((HtmlEntryImpl) htmlEntry).setState(HtmlEntry.RESOLVED_UNIT, CacheState.ERROR);
            AnalysisEngine.getInstance().getLogger().logError(
                "Could not resolve " + entry.getKey().getFullName(),
                exception);
          }
          return true;
        }
      }
    }
    return false;
  }

  private HtmlScanResult scanHtml(Source source) throws AnalysisException {
    HtmlScanner scanner = new HtmlScanner(source);
    try {
      source.getContents(scanner);
    } catch (Exception exception) {
      throw new AnalysisException(exception);
    }
    return scanner.getResult();
  }

  /**
   * Create an entry for the newly added source. Return {@code true} if the new source is a Dart
   * file.
   * <p>
   * <b>Note:</b> This method must only be invoked while we are synchronized on {@link #cacheLock}.
   * 
   * @param source the source that has been added
   * @return {@code true} if the new source is a Dart file
   */
  private boolean sourceAvailable(Source source) {
    SourceEntry sourceEntry = sourceMap.get(source);
    if (sourceEntry == null) {
      sourceEntry = createSourceEntry(source);
    }
    return sourceEntry instanceof DartEntry;
  }

  /**
   * <b>Note:</b> This method must only be invoked while we are synchronized on {@link #cacheLock}.
   * 
   * @param source the source that has been changed
   */
  private void sourceChanged(Source source) {
    SourceEntry sourceEntry = sourceMap.get(source);
    if (sourceEntry instanceof HtmlEntry) {
      HtmlEntryImpl htmlEntry = (HtmlEntryImpl) sourceEntry;
      htmlEntry.setState(HtmlEntry.ELEMENT, CacheState.INVALID);
      htmlEntry.setState(HtmlEntry.LINE_INFO, CacheState.INVALID);
      htmlEntry.setState(HtmlEntry.PARSED_UNIT, CacheState.INVALID);
      htmlEntry.setState(HtmlEntry.REFERENCED_LIBRARIES, CacheState.INVALID);
      htmlEntry.setState(HtmlEntry.RESOLVED_UNIT, CacheState.INVALID);
    } else if (sourceEntry instanceof DartEntry) {
      DartEntryImpl dartEntry = (DartEntryImpl) sourceEntry;
      Source[] containingLibraries = getLibrariesContaining(source);
      invalidateLibraryResolution(source, dartEntry);
      dartEntry.setState(DartEntry.INCLUDED_PARTS, CacheState.INVALID);
      dartEntry.setState(SourceEntry.LINE_INFO, CacheState.INVALID);
      dartEntry.setState(DartEntry.PARSE_ERRORS, CacheState.INVALID);
      dartEntry.setState(DartEntry.PARSED_UNIT, CacheState.INVALID);
      dartEntry.setState(DartEntry.SOURCE_KIND, CacheState.INVALID);
      for (Source librarySource : containingLibraries) {
        DartEntryImpl libraryEntry = (DartEntryImpl) getDartEntry(librarySource);
        invalidateLibraryResolution(librarySource, libraryEntry);
      }
    }
  }

  /**
   * <b>Note:</b> This method must only be invoked while we are synchronized on {@link #cacheLock}.
   * 
   * @param source the source that has been deleted
   */
  private void sourceRemoved(Source source) {
    // TODO(brianwilkerson) Determine whether the source should be removed (that is, whether
    // there are no additional dependencies on the source), and if so remove all information
    // about the source.
    DartEntry dartEntry = getDartEntry(source);
    if (dartEntry != null) {
      for (Source librarySource : getLibrariesContaining(source)) {
        DartEntryImpl libraryEntry = (DartEntryImpl) getDartEntry(librarySource);
        invalidateLibraryResolution(librarySource, libraryEntry);
      }
    }
    sourceMap.remove(source);
  }
}
