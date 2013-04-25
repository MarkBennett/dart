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
  { DartUtils::kBuiltinLibURL, builtin_source_, NULL, NULL, true },
  { DartUtils::kIOLibURL, io_source_,
    DartUtils::kIOLibPatchURL, io_patch_, true },
};


Dart_Handle Builtin::Source(BuiltinLibraryId id) {
  ASSERT((sizeof(builtin_libraries_) / sizeof(builtin_lib_props)) ==
         kInvalidLibrary);
  ASSERT(id >= kBuiltinLibrary && id < kInvalidLibrary);
  return DartUtils::NewString(builtin_libraries_[id].source_);
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
  UNREACHABLE();
}


Dart_Handle Builtin::LoadAndCheckLibrary(BuiltinLibraryId id) {
  ASSERT((sizeof(builtin_libraries_) / sizeof(builtin_lib_props)) ==
         kInvalidLibrary);
  ASSERT(id >= kBuiltinLibrary && id < kInvalidLibrary);
  Dart_Handle url = DartUtils::NewString(builtin_libraries_[id].url_);
  Dart_Handle library = Dart_LookupLibrary(url);
  if (Dart_IsError(library)) {
    library = Dart_LoadLibrary(url, Source(id));
    if (!Dart_IsError(library) && (builtin_libraries_[id].has_natives_)) {
      // Setup the native resolver for built in library functions.
      DART_CHECK_VALID(Dart_SetNativeResolver(library, NativeLookup));
    }
    if (builtin_libraries_[id].patch_url_ != NULL) {
      ASSERT(builtin_libraries_[id].patch_source_ != NULL);
      Dart_Handle patch_url =
          DartUtils::NewString(builtin_libraries_[id].patch_url_);
      Dart_Handle patch_source =
          DartUtils::NewString(builtin_libraries_[id].patch_source_);
      DART_CHECK_VALID(Dart_LoadPatch(library, patch_url, patch_source));
    }
  }
  DART_CHECK_VALID(library);
  return library;
}

}  // namespace bin
}  // namespace dart
