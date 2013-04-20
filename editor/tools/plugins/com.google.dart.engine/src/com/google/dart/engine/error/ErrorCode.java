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
package com.google.dart.engine.error;

/**
 * The interface {@code ErrorCode} defines the behavior common to objects representing error codes
 * associated with {@link AnalysisError analysis errors}.
 * 
 * @coverage dart.engine.error
 */
public interface ErrorCode {
  /**
   * Return the severity of this error.
   * 
   * @return the severity of this error
   */
  public ErrorSeverity getErrorSeverity();

  /**
   * Return the message template used to create the message to be displayed for this error.
   * 
   * @return the message template used to create the message to be displayed for this error
   */
  public String getMessage();

  /**
   * Return the type of the error.
   * 
   * @return the type of the error
   */
  public ErrorType getType();

  /**
   * Return {@code true} if this error should cause recompilation of the source during the next
   * incremental compilation.
   * 
   * @return {@code true} if this error should cause recompilation of the source during the next
   *         incremental compilation
   */
  public boolean needsRecompilation();
}
