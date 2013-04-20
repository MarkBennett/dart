// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.google.dart.compiler;

import com.google.common.base.Objects;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;
import com.google.common.collect.Sets.SetView;
import com.google.common.io.CharStreams;
import com.google.common.io.Closeables;
import com.google.dart.compiler.CommandLineOptions.CompilerOptions;
import com.google.dart.compiler.LibraryDeps.Dependency;
import com.google.dart.compiler.UnitTestBatchRunner.Invocation;
import com.google.dart.compiler.ast.DartDirective;
import com.google.dart.compiler.ast.DartLibraryDirective;
import com.google.dart.compiler.ast.DartNode;
import com.google.dart.compiler.ast.DartPartOfDirective;
import com.google.dart.compiler.ast.DartToSourceVisitor;
import com.google.dart.compiler.ast.DartUnit;
import com.google.dart.compiler.ast.LibraryExport;
import com.google.dart.compiler.ast.LibraryNode;
import com.google.dart.compiler.ast.LibraryUnit;
import com.google.dart.compiler.ast.Modifiers;
import com.google.dart.compiler.common.SourceInfo;
import com.google.dart.compiler.metrics.CompilerMetrics;
import com.google.dart.compiler.metrics.DartEventType;
import com.google.dart.compiler.metrics.JvmMetrics;
import com.google.dart.compiler.metrics.Tracer;
import com.google.dart.compiler.metrics.Tracer.TraceEvent;
import com.google.dart.compiler.parser.DartParser;
import com.google.dart.compiler.resolver.CompileTimeConstantAnalyzer;
import com.google.dart.compiler.resolver.CoreTypeProvider;
import com.google.dart.compiler.resolver.CoreTypeProviderImplementation;
import com.google.dart.compiler.resolver.Element;
import com.google.dart.compiler.resolver.ElementKind;
import com.google.dart.compiler.resolver.Elements;
import com.google.dart.compiler.resolver.LibraryElement;
import com.google.dart.compiler.resolver.MemberBuilder;
import com.google.dart.compiler.resolver.MethodElement;
import com.google.dart.compiler.resolver.Resolver;
import com.google.dart.compiler.resolver.ResolverErrorCode;
import com.google.dart.compiler.resolver.SupertypeResolver;
import com.google.dart.compiler.resolver.TopLevelElementBuilder;
import com.google.dart.compiler.type.TypeAnalyzer;
import com.google.dart.compiler.util.DefaultTextOutput;
import com.google.dart.compiler.util.apache.StringUtils;

import org.kohsuke.args4j.CmdLineException;
import org.kohsuke.args4j.CmdLineParser;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintStream;
import java.io.Reader;
import java.io.Writer;
import java.net.URI;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

/**
 * Entry point for the Dart compiler.
 */
public class DartCompiler {

  static final int RESULT_OK = 0;
  static final int RESULT_WARNINGS = 1;
  static final int RESULT_ERRORS = 2;
  static final int RESULT_OTHER = 127;

  static class Result {
    final int code;
    final String message;
    public Result(int code, String message) {
      this.code = code;
      this.message = message;
    }
    Result merge(Result other) {
      if (other.code > code) {
        return other;
      }
      return this;
    }
  }

  public static final String EXTENSION_DEPS = "deps";
  public static final String EXTENSION_LOG = "log";
  public static final String EXTENSION_TIMESTAMP = "timestamp";

  public static final String CORELIB_URL_SPEC = "dart:core";
  public static final String MAIN_ENTRY_POINT_NAME = "main";

  private static class Compiler {
    private final LibrarySource app;
    private final List<LibrarySource> embeddedLibraries = new ArrayList<LibrarySource>();
    private final DartCompilerMainContext context;
    private final CompilerConfiguration config;
    private final Map<URI, LibraryUnit> libraries = new LinkedHashMap<URI, LibraryUnit>();
    private CoreTypeProvider typeProvider;
    private final boolean incremental;
    private final List<DartCompilationPhase> phases;
    private final LibrarySource coreLibrarySource;

    private Compiler(LibrarySource app, List<LibrarySource> embedded, CompilerConfiguration config,
        DartCompilerMainContext context) {
      this.app = app;
      this.config = config;
      this.phases = config.getPhases();
      this.context = context;
      for (LibrarySource library : embedded) {
        if (PackageLibraryManager.isDartSpec(library.getName())) {
          LibrarySource foundLibrary = context.getSystemLibraryFor(library.getName());
          assert(foundLibrary != null);
          embeddedLibraries.add(foundLibrary);
        } else {
          embeddedLibraries.add(library);
        }
      }
      coreLibrarySource = context.getSystemLibraryFor(CORELIB_URL_SPEC);
      assert(coreLibrarySource != null);
      embeddedLibraries.add(coreLibrarySource);

      incremental = config.incremental();
    }

    void addResolvedLibraries(Map<URI, LibraryUnit> resolvedLibraries) {
      libraries.putAll(resolvedLibraries);
    }

    Map<URI, LibraryUnit> getLibraries() {
      return libraries;
    }

    private void compile() {
      TraceEvent logEvent = Tracer.canTrace() ? Tracer.start(DartEventType.COMPILE) : null;
      try {
        updateAndResolve();
        if (!config.resolveDespiteParseErrors() && context.getErrorCount() > 0) {
          return;
        }
        compileLibraries();
      } catch (IOException e) {
        context.onError(new DartCompilationError(app, DartCompilerErrorCode.IO, e.getMessage()));
      } finally {
        Tracer.end(logEvent);
      }
    }

    /**
     * Update the current application and any referenced libraries and resolve
     * them.
     *
     * @return a {@link LibraryUnit}, maybe <code>null</code>
     * @throws IOException on IO errors - the caller must log this if it cares
     */
    private LibraryUnit updateAndResolve() throws IOException {
      TraceEvent logEvent = Tracer.canTrace() ? Tracer.start(DartEventType.UPDATE_RESOLVE) : null;

      CompilerMetrics compilerMetrics = context.getCompilerMetrics();
      if (compilerMetrics != null) {
        compilerMetrics.startUpdateAndResolveTime();
      }

      try {
        LibraryUnit library = updateLibraries(app);
        importEmbeddedLibraries();
        parseOutOfDateFiles();
        if (incremental) {
          addOutOfDateDeps();
        }
        if (!config.resolveDespiteParseErrors() && (context.getErrorCount() > 0)) {
          return library;
        }
        buildLibraryScopes();
        LibraryUnit corelibUnit = updateLibraries(coreLibrarySource);
        typeProvider = new CoreTypeProviderImplementation(corelibUnit.getElement().getScope(),
                                                          context);
        resolveLibraries();
        validateLibraryDirectives();
        return library;
      } finally {
        if(compilerMetrics != null) {
          compilerMetrics.endUpdateAndResolveTime();
        }

        Tracer.end(logEvent);
      }
    }

