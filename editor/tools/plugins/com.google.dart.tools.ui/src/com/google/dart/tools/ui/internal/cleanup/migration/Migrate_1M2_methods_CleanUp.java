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
package com.google.dart.tools.ui.internal.cleanup.migration;

import com.google.dart.compiler.ast.ASTVisitor;
import com.google.dart.compiler.ast.DartClass;
import com.google.dart.compiler.ast.DartExpression;
import com.google.dart.compiler.ast.DartIdentifier;
import com.google.dart.compiler.ast.DartMethodDefinition;
import com.google.dart.compiler.ast.DartMethodInvocation;
import com.google.dart.compiler.ast.DartPropertyAccess;
import com.google.dart.compiler.resolver.ClassElement;
import com.google.dart.compiler.resolver.Elements;
import com.google.dart.compiler.resolver.LibraryElement;
import com.google.dart.compiler.type.InterfaceType;
import com.google.dart.compiler.type.Type;
import com.google.dart.tools.core.utilities.general.SourceRangeFactory;

import org.eclipse.ltk.core.refactoring.TextChange;

/**
 * In 1.0 M2 library many methods become getters; and some of them were renamed.
 * 
 * @coverage dart.editor.ui.cleanup
 */
public class Migrate_1M2_methods_CleanUp extends AbstractMigrateCleanUp {
  static class MethodSpec {
    private final String libUri;
    private final String className;
    private final String methodName;
    private final String newName;

    public MethodSpec(String libUri, String className, String methodName) {
      this(libUri, className, methodName, null);
    }

    public MethodSpec(String libUri, String className, String methodName, String newName) {
      this.libUri = libUri;
      this.className = className;
      this.methodName = methodName;
      this.newName = newName;
    }
  }

  private static final MethodSpec[] METHOD_TO_GETTER_LIST = new MethodSpec[] {
      new MethodSpec("dart://core/core.dart", "Object", "hashCode"),
      new MethodSpec("dart://core/core.dart", "Iterator", "hasNext"),
      new MethodSpec("dart://core/core.dart", "Collection", "isEmpty"),
      new MethodSpec("dart://core/core.dart", "Map", "isEmpty"),
      new MethodSpec("dart://core/core.dart", "Map", "getKeys", "keys"),
      new MethodSpec("dart://core/core.dart", "Map", "getValues", "values"),
      new MethodSpec("dart://core/core.dart", "Match", "start"),
      new MethodSpec("dart://core/core.dart", "Match", "end"),
      new MethodSpec("dart://core/core.dart", "Match", "groupCount"),
      new MethodSpec("dart://core/core.dart", "List", "last"),
      new MethodSpec("dart://core/core.dart", "Queue", "first"),
      new MethodSpec("dart://core/core.dart", "Queue", "last"),
      new MethodSpec("dart://core/core.dart", "String", "charCodes"),
      new MethodSpec("dart://core/core.dart", "String", "isEmpty"),
      new MethodSpec("dart://core/core.dart", "StringBuffer", "isEmpty"),
      new MethodSpec("dart://core/core.dart", "num", "isNaN"),
      new MethodSpec("dart://core/core.dart", "num", "isInfinite"),
      new MethodSpec("dart://core/core.dart", "num", "isNegative"),
      new MethodSpec("dart://core/core.dart", "int", "isEven"),
      new MethodSpec("dart://core/core.dart", "int", "isOdd"),
      new MethodSpec("dart://core/core.dart", "Stopwatch", "frequency"),
      new MethodSpec("dart://core/core.dart", "Stopwatch", "elapsedInMs", "elapsedMilliseconds"),
      new MethodSpec("dart://core/core.dart", "Stopwatch", "elapsedInUs", "elapsedMicroseconds"),
      new MethodSpec("dart://core/core.dart", "Stopwatch", "elapsed", "elapsedTicks"),
      new MethodSpec(null, "_JustForInternalTest", "foo"),};

  private static final MethodSpec[] METHOD_RENAME_LIST = new MethodSpec[] {
      new MethodSpec("dart://io/io.dart", "File", "readAsText", "readAsString"),
      new MethodSpec(null, "_JustForInternalTest", "foo"),};

  private static final MethodSpec[] GETTER_RENAME_LIST = new MethodSpec[] {
      new MethodSpec("dart://html/dartium/html_dartium.dart", "Element", "elements", "children"),
      new MethodSpec(null, "_JustForInternalTest", "foo"),};

