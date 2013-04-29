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
package com.google.dart.tools.core.utilities.compiler;

import com.google.common.collect.MapMaker;
import com.google.common.collect.Sets;
import com.google.dart.compiler.CommandLineOptions.CompilerOptions;
import com.google.dart.compiler.CompilerConfiguration;
import com.google.dart.compiler.DartArtifactProvider;
import com.google.dart.compiler.DartCompilationError;
import com.google.dart.compiler.DartCompiler;
import com.google.dart.compiler.DartCompiler.SelectiveCache;
import com.google.dart.compiler.DartCompilerListener;
import com.google.dart.compiler.DartSource;
import com.google.dart.compiler.DefaultCompilerConfiguration;
import com.google.dart.compiler.LibrarySource;
import com.google.dart.compiler.PackageLibraryManager;
import com.google.dart.compiler.Source;
import com.google.dart.compiler.SourceDelta;
import com.google.dart.compiler.ast.DartNode;
import com.google.dart.compiler.ast.DartUnit;
import com.google.dart.compiler.ast.LibraryUnit;
import com.google.dart.compiler.parser.DartParser;
import com.google.dart.compiler.resolver.LibraryElement;
import com.google.dart.compiler.util.DartSourceString;
import com.google.dart.engine.utilities.instrumentation.Instrumentation;
import com.google.dart.engine.utilities.instrumentation.InstrumentationBuilder;
import com.google.dart.tools.core.DartCore;
import com.google.dart.tools.core.analysis.AnalysisServer;
import com.google.dart.tools.core.internal.builder.LocalArtifactProvider;
import com.google.dart.tools.core.internal.builder.RootArtifactProvider;
import com.google.dart.tools.core.internal.model.CompilationUnitImpl;
import com.google.dart.tools.core.internal.model.DartLibraryImpl;
import com.google.dart.tools.core.internal.model.ExternalCompilationUnitImpl;
import com.google.dart.tools.core.internal.model.PackageLibraryManagerProvider;
import com.google.dart.tools.core.model.CompilationUnit;
import com.google.dart.tools.core.model.DartModelException;
import com.google.dart.tools.core.model.DartSdkManager;
import com.google.dart.tools.core.utilities.net.URIUtilities;

import org.eclipse.core.filesystem.URIUtil;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;

import java.io.File;
import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * The class <code>DartCompilerUtilities</code> defines utility methods for parsing, resolving, and
 * compiling Dart source, including compilation units, libraries, and applications.
 */
public class DartCompilerUtilities {

  /**
   * The abstract class <code>CompilerRunner</code> defines behavior common to classes used to
   * safely invoke the parser, record compilation errors, and capture any parser exception.
   */
  private static abstract class CompilerRunner implements DartCompilerListener {
    private final Collection<DartCompilationError> parseErrors;
    protected Throwable exception;

    protected CompilerRunner(Collection<DartCompilationError> parseErrors) {
      this.parseErrors = parseErrors;
    }

    public void handleException(Throwable exception) {
      this.exception = exception;
    }

    @Override
    public void onError(DartCompilationError event) {
      if (parseErrors != null) {
        parseErrors.add(event);
      }
    }

    public final void runSafe() {
      try {
        run();
      } catch (Exception e) {
        // Don't log here... let caller determine what to do
        handleException(e);
      } catch (LinkageError e) {
        DartCore.logError(e);
        handleException(e);
      } catch (AssertionError e) {
        DartCore.logError(e);
        handleException(e);
      }
    }

    @Override
    public void unitAboutToCompile(DartSource source, boolean diet) {
    }

    @Override
    public void unitCompiled(DartUnit unit) {
    }

    /**
     * Do not call this method directly. Call {@link #runSafe()} which in turn calls this method and
     * redirects any exceptions to {@link #handleException(Throwable)}. Subclasses should implement
     * this method to perform the actual operation.
     */
    protected abstract void run() throws Exception;
  }

  /**
   * An in-memory {@link DartSource} referenced by {@link LibraryWithSuppliedSources}
   */
  private static class DartURIStringSource implements DartSource {
    private final LibrarySource library;
    private final URI uri;
    private final String relPath;
    private final String source;
    private final long lastModified = System.currentTimeMillis();

    private DartURIStringSource(LibrarySource library, URI uri, String relPath, String source) {
      this.library = library;
      this.uri = uri;
      this.relPath = relPath;
      this.source = source;
    }

    @Override
    public boolean exists() {
      return true;
    }

    @Override
    public long getLastModified() {
      return lastModified;
    }

    @Override
    public LibrarySource getLibrary() {
      return library;
    }