    /**
     * This method reads all libraries. They will be populated from some combination of fully-parsed
     * and diet-parser compilation units.
     */
    private void parseOutOfDateFiles() throws IOException {
      TraceEvent logEvent =
          Tracer.canTrace() ? Tracer.start(DartEventType.PARSE_OUTOFDATE) : null;
      CompilerMetrics compilerMetrics = context.getCompilerMetrics();
      long parseStart = compilerMetrics != null ? CompilerMetrics.getCPUTime() : 0;

      try {
        final Set<String> topLevelSymbolsDiff = Sets.newHashSet();
        for (LibraryUnit lib : getLibrariesToProcess()) {
          LibrarySource libSrc = lib.getSource();
          LibraryNode selfSourcePath = lib.getSelfSourcePath();

          // Load the existing DEPS, or create an empty one.
          LibraryDeps deps = lib.getDeps(context);
          Set<String> newUnitPaths = Sets.newHashSet();

          // Parse each compilation unit.
          for (LibraryNode sourcePathNode : lib.getSourcePaths()) {
            String relPath = sourcePathNode.getText();
            newUnitPaths.add(relPath);

            // Prepare DartSource for "#source" unit.
            final DartSource dartSrc = libSrc.getSourceFor(relPath);
            if (dartSrc == null || !dartSrc.exists()) {
              continue;
            }

            if (!incremental
                || PackageLibraryManager.isDartUri(libSrc.getUri())
                || isSourceOutOfDate(dartSrc)) {
              DartUnit unit = parse(dartSrc, lib.getPrefixes(),  false);
              // If we just parsed unit of library, report problems.
              if (sourcePathNode == selfSourcePath) {
                // report "#import" problems
                for (LibraryNode importPathNode : lib.getImportPaths()) {
                  LibrarySource dep = getImportSource(libSrc, importPathNode);
                  if (dep == null) {
                    reportMissingSource(context, libSrc, importPathNode);
                  }
                }
                // report "#source" problems
                for (LibraryNode checkSourcePathNode : lib.getSourcePaths()) {
                  String checkRelPath = checkSourcePathNode.getText();
                  final DartSource checkSource = libSrc.getSourceFor(checkRelPath);
                  if (checkSource == null || !checkSource.exists()) {
                    reportMissingSource(context, libSrc, checkSourcePathNode);
                  }
                }
              }

              // Process unit, if exists.
              if (unit != null) {
                if (sourcePathNode == selfSourcePath) {
                  lib.setSelfDartUnit(unit);
                }
                // Replace unit within the library.
                lib.putUnit(unit);
                context.setFilesHaveChanged();
                // Include into top-level symbols diff from current units, already existed or new.
                {
                  LibraryDeps.Source source = deps.getSource(relPath);
                  Set<String> newTopSymbols = unit.getTopDeclarationNames();
                  if (source != null) {
                    Set<String> oldTopSymbols = source.getTopSymbols();
                    SetView<String> diff0 = Sets.symmetricDifference(oldTopSymbols, newTopSymbols);
                    topLevelSymbolsDiff.addAll(diff0);
                  } else {
                    topLevelSymbolsDiff.addAll(newTopSymbols);
                  }
                }
              }
            } else {
              DartUnit dietUnit = parse(dartSrc, lib.getPrefixes(), true);
              if (dietUnit != null) {
                if (sourcePathNode == selfSourcePath) {
                  lib.setSelfDartUnit(dietUnit);
                }
                lib.putUnit(dietUnit);
              }
            }
          }

          // Include into top-level symbols diff from units which disappeared since last compiling.
          {
            Set<String> oldUnitPaths = deps.getUnitPaths();
            Set<String> disappearedUnitPaths = Sets.difference(oldUnitPaths, newUnitPaths);
            for (String relPath : disappearedUnitPaths) {
              LibraryDeps.Source source = deps.getSource(relPath);
              if (source != null) {
                Set<String> oldTopSymbols = source.getTopSymbols();
                topLevelSymbolsDiff.addAll(oldTopSymbols);
              }
            }
          }
        }

        // Parse units, which potentially depend on the difference in top-level symbols.
        if (!topLevelSymbolsDiff.isEmpty()) {
          context.setFilesHaveChanged();
          for (LibraryUnit lib : getLibrariesToProcess()) {
            LibrarySource libSrc = lib.getSource();
            LibraryNode selfSourcePath = lib.getSelfSourcePath();
            LibraryDeps deps = lib.getDeps(context);
            for (LibraryNode libNode : lib.getSourcePaths()) {
              String relPath = libNode.getText();
              // Prepare source dependency.
              LibraryDeps.Source source = deps.getSource(relPath);
              if (source == null) {
                continue;
              }
              // Check re-compilation conditions.
              if (source.shouldRecompileOnAnyTopLevelChange()
                  || !Sets.intersection(source.getAllSymbols(), topLevelSymbolsDiff).isEmpty()
                  || !Sets.intersection(source.getHoles(), topLevelSymbolsDiff).isEmpty()) {
                DartSource dartSrc = libSrc.getSourceFor(relPath);
                if (dartSrc == null || !dartSrc.exists()) {
                  continue;
                }
                DartUnit unit = parse(dartSrc, lib.getPrefixes(), false);
                if (unit != null) {
                  if (libNode == selfSourcePath) {
                    lib.setSelfDartUnit(unit);
                  } else {
                    lib.putUnit(unit);
                  }
                }
              }
            }
          }
        }
      } finally {
        if (compilerMetrics != null) {
          compilerMetrics.addParseWallTimeNano(CompilerMetrics.getCPUTime() - parseStart);
        }
        Tracer.end(logEvent);
      }
    }

    Collection<LibraryUnit> getLibrariesToProcess() {
      return libraries.values();
    }

