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
package com.google.dart.engine.internal.type;

import com.google.common.annotations.VisibleForTesting;
import com.google.dart.engine.element.ClassElement;
import com.google.dart.engine.element.Element;
import com.google.dart.engine.element.LibraryElement;
import com.google.dart.engine.element.MethodElement;
import com.google.dart.engine.element.PropertyAccessorElement;
import com.google.dart.engine.element.TypeVariableElement;
import com.google.dart.engine.internal.element.ClassElementImpl;
import com.google.dart.engine.internal.element.member.MethodMember;
import com.google.dart.engine.internal.element.member.PropertyAccessorMember;
import com.google.dart.engine.type.InterfaceType;
import com.google.dart.engine.type.Type;
import com.google.dart.engine.type.TypeVariableType;
import com.google.dart.engine.utilities.general.ObjectUtilities;

import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

/**
 * Instances of the class {@code InterfaceTypeImpl} defines the behavior common to objects
 * representing the type introduced by either a class or an interface, or a reference to such a
 * type.
 * 
 * @coverage dart.engine.type
 */
public class InterfaceTypeImpl extends TypeImpl implements InterfaceType {
  /**
   * An empty array of types.
   */
  public static final InterfaceType[] EMPTY_ARRAY = new InterfaceType[0];

  /**
   * This method computes the longest inheritance path from some passed {@link Type} to Object.
   * 
   * @param type the {@link Type} to compute the longest inheritance path of from the passed
   *          {@link Type} to Object
   * @return the computed longest inheritance path to Object
   * @see #computeLongestInheritancePathToObject(Type, int)
   * @see InterfaceType#getLeastUpperBound(Type)
   */
  @VisibleForTesting
  public static int computeLongestInheritancePathToObject(InterfaceType type) {
    return computeLongestInheritancePathToObject(type, 0);
  }

  /**
   * Returns the set of all superinterfaces of the passed {@link Type}.
   * 
   * @param type the {@link Type} to compute the set of superinterfaces of
   * @return the {@link Set} of superinterfaces of the passed {@link Type}
   * @see #computeSuperinterfaceSet(Type, HashSet)
   * @see #getLeastUpperBound(Type)
   */
  @VisibleForTesting
  public static Set<InterfaceType> computeSuperinterfaceSet(InterfaceType type) {
    return computeSuperinterfaceSet(type, new HashSet<InterfaceType>());
  }

  /**
   * This method computes the longest inheritance path from some passed {@link Type} to Object. This
   * method calls itself recursively, callers should use the public method
   * {@link #computeLongestInheritancePathToObject(Type)}.
   * 
   * @param type the {@link Type} to compute the longest inheritance path of from the passed
   *          {@link Type} to Object
   * @param depth a field used recursively
   * @return the computed longest inheritance path to Object
   * @see #computeLongestInheritancePathToObject(Type)
   * @see #getLeastUpperBound(Type)
   */
  private static int computeLongestInheritancePathToObject(InterfaceType type, int depth) {
    ClassElement classElement = type.getElement();
    // Object case
    if (classElement.getSupertype() == null) {
      return depth;
    }
    InterfaceType[] superinterfaces = classElement.getInterfaces();
    int longestPath = 1;
    int pathLength;
    if (superinterfaces.length > 0) {
      // loop through each of the superinterfaces recursively calling this method and keeping track
      // of the longest path to return
      for (InterfaceType superinterface : superinterfaces) {
        pathLength = computeLongestInheritancePathToObject(superinterface, depth + 1);
        if (pathLength > longestPath) {
          longestPath = pathLength;
        }
      }
    }
    // finally, perform this same check on the super type
    InterfaceType supertype = classElement.getSupertype();
    pathLength = computeLongestInheritancePathToObject(supertype, depth + 1);
    if (pathLength > longestPath) {
      longestPath = pathLength;
    }
    return longestPath;
  }

