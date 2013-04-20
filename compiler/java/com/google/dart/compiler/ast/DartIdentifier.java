// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.google.dart.compiler.ast;

import com.google.dart.compiler.resolver.Element;
import com.google.dart.compiler.util.StringInterner;

/**
 * Represents a Dart identifier expression.
 */
public class DartIdentifier extends DartExpression {

  private final String name;
  private Element element;
  private boolean resolutionAlreadyReportedThatTheMethodCouldNotBeFound;

  public DartIdentifier(String name) {
    assert name != null;
    this.name = StringInterner.intern(name);
  }

  public DartIdentifier(DartIdentifier original) {
    this.name = StringInterner.intern(original.name);
  }

  @Override
  public Element getElement() {
    return element;
  }

  @Override
  // Note: final added for performance reasons.
  public final String toString() {
    return name;
  }

  @Override
  public boolean isAssignable() {
    return true;
  }

  public String getName() {
    return name;
  }

  @Override
  public void setElement(Element element) {
    this.element = element;
  }

  /**
   * Specifies that this name was not found it enclosing {@link Element}.
   */
  public void markResolutionAlreadyReportedThatTheMethodCouldNotBeFound() {
    this.resolutionAlreadyReportedThatTheMethodCouldNotBeFound = true;
  }
  
  /**
   * @return <code>true</code> if we know that this name was not found in its enclosing
   *         {@link Element}, and error was already reported.
   */
  public boolean isResolutionAlreadyReportedThatTheMethodCouldNotBeFound() {
    return resolutionAlreadyReportedThatTheMethodCouldNotBeFound;
  }

  @Override
  public final void visitChildren(ASTVisitor<?> visitor) {
  }

  @Override
  public <R> R accept(ASTVisitor<R> visitor) {
    return visitor.visitIdentifier(this);
  }

  public static boolean isPrivateName(String name) {
    return name.startsWith("_");
  }
}