    @Override
    public String getName() {
      return uri.toString();
    }

    @Override
    public String getRelativePath() {
      return relPath;
    }

    @Override
    public Reader getSourceReader() throws IOException {
      return new StringReader(source);
    }

    @Override
    public String getUniqueIdentifier() {
      return uri.toString();
    }

    @Override
    public URI getUri() {
      return uri;
    }
  }

  /**
   * Internal class for safely calling
   * {@link DartCompiler#analyzeDelta(SourceDelta, LibraryElement, LibraryElement, DartNode, int, int, CompilerConfiguration, DartCompilerListener)}
   * , recording compilation errors, and capturing any parser exception.
   * <p>
   * TODO Unify with ResolverRunnable - compilerConfig could be shared
   */
  private static final class DeltaAnalysisRunnable extends CompilerRunner {
    private int completionLocation;
    private DartNode completionNode;
    private LibraryWithSuppliedSources librarySource;
    private DartUnit parsedUnit;
    private DartSourceString source;
    private DartNode analyzedNode;
    private URI unitUri;

    DeltaAnalysisRunnable(LibrarySource librarySource, URI unitUri,
        Map<URI, String> suppliedSources, DartUnit suppliedUnit, DartNode completionNode,
        int completionLocation, Collection<DartCompilationError> parseErrors) {
      super(parseErrors);
      librarySource.getClass(); // quick null check
      unitUri.getClass(); // quick null check
      suppliedSources.getClass(); // quick null check
      suppliedUnit.getClass(); // quick null check
      completionNode.getClass(); // quick null check
      parseErrors.getClass(); // quick null check
      this.librarySource = new LibraryWithSuppliedSources(librarySource, suppliedSources);
      this.parsedUnit = suppliedUnit;
      this.completionNode = completionNode;
      this.completionLocation = completionLocation;
      String sourceString = suppliedSources.get(unitUri);
      this.source = new DartSourceString(unitUri.getPath(), sourceString);
      this.unitUri = unitUri;
    }

    @Override
    public void run() throws Exception {
      final PackageLibraryManager libraryManager = PackageLibraryManagerProvider.getPackageLibraryManager();
      final LibraryElement enclosingLibrary = cachedLibraries.get(librarySource.wrappedSource).getElement();

      // Try to find the core library in the enclosing set of libraries, otherwise the typeAnalyzer
      // will be void of core types.
      LibraryUnit coreUnit;
      // All calls to DartC must be synchronized
      synchronized (compilerLock) {
        coreUnit = DartCompiler.getCoreLib(enclosingLibrary.getLibraryUnit());
      }
      if (coreUnit == null) {
        throw new RuntimeException("Unable to locate core library");
      }
      LibraryElement coreLibrary = coreUnit.getElement();

      SourceDelta delta = new SourceDelta() {

        @Override
        public DartSource getSourceAfter() {
          return source;
        }

        @Override
        public Source getSourceBefore() {
          for (DartUnit u : enclosingLibrary.getLibraryUnit().getUnits()) {
            Source unitSource = u.getSourceInfo().getSource();
            if (unitSource.getUri().equals(unitUri)) {
              return unitSource;
            }
          }
          return null;
        }

        @Override
        public DartUnit getUnitAfter() {
          return parsedUnit;
        }
      };
      final CompilerConfiguration config = new DefaultCompilerConfiguration(
          DartCompilerUtilities.COMPILER_OPTIONS,
          libraryManager) {

        @Override
        public boolean incremental() {
          return true;
        }

        @Override
        public boolean resolveDespiteParseErrors() {
          return true;
        }

        @Override
        public boolean typeErrorsAreFatal() {
          return false;
        }

        @Override
        public boolean warningsAreFatal() {
          return false;
        }
      };
      // All calls to DartC must be synchronized
      synchronized (compilerLock) {
        analyzedNode = DartCompiler.analyzeDelta(
            delta,
            enclosingLibrary,
            coreLibrary,
            completionNode,
            completionLocation,
            0,
            config,
            this);
      }
    }
  }

  /**
   * An in-memory {@link LibrarySource} wrapping an underlying library and containing
   * {@link DartURIStringSource} to represent in memory changes to on disk sources
   */
  private static class LibraryWithSuppliedSources implements LibrarySource {
    private final LibrarySource wrappedSource;
    private final PackageLibraryManager libraryManager = PackageLibraryManagerProvider.getPackageLibraryManager();
    private final Map<URI, String> suppliedSources;

    private LibraryWithSuppliedSources(LibrarySource wrappedSource, Map<URI, String> suppliedSources) {
      this.wrappedSource = wrappedSource;
      this.suppliedSources = suppliedSources;
    }

