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
package com.google.dart.engine.element;

/**
 * The interface {@code NamespaceCombinator} defines the behavior common to objects that control how
 * namespaces are combined.
 * 
 * @coverage dart.engine.element
 */
public interface NamespaceCombinator {
  /**
   * An empty array of namespace combinators.
   */
  public static final NamespaceCombinator[] EMPTY_ARRAY = new NamespaceCombinator[0];
}
