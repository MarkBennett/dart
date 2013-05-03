// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef VM_BOOTSTRAP_H_
#define VM_BOOTSTRAP_H_

#include "vm/allocation.h"

namespace dart {

// Forward declarations.
class RawError;

class Bootstrap : public AllStatic {
 public:
  static RawError* LoadandCompileScripts();
  static void SetupNativeResolver();

  // Source path mapping for library URI and 'parts'.
  static const char* async_source_paths_[];
  static const char* corelib_source_paths_[];
  static const char* collection_source_paths_[];
  static const char* collection_dev_source_paths_[];
  static const char* crypto_source_paths_[];
  static const char* isolate_source_paths_[];
  static const char* json_source_paths_[];
  static const char* math_source_paths_[];
  static const char* mirrors_source_paths_[];
  static const char* typed_data_source_paths_[];
  static const char* uri_source_paths_[];
  static const char* utf_source_paths_[];

  // Patch sources for libaries (concatenated source).
  static const char async_patch_[];
  static const char corelib_patch_[];
  static const char collection_patch_[];
  static const char collection_dev_patch_[];
  static const char isolate_patch_[];
  static const char json_patch_[];
  static const char math_patch_[];
  static const char mirrors_patch_[];
  static const char typed_data_patch_[];
};

}  // namespace dart

#endif  // VM_BOOTSTRAP_H_
