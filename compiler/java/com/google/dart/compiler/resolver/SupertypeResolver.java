// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.google.dart.compiler.resolver;

import com.google.common.base.Objects;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Sets;
import com.google.dart.compiler.DartCompilerContext;
import com.google.dart.compiler.Source;
import com.google.dart.compiler.ast.ASTVisitor;
import com.google.dart.compiler.ast.DartClass;
import com.google.dart.compiler.ast.DartClassTypeAlias;
import com.google.dart.compiler.ast.DartFunctionTypeAlias;
import com.google.dart.compiler.ast.DartParameterizedTypeNode;
import com.google.dart.compiler.ast.DartTypeNode;
import com.google.dart.compiler.ast.DartTypeParameter;
import com.google.dart.compiler.ast.DartUnit;
import com.google.dart.compiler.type.InterfaceType;
import com.google.dart.compiler.type.Type;
import com.google.dart.compiler.type.TypeKind;

import java.util.List;
import java.util.Set;

/**
 * Resolves the super class, interfaces, default implementation and
 * bounds type parameters of classes in a DartUnit.
 */
public class SupertypeResolver {
  private static final Set<String> BLACK_LISTED_TYPES = ImmutableSet.of(
      "dynamic",
      "Function",
      "bool",
      "num",
      "int",
      "double",
      "String");

  private ResolutionContext topLevelContext;
  private CoreTypeProvider typeProvider;

  public void exec(DartUnit unit, DartCompilerContext context, CoreTypeProvider typeProvider) {
    exec(unit, context, unit.getLibrary().getElement().getScope(), typeProvider);
  }

  public void exec(DartUnit unit, DartCompilerContext compilerContext, Scope libraryScope,
                   CoreTypeProvider typeProvider) {
    this.typeProvider = typeProvider;
    this.topLevelContext = new ResolutionContext(libraryScope, compilerContext, typeProvider);
    unit.accept(new ClassElementResolver());
  }

  // Resolves super class, interfaces and default class of all classes.
  private class ClassElementResolver extends ASTVisitor<Void> {
    @Override
    public Void visitClass(DartClass node) {
      ClassElement classElement = node.getElement();

      // Make sure that the type parameters are in scope before resolving the
      // super class and interfaces
      ResolutionContext classContext = topLevelContext.extend(classElement);

      DartTypeNode superclassNode = node.getSuperclass();
      List<DartTypeNode> mixins = node.getMixins();
      List<DartTypeNode> interfaces = node.getInterfaces();

      visitClassLike(classElement, classContext, superclassNode, mixins, interfaces,
          node.getDefaultClass());
      return null;
    }

    @Override
    public Void visitClassTypeAlias(DartClassTypeAlias node) {
      ClassElement classElement = node.getElement();
      
      // Make sure that the type parameters are in scope before resolving the
      // super class and interfaces
      ResolutionContext classContext = topLevelContext.extend(classElement);
      
      DartTypeNode superclassNode = node.getSuperclass();
      List<DartTypeNode> mixins = node.getMixins();
      List<DartTypeNode> interfaces = node.getInterfaces();
      
      visitClassLike(classElement, classContext, superclassNode, mixins, interfaces, null);
      return null;
    }