  /**
   * Returns the set of all superinterfaces of the passed {@link Type}. This is a recursive method,
   * callers should call the public {@link #computeSuperinterfaceSet(Type)}.
   * 
   * @param type the {@link Type} to compute the set of superinterfaces of
   * @param set a {@link HashSet} used recursively by this method
   * @return the {@link Set} of superinterfaces of the passed {@link Type}
   * @see #computeSuperinterfaceSet(Type)
   * @see #getLeastUpperBound(Type)
   */
  private static Set<InterfaceType> computeSuperinterfaceSet(InterfaceType type,
      HashSet<InterfaceType> set) {
    Element element = type.getElement();
    if (element != null && element instanceof ClassElement) {
      ClassElement classElement = (ClassElement) element;
      InterfaceType[] superinterfaces = classElement.getInterfaces();
      for (InterfaceType superinterface : superinterfaces) {
        set.add(superinterface);
        computeSuperinterfaceSet(superinterface, set);
      }
      InterfaceType supertype = classElement.getSupertype();
      if (supertype != null) {
        set.add(supertype);
        computeSuperinterfaceSet(supertype, set);
      }
    }
    return set;
  }

  /**
   * Return the intersection of the given sets of types, where intersection is based on the equality
   * of the elements of the types rather than on the equality of the types themselves. In cases
   * where two non-equal types have equal elements, which only happens when the class is
   * parameterized, the type that is added to the intersection is the base type with type arguments
   * that are the least upper bound of the type arguments of the two types.
   * 
   * @param first the first set of types to be intersected
   * @param second the second set of types to be intersected
   * @return the intersection of the given sets of types
   */
  private static InterfaceType[] intersection(Set<InterfaceType> first, Set<InterfaceType> second) {
    HashMap<ClassElement, InterfaceType> firstMap = new HashMap<ClassElement, InterfaceType>();
    for (InterfaceType firstType : first) {
      firstMap.put(firstType.getElement(), firstType);
    }
    Set<InterfaceType> result = new HashSet<InterfaceType>();
    for (InterfaceType secondType : second) {
      InterfaceType firstType = firstMap.get(secondType.getElement());
      if (firstType != null) {
        result.add(leastUpperBound(firstType, secondType));
      }
    }
    return result.toArray(new InterfaceType[result.size()]);
  }

  /**
   * Return the "least upper bound" of the given types under the assumption that the types have the
   * same element and differ only in terms of the type arguments. The resulting type is composed by
   * comparing the corresponding type arguments, keeping those that are the same, and using
   * 'dynamic' for those that are different.
   * 
   * @param firstType the first type
   * @param secondType the second type
   * @return the "least upper bound" of the given types
   */
  private static InterfaceType leastUpperBound(InterfaceType firstType, InterfaceType secondType) {
    if (firstType.equals(secondType)) {
      return firstType;
    }
    Type[] firstArguments = firstType.getTypeArguments();
    Type[] secondArguments = secondType.getTypeArguments();
    int argumentCount = firstArguments.length;
    if (argumentCount == 0) {
      return firstType;
    }
    Type[] lubArguments = new Type[argumentCount];
    for (int i = 0; i < argumentCount; i++) {
      //
      // Ideally we would take the least upper bound of the two argument types, but this can cause
      // an infinite recursion (such as when finding the least upper bound of String and num).
      //
      if (firstArguments[i].equals(secondArguments[i])) {
        lubArguments[i] = firstArguments[i];
      }
      if (lubArguments[i] == null) {
        lubArguments[i] = DynamicTypeImpl.getInstance();
      }
    }
    InterfaceTypeImpl lub = new InterfaceTypeImpl(firstType.getElement());
    lub.setTypeArguments(lubArguments);
    return lub;
  }

  /**
   * An array containing the actual types of the type arguments.
   */
  private Type[] typeArguments = TypeImpl.EMPTY_ARRAY;

