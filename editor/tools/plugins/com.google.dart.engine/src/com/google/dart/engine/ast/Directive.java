/*
 * Copyright 2012, the Dart project authors.
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
package com.google.dart.engine.ast;

import com.google.dart.engine.element.Element;
import com.google.dart.engine.scanner.Token;

import java.util.List;

/**
 * The abstract class {@code Directive} defines the behavior common to nodes that represent a
 * directive.
 * 
 * <pre>
 * directive ::=
 *     {@link ExportDirective exportDirective}
 *   | {@link ImportDirective importDirective}
 *   | {@link LibraryDirective libraryDirective}
 *   | {@link PartDirective partDirective}
 *   | {@link PartOfDirective partOfDirective}
 * </pre>
 * 
 * @coverage dart.engine.ast
 */
public abstract class Directive extends AnnotatedNode {
  /**
   * The element associated with this directive, or {@code null} if the AST structure has not been
   * resolved or if this directive could not be resolved.
   */
  private Element element;

  /**
   * Initialize a newly create directive.
   * 
   * @param comment the documentation comment associated with this directive
   * @param metadata the annotations associated with the directive
   */
  public Directive(Comment comment, List<Annotation> metadata) {
    super(comment, metadata);
  }

  /**
   * Return the element associated with this directive, or {@code null} if the AST structure has not
   * been resolved or if this directive could not be resolved. Examples of the latter case include a
   * directive that contains an invalid URL or a URL that does not exist.
   * 
   * @return the element associated with this directive
   */
  public Element getElement() {
    return element;
  }

  /**
   * Return the token representing the keyword that introduces this directive ('import', 'export',
   * 'library' or 'part').
   * 
   * @return the token representing the keyword that introduces this directive
   */
  public abstract Token getKeyword();

  /**
   * Set the element associated with this directive to the given element.
   * 
   * @param element the element associated with this directive
   */
  public void setElement(Element element) {
    this.element = element;
  }
}
