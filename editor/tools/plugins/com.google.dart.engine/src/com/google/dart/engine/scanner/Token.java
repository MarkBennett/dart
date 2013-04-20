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
package com.google.dart.engine.scanner;

/**
 * Instances of the class {@code Token} represent a token that was scanned from the input. Each
 * token knows which token follows it, acting as the head of a linked list of tokens.
 * 
 * @coverage dart.engine.parser
 */
public class Token {
  /**
   * The type of the token.
   */
  private final TokenType type;

  /**
   * The offset from the beginning of the file to the first character in the token.
   */
  private int offset;

  /**
   * The previous token in the token stream.
   */
  private Token previous;

  /**
   * The next token in the token stream.
   */
  private Token next;

  /**
   * Initialize a newly created token to have the given type and offset.
   * 
   * @param type the type of the token
   * @param offset the offset from the beginning of the file to the first character in the token
   */
  public Token(TokenType type, int offset) {
    this.type = type;
    this.offset = offset;
  }

  /**
   * Return the offset from the beginning of the file to the character after last character of the
   * token.
   * 
   * @return the offset from the beginning of the file to the first character after last character
   *         of the token
   */
  public int getEnd() {
    return offset + getLength();
  }

  /**
   * Return the number of characters in the node's source range.
   * 
   * @return the number of characters in the node's source range
   */
  public int getLength() {
    return getLexeme().length();
  }

  /**
   * Return the lexeme that represents this token.
   * 
   * @return the lexeme that represents this token
   */
  public String getLexeme() {
    return type.getLexeme();
  }

  /**
   * Return the next token in the token stream.
   * 
   * @return the next token in the token stream
   */
  public Token getNext() {
    return next;
  }

  /**
   * Return the offset from the beginning of the file to the first character in the token.
   * 
   * @return the offset from the beginning of the file to the first character in the token
   */
  public int getOffset() {
    return offset;
  }

  /**
   * Return the first comment in the list of comments that precede this token, or {@code null} if
   * there are no comments preceding this token. Additional comments can be reached by following the
   * token stream using {@link #getNext()} until {@code null} is returned.
   * 
   * @return the first comment in the list of comments that precede this token
   */
  public Token getPrecedingComments() {
    return null;
  }

  /**
   * Return the previous token in the token stream.
   * 
   * @return the previous token in the token stream
   */
  public Token getPrevious() {
    return previous;
  }

  /**
   * Return the type of the token.
   * 
   * @return the type of the token
   */
  public TokenType getType() {
    return type;
  }

  /**
   * Return {@code true} if this token represents an operator.
   * 
   * @return {@code true} if this token represents an operator
   */
  public boolean isOperator() {
    return type.isOperator();
  }

  /**
   * Return {@code true} if this token is a synthetic token. A synthetic token is a token that was
   * introduced by the parser in order to recover from an error in the code. Synthetic tokens always
   * have a length of zero ({@code 0}).
   * 
   * @return {@code true} if this token is a synthetic token
   */
  public boolean isSynthetic() {
    return getLength() == 0;
  }

  /**
   * Return {@code true} if this token represents an operator that can be defined by users.
   * 
   * @return {@code true} if this token represents an operator that can be defined by users
   */
  public boolean isUserDefinableOperator() {
    return type.isUserDefinableOperator();
  }

  /**
   * Set the next token in the token stream to the given token. This has the side-effect of setting
   * this token to be the previous token for the given token.
   * 
   * @param token the next token in the token stream
   * @return the token that was passed in
   */
  public Token setNext(Token token) {
    next = token;
    token.setPrevious(this);
    return token;
  }

  /**
   * Set the next token in the token stream to the given token without changing which token is the
   * previous token for the given token.
   * 
   * @param token the next token in the token stream
   * @return the token that was passed in
   */
  public Token setNextWithoutSettingPrevious(Token token) {
    next = token;
    return token;
  }

  /**
   * Set the offset from the beginning of the file to the first character in the token to the given
   * offset.
   * 
   * @param offset the offset from the beginning of the file to the first character in the token
   */
  public void setOffset(int offset) {
    this.offset = offset;
  }

  @Override
  public String toString() {
    return getLexeme();
  }

  /**
   * Return the value of this token. For keyword tokens, this is the keyword associated with the
   * token, for other tokens it is the lexeme associated with the token.
   * 
   * @return the value of this token
   */
  public Object value() {
    return type.getLexeme();
  }

  /**
   * Set the previous token in the token stream to the given token.
   * 
   * @param previous the previous token in the token stream
   */
  private void setPrevious(Token previous) {
    this.previous = previous;
  }
}
