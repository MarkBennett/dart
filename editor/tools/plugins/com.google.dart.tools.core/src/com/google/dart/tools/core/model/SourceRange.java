/*
 * Copyright (c) 2011, the Dart project authors.
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
package com.google.dart.tools.core.model;

/**
 * A source range defines an element's source coordinates relative to its source buffer.
 * <p>
 * This interface is not intended to be implemented by clients. Provisional API: This
 * class/interface is part of an interim API that is still under development and expected to change
 * significantly before reaching stability. It is being made available at this early stage to
 * solicit feedback from pioneering adopters on the understanding that any code that uses this API
 * will almost certainly be broken (repeatedly) as the API evolves.
 */
public interface SourceRange {
  /**
   * Returns the number of characters of the source code for this element, relative to the source
   * buffer in which this element is contained.
   * 
   * @return the number of characters of the source code for this element, relative to the source
   *         buffer in which this element is contained
   */
  int getLength();

  /**
   * Returns the 0-based index of the first character of the source code for this element, relative
   * to the source buffer in which this element is contained.
   * 
   * @return the 0-based index of the first character of the source code for this element, relative
   *         to the source buffer in which this element is contained
   */
  int getOffset();
}
