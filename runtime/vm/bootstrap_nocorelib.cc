// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/bootstrap.h"

#include "include/dart_api.h"

#include "vm/dart_api_impl.h"
#include "vm/object.h"
#include "vm/object_store.h"

namespace dart {

DEFINE_FLAG(bool, print_bootstrap, false, "Print the bootstrap source.");


RawError* Bootstrap::LoadandCompileScripts() {
  UNREACHABLE();
  return Error::null();
}

}  // namespace dart
