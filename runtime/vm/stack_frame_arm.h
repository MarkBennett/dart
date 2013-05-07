// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef VM_STACK_FRAME_ARM_H_
#define VM_STACK_FRAME_ARM_H_

namespace dart {

/* ARM Dart Frame Layout

               |                    | <- TOS
Callee frame   | ...                |
               | current LR         |    (PC of current frame)
               | callee's PC marker |
               +--------------------+
Current frame  | ...                | <- SP of current frame
               | first local        |
               | caller's PP        |
               | caller's FP        | <- FP of current frame
               | caller's LR        |    (PC of caller frame)
               | PC marker          |    (current frame's code entry + offset)
               +--------------------+
Caller frame   | last parameter     | <- SP of caller frame
               |  ...               |
*/

static const int kSavedPcSlotFromSp = -2;
static const int kFirstLocalSlotFromFp = -2;
static const int kSavedCallerFpSlotFromFp = 0;
static const int kPcMarkerSlotFromFp = 2;
static const int kParamEndSlotFromFp = 2;  // Same slot as current pc marker.
static const int kCallerSpSlotFromFp = 3;

// Entry and exit frame layout.
static const int kSavedContextSlotFromEntryFp = -10;
static const int kExitLinkSlotFromEntryFp = -9;

}  // namespace dart

#endif  // VM_STACK_FRAME_ARM_H_

