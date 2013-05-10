// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/globals.h"  // Needed here to get TARGET_ARCH_X64.
#if defined(TARGET_ARCH_X64)

#include "vm/assembler.h"
#include "vm/code_patcher.h"
#include "vm/cpu.h"
#include "vm/dart_entry.h"
#include "vm/instructions.h"
#include "vm/object.h"
#include "vm/raw_object.h"

namespace dart {

// The pattern of a Dart instance call is:
//  00: 48 bb imm64  mov RBX, immediate 1
//  10: 49 ba imm64  mov R10, immediate 2
//  20: 49 bb imm64  mov R11, target_address
//  30: 41 ff d3     call R11
//  33: <- return_address
class DartCallPattern : public ValueObject {
 public:
  explicit DartCallPattern(uword return_address)
      : start_(return_address - kCallPatternSize) {
    ASSERT(IsValid(return_address));
    ASSERT((kCallPatternSize - 20) == Assembler::kCallExternalLabelSize);
  }

  static const int kCallPatternSize = 33;

  static bool IsValid(uword return_address) {
    uint8_t* code_bytes =
        reinterpret_cast<uint8_t*>(return_address - kCallPatternSize);
    return (code_bytes[00] == 0x48) && (code_bytes[01] == 0xBB) &&
           (code_bytes[10] == 0x49) && (code_bytes[11] == 0xBA) &&
           (code_bytes[20] == 0x49) && (code_bytes[21] == 0xBB) &&
           (code_bytes[30] == 0x41) && (code_bytes[31] == 0xFF) &&
           (code_bytes[32] == 0xD3);
  }

  uword target() const {
    return *reinterpret_cast<uword*>(start_ + 20 + 2);
  }

  void set_target(uword target) const {
    uword* target_addr = reinterpret_cast<uword*>(start_ + 20 + 2);
    *target_addr = target;
    CPU::FlushICache(start_ + 20, 2 + 8);
  }

  RawObject* immediate_one() const {
    return *reinterpret_cast<RawObject**>(start_ + 0 + 2);
  }

  RawObject* immediate_two() const {
    return *reinterpret_cast<RawObject**>(start_ + 10 + 2);
  }

 private:
  uword start_;
  DISALLOW_IMPLICIT_CONSTRUCTORS(DartCallPattern);
};


// A Dart instance call passes the ic-data in RBX.
// The expected pattern of a dart instance call:
//  mov RBX, ic-data
//  mov R10, arguments_descriptor_array
//  mov R11, target_address
//  call R11
//  <- return address
class InstanceCall : public DartCallPattern {
 public:
  explicit InstanceCall(uword return_address)
      : DartCallPattern(return_address) {}

  RawObject* ic_data() const { return immediate_one(); }
  RawObject* arguments_descriptor() const { return immediate_two(); }

 private:
  DISALLOW_IMPLICIT_CONSTRUCTORS(InstanceCall);
};


// The expected pattern of a dart static call:
//  mov R10, arguments_descriptor_array (10 bytes) (optional in polym. calls)
//  mov R11, target_address (10 bytes)
//  call R11  (3 bytes)
//  <- return address
class StaticCall : public ValueObject {
 public:
  explicit StaticCall(uword return_address)
      : start_(return_address - kCallPatternSize) {
    ASSERT(IsValid(return_address));
    ASSERT(kCallPatternSize == Assembler::kCallExternalLabelSize);
  }

  static const int kCallPatternSize = 13;

  static bool IsValid(uword return_address) {
    uint8_t* code_bytes =
        reinterpret_cast<uint8_t*>(return_address - kCallPatternSize);
    return (code_bytes[00] == 0x49) && (code_bytes[01] == 0xBB) &&
           (code_bytes[10] == 0x41) && (code_bytes[11] == 0xFF) &&
           (code_bytes[12] == 0xD3);
  }

  uword target() const {
    return *reinterpret_cast<uword*>(start_ + 2);
  }

  void set_target(uword target) const {
    uword* target_addr = reinterpret_cast<uword*>(start_ + 2);
    *target_addr = target;
    CPU::FlushICache(start_, 2 + 8);
  }

 private:
  uword start_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(StaticCall);
};


// The expected code pattern of a dart closure call:
//  00: 49 ba imm64  mov R10, immediate 2      ; 10 bytes
//  10: 49 bb imm64  mov R11, target_address   ; 10 bytes
//  20: 41 ff d3     call R11                  ; 3 bytes
//  23: <- return_address
class ClosureCall : public ValueObject {
 public:
  explicit ClosureCall(uword return_address)
      : start_(return_address - kCallPatternSize) {
    ASSERT(IsValid(return_address));
  }

  static bool IsValid(uword return_address) {
    uint8_t* code_bytes =
        reinterpret_cast<uint8_t*>(return_address - kCallPatternSize);
    return (code_bytes[00] == 0x49) && (code_bytes[01] == 0xBA) &&
           (code_bytes[10] == 0x49) && (code_bytes[11] == 0xBB) &&
           (code_bytes[20] == 0x41) && (code_bytes[21] == 0xFF) &&
           (code_bytes[22] == 0xD3);
  }

  RawArray* arguments_descriptor() const {
    return *reinterpret_cast<RawArray**>(start_ + 2);
  }

 private:
  static const int kCallPatternSize = 10 + 10 + 3;
  uword start_;
  DISALLOW_IMPLICIT_CONSTRUCTORS(ClosureCall);
};


RawArray* CodePatcher::GetClosureArgDescAt(uword return_address,
                                           const Code& code) {
  ASSERT(code.ContainsInstructionAt(return_address));
  ClosureCall call(return_address);
  return call.arguments_descriptor();
}


uword CodePatcher::GetStaticCallTargetAt(uword return_address,
                                         const Code& code) {
  ASSERT(code.ContainsInstructionAt(return_address));
  StaticCall call(return_address);
  return call.target();
}


void CodePatcher::PatchStaticCallAt(uword return_address,
                                    const Code& code,
                                    uword new_target) {
  ASSERT(code.ContainsInstructionAt(return_address));
  StaticCall call(return_address);
  call.set_target(new_target);
}


void CodePatcher::PatchInstanceCallAt(uword return_address,
                                      const Code& code,
                                      uword new_target) {
  ASSERT(code.ContainsInstructionAt(return_address));
  InstanceCall call(return_address);
  call.set_target(new_target);
}


uword CodePatcher::GetInstanceCallAt(uword return_address,
                                     const Code& code,
                                     ICData* ic_data,
                                     Array* arguments_descriptor) {
  ASSERT(code.ContainsInstructionAt(return_address));
  InstanceCall call(return_address);
  if (ic_data != NULL) {
    *ic_data ^= call.ic_data();
  }
  if (arguments_descriptor != NULL) {
    *arguments_descriptor ^= call.arguments_descriptor();
  }
  return call.target();
}


intptr_t CodePatcher::InstanceCallSizeInBytes() {
  return DartCallPattern::kCallPatternSize;
}


void CodePatcher::InsertCallAt(uword start, uword target) {
  // The inserted call should not overlap the lazy deopt jump code.
  ASSERT(start + ShortCallPattern::InstructionLength() <= target);
  *reinterpret_cast<uint8_t*>(start) = 0xE8;
  ShortCallPattern call(start);
  call.SetTargetAddress(target);
  CPU::FlushICache(start, ShortCallPattern::InstructionLength());
}


}  // namespace dart

#endif  // defined TARGET_ARCH_X64
