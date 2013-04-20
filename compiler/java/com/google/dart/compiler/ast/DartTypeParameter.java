// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.google.dart.compiler.ast;

import com.google.dart.compiler.resolver.Element;

/**
 * Represents a type parameter in a class or interface declaration.
 */
public class DartTypeParameter extends DartDeclaration<DartIdentifier> {

  private DartTypeNode bound;

  public DartTypeParameter(DartIdentifier name, DartTypeNode bound) {
    super(name);
    this.bound = becomeParentOf(bound);
  }

  public DartTypeNode getBound() {
    return bound;
  }

  @Override
  public void visitChildren(ASTVisitor<?> visitor) {
    super.visitChildren(visitor);
    safelyVisitChild(bound, visitor);
  }

  @Override
  public <R> R accept(ASTVisitor<R> visitor) {
    return visitor.visitTypeParameter(this);
  }
  
  @Override
  public Element getElement() {
    return getName().getElement();
  }
}
