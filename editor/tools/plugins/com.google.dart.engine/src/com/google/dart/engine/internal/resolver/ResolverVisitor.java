/*
 * Copyright (c) 2013, the Dart project authors.
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
package com.google.dart.engine.internal.resolver;

import com.google.dart.engine.ast.ASTNode;
import com.google.dart.engine.ast.AsExpression;
import com.google.dart.engine.ast.AssertStatement;
import com.google.dart.engine.ast.BinaryExpression;
import com.google.dart.engine.ast.Block;
import com.google.dart.engine.ast.BreakStatement;
import com.google.dart.engine.ast.ClassDeclaration;
import com.google.dart.engine.ast.CommentReference;
import com.google.dart.engine.ast.CompilationUnit;
import com.google.dart.engine.ast.CompilationUnitMember;
import com.google.dart.engine.ast.ConditionalExpression;
import com.google.dart.engine.ast.ConstructorDeclaration;
import com.google.dart.engine.ast.ConstructorFieldInitializer;
import com.google.dart.engine.ast.ConstructorName;
import com.google.dart.engine.ast.ContinueStatement;
import com.google.dart.engine.ast.DeclaredIdentifier;
import com.google.dart.engine.ast.Directive;
import com.google.dart.engine.ast.DoStatement;
import com.google.dart.engine.ast.Expression;
import com.google.dart.engine.ast.ExpressionStatement;
import com.google.dart.engine.ast.FieldDeclaration;
import com.google.dart.engine.ast.ForEachStatement;
import com.google.dart.engine.ast.ForStatement;
import com.google.dart.engine.ast.FunctionBody;
import com.google.dart.engine.ast.FunctionDeclaration;
import com.google.dart.engine.ast.FunctionExpression;
import com.google.dart.engine.ast.HideCombinator;
import com.google.dart.engine.ast.IfStatement;
import com.google.dart.engine.ast.IsExpression;
import com.google.dart.engine.ast.Label;
import com.google.dart.engine.ast.LibraryIdentifier;
import com.google.dart.engine.ast.MethodDeclaration;
import com.google.dart.engine.ast.MethodInvocation;
import com.google.dart.engine.ast.NodeList;
import com.google.dart.engine.ast.ParenthesizedExpression;
import com.google.dart.engine.ast.PrefixExpression;
import com.google.dart.engine.ast.PrefixedIdentifier;
import com.google.dart.engine.ast.PropertyAccess;
import com.google.dart.engine.ast.RedirectingConstructorInvocation;
import com.google.dart.engine.ast.RethrowExpression;
import com.google.dart.engine.ast.ReturnStatement;
import com.google.dart.engine.ast.ShowCombinator;
import com.google.dart.engine.ast.SimpleIdentifier;
import com.google.dart.engine.ast.Statement;
import com.google.dart.engine.ast.SuperConstructorInvocation;
import com.google.dart.engine.ast.SwitchCase;
import com.google.dart.engine.ast.SwitchDefault;
import com.google.dart.engine.ast.ThrowExpression;
import com.google.dart.engine.ast.TopLevelVariableDeclaration;
import com.google.dart.engine.ast.TypeName;
import com.google.dart.engine.ast.WhileStatement;
import com.google.dart.engine.element.ClassElement;
import com.google.dart.engine.element.Element;
import com.google.dart.engine.element.ExecutableElement;
import com.google.dart.engine.element.LibraryElement;
import com.google.dart.engine.element.LocalVariableElement;
import com.google.dart.engine.element.ParameterElement;
import com.google.dart.engine.element.PropertyAccessorElement;
import com.google.dart.engine.element.PropertyInducingElement;
import com.google.dart.engine.element.VariableElement;
import com.google.dart.engine.error.AnalysisErrorListener;
import com.google.dart.engine.internal.type.BottomTypeImpl;
import com.google.dart.engine.scanner.TokenType;
import com.google.dart.engine.source.Source;
import com.google.dart.engine.type.InterfaceType;
import com.google.dart.engine.type.Type;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * Instances of the class {@code ResolverVisitor} are used to resolve the nodes within a single
 * compilation unit.
 * 
 * @coverage dart.engine.resolver
 */
public class ResolverVisitor extends ScopedVisitor {
  /**
   * The object used to resolve the element associated with the current node.
   */
  private ElementResolver elementResolver;

  /**
   * The object used to compute the type associated with the current node.
   */
  private StaticTypeAnalyzer typeAnalyzer;

