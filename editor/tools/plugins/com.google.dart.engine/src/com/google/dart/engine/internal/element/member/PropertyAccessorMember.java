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
package com.google.dart.engine.internal.element.member;

import com.google.dart.engine.element.Element;
import com.google.dart.engine.element.ElementVisitor;
import com.google.dart.engine.element.FieldElement;
import com.google.dart.engine.element.PropertyAccessorElement;
import com.google.dart.engine.element.PropertyInducingElement;
import com.google.dart.engine.internal.type.TypeVariableTypeImpl;
import com.google.dart.engine.type.FunctionType;
import com.google.dart.engine.type.InterfaceType;
import com.google.dart.engine.type.Type;

/**
 * Instances of the class {@code PropertyAccessorMember} represent a property accessor element
 * defined in a parameterized type where the values of the type parameters are known.
 */
public class PropertyAccessorMember extends ExecutableMember implements PropertyAccessorElement {
  /**
   * If the given property accessor's type is different when any type parameters from the defining
   * type's declaration are replaced with the actual type arguments from the defining type, create a
   * property accessor member representing the given property accessor. Return the member that was
   * created, or the base accessor if no member was created.
   * 
   * @param baseAccessor the base property accessor for which a member might be created
   * @param definingType the type defining the parameters and arguments to be used in the
   *          substitution
   * @return the property accessor element that will return the correctly substituted types
   */
  public static PropertyAccessorElement from(PropertyAccessorElement baseAccessor,
      InterfaceType definingType) {
    if (baseAccessor == null || definingType.getTypeArguments().length == 0) {
      return baseAccessor;
    }
    FunctionType baseType = baseAccessor.getType();
    Type[] argumentTypes = definingType.getTypeArguments();
    Type[] parameterTypes = TypeVariableTypeImpl.getTypes(definingType.getElement().getTypeVariables());
    FunctionType substitutedType = baseType.substitute(argumentTypes, parameterTypes);
    if (baseType.equals(substitutedType)) {
      return baseAccessor;
    }
    // TODO(brianwilkerson) Consider caching the substituted type in the instance. It would use more
    // memory but speed up some operations. We need to see how often the type is being re-computed.
    return new PropertyAccessorMember(baseAccessor, definingType);
  }

  /**
   * Initialize a newly created element to represent a property accessor of the given parameterized
   * type.
   * 
   * @param baseElement the element on which the parameterized element was created
   * @param definingType the type in which the element is defined
   */
  public PropertyAccessorMember(PropertyAccessorElement baseElement, InterfaceType definingType) {
    super(baseElement, definingType);
  }

  @Override
  public <R> R accept(ElementVisitor<R> visitor) {
    return visitor.visitPropertyAccessorElement(this);
  }

  @Override
  public PropertyAccessorElement getBaseElement() {
    return (PropertyAccessorElement) super.getBaseElement();
  }

  @Override
  public Element getEnclosingElement() {
    return getBaseElement().getEnclosingElement();
  }

  @Override
  public PropertyInducingElement getVariable() {
    PropertyInducingElement variable = getBaseElement().getVariable();
    if (variable instanceof FieldElement) {
      return FieldMember.from(((FieldElement) variable), getDefiningType());
    }
    return variable;
  }

  @Override
  public boolean isGetter() {
    return getBaseElement().isGetter();
  }

  @Override
  public boolean isSetter() {
    return getBaseElement().isSetter();
  }
}
