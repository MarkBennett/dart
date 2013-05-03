// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
part of analyzer;

/// Analyzes single library [File].
class _AnalyzerImpl {
  final CommandLineOptions options;
  DartSdk sdk;

  ContentCache contentCache = new ContentCache();
  SourceFactory sourceFactory;
  AnalysisContext context;

  /// All [Source]s references by the analyzed library.
  final Set<Source> sources = new Set<Source>();

  /// All [AnalysisErrorInfo]s in the analyzed library.
  final List<AnalysisErrorInfo> errorInfos = new List<AnalysisErrorInfo>();

  _AnalyzerImpl(CommandLineOptions this.options) {
    sdk = new DirectoryBasedDartSdk(new JavaFile(options.dartSdkPath));
  }

  /**
   * Treats the [sourcePath] as the top level library and analyzes it.
   */
  void analyze(String sourcePath) {
    sources.clear();
    errorInfos.clear();
    if (sourcePath == null) {
      throw new ArgumentError("sourcePath cannot be null");
    }
    var sourceFile = new JavaFile(sourcePath);
    var librarySource = new FileBasedSource.con1(contentCache, sourceFile);
    // resolve library
    prepareAnalysisContext(sourceFile);
    var libraryElement = context.computeLibraryElement(librarySource);
    // prepare source and errors
    prepareSources(libraryElement);
    prepareErrors();
  }

  /// Returns the maximal [ErrorSeverity] of the recorded errors.
  ErrorSeverity get maxErrorSeverity {
    var status = ErrorSeverity.NONE;
    for (AnalysisErrorInfo errorInfo in errorInfos) {
      for (AnalysisError error in errorInfo.errors) {
        var severity = error.errorCode.errorSeverity;
        status = status.max(severity);
      }
    }
    return status;
  }

  void prepareAnalysisContext(JavaFile sourceFile) {
    List<UriResolver> resolvers = [new DartUriResolver(sdk), new FileUriResolver()];
    // may be add package resolver
    {
      var packageDirectory = getPackageDirectoryFor(sourceFile);
      if (packageDirectory != null) {
        resolvers.add(new PackageUriResolver([packageDirectory]));
      }
    }
    sourceFactory = new SourceFactory.con1(contentCache, resolvers);
    context = AnalysisEngine.instance.createAnalysisContext();
    context.sourceFactory = sourceFactory;
  }

  /// Fills [sources].
  void prepareSources(LibraryElement library) {
    var units = new Set<CompilationUnitElement>();
    var libraries = new Set<LibraryElement>();
    addLibrarySources(library, libraries, units);
  }

  void addCompilationUnitSource(CompilationUnitElement unit, Set<LibraryElement> libraries,
      Set<CompilationUnitElement> units) {
    if (unit == null || units.contains(unit)) {
      return;
    }
    units.add(unit);
    sources.add(unit.source);
  }

  void addLibrarySources(LibraryElement library, Set<LibraryElement> libraries,
      Set<CompilationUnitElement> units) {
    if (library == null || libraries.contains(library)) {
      return;
    }
    libraries.add(library);
    // may be skip library
    {
      UriKind uriKind = library.source.uriKind;
      // Optionally skip package: libraries.
      if (!options.showPackageWarnings && uriKind == UriKind.PACKAGE_URI) {
        return;
      }
      // Optionally skip SDK libraries.
      if (!options.showSdkWarnings && uriKind == UriKind.DART_URI) {
        return;
      }
    }
    // add compilation units
    addCompilationUnitSource(library.definingCompilationUnit, libraries, units);
    for (CompilationUnitElement child in library.parts) {
      addCompilationUnitSource(child, libraries, units);
    }
    // add referenced libraries
    for (LibraryElement child in library.importedLibraries) {
      addLibrarySources(child, libraries, units);
    }
    for (LibraryElement child in library.exportedLibraries) {
      addLibrarySources(child, libraries, units);
    }
  }

  /// Fills [errorInfos].
  void prepareErrors() {
    for (Source source in sources) {
      var sourceErrors = context.getErrors(source);
      errorInfos.add(sourceErrors);
    }
  }

  static JavaFile getPackageDirectoryFor(JavaFile sourceFile) {
    JavaFile sourceFolder = sourceFile.getParentFile();
    JavaFile packagesFolder = new JavaFile.relative(sourceFolder, "packages");
    if (packagesFolder.exists()) {
      return packagesFolder;
    }
    return null;
  }
}