  /**
   * The class element representing the class containing the current node, or {@code null} if the
   * current node is not contained in a class.
   */
  private ClassElement enclosingClass = null;

  /**
   * The element representing the function containing the current node, or {@code null} if the
   * current node is not contained in a function.
   */
  private ExecutableElement enclosingFunction = null;

  /**
   * The object keeping track of which elements have had their types overridden.
   */
  private TypeOverrideManager overrideManager = new TypeOverrideManager();

  /**
   * A table mapping nodes in the AST to the element produced based on static type information.
   */
  private HashMap<ASTNode, ExecutableElement> staticElementMap = new HashMap<ASTNode, ExecutableElement>();

  /**
   * Initialize a newly created visitor to resolve the nodes in a compilation unit.
   * 
   * @param library the library containing the compilation unit being resolved
   * @param source the source representing the compilation unit being visited
   * @param typeProvider the object used to access the types from the core library
   */
  public ResolverVisitor(Library library, Source source, TypeProvider typeProvider) {
    super(library, source, typeProvider);
    this.elementResolver = new ElementResolver(this);
    this.typeAnalyzer = new StaticTypeAnalyzer(this);
  }

  /**
   * Initialize a newly created visitor to resolve the nodes in a compilation unit.
   * 
   * @param definingLibrary the element for the library containing the compilation unit being
   *          visited
   * @param source the source representing the compilation unit being visited
   * @param typeProvider the object used to access the types from the core library
   * @param errorListener the error listener that will be informed of any errors that are found
   *          during resolution
   */
  public ResolverVisitor(LibraryElement definingLibrary, Source source, TypeProvider typeProvider,
      AnalysisErrorListener errorListener) {
    super(definingLibrary, source, typeProvider, errorListener);
    this.elementResolver = new ElementResolver(this);
    this.typeAnalyzer = new StaticTypeAnalyzer(this);
  }

  /**
   * Return the object keeping track of which elements have had their types overridden.
   * 
   * @return the object keeping track of which elements have had their types overridden
   */
  public TypeOverrideManager getOverrideManager() {
    return overrideManager;
  }

  /**
   * Return a table mapping nodes in the AST to the element produced based on static type
   * information.
   * 
   * @return the static element map
   */
  public HashMap<ASTNode, ExecutableElement> getStaticElementMap() {
    return staticElementMap;
  }

  @Override
  public Void visitAsExpression(AsExpression node) {
    super.visitAsExpression(node);
    VariableElement element = getOverridableElement(node.getExpression());
    if (element != null) {
      override(element, node.getType().getType());
    }
    return null;
  }

  @Override
  public Void visitAssertStatement(AssertStatement node) {
    super.visitAssertStatement(node);
    propagateTrueState(node.getCondition());
    return null;
  }

  @Override
  public Void visitBinaryExpression(BinaryExpression node) {
    TokenType operatorType = node.getOperator().getType();
    Expression leftOperand = node.getLeftOperand();
    Expression rightOperand = node.getRightOperand();
    if (operatorType == TokenType.AMPERSAND_AMPERSAND) {
      safelyVisit(leftOperand);
      if (rightOperand != null) {
        try {
          overrideManager.enterScope();
          propagateTrueState(leftOperand);
          rightOperand.accept(this);
        } finally {
          overrideManager.exitScope();
        }
      }
    } else if (operatorType == TokenType.BAR_BAR) {
      safelyVisit(leftOperand);
      if (rightOperand != null) {
        try {
          overrideManager.enterScope();
          propagateFalseState(leftOperand);
          rightOperand.accept(this);
        } finally {
          overrideManager.exitScope();
        }
      }
    } else {
      safelyVisit(leftOperand);
      safelyVisit(rightOperand);
    }
    node.accept(elementResolver);
    node.accept(typeAnalyzer);
    return null;
  }

  @Override
  public Void visitBreakStatement(BreakStatement node) {
    //
    // We do not visit the label because it needs to be visited in the context of the statement.
    //
    node.accept(elementResolver);
    node.accept(typeAnalyzer);
    return null;
  }

  @Override
  public Void visitClassDeclaration(ClassDeclaration node) {
    ClassElement outerType = enclosingClass;
    try {
      enclosingClass = node.getElement();
      typeAnalyzer.setThisType(enclosingClass == null ? null : enclosingClass.getType());
      super.visitClassDeclaration(node);
    } finally {
      typeAnalyzer.setThisType(outerType == null ? null : outerType.getType());
      enclosingClass = outerType;
    }
    return null;
  }