    @Override
    public boolean exists() {
      return wrappedSource.exists();
    }

    @Override
    public LibrarySource getImportFor(String relPath) throws IOException {
      try {
        return wrappedSource.getImportFor(relPath);
      } catch (Exception exception) {
        DartCore.logInformation("Could not find import: '" + relPath + "'", exception);
        return null;
      }
    }

    @Override
    public long getLastModified() {
      return wrappedSource.getLastModified();
    }

    @Override
    public String getName() {
      return wrappedSource.getName();
    }

    @Override
    public DartSource getSourceFor(String relPath) {
      URI uri;
      try {
        uri = wrappedSource.getUri().resolve(new URI(null, null, relPath, null));
      } catch (URISyntaxException e) {
        uri = null;
      }
      if (uri != null) {
        for (URI key : suppliedSources.keySet()) {
          if (equalUris(libraryManager, key, uri)) {
            String source = suppliedSources.get(key);
            return new DartURIStringSource(this, uri, relPath, source);
          }
        }
      }
      return wrappedSource.getSourceFor(relPath);
    }

    @Override
    public Reader getSourceReader() throws IOException {
      return wrappedSource.getSourceReader();
    }

    @Override
    public String getUniqueIdentifier() {
      return wrappedSource.getUniqueIdentifier();
    }

    @Override
    public URI getUri() {
      return wrappedSource.getUri();
    }
  }

  /**
   * Internal class for safely calling the parser, and capturing any parser exception.
   */
  private static final class ParserRunnable extends CompilerRunner {
    private final DartSource sourceRef;
    private final String source;
//    private boolean preserveComments;
    private DartUnit result;

    public ParserRunnable(DartSource sourceRef, String source, boolean preserveComments,
        Collection<DartCompilationError> parseErrors) {
      super(parseErrors);
      this.sourceRef = sourceRef;
      this.source = source;
//      this.preserveComments = preserveComments;
    }

    @Override
    public void run() throws Exception {
      result = secureParseUnit(createParser(), sourceRef);
    }

    private DartParser createParser() {
      return new DartParser(sourceRef, source, false, Sets.<String> newHashSet(), this, null);
    }
  }

  /**
   * Internal class for safely calling the
   * {@link DartCompiler#analyzeLibrary(LibrarySource, Map, CompilerConfiguration, DartArtifactProvider, DartCompilerListener)}
   * , recording compilation errors, and capturing any parser exception.
   */
  private static final class ResolverRunnable extends CompilerRunner {
    private LibrarySource librarySource;
    private URI unitUri;
    private boolean forceFullAST;
    private LibraryUnit libraryResult;
    private DartUnit unitResult;
    private Map<URI, DartUnit> parsedUnits;

    ResolverRunnable(LibrarySource librarySource, Map<URI, DartUnit> suppliedUnits,
        boolean forceFullAST, Collection<DartCompilationError> parseErrors) {
      this(librarySource, null, null, suppliedUnits, forceFullAST, parseErrors);
    }

    ResolverRunnable(LibrarySource librarySource, URI unitUri, Map<URI, String> suppliedSources,
        boolean forceFullAST, Collection<DartCompilationError> parseErrors) {
      this(librarySource, unitUri, suppliedSources, null, forceFullAST, parseErrors);
    }

    private ResolverRunnable(LibrarySource librarySource, URI unitUri,
        Map<URI, String> suppliedSources, Map<URI, DartUnit> suppliedUnits, boolean forceFullAST,
        Collection<DartCompilationError> parseErrors) {
      super(parseErrors);
      if (suppliedSources != null) {
        this.librarySource = new LibraryWithSuppliedSources(librarySource, suppliedSources);
      } else {
        this.librarySource = librarySource;
      }
      this.unitUri = unitUri;
      this.parsedUnits = suppliedUnits;
      this.forceFullAST = forceFullAST;
    }

