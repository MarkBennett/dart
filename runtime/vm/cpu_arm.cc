// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/globals.h"

#if defined(TARGET_ARCH_ARM)

#if defined(HOST_ARCH_ARM)
#include <sys/syscall.h>  /* NOLINT */
#include <unistd.h>  /* NOLINT */
#endif

#include "vm/cpu.h"

namespace dart {

void CPU::FlushICache(uword start, uword size) {
#if defined(HOST_ARCH_ARM)

#if defined(__ARM_EABI__) && !defined(__thumb__)
  syscall(__ARM_NR_cacheflush, start, start + size, 0);
#else
#error FlushICache only tested/supported on EABI ARM currently.
#endif

#else  // defined(HOST_ARCH_ARM)
  // When running in simulated mode we do not need to flush the ICache because
  // we are not running on the actual hardware.
#endif  // defined(HOST_ARCH_ARM)
}


const char* CPU::Id() {
  return
#if !defined(HOST_ARCH_ARM)
  "sim"
#endif  // !defined(HOST_ARCH_ARM)
  "arm";
}

}  // namespace dart

#endif  // defined TARGET_ARCH_ARM
