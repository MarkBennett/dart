/*
 * Copyright 2012, the Dart project authors.
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
package com.google.dart.engine.ast;

import com.google.dart.engine.element.ParameterElement;
import com.google.dart.engine.type.Type;

/**
 * Instances of the class {@code Expression} defines the behavior common to nodes that represent an
 * expression.
 * 
 * <pre>
 * expression ::=
 *     {@link AssignmentExpression assignmentExpression}
 *   | {@link ConditionalExpression conditionalExpression} cascadeSection*
 *   | {@link ThrowExpression throwExpression}
 * </pre>
 * 
 * @coverage dart.engine.ast
 */
public abstract class Expression extends ASTNode {
  /**
   * The static type of this expression, or {@code null} if the AST structure has not been resolved.
   */
  private Type staticType;

  /**
   * The propagated type of this expression, or {@code null} if type propagation has not been
   * performed on the AST structure.
   */
  private Type propagatedType;

  /**
   * If this expression is an argument to an invocation, and the AST structure has been resolved,
   * and the function being invoked is known, and this expression corresponds to one of the
   * parameters of the function being invoked, then return the parameter element representing the
   * parameter to which the value of this expression will be bound. Otherwise, return {@code null}.
   * 
   * @return the parameter element representing the parameter to which the value of this expression
   *         will be bound
   */
  public ParameterElement getParameterElement() {
    ASTNode parent = getParent();
    if (parent instanceof ArgumentList) {
      return ((ArgumentList) parent).getParameterElementFor(this);
    }
    // TODO(brianwilkerson) Consider implementing this method for children of BinaryExpression,
    // IndexExpression, PrefixExpression, and PostfixExpression.
    return null;
  }

  /**
   * Return the propagated type of this expression, or {@code null} if type propagation has not been
   * performed on the AST structure.
   * 
   * @return the propagated type of this expression
   */
  public Type getPropagatedType() {
    return propagatedType;
  }

  /**
   * Return the static type of this expression, or {@code null} if the AST structure has not been
   * resolved.
   * 
   * @return the static type of this expression
   */
  public Type getStaticType() {
    return staticType;
  }

  /**
   * Return {@code true} if this expression is syntactically valid for the LHS of an
   * {@link AssignmentExpression assignment expression}.
   * 
   * @return {@code true} if this expression matches the {@code assignableExpression} production
   */
  public boolean isAssignable() {
    return false;
  }

  /**
   * Set the propagated type of this expression to the given type.
   * 
   * @param propagatedType the propagated type of this expression
   */
  public void setPropagatedType(Type propagatedType) {
    this.propagatedType = propagatedType;
  }

  /**
   * Set the static type of this expression to the given type.
   * 
   * @param staticType the static type of this expression
   */
  public void setStaticType(Type staticType) {
    this.staticType = staticType;
  }
}