  @Override
  public Void visitCommentReference(CommentReference node) {
    //
    // We do not visit the identifier because it needs to be visited in the context of the reference.
    //
    node.accept(elementResolver);
    node.accept(typeAnalyzer);
    return null;
  }

  @Override
  public Void visitCompilationUnit(CompilationUnit node) {
    //
    // TODO(brianwilkerson) The goal of the code below is to visit the declarations in such an
    // order that we can infer type information for top-level variables before we visit references
    // to them. This is better than making no effort, but still doesn't completely satisfy that
    // goal (consider for example "final var a = b; final var b = 0;"; we'll infer a type of 'int'
    // for 'b', but not for 'a' because of the order of the visits). Ideally we would create a
    // dependency graph, but that would require references to be resolved, which they are not.
    //
    try {
      overrideManager.enterScope();
      for (Directive directive : node.getDirectives()) {
        directive.accept(this);
      }
      ArrayList<CompilationUnitMember> classes = new ArrayList<CompilationUnitMember>();
      for (CompilationUnitMember declaration : node.getDeclarations()) {
        if (declaration instanceof ClassDeclaration) {
          classes.add(declaration);
        } else {
          declaration.accept(this);
        }
      }
      for (CompilationUnitMember declaration : classes) {
        declaration.accept(this);
      }
    } finally {
      overrideManager.exitScope();
    }
    node.accept(elementResolver);
    node.accept(typeAnalyzer);
    return null;
  }

  @Override
  public Void visitConditionalExpression(ConditionalExpression node) {
    Expression condition = node.getCondition();
    safelyVisit(condition);
    Expression thenExpression = node.getThenExpression();
    if (thenExpression != null) {
      try {
        overrideManager.enterScope();
        propagateTrueState(condition);
        thenExpression.accept(this);
      } finally {
        overrideManager.exitScope();
      }
    }
    Expression elseExpression = node.getElseExpression();
    if (elseExpression != null) {
      try {
        overrideManager.enterScope();
        propagateFalseState(condition);
        elseExpression.accept(this);
      } finally {
        overrideManager.exitScope();
      }
    }
    node.accept(elementResolver);
    node.accept(typeAnalyzer);

    boolean thenIsAbrupt = isAbruptTermination(thenExpression);
    boolean elseIsAbrupt = isAbruptTermination(elseExpression);
    if (elseIsAbrupt && !thenIsAbrupt) {
      propagateTrueState(condition);
      propagateState(thenExpression);
    } else if (thenIsAbrupt && !elseIsAbrupt) {
      propagateFalseState(condition);
      propagateState(elseExpression);
    }
    return null;
  }

  @Override
  public Void visitConstructorDeclaration(ConstructorDeclaration node) {
    ExecutableElement outerFunction = enclosingFunction;
    try {
      enclosingFunction = node.getElement();
      super.visitConstructorDeclaration(node);
    } finally {
      enclosingFunction = outerFunction;
    }
    return null;
  }

  @Override
  public Void visitConstructorFieldInitializer(ConstructorFieldInitializer node) {
    //
    // We visit the expression, but do not visit the field name because it needs to be visited in
    // the context of the constructor field initializer node.
    //
    safelyVisit(node.getExpression());
    node.accept(elementResolver);
    node.accept(typeAnalyzer);
    return null;
  }

  @Override
  public Void visitConstructorName(ConstructorName node) {
    //
    // We do not visit either the type name, because it won't be visited anyway, or the name,
    // because it needs to be visited in the context of the constructor name.
    //
    node.accept(elementResolver);
    node.accept(typeAnalyzer);
    return null;
  }

  @Override
  public Void visitContinueStatement(ContinueStatement node) {
    //
    // We do not visit the label because it needs to be visited in the context of the statement.
    //
    node.accept(elementResolver);
    node.accept(typeAnalyzer);
    return null;
  }

  @Override
  public Void visitDoStatement(DoStatement node) {
    try {
      overrideManager.enterScope();
      super.visitDoStatement(node);
    } finally {
      overrideManager.exitScope();
    }
    // TODO(brianwilkerson) If the loop can only be exited because the condition is false, then
    // propagateFalseState(node.getCondition());
    return null;
  }

