// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef VM_CLASS_FINALIZER_H_
#define VM_CLASS_FINALIZER_H_

#include "vm/allocation.h"
#include "vm/growable_array.h"

namespace dart {

class AbstractType;
class MixinAppType;
class AbstractTypeArguments;
class Class;
class Error;
class Function;
class GrowableObjectArray;
class RawAbstractType;
class RawClass;
class RawType;
class Script;
class Type;
class UnresolvedClass;

// Traverses all pending, unfinalized classes, validates and marks them as
// finalized.
class ClassFinalizer : public AllStatic {
 public:
  // Modes for type resolution and finalization. The ordering is relevant.
  enum FinalizationKind {
    kIgnore,                   // Type is ignored and replaced by dynamic.
    kDoNotResolve,             // Type resolution is postponed.
    kTryResolve,               // Type resolution is attempted.
    kFinalize,                 // Type resolution and type finalization are
                               // required; a malformed type is tolerated, since
                               // the type may be used as a type annotation.
    kCanonicalize,             // Same as kFinalize, but with canonicalization.
    kCanonicalizeExpression,   // Same as kCanonicalize, but do not tolerate
                               // wrong number of type arguments or ambiguous
                               // type reference, since the type is not used as
                               // a type annotation, but as a type expression.
    kCanonicalizeWellFormed    // Error-free resolution, finalization, and
                               // canonicalization are required; a malformed
                               // type is not tolerated.
  };

  // Finalize given type while parsing class cls.
  // Also canonicalize type if applicable.
  static RawAbstractType* FinalizeType(const Class& cls,
                                       const AbstractType& type,
                                       FinalizationKind finalization);

  // Allocate, finalize, and return a new malformed type as if it was declared
  // in class cls at the given token position.
  // If not null, prepend prev_error to the error message built from the format
  // string and its arguments.
  static RawType* NewFinalizedMalformedType(const Error& prev_error,
                                            const Class& cls,
                                            intptr_t type_pos,
                                            FinalizationKind finalization,
                                            const char* format, ...)
       PRINTF_ATTRIBUTE(5, 6);

  // Depending on the given type, finalization mode, and execution mode, mark
  // the given type as malformed or report a compile time error.
  // If not null, prepend prev_error to the error message built from the format
  // string and its arguments.
  static void FinalizeMalformedType(const Error& prev_error,
                                    const Class& cls,
                                    const Type& type,
                                    FinalizationKind finalization,
                                    const char* format, ...)
       PRINTF_ATTRIBUTE(5, 6);

  // Return false if we still have classes pending to be finalized.
  static bool AllClassesFinalized();

  // Return whether class finalization failed.
  // The function returns true if the finalization was successful.
  // If finalization fails, an error message is set in the sticky error field
  // in the object store.
  static bool FinalizePendingClasses();


  // Verify that the classes have been properly prefinalized. This is
  // needed during bootstrapping where the classes have been preloaded.
  static void VerifyBootstrapClasses();

 private:
  static void FinalizeClass(const Class& cls);
  static bool IsSuperCycleFree(const Class& cls);
  static bool IsAliasCycleFree(const Class& cls,
                               GrowableArray<intptr_t>* visited);
  static void CheckForLegalConstClass(const Class& cls);
  static RawClass* ResolveClass(const Class& cls,
                                const UnresolvedClass& unresolved_class);
  static void ResolveRedirectingFactoryTarget(
      const Class& cls,
      const Function& factory,
      const GrowableObjectArray& visited_factories);
  static void CloneTypeParameters(const Class& mixapp_class);
  static void ApplyMixin(const Class& cls);
  static void CollectTypeArguments(const Class& cls,
                                   const Type& type,
                                   const GrowableObjectArray& collected_args);
  static RawType* ResolveMixinAppType(const Class& cls,
                                      const MixinAppType& mixin_app);
  static void ResolveSuperTypeAndInterfaces(const Class& cls,
                                            GrowableArray<intptr_t>* visited);
  static void FinalizeTypeParameters(const Class& cls);
  static void FinalizeTypeArguments(const Class& cls,
                                    const AbstractTypeArguments& arguments,
                                    FinalizationKind finalization,
                                    Error* bound_error);
  static void CheckTypeArgumentBounds(const Class& cls,
                                      const AbstractTypeArguments& arguments,
                                      Error* bound_error);
  static void ResolveType(const Class& cls,
                          const AbstractType& type,
                          FinalizationKind finalization);
  static void ResolveUpperBounds(const Class& cls);
  static void FinalizeUpperBounds(const Class& cls);
  static void ResolveAndFinalizeSignature(const Class& cls,
                                          const Function& function);
  static void ResolveAndFinalizeMemberTypes(const Class& cls);
  static void PrintClassInformation(const Class& cls);
  static void CollectInterfaces(const Class& cls,
                                const GrowableObjectArray& interfaces);
  static void ReportMalformedType(const Error& prev_error,
                                  const Class& cls,
                                  const Type& type,
                                  FinalizationKind finalization,
                                  const char* format,
                                  va_list args);
  static void ReportError(const Error& error);
  static void ReportError(const Script& script,
                          intptr_t token_index,
                          const char* format, ...) PRINTF_ATTRIBUTE(3, 4);
  static void ReportError(const char* format, ...) PRINTF_ATTRIBUTE(1, 2);

  // Verify implicit offsets recorded in the VM for direct access to fields of
  // Dart instances (e.g: _TypedListView, _ByteDataView).
  static void VerifyImplicitFieldOffsets();
};

}  // namespace dart

#endif  // VM_CLASS_FINALIZER_H_
