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
package com.google.dart.tools.search.ui.text;

import org.eclipse.core.runtime.Assert;

/**
 * A textual match in a given object. This class may be instantiated and also subclassed (to add
 * additional match state like accuracy, etc). The element a match is reported against is assumed to
 * contain the match, and the UI will group matches against the same element together. A match has
 * an offset and a length which may be specified in characters or in lines.
 */
public class Match {

  /**
   * A constant expressing that offset and length of this match are specified in lines
   */
  public static final int UNIT_LINE = 1;

  /**
   * A constant expressing that offset and length of this match are specified in characters
   */
  public static final int UNIT_CHARACTER = 2;

  private static final int IS_FILTERED = 1 << 2;

  private Object fElement;
  private int fOffset;
  private int fLength;
  private int fFlags;

  /**
   * Constructs a new Match object.
   * 
   * @param element the element that contains the match
   * @param unit the unit offset and length are based on
   * @param offset the offset the match starts at
   * @param length the length of the match
   */
  public Match(Object element, int unit, int offset, int length) {
    Assert.isTrue(unit == UNIT_CHARACTER || unit == UNIT_LINE);
    fElement = element;
    fOffset = offset;
    fLength = length;
    fFlags = unit;
  }

  /**
   * Constructs a new Match object. The offset and length will be based on characters.
   * 
   * @param element the element that contains the match
   * @param offset the offset the match starts at
   * @param length the length of the match
   */
  public Match(Object element, int offset, int length) {
    this(element, UNIT_CHARACTER, offset, length);
  }

  /**
   * Returns the offset of this match.
   * 
   * @return the offset
   */
  public int getOffset() {
    return fOffset;
  }

  /**
   * Sets the offset of this match.
   * 
   * @param offset the offset to set
   */
  public void setOffset(int offset) {
    fOffset = offset;
  }

  /**
   * Returns the length of this match.
   * 
   * @return the length
   */
  public int getLength() {
    return fLength;
  }

  /**
   * Sets the length.
   * 
   * @param length the length to set
   */
  public void setLength(int length) {
    fLength = length;
  }

  /**
   * Returns the element that contains this match. The element is used to group the match.
   * 
   * @return the element that contains this match
   */
  public Object getElement() {
    return fElement;
  }

  /**
   * Returns whether match length and offset are expressed in lines or characters.
   * 
   * @return either UNIT_LINE or UNIT_CHARACTER;
   */
  public int getBaseUnit() {
    if ((fFlags & UNIT_LINE) != 0)
      return UNIT_LINE;
    return UNIT_CHARACTER;
  }

  /**
   * Marks this match as filtered or not.
   * 
   * @param value <code>true</code> if the match is filtered; otherwise <code>false</code>
   */
  public void setFiltered(boolean value) {
    if (value) {
      fFlags |= IS_FILTERED;
    } else {
      fFlags &= (~IS_FILTERED);
    }
  }

  /**
   * Returns whether this match is filtered or not.
   * 
   * @return <code>true<code> if the match is filtered;
   *  otherwise <code>false</code>
   */
  public boolean isFiltered() {
    return (fFlags & IS_FILTERED) != 0;
  }
}
