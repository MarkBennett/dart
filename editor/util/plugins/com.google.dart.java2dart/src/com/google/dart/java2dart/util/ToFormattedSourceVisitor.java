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
package com.google.dart.java2dart.util;

import com.google.dart.engine.ast.*;
import com.google.dart.engine.scanner.Token;
import com.google.dart.engine.utilities.dart.ParameterKind;

import org.apache.commons.lang3.StringUtils;

import java.io.PrintWriter;

/**
 * Instances of the class {link ToFormattedSourceVisitor} write a source representation of a visited
 * AST node (and all of it's children) to a writer.
 */
public class ToFormattedSourceVisitor implements ASTVisitor<Void> {
  /**
   * The writer to which the source is to be written.
   */
  private PrintWriter writer;
  private int indentLevel = 0;
  private String indentString = "";

  /**
   * Initialize a newly created visitor to write source code representing the visited nodes to the
   * given writer.
   * 
   * @param writer the writer to which the source is to be written
   */
  public ToFormattedSourceVisitor(PrintWriter writer) {
    this.writer = writer;
  }

  @Override
  public Void visitAdjacentStrings(AdjacentStrings node) {
    visitList(node.getStrings(), " ");
    return null;
  }

  @Override
  public Void visitAnnotation(Annotation node) {
    writer.print('@');
    visit(node.getName());
    visit(".", node.getConstructorName());
    visit(node.getArguments());
    return null;
  }

  @Override
  public Void visitArgumentDefinitionTest(ArgumentDefinitionTest node) {
    writer.print('?');
    visit(node.getIdentifier());
    return null;
  }

  @Override
  public Void visitArgumentList(ArgumentList node) {
    writer.print('(');
    visitList(node.getArguments(), ", ");
    writer.print(')');
    return null;
  }

  @Override
  public Void visitAsExpression(AsExpression node) {
    visit(node.getExpression());
    writer.print(" as ");
    visit(node.getType());
    return null;
  }

  @Override
  public Void visitAssertStatement(AssertStatement node) {
    writer.print("assert(");
    visit(node.getCondition());
    writer.print(");");
    return null;
  }

  @Override
  public Void visitAssignmentExpression(AssignmentExpression node) {
    visit(node.getLeftHandSide());
    writer.print(' ');
    writer.print(node.getOperator().getLexeme());
    writer.print(' ');
    visit(node.getRightHandSide());
    return null;
  }

  @Override
  public Void visitBinaryExpression(BinaryExpression node) {
    visit(node.getLeftOperand());
    writer.print(' ');
    writer.print(node.getOperator().getLexeme());
    writer.print(' ');
    visit(node.getRightOperand());
    return null;
  }

  @Override
  public Void visitBlock(Block node) {
    writer.print('{');
    {
      indentInc();
      visitList(node.getStatements(), "\n");
      indentDec();
    }
    nl2();
    writer.print('}');
    return null;
  }

  @Override
  public Void visitBlockFunctionBody(BlockFunctionBody node) {
    visit(node.getBlock());
    return null;
  }

  @Override
  public Void visitBooleanLiteral(BooleanLiteral node) {
    writer.print(node.getLiteral().getLexeme());
    return null;
  }

  @Override
  public Void visitBreakStatement(BreakStatement node) {
    writer.print("break");
    visit(" ", node.getLabel());
    writer.print(";");
    return null;
  }

  @Override
  public Void visitCascadeExpression(CascadeExpression node) {
    visit(node.getTarget());
    visitList(node.getCascadeSections());
    return null;
  }

  @Override
  public Void visitCatchClause(CatchClause node) {
    visit("on ", node.getExceptionType());
    if (node.getCatchKeyword() != null) {
      if (node.getExceptionType() != null) {
        writer.print(' ');
      }
      writer.print("catch (");
      visit(node.getExceptionParameter());
      visit(", ", node.getStackTraceParameter());
      writer.print(") ");
    } else {
      writer.print(" ");
    }
    visit(node.getBody());
    return null;
  }

