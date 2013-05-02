// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of dart2js;

class World {
  final Compiler compiler;
  final Map<ClassElement, Set<MixinApplicationElement>> mixinUses;
  final Map<ClassElement, Set<ClassElement>> typesImplementedBySubclasses;
  final FullFunctionSet allFunctions;
  final Set<Element> functionsCalledInLoop = new Set<Element>();
  final Map<Element, SideEffects> sideEffects = new Map<Element, SideEffects>();

  // We keep track of subtype and subclass relationships in four
  // distinct sets to make class hierarchy analysis faster.
  final Map<ClassElement, Set<ClassElement>> subclasses =
      new Map<ClassElement, Set<ClassElement>>();
  final Map<ClassElement, Set<ClassElement>> superclasses =
      new Map<ClassElement, Set<ClassElement>>();
  final Map<ClassElement, Set<ClassElement>> subtypes =
      new Map<ClassElement, Set<ClassElement>>();
  final Map<ClassElement, Set<ClassElement>> supertypes =
      new Map<ClassElement, Set<ClassElement>>();

  World(Compiler compiler)
      : mixinUses = new Map<ClassElement, Set<MixinApplicationElement>>(),
        typesImplementedBySubclasses =
            new Map<ClassElement, Set<ClassElement>>(),
        allFunctions = new FullFunctionSet(compiler),
        this.compiler = compiler;

  void populate() {
    void addSubtypes(ClassElement cls) {
      if (cls.resolutionState != STATE_DONE) {
        compiler.internalErrorOnElement(
            cls, 'Class "${cls.name.slowToString()}" is not resolved.');
      }

      for (DartType type in cls.allSupertypes) {
        Set<Element> supertypesOfClass =
            supertypes.putIfAbsent(cls, () => new Set<ClassElement>());
        Set<Element> subtypesOfSupertype =
            subtypes.putIfAbsent(type.element, () => new Set<ClassElement>());
        supertypesOfClass.add(type.element);
        subtypesOfSupertype.add(cls);
      }

      // Walk through the superclasses, and record the types
      // implemented by that type on the superclasses.
      DartType type = cls.supertype;
      while (type != null) {
        Set<Element> superclassesOfClass =
            superclasses.putIfAbsent(cls, () => new Set<ClassElement>());
        Set<Element> subclassesOfSuperclass =
            subclasses.putIfAbsent(type.element, () => new Set<ClassElement>());
        superclassesOfClass.add(type.element);
        subclassesOfSuperclass.add(cls);

        Set<Element> typesImplementedBySubclassesOfCls =
            typesImplementedBySubclasses.putIfAbsent(
                type.element, () => new Set<ClassElement>());
        for (DartType current in cls.allSupertypes) {
          typesImplementedBySubclassesOfCls.add(current.element);
        }
        ClassElement classElement = type.element;
        type = classElement.supertype;
      }
    }

    // Use the [:seenClasses:] set to include non-instantiated
    // classes: if the superclass of these classes require RTI, then
    // they also need RTI, so that a constructor passes the type
    // variables to the super constructor.
    compiler.enqueuer.resolution.seenClasses.forEach(addSubtypes);
  }

  Iterable<ClassElement> commonSupertypesOf(ClassElement x, ClassElement y) {
    Set<ClassElement> xSet = supertypes[x];
    if (xSet == null) return const <ClassElement>[];
    Set<ClassElement> ySet = supertypes[y];
    if (ySet == null) return const <ClassElement>[];
    Set<ClassElement> smallSet, largeSet;
    if (xSet.length <= ySet.length) {
      smallSet = xSet;
      largeSet = ySet;
    } else {
      smallSet = ySet;
      largeSet = xSet;
    }
    return smallSet.where((ClassElement each) => largeSet.contains(each));
  }

  void registerMixinUse(MixinApplicationElement mixinApplication,
                        ClassElement mixin) {
    Set<MixinApplicationElement> users =
        mixinUses.putIfAbsent(mixin, () =>
                              new Set<MixinApplicationElement>());
    users.add(mixinApplication);
  }