    @Override
    public void run() throws Exception {
      final PackageLibraryManager libraryManager = PackageLibraryManagerProvider.getPackageLibraryManager();
      final CompilerConfiguration config = new DefaultCompilerConfiguration(
          DartCompilerUtilities.COMPILER_OPTIONS,
          libraryManager) {
        @Override
        public boolean incremental() {
          return true;
        }

        @Override
        public boolean resolveDespiteParseErrors() {
          return true;
        }
      };
      DartArtifactProvider provider = new LocalArtifactProvider(RootArtifactProvider.getInstance()) {
        @Override
        protected boolean isOutOfDateInParent(Source source, Source base, String extension) {
          if (forceFullAST || equalUris(libraryManager, unitUri, source.getUri())) {
            return true;
          }
          if (parsedUnits != null && parsedUnits.containsKey(source.getUri())) {
            return true;
          }
          return super.isOutOfDateInParent(source, base, extension);
        }
      };
      libraryResult = secureAnalyzeLibrary(librarySource, parsedUnits, config, provider, this);
      if (libraryResult != null && unitUri != null) {
        for (DartUnit unit : libraryResult.getUnits()) {
          Source source = unit.getSourceInfo().getSource();
          if (source != null) {
            if (equalUris(libraryManager, unitUri, source.getUri())) {
              unitResult = unit;
              return;
            }
          }
        }
      }
    }
  }

  public static final CompilerOptions COMPILER_OPTIONS = new CompilerOptions() {
    @Override
    public boolean reportNoMemberWhenHasInterceptor() {
      return false;
    }

    @Override
    public boolean typeChecksForInferredTypes() {
      return DartCore.getPlugin().getPrefs().getBoolean(
          DartCore.TYPE_CHECKS_FOR_INFERRED_TYPES,
          true);
    }
  };

  /**
   * Synchronize against this field when calling the compiler and passing an artifact provider
   */
  private static final Object compilerLock = new Object();

  private static Map<LibrarySource, LibraryUnit> cachedLibraries = new MapMaker().softValues().makeMap();

  public static DartNode analyzeDelta(LibrarySource library, String sourceString,
      DartUnit suppliedUnit, DartNode completionNode, int completionLocation,
      final Collection<DartCompilationError> parseErrors) throws DartModelException {

    checkUse();

    InstrumentationBuilder instrumentation = Instrumentation.builder("DartCompilerUtilities.resolveUnit");
    try {

      if (cachedLibraries.get(library) == null) {
        Collection<DartUnit> parsedUnits = new ArrayList<DartUnit>();
        parsedUnits.add(suppliedUnit);
        LibraryUnit resolvedLib = resolveLibrary(library, parsedUnits, parseErrors);
        synchronized (cachedLibraries) {
          LibraryUnit newLib = cachedLibraries.get(library);
          if (newLib == null) {
            cachedLibraries.put(library, resolvedLib);
          }
        }

        instrumentation.metric("Cached", "false");
        instrumentation.metric("librarySource.LastModified", library.getLastModified());
        instrumentation.metric("ParsedUnits", parsedUnits.size());
        instrumentation.metric("ParseErrors", parseErrors != null ? parseErrors.size() : 0);
        instrumentation.metric("sourceString-length", sourceString.length());

        instrumentation.data("analyzeDelta.Name", library.getName());
        instrumentation.data("sourceString", sourceString);

        return completionNode;
      }
      DartSource src = (DartSource) suppliedUnit.getSourceInfo().getSource();
      URI unitUri = src.getUri();
      Map<URI, String> suppliedSources = new HashMap<URI, String>();
      suppliedSources.put(unitUri, sourceString);
      DeltaAnalysisRunnable runnable = new DeltaAnalysisRunnable(
          library,
          unitUri,
          suppliedSources,
          suppliedUnit,
          completionNode,
          completionLocation,
          parseErrors);
      runnable.runSafe();

      instrumentation.metric("librarySource.LastModified", library.getLastModified());
      instrumentation.metric("ParseErrors", parseErrors != null ? parseErrors.size() : 0);
      instrumentation.metric("sourceString-length", sourceString.length());

      instrumentation.data("analyzeDelta.Name", library.getName());
      instrumentation.data("sourceString", sourceString);

      if (runnable.exception != null) {
        throw new DartModelException(new CoreException(new Status(
            IStatus.ERROR,
            DartCore.PLUGIN_ID,
            "Failed to parse " + library.getName(),
            runnable.exception)));

      }
      return runnable.analyzedNode;

    } finally {
      instrumentation.log();

    }
  }