  @Override
  public Void visitClassDeclaration(ClassDeclaration node) {
    visit(node.getDocumentationComment());
    visit(node.getAbstractKeyword(), " ");
    writer.print("class ");
    visit(node.getName());
    visit(node.getTypeParameters());
    visit(" ", node.getExtendsClause());
    visit(" ", node.getWithClause());
    visit(" ", node.getImplementsClause());
    writer.print(" {");
    {
      indentInc();
      visitList(node.getMembers(), "\n");
      indentDec();
    }
    nl2();
    writer.print("}");
    return null;
  }

  @Override
  public Void visitClassTypeAlias(ClassTypeAlias node) {
    writer.print("typedef ");
    visit(node.getName());
    visit(node.getTypeParameters());
    writer.print(" = ");
    if (node.getAbstractKeyword() != null) {
      writer.print("abstract ");
    }
    visit(node.getSuperclass());
    visit(" ", node.getWithClause());
    visit(" ", node.getImplementsClause());
    writer.print(";");
    return null;
  }

  @Override
  public Void visitComment(Comment node) {
    Token token = node.getBeginToken();
    while (token != null) {
      boolean firstLine = true;
      for (String line : StringUtils.split(token.getLexeme(), "\n")) {
        if (firstLine) {
          firstLine = false;
        } else {
          line = " " + line.trim();
          line = StringUtils.replace(line, "/*", "/ *");
        }
        writer.print(line);
        nl2();
      }
      if (token == node.getEndToken()) {
        break;
      }
    }
    return null;
  }

  @Override
  public Void visitCommentReference(CommentReference node) {
    // We don't print comment references.
    return null;
  }

  @Override
  public Void visitCompilationUnit(CompilationUnit node) {
    ScriptTag scriptTag = node.getScriptTag();
    NodeList<Directive> directives = node.getDirectives();
    visit(scriptTag);
    String prefix = scriptTag == null ? "" : " ";
    visitList(prefix, directives, "\n");
    prefix = scriptTag == null && directives.isEmpty() ? "" : "\n\n";
    visitList(prefix, node.getDeclarations(), "\n");
    return null;
  }

  @Override
  public Void visitConditionalExpression(ConditionalExpression node) {
    visit(node.getCondition());
    writer.print(" ? ");
    visit(node.getThenExpression());
    writer.print(" : ");
    visit(node.getElseExpression());
    return null;
  }

  @Override
  public Void visitConstructorDeclaration(ConstructorDeclaration node) {
    visit(node.getDocumentationComment());
    visit(node.getExternalKeyword(), " ");
    visit(node.getConstKeyword(), " ");
    visit(node.getFactoryKeyword(), " ");
    visit(node.getReturnType());
    visit(".", node.getName());
    visit(node.getParameters());
    visitList(" : ", node.getInitializers(), ", ");
    visit(" = ", node.getRedirectedConstructor());
    if (!(node.getBody() instanceof EmptyFunctionBody)) {
      writer.print(' ');
    }
    visit(node.getBody());
    return null;
  }

  @Override
  public Void visitConstructorFieldInitializer(ConstructorFieldInitializer node) {
    visit(node.getKeyword(), ".");
    visit(node.getFieldName());
    writer.print(" = ");
    visit(node.getExpression());
    return null;
  }

  @Override
  public Void visitConstructorName(ConstructorName node) {
    visit(node.getType());
    visit(".", node.getName());
    return null;
  }

  @Override
  public Void visitContinueStatement(ContinueStatement node) {
    writer.print("continue");
    visit(" ", node.getLabel());
    writer.print(";");
    return null;
  }

  @Override
  public Void visitDeclaredIdentifier(DeclaredIdentifier node) {
    visit(node.getKeyword(), " ");
    visit(node.getType(), " ");
    visit(node.getIdentifier());
    return null;
  }

