// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/globals.h"  // Needed here to get TARGET_ARCH_ARM.
#if defined(TARGET_ARCH_ARM)

#include "vm/code_patcher.h"

#include "vm/instructions.h"
#include "vm/object.h"

namespace dart {

uword CodePatcher::GetStaticCallTargetAt(uword return_address,
                                         const Code& code) {
  ASSERT(code.ContainsInstructionAt(return_address));
  CallPattern call(return_address, code);
  return call.TargetAddress();
}


void CodePatcher::PatchStaticCallAt(uword return_address,
                                    const Code& code,
                                    uword new_target) {
  ASSERT(code.ContainsInstructionAt(return_address));
  CallPattern call(return_address, code);
  call.SetTargetAddress(new_target);
}


void CodePatcher::PatchInstanceCallAt(uword return_address,
                                      const Code& code,
                                      uword new_target) {
  ASSERT(code.ContainsInstructionAt(return_address));
  CallPattern call(return_address, code);
  call.SetTargetAddress(new_target);
}


void CodePatcher::InsertCallAt(uword start, uword target) {
  // The inserted call should not overlap the lazy deopt jump code.
  ASSERT(start + CallPattern::kFixedLengthInBytes <= target);
  CallPattern::InsertAt(start, target);
}


uword CodePatcher::GetInstanceCallAt(uword return_address,
                                     const Code& code,
                                     ICData* ic_data,
                                     Array* arguments_descriptor) {
  ASSERT(code.ContainsInstructionAt(return_address));
  CallPattern call(return_address, code);
  if (ic_data != NULL) {
    *ic_data = call.IcData();
  }
  if (arguments_descriptor != NULL) {
    *arguments_descriptor = call.ArgumentsDescriptor();
  }
  return call.TargetAddress();
}


intptr_t CodePatcher::InstanceCallSizeInBytes() {
  // The instance call instruction sequence has a variable size on ARM.
  UNREACHABLE();
  return 0;
}

}  // namespace dart

#endif  // defined TARGET_ARCH_ARM
