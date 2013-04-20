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

import com.google.dart.engine.element.MethodElement;
import com.google.dart.engine.scanner.Token;

/**
 * Instances of the class {@code AssignmentExpression} represent an assignment expression.
 * 
 * <pre>
 * assignmentExpression ::=
 *     {@link Expression leftHandSide} {@link Token operator} {@link Expression rightHandSide}
 * </pre>
 * 
 * @coverage dart.engine.ast
 */
public class AssignmentExpression extends Expression {
  /**
   * The expression used to compute the left hand side.
   */
  private Expression leftHandSide;

  /**
   * The assignment operator being applied.
   */
  private Token operator;

  /**
   * The expression used to compute the right hand side.
   */
  private Expression rightHandSide;

  /**
   * The element associated with the operator, or {@code null} if the AST structure has not been
   * resolved, if the operator is not a compound operator, or if the operator could not be resolved.
   */
  private MethodElement element;

  /**
   * Initialize a newly created assignment expression.
   * 
   * @param leftHandSide the expression used to compute the left hand side
   * @param operator the assignment operator being applied
   * @param rightHandSide the expression used to compute the right hand side
   */
  public AssignmentExpression(Expression leftHandSide, Token operator, Expression rightHandSide) {
    this.leftHandSide = becomeParentOf(leftHandSide);
    this.operator = operator;
    this.rightHandSide = becomeParentOf(rightHandSide);
  }

  @Override
  public <R> R accept(ASTVisitor<R> visitor) {
    return visitor.visitAssignmentExpression(this);
  }

  @Override
  public Token getBeginToken() {
    return leftHandSide.getBeginToken();
  }

  /**
   * Return the element associated with the operator, or {@code null} if the AST structure has not
   * been resolved, if the operator is not a compound operator, or if the operator could not be
   * resolved. One example of the latter case is an operator that is not defined for the type of the
   * left-hand operand.
   * 
   * @return the element associated with the operator
   */
  public MethodElement getElement() {
    return element;
  }

  @Override
  public Token getEndToken() {
    return rightHandSide.getEndToken();
  }

  /**
   * Set the expression used to compute the left hand side to the given expression.
   * 
   * @return the expression used to compute the left hand side
   */
  public Expression getLeftHandSide() {
    return leftHandSide;
  }

  /**
   * Return the assignment operator being applied.
   * 
   * @return the assignment operator being applied
   */
  public Token getOperator() {
    return operator;
  }

  /**
   * Return the expression used to compute the right hand side.
   * 
   * @return the expression used to compute the right hand side
   */
  public Expression getRightHandSide() {
    return rightHandSide;
  }

  /**
   * Set the element associated with the operator to the given element.
   * 
   * @param element the element associated with the operator
   */
  public void setElement(MethodElement element) {
    this.element = element;
  }

  /**
   * Return the expression used to compute the left hand side.
   * 
   * @param expression the expression used to compute the left hand side
   */
  public void setLeftHandSide(Expression expression) {
    leftHandSide = becomeParentOf(expression);
  }

  /**
   * Set the assignment operator being applied to the given operator.
   * 
   * @param operator the assignment operator being applied
   */
  public void setOperator(Token operator) {
    this.operator = operator;
  }

  /**
   * Set the expression used to compute the left hand side to the given expression.
   * 
   * @param expression the expression used to compute the left hand side
   */
  public void setRightHandSide(Expression expression) {
    rightHandSide = becomeParentOf(expression);
  }

  @Override
  public void visitChildren(ASTVisitor<?> visitor) {
    safelyVisitChild(leftHandSide, visitor);
    safelyVisitChild(rightHandSide, visitor);
  }
}
