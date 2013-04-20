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
package com.google.dart.compiler;

import com.google.common.annotations.VisibleForTesting;
import com.google.common.io.CharStreams;
import com.google.common.io.Closeables;
import com.google.dart.compiler.CompilerConfiguration.ErrorFormat;
import com.google.dart.compiler.ast.ASTVisitor;
import com.google.dart.compiler.ast.DartBooleanLiteral;
import com.google.dart.compiler.ast.DartExpression;
import com.google.dart.compiler.ast.DartFieldDefinition;
import com.google.dart.compiler.ast.DartIdentifier;
import com.google.dart.compiler.ast.DartMapLiteralEntry;
import com.google.dart.compiler.ast.DartNamedExpression;
import com.google.dart.compiler.ast.DartNewExpression;
import com.google.dart.compiler.ast.DartNode;
import com.google.dart.compiler.ast.DartStringLiteral;
import com.google.dart.compiler.ast.DartUnit;
import com.google.dart.compiler.metrics.CompilerMetrics;
import com.google.dart.compiler.parser.DartParser;
import com.google.dart.compiler.util.DartSourceString;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URI;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

/**
 * A reader that parses and reads the libraries dart-sdk/lib/_internal/libraries.dart file for
 * system library information library information is in the format final Map<String, LibraryInfo>
 * LIBRARIES = const <LibraryInfo> { // Used by VM applications "builtin": const LibraryInfo(
 * "builtin/builtin_runtime.dart", category: "Server", platforms: VM_PLATFORM), "compiler": const
 * LibraryInfo( "compiler/compiler.dart", category: "Tools", platforms: 0), };
 */
public class SystemLibrariesReader {

  @VisibleForTesting
  public class DartLibrary {

    private String shortName = null;
    private String path = null;
    private String category = "Shared";
    private boolean documented = true;
    private boolean implementation = false;
    private int platforms = 0;

    DartLibrary(String name) {
      this.shortName = name;
    }

    public String getShortName() {
      return shortName;
    }

    public String getPath() {
      return path;
    }

    public void setPath(String path) {
      this.path = path;
    }

    public String getCategory() {
      return category;
    }

    public void setCategory(String category) {
      this.category = category;
    }

    public boolean isDocumented() {
      return documented;
    }

    public void setDocumented(boolean documented) {
      this.documented = documented;
    }

    public boolean isImplementation() {
      return implementation;
    }

    public void setImplementation(boolean implementation) {
      this.implementation = implementation;
    }

    public boolean isDart2JsLibrary() {
      return (platforms & DART2JS_PLATFORM) != 0;
    }

    public boolean isVmLibrary() {
      return (platforms & VM_PLATFORM) != 0;
    }

    public void setPlatforms(int platforms) {
      this.platforms = platforms;
    }
  }

  class LibrariesFileAstVistor extends ASTVisitor<Void> {

    @Override
    public Void visitMapLiteralEntry(DartMapLiteralEntry node) {

      String keyString = null;
      DartExpression key = node.getKey();
      if (key instanceof DartStringLiteral) {
        keyString = "dart:" + ((DartStringLiteral) key).getValue();
      }
      DartExpression value = node.getValue();
      if (value instanceof DartNewExpression) {
        DartLibrary library = new DartLibrary(keyString);
        List<DartExpression> args = ((DartNewExpression) value).getArguments();
        for (DartExpression arg : args) {
          if (arg instanceof DartStringLiteral) {
            library.setPath(((DartStringLiteral) arg).getValue());
          }
          if (arg instanceof DartNamedExpression) {
            String name = ((DartNamedExpression) arg).getName().getName();
            DartExpression expression = ((DartNamedExpression) arg).getExpression();
            if (name.equals(CATEGORY)) {
              library.setCategory(((DartStringLiteral) expression).getValue());
            } else if (name.equals(IMPLEMENTATION)) {
              library.setImplementation(((DartBooleanLiteral) expression).getValue());
            } else if (name.equals(DOCUMENTED)) {
              library.setDocumented(((DartBooleanLiteral) expression).getValue());
            } else if (name.equals(PATCH_PATH)) {
              String path = ((DartStringLiteral) expression).getValue();
              URI uri = sdkLibPath.resolve(URI.create(path));
              patchPaths.add(uri);
            } else if (name.equals(PLATFORMS)) {
              if (expression instanceof DartIdentifier) {
                String identifier = ((DartIdentifier) expression).getName();
                if (identifier.equals("VM_PLATFORM")) {
                  library.setPlatforms(VM_PLATFORM);
                } else {
                  library.setPlatforms(DART2JS_PLATFORM);
                }
              }
            }
          }
        }
        librariesMap.put(keyString, library);
      }
      return null;
    }

  }

