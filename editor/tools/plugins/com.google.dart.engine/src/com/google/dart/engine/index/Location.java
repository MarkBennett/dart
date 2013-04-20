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
package com.google.dart.engine.index;

import com.google.common.base.Objects;
import com.google.dart.engine.element.Element;

/**
 * Instances of the class <code>Location</code> represent a location related to an element. The
 * location is expressed as an offset and length, but the offset is relative to the resource
 * containing the element rather than the start of the element within that resource.
 * 
 * @coverage dart.engine.index
 */
public class Location {

  /**
   * An empty array of locations.
   */
  public static final Location[] EMPTY_ARRAY = new Location[0];

  /**
   * The element containing this location.
   */
  private final Element element;

  /**
   * The offset of this location within the resource containing the element.
   */
  private final int offset;

  /**
   * The length of this location.
   */
  private final int length;

  /**
   * The name of the import prefix used at this location, or {@code null} if the location does not
   * involve the use of a prefix.
   */
  private final String importPrefix;

  /**
   * Initialize a newly create location to be relative to the given element at the given offset with
   * the given length.
   * 
   * @param element the {@link Element} containing this location
   * @param offset the offset of this location within the resource containing the element
   * @param length the length of this location
   */
  public Location(Element element, int offset, int length, String importPrefix) {
    if (element == null) {
      throw new IllegalArgumentException("element location cannot be null");
    }
    this.element = element;
    this.offset = offset;
    this.length = length;
    this.importPrefix = importPrefix;
  }

  @Override
  public boolean equals(Object obj) {
    if (obj instanceof Location) {
      Location other = (Location) obj;
      return offset == other.offset && length == other.length
          && Objects.equal(element, other.element)
          && Objects.equal(importPrefix, other.importPrefix);
    }
    return false;
  }

  /**
   * @return the {@link Element} containing this location.
   */
  public Element getElement() {
    return element;
  }

  /**
   * @return the name of the import prefix, may be {@code null}.
   */
  public String getImportPrefix() {
    return importPrefix;
  }

  /**
   * Return the length of this location.
   * 
   * @return the length of this location
   */
  public int getLength() {
    return length;
  }

  /**
   * Return the offset of this location within the resource containing the element.
   * 
   * @return the offset of this location within the resource containing the element
   */
  public int getOffset() {
    return offset;
  }

  @Override
  public int hashCode() {
    return Objects.hashCode(element, offset, length, importPrefix);
  }

  @Override
  public String toString() {
    String result = "[" + offset + " - " + (offset + length) + ") in " + element;
    if (importPrefix != null) {
      result += " with prefix '" + importPrefix + "'";
    }
    return result;
  }
}