  @Override
  public Void visitFieldDeclaration(FieldDeclaration node) {
    try {
      overrideManager.enterScope();
      super.visitFieldDeclaration(node);
    } finally {
      HashMap<Element, Type> overrides = overrideManager.captureOverrides(node.getFields());
      overrideManager.exitScope();
      overrideManager.applyOverrides(overrides);
    }
    return null;
  }

  @Override
  public Void visitForEachStatement(ForEachStatement node) {
    try {
      overrideManager.enterScope();
      super.visitForEachStatement(node);
    } finally {
      overrideManager.exitScope();
    }
    return null;
  }

  @Override
  public Void visitForStatement(ForStatement node) {
    try {
      overrideManager.enterScope();
      super.visitForStatement(node);
    } finally {
      overrideManager.exitScope();
    }
    return null;
  }

  @Override
  public Void visitFunctionBody(FunctionBody node) {
    try {
      overrideManager.enterScope();
      super.visitFunctionBody(node);
    } finally {
      overrideManager.exitScope();
    }
    return null;
  }

  @Override
  public Void visitFunctionDeclaration(FunctionDeclaration node) {
    ExecutableElement outerFunction = enclosingFunction;
    try {
      SimpleIdentifier functionName = node.getName();
      enclosingFunction = (ExecutableElement) functionName.getElement();
      super.visitFunctionDeclaration(node);
    } finally {
      enclosingFunction = outerFunction;
    }
    return null;
  }

  @Override
  public Void visitFunctionExpression(FunctionExpression node) {
    ExecutableElement outerFunction = enclosingFunction;
    try {
      enclosingFunction = node.getElement();
      overrideManager.enterScope();
      super.visitFunctionExpression(node);
    } finally {
      overrideManager.exitScope();
      enclosingFunction = outerFunction;
    }
    return null;
  }

  @Override
  public Void visitHideCombinator(HideCombinator node) {
    //
    // Combinators aren't visited by this visitor, the LibraryResolver has already resolved the
    // identifiers and there is no type analysis to be done.
    //
    return null;
  }

  @Override
  public Void visitIfStatement(IfStatement node) {
    Expression condition = node.getCondition();
    safelyVisit(condition);
    HashMap<Element, Type> thenOverrides = null;
    Statement thenStatement = node.getThenStatement();
    if (thenStatement != null) {
      try {
        overrideManager.enterScope();
        propagateTrueState(condition);
        thenStatement.accept(this);
      } finally {
        thenOverrides = overrideManager.captureLocalOverrides();
        overrideManager.exitScope();
      }
    }
    HashMap<Element, Type> elseOverrides = null;
    Statement elseStatement = node.getElseStatement();
    if (elseStatement != null) {
      try {
        overrideManager.enterScope();
        propagateFalseState(condition);
        elseStatement.accept(this);
      } finally {
        elseOverrides = overrideManager.captureLocalOverrides();
        overrideManager.exitScope();
      }
    }
    node.accept(elementResolver);
    node.accept(typeAnalyzer);

    boolean thenIsAbrupt = isAbruptTermination(thenStatement);
    boolean elseIsAbrupt = isAbruptTermination(elseStatement);
    if (elseIsAbrupt && !thenIsAbrupt) {
      propagateTrueState(condition);
      if (thenOverrides != null) {
        overrideManager.applyOverrides(thenOverrides);
      }
    } else if (thenIsAbrupt && !elseIsAbrupt) {
      propagateFalseState(condition);
      if (elseOverrides != null) {
        overrideManager.applyOverrides(elseOverrides);
      }
    }
    return null;
  }

  @Override
  public Void visitLabel(Label node) {
    //
    // We don't visit labels or their children because they don't have a type. Instead, the element
    // resolver is responsible for resolving the labels in the context of their parent (either a
    // BreakStatement, ContinueStatement, or NamedExpression).
    //
    return null;
  }

  @Override
  public Void visitLibraryIdentifier(LibraryIdentifier node) {
    //
    // We don't visit library identifiers or their children because they have already been resolved.
    //
    return null;
  }

  @Override
  public Void visitMethodDeclaration(MethodDeclaration node) {
    ExecutableElement outerFunction = enclosingFunction;
    try {
      enclosingFunction = node.getElement();
      super.visitMethodDeclaration(node);
    } finally {
      enclosingFunction = outerFunction;
    }
    return null;
  }

