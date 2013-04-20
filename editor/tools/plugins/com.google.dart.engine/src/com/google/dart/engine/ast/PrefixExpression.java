/*
 * Copyright 2011, the Dart project authors.
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
 * Instances of the class {@code PrefixExpression} represent a prefix unary expression.
 * 
 * <pre>
 * prefixExpression ::=
 *     {@link Token operator} {@link Expression operand}
 * </pre>
 * 
 * @coverage dart.engine.ast
 */
public class PrefixExpression extends Expression {
  /**
   * The prefix operator being applied to the operand.
   */
  private Token operator;

  /**
   * The expression computing the operand for the operator.
   */
  private Expression operand;

  /**
   * The element associated with the operator, or {@code null} if the AST structure has not been
   * resolved, if the operator is not user definable, or if the operator could not be resolved.
   */
  private MethodElement element;

  /**
   * Initialize a newly created prefix expression.
   * 
   * @param operator the prefix operator being applied to the operand
   * @param operand the expression computing the operand for the operator
   */
  public PrefixExpression(Token operator, Expression operand) {
    this.operator = operator;
    this.operand = becomeParentOf(operand);
  }

  @Override
  public <R> R accept(ASTVisitor<R> visitor) {
    return visitor.visitPrefixExpression(this);
  }

  @Override
  public Token getBeginToken() {
    return operator;
  }

  /**
   * Return the element associated with the operator, or {@code null} if the AST structure has not
   * been resolved, if the operator is not user definable, or if the operator could not be resolved.
   * One example of the latter case is an operator that is not defined for the type of the operand.
   * 
   * @return the element associated with the operator
   */
  public MethodElement getElement() {
    return element;
  }

  @Override
  public Token getEndToken() {
    return operand.getEndToken();
  }

  /**
   * Return the expression computing the operand for the operator.
   * 
   * @return the expression computing the operand for the operator
   */
  public Expression getOperand() {
    return operand;
  }

  /**
   * Return the prefix operator being applied to the operand.
   * 
   * @return the prefix operator being applied to the operand
   */
  public Token getOperator() {
    return operator;
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
   * Set the expression computing the operand for the operator to the given expression.
   * 
   * @param expression the expression computing the operand for the operator
   */
  public void setOperand(Expression expression) {
    operand = becomeParentOf(expression);
  }

  /**
   * Set the prefix operator being applied to the operand to the given operator.
   * 
   * @param operator the prefix operator being applied to the operand
   */
  public void setOperator(Token operator) {
    this.operator = operator;
  }

  @Override
  public void visitChildren(ASTVisitor<?> visitor) {
    safelyVisitChild(operand, visitor);
  }
}