    private void visitClassLike(ClassElement classElement, ResolutionContext classContext,
        DartTypeNode superclassNode, List<DartTypeNode> mixins, List<DartTypeNode> interfaces,
        DartParameterizedTypeNode defaultClassNode) {
      Source source = classElement.getSourceInfo().getSource();
      InterfaceType supertype;
      if (superclassNode == null) {
        supertype = typeProvider.getObjectType();
        if (supertype.equals(classElement.getType())) {
          // Object has no supertype.
          supertype = null;
        }
      } else {
        supertype = classContext.resolveClass(superclassNode, false, false);
        supertype.getClass(); // Quick null check.
      }
      if (supertype != null) {
        if (Elements.isTypeNode(superclassNode, BLACK_LISTED_TYPES)
            && !Elements.isCoreLibrarySource(source)) {
          topLevelContext.onError(
              superclassNode,
              ResolverErrorCode.BLACK_LISTED_EXTENDS,
              superclassNode);
        }
        classElement.setSupertype(supertype);
      } else {
        assert classElement.getName().equals("Object") : classElement;
      }

      if (defaultClassNode != null) {
        Element defaultClassElement = classContext.resolveName(defaultClassNode.getExpression());
        if (ElementKind.of(defaultClassElement).equals(ElementKind.CLASS)) {
          Elements.setDefaultClass(classElement, (InterfaceType)defaultClassElement.getType());
          defaultClassNode.setType(defaultClassElement.getType());
        }
      }

      if (interfaces != null) {
        Set<InterfaceType> seenImplement = Sets.newHashSet();
        for (DartTypeNode intNode : interfaces) {
          InterfaceType intType = classContext.resolveInterface(intNode, false, false);
          // May be type which can not be used as interface.
          if (Elements.isTypeNode(intNode, BLACK_LISTED_TYPES)
              && !Elements.isCoreLibrarySource(source)) {
            topLevelContext.onError(intNode, ResolverErrorCode.BLACK_LISTED_IMPLEMENTS, intNode);
            continue;
          }
          // May be unresolved type, error already reported, ignore.
          if (intType.getKind() == TypeKind.DYNAMIC) {
            continue;
          }
          // check for uniqueness
          if (!classElement.isInterface()) {
            if (seenImplement.contains(intType)) {
              topLevelContext.onError(intNode, ResolverErrorCode.DUPLICATE_IMPLEMENTS_TYPE);
              continue;
            }
            if (Objects.equal(intType, supertype)) {
              topLevelContext.onError(intNode, ResolverErrorCode.SUPER_CLASS_IN_IMPLEMENTS);
              continue;
            }
            seenImplement.add(intType);
          }
          // OK, add
          Elements.addInterface(classElement, intType);
        }
      }
      
      if (mixins != null) {
        Set<InterfaceType> seenMixin = Sets.newHashSet();
        for (DartTypeNode mixNode : mixins) {
          InterfaceType mixType = classContext.resolveInterface(mixNode, false, false);
          // May be type which can not be used as interface.
          if (Elements.isTypeNode(mixNode, BLACK_LISTED_TYPES)
              && !Elements.isCoreLibrarySource(source)) {
            topLevelContext.onError(mixNode, ResolverErrorCode.BLACK_LISTED_MIXINS, mixNode);
            continue;
          }
          // May be unresolved type, error already reported, ignore.
          if (mixType.getKind() == TypeKind.DYNAMIC) {
            continue;
          }
          // check for uniqueness
          if (seenMixin.contains(mixType)) {
            topLevelContext.onError(mixNode, ResolverErrorCode.DUPLICATE_WITH_TYPE);
            continue;
          }
          if (Objects.equal(mixType, supertype)) {
            topLevelContext.onError(mixNode, ResolverErrorCode.SUPER_CLASS_IN_WITH);
            continue;
          }
          seenMixin.add(mixType);
          // OK, add
          Elements.addMixin(classElement, mixType);
        }
      }
      setBoundsOnTypeParameters(classElement.getTypeParameters(), classContext);
    }

    @Override
    public Void visitFunctionTypeAlias(DartFunctionTypeAlias node) {
      ResolutionContext resolutionContext = topLevelContext.extend(node.getElement());
      Elements.addInterface(node.getElement(), typeProvider.getFunctionType());
      setBoundsOnTypeParameters(node.getElement().getTypeParameters(), resolutionContext);
      return null;
    }
  }

  private void setBoundsOnTypeParameters(List<Type> typeParameters,
                                         ResolutionContext resolutionContext) {
    for (Type typeParameter : typeParameters) {
      TypeVariableNodeElement variable = (TypeVariableNodeElement) typeParameter.getElement();
      DartTypeParameter typeParameterNode = (DartTypeParameter) variable.getNode();
      DartTypeNode boundNode = typeParameterNode.getBound();
      if (boundNode != null) {
        Type bound =
            resolutionContext.resolveType(
                boundNode,
                false,
                false,
                true,
                ResolverErrorCode.NO_SUCH_TYPE,
                ResolverErrorCode.WRONG_NUMBER_OF_TYPE_ARGUMENTS);
        boundNode.setType(bound);
      }
    }
  }

}