    /**
     * This method reads the embedded library sources, making sure they are added
     * to the list of libraries to compile. It then adds the libraries as imports
     * of all libraries. The import is without prefix.
     */
    private void importEmbeddedLibraries() throws IOException {
      TraceEvent importEvent =
          Tracer.canTrace() ? Tracer.start(DartEventType.IMPORT_EMBEDDED_LIBRARIES) : null;
      try {
        for (LibrarySource embedded : embeddedLibraries) {
          updateLibraries(embedded);
        }

        for (LibraryUnit lib : getLibrariesToProcess()) {
          for (LibrarySource embedded : embeddedLibraries) {
            LibraryUnit imp = libraries.get(embedded.getUri());
            // Check that the current library is not the embedded library, and
            // that the current library does not already import the embedded
            // library.
            if (lib != imp && !lib.hasImport(imp)) {
              lib.addImport(imp, null);
            }
          }
        }
      } finally {
        Tracer.end(importEvent);
      }
    }

    /**
     * This method reads a library source and sets it up with its imports. When it
     * completes, it is guaranteed that {@link Compiler#libraries} will be completely populated.
     */
    private LibraryUnit updateLibraries(LibrarySource libSrc) throws IOException {
      TraceEvent updateEvent =
          Tracer.canTrace() ? Tracer.start(DartEventType.UPDATE_LIBRARIES, "name",
              libSrc.getName()) : null;
      try {
        // Avoid cycles.
        LibraryUnit lib = libraries.get(libSrc.getUri());
        if (lib != null) {
          return lib;
        }

        lib = context.getLibraryUnit(libSrc);
        // If we could not find the library, continue. The context will report
        // the error at the end.
        if (lib == null) {
          return null;
        }

        libraries.put(libSrc.getUri(), lib);

        // Update dependencies.
        for (LibraryNode libNode : lib.getImportPaths()) {
          LibrarySource dep = getImportSource(libSrc, libNode);
          if (dep != null) {
            LibraryUnit importedLib = updateLibraries(dep);
            lib.addImport(importedLib, libNode);
            if (libNode.isExported()) {
              lib.addExport(importedLib, libNode);
            }
          }
        }
        for (LibraryNode libNode : lib.getExportPaths()) {
          LibrarySource dep = getImportSource(libSrc, libNode);
          if (dep != null) {
            lib.addExport(updateLibraries(dep), libNode);
          }
        }
        return lib;
      } finally {
        Tracer.end(updateEvent);
      }
    }

    /**
     * @return the {@link LibrarySource} referenced in the "#import" from "libSrc". May be
     *         <code>null</code> if invalid URI or not existing library.
     */
    private LibrarySource getImportSource(LibrarySource libSrc, LibraryNode libNode)
        throws IOException {
      String libSpec = libNode.getText();
      LibrarySource dep;
      try {
        if (PackageLibraryManager.isDartSpec(libSpec)) {
          dep = context.getSystemLibraryFor(libSpec);
        } else {
          dep = libSrc.getImportFor(libSpec);
        }
      } catch (Throwable e) {
        return null;
      }
      if (dep == null || !dep.exists()) {
        return null;
      }
      return dep;
    }

    /**
     * Determines whether the given source is out-of-date with respect to its artifacts.
     */
    private boolean isSourceOutOfDate(DartSource dartSrc) {
      TraceEvent logEvent =
          Tracer.canTrace() ? Tracer.start(DartEventType.IS_SOURCE_OUTOFDATE, "src",
              dartSrc.getName()) : null;

      try {
        // If incremental compilation is disabled, just return true to force all
        // units to be recompiled.
        if (!incremental) {
          return true;
        }

        TraceEvent timestampEvent =
            Tracer.canTrace() ? Tracer.start(
                DartEventType.TIMESTAMP_OUTOFDATE,
                "src",
                dartSrc.getName()) : null;
        try {
          return context.isOutOfDate(dartSrc, dartSrc, EXTENSION_TIMESTAMP);
        } finally {
          Tracer.end(timestampEvent);
        }
      } finally {
        Tracer.end(logEvent);
      }
    }

    /**
     * Build scopes for the given libraries.
     */
    private void buildLibraryScopes() {
      TraceEvent logEvent =
          Tracer.canTrace() ? Tracer.start(DartEventType.BUILD_LIB_SCOPES) : null;
      try {
        Collection<LibraryUnit> libs = getLibrariesToProcess();

        // Build the class elements declared in the sources of a library.
        // Loop can be parallelized.
        for (LibraryUnit lib : libs) {
          new TopLevelElementBuilder().exec(lib, context);
        }

        // The library scope can then be constructed, containing types declared
        // in the library, and types declared in the imports. Loop can be parallelized.
        for (LibraryUnit lib : libs) {
          new TopLevelElementBuilder().fillInLibraryScope(lib, context);
        }
      } finally {
        Tracer.end(logEvent);
      }
    }

    /**
     * Parses compilation units that are out-of-date with respect to their dependencies.
     */
    private void addOutOfDateDeps() throws IOException {
      TraceEvent logEvent = Tracer.canTrace() ? Tracer.start(DartEventType.ADD_OUTOFDATE) : null;
      try {
        boolean filesHaveChanged = false;
        for (LibraryUnit lib : getLibrariesToProcess()) {

          // Load the existing DEPS, or create an empty one.
          LibraryDeps deps = lib.getDeps(context);

          // Prepare all top-level symbols.
          Set<String> oldTopLevelSymbols = Sets.newHashSet();
          for (LibraryDeps.Source source : deps.getSources()) {
            oldTopLevelSymbols.addAll(source.getTopSymbols());
          }

          // Parse units that are out-of-date with respect to their dependencies.
          for (DartUnit unit : lib.getUnits()) {
            if (unit.isDiet()) {
              String relPath = ((DartSource) unit.getSourceInfo().getSource()).getRelativePath();
              LibraryDeps.Source source = deps.getSource(relPath);
              if (isUnitOutOfDate(lib, source)) {
                filesHaveChanged = true;
                DartSource dartSrc = lib.getSource().getSourceFor(relPath);
                if (dartSrc != null && dartSrc.exists()) {
                  unit = parse(dartSrc, lib.getPrefixes(), false);
                  if (unit != null) {
                    lib.putUnit(unit);
                  }
                }
              }
            }
          }
        }

        if (filesHaveChanged) {
          context.setFilesHaveChanged();
        }
      } finally {
        Tracer.end(logEvent);
      }
    }

