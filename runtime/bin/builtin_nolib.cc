// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <stdio.h>

#include "include/dart_api.h"

#include "bin/builtin.h"
#include "bin/dartutils.h"
#include "bin/io_natives.h"


namespace dart {
namespace bin {

Builtin::builtin_lib_props Builtin::builtin_libraries_[] = {
  /* { url_, source_, patch_url_, patch_source_, has_natives_ } */
  { DartUtils::kBuiltinLibURL, NULL, NULL, NULL, true },
  { DartUtils::kIOLibURL, NULL, NULL, NULL, true  },
};


Dart_Handle Builtin::Source(BuiltinLibraryId id) {
  ASSERT((sizeof(builtin_libraries_) / sizeof(builtin_lib_props)) ==
         kInvalidLibrary);
  return Dart_NewApiError("Unreachable code in Builtin::Source (%d).", id);
}

/**
 * Looks up native functions in both libdart_builtin and libdart_io.
 */
Dart_NativeFunction Builtin::NativeLookup(Dart_Handle name,
                                          int argument_count) {
  Dart_NativeFunction result = BuiltinNativeLookup(name, argument_count);
  if (result != NULL) return result;
  return IONativeLookup(name, argument_count);
}

void Builtin::SetNativeResolver(BuiltinLibraryId id) {
  ASSERT((sizeof(builtin_libraries_) / sizeof(builtin_lib_props)) ==
         kInvalidLibrary);
  ASSERT(id >= kBuiltinLibrary && id < kInvalidLibrary);
  if (builtin_libraries_[id].has_natives_) {
    Dart_Handle url = DartUtils::NewString(builtin_libraries_[id].url_);
    Dart_Handle library = Dart_LookupLibrary(url);
    ASSERT(!Dart_IsError(library));
    // Setup the native resolver for built in library functions.
    DART_CHECK_VALID(Dart_SetNativeResolver(library, NativeLookup));
  }
}


Dart_Handle Builtin::LoadAndCheckLibrary(BuiltinLibraryId id) {
  ASSERT((sizeof(builtin_libraries_) / sizeof(builtin_lib_props)) ==
         kInvalidLibrary);
  ASSERT(id >= kBuiltinLibrary && id < kInvalidLibrary);
  Dart_Handle url = DartUtils::NewString(builtin_libraries_[id].url_);
  Dart_Handle library = Dart_LookupLibrary(url);
  if (Dart_IsError(library)) {
    ASSERT(id > kIOLibrary);
    library = Dart_LoadLibrary(url, Source(id));
    if (!Dart_IsError(library) && (builtin_libraries_[id].has_natives_)) {
      // Setup the native resolver for built in library functions.
      DART_CHECK_VALID(Dart_SetNativeResolver(library, NativeLookup));
    }
  }
  DART_CHECK_VALID(library);
  return library;
}

}  // namespace bin
}  // namespace dart