  @Override
  public Void visitMethodInvocation(MethodInvocation node) {
    //
    // We visit the target and argument list, but do not visit the method name because it needs to
    // be visited in the context of the invocation.
    //
    safelyVisit(node.getTarget());
    safelyVisit(node.getArgumentList());
    node.accept(elementResolver);
    node.accept(typeAnalyzer);
    return null;
  }

  @Override
  public Void visitNode(ASTNode node) {
    node.visitChildren(this);
    node.accept(elementResolver);
    node.accept(typeAnalyzer);
    return null;
  }

  @Override
  public Void visitPrefixedIdentifier(PrefixedIdentifier node) {
    //
    // We visit the prefix, but do not visit the identifier because it needs to be visited in the
    // context of the prefix.
    //
    safelyVisit(node.getPrefix());
    node.accept(elementResolver);
    node.accept(typeAnalyzer);
    return null;
  }

  @Override
  public Void visitPropertyAccess(PropertyAccess node) {
    //
    // We visit the target, but do not visit the property name because it needs to be visited in the
    // context of the property access node.
    //
    safelyVisit(node.getTarget());
    node.accept(elementResolver);
    node.accept(typeAnalyzer);
    return null;
  }

  @Override
  public Void visitRedirectingConstructorInvocation(RedirectingConstructorInvocation node) {
    //
    // We visit the argument list, but do not visit the optional identifier because it needs to be
    // visited in the context of the constructor invocation.
    //
    safelyVisit(node.getArgumentList());
    node.accept(elementResolver);
    node.accept(typeAnalyzer);
    return null;
  }

  @Override
  public Void visitShowCombinator(ShowCombinator node) {
    //
    // Combinators aren't visited by this visitor, the LibraryResolver has already resolved the
    // identifiers and there is no type analysis to be done.
    //
    return null;
  }

  @Override
  public Void visitSuperConstructorInvocation(SuperConstructorInvocation node) {
    //
    // We visit the argument list, but do not visit the optional identifier because it needs to be
    // visited in the context of the constructor invocation.
    //
    safelyVisit(node.getArgumentList());
    node.accept(elementResolver);
    node.accept(typeAnalyzer);
    return null;
  }

  @Override
  public Void visitSwitchCase(SwitchCase node) {
    try {
      overrideManager.enterScope();
      super.visitSwitchCase(node);
    } finally {
      overrideManager.exitScope();
    }
    return null;
  }

  @Override
  public Void visitSwitchDefault(SwitchDefault node) {
    try {
      overrideManager.enterScope();
      super.visitSwitchDefault(node);
    } finally {
      overrideManager.exitScope();
    }
    return null;
  }