    /**
     * Determines whether the given dependencies are out-of-date.
     */
    private boolean isUnitOutOfDate(LibraryUnit lib, LibraryDeps.Source source) {
      // If we don't have dependency information, then we can not be sure that nothing changed.
      if (source == null) {
        return true;
      }
      // Check all dependencies.
      for (Dependency dep : source.getDeps()) {
        LibraryUnit depLib = libraries.get(dep.getLibUri());
        if (depLib == null) {
          return true;
        }
        // Prepare unit.
        DartUnit depUnit = depLib.getUnit(dep.getUnitName());
        if (depUnit == null) {
          return true;
        }
        // May be unit modified.
        if (depUnit.getSourceInfo().getSource().getLastModified() != dep.getLastModified()) {
          return true;
        }
      }
      // No changed dependencies.
      return false;
    }

    /**
     * Resolve all libraries. Assume that all library scopes are already built.
     */
    private void resolveLibraries() {
      TraceEvent logEvent =
          Tracer.canTrace() ? Tracer.start(DartEventType.RESOLVE_LIBRARIES) : null;
      try {
        // TODO(jgw): Optimization: Skip work for libraries that have nothing to
        // compile.

        // Resolve super class chain, and build the member elements. Both passes
        // need the library scope to be setup. Each for loop can be
        // parallelized.
        for (LibraryUnit lib : getLibrariesToProcess()) {
          for (DartUnit unit : lib.getUnits()) {
            // These two method calls can be parallelized.
            new SupertypeResolver().exec(unit, context, getTypeProvider());
            new MemberBuilder().exec(unit, context, getTypeProvider());
          }
        }

      } finally {
        Tracer.end(logEvent);
      }
    }

    private void validateLibraryDirectives() {
      for (LibraryUnit lib : getLibrariesToProcess()) {
        // don't need to validate system libraries
        if (PackageLibraryManager.isDartUri(lib.getSource().getUri())) {
          continue;
        }
        
        // check for #source uniqueness
        {
          Set<URI> includedSourceUris = Sets.newHashSet();
          for (LibraryNode sourceNode : lib.getSourcePaths()) {
            String path = sourceNode.getText();
            DartSource source = lib.getSource().getSourceFor(path);
            if (source != null) {
              URI uri = source.getUri();
              if (includedSourceUris.contains(uri)) {
                context.onError(new DartCompilationError(sourceNode.getSourceInfo(),
                    DartCompilerErrorCode.UNIT_WAS_ALREADY_INCLUDED, uri));
              }
              includedSourceUris.add(uri);
            }
          }
        }

        // Validate imports.
        boolean hasIO = false;
        boolean hasHTML = false;
        for (LibraryNode importNode : lib.getImportPaths()) {
          String libSpec = importNode.getText();
          hasIO |= "dart:io".equals(libSpec);
          hasHTML |= "dart:html".equals(libSpec);
          // "dart:mirrors" are not done yet
          if ("dart:mirrors".equals(libSpec)) {
            context.onError(new DartCompilationError(importNode,
                DartCompilerErrorCode.MIRRORS_NOT_FULLY_IMPLEMENTED));
          }
          // validate console/web mix
          if (hasIO && hasHTML) {
            context.onError(new DartCompilationError(importNode.getSourceInfo(),
                DartCompilerErrorCode.CONSOLE_WEB_MIX));
          }
        }

        // check that each exported library has a library directive
        for (LibraryExport libraryExport : lib.getExports()) {
          LibraryUnit exportedLibrary = libraryExport.getLibrary();
          String exportedLibraryName = getLibraryName(exportedLibrary);
          // no => error
          if (exportedLibraryName == null) {
            SourceInfo info = findExportDirective(lib, exportedLibrary);
            if (info != null) {
              Source expSource = exportedLibrary.getSelfDartUnit().getSourceInfo().getSource();
              context.onError(new DartCompilationError(info,
                  DartCompilerErrorCode.MISSING_LIBRARY_DIRECTIVE_EXPORT,
                  ((DartSource) expSource).getRelativePath()));
            }
          }
        }
          
        // check that each imported library has a library directive
        Map<String, LibraryUnit> nameToImportedLibrary = Maps.newHashMap();
        for (LibraryUnit importedLib  : lib.getImportedLibraries()) {

          if (PackageLibraryManager.isDartUri(importedLib.getSource().getUri())) {
            // system libraries are always valid
            continue;
          }

          // get the dart unit corresponding to this library
          DartUnit unit = importedLib.getSelfDartUnit();
          if (unit == null || unit.isDiet()) {
            // don't need to check a unit that hasn't changed
            continue;
          }

          // find imported library name
          String importedLibraryName = getLibraryName(importedLib);
          
          // no name => error
          if (importedLibraryName == null) {
            SourceInfo info = findImportDirective(lib, importedLib);
            if (info != null) {
              context.onError(new DartCompilationError(info,
                  DartCompilerErrorCode.MISSING_LIBRARY_DIRECTIVE_IMPORT,
                  ((DartSource) unit.getSourceInfo().getSource()).getRelativePath()));
            }
          }
          
          // has already library with such name => error
          if (importedLibraryName != null) {
            LibraryUnit prevLibraryWithSameName = nameToImportedLibrary.get(importedLibraryName);
            if (prevLibraryWithSameName != null) {
              SourceInfo info = findImportDirective(lib, importedLib);
              if (info != null) {
                Source prevSource = prevLibraryWithSameName.getSelfDartUnit().getSourceInfo().getSource();
                context.onError(new DartCompilationError(info,
                    DartCompilerErrorCode.DUPLICATE_IMPORTED_LIBRARY_NAME,
                    importedLibraryName,
                    ((DartSource) prevSource).getRelativePath()));
              }
            } else {
              nameToImportedLibrary.put(importedLibraryName, importedLib);
            }
          }
        }

        // check that all sourced units have no directives
        for (DartUnit unit : lib.getUnits()) {
          // don't need to check a unit that hasn't changed
          if (unit.isDiet()) {
            continue;
          }
          // ignore library unit
          DartSource unitSource = (DartSource) unit.getSourceInfo().getSource();
          if (isLibrarySelfUnit(lib, unitSource)) {
            continue;
          }
          // analyze directives
          List<DartDirective> directives = unit.getDirectives();
          if (directives.isEmpty()) {
            context.onError(new DartCompilationError(unitSource,
                DartCompilerErrorCode.MISSING_PART_OF_DIRECTIVE, lib.getName()));
          } else if (directives.size() == 1 && directives.get(0) instanceof DartPartOfDirective) {
            DartPartOfDirective directive = (DartPartOfDirective) directives.get(0);
            String dirName = directive.getLibraryName();
            if (!Objects.equal(dirName, lib.getName())) {
              context.onError(new DartCompilationError(directive,
                  DartCompilerErrorCode.WRONG_PART_OF_NAME, lib.getName(), dirName));
            }
          } else {
            context.onError(new DartCompilationError(directives.get(0),
                DartCompilerErrorCode.ILLEGAL_DIRECTIVES_IN_SOURCED_UNIT,
                Elements.getRelativeSourcePath(unitSource, lib.getSource())));
          }
        }
      }
    }
    
