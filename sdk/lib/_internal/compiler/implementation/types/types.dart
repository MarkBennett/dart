// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library types;

import 'dart:collection' show Queue, IterableBase;

import '../dart2jslib.dart' hide Selector;
import '../js_backend/js_backend.dart' show JavaScriptBackend;
import '../tree/tree.dart';
import '../elements/elements.dart';
import '../native_handler.dart' as native;
import '../util/util.dart';
import '../universe/universe.dart';
import 'simple_types_inferrer.dart' show SimpleTypesInferrer;
import '../dart_types.dart';

part 'concrete_types_inferrer.dart';
part 'type_mask.dart';

/**
 * Common super class for our type inferrers.
 */
abstract class TypesInferrer {
  analyzeMain(Element element);
  TypeMask getReturnTypeOfElement(Element element);
  TypeMask getTypeOfElement(Element element);
  TypeMask getTypeOfNode(Element owner, Node node);
  TypeMask getTypeOfSelector(Selector selector);
}

/**
 * The types task infers guaranteed types globally.
 */
class TypesTask extends CompilerTask {
  static final bool DUMP_SURPRISING_RESULTS = false;

  final String name = 'Type inference';
  SimpleTypesInferrer typesInferrer;
  ConcreteTypesInferrer concreteTypesInferrer;

  TypesTask(Compiler compiler) : super(compiler) {
    typesInferrer = new SimpleTypesInferrer(compiler);
    if (compiler.enableConcreteTypeInference) {
      concreteTypesInferrer = new ConcreteTypesInferrer(compiler);
    }
  }

  /// Replaces native types by their backend implementation.
  Element normalize(Element cls) {
    if (cls == compiler.boolClass) {
      return compiler.backend.boolImplementation;
    }
    if (cls == compiler.intClass) {
      return compiler.backend.intImplementation;
    }
    if (cls == compiler.doubleClass) {
      return compiler.backend.doubleImplementation;
    }
    if (cls == compiler.numClass) {
      return compiler.backend.numImplementation;
    }
    if (cls == compiler.stringClass) {
      return compiler.backend.stringImplementation;
    }
    if (cls == compiler.listClass) {
      return compiler.backend.listImplementation;
    }
    return cls;
  }

  /// Checks that two [DartType]s are the same modulo normalization.
  bool same(DartType type1, DartType type2) {
    return (type1 == type2)
        || normalize(type1.element) == normalize(type2.element);
  }

  /**
   * Checks that one of [type1] and [type2] is a subtype of the other.
   */
  bool related(DartType type1, DartType type2) {
    return compiler.types.isSubtype(type1, type2)
        || compiler.types.isSubtype(type2, type1);
  }

  /**
   * Return the more precise of both types, giving precedence in that order to
   * exactness, subclassing, subtyping and nullability. The [element] parameter
   * is for debugging purposes only and can be omitted.
   */
  TypeMask best(TypeMask type1, TypeMask type2, [element]) {
    final result = _best(type1, type2);
    similar() {
      if (type1 == null) return type2 == null;
      if (type2 == null) return false;
      return same(type1.base, type2.base);
    }
    if (DUMP_SURPRISING_RESULTS && result == type1 && !similar()) {
      print("$type1 better than $type2 for $element");
    }
    return result;
  }

  /// Helper method for [best].
  TypeMask _best(TypeMask type1, TypeMask type2) {
    if (type1 == null) return type2;
    if (type2 == null) return type1;
    if (type1.isExact) {
      if (type2.isExact) {
        assert(same(type1.base, type2.base));
        return type1.isNullable ? type2 : type1;
      } else {
        return type1;
      }
    } else if (type2.isExact) {
      return type2;
    } else if (type1.isSubclass) {
      if (type2.isSubclass) {
        assert(related(type1.base, type2.base));
        if (same(type1.base, type2.base)) {
          return type1.isNullable ? type2 : type1;
        } else if (compiler.types.isSubtype(type1.base, type2.base)) {
          return type1;
        } else {
          return type2;
        }
      } else {
        return type1;
      }
    } else if (type2.isSubclass) {
      return type2;
    } else if (type1.isSubtype) {
      if (type2.isSubtype) {
        assert(related(type1.base, type2.base));
        if (same(type1.base, type2.base)) {
          return type1.isNullable ? type2 : type1;
        } else if (compiler.types.isSubtype(type1.base, type2.base)) {
          return type1;
        } else {
          return type2;
        }
      } else {
        return type1;
      }
    } else if (type2.isSubtype) {
      return type2;
    } else {
      return type1.isNullable ? type2 : type1;
    }
  }

  /**
   * Called when resolution is complete.
   */
  void onResolutionComplete(Element mainElement) {
    measure(() {
      typesInferrer.analyzeMain(mainElement);
      if (concreteTypesInferrer != null) {
        bool success = concreteTypesInferrer.analyzeMain(mainElement);
        if (!success) {
          // If the concrete type inference bailed out, we pretend it didn't
          // happen. In the future we might want to record that it failed but
          // use the partial results as hints.
          concreteTypesInferrer = null;
        }
      }
    });
  }

  /**
   * Return the (inferred) guaranteed type of [element] or null.
   */
  TypeMask getGuaranteedTypeOfElement(Element element) {
    return measure(() {
      TypeMask guaranteedType = typesInferrer.getTypeOfElement(element);
      return (concreteTypesInferrer == null)
          ? guaranteedType
          : best(guaranteedType,
                 concreteTypesInferrer.getTypeOfElement(element),
                 element);
    });
  }

  TypeMask getGuaranteedReturnTypeOfElement(Element element) {
    return measure(() {
      TypeMask guaranteedType =
          typesInferrer.getReturnTypeOfElement(element);
      return (concreteTypesInferrer == null)
          ? guaranteedType
          : best(guaranteedType,
                 concreteTypesInferrer.getReturnTypeOfElement(element),
                 element);
    });
  }

  /**
   * Return the (inferred) guaranteed type of [node] or null.
   * [node] must be an AST node of [owner].
   */
  TypeMask getGuaranteedTypeOfNode(owner, node) {
    return measure(() {
      TypeMask guaranteedType = typesInferrer.getTypeOfNode(owner, node);
      return (concreteTypesInferrer == null)
          ? guaranteedType
          : best(guaranteedType,
                 concreteTypesInferrer.getTypeOfNode(owner, node),
                 node);
    });
  }

  /**
   * Return the (inferred) guaranteed type of [selector] or null.
   * [node] must be an AST node of [owner].
   */
  TypeMask getGuaranteedTypeOfSelector(Selector selector) {
    return measure(() {
      TypeMask guaranteedType =
          typesInferrer.getTypeOfSelector(selector);
      return (concreteTypesInferrer == null)
          ? guaranteedType
          : best(guaranteedType,
                 concreteTypesInferrer.getTypeOfSelector(selector),
                 selector);
    });
  }
}