  @Override
  public Void visitDefaultFormalParameter(DefaultFormalParameter node) {
    visit(node.getParameter());
    if (node.getSeparator() != null) {
      writer.print(" ");
      writer.print(node.getSeparator().getLexeme());
      visit(" ", node.getDefaultValue());
    }
    return null;
  }

  @Override
  public Void visitDoStatement(DoStatement node) {
    writer.print("do ");
    visit(node.getBody());
    writer.print(" while (");
    visit(node.getCondition());
    writer.print(");");
    return null;
  }

  @Override
  public Void visitDoubleLiteral(DoubleLiteral node) {
    writer.print(node.getLiteral().getLexeme());
    return null;
  }

  @Override
  public Void visitEmptyFunctionBody(EmptyFunctionBody node) {
    writer.print(';');
    return null;
  }

  @Override
  public Void visitEmptyStatement(EmptyStatement node) {
    writer.print(';');
    return null;
  }

  @Override
  public Void visitExportDirective(ExportDirective node) {
    writer.print("export ");
    visit(node.getUri());
    visitList(" ", node.getCombinators(), " ");
    writer.print(';');
    return null;
  }

  @Override
  public Void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    writer.print("=> ");
    visit(node.getExpression());
    if (node.getSemicolon() != null) {
      writer.print(';');
    }
    return null;
  }

  @Override
  public Void visitExpressionStatement(ExpressionStatement node) {
    visit(node.getExpression());
    writer.print(';');
    return null;
  }

  @Override
  public Void visitExtendsClause(ExtendsClause node) {
    writer.print("extends ");
    visit(node.getSuperclass());
    return null;
  }

  @Override
  public Void visitFieldDeclaration(FieldDeclaration node) {
    visit(node.getDocumentationComment());
    visit(node.getKeyword(), " ");
    visit(node.getFields());
    writer.print(";");
    return null;
  }

  @Override
  public Void visitFieldFormalParameter(FieldFormalParameter node) {
    visit(node.getKeyword(), " ");
    visit(node.getType(), " ");
    writer.print("this.");
    visit(node.getIdentifier());
    return null;
  }

  @Override
  public Void visitForEachStatement(ForEachStatement node) {
    writer.print("for (");
    visit(node.getLoopVariable());
    writer.print(" in ");
    visit(node.getIterator());
    writer.print(") ");
    visit(node.getBody());
    return null;
  }

  @Override
  public Void visitFormalParameterList(FormalParameterList node) {
    String groupEnd = null;
    writer.print('(');
    NodeList<FormalParameter> parameters = node.getParameters();
    int size = parameters.size();
    for (int i = 0; i < size; i++) {
      FormalParameter parameter = parameters.get(i);
      if (i > 0) {
        writer.print(", ");
      }
      if (groupEnd == null && parameter instanceof DefaultFormalParameter) {
        if (parameter.getKind() == ParameterKind.NAMED) {
          groupEnd = "}";
          writer.print('{');
        } else {
          groupEnd = "]";
          writer.print('[');
        }
      }
      parameter.accept(this);
    }
    if (groupEnd != null) {
      writer.print(groupEnd);
    }
    writer.print(')');
    return null;
  }

  @Override
  public Void visitForStatement(ForStatement node) {
    Expression initialization = node.getInitialization();
    writer.print("for (");
    if (initialization != null) {
      visit(initialization);
    } else {
      visit(node.getVariables());
    }
    writer.print(";");
    visit(" ", node.getCondition());
    writer.print(";");
    visitList(" ", node.getUpdaters(), ", ");
    writer.print(") ");
    visit(node.getBody());
    return null;
  }

  @Override
  public Void visitFunctionDeclaration(FunctionDeclaration node) {
    visit(node.getReturnType(), " ");
    visit(node.getPropertyKeyword(), " ");
    visit(node.getName());
    visit(node.getFunctionExpression());
    return null;
  }

  @Override
  public Void visitFunctionDeclarationStatement(FunctionDeclarationStatement node) {
    visit(node.getFunctionDeclaration());
    writer.print(';');
    return null;
  }

  @Override
  public Void visitFunctionExpression(FunctionExpression node) {
    visit(node.getParameters());
    writer.print(' ');
    visit(node.getBody());
    return null;
  }

  @Override
  public Void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    visit(node.getFunction());
    visit(node.getArgumentList());
    return null;
  }

  @Override
  public Void visitFunctionTypeAlias(FunctionTypeAlias node) {
    writer.print("typedef ");
    visit(node.getReturnType(), " ");
    visit(node.getName());
    visit(node.getTypeParameters());
    visit(node.getParameters());
    writer.print(";");
    return null;
  }

  @Override
  public Void visitFunctionTypedFormalParameter(FunctionTypedFormalParameter node) {
    visit(node.getReturnType(), " ");
    visit(node.getIdentifier());
    visit(node.getParameters());
    return null;
  }

  @Override
  public Void visitHideCombinator(HideCombinator node) {
    writer.print("hide ");
    visitList(node.getHiddenNames(), ", ");
    return null;
  }

  @Override
  public Void visitIfStatement(IfStatement node) {
    writer.print("if (");
    visit(node.getCondition());
    writer.print(") ");
    visit(node.getThenStatement());
    visit(" else ", node.getElseStatement());
    return null;
  }

  @Override
  public Void visitImplementsClause(ImplementsClause node) {
    writer.print("implements ");
    visitList(node.getInterfaces(), ", ");
    return null;
  }

  @Override
  public Void visitImportDirective(ImportDirective node) {
    writer.print("import ");
    visit(node.getUri());
    visit(" as ", node.getPrefix());
    visitList(" ", node.getCombinators(), " ");
    writer.print(';');
    return null;
  }

  @Override
  public Void visitIndexExpression(IndexExpression node) {
    if (node.isCascaded()) {
      writer.print("..");
    } else {
      visit(node.getArray());
    }
    writer.print('[');
    visit(node.getIndex());
    writer.print(']');
    return null;
  }

  @Override
  public Void visitInstanceCreationExpression(InstanceCreationExpression node) {
    visit(node.getKeyword(), " ");
    visit(node.getConstructorName());
    visit(node.getArgumentList());
    return null;
  }

  @Override
  public Void visitIntegerLiteral(IntegerLiteral node) {
    writer.print(node.getLiteral().getLexeme());
    return null;
  }

  @Override
  public Void visitInterpolationExpression(InterpolationExpression node) {
    if (node.getRightBracket() != null) {
      writer.print("${");
      visit(node.getExpression());
      writer.print("}");
    } else {
      writer.print("$");
      visit(node.getExpression());
    }
    return null;
  }

  @Override
  public Void visitInterpolationString(InterpolationString node) {
    writer.print(node.getContents().getLexeme());
    return null;
  }

  @Override
  public Void visitIsExpression(IsExpression node) {
    visit(node.getExpression());
    if (node.getNotOperator() == null) {
      writer.print(" is ");
    } else {
      writer.print(" is! ");
    }
    visit(node.getType());
    return null;
  }

  @Override
  public Void visitLabel(Label node) {
    visit(node.getLabel());
    writer.print(":");
    return null;
  }

  @Override
  public Void visitLabeledStatement(LabeledStatement node) {
    visitList(node.getLabels(), " ", " ");
    visit(node.getStatement());
    return null;
  }

  @Override
  public Void visitLibraryDirective(LibraryDirective node) {
    writer.print("library ");
    visit(node.getName());
    writer.print(';');
    nl();
    return null;
  }

  @Override
  public Void visitLibraryIdentifier(LibraryIdentifier node) {
    writer.print(node.getName());
    return null;
  }

  @Override
  public Void visitListLiteral(ListLiteral node) {
    if (node.getModifier() != null) {
      writer.print(node.getModifier().getLexeme());
      writer.print(' ');
    }
    visit(node.getTypeArguments(), " ");
    writer.print("[");
    visitList(node.getElements(), ", ");
    writer.print("]");
    return null;
  }

  @Override
  public Void visitMapLiteral(MapLiteral node) {
    if (node.getModifier() != null) {
      writer.print(node.getModifier().getLexeme());
      writer.print(' ');
    }
    visit(node.getTypeArguments(), " ");
    writer.print("{");
    visitList(node.getEntries(), ", ");
    writer.print("}");
    return null;
  }

  @Override
  public Void visitMapLiteralEntry(MapLiteralEntry node) {
    visit(node.getKey());
    writer.print(" : ");
    visit(node.getValue());
    return null;
  }

  @Override
  public Void visitMethodDeclaration(MethodDeclaration node) {
    visit(node.getDocumentationComment());
    visit(node.getExternalKeyword(), " ");
    visit(node.getModifierKeyword(), " ");
    visit(node.getReturnType(), " ");
    visit(node.getPropertyKeyword(), " ");
    visit(node.getOperatorKeyword(), " ");
    visit(node.getName());
    if (!node.isGetter()) {
      visit(node.getParameters());
    }
    if (!(node.getBody() instanceof EmptyFunctionBody)) {
      writer.print(' ');
    }
    visit(node.getBody());
    return null;
  }

  @Override
  public Void visitMethodInvocation(MethodInvocation node) {
    if (node.isCascaded()) {
      writer.print("..");
    } else {
      visit(node.getTarget(), ".");
    }
    visit(node.getMethodName());
    visit(node.getArgumentList());
    return null;
  }

  @Override
  public Void visitNamedExpression(NamedExpression node) {
    visit(node.getName());
    visit(" ", node.getExpression());
    return null;
  }

  @Override
  public Void visitNativeFunctionBody(NativeFunctionBody node) {
    writer.print("native ");
    visit(node.getStringLiteral());
    writer.print(';');
    return null;
  }

  @Override
  public Void visitNullLiteral(NullLiteral node) {
    writer.print("null");
    return null;
  }

  @Override
  public Void visitParenthesizedExpression(ParenthesizedExpression node) {
    writer.print('(');
    visit(node.getExpression());
    writer.print(')');
    return null;
  }

  @Override
  public Void visitPartDirective(PartDirective node) {
    writer.print("part ");
    visit(node.getUri());
    writer.print(';');
    return null;
  }

  @Override
  public Void visitPartOfDirective(PartOfDirective node) {
    writer.print("part of ");
    visit(node.getLibraryName());
    writer.print(';');
    return null;
  }

  @Override
  public Void visitPostfixExpression(PostfixExpression node) {
    visit(node.getOperand());
    writer.print(node.getOperator().getLexeme());
    return null;
  }

  @Override
  public Void visitPrefixedIdentifier(PrefixedIdentifier node) {
    visit(node.getPrefix());
    writer.print('.');
    visit(node.getIdentifier());
    return null;
  }

  @Override
  public Void visitPrefixExpression(PrefixExpression node) {
    writer.print(node.getOperator().getLexeme());
    visit(node.getOperand());
    return null;
  }

  @Override
  public Void visitPropertyAccess(PropertyAccess node) {
    if (node.isCascaded()) {
      writer.print("..");
    } else {
      visit(node.getTarget(), ".");
    }
    visit(node.getPropertyName());
    return null;
  }

  @Override
  public Void visitRedirectingConstructorInvocation(RedirectingConstructorInvocation node) {
    writer.print("this");
    visit(".", node.getConstructorName());
    visit(node.getArgumentList());
    return null;
  }

  @Override
  public Void visitRethrowExpression(RethrowExpression node) {
    writer.print("rethrow");
    return null;
  }

  @Override
  public Void visitReturnStatement(ReturnStatement node) {
    Expression expression = node.getExpression();
    if (expression == null) {
      writer.print("return;");
    } else {
      writer.print("return ");
      expression.accept(this);
      writer.print(";");
    }
    return null;
  }

  @Override
  public Void visitScriptTag(ScriptTag node) {
    writer.print(node.getScriptTag().getLexeme());
    return null;
  }

  @Override
  public Void visitShowCombinator(ShowCombinator node) {
    writer.print("show ");
    visitList(node.getShownNames(), ", ");
    return null;
  }

  @Override
  public Void visitSimpleFormalParameter(SimpleFormalParameter node) {
    visit(node.getKeyword(), " ");
    visit(node.getType(), " ");
    visit(node.getIdentifier());
    return null;
  }

  @Override
  public Void visitSimpleIdentifier(SimpleIdentifier node) {
    writer.print(node.getToken().getLexeme());
    return null;
  }

  @Override
  public Void visitSimpleStringLiteral(SimpleStringLiteral node) {
    writer.print(node.getLiteral().getLexeme());
    return null;
  }

  @Override
  public Void visitStringInterpolation(StringInterpolation node) {
    visitList(node.getElements());
    return null;
  }

  @Override
  public Void visitSuperConstructorInvocation(SuperConstructorInvocation node) {
    writer.print("super");
    visit(".", node.getConstructorName());
    visit(node.getArgumentList());
    return null;
  }

  @Override
  public Void visitSuperExpression(SuperExpression node) {
    writer.print("super");
    return null;
  }

  @Override
  public Void visitSwitchCase(SwitchCase node) {
    visitList(node.getLabels(), " ", " ");
    writer.print("case ");
    visit(node.getExpression());
    writer.print(": ");
    {
      indentInc();
      visitList(node.getStatements(), "\n");
      indentDec();
    }
    return null;
  }

  @Override
  public Void visitSwitchDefault(SwitchDefault node) {
    visitList(node.getLabels(), " ", " ");
    writer.print("default: ");
    {
      indentInc();
      visitList(node.getStatements(), "\n");
      indentDec();
    }
    return null;
  }

  @Override
  public Void visitSwitchStatement(SwitchStatement node) {
    writer.print("switch (");
    visit(node.getExpression());
    writer.print(") {");
    {
      indentInc();
      visitList(node.getMembers(), "\n");
      indentDec();
    }
    nl2();
    writer.print('}');
    return null;
  }

  @Override
  public Void visitThisExpression(ThisExpression node) {
    writer.print("this");
    return null;
  }

  @Override
  public Void visitThrowExpression(ThrowExpression node) {
    writer.print("throw ");
    visit(node.getExpression());
    return null;
  }

  @Override
  public Void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    visit(node.getVariables(), ";");
    return null;
  }

  @Override
  public Void visitTryStatement(TryStatement node) {
    writer.print("try ");
    visit(node.getBody());
    visitList(" ", node.getCatchClauses(), " ");
    visit(" finally ", node.getFinallyClause());
    return null;
  }

  @Override
  public Void visitTypeArgumentList(TypeArgumentList node) {
    writer.print('<');
    visitList(node.getArguments(), ", ");
    writer.print('>');
    return null;
  }

  @Override
  public Void visitTypeName(TypeName node) {
    visit(node.getName());
    visit(node.getTypeArguments());
    return null;
  }

  @Override
  public Void visitTypeParameter(TypeParameter node) {
    visit(node.getName());
    visit(" extends ", node.getBound());
    return null;
  }

  @Override
  public Void visitTypeParameterList(TypeParameterList node) {
    writer.print('<');
    visitList(node.getTypeParameters(), ", ");
    writer.print('>');
    return null;
  }

  @Override
  public Void visitVariableDeclaration(VariableDeclaration node) {
    visit(node.getName());
    visit(" = ", node.getInitializer());
    return null;
  }

  @Override
  public Void visitVariableDeclarationList(VariableDeclarationList node) {
    visit(node.getKeyword(), " ");
    visit(node.getType(), " ");
    visitList(node.getVariables(), ", ");
    return null;
  }

  @Override
  public Void visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    visit(node.getVariables());
    writer.print(";");
    return null;
  }

  @Override
  public Void visitWhileStatement(WhileStatement node) {
    writer.print("while (");
    visit(node.getCondition());
    writer.print(") ");
    visit(node.getBody());
    return null;
  }

  @Override
  public Void visitWithClause(WithClause node) {
    writer.print("with ");
    visitList(node.getMixinTypes(), ", ");
    return null;
  }

  private void indent() {
    writer.print(indentString);
  }

  private void indentDec() {
    indentLevel -= 2;
    indentString = StringUtils.repeat(" ", indentLevel);
  }

  private void indentInc() {
    indentLevel += 2;
    indentString = StringUtils.repeat(" ", indentLevel);
  }

  private void nl() {
    writer.print("\n");
  }

  private void nl2() {
    nl();
    indent();
  }

  /**
   * Safely visit the given node.
   * 
   * @param node the node to be visited
   */
  private void visit(ASTNode node) {
    if (node != null) {
      node.accept(this);
    }
  }

  /**
   * Safely visit the given node, printing the suffix after the node if it is non-<code>null</code>.
   * 
   * @param suffix the suffix to be printed if there is a node to visit
   * @param node the node to be visited
   */
  private void visit(ASTNode node, String suffix) {
    if (node != null) {
      node.accept(this);
      writer.print(suffix);
    }
  }

  /**
   * Safely visit the given node, printing the prefix before the node if it is non-<code>null</code>
   * .
   * 
   * @param prefix the prefix to be printed if there is a node to visit
   * @param node the node to be visited
   */
  private void visit(String prefix, ASTNode node) {
    if (node != null) {
      writer.print(prefix);
      node.accept(this);
    }
  }

  /**
   * Safely visit the given node, printing the suffix after the node if it is non-<code>null</code>.
   * 
   * @param suffix the suffix to be printed if there is a node to visit
   * @param node the node to be visited
   */
  private void visit(Token token, String suffix) {
    if (token != null) {
      writer.print(token.getLexeme());
      writer.print(suffix);
    }
  }

  /**
   * Print a list of nodes without any separation.
   * 
   * @param nodes the nodes to be printed
   * @param separator the separator to be printed between adjacent nodes
   */
  private void visitList(NodeList<? extends ASTNode> nodes) {
    visitList(nodes, "");
  }

  /**
   * Print a list of nodes, separated by the given separator.
   * 
   * @param nodes the nodes to be printed
   * @param separator the separator to be printed between adjacent nodes
   */
  private void visitList(NodeList<? extends ASTNode> nodes, String separator) {
    if (nodes != null) {
      int size = nodes.size();
      for (int i = 0; i < size; i++) {
        if ("\n".equals(separator)) {
          writer.print("\n");
          indent();
        } else if (i > 0) {
          writer.print(separator);
        }
        nodes.get(i).accept(this);
      }
    }
  }

  /**
   * Print a list of nodes, separated by the given separator.
   * 
   * @param nodes the nodes to be printed
   * @param separator the separator to be printed between adjacent nodes
   * @param suffix the suffix to be printed if the list is not empty
   */
  private void visitList(NodeList<? extends ASTNode> nodes, String separator, String suffix) {
    if (nodes != null) {
      int size = nodes.size();
      if (size > 0) {
        for (int i = 0; i < size; i++) {
          if (i > 0) {
            writer.print(separator);
          }
          nodes.get(i).accept(this);
        }
        writer.print(suffix);
      }
    }
  }

  /**
   * Print a list of nodes, separated by the given separator.
   * 
   * @param prefix the prefix to be printed if the list is not empty
   * @param nodes the nodes to be printed
   * @param separator the separator to be printed between adjacent nodes
   */
  private void visitList(String prefix, NodeList<? extends ASTNode> nodes, String separator) {
    if (nodes != null) {
      int size = nodes.size();
      if (size > 0) {
        writer.print(prefix);
        for (int i = 0; i < size; i++) {
          if (i > 0) {
            writer.print(separator);
          }
          nodes.get(i).accept(this);
        }
      }
    }
  }
}
