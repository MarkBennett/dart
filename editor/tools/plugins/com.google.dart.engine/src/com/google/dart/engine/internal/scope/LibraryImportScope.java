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
package com.google.dart.engine.internal.scope;

import com.google.dart.engine.ast.ASTNode;
import com.google.dart.engine.ast.FunctionDeclaration;
import com.google.dart.engine.ast.FunctionTypeAlias;
import com.google.dart.engine.ast.Identifier;
import com.google.dart.engine.ast.MethodDeclaration;
import com.google.dart.engine.ast.SimpleFormalParameter;
import com.google.dart.engine.ast.TypeArgumentList;
import com.google.dart.engine.ast.TypeName;
import com.google.dart.engine.ast.TypeParameter;
import com.google.dart.engine.ast.VariableDeclarationList;
import com.google.dart.engine.element.Element;
import com.google.dart.engine.element.ImportElement;
import com.google.dart.engine.element.LibraryElement;
import com.google.dart.engine.error.AnalysisError;
import com.google.dart.engine.error.AnalysisErrorListener;
import com.google.dart.engine.error.CompileTimeErrorCode;
import com.google.dart.engine.error.ErrorCode;
import com.google.dart.engine.error.StaticWarningCode;
import com.google.dart.engine.internal.element.MultiplyDefinedElementImpl;

import java.util.ArrayList;

/**
 * Instances of the class {@code LibraryImportScope} represent the scope containing all of the names
 * available from imported libraries.
 * 
 * @coverage dart.engine.resolver
 */
public class LibraryImportScope extends Scope {
  /**
   * @return {@code true} if the given {@link Identifier} is the part of type annotation.
   */
  private static boolean isTypeAnnotation(Identifier identifier) {
    ASTNode parent = identifier.getParent();
    if (parent instanceof TypeName) {
      ASTNode parent2 = parent.getParent();
      if (parent2 instanceof FunctionDeclaration) {
        FunctionDeclaration decl = (FunctionDeclaration) parent2;
        return decl.getReturnType() == parent;
      }
      if (parent2 instanceof FunctionTypeAlias) {
        FunctionTypeAlias decl = (FunctionTypeAlias) parent2;
        return decl.getReturnType() == parent;
      }
      if (parent2 instanceof MethodDeclaration) {
        MethodDeclaration decl = (MethodDeclaration) parent2;
        return decl.getReturnType() == parent;
      }
      if (parent2 instanceof VariableDeclarationList) {
        VariableDeclarationList decl = (VariableDeclarationList) parent2;
        return decl.getType() == parent;
      }
      if (parent2 instanceof SimpleFormalParameter) {
        SimpleFormalParameter decl = (SimpleFormalParameter) parent2;
        return decl.getType() == parent;
      }
      if (parent2 instanceof TypeParameter) {
        TypeParameter decl = (TypeParameter) parent2;
        return decl.getBound() == parent;
      }
      if (parent2 instanceof TypeArgumentList) {
        ASTNode parent3 = parent2.getParent();
        if (parent3 instanceof TypeName) {
          TypeName typeName = (TypeName) parent3;
          if ((typeName).getTypeArguments() == parent2) {
            return isTypeAnnotation(typeName.getName());
          }
        }
      }
      return false;
    }
    return false;
  }

  /**
   * The element representing the library in which this scope is enclosed.
   */
  private LibraryElement definingLibrary;

  /**
   * The listener that is to be informed when an error is encountered.
   */
  private AnalysisErrorListener errorListener;

  /**
   * A list of the namespaces representing the names that are available in this scope from imported
   * libraries.
   */
  private ArrayList<Namespace> importedNamespaces = new ArrayList<Namespace>();

  /**
   * Initialize a newly created scope representing the names imported into the given library.
   * 
   * @param definingLibrary the element representing the library that imports the names defined in
   *          this scope
   * @param errorListener the listener that is to be informed when an error is encountered
   */
  public LibraryImportScope(LibraryElement definingLibrary, AnalysisErrorListener errorListener) {
    this.definingLibrary = definingLibrary;
    this.errorListener = errorListener;
    createImportedNamespaces(definingLibrary);
  }

  @Override
  public void define(Element element) {
    if (!isPrivateName(element.getDisplayName())) {
      super.define(element);
    }
  }

  @Override
  public LibraryElement getDefiningLibrary() {
    return definingLibrary;
  }

  @Override
  public AnalysisErrorListener getErrorListener() {
    return errorListener;
  }

  @Override
  protected Element lookup(Identifier identifier, String name, LibraryElement referencingLibrary) {
    Element foundElement = localLookup(name, referencingLibrary);
    if (foundElement != null) {
      return foundElement;
    }
    for (Namespace nameSpace : importedNamespaces) {
      Element element = nameSpace.get(name);
      if (element != null) {
        if (foundElement == null) {
          foundElement = element;
        } else {
          foundElement = new MultiplyDefinedElementImpl(
              definingLibrary.getContext(),
              foundElement,
              element);
        }
      }
    }
    if (foundElement instanceof MultiplyDefinedElementImpl) {
      String foundEltName = foundElement.getDisplayName();
      String libName1 = "", libName2 = "";
      Element[] conflictingMembers = ((MultiplyDefinedElementImpl) foundElement).getConflictingElements();
      LibraryElement enclosingLibrary = conflictingMembers[0].getAncestor(LibraryElement.class);
      if (enclosingLibrary != null) {
        libName1 = enclosingLibrary.getDefiningCompilationUnit().getDisplayName();
      }
      enclosingLibrary = conflictingMembers[1].getAncestor(LibraryElement.class);
      if (enclosingLibrary != null) {
        libName2 = enclosingLibrary.getDefiningCompilationUnit().getDisplayName();
      }
      // TODO (jwren) Change the error message to include a list of all library names instead of
      // just the first two
      ErrorCode errorCode = isTypeAnnotation(identifier) ? StaticWarningCode.AMBIGUOUS_IMPORT
          : CompileTimeErrorCode.AMBIGUOUS_IMPORT;
      errorListener.onError(new AnalysisError(
          getSource(),
          identifier.getOffset(),
          identifier.getLength(),
          errorCode,
          foundEltName,
          libName1,
          libName2));
      return foundElement;
    }
    if (foundElement != null) {
      defineWithoutChecking(name, foundElement);
    }
    return foundElement;
  }

  /**
   * Create all of the namespaces associated with the libraries imported into this library. The
   * names are not added to this scope, but are stored for later reference.
   * 
   * @param definingLibrary the element representing the library that imports the libraries for
   *          which namespaces will be created
   */
  private final void createImportedNamespaces(LibraryElement definingLibrary) {
    NamespaceBuilder builder = new NamespaceBuilder();
    for (ImportElement element : definingLibrary.getImports()) {
      importedNamespaces.add(builder.createImportNamespace(element));
    }
  }
}