  /**
   * Initialize a newly created type to be declared by the given element.
   * 
   * @param element the element representing the declaration of the type
   */
  public InterfaceTypeImpl(ClassElement element) {
    super(element, element.getDisplayName());
  }

  /**
   * Initialize a newly created type to have the given name. This constructor should only be used in
   * cases where there is no declaration of the type.
   * 
   * @param name the name of the type
   */
  private InterfaceTypeImpl(String name) {
    super(null, name);
  }

  @Override
  public boolean equals(Object object) {
    if (!(object instanceof InterfaceTypeImpl)) {
      return false;
    }
    InterfaceTypeImpl otherType = (InterfaceTypeImpl) object;
    return ObjectUtilities.equals(getElement(), otherType.getElement())
        && Arrays.equals(typeArguments, otherType.typeArguments);
  }

  @Override
  public ClassElement getElement() {
    return (ClassElement) super.getElement();
  }

  @Override
  public PropertyAccessorElement getGetter(String getterName) {
    return PropertyAccessorMember.from(
        ((ClassElementImpl) getElement()).getGetter(getterName),
        this);
  }

  @Override
  public InterfaceType[] getInterfaces() {
    ClassElement classElement = getElement();
    InterfaceType[] interfaces = classElement.getInterfaces();
    TypeVariableElement[] typeVariables = classElement.getTypeVariables();
    if (typeVariables.length == 0) {
      return interfaces;
    }
    int count = interfaces.length;
    InterfaceType[] typedInterfaces = new InterfaceType[count];
    for (int i = 0; i < count; i++) {
      typedInterfaces[i] = interfaces[i].substitute(
          typeArguments,
          TypeVariableTypeImpl.getTypes(typeVariables));
    }
    return typedInterfaces;
  }

  @Override
  public Type getLeastUpperBound(Type type) {
    Type dynamicType = DynamicTypeImpl.getInstance();
    if (this == dynamicType || type == dynamicType) {
      return dynamicType;
    }
    // TODO (jwren) opportunity here for a better, faster algorithm if this turns out to be a bottle-neck
    if (!(type instanceof InterfaceType)) {
      return null;
    }
    // new names to match up with the spec
    InterfaceType i = this;
    InterfaceType j = (InterfaceType) type;

    // compute set of supertypes
    Set<InterfaceType> si = computeSuperinterfaceSet(i);
    Set<InterfaceType> sj = computeSuperinterfaceSet(j);

    // union si with i and sj with j
    si.add(i);
    sj.add(j);

    // compute intersection, reference as set 's'
    InterfaceType[] s = intersection(si, sj);

    // for each element in Set s, compute the largest inheritance path to Object
    int[] depths = new int[s.length];
    int maxDepth = 0;
    for (int n = 0; n < s.length; n++) {
      depths[n] = computeLongestInheritancePathToObject(s[n]);
      if (depths[n] > maxDepth) {
        maxDepth = depths[n];
      }
    }

    // ensure that the currently computed maxDepth is unique,
    // otherwise, decrement and test for uniqueness again
    for (; maxDepth >= 0; maxDepth--) {
      int indexOfLeastUpperBound = -1;
      int numberOfTypesAtMaxDepth = 0;
      for (int m = 0; m < depths.length; m++) {
        if (depths[m] == maxDepth) {
          numberOfTypesAtMaxDepth++;
          indexOfLeastUpperBound = m;
        }
      }
      if (numberOfTypesAtMaxDepth == 1) {
        return s[indexOfLeastUpperBound];
      }
    }

    // illegal state, log and return null- Object at maxDepth == 0 should always return itself as
    // the least upper bound.
    // TODO (jwren) log the error state 
    return null;
  }

  @Override
  public MethodElement getMethod(String methodName) {
    return MethodMember.from(((ClassElementImpl) getElement()).getMethod(methodName), this);
  }

