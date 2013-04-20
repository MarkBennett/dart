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
package com.google.dart.tools.core.html;

/**
 * An xml model element. An XmlAttribute is owned by an XmlNode.
 */
public class XmlAttribute extends XmlNode {
  private String value;

  public XmlAttribute(String name) {
    this(name, null);
  }

  public XmlAttribute(String name, String value) {
    super(name);

    this.value = value;
  }

  public String getName() {
    return getLabel();
  }

  public String getValue() {
    return value;
  }

  public void setValue(String val) {
    this.value = val;
  }

}