  /**
   * Parse the specified source. Any exceptions thrown by the {@link DartParser} will be logged and
   * a {@link DartModelException} thrown.
   * 
   * @param sourceRef the Dart source being parsed
   * @param source the source to be parsed (not <code>null</code>)
   * @param preserveComments <code>true</code> if comments are to be preserved
   * @param parseErrors a collection to which parse errors are appended or <code>null</code> if
   *          parse errors should be ignored
   * @return the parse result
   */
  public static DartUnit parseSource(DartSource sourceRef, String source, boolean preserveComments,
      Collection<DartCompilationError> parseErrors) throws DartModelException {

    checkUse();

    InstrumentationBuilder instrumentation = Instrumentation.builder("DartCompilerUtilities.parseSource");
    try {

      ParserRunnable runnable = new ParserRunnable(sourceRef, source, preserveComments, parseErrors);
      runnable.runSafe();

      instrumentation.data("sourceRef.Name", sourceRef.getName());
      instrumentation.data("source", source);
      instrumentation.metric("ParseError", parseErrors != null ? parseErrors.size() : 0);

      if (runnable.exception != null) {
        throw new DartModelException(new CoreException(new Status(
            IStatus.ERROR,
            DartCore.PLUGIN_ID,
            "Failed to parse " + sourceRef.getName(),
            runnable.exception)));
      }
      return runnable.result;

    } finally {
      instrumentation.log();

    }
  }

  /**
   * Parse the specified source. Any exceptions thrown by the {@link DartParser} will be logged and
   * a {@link DartModelException} thrown.
   * 
   * @param sourceRef the Dart source being parsed
   * @param source the source to be parsed (not <code>null</code>)
   * @param parseErrors a collection to which parse errors are appended or <code>null</code> if
   *          parse errors should be ignored
   * @return the parse result
   */
  public static DartUnit parseSource(DartSource sourceRef, String source,
      Collection<DartCompilationError> parseErrors) throws DartModelException {
    return parseSource(sourceRef, source, false, parseErrors);
  }

  /**
   * Parse the source for the specified compilation unit. Any exceptions thrown by the
   * {@link DartParser} will be logged and a {@link DartModelException} thrown.
   * 
   * @param name a name for the source being parsed
   * @param source the source to be parsed (not <code>null</code>)
   * @return the parse result or <code>null</code> if there are any parse errors
   */
  public static DartUnit parseSource(String name, String source) throws DartModelException {

    checkUse();

    Collection<DartCompilationError> parseErrors = new ArrayList<DartCompilationError>();
    DartUnit dartUnit = parseSource(name, source, parseErrors);
    if (parseErrors.size() > 0) {
      return null;
    }
    return dartUnit;
  }

  /**
   * Parse the specified source. Any exceptions thrown by the {@link DartParser} will be logged and
   * a {@link DartModelException} thrown.
   * 
   * @param name a name for the source being parsed
   * @param source the source to be parsed (not <code>null</code>)
   * @param preserveComments <code>true</code> if comments are to be preserved
   * @param parseErrors a collection to which parse errors are appended or <code>null</code> if
   *          parse errors should be ignored
   * @return the parse result
   */
  public static DartUnit parseSource(String name, String source, boolean preserveComments,
      final Collection<DartCompilationError> parseErrors) throws DartModelException {
    DartSource sourceRef = new DartSourceString(name, source);
    return parseSource(sourceRef, source, preserveComments, parseErrors);
  }

  /**
   * Parse the specified source. Any exceptions thrown by the {@link DartParser} will be logged and
   * a {@link DartModelException} thrown.
   * 
   * @param name a name for the source being parsed
   * @param source the source to be parsed (not <code>null</code>)
   * @param parseErrors a collection to which parse errors are appended or <code>null</code> if
   *          parse errors should be ignored
   * @return the parse result
   */
  public static DartUnit parseSource(String name, String source,
      final Collection<DartCompilationError> parseErrors) throws DartModelException {
    DartSource sourceRef = new DartSourceString(name, source);
    return parseSource(sourceRef, source, parseErrors);
  }

  /**
   * Parse the source for the specified compilation unit. Any exceptions thrown by the
   * {@link DartParser} will be logged and a {@link DartModelException} thrown.
   * 
   * @param compilationUnit the compilation unit (not <code>null</code>)
   * @return the parse result or <code>null</code> if there are any parse errors
   */
  public static DartUnit parseUnit(CompilationUnit compilationUnit) throws DartModelException {

    checkUse();

    Collection<DartCompilationError> parseErrors = new ArrayList<DartCompilationError>();
    DartUnit dartUnit = parseUnit(compilationUnit, parseErrors);
    if (parseErrors.size() > 0) {
      return null;
    }
    return dartUnit;
  }

  /**
   * Parse the source for the specified compilation unit. Any exceptions thrown by the
   * {@link DartParser} will be logged and a {@link DartModelException} thrown.
   * 
   * @param compilationUnit the compilation unit (not <code>null</code>)
   * @param parseErrors a collection to which parse errors are appended or <code>null</code> if
   *          parse errors should be ignored
   * @return the parse result
   */
  public static DartUnit parseUnit(CompilationUnit compilationUnit,
      Collection<DartCompilationError> parseErrors) throws DartModelException {
    String name = compilationUnit.getElementName();
    String source = compilationUnit.getSource();
    return parseSource(name, source, parseErrors);
  }