  bool isUsedAsMixin(ClassElement cls) {
    Set<MixinApplicationElement> uses = mixinUses[cls];
    return uses != null && !uses.isEmpty;
  }

  bool hasAnySubclass(ClassElement cls) {
    Set<ClassElement> classes = subclasses[cls];
    return classes != null && !classes.isEmpty;
  }

  bool hasAnySubtype(ClassElement cls) {
    Set<ClassElement> classes = subtypes[cls];
    return classes != null && !classes.isEmpty;
  }

  bool hasAnyUserDefinedGetter(Selector selector) {
    return allFunctions.filter(selector).any((each) => each.isGetter());
  }

  bool hasAnyUserDefinedSetter(Selector selector) {
     return allFunctions.filter(selector).any((each) => each.isSetter());
  }

  // Returns whether a subclass of [superclass] implements [type].
  bool hasAnySubclassThatImplements(ClassElement superclass, DartType type) {
    Set<ClassElement> subclasses = typesImplementedBySubclasses[superclass];
    if (subclasses == null) return false;
    return subclasses.contains(type.element);
  }

  // Returns whether a subclass of [superclass] mixes in [other].
  bool hasAnySubclassThatMixes(ClassElement superclass, ClassElement other) {
    Set<MixinApplicationElement> uses = mixinUses[other];
    return (uses != null)
        ? uses.any((each) => each.isSubclassOf(superclass))
        : false;
  }

  void registerUsedElement(Element element) {
    if (element.isInstanceMember() && !element.isAbstract(compiler)) {
      allFunctions.add(element);
    }
  }

  VariableElement locateSingleField(Selector selector) {
    Element result = locateSingleElement(selector);
    return (result != null && result.isField()) ? result : null;
  }

  Element locateSingleElement(Selector selector) {
    ti.TypeMask mask = selector.mask == null
        ? new ti.TypeMask.subclass(compiler.objectClass.rawType)
        : selector.mask;
    return mask.locateSingleElement(selector, compiler);
  }

  bool hasSingleMatch(Selector selector) {
    Iterable<Element> targets = allFunctions.filter(selector);
    return targets.length == 1;
  }

  Iterable<ClassElement> locateNoSuchMethodHolders(Selector selector) {
    Selector noSuchMethodSelector = compiler.noSuchMethodSelector;
    ti.TypeMask mask = selector.mask;
    if (mask != null) {
      noSuchMethodSelector = new TypedSelector(mask, noSuchMethodSelector);
    }
    ClassElement objectClass = compiler.objectClass;
    return allFunctions
        .filter(noSuchMethodSelector)
        .map((Element member) => member.getEnclosingClass())
        .where((ClassElement holder) => !identical(holder, objectClass));
  }

  void addFunctionCalledInLoop(Element element) {
    functionsCalledInLoop.add(element.declaration);
  }

  bool isCalledInLoop(Element element) {
    return functionsCalledInLoop.contains(element.declaration);
  }

  SideEffects getSideEffectsOfElement(Element element) {
    return sideEffects.putIfAbsent(element.declaration, () {
      return new SideEffects();
    });
  }

  void registerSideEffects(Element element, SideEffects effects) {
    sideEffects[element.declaration] = effects;
  }

  SideEffects getSideEffectsOfSelector(Selector selector) {
    // We're not tracking side effects of closures.
    if (selector.isClosureCall()) {
      return new SideEffects();
    }
    SideEffects sideEffects = new SideEffects.empty();
    for (Element e in allFunctions.filter(selector)) {
      if (e.isField()) {
        if (selector.isGetter()) {
          sideEffects.setDependsOnInstancePropertyStore();
        } else if (selector.isSetter()) {
          sideEffects.setChangesInstanceProperty();
        }
      }
      sideEffects.add(getSideEffectsOfElement(e));
    }
    return sideEffects;
  }
}