    /**
     * @return the name of the given {@link LibraryUnit} specified in {@link DartLibraryDirective}.
     */
    private static String getLibraryName(LibraryUnit libraryUnit) {
      DartUnit unit = libraryUnit.getSelfDartUnit();
      for (DartDirective directive : unit.getDirectives()) {
        if (directive instanceof DartLibraryDirective) {
          return ((DartLibraryDirective) directive).getLibraryName();
        }
      }
      return null;
    }

    /**
     * @return the {@link SourceInfo} of the import directive in "lib" for "importedLib".
     */
    private static SourceInfo findImportDirective(LibraryUnit lib, LibraryUnit importedLib) {
      for (LibraryNode importPath : lib.getImportPaths()) {
        if (importPath.getText().equals(importedLib.getSelfSourcePath().getText())) {
          return importPath.getSourceInfo();
        }
      }
      return null;
    }
    
    /**
     * @return the {@link SourceInfo} of the export directive in "lib" for "importedLib".
     */
    private static SourceInfo findExportDirective(LibraryUnit lib, LibraryUnit importedLib) {
      for (LibraryNode exportPath : lib.getExportPaths()) {
        if (exportPath.getText().equals(importedLib.getSelfSourcePath().getText())) {
          return exportPath.getSourceInfo();
        }
      }
      return null;
    }

    private static boolean isLibrarySelfUnit(LibraryUnit lib, DartSource unitSource) {
      String unitRelativePath = unitSource.getRelativePath();
      for (LibraryNode sourceNode : lib.getSourcePaths()) {
        if (unitRelativePath.equals(sourceNode.getText())) {
          if (sourceNode == lib.getSelfSourcePath()) {
            return true;
          }
          return false;
        }
      }
      return false;
    }

    private void setEntryPoint() {
      LibraryUnit lib = context.getAppLibraryUnit();
      lib.setEntryNode(new LibraryNode(MAIN_ENTRY_POINT_NAME));
      // this ensures that if we find it, it's a top-level static element
      Element element = lib.getElement().lookupLocalElement(MAIN_ENTRY_POINT_NAME);
      switch (ElementKind.of(element)) {
        case NONE:
          // this is ok, it might just be a library
          break;

        case METHOD:
          MethodElement methodElement = (MethodElement) element;
          Modifiers modifiers = methodElement.getModifiers();
          if (modifiers.isGetter()) {
            context.onError(new DartCompilationError(element,
                DartCompilerErrorCode.ENTRY_POINT_METHOD_MAY_NOT_BE_GETTER, MAIN_ENTRY_POINT_NAME));
          } else if (modifiers.isSetter()) {
            context.onError(new DartCompilationError(element,
                DartCompilerErrorCode.ENTRY_POINT_METHOD_MAY_NOT_BE_SETTER, MAIN_ENTRY_POINT_NAME));
          } else if (methodElement.getParameters().size() > 0) {
            context.onError(new DartCompilationError(element,
                DartCompilerErrorCode.ENTRY_POINT_METHOD_CANNOT_HAVE_PARAMETERS,
                MAIN_ENTRY_POINT_NAME));
          } else {
            lib.getElement().setEntryPoint(methodElement);
          }
          break;

        default:
          context.onError(new DartCompilationError(element,
              ResolverErrorCode.NOT_A_STATIC_METHOD, MAIN_ENTRY_POINT_NAME));
          break;
      }
    }

    private void compileLibraries() throws IOException {
      TraceEvent logEvent =
          Tracer.canTrace() ? Tracer.start(DartEventType.COMPILE_LIBRARIES) : null;

      CompilerMetrics compilerMetrics = context.getCompilerMetrics();
      if (compilerMetrics != null) {
        compilerMetrics.startCompileLibrariesTime();
      }

      try {
        // Set entry point
        setEntryPoint();

        // The two following for loops can be parallelized.
        for (LibraryUnit lib : getLibrariesToProcess()) {
          boolean persist = false;

          // Compile all the units in this library.
          for (DartCompilationPhase phase : phases) {

            // Run all compiler phases including AST simplification and symbol
            // resolution. This must run in serial.
            for (DartUnit unit : lib.getUnits()) {
              
              // Don't compile diet units.
              if (unit.isDiet()) {
                continue;
              }

              unit = phase.exec(unit, context, getTypeProvider());
              if (!config.resolveDespiteParseErrors() && context.getErrorCount() > 0) {
                return;
              }
            }

          }

          for (DartUnit unit : lib.getUnits()) {
            if (unit.isDiet()) {
              continue;
            }
            updateAnalysisTimestamp(unit);
            // To help support the IDE, notify the listener that this unit is compiled.
            context.unitCompiled(unit);
            // Update deps.
            lib.getDeps(context).update(context, unit);
            // We analyzed something, so we need to persist the deps.
            persist = true;
          }

          // Persist the DEPS file.
          if (persist) {
            lib.writeDeps(context);
          }
        }
      } finally {
        if (compilerMetrics != null) {
          compilerMetrics.endCompileLibrariesTime();
        }
        Tracer.end(logEvent);
      }
    }

    private void updateAnalysisTimestamp(DartUnit unit) throws IOException {
      // Update timestamp.
      Writer writer =
          context.getArtifactWriter(unit.getSourceInfo().getSource(), "", EXTENSION_TIMESTAMP);
      String timestampData = String.format("%d\n", System.currentTimeMillis());
      writer.write(timestampData);
      writer.close();
    }

    DartUnit parse(DartSource dartSrc, Set<String> libraryPrefixes, boolean diet) throws IOException {
      TraceEvent parseEvent =
          Tracer.canTrace() ? Tracer.start(DartEventType.PARSE, "src", dartSrc.getName()) : null;
      CompilerMetrics compilerMetrics = context.getCompilerMetrics();
      long parseStart = compilerMetrics != null ? CompilerMetrics.getThreadTime() : 0;
      Reader r = dartSrc.getSourceReader();
      String srcCode;
      boolean failed = true;
      try {
        try {
          srcCode = CharStreams.toString(r);
          failed = false;
        } finally {
          Closeables.close(r, failed);
        }

        DartParser parser = new DartParser(dartSrc, srcCode, diet, libraryPrefixes, context,
            context.getCompilerMetrics());
        DartUnit unit = parser.parseUnit();
        if (compilerMetrics != null) {
          compilerMetrics.addParseTimeNano(CompilerMetrics.getThreadTime() - parseStart);
        }

        if (!config.resolveDespiteParseErrors() && context.getErrorCount() > 0) {
          // We don't return this unit, so no more processing expected for it.
          context.unitCompiled(unit);
          return null;
        }
        return unit;
      } finally {
        Tracer.end(parseEvent);
      }
    }