  @Override
  public InterfaceType[] getMixins() {
    ClassElement classElement = getElement();
    InterfaceType[] mixins = classElement.getMixins();
    TypeVariableElement[] typeVariables = classElement.getTypeVariables();
    if (typeVariables.length == 0) {
      return mixins;
    }
    int count = mixins.length;
    InterfaceType[] typedMixins = new InterfaceType[count];
    for (int i = 0; i < count; i++) {
      typedMixins[i] = mixins[i].substitute(
          typeArguments,
          TypeVariableTypeImpl.getTypes(typeVariables));
    }
    return typedMixins;
  }

  @Override
  public PropertyAccessorElement getSetter(String setterName) {
    return PropertyAccessorMember.from(
        ((ClassElementImpl) getElement()).getSetter(setterName),
        this);
  }

  @Override
  public InterfaceType getSuperclass() {
    ClassElement classElement = getElement();
    InterfaceType supertype = classElement.getSupertype();
    if (supertype == null) {
      return null;
    }
    return supertype.substitute(
        typeArguments,
        TypeVariableTypeImpl.getTypes(classElement.getTypeVariables()));
  }

  @Override
  public Type[] getTypeArguments() {
    return typeArguments;
  }

  @Override
  public int hashCode() {
    ClassElement element = getElement();
    if (element == null) {
      return 0;
    }
    return element.hashCode();
  }

  @Override
  public boolean isDartCoreFunction() {
    ClassElement element = getElement();
    if (element == null) {
      return false;
    }
    return element.getName().equals("Function") && element.getLibrary().isDartCore();
  }

  @Override
  public boolean isDirectSupertypeOf(InterfaceType type) {
    ClassElement i = getElement();
    ClassElement j = type.getElement();
    InterfaceType supertype = j.getSupertype();
    //
    // If J has no direct supertype then it is Object, and Object has no direct supertypes.
    //
    if (supertype == null) {
      return false;
    }
    //
    // I is listed in the extends clause of J.
    //
    ClassElement supertypeElement = supertype.getElement();
    if (supertypeElement.equals(i)) {
      return true;
    }
    //
    // I is listed in the implements clause of J.
    //
    for (InterfaceType interfaceType : j.getInterfaces()) {
      if (interfaceType.getElement().equals(i)) {
        return true;
      }
    }
    //
    // I is listed in the with clause of J.
    //
    for (InterfaceType mixinType : j.getMixins()) {
      if (mixinType.getElement().equals(i)) {
        return true;
      }
    }
    //
    // J is a mixin application of the mixin of I.
    //
    // TODO(brianwilkerson) Determine whether this needs to be implemented or whether it is covered
    // by the case above.
    return false;
  }

  @Override
  public boolean isMoreSpecificThan(Type type) {
    //
    // S is dynamic.
    // The test to determine whether S is dynamic is done here because dynamic is not an instance of
    // InterfaceType.
    //
    if (type == DynamicTypeImpl.getInstance()) {
      return true;
    } else if (!(type instanceof InterfaceType)) {
      return false;
    }
    return isMoreSpecificThan((InterfaceType) type, new HashSet<ClassElement>());
  }

  @Override
  public boolean isSubtypeOf(Type type) {
    //
    // T is a subtype of S, written T <: S, iff [bottom/dynamic]T << S
    //
    if (type == DynamicTypeImpl.getInstance()) {
      return true;
    } else if (type instanceof TypeVariableType) {
      return true;
    } else if (!(type instanceof InterfaceType)) {
      return false;
    } else if (this.equals(type)) {
      return true;
    }
    return isSubtypeOf((InterfaceType) type, new HashSet<ClassElement>());
  }