  /**
   * Remove the given LibraryUnit from the cache of previously-analyzed libraries.
   */
  public static void removeCachedLibrary(LibrarySource library) {

    checkUse();

    synchronized (cachedLibraries) {
      cachedLibraries.remove(library);
    }
  }

  /**
   * Parse the compilation units in the specified library. Any exceptions thrown by the
   * {@link DartParser} will be logged and a {@link DartModelException} thrown.
   * 
   * @param library the library to be parsed (not <code>null</code>)
   * @param parseErrors a collection to which parse errors are appended or <code>null</code> if
   *          parse errors should be ignored
   * @return the parse result
   * @throws DartModelException if the library could not be parsed
   */
  public static LibraryUnit resolveLibrary(LibrarySource library,
      Collection<DartUnit> suppliedUnits, final Collection<DartCompilationError> parseErrors)
      throws DartModelException {

    checkUse();

    InstrumentationBuilder instrumentation = Instrumentation.builder("DartCompilerUtilities.resolveLibrary");
    try {

      ResolverRunnable runnable = new ResolverRunnable(
          library,
          createMap(suppliedUnits),
          false,
          parseErrors);
      runnable.runSafe();

      instrumentation.metric("librarySource.LastModified", library.getLastModified());
      instrumentation.data("librarySource.Name", library.getName());

      if (runnable.exception != null) {
        throw new DartModelException(new CoreException(new Status(
            IStatus.ERROR,
            DartCore.PLUGIN_ID,
            "Failed to parse " + library.getName(),
            runnable.exception)));
      }
      return runnable.libraryResult;

    } finally {
      instrumentation.log();

    }
  }

  /**
   * Parse the source for the specified compilation unit. Any exceptions thrown by the
   * {@link DartParser} will be logged and a {@link DartModelException} thrown.
   * 
   * @param compilationUnit the compilation unit (not <code>null</code>)
   * @param resolve <code>true</code> if elements are to be resolved
   * @return the parse result or <code>null</code> if there are any parse errors
   */
  public static DartUnit resolveUnit(CompilationUnit compilationUnit) throws DartModelException {
    return resolveUnit(compilationUnit, null);
  }

  /**
   * Parse the source for the specified compilation unit and resolve any elements found in it. Any
   * exceptions thrown by the {@link DartParser} will be added to the given collection.
   * 
   * @param compilationUnit the compilation unit (not <code>null</code>)
   * @param parseErrors a collection to which parse errors are added or <code>null</code> if parse
   *          errors should be ignored
   * @return the parse result
   */
  public static DartUnit resolveUnit(CompilationUnit compilationUnit,
      Collection<DartCompilationError> parseErrors) throws DartModelException {

    checkUse();

    InstrumentationBuilder instrumentation = Instrumentation.builder("DartCompilerUtilities.resolveUnit");
    try {

      DartLibraryImpl library = (DartLibraryImpl) compilationUnit.getLibrary();
      if (library == null) {
        // If we cannot get the library, we cannot resolve any elements so we
        // revert to simply parsing the compilation unit.
        DartUnit ret = parseUnit(compilationUnit, parseErrors);

        instrumentation.metric("ParseOnlyFallback", "true");
        instrumentation.data("Element name", compilationUnit.getElementName());

        return ret;

      }
      IResource resource = compilationUnit.getResource();
      URI unitUri = null;
      if (resource != null) {
        unitUri = resource.getLocationURI();
      }
      if (unitUri == null && compilationUnit instanceof ExternalCompilationUnitImpl) {
        unitUri = ((ExternalCompilationUnitImpl) compilationUnit).getUri();
      }
      if (unitUri == null) {
        unitUri = ((CompilationUnitImpl) compilationUnit).getSourceRef().getUri();
      }
      String unitSource = compilationUnit.getSource();
      Map<URI, String> suppliedSources = new HashMap<URI, String>();
      if (unitSource != null) {
        suppliedSources.put(unitUri, unitSource);
      }
      DartUnit ret = resolveUnit(
          library.getLibrarySourceFile(),
          unitUri,
          suppliedSources,
          parseErrors);

      instrumentation.metric("ParseOnlyFallback", "false");
      instrumentation.data("Element name", compilationUnit.getElementName());
      //TODO(Luke): Push the compilation Unit instrumentation utility method down to here

      return ret;
    } finally {
      instrumentation.log();

    }
  }