    private void reportMissingSource(DartCompilerContext context,
                                     LibrarySource libSrc,
                                     LibraryNode libNode) {
      if (libNode != null && StringUtils.startsWith(libNode.getText(), "dart-ext:")) {
        return;
      }
      DartCompilationError event = new DartCompilationError(libNode,
                                                            DartCompilerErrorCode.MISSING_SOURCE,
                                                            libNode.getText());
      event.setSource(libSrc);
      context.onError(event);
    }
    CoreTypeProvider getTypeProvider() {
      typeProvider.getClass(); // Quick null check.
      return typeProvider;
    }
  }

  /**
   * Provides cached parse and resolution results during selective compilation
   */
  public abstract static class SelectiveCache {

    /**
     * Answer the cached resolved libraries
     * 
     * @return a mapping (not <code>null</code>) of library source URI to cached {@link LibraryUnit}
     */
    public abstract Map<URI, LibraryUnit> getResolvedLibraries();

    /**
     * Answer the cached unresolved {@link DartUnit} for the specified source
     * 
     * @param dartSrc the source (not <code>null</code>)
     * @return the cached unit or <code>null</code> if it is not cached
     */
    public abstract DartUnit getUnresolvedDartUnit(DartSource dartSrc);
  }

  /**
   * Selectively compile a library. Use supplied libraries and ASTs when available.
   * This allows programming tools to provide customized ASTs for code that is currently being
   * edited, and may not compile correctly.
   */
  static class SelectiveCompiler extends Compiler {
    private final SelectiveCache selectiveCache;
    private Collection<LibraryUnit> librariesToProcess;

    private SelectiveCompiler(LibrarySource app, SelectiveCache selectiveCache,
        CompilerConfiguration config, DartCompilerMainContext context) {
      super(app, Collections.<LibrarySource>emptyList(), config, context);
      this.selectiveCache = selectiveCache;
      addResolvedLibraries(selectiveCache.getResolvedLibraries());
    }

    @Override
    Collection<LibraryUnit> getLibrariesToProcess() {
      if (librariesToProcess == null) {
        librariesToProcess = new ArrayList<LibraryUnit>();
        librariesToProcess.addAll(super.getLibrariesToProcess());
        librariesToProcess.removeAll(selectiveCache.getResolvedLibraries().values());
      }
      return librariesToProcess;
    }

    @Override
    DartUnit parse(DartSource dartSrc, Set<String> prefixes, boolean diet) throws IOException {
      DartUnit parsedUnit = selectiveCache.getUnresolvedDartUnit(dartSrc);
      if (parsedUnit != null) {
        return parsedUnit;
      }
      return super.parse(dartSrc, prefixes, diet);
    }
  }

  private static CompilerOptions processCommandLineOptions(String[] args) {
    CmdLineParser cmdLineParser = null;
    CompilerOptions compilerOptions = null;
    try {
      compilerOptions = new CompilerOptions();
      cmdLineParser = CommandLineOptions.parse(args, compilerOptions);
      if (args.length == 0 || compilerOptions.showHelp()) {
        showUsage(cmdLineParser, System.err);
        System.exit(1);
      }
    } catch (CmdLineException e) {
      System.err.println(e.getLocalizedMessage());
      showUsage(cmdLineParser, System.err);
      System.exit(1);
    }

    assert compilerOptions != null;
    return compilerOptions;
  }

  public static void main(final String[] topArgs) {
    Tracer.init();

    CompilerOptions topCompilerOptions = processCommandLineOptions(topArgs);
    Result result = null;
    try {
      // configure UTF-8 output
      System.setOut(new PrintStream(System.out, true, "UTF-8"));
      System.setErr(new PrintStream(System.err, true, "UTF-8"));

      if (topCompilerOptions.showVersion()) {
        showVersion(topCompilerOptions);
        System.exit(RESULT_OK);
      }
      if (topCompilerOptions.shouldBatch()) {
        if (topArgs.length > 1) {
          System.err.println("(Extra arguments specified with -batch ignored.)");
        }
        result = UnitTestBatchRunner.runAsBatch(topArgs, new Invocation() {
          @Override
          public Result invoke(String[] lineArgs) throws Throwable {
            List<String> allArgs = new ArrayList<String>();
            for (String arg: topArgs) {
              if (!arg.equals("-batch")) {
                allArgs.add(arg);
              }
            }
            for (String arg: lineArgs) {
              allArgs.add(arg);
            }

            CompilerOptions compilerOptions = processCommandLineOptions(
                allArgs.toArray(new String[allArgs.size()]));
            if (compilerOptions.shouldBatch()) {
              System.err.println("-batch ignored: Already in batch mode.");
            }
            return compilerMain(compilerOptions);
          }
        });
      } else {
        result = compilerMain(topCompilerOptions);
      }
    } catch (Throwable t) {
      t.printStackTrace();
      crash();
    }
    // exit
    {
      int exitCode = result.code;
      if (!topCompilerOptions.extendedExitCode()) {
        if (exitCode == RESULT_ERRORS) {
          exitCode = 1;
        } else {
          exitCode = 0;
        }
      }
      System.exit(exitCode);
    }
  }

  /**
   * Invoke the compiler to build single application.
   * 
   * @param compilerOptions parsed command line arguments
   * @return the result as integer when <code>0</code> means clean; <code>1</code> there were
   *         warnings; <code>2</code> there were errors; <code>127</code> other problems or
   *         exceptions.
   */
  public static Result compilerMain(CompilerOptions compilerOptions) throws IOException {
    List<String> sourceFiles = compilerOptions.getSourceFiles();
    if (sourceFiles.size() == 0) {
      System.err.println("dart_analyzer: no source files were specified.");
      showUsage(null, System.err);
      return new Result(RESULT_OTHER, null);
    }

    File sourceFile = new File(sourceFiles.get(0));
    if (!sourceFile.exists()) {
      System.err.println("dart_analyzer: file not found: " + sourceFile);
      showUsage(null, System.err);
      return new Result(RESULT_OTHER, null);
    }

    CompilerConfiguration config = new DefaultCompilerConfiguration(compilerOptions);
    config.getPackageLibraryManager().setPackageRoots(Arrays.asList(new File[]{compilerOptions.getPackageRoot()}));
    return compilerMain(sourceFile, config);
  }