  @Override
  public PropertyAccessorElement lookUpGetter(String getterName, LibraryElement library) {
    PropertyAccessorElement element = getGetter(getterName);
    if (element != null && element.isAccessibleIn(library)) {
      return element;
    }
    for (InterfaceType mixin : getMixins()) {
      element = mixin.getGetter(getterName);
      if (element != null && element.isAccessibleIn(library)) {
        return element;
      }
    }
    InterfaceType supertype = getSuperclass();
    while (supertype != null) {
      element = supertype.getGetter(getterName);
      if (element != null && element.isAccessibleIn(library)) {
        return element;
      }
      for (InterfaceType mixin : supertype.getMixins()) {
        element = mixin.getGetter(getterName);
        if (element != null && element.isAccessibleIn(library)) {
          return element;
        }
      }
      supertype = supertype.getSuperclass();
    }
    return null;
  }

  @Override
  public MethodElement lookUpMethod(String methodName, LibraryElement library) {
    MethodElement element = getMethod(methodName);
    if (element != null && element.isAccessibleIn(library)) {
      return element;
    }
    for (InterfaceType mixin : getMixins()) {
      element = mixin.getMethod(methodName);
      if (element != null && element.isAccessibleIn(library)) {
        return element;
      }
    }
    InterfaceType supertype = getSuperclass();
    while (supertype != null) {
      element = supertype.getMethod(methodName);
      if (element != null && element.isAccessibleIn(library)) {
        return element;
      }
      for (InterfaceType mixin : supertype.getMixins()) {
        element = mixin.getMethod(methodName);
        if (element != null && element.isAccessibleIn(library)) {
          return element;
        }
      }
      supertype = supertype.getSuperclass();
    }
    return null;
  }

  @Override
  public PropertyAccessorElement lookUpSetter(String setterName, LibraryElement library) {
    PropertyAccessorElement element = getSetter(setterName);
    if (element != null && element.isAccessibleIn(library)) {
      return element;
    }
    for (InterfaceType mixin : getMixins()) {
      element = mixin.getSetter(setterName);
      if (element != null && element.isAccessibleIn(library)) {
        return element;
      }
    }
    InterfaceType supertype = getSuperclass();
    while (supertype != null) {
      element = supertype.getSetter(setterName);
      if (element != null && element.isAccessibleIn(library)) {
        return element;
      }
      for (InterfaceType mixin : supertype.getMixins()) {
        element = mixin.getSetter(setterName);
        if (element != null && element.isAccessibleIn(library)) {
          return element;
        }
      }
      supertype = supertype.getSuperclass();
    }
    return null;
  }

  /**
   * Set the actual types of the type arguments to those in the given array.
   * 
   * @param typeArguments the actual types of the type arguments
   */
  public void setTypeArguments(Type[] typeArguments) {
    this.typeArguments = typeArguments;
  }

  @Override
  public InterfaceTypeImpl substitute(Type[] argumentTypes) {
    return substitute(argumentTypes, getTypeArguments());
  }

  @Override
  public InterfaceTypeImpl substitute(Type[] argumentTypes, Type[] parameterTypes) {
    if (argumentTypes.length != parameterTypes.length) {
      throw new IllegalArgumentException("argumentTypes.length (" + argumentTypes.length
          + ") != parameterTypes.length (" + parameterTypes.length + ")");
    }
    if (argumentTypes.length == 0) {
      return this;
    }
    InterfaceTypeImpl newType = new InterfaceTypeImpl(getElement());
    newType.setTypeArguments(substitute(typeArguments, argumentTypes, parameterTypes));
    return newType;
  }

  @Override
  protected void appendTo(StringBuilder builder) {
    builder.append(getName());
    int argumentCount = typeArguments.length;
    if (argumentCount > 0) {
      builder.append("<");
      for (int i = 0; i < argumentCount; i++) {
        if (i > 0) {
          builder.append(", ");
        }
        ((TypeImpl) typeArguments[i]).appendTo(builder);
      }
      builder.append(">");
    }
  }

