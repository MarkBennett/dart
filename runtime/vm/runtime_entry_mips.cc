// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/globals.h"
#if defined(TARGET_ARCH_MIPS)

#include "vm/runtime_entry.h"

#include "vm/assembler.h"
#include "vm/simulator.h"
#include "vm/stub_code.h"

namespace dart {

#define __ assembler->


// Generate code to call into the stub which will call the runtime
// function. Input for the stub is as follows:
//   SP : points to the arguments and return value array.
//   S5 : address of the runtime function to call.
//   S4 : number of arguments to the call.
void RuntimeEntry::Call(Assembler* assembler) const {
  // Compute the effective address. When running under the simulator,
  // this is a redirection address that forces the simulator to call
  // into the runtime system.
  uword entry = GetEntryPoint();
#if defined(USING_SIMULATOR)
  // Redirection to leaf runtime calls supports a maximum of 4 arguments passed
  // in registers.
  ASSERT(!is_leaf() || (argument_count() <= 4));
  Simulator::CallKind call_kind =
      is_leaf() ? Simulator::kLeafRuntimeCall : Simulator::kRuntimeCall;
  entry = Simulator::RedirectExternalReference(entry, call_kind);
#endif
  if (is_leaf()) {
    ExternalLabel label(name(), entry);
    __ BranchLink(&label);
  } else {
    __ LoadImmediate(S5, entry);
    __ LoadImmediate(S4, argument_count());
    __ BranchLink(&StubCode::CallToRuntimeLabel());
  }
}

}  // namespace dart

#endif  // defined TARGET_ARCH_MIPS