  /**
   * Parse the specified source. Any exceptions thrown by the {@link DartParser} will be logged and
   * a {@link DartModelException} thrown.
   * 
   * @param librarySource the source for the library containing the compilation unit being parsed
   * @param unitUri the URI of the compilation unit being parsed
   * @param parseErrors a collection to which parse errors are appended or <code>null</code> if
   *          parse errors should be ignored
   * @return the parse result
   */
  public static DartUnit resolveUnit(LibrarySource librarySource, URI unitUri,
      Map<URI, String> suppliedSources, final Collection<DartCompilationError> parseErrors)
      throws DartModelException {

    checkUse();

    InstrumentationBuilder instrumentation = Instrumentation.builder("DartCompilerUtilities.resolveUnit");
    try {

      ResolverRunnable runnable = new ResolverRunnable(
          librarySource,
          unitUri,
          suppliedSources,
          false,
          parseErrors);
      runnable.runSafe();

      instrumentation.metric("librarySource.LastModified", librarySource.getLastModified());
      instrumentation.data("librarySource-ElementName", librarySource.getName());

      if (runnable.exception != null) {
        throw new DartModelException(new CoreException(new Status(
            IStatus.ERROR,
            DartCore.PLUGIN_ID,
            "Failed to parse " + unitUri,
            runnable.exception)));
      }
      return runnable.unitResult;
    } finally {
      instrumentation.log();

    }
  }

  /**
   * A synchronized call to {@link DartCompiler#analyzeLibraries}
   */
  public static Map<URI, LibraryUnit> secureAnalyzeLibraries(LibrarySource librarySource,
      SelectiveCache selectiveCache, CompilerConfiguration config, DartArtifactProvider provider,
      DartCompilerListener listener, boolean resolveAllNewLibs) throws IOException {

    checkUse();

    // All calls to DartC must be synchronized

    Map<URI, LibraryUnit> ret;

    InstrumentationBuilder instrumentation = Instrumentation.builder("DartCompilerUtilities.secureAnalyzeLibraries");
    try {

      synchronized (compilerLock) {
        ret = DartCompiler.analyzeLibraries(
            librarySource,
            selectiveCache,
            config,
            provider,
            listener,
            resolveAllNewLibs);
      }

      instrumentation.metric("librarySource.LastModified", librarySource.getLastModified());
      instrumentation.data("librarySource.Name", librarySource.getName());
      return ret;
    } finally {
      instrumentation.log();

    }
  }

  /**
   * A synchronized call to {@link DartCompiler#analyzeLibrary}
   */
  public static LibraryUnit secureAnalyzeLibrary(LibrarySource librarySource,
      final Map<URI, DartUnit> parsedUnits, final CompilerConfiguration config,
      DartArtifactProvider provider, DartCompilerListener listener) throws IOException {

    checkUse();

    InstrumentationBuilder instrumentation = Instrumentation.builder("DartCompilerUtilities.secureAnalyzeLibrary");
    try {

      if (!DartSdkManager.getManager().hasSdk()) {
        instrumentation.metric("Problem", "No SDK");
        return null;
      }

      final PackageLibraryManager manager = PackageLibraryManagerProvider.getPackageLibraryManager();
      AnalysisServer server = PackageLibraryManagerProvider.getDefaultAnalysisServer();

      URI librarySourceUri = librarySource.getUri();

      if (parsedUnits == null && !(librarySource instanceof LibraryWithSuppliedSources)) {

        // Resolve dart:<libname> to file URI before calling AnalysisServer
        URI libraryFileUri = manager.resolveDartUri(librarySourceUri);
        File libraryFile = new File(libraryFileUri.getPath());

        LibraryUnit ret = server.getSavedContext().resolve(libraryFile, 30000);

        instrumentation.metric("librarySource.LastModified", librarySource.getLastModified());
        instrumentation.data("librarySource.Name", librarySource.getName());

        return ret;

      }

      // Resolve the specified library against all currently cached libraries
      final Map<URI, LibraryUnit> resolvedLibs = server.getSavedContext().getResolvedLibraries(50);
      resolvedLibs.remove(librarySourceUri);

      // Construct the selective cache
      SelectiveCache selectiveCache = new DartCompiler.SelectiveCache() {
        @Override
        public Map<URI, LibraryUnit> getResolvedLibraries() {
          return resolvedLibs;
        }

        @Override
        public DartUnit getUnresolvedDartUnit(DartSource dartSrc) {
          if (parsedUnits == null) {
            return null;
          }
          URI srcUri = dartSrc.getUri();
          DartUnit parsedUnit = parsedUnits.remove(srcUri);
          if (parsedUnit != null) {
            return parsedUnit;
          }
          URI fileUri = manager.resolveDartUri(srcUri);
          return parsedUnits.remove(fileUri);
        }
      };

      Map<URI, LibraryUnit> libMap;
      // All calls to DartC must be synchronized
      synchronized (compilerLock) {
        libMap = DartCompiler.analyzeLibraries(
            librarySource,
            selectiveCache,
            config,
            provider,
            listener,
            false);
      }

      instrumentation.metric("librarySource.LastModified", librarySource.getLastModified());
      instrumentation.metric("LibMapHasResult", Boolean.toString(libMap != null)).log();
      instrumentation.data("librarySource.Name", librarySource.getName());

      return libMap != null ? libMap.get(librarySourceUri) : null;
    } finally {
      instrumentation.log();

    }
  }