  public static final String LIBRARIES_FILE = "libraries.dart";
  public static final String INTERNAL_DIR = "_internal";

  private static final String IMPLEMENTATION = "implementation";
  private static final String DOCUMENTED = "documented";
  private static final String CATEGORY = "category";
  private static final String PATCH_PATH = "dart2jsPatchPath";
  private static final String PLATFORMS = "platforms";

  private static final int DART2JS_PLATFORM = 1;
  private static final int VM_PLATFORM = 2;

  private final URI sdkLibPath;
  private final Map<String, DartLibrary> librariesMap = new HashMap<String, DartLibrary>();
  private final List<URI> patchPaths = new ArrayList<URI>();

  public SystemLibrariesReader(URI sdkLibPath, Reader sdkFileReader) {
    this.sdkLibPath = sdkLibPath;
    loadLibraryInfo(sdkFileReader);
  }

  public SystemLibrariesReader(File sdkLibPath) throws IOException {
    this(sdkLibPath.getAbsoluteFile().toURI(), new InputStreamReader(new FileInputStream(
        getLibrariesFile(sdkLibPath)), Charset.forName("UTF8")));
  }

  public Map<String, DartLibrary> getLibrariesMap() {
    return librariesMap;
  }

  public List<URI> getPatchPaths() {
    return patchPaths;
  }

  private void loadLibraryInfo(Reader sdkFileReader) {

    DartUnit unit = getDartUnit(sdkFileReader);

    List<DartNode> nodes = unit.getTopLevelNodes();
    for (DartNode node : nodes) {
      if (node instanceof DartFieldDefinition) {
        node.accept(new LibrariesFileAstVistor());
      }
    }
  }

  /**
   * Parse the given dart file and return the AST
   * 
   * @param fileReader the dart file reader
   * @return the parsed AST
   */
  private DartUnit getDartUnit(Reader fileReader) {

    String srcCode = getSource(fileReader);
    DartSourceString dartSource = new DartSourceString(LIBRARIES_FILE, srcCode);
    DefaultDartCompilerListener listener = new DefaultDartCompilerListener(ErrorFormat.NORMAL);
    DartParser parser = new DartParser(
        dartSource,
        srcCode,
        false,
        new HashSet<String>(),
        listener,
        new CompilerMetrics());
    return parser.parseUnit();
  }

  private String getSource(Reader reader) {
    String srcCode = null;
    boolean failed = true;
    try {
      srcCode = CharStreams.toString(reader);
      failed = false;
    } catch (IOException e) {
      e.printStackTrace();
    } finally {
      try {
        Closeables.close(reader, failed);
      } catch (IOException e) {
        e.printStackTrace();
      }
    }
    return srcCode;
  }

  private static File getLibrariesFile(File sdkLibDir) {
    File file = new File(new File(sdkLibDir, INTERNAL_DIR), LIBRARIES_FILE);
    if (!file.exists()) {
      throw new InternalCompilerException("Failed to find " + file.toString()
          + ".  Is dart-sdk path correct?");
    }
    return file;
  }

}
