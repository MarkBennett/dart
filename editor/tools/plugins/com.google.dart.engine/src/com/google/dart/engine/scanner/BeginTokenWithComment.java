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
 * Instances of the class {@code BeginTokenWithComment} represent a begin token that is preceded by
 * comments.
 * 
 * @coverage dart.engine.parser
 */
public class BeginTokenWithComment extends BeginToken {
  /**
   * The first comment in the list of comments that precede this token.
   */
  private Token precedingComment;

  /**
   * Initialize a newly created token to have the given type and offset and to be preceded by the
   * comments reachable from the given comment.
   * 
   * @param type the type of the token
   * @param offset the offset from the beginning of the file to the first character in the token
   * @param precedingComment the first comment in the list of comments that precede this token
   */
  public BeginTokenWithComment(TokenType type, int offset, Token precedingComment) {
    super(type, offset);
    this.precedingComment = precedingComment;
  }

  @Override
  public Token getPrecedingComments() {
    return precedingComment;
  }
}