  /**
   * A synchronized call to
   * {@link DartCompiler#compileLib(LibrarySource, CompilerConfiguration, DartArtifactProvider, DartCompilerListener)}
   */
  public static void secureCompileLib(LibrarySource libSource, CompilerConfiguration config,
      DartArtifactProvider provider, DartCompilerListener listener) throws IOException {

    checkUse();

    InstrumentationBuilder instrumentation = Instrumentation.builder("DartCompilerUtilities.secureAnalyzeLibrary");
    try {

      if (!DartSdkManager.getManager().hasSdk()) {
        instrumentation.metric("Problem", "No SDK");
        return;
      }

      List<LibrarySource> embeddedLibraries = new ArrayList<LibrarySource>();
      // All calls to DartC must be synchronized
      synchronized (compilerLock) {
        DartCompiler.compileLib(libSource, embeddedLibraries, config, provider, listener);
      }
      instrumentation.data("librarySource.Name", libSource.getName());
    } finally {
      instrumentation.log();

    }
  }

  /**
   * A synchronized call to {@link DartParser#parseUnit(DartSource)}
   */
  public static DartUnit secureParseUnit(DartParser parser, DartSource sourceRef) {

    checkUse();

    InstrumentationBuilder instrumentation = Instrumentation.builder("DartCompilerUtilities.secureParseUnit");
    try {

      // All calls to DartC must be synchronized
      synchronized (compilerLock) {
        DartUnit ret = parser.parseUnit();
        instrumentation.data("sourceRef.Name", sourceRef != null ? sourceRef.getName() : "null");
        return ret;
      }
    } finally {
      instrumentation.log();

    }
  }

  private static void checkUse() {
    DartCore.oldModelCheck();
  }

  private static Map<URI, DartUnit> createMap(Collection<DartUnit> suppliedUnits) {
    if (suppliedUnits == null || suppliedUnits.isEmpty()) {
      return null;
    }
    Map<URI, DartUnit> parsedUnits = new HashMap<URI, DartUnit>(suppliedUnits.size());
    for (DartUnit unit : suppliedUnits) {
      DartSource src = (DartSource) unit.getSourceInfo().getSource();
      URI uri = src.getUri();
      parsedUnits.put(uri, unit);
    }
    return parsedUnits;
  }

  private static boolean equalUris(PackageLibraryManager manager, URI firstUri, URI secondUri) {
    if (firstUri == null) {
      return secondUri == null;
    } else if (secondUri == null) {
      return false;
    }
    String firstScheme = firstUri.getScheme();
    String secondScheme = secondUri.getScheme();
    if (firstScheme == null || firstScheme.equals("file")) {
      if (secondScheme != null && !secondScheme.equals("file")) {
        return false;
      }

      String firstPath = firstUri.getPath();
      String secondPath = secondUri.getPath();

      if (firstPath.equals(secondPath)) {
        return true;
      }

      // handle relative uris
      // TODO(devoncarew): we should look into whether using relative URIs is a good idea

      String currentPath = new File(".").toURI().normalize().getPath();

      if (firstPath.endsWith(secondPath)) {
        if (firstPath.equals(currentPath + secondPath)) {
          return true;
        }
      }

      if (secondPath.endsWith(firstPath)) {
        if (secondPath.equals(currentPath + firstPath)) {
          return true;
        }
      }

      return false;
    } else if (secondScheme == null || !firstScheme.equals(secondScheme)) {
      return false;
    } else if (PackageLibraryManager.isDartUri(firstUri)
        || PackageLibraryManager.isDartUri(secondUri)) {
      return URIUtilities.safelyResolveDartUri(firstUri).equals(
          URIUtilities.safelyResolveDartUri(secondUri));
    }
    return URIUtil.toPath(firstUri).equals(URIUtil.toPath(secondUri));
  }

}