  /**
   * Invoke the compiler to build single application.
   *
   * @param sourceFile file passed on the command line to build
   * @param config compiler configuration built from parsed command line options
   */
  public static Result compilerMain(File sourceFile, CompilerConfiguration config)
      throws IOException {
    Result result = compileApp(sourceFile, config);
    String errorMessage = result.message;
    if (errorMessage != null) {
      System.err.println(errorMessage);
      return result;
    }

    TraceEvent logEvent = Tracer.canTrace() ? Tracer.start(DartEventType.WRITE_METRICS) : null;
    try {
      maybeShowMetrics(config);
    } finally {
      Tracer.end(logEvent);
    }
    return result;
  }

  public static void crash() {
    // Our test scripts look for 253 to signal a "crash".
    System.exit(253);
  }

  private static void showUsage(CmdLineParser cmdLineParser, PrintStream out) {
    out.println("Usage: dart_analyzer [<options>] <dart-script> [script-arguments]");
    out.println("Available options:");
    if (cmdLineParser == null) {
      cmdLineParser = new CmdLineParser(new CompilerOptions());
    }
    cmdLineParser.printUsage(out);
  }

  private static void maybeShowMetrics(CompilerConfiguration config) {
    CompilerMetrics compilerMetrics = config.getCompilerMetrics();
    if (compilerMetrics != null) {
      compilerMetrics.write(System.out);
    }

    JvmMetrics.maybeWriteJvmMetrics(System.out, config.getJvmMetricOptions());
  }

  /**
   * Treats the <code>sourceFile</code> as the top level library and generates compiled output by
   * linking the dart source in this file with all libraries referenced with <code>#import</code>
   * statements.
   * 
   * @return the result as integer when <code>0</code> means clean; <code>1</code> there were
   *         warnings; <code>2</code> there were errors; <code>127</code> other problems or
   *         exceptions.
   */
  public static Result compileApp(File sourceFile, CompilerConfiguration config) throws IOException {
    TraceEvent logEvent =
        Tracer.canTrace() ? Tracer.start(DartEventType.COMPILE_APP, "src", sourceFile.toString())
            : null;
    try {
      File outputDirectory = config.getOutputDirectory();
      DefaultDartArtifactProvider provider = new DefaultDartArtifactProvider(outputDirectory);
      // Compile the Dart application and its dependencies.
      PackageLibraryManager libraryManager = config.getPackageLibraryManager();
      final LibrarySource lib = new UrlLibrarySource(sourceFile.toURI(),libraryManager);
      DefaultDartCompilerListener listener;
      if (config.getCompilerOptions().showSourceFromAst()) {
        listener = new DefaultDartCompilerListener(config.printErrorFormat()) {
          @Override
          public void unitCompiled(DartUnit unit) {
            if (unit.getLibrary() != null) {
              if (unit.getLibrary().getSource() == lib) {
                DefaultTextOutput output = new DefaultTextOutput(false);
                unit.accept(new DartToSourceVisitor(output));
                System.out.println(output.toString());
              }
            }
          }
        };
      } else {
        listener = new DefaultDartCompilerListener(config.printErrorFormat());
      }
      return compileLib(lib, config, provider, listener);
    } finally {
      Tracer.end(logEvent);
    }
  }

  /**
   * Compiles the given library, translating all its source files, and those
   * of its imported libraries, transitively.
   *
   * @param lib The library to be compiled (not <code>null</code>)
   * @param config The compiler configuration specifying the compilation phases
   * @param provider A mechanism for specifying where code should be generated
   * @param listener An object notified when compilation errors occur
   */
  public static Result compileLib(LibrarySource lib, CompilerConfiguration config,
      DartArtifactProvider provider, DartCompilerListener listener) throws IOException {
    return compileLib(lib, Collections.<LibrarySource>emptyList(), config, provider, listener);
  }

  /**
   * Same method as above, but also takes a list of libraries that should be
   * implicitly imported by all libraries. These libraries are provided by the embedder.
   */
  public static Result compileLib(LibrarySource lib,
                                  List<LibrarySource> embeddedLibraries,
                                  CompilerConfiguration config,
                                  DartArtifactProvider provider,
                                  DartCompilerListener listener) throws IOException {
    DartCompilerMainContext context = new DartCompilerMainContext(lib, provider, listener,
                                                                  config);
    new Compiler(lib, embeddedLibraries, config, context).compile();
    int errorCount = context.getErrorCount();
    if (config.typeErrorsAreFatal()) {
      errorCount += context.getTypeErrorCount();
    }
    if (config.warningsAreFatal()) {
      errorCount += context.getWarningCount();
    }
    if (errorCount > 0) {
      return new Result(RESULT_ERRORS, "Compilation failed with " + errorCount
          + (errorCount == 1 ? " problem." : " problems."));
    }
    if (!context.getFilesHaveChanged()) {
      return null;
    }
    // Write checking log.
    {
      Writer writer = provider.getArtifactWriter(lib, "", EXTENSION_LOG);
      boolean threw = true;
      try {
        writer.write(String.format("Checked %s and found:%n", lib.getName()));
        writer.write(String.format("  no load/resolution errors%n"));
        writer.write(String.format("  %s type errors%n", context.getTypeErrorCount()));
        threw = false;
      } finally {
        Closeables.close(writer, threw);
      }
    }
    {
      int resultCode = RESULT_OK;
      if (context.getWarningCount() != 0) {
        resultCode = RESULT_WARNINGS;
      }
      return new Result(resultCode, null);
    }
  }

