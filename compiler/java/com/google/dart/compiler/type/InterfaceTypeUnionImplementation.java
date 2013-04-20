// Copyright (c) 2012, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.google.dart.compiler.type;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Lists;
import com.google.dart.compiler.resolver.ClassElement;
import com.google.dart.compiler.resolver.ClassElementUnion;

import java.util.List;

/**
 * Implementation of {@link InterfaceTypeUnion}.
 */
class InterfaceTypeUnionImplementation implements InterfaceTypeUnion {

  private final List<InterfaceType> types;
  private final ClassElement element;

  public InterfaceTypeUnionImplementation(List<InterfaceType> types) {
    this.types = types;
    this.element = new ClassElementUnion(this, types);
  }

  @Override
  public boolean equals(Object obj) {
    if (obj instanceof InterfaceTypeUnionImplementation) {
      InterfaceTypeUnionImplementation other = (InterfaceTypeUnionImplementation) obj;
      return getElement().equals(other.getElement());
    }
    return false;
  }

  @Override
  public int hashCode() {
    int hashCode = 31;
    hashCode += getElement().hashCode();
    hashCode += 31 * hashCode + getArguments().hashCode();
    return hashCode;
  }

  @Override
  public String toString() {
    return types.toString();
  }

  @Override
  public TypeKind getKind() {
    return TypeKind.INTERFACE;
  }

  @Override
  public TypeQuality getQuality() {
    return TypeQuality.EXACT;
  }

  @Override
  public InterfaceType subst(List<Type> arguments, List<Type> parameters) {
    return null;
  }

  @Override
  public ClassElement getElement() {
    return element;
  }

  @Override
  public List<Type> getArguments() {
    return ImmutableList.of();
  }

  @Override
  public boolean isRaw() {
    return true;
  }

  @Override
  public boolean hasDynamicTypeArgs() {
    return false;
  }

  @Override
  public InterfaceType asRawType() {
    return this;
  }

  @Override
  public Member lookupMember(String name) {
    for (InterfaceType type : types) {
      Member member = type.lookupMember(name);
      if (member != null) {
        return member;
      }
    }
    return null;
  }

  @Override
  public void registerSubClass(ClassElement subClass) {
  }

  @Override
  public void unregisterSubClass(ClassElement subClass) {
  }

  @Override
  public List<Member> lookupSubTypeMembers(String name) {
    return Lists.newArrayList();
  }

  public List<InterfaceType> getTypes() {
    return types;
  }
}
