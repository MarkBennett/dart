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

import com.google.dart.engine.scanner.Token;

import java.util.AbstractList;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * Instances of the class {@code NodeList} represent a list of AST nodes that have a common parent.
 * 
 * @coverage dart.engine.ast
 */
public class NodeList<E extends ASTNode> extends AbstractList<E> {
  /**
   * Create an empty list with the given owner. This is a convenience method that allows the
   * compiler to determine the correct value of the type argument {@link #E} without needing to
   * explicitly specify it.
   * 
   * @param owner the node that is the parent of each of the elements in the list
   * @return the list that was created
   */
  public static <E extends ASTNode> NodeList<E> create(ASTNode owner) {
    return new NodeList<E>(owner);
  }

  /**
   * The node that is the parent of each of the elements in the list.
   */
  private final ASTNode owner;

  /**
   * The elements of the list.
   */
  private List<E> elements = null;

  /**
   * Initialize a newly created list of nodes to be empty.
   * 
   * @param owner the node that is the parent of each of the elements in the list
   */
  public NodeList(ASTNode owner) {
    this.owner = owner;
  }

  /**
   * Use the given visitor to visit each of the nodes in this list.
   * 
   * @param visitor the visitor to be used to visit the elements of this list
   */
  public void accept(ASTVisitor<?> visitor) {
    if (elements == null) {
      return;
    }
    for (E element : elements) {
      element.accept(visitor);
    }
  }

  @Override
  public void add(int index, E node) {
    if (elements == null) {
      elements = new ArrayList<E>(1);
    }
    owner.becomeParentOf(node);
    elements.add(index, node);
  }

  @Override
  public boolean addAll(Collection<? extends E> nodes) {
    if (nodes != null) {
      return super.addAll(nodes);
    }
    return false;
  }

  @Override
  public E get(int index) {
    if (elements == null) {
      throw new IndexOutOfBoundsException("Index: " + index + ", Size: 0");
    }
    return elements.get(index);
  }

  /**
   * Return the first token included in this node's source range.
   * 
   * @return the first token included in this node's source range
   */
  public Token getBeginToken() {
    if (elements == null || elements.isEmpty()) {
      return null;
    }
    return elements.get(0).getBeginToken();
  }

  /**
   * Return the last token included in this node list's source range.
   * 
   * @return the last token included in this node list's source range
   */
  public Token getEndToken() {
    if (elements == null || elements.isEmpty()) {
      return null;
    }
    return elements.get(elements.size() - 1).getEndToken();
  }

  /**
   * Return the node that is the parent of each of the elements in the list.
   * 
   * @return the node that is the parent of each of the elements in the list
   */
  public ASTNode getOwner() {
    return owner;
  }

  @Override
  public E remove(int index) {
    if (elements == null) {
      throw new IndexOutOfBoundsException("Index: " + index + ", Size: 0");
    }
    return elements.remove(index);
  }

  @Override
  public E set(int index, E node) {
    if (elements == null) {
      throw new IndexOutOfBoundsException("Index: " + index + ", Size: 0");
    }
    owner.becomeParentOf(node);
    return elements.set(index, node);
  }

  @Override
  public int size() {
    if (elements == null) {
      return 0;
    }
    return elements.size();
  }
}
