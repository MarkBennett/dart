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
package com.google.dart.engine.html.scanner;

import com.google.dart.engine.source.Source;

/**
 * Instances of the class {@code StringScanner} implement a scanner that reads from a string. The
 * scanning logic is in the superclass.
 * 
 * @coverage dart.engine.html
 */
public class StringScanner extends AbstractScanner {

  /**
   * The string from which characters will be read.
   */
  private final String string;

  /**
   * The number of characters in the string.
   */
  private final int stringLength;

  /**
   * The index, relative to the string, of the last character that was read.
   */
  private int charOffset;

  /**
   * Initialize a newly created scanner to scan the characters in the given string.
   * 
   * @param source the source being scanned
   * @param string the string from which characters will be read
   */
  public StringScanner(Source source, String string) {
    super(source);
    this.string = string;
    this.stringLength = string.length();
    this.charOffset = -1;
  }

  @Override
  public int getOffset() {
    return charOffset;
  }

  public void setOffset(int offset) {
    charOffset = offset;
  }

  @Override
  protected int advance() {
    if (++charOffset < stringLength) {
      return string.charAt(charOffset);
    }
    charOffset = stringLength;
    return -1;
  }

  @Override
  protected String getString(int start, int endDelta) {
    return string.substring(start, charOffset + 1 + endDelta);
  }

  @Override
  protected int peek() {
    if (charOffset + 1 < stringLength) {
      return string.charAt(charOffset + 1);
    }
    return -1;
  }
}
