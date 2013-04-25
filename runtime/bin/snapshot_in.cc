// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file is linked into the dart executable when it has a snapshot
// linked into it.

#if defined(_WIN32)
typedef unsigned __int8 uint8_t;
#else
#include <inttypes.h>
#include <stdint.h>
#endif
#include <stddef.h>


namespace dart {
namespace bin {

// The string on the next line will be filled in with the contents of the
// generated snapshot binary file.
// This string forms the content of a snapshot which is loaded in by dart.
static const uint8_t snapshot_buffer_[] = {
  %s
};
const uint8_t* snapshot_buffer = snapshot_buffer_;

}  // namespace bin
}  // namespace dart