  private boolean isMoreSpecificThan(InterfaceType s, HashSet<ClassElement> visitedClasses) {
    //
    // A type T is more specific than a type S, written T << S,  if one of the following conditions
    // is met:
    //
    // Reflexivity: T is S.
    //
    if (this.equals(s)) {
      return true;
    }
    //
    // T is bottom. (This case is handled by the class BottomTypeImpl.)
    //
    // Direct supertype: S is a direct supertype of T.
    //
    if (s.isDirectSupertypeOf(this)) {
      return true;
    }
    //
    // Covariance: T is of the form I<T1, ..., Tn> and S is of the form I<S1, ..., Sn> and Ti << Si, 1 <= i <= n.
    //
    ClassElement tElement = getElement();
    ClassElement sElement = s.getElement();
    if (tElement.equals(sElement)) {
      Type[] tArguments = getTypeArguments();
      Type[] sArguments = s.getTypeArguments();
      if (tArguments.length != sArguments.length) {
        return false;
      }
      for (int i = 0; i < tArguments.length; i++) {
        if (!tArguments[i].isMoreSpecificThan(sArguments[i])) {
          return false;
        }
      }
      return true;
    }
    //
    // Transitivity: T << U and U << S.
    //
    ClassElement element = getElement();
    if (element == null || visitedClasses.contains(element)) {
      return false;
    }
    visitedClasses.add(element);
    //
    // Iterate over all of the types U that are more specific than T because they are direct
    // supertypes of T and return true if any of them are more specific than S.
    //
    InterfaceType supertype = element.getSupertype();
    if (supertype != null && ((InterfaceTypeImpl) supertype).isMoreSpecificThan(s, visitedClasses)) {
      return true;
    }
    for (InterfaceType interfaceType : element.getInterfaces()) {
      if (((InterfaceTypeImpl) interfaceType).isMoreSpecificThan(s, visitedClasses)) {
        return true;
      }
    }
    for (InterfaceType mixinType : element.getMixins()) {
      if (((InterfaceTypeImpl) mixinType).isMoreSpecificThan(s, visitedClasses)) {
        return true;
      }
    }
    return false;
  }

  private boolean isSubtypeOf(InterfaceType type, HashSet<ClassElement> visitedClasses) {
    InterfaceType typeT = this;
    InterfaceType typeS = type;
    ClassElement elementT = getElement();
    if (elementT == null || visitedClasses.contains(elementT)) {
      return false;
    }
    visitedClasses.add(elementT);

    typeT = substitute(typeArguments, TypeVariableTypeImpl.getTypes(elementT.getTypeVariables()));
    if (typeT.equals(typeS)) {
      return true;
    } else if (ObjectUtilities.equals(elementT, typeS.getElement())) {
      // For each of the type arguments return true if all type args from T is a subtype of all
      // types from S.
      Type[] typeTArgs = typeT.getTypeArguments();
      Type[] typeSArgs = typeS.getTypeArguments();
      if (typeTArgs.length != typeSArgs.length) {
        // This case covers the case where two objects are being compared that have a different
        // number of parameterized types.
        return false;
      }
      for (int i = 0; i < typeTArgs.length; i++) {
        // Recursively call isSubtypeOf the type arguments and return false if the T argument is not
        // a subtype of the S argument.
        if (!typeTArgs[i].isSubtypeOf(typeSArgs[i])) {
          return false;
        }
      }
      return true;
    }

    InterfaceType supertype = elementT.getSupertype();
    // The type is Object, return false.
    if (supertype != null && ((InterfaceTypeImpl) supertype).isSubtypeOf(typeS, visitedClasses)) {
      return true;
    }
    InterfaceType[] interfaceTypes = elementT.getInterfaces();
    for (InterfaceType interfaceType : interfaceTypes) {
      if (((InterfaceTypeImpl) interfaceType).isSubtypeOf(typeS, visitedClasses)) {
        return true;
      }
    }
    InterfaceType[] mixinTypes = elementT.getMixins();
    for (InterfaceType mixinType : mixinTypes) {
      if (((InterfaceTypeImpl) mixinType).isSubtypeOf(typeS, visitedClasses)) {
        return true;
      }
    }
    return false;
  }
}