  @Override
  public Void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    try {
      overrideManager.enterScope();
      super.visitTopLevelVariableDeclaration(node);
    } finally {
      HashMap<Element, Type> overrides = overrideManager.captureOverrides(node.getVariables());
      overrideManager.exitScope();
      overrideManager.applyOverrides(overrides);
    }
    return null;
  }

  @Override
  public Void visitTypeName(TypeName node) {
    //
    // We don't visit type names or their children because they have already been resolved.
    //
    return null;
  }

  @Override
  public Void visitWhileStatement(WhileStatement node) {
    Expression condition = node.getCondition();
    safelyVisit(condition);
    Statement body = node.getBody();
    if (body != null) {
      try {
        overrideManager.enterScope();
        propagateTrueState(condition);
        body.accept(this);
      } finally {
        overrideManager.exitScope();
      }
    }
    // TODO(brianwilkerson) If the loop can only be exited because the condition is false, then
    // propagateFalseState(condition);
    node.accept(elementResolver);
    node.accept(typeAnalyzer);
    return null;
  }

  /**
   * Return the class element representing the class containing the current node, or {@code null} if
   * the current node is not contained in a class.
   * 
   * @return the class element representing the class containing the current node
   */
  protected ClassElement getEnclosingClass() {
    return enclosingClass;
  }

  /**
   * Return the element representing the function containing the current node, or {@code null} if
   * the current node is not contained in a function.
   * 
   * @return the element representing the function containing the current node
   */
  protected ExecutableElement getEnclosingFunction() {
    return enclosingFunction;
  }

  /**
   * Return the element associated with the given expression whose type can be overridden, or
   * {@code null} if there is no element whose type can be overridden.
   * 
   * @param expression the expression with which the element is associated
   * @return the element associated with the given expression
   */
  protected VariableElement getOverridableElement(Expression expression) {
    Element element = null;
    if (expression instanceof SimpleIdentifier) {
      element = ((SimpleIdentifier) expression).getElement();
    } else if (expression instanceof PrefixedIdentifier) {
      element = ((PrefixedIdentifier) expression).getElement();
    } else if (expression instanceof PropertyAccess) {
      element = ((PropertyAccess) expression).getPropertyName().getElement();
    }
    if (element instanceof VariableElement) {
      return (VariableElement) element;
    }
    return null;
  }

  /**
   * If it is appropriate to do so, override the current type of the given element with the given
   * type. Generally speaking, it is appropriate if the given type is more specific than the current
   * type.
   * 
   * @param element the element whose type might be overridden
   * @param potentialType the potential type of the element
   */
  protected void override(VariableElement element, Type potentialType) {
    if (potentialType == null || potentialType == BottomTypeImpl.getInstance()) {
      return;
    }
    if (element instanceof PropertyInducingElement) {
      PropertyInducingElement variable = (PropertyInducingElement) element;
      if (!variable.isConst() && !variable.isFinal()) {
        return;
      }
    }
    Type currentType = getBestType(element);
    if (currentType == null || !currentType.isMoreSpecificThan(potentialType)) {
      overrideManager.setType(element, potentialType);
    }
  }

  @Override
  protected void visitForEachStatementInScope(ForEachStatement node) {
    //
    // We visit the iterator before the loop variable because the loop variable cannot be in scope
    // while visiting the iterator.
    //
    Expression iterator = node.getIterator();
    safelyVisit(iterator);
    DeclaredIdentifier loopVariable = node.getLoopVariable();
    safelyVisit(loopVariable);
    Statement body = node.getBody();
    if (body != null) {
      try {
        overrideManager.enterScope();
        if (loopVariable != null && iterator != null) {
          LocalVariableElement loopElement = loopVariable.getElement();
          if (loopElement != null) {
            override(loopElement, getIteratorElementType(iterator));
          }
        }
        body.accept(this);
      } finally {
        overrideManager.exitScope();
      }
    }
    node.accept(elementResolver);
    node.accept(typeAnalyzer);
  }

  @Override
  protected void visitForStatementInScope(ForStatement node) {
    safelyVisit(node.getVariables());
    safelyVisit(node.getInitialization());
    safelyVisit(node.getCondition());
    overrideManager.enterScope();
    try {
      propagateTrueState(node.getCondition());
      safelyVisit(node.getBody());
      node.getUpdaters().accept(this);
    } finally {
      overrideManager.exitScope();
    }
    // TODO(brianwilkerson) If the loop can only be exited because the condition is false, then
    // propagateFalseState(condition);
  }

  /**
   * Return the best type information available for the given element. If the type of the element
   * has been overridden, then return the overriding type. Otherwise, return the static type.
   * 
   * @param element the element for which type information is to be returned
   * @return the best type information available for the given element
   */
  private Type getBestType(Element element) {
    Type bestType = overrideManager.getType(element);
    if (bestType == null) {
      if (element instanceof LocalVariableElement) {
        bestType = ((LocalVariableElement) element).getType();
      } else if (element instanceof ParameterElement) {
        bestType = ((ParameterElement) element).getType();
      }
    }
    return bestType;
  }

  /**
   * The given expression is the expression used to compute the iterator for a for-each statement.
   * Attempt to compute the type of objects that will be assigned to the loop variable and return
   * that type. Return {@code null} if the type could not be determined.
   * 
   * @param iterator the iterator for a for-each statement
   * @return the type of objects that will be assigned to the loop variable
   */
  private Type getIteratorElementType(Expression iteratorExpression) {
    Type expressionType = iteratorExpression.getStaticType();
    if (expressionType instanceof InterfaceType) {
      PropertyAccessorElement iterator = ((InterfaceType) expressionType).lookUpGetter(
          "iterator",
          getDefiningLibrary());
      if (iterator == null) {
        // TODO(brianwilkerson) Should we report this error?
        return null;
      }
      Type iteratorType = iterator.getType().getReturnType();
      if (iteratorType instanceof InterfaceType) {
        PropertyAccessorElement current = ((InterfaceType) iteratorType).lookUpGetter(
            "current",
            getDefiningLibrary());
        if (current == null) {
          // TODO(brianwilkerson) Should we report this error?
          return null;
        }
        return current.getType().getReturnType();
      }
    }
    return null;
  }

  /**
   * Return {@code true} if the given expression terminates abruptly (that is, if any expression
   * following the given expression will not be reached).
   * 
   * @param expression the expression being tested
   * @return {@code true} if the given expression terminates abruptly
   */
  private boolean isAbruptTermination(Expression expression) {
    // TODO(brianwilkerson) This needs to be significantly improved. Ideally we would eventually
    // turn this into a method on Expression that returns a termination indication (normal, abrupt
    // with no exception, abrupt with an exception).
    while (expression instanceof ParenthesizedExpression) {
      expression = ((ParenthesizedExpression) expression).getExpression();
    }
    return expression instanceof ThrowExpression || expression instanceof RethrowExpression;
  }

  /**
   * Return {@code true} if the given statement terminates abruptly (that is, if any statement
   * following the given statement will not be reached).
   * 
   * @param statement the statement being tested
   * @return {@code true} if the given statement terminates abruptly
   */
  private boolean isAbruptTermination(Statement statement) {
    // TODO(brianwilkerson) This needs to be significantly improved. Ideally we would eventually
    // turn this into a method on Statement that returns a termination indication (normal, abrupt
    // with no exception, abrupt with an exception).
    if (statement instanceof ReturnStatement || statement instanceof BreakStatement
        || statement instanceof ContinueStatement) {
      return true;
    } else if (statement instanceof ExpressionStatement) {
      return isAbruptTermination(((ExpressionStatement) statement).getExpression());
    } else if (statement instanceof Block) {
      NodeList<Statement> statements = ((Block) statement).getStatements();
      int size = statements.size();
      if (size == 0) {
        return false;
      }
      return isAbruptTermination(statements.get(size - 1));
    }
    return false;
  }

  /**
   * Propagate any type information that results from knowing that the given condition will have
   * been evaluated to 'false'.
   * 
   * @param condition the condition that will have evaluated to 'false'
   */
  private void propagateFalseState(Expression condition) {
    if (condition instanceof BinaryExpression) {
      BinaryExpression binary = (BinaryExpression) condition;
      if (binary.getOperator().getType() == TokenType.BAR_BAR) {
        propagateFalseState(binary.getLeftOperand());
        propagateFalseState(binary.getRightOperand());
      }
    } else if (condition instanceof IsExpression) {
      IsExpression is = (IsExpression) condition;
      if (is.getNotOperator() != null) {
        VariableElement element = getOverridableElement(is.getExpression());
        if (element != null) {
          override(element, is.getType().getType());
        }
      }
    } else if (condition instanceof PrefixExpression) {
      PrefixExpression prefix = (PrefixExpression) condition;
      if (prefix.getOperator().getType() == TokenType.BANG) {
        propagateTrueState(prefix.getOperand());
      }
    } else if (condition instanceof ParenthesizedExpression) {
      propagateFalseState(((ParenthesizedExpression) condition).getExpression());
    }
  }

  /**
   * Propagate any type information that results from knowing that the given expression will have
   * been evaluated without altering the flow of execution.
   * 
   * @param expression the expression that will have been evaluated
   */
  private void propagateState(Expression expression) {
    // TODO(brianwilkerson) Implement this.
  }

  /**
   * Propagate any type information that results from knowing that the given condition will have
   * been evaluated to 'true'.
   * 
   * @param condition the condition that will have evaluated to 'true'
   */
  private void propagateTrueState(Expression condition) {
    if (condition instanceof BinaryExpression) {
      BinaryExpression binary = (BinaryExpression) condition;
      if (binary.getOperator().getType() == TokenType.AMPERSAND_AMPERSAND) {
        propagateTrueState(binary.getLeftOperand());
        propagateTrueState(binary.getRightOperand());
      }
    } else if (condition instanceof IsExpression) {
      IsExpression is = (IsExpression) condition;
      if (is.getNotOperator() == null) {
        VariableElement element = getOverridableElement(is.getExpression());
        if (element != null) {
          override(element, is.getType().getType());
        }
      }
    } else if (condition instanceof PrefixExpression) {
      PrefixExpression prefix = (PrefixExpression) condition;
      if (prefix.getOperator().getType() == TokenType.BANG) {
        propagateFalseState(prefix.getOperand());
      }
    } else if (condition instanceof ParenthesizedExpression) {
      propagateTrueState(((ParenthesizedExpression) condition).getExpression());
    }
  }
}