  static void convertMethodToGetter(TextChange change, DartMethodInvocation node, MethodSpec[] specs) {
    DartIdentifier nameNode = node.getFunctionName();
    if (node.getArguments().isEmpty()) {
      for (MethodSpec spec : specs) {
        if (Elements.isIdentifierName(nameNode, spec.methodName)) {
          Type targetType = node.getTarget().getType();
          if (targetType instanceof InterfaceType) {
            if (isSubType((InterfaceType) targetType, spec.className, spec.libUri)) {
              change.addEdit(createReplaceEdit(SourceRangeFactory.forEndEnd(nameNode, node), ""));
              // may be also rename
              if (spec.newName != null) {
                change.addEdit(createReplaceEdit(SourceRangeFactory.create(nameNode), spec.newName));
              }
            }
          }
        }
      }
    }
  }

  /**
   * @return <code>true</code> if given {@link InterfaceType} is sub type of required type from
   *         library with required name.
   */
  static boolean isSubType(InterfaceType type, String requiredName, String requiredLib) {
    if (type == null) {
      return false;
    }
    ClassElement element = type.getElement();
    if (element != null) {
      if (requiredName.equals(element.getName())) {
        if (requiredLib == null) {
          return true;
        }
        LibraryElement library = element.getLibrary();
        if (library != null && requiredLib.equals(library.getName())) {
          return true;
        }
      }
      if (isSubType(element.getSupertype(), requiredName, requiredLib)) {
        return true;
      }
      for (InterfaceType intf : element.getInterfaces()) {
        if (isSubType(intf, requiredName, requiredLib)) {
          return true;
        }
      }
    }
    return false;
  }

  @Override
  protected void createFix() {
    unitNode.accept(new ASTVisitor<Void>() {
      @Override
      public Void visitMethodDefinition(DartMethodDefinition node) {
        if (!node.getModifiers().isGetter() && node.getFunction().getParameters().isEmpty()
            && node.getParent() instanceof DartClass) {
          DartClass parentClass = (DartClass) node.getParent();
          for (MethodSpec spec : METHOD_TO_GETTER_LIST) {
            DartExpression nameNode = node.getName();
            if (Elements.isIdentifierName(nameNode, spec.methodName)) {
              InterfaceType parentType = parentClass.getElement().getType();
              if (isSubType(parentType, spec.className, spec.libUri)) {
                addReplaceEdit(SourceRangeFactory.forStartLength(nameNode, 0), "get ");
                addReplaceEdit(SourceRangeFactory.forEndEnd(
                    nameNode,
                    node.getFunction().getParametersCloseParen() + 1), "");
                break;
              }
            }
          }
        }
        return super.visitMethodDefinition(node);
      }

      @Override
      public Void visitMethodInvocation(DartMethodInvocation node) {
        DartIdentifier nameNode = node.getFunctionName();
        if (node.getTarget() != null) {
          // method => getter
          convertMethodToGetter(change, node, METHOD_TO_GETTER_LIST);
          // rename method
          for (MethodSpec spec : METHOD_RENAME_LIST) {
            if (Elements.isIdentifierName(nameNode, spec.methodName) && spec.newName != null) {
              Type targetType = node.getTarget().getType();
              if (targetType instanceof InterfaceType) {
                if (isSubType((InterfaceType) targetType, spec.className, spec.libUri)) {
                  addReplaceEdit(SourceRangeFactory.create(nameNode), spec.newName);
                }
              }
            }
          }
        }
        return super.visitMethodInvocation(node);
      }

      @Override
      public Void visitPropertyAccess(DartPropertyAccess node) {
        DartIdentifier nameNode = node.getName();
        for (MethodSpec spec : GETTER_RENAME_LIST) {
          if (Elements.isIdentifierName(nameNode, spec.methodName) && spec.newName != null) {
            Type targetType = node.getRealTarget().getType();
            if (targetType instanceof InterfaceType) {
              if (isSubType((InterfaceType) targetType, spec.className, spec.libUri)) {
                addReplaceEdit(SourceRangeFactory.create(nameNode), spec.newName);
              }
            }
          }
        }
        return super.visitPropertyAccess(node);
      }
    });
  }
}
