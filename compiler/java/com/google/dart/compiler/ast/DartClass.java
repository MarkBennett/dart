// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.google.dart.compiler.ast;

import com.google.dart.compiler.resolver.ClassNodeElement;
import com.google.dart.compiler.resolver.Element;

import java.util.List;

/**
 * Represents a Dart class.
 */
public class DartClass extends DartDeclaration<DartIdentifier> {

  private ClassNodeElement element;

  private DartTypeNode superclass;

  private final NodeList<DartNode> members = NodeList.create(this);
  private final NodeList<DartTypeParameter> typeParameters = NodeList.create(this);
  private final NodeList<DartTypeNode> interfaces = NodeList.create(this);
  private final NodeList<DartTypeNode> mixins = NodeList.create(this);

  private boolean isInterface;
  private DartParameterizedTypeNode defaultClass;
  private final Modifiers modifiers;

  // If the Dart class is implemented by a native JS class the nativeName
  // points to the JS class. Otherwise it is null.
  private final DartStringLiteral nativeName;

  private final int tokenOffset;
  private final int tokenLength;
  private final int defaultTokenOffset;
  private final int implementsOffset;
  private final int openBraceOffset;
  private final int closeBraceOffset;

  public DartClass(int tokenOffset, int tokenLength, DartIdentifier name,
      DartStringLiteral nativeName, DartTypeNode superclass, int implementsOffset,
      List<DartTypeNode> interfaces, List<DartTypeNode> mixins, int defaultTokenOffset,
      int openBraceOffset, int closeBraceOffset, List<DartNode> members,
      List<DartTypeParameter> typeParameters, DartParameterizedTypeNode defaultClass,
      boolean isInterface, Modifiers modifiers) {
    super(name);
    this.tokenOffset = tokenOffset;
    this.tokenLength = tokenLength;
    this.nativeName = becomeParentOf(nativeName);
    this.superclass = becomeParentOf(superclass);
    this.defaultTokenOffset = defaultTokenOffset;
    this.openBraceOffset = openBraceOffset;
    this.closeBraceOffset = closeBraceOffset;
    this.members.addAll(members);
    this.typeParameters.addAll(typeParameters);
    this.implementsOffset = implementsOffset;
    this.interfaces.addAll(interfaces);
    this.mixins.addAll(mixins);
    this.defaultClass = becomeParentOf(defaultClass);
    this.isInterface = isInterface;
    this.modifiers = modifiers;
  }

  public boolean isInterface() {
    return isInterface;
  }

  public Modifiers getModifiers() {
    return modifiers;
  }

  public boolean isAbstract() {
    if (modifiers.isAbstract()) {
      return true;
    }
    for (DartNode node : members) {
      if (node instanceof DartMethodDefinition) {
        DartMethodDefinition methodDefinition = (DartMethodDefinition) node;
        if (methodDefinition.getModifiers().isAbstract()) {
          return true;
        }
      }
      if (node instanceof DartFieldDefinition) {
        DartFieldDefinition fieldDefinition = (DartFieldDefinition) node;
        for (DartField field : fieldDefinition.getFields()) {
          if (field.getModifiers().isAbstract()) {
            return true;
          }
        }
      }
    }
    return false;
  }

  public int getTokenOffset() {
    return tokenOffset;
  }
  
  public int getTokenLength() {
    return tokenLength;
  }
  
  public int getDefaultTokenOffset() {
    return defaultTokenOffset;
  }
  
  public int getOpenBraceOffset() {
    return openBraceOffset;
  }
  
  public int getCloseBraceOffset() {
    return closeBraceOffset;
  }

  public List<DartNode> getMembers() {
    return members;
  }

  public List<DartTypeParameter> getTypeParameters() {
    return typeParameters;
  }
  
  public int getImplementsOffset() {
    return implementsOffset;
  }

  public List<DartTypeNode> getInterfaces() {
    return interfaces;
  }
  
  public NodeList<DartTypeNode> getMixins() {
    return mixins;
  }

  public String getClassName() {
    if (getName() == null) {
      return null;
    }
    return getName().getName();
  }

  public DartTypeNode getSuperclass() {
    return superclass;
  }

  public DartParameterizedTypeNode getDefaultClass() {
    return defaultClass;
  }

  public Element getDefaultSymbol() {
    if (defaultClass != null) {
      return defaultClass.getType().getElement();
    } else {
      return null;
    }
  }

  public Element getSuperSymbol() {
    if (superclass != null) {
      return superclass.getType().getElement();
    } else {
      return null;
    }
  }

  @Override
  public ClassNodeElement getElement() {
    return element;
  }

  public void setDefaultClass(DartParameterizedTypeNode newName) {
    defaultClass = becomeParentOf(newName);
  }

  public void setSuperclass(DartTypeNode newName) {
    superclass = becomeParentOf(newName);
  }

  @Override
  public void setElement(Element element) {
    this.element = (ClassNodeElement) element;
  }

  public DartStringLiteral getNativeName() {
    return nativeName;
  }

  @Override
  public void visitChildren(ASTVisitor<?> visitor) {
    super.visitChildren(visitor);
    typeParameters.accept(visitor);
    safelyVisitChild(superclass, visitor);
    interfaces.accept(visitor);
    mixins.accept(visitor);
    safelyVisitChild(defaultClass, visitor);
    members.accept(visitor);
  }

  @Override
  public <R> R accept(ASTVisitor<R> visitor) {
    return visitor.visitClass(this);
  }
}