  /**
   * Analyzes the given library and all its transitive dependencies.
   *
   * @param lib The library to be analyzed
   * @param parsedUnits A collection of unresolved ASTs that should be used
   * instead of parsing the associated source from storage. Intended for
   * IDE use when modified buffers must be analyzed. AST nodes in the map may be
   * ignored if not referenced by {@code lib}. (May be null.)
   * @param config The compiler configuration (phases will not be used), but resolution and
   * type-analysis will be invoked
   * @param provider A mechanism for specifying where code should be generated
   * @param listener An object notified when compilation errors occur
   * @throws NullPointerException if any of the arguments except {@code parsedUnits}
   * are {@code null}
   * @throws IOException on IO errors, which are not logged
   */
  public static LibraryUnit analyzeLibrary(LibrarySource lib, final Map<URI, DartUnit> parsedUnits,
      CompilerConfiguration config, DartArtifactProvider provider, DartCompilerListener listener)
      throws IOException {
    final PackageLibraryManager manager = config.getPackageLibraryManager();
    final HashMap<URI, LibraryUnit> resolvedLibs = new HashMap<URI, LibraryUnit>();
    SelectiveCache selectiveCache = new SelectiveCache() {
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
    Map<URI, LibraryUnit> libraryUnit = analyzeLibraries(lib, selectiveCache, config,
        provider, listener, false);
    return libraryUnit != null ? libraryUnit.get(lib.getUri()) : null;
  }

  /**
   * Analyzes the given library and all its transitive dependencies.
   *
   * @param lib The library to be analyzed
   * @param selectiveCache Provides cached parse and resolution results 
   *    during selective compilation (not <code>null</code>)
   * @param config The compiler configuration (phases and backends
   *    will not be used), but resolution and type-analysis will be invoked
   * @param provider A mechanism for specifying where code should be generated
   * @param listener An object notified when compilation errors occur
   * @param resolveAllNewLibs <code>true</code> if all new libraries should be resolved
   *    or false if only the library specified by the "lib" parameter should be resolved
   * @throws NullPointerException if any of the arguments except {@code parsedUnits}
   *    are {@code null}
   * @throws IOException on IO errors, which are not logged
   */
  public static Map<URI, LibraryUnit> analyzeLibraries(LibrarySource lib,
      SelectiveCache selectiveCache, CompilerConfiguration config,
      DartArtifactProvider provider, DartCompilerListener listener, 
      boolean resolveAllNewLibs) throws IOException {
    lib.getClass(); // Quick null check.
    provider.getClass(); // Quick null check.
    listener.getClass(); // Quick null check.
    Map<URI, LibraryUnit> resolvedLibs = selectiveCache.getResolvedLibraries();
    DartCompilerMainContext context = new DartCompilerMainContext(lib, provider, listener, config);
    Compiler compiler = new SelectiveCompiler(lib, selectiveCache, config, context);

    LibraryUnit topLibUnit = compiler.updateAndResolve();
    if (topLibUnit == null) {
      return null;
    }

    Map<URI, LibraryUnit> librariesToResolve;
    librariesToResolve = new HashMap<URI, LibraryUnit>();
    if (resolveAllNewLibs) {
      librariesToResolve.putAll(compiler.getLibraries());
    }
    librariesToResolve.put(topLibUnit.getSource().getUri(), topLibUnit);
    
    DartCompilationPhase[] phases = {
        new Resolver.Phase(),
        new CompileTimeConstantAnalyzer.Phase(),
        new TypeAnalyzer()};
    Map<URI, LibraryUnit> newLibraries = Maps.newHashMap();
    for (Entry<URI, LibraryUnit> entry : librariesToResolve.entrySet()) {
      URI libUri = entry.getKey();
      LibraryUnit libUnit = entry.getValue();
      if (!resolvedLibs.containsKey(libUri) && libUnit != null) {
        newLibraries.put(libUri, libUnit);
        for (DartCompilationPhase phase : phases) {
          // Run phase on all units, because "const" phase expects to have fully resolved library.
          for (DartUnit unit : libUnit.getUnits()) {
            if (unit.isDiet()) {
              continue;
            }
            unit = phase.exec(unit, context, compiler.getTypeProvider());
          }
        }
        // To help support the IDE, notify the listener that these unit were compiled.
        for (DartUnit unit : libUnit.getUnits()) {
          context.unitCompiled(unit);
        }
      }
    }

    return newLibraries;
  }

  /**
   * Re-analyzes source code after a modification. The modification is described by a SourceDelta.
   *
   * @param delta what has changed
   * @param enclosingLibrary the library in which the change occurred
   * @param interestStart beginning of interest area (as character offset from the beginning of the
   *          source file after the change.
   * @param interestLength length of interest area
   * @return a node which covers the entire interest area.
   */
  public static DartNode analyzeDelta(SourceDelta delta,
                                      LibraryElement enclosingLibrary,
                                      LibraryElement coreLibrary,
                                      DartNode interestNode,
                                      int interestStart,
                                      int interestLength,
                                      CompilerConfiguration config,
                                      DartCompilerListener listener) throws IOException {
    DeltaAnalyzer analyzer = new DeltaAnalyzer(delta, enclosingLibrary, coreLibrary,
                                               interestNode, interestStart, interestLength,
                                               config, listener);
    return analyzer.analyze();
  }

  public static LibraryUnit findLibrary(LibraryUnit libraryUnit, String uri,
      Set<LibraryElement> seen) {
    if (seen.contains(libraryUnit.getElement())) {
      return null;
    }
    seen.add(libraryUnit.getElement());
    if (uri.equals(libraryUnit.getName())) {
      return libraryUnit;
    }
    for (LibraryNode src : libraryUnit.getSourcePaths()) {
      if (src.getText().equals(uri)) {
        return libraryUnit;
      }
    }
    for (LibraryUnit importedLibrary : libraryUnit.getImportedLibraries()) {
      LibraryUnit unit = findLibrary(importedLibrary, uri, seen);
      if (unit != null) {
        return unit;
      }
    }
    return null;
  }

  public static LibraryUnit getCoreLib(LibraryUnit libraryUnit) {
    LibraryUnit coreLib = findLibrary(libraryUnit, "dart.core", new HashSet<LibraryElement>());
    if (coreLib == null) {
      coreLib = findLibrary(libraryUnit, "dart:core", new HashSet<LibraryElement>());
    }
    return coreLib;
  }

  private static void showVersion(CompilerOptions options) {
    String version = getSdkVersion(options);
    if (version == null) {
      version = "<unkown>";
    }
    System.out.println("dart_analyzer version " + version);
  }

  /**
   * @return the numeric revision of SDK, may be <code>null</code> if cannot find.
   */
  private static String getSdkVersion(CompilerOptions options) {
    try {
      File sdkPath = options.getDartSdkPath();
      File revisionFile = new File(sdkPath, "version");
      if (revisionFile.exists() && revisionFile.isFile()) {
        BufferedReader br = new BufferedReader(new FileReader(revisionFile));
        try {
          return br.readLine();
        } finally {
          br.close();
        }
      }
    } catch (Throwable e) {
    }
    return null;
  }
}
