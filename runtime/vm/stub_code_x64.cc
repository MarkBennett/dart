// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/globals.h"
#if defined(TARGET_ARCH_X64)

#include "vm/assembler.h"
#include "vm/compiler.h"
#include "vm/dart_entry.h"
#include "vm/flow_graph_compiler.h"
#include "vm/heap.h"
#include "vm/instructions.h"
#include "vm/object_store.h"
#include "vm/resolver.h"
#include "vm/scavenger.h"
#include "vm/stack_frame.h"
#include "vm/stub_code.h"


#define __ assembler->

namespace dart {

DEFINE_FLAG(bool, inline_alloc, true, "Inline allocation of objects.");
DEFINE_FLAG(bool, use_slow_path, false,
    "Set to true for debugging & verifying the slow paths.");
DECLARE_FLAG(int, optimization_counter_threshold);
DECLARE_FLAG(bool, trace_optimized_ic_calls);

// Input parameters:
//   RSP : points to return address.
//   RSP + 8 : address of last argument in argument array.
//   RSP + 8*R10 : address of first argument in argument array.
//   RSP + 8*R10 + 8 : address of return value.
//   RBX : address of the runtime function to call.
//   R10 : number of arguments to the call.
// Must preserve callee saved registers R12 and R13.
void StubCode::GenerateCallToRuntimeStub(Assembler* assembler) {
  ASSERT((R12 != CTX) && (R13 != CTX));
  const intptr_t isolate_offset = NativeArguments::isolate_offset();
  const intptr_t argc_tag_offset = NativeArguments::argc_tag_offset();
  const intptr_t argv_offset = NativeArguments::argv_offset();
  const intptr_t retval_offset = NativeArguments::retval_offset();

  __ EnterFrame(0);

  // Load current Isolate pointer from Context structure into RAX.
  __ movq(RAX, FieldAddress(CTX, Context::isolate_offset()));

  // Save exit frame information to enable stack walking as we are about
  // to transition to Dart VM C++ code.
  __ movq(Address(RAX, Isolate::top_exit_frame_info_offset()), RSP);

  // Save current Context pointer into Isolate structure.
  __ movq(Address(RAX, Isolate::top_context_offset()), CTX);

  // Cache Isolate pointer into CTX while executing runtime code.
  __ movq(CTX, RAX);

  // Reserve space for arguments and align frame before entering C++ world.
  __ AddImmediate(RSP, Immediate(-sizeof(NativeArguments)));
  if (OS::ActivationFrameAlignment() > 0) {
    __ andq(RSP, Immediate(~(OS::ActivationFrameAlignment() - 1)));
  }

  // Pass NativeArguments structure by value and call runtime.
  __ movq(Address(RSP, isolate_offset), CTX);  // Set isolate in NativeArgs.
  // There are no runtime calls to closures, so we do not need to set the tag
  // bits kClosureFunctionBit and kInstanceFunctionBit in argc_tag_.
  __ movq(Address(RSP, argc_tag_offset), R10);  // Set argc in NativeArguments.
  __ leaq(RAX, Address(RBP, R10, TIMES_8, 1 * kWordSize));  // Compute argv.
  __ movq(Address(RSP, argv_offset), RAX);  // Set argv in NativeArguments.
  __ addq(RAX, Immediate(1 * kWordSize));  // Retval is next to 1st argument.
  __ movq(Address(RSP, retval_offset), RAX);  // Set retval in NativeArguments.
  __ call(RBX);

  // Reset exit frame information in Isolate structure.
  __ movq(Address(CTX, Isolate::top_exit_frame_info_offset()), Immediate(0));

  // Load Context pointer from Isolate structure into RBX.
  __ movq(RBX, Address(CTX, Isolate::top_context_offset()));

  // Reset Context pointer in Isolate structure.
  const Immediate& raw_null =
      Immediate(reinterpret_cast<intptr_t>(Object::null()));
  __ movq(Address(CTX, Isolate::top_context_offset()), raw_null);

  // Cache Context pointer into CTX while executing Dart code.
  __ movq(CTX, RBX);

  __ LeaveFrame();
  __ ret();
}


// Print the stop message.
DEFINE_LEAF_RUNTIME_ENTRY(void, PrintStopMessage, const char* message) {
  OS::Print("Stop message: %s\n", message);
}
END_LEAF_RUNTIME_ENTRY


// Input parameters:
//   RSP : points to return address.
//   RDI : stop message (const char*).
// Must preserve all registers.
void StubCode::GeneratePrintStopMessageStub(Assembler* assembler) {
  __ EnterCallRuntimeFrame(0);
  // Call the runtime leaf function. RDI already contains the parameter.
  __ CallRuntime(kPrintStopMessageRuntimeEntry);
  __ LeaveCallRuntimeFrame();
  __ ret();
}


// Input parameters:
//   RSP : points to return address.
//   RSP + 8 : address of return value.
//   RAX : address of first argument in argument array.
//   RBX : address of the native function to call.
//   R10 : argc_tag including number of arguments and function kind.
void StubCode::GenerateCallNativeCFunctionStub(Assembler* assembler) {
  const intptr_t native_args_struct_offset = 0;
  const intptr_t isolate_offset =
      NativeArguments::isolate_offset() + native_args_struct_offset;
  const intptr_t argc_tag_offset =
      NativeArguments::argc_tag_offset() + native_args_struct_offset;
  const intptr_t argv_offset =
      NativeArguments::argv_offset() + native_args_struct_offset;
  const intptr_t retval_offset =
      NativeArguments::retval_offset() + native_args_struct_offset;

  __ EnterFrame(0);

  // Load current Isolate pointer from Context structure into R8.
  __ movq(R8, FieldAddress(CTX, Context::isolate_offset()));

  // Save exit frame information to enable stack walking as we are about
  // to transition to native code.
  __ movq(Address(R8, Isolate::top_exit_frame_info_offset()), RSP);

  // Save current Context pointer into Isolate structure.
  __ movq(Address(R8, Isolate::top_context_offset()), CTX);

  // Cache Isolate pointer into CTX while executing native code.
  __ movq(CTX, R8);

  // Reserve space for the native arguments structure passed on the stack (the
  // outgoing pointer parameter to the native arguments structure is passed in
  // RDI) and align frame before entering the C++ world.
  __ AddImmediate(RSP, Immediate(-sizeof(NativeArguments)));
  if (OS::ActivationFrameAlignment() > 0) {
    __ andq(RSP, Immediate(~(OS::ActivationFrameAlignment() - 1)));
  }

  // Pass NativeArguments structure by value and call native function.
  __ movq(Address(RSP, isolate_offset), CTX);  // Set isolate in NativeArgs.
  __ movq(Address(RSP, argc_tag_offset), R10);  // Set argc in NativeArguments.
  __ movq(Address(RSP, argv_offset), RAX);  // Set argv in NativeArguments.
  __ leaq(RAX, Address(RBP, 2 * kWordSize));  // Compute return value addr.
  __ movq(Address(RSP, retval_offset), RAX);  // Set retval in NativeArguments.
  __ movq(RDI, RSP);  // Pass the pointer to the NativeArguments.
  __ call(RBX);

  // Reset exit frame information in Isolate structure.
  __ movq(Address(CTX, Isolate::top_exit_frame_info_offset()), Immediate(0));

  // Load Context pointer from Isolate structure into R8.
  __ movq(R8, Address(CTX, Isolate::top_context_offset()));

  // Reset Context pointer in Isolate structure.
  const Immediate& raw_null =
      Immediate(reinterpret_cast<intptr_t>(Object::null()));
  __ movq(Address(CTX, Isolate::top_context_offset()), raw_null);

  // Cache Context pointer into CTX while executing Dart code.
  __ movq(CTX, R8);

  __ LeaveFrame();
  __ ret();
}


// Input parameters:
//   R10: arguments descriptor array.
void StubCode::GenerateCallStaticFunctionStub(Assembler* assembler) {
  const Immediate& raw_null =
      Immediate(reinterpret_cast<intptr_t>(Object::null()));
  __ EnterStubFrame();
  __ pushq(R10);  // Preserve arguments descriptor array.
  __ pushq(raw_null);  // Setup space on stack for return value.
  __ CallRuntime(kPatchStaticCallRuntimeEntry);
  __ popq(RAX);  // Get Code object result.
  __ popq(R10);  // Restore arguments descriptor array.
  // Remove the stub frame as we are about to jump to the dart function.
  __ LeaveFrame();

  __ movq(RBX, FieldAddress(RAX, Code::instructions_offset()));
  __ addq(RBX, Immediate(Instructions::HeaderSize() - kHeapObjectTag));
  __ jmp(RBX);
}


// Called from a static call only when an invalid code has been entered
// (invalid because its function was optimized or deoptimized).
// R10: arguments descriptor array.
void StubCode::GenerateFixCallersTargetStub(Assembler* assembler) {
  const Immediate& raw_null =
      Immediate(reinterpret_cast<intptr_t>(Object::null()));
  __ EnterStubFrame();
  __ pushq(R10);  // Preserve arguments descriptor array.
  __ pushq(raw_null);  // Setup space on stack for return value.
  __ CallRuntime(kFixCallersTargetRuntimeEntry);
  __ popq(RAX);  // Get Code object.
  __ popq(R10);  // Restore arguments descriptor array.
  __ movq(RAX, FieldAddress(RAX, Code::instructions_offset()));
  __ addq(RAX, Immediate(Instructions::HeaderSize() - kHeapObjectTag));
  __ LeaveFrame();
  __ jmp(RAX);
  __ int3();
}


// Input parameters:
//   R10: smi-tagged argument count, may be zero.
static void PushArgumentsArray(Assembler* assembler, intptr_t arg_offset) {
  const Immediate& raw_null =
      Immediate(reinterpret_cast<intptr_t>(Object::null()));

  // Allocate array to store arguments of caller.
  __ movq(RBX, raw_null);  // Null element type for raw Array.
  __ call(&StubCode::AllocateArrayLabel());
  __ SmiUntag(R10);
  // RAX: newly allocated array.
  // R10: length of the array (was preserved by the stub).
  __ pushq(RAX);  // Array is in RAX and on top of stack.
  __ leaq(R12, Address(RSP, R10, TIMES_8, arg_offset));  // Addr of first arg.
  __ leaq(RBX, FieldAddress(RAX, Array::data_offset()));
  Label loop, loop_condition;
  __ jmp(&loop_condition, Assembler::kNearJump);
  __ Bind(&loop);
  __ movq(RAX, Address(R12, 0));
  __ movq(Address(RBX, 0), RAX);
  __ AddImmediate(RBX, Immediate(kWordSize));
  __ AddImmediate(R12, Immediate(-kWordSize));
  __ Bind(&loop_condition);
  __ decq(R10);
  __ j(POSITIVE, &loop, Assembler::kNearJump);
}


// Input parameters:
//   RBX: ic-data.
//   R10: arguments descriptor array.
// Note: The receiver object is the first argument to the function being
//       called, the stub accesses the receiver from this location directly
//       when trying to resolve the call.
void StubCode::GenerateInstanceFunctionLookupStub(Assembler* assembler) {
  __ EnterStubFrame();

  const Immediate& raw_null =
      Immediate(reinterpret_cast<intptr_t>(Object::null()));
  __ pushq(raw_null);  // Space for the return value.

  // Push the receiver as an argument.  Load the smi-tagged argument
  // count into R13 to index the receiver in the stack.  There are
  // three words (null, stub's pc marker, saved fp) above the return
  // address.
  __ movq(R13, FieldAddress(R10, ArgumentsDescriptor::count_offset()));
  __ pushq(Address(RSP, R13, TIMES_4, (3 * kWordSize)));

  __ pushq(RBX);  // Pass IC data object.
  __ pushq(R10);  // Pass arguments descriptor array.

  // Pass the call's arguments array.
  __ movq(R10, R13);  // Smi-tagged arguments array length.
  PushArgumentsArray(assembler, (7 * kWordSize));
  // Stack layout explaining "(7 * kWordSize)" offset.
  // TOS + 0: Arguments array.
  // TOS + 1: Arguments descriptor array.
  // TOS + 2: IC data object.
  // TOS + 3: Receiver.
  // TOS + 4: Space for the result of the runtime call.
  // TOS + 5: Stub's PC marker (0)
  // TOS + 6: Saved FP
  // TOS + 7: Dart code return address
  // TOS + 8: Last argument of caller.
  // ....

  __ CallRuntime(kInstanceFunctionLookupRuntimeEntry);
  // Remove arguments.
  __ popq(RAX);
  __ popq(RAX);
  __ popq(RAX);
  __ popq(RAX);
  __ popq(RAX);  // Get result into RAX.
  __ LeaveFrame();
  __ ret();
}


DECLARE_LEAF_RUNTIME_ENTRY(intptr_t, DeoptimizeCopyFrame,
                           intptr_t deopt_reason,
                           uword saved_registers_address);

DECLARE_LEAF_RUNTIME_ENTRY(void, DeoptimizeFillFrame, uword last_fp);


// This stub translates optimized frame into unoptimized frame. The optimized
// frame can contain values in registers and on stack, the unoptimized
// frame contains all values on stack.
// Deoptimization occurs in following steps:
// - Push all registers that can contain values.
// - Call C routine to copy the stack and saved registers into temporary buffer.
// - Adjust caller's frame to correct unoptimized frame size.
// - Fill the unoptimized frame.
// - Materialize objects that require allocation (e.g. Double instances).
// GC can occur only after frame is fully rewritten.
// Stack after EnterFrame(0) below:
//   +------------------+
//   | Saved FP         | <- TOS
//   +------------------+
//   | return-address   |  (deoptimization point)
//   +------------------+
//   | optimized frame  |
//   |  ...             |
//
// Parts of the code cannot GC, part of the code can GC.
static void GenerateDeoptimizationSequence(Assembler* assembler,
                                           bool preserve_rax) {
  __ EnterFrame(0);
  // The code in this frame may not cause GC. kDeoptimizeCopyFrameRuntimeEntry
  // and kDeoptimizeFillFrameRuntimeEntry are leaf runtime calls.
  const intptr_t saved_rax_offset_from_ebp = -(kNumberOfCpuRegisters - RAX);
  // Result in EAX is preserved as part of pushing all registers below.

  // Push registers in their enumeration order: lowest register number at
  // lowest address.
  for (intptr_t i = kNumberOfCpuRegisters - 1; i >= 0; i--) {
    __ pushq(static_cast<Register>(i));
  }
  __ subq(RSP, Immediate(kNumberOfXmmRegisters * kFpuRegisterSize));
  intptr_t offset = 0;
  for (intptr_t reg_idx = 0; reg_idx < kNumberOfXmmRegisters; ++reg_idx) {
    XmmRegister xmm_reg = static_cast<XmmRegister>(reg_idx);
    __ movups(Address(RSP, offset), xmm_reg);
    offset += kFpuRegisterSize;
  }

  __ movq(RDI, RSP);  // Pass address of saved registers block.
  __ ReserveAlignedFrameSpace(0);
  __ CallRuntime(kDeoptimizeCopyFrameRuntimeEntry);
  // Result (RAX) is stack-size (FP - SP) in bytes, incl. the return address.

  if (preserve_rax) {
    // Restore result into RBX temporarily.
    __ movq(RBX, Address(RBP, saved_rax_offset_from_ebp * kWordSize));
  }

  __ LeaveFrame();
  __ popq(RCX);   // Preserve return address.
  __ movq(RSP, RBP);
  __ subq(RSP, RAX);
  __ movq(Address(RSP, 0), RCX);

  __ EnterFrame(0);
  __ movq(RCX, RSP);  // Get last FP address.
  if (preserve_rax) {
    __ pushq(RBX);  // Preserve result.
  }
  __ ReserveAlignedFrameSpace(0);
  __ movq(RDI, RCX);  // Set up argument 1 last_fp.
  __ CallRuntime(kDeoptimizeFillFrameRuntimeEntry);
  // Result (RAX) is our FP.
  if (preserve_rax) {
    // Restore result into RBX.
    __ movq(RBX, Address(RBP, -1 * kWordSize));
  }
  // Code above cannot cause GC.
  __ LeaveFrame();
  __ movq(RBP, RAX);

  // Frame is fully rewritten at this point and it is safe to perform a GC.
  // Materialize any objects that were deferred by FillFrame because they
  // require allocation.
  __ EnterStubFrame();
  if (preserve_rax) {
    __ pushq(RBX);  // Preserve result, it will be GC-d here.
  }
  __ pushq(Immediate(Smi::RawValue(0)));  // Space for the result.
  __ CallRuntime(kDeoptimizeMaterializeRuntimeEntry);
  // Result tells stub how many bytes to remove from the expression stack
  // of the bottom-most frame. They were used as materialization arguments.
  __ popq(RBX);
  __ SmiUntag(RBX);
  if (preserve_rax) {
    __ popq(RAX);  // Restore result.
  }
  __ LeaveFrame();

  __ popq(RCX);  // Pop return address.
  __ addq(RSP, RBX);  // Remove materialization arguments.
  __ pushq(RCX);  // Push return address.
  __ ret();
}


// TOS: return address + call-instruction-size (5 bytes).
// RAX: result, must be preserved
void StubCode::GenerateDeoptimizeLazyStub(Assembler* assembler) {
  // Correct return address to point just after the call that is being
  // deoptimized.
  __ popq(RBX);
  __ subq(RBX, Immediate(ShortCallPattern::InstructionLength()));
  __ pushq(RBX);
  GenerateDeoptimizationSequence(assembler, true);  // Preserve RAX.
}


void StubCode::GenerateDeoptimizeStub(Assembler* assembler) {
  GenerateDeoptimizationSequence(assembler, false);  // Don't preserve RAX.
}


void StubCode::GenerateMegamorphicMissStub(Assembler* assembler) {
  __ EnterStubFrame();
  // Load the receiver into RAX.  The argument count in the arguments
  // descriptor in R10 is a smi.
  __ movq(RAX, FieldAddress(R10, ArgumentsDescriptor::count_offset()));
  // Two words (saved fp, stub's pc marker) in the stack above the return
  // address.
  __ movq(RAX, Address(RSP, RAX, TIMES_4, 2 * kWordSize));
  // Preserve IC data and arguments descriptor.
  __ pushq(RBX);
  __ pushq(R10);

  const Immediate& raw_null =
      Immediate(reinterpret_cast<intptr_t>(Instructions::null()));
  __ pushq(raw_null);  // Space for the result of the runtime call.
  __ pushq(RAX);  // Receiver.
  __ pushq(RBX);  // IC data.
  __ pushq(R10);  // Arguments descriptor.
  __ CallRuntime(kMegamorphicCacheMissHandlerRuntimeEntry);
  // Discard arguments.
  __ popq(RAX);
  __ popq(RAX);
  __ popq(RAX);
  __ popq(RAX);  // Return value from the runtime call (instructions).
  __ popq(R10);  // Restore arguments descriptor.
  __ popq(RBX);  // Restore IC data.
  __ LeaveFrame();

  Label lookup;
  __ cmpq(RAX, raw_null);
  __ j(EQUAL, &lookup, Assembler::kNearJump);
  __ addq(RAX, Immediate(Instructions::HeaderSize() - kHeapObjectTag));
  __ jmp(RAX);

  __ Bind(&lookup);
  __ jmp(&StubCode::InstanceFunctionLookupLabel());
}


// Called for inline allocation of arrays.
// Input parameters:
//   R10 : Array length as Smi.
//   RBX : array element type (either NULL or an instantiated type).
// NOTE: R10 cannot be clobbered here as the caller relies on it being saved.
// The newly allocated object is returned in RAX.
void StubCode::GenerateAllocateArrayStub(Assembler* assembler) {
  Label slow_case;
  const Immediate& raw_null =
      Immediate(reinterpret_cast<intptr_t>(Object::null()));

  if (FLAG_inline_alloc) {
    // Compute the size to be allocated, it is based on the array length
    // and is computed as:
    // RoundedAllocationSize((array_length * kwordSize) + sizeof(RawArray)).
    // Assert that length is a Smi.
    __ testq(R10, Immediate(kSmiTagMask));
    if (FLAG_use_slow_path) {
      __ jmp(&slow_case);
    } else {
      __ j(NOT_ZERO, &slow_case);
    }
    __ movq(R13, FieldAddress(CTX, Context::isolate_offset()));
    __ movq(R13, Address(R13, Isolate::heap_offset()));
    __ movq(R13, Address(R13, Heap::new_space_offset()));

    // Calculate and align allocation size.
    // Load new object start and calculate next object start.
    // RBX: array element type.
    // R10: Array length as Smi.
    // R13: Points to new space object.
    __ movq(RAX, Address(R13, Scavenger::top_offset()));
    intptr_t fixed_size = sizeof(RawArray) + kObjectAlignment - 1;
    __ leaq(R12, Address(R10, TIMES_4, fixed_size));  // R10 is Smi.
    ASSERT(kSmiTagShift == 1);
    __ andq(R12, Immediate(-kObjectAlignment));
    __ leaq(R12, Address(RAX, R12, TIMES_1, 0));

    // Check if the allocation fits into the remaining space.
    // RAX: potential new object start.
    // R12: potential next object start.
    // RBX: array element type.
    // R10: Array length as Smi.
    // R13: Points to new space object.
    __ cmpq(R12, Address(R13, Scavenger::end_offset()));
    __ j(ABOVE_EQUAL, &slow_case);

    // Successfully allocated the object(s), now update top to point to
    // next object start and initialize the object.
    // RAX: potential new object start.
    // R12: potential next object start.
    // R13: Points to new space object.
    __ movq(Address(R13, Scavenger::top_offset()), R12);
    __ addq(RAX, Immediate(kHeapObjectTag));

    // RAX: new object start as a tagged pointer.
    // R12: new object end address.
    // RBX: array element type.
    // R10: Array length as Smi.

    // Store the type argument field.
    __ StoreIntoObjectNoBarrier(
        RAX, FieldAddress(RAX, Array::type_arguments_offset()), RBX);

    // Set the length field.
    __ StoreIntoObjectNoBarrier(
        RAX, FieldAddress(RAX, Array::length_offset()), R10);

    // Calculate the size tag.
    // RAX: new object start as a tagged pointer.
    // R12: new object end address.
    // R10: Array length as Smi.
    {
      Label size_tag_overflow, done;
      __ leaq(RBX, Address(R10, TIMES_4, fixed_size));  // R10 is Smi.
      ASSERT(kSmiTagShift == 1);
      __ andq(RBX, Immediate(-kObjectAlignment));
      __ cmpq(RBX, Immediate(RawObject::SizeTag::kMaxSizeTag));
      __ j(ABOVE, &size_tag_overflow, Assembler::kNearJump);
      __ shlq(RBX, Immediate(RawObject::kSizeTagBit - kObjectAlignmentLog2));
      __ jmp(&done);

      __ Bind(&size_tag_overflow);
      __ movq(RBX, Immediate(0));
      __ Bind(&done);

      // Get the class index and insert it into the tags.
      __ orq(RBX, Immediate(RawObject::ClassIdTag::encode(kArrayCid)));
      __ movq(FieldAddress(RAX, Array::tags_offset()), RBX);
    }

    // Initialize all array elements to raw_null.
    // RAX: new object start as a tagged pointer.
    // R12: new object end address.
    // R10: Array length as Smi.
    __ leaq(RBX, FieldAddress(RAX, Array::data_offset()));
    // RBX: iterator which initially points to the start of the variable
    // data area to be initialized.
    Label done;
    Label init_loop;
    __ Bind(&init_loop);
    __ cmpq(RBX, R12);
    __ j(ABOVE_EQUAL, &done, Assembler::kNearJump);
    // TODO(cshapiro): StoreIntoObjectNoBarrier
    __ movq(Address(RBX, 0), raw_null);
    __ addq(RBX, Immediate(kWordSize));
    __ jmp(&init_loop, Assembler::kNearJump);
    __ Bind(&done);

    // Done allocating and initializing the array.
    // RAX: new object.
    // R10: Array length as Smi (preserved for the caller.)
    __ ret();
  }

  // Unable to allocate the array using the fast inline code, just call
  // into the runtime.
  __ Bind(&slow_case);
  // Create a stub frame as we are pushing some objects on the stack before
  // calling into the runtime.
  __ EnterStubFrame();
  __ pushq(raw_null);  // Setup space on stack for return value.
  __ pushq(R10);  // Array length as Smi.
  __ pushq(RBX);  // Element type.
  __ CallRuntime(kAllocateArrayRuntimeEntry);
  __ popq(RAX);  // Pop element type argument.
  __ popq(R10);  // Pop array length argument.
  __ popq(RAX);  // Pop return value from return slot.
  __ LeaveFrame();
  __ ret();
}


// Input parameters:
//   R10: Arguments descriptor array.
// Note: The closure object is the first argument to the function being
//       called, the stub accesses the closure from this location directly
//       when trying to resolve the call.
void StubCode::GenerateCallClosureFunctionStub(Assembler* assembler) {
  const Immediate& raw_null =
      Immediate(reinterpret_cast<intptr_t>(Object::null()));

  // Load num_args.
  __ movq(RAX, FieldAddress(R10, ArgumentsDescriptor::count_offset()));
  // Load closure object in R13.
  __ movq(R13, Address(RSP, RAX, TIMES_4, 0));  // RAX is a Smi.

  // Verify that R13 is a closure by checking its class.
  Label not_closure;
  __ cmpq(R13, raw_null);
  // Not a closure, but null object.
  __ j(EQUAL, &not_closure);
  __ testq(R13, Immediate(kSmiTagMask));
  __ j(ZERO, &not_closure);  // Not a closure, but a smi.
  // Verify that the class of the object is a closure class by checking that
  // class.signature_function() is not null.
  __ LoadClass(RAX, R13);
  __ movq(RAX, FieldAddress(RAX, Class::signature_function_offset()));
  __ cmpq(RAX, raw_null);
  // Actual class is not a closure class.
  __ j(EQUAL, &not_closure, Assembler::kNearJump);

  // RAX is just the signature function. Load the actual closure function.
  __ movq(RBX, FieldAddress(R13, Closure::function_offset()));

  // Load closure context in CTX; note that CTX has already been preserved.
  __ movq(CTX, FieldAddress(R13, Closure::context_offset()));

  // Load closure function code in RAX.
  __ movq(RAX, FieldAddress(RBX, Function::code_offset()));
  __ cmpq(RAX, raw_null);
  Label function_compiled;
  __ j(NOT_EQUAL, &function_compiled, Assembler::kNearJump);

  // Create a stub frame as we are pushing some objects on the stack before
  // calling into the runtime.
  __ EnterStubFrame();

  __ pushq(R10);  // Preserve arguments descriptor array.
  __ pushq(RBX);  // Preserve read-only function object argument.
  __ CallRuntime(kCompileFunctionRuntimeEntry);
  __ popq(RBX);  // Restore read-only function object argument in RBX.
  __ popq(R10);  // Restore arguments descriptor array.
  // Restore RAX.
  __ movq(RAX, FieldAddress(RBX, Function::code_offset()));

  // Remove the stub frame as we are about to jump to the closure function.
  __ LeaveFrame();

  __ Bind(&function_compiled);
  // RAX: Code.
  // RBX: Function.
  // R10: Arguments descriptor array.

  __ movq(RBX, FieldAddress(RAX, Code::instructions_offset()));
  __ addq(RBX, Immediate(Instructions::HeaderSize() - kHeapObjectTag));
  __ jmp(RBX);

  __ Bind(&not_closure);
  // Call runtime to attempt to resolve and invoke a call method on a
  // non-closure object, passing the non-closure object and its arguments array,
  // returning here.
  // If no call method exists, throw a NoSuchMethodError.
  // R13: non-closure object.
  // R10: arguments descriptor array.

  // Create a stub frame as we are pushing some objects on the stack before
  // calling into the runtime.
  __ EnterStubFrame();

  __ pushq(raw_null);  // Setup space on stack for result from call.
  __ pushq(R10);  // Arguments descriptor.
  // Load smi-tagged arguments array length, including the non-closure.
  __ movq(R10, FieldAddress(R10, ArgumentsDescriptor::count_offset()));
  // See stack layout below explaining "wordSize * 5" offset.
  PushArgumentsArray(assembler, (kWordSize * 5));

  // Stack:
  // TOS + 0: Argument array.
  // TOS + 1: Arguments descriptor array.
  // TOS + 2: Place for result from the call.
  // TOS + 3: PC marker => RawInstruction object.
  // TOS + 4: Saved RBP of previous frame. <== RBP
  // TOS + 5: Dart code return address
  // TOS + 6: Last argument of caller.
  // ....
  __ CallRuntime(kInvokeNonClosureRuntimeEntry);
  // Remove arguments.
  __ popq(RAX);
  __ popq(RAX);
  __ popq(RAX);  // Get result into RAX.

  // Remove the stub frame as we are about to return.
  __ LeaveFrame();
  __ ret();
}


// Called when invoking Dart code from C++ (VM code).
// Input parameters:
//   RSP : points to return address.
//   RDI : entrypoint of the Dart function to call.
//   RSI : arguments descriptor array.
//   RDX : arguments array.
//   RCX : new context containing the current isolate pointer.
void StubCode::GenerateInvokeDartCodeStub(Assembler* assembler) {
  // Save frame pointer coming in.
  __ EnterFrame(0);

  // Save arguments descriptor array and new context.
  const intptr_t kArgumentsDescOffset = -1 * kWordSize;
  __ pushq(RSI);
  const intptr_t kNewContextOffset = -2 * kWordSize;
  __ pushq(RCX);

  // Save C++ ABI callee-saved registers.
  __ pushq(RBX);
  __ pushq(R12);
  __ pushq(R13);
  __ pushq(R14);
  __ pushq(R15);

  // The new Context structure contains a pointer to the current Isolate
  // structure. Cache the Context pointer in the CTX register so that it is
  // available in generated code and calls to Isolate::Current() need not be
  // done. The assumption is that this register will never be clobbered by
  // compiled or runtime stub code.

  // Cache the new Context pointer into CTX while executing Dart code.
  __ movq(CTX, Address(RCX, VMHandles::kOffsetOfRawPtrInHandle));

  // Load Isolate pointer from Context structure into R8.
  __ movq(R8, FieldAddress(CTX, Context::isolate_offset()));

  // Save the top exit frame info. Use RAX as a temporary register.
  // StackFrameIterator reads the top exit frame info saved in this frame.
  // The constant kExitLinkSlotFromEntryFp must be kept in sync with the
  // code below.
  ASSERT(kExitLinkSlotFromEntryFp == -8);
  __ movq(RAX, Address(R8, Isolate::top_exit_frame_info_offset()));
  __ pushq(RAX);
  __ movq(Address(R8, Isolate::top_exit_frame_info_offset()), Immediate(0));

  // Save the old Context pointer. Use RAX as a temporary register.
  // Note that VisitObjectPointers will find this saved Context pointer during
  // GC marking, since it traverses any information between SP and
  // FP - kExitLinkSlotFromEntryFp * kWordSize.
  // EntryFrame::SavedContext reads the context saved in this frame.
  // The constant kSavedContextSlotFromEntryFp must be kept in sync with
  // the code below.
  ASSERT(kSavedContextSlotFromEntryFp == -9);
  __ movq(RAX, Address(R8, Isolate::top_context_offset()));
  __ pushq(RAX);

  // Load arguments descriptor array into R10, which is passed to Dart code.
  __ movq(R10, Address(RSI, VMHandles::kOffsetOfRawPtrInHandle));

  // Load number of arguments into RBX.
  __ movq(RBX, FieldAddress(R10, ArgumentsDescriptor::count_offset()));
  __ SmiUntag(RBX);

  // Compute address of 'arguments array' data area into RDX.
  __ movq(RDX, Address(RDX, VMHandles::kOffsetOfRawPtrInHandle));
  __ leaq(RDX, FieldAddress(RDX, Array::data_offset()));

  // Set up arguments for the Dart call.
  Label push_arguments;
  Label done_push_arguments;
  __ testq(RBX, RBX);  // check if there are arguments.
  __ j(ZERO, &done_push_arguments, Assembler::kNearJump);
  __ movq(RAX, Immediate(0));
  __ Bind(&push_arguments);
  __ movq(RCX, Address(RDX, RAX, TIMES_8, 0));  // RDX is start of arguments.
  __ pushq(RCX);
  __ incq(RAX);
  __ cmpq(RAX, RBX);
  __ j(LESS, &push_arguments, Assembler::kNearJump);
  __ Bind(&done_push_arguments);

  // Call the Dart code entrypoint.
  __ call(RDI);  // R10 is the arguments descriptor array.

  // Read the saved new Context pointer.
  __ movq(CTX, Address(RBP, kNewContextOffset));
  __ movq(CTX, Address(CTX, VMHandles::kOffsetOfRawPtrInHandle));

  // Read the saved arguments descriptor array to obtain the number of passed
  // arguments.
  __ movq(RSI, Address(RBP, kArgumentsDescOffset));
  __ movq(R10, Address(RSI, VMHandles::kOffsetOfRawPtrInHandle));
  __ movq(RDX, FieldAddress(R10, ArgumentsDescriptor::count_offset()));
  // Get rid of arguments pushed on the stack.
  __ leaq(RSP, Address(RSP, RDX, TIMES_4, 0));  // RDX is a Smi.

  // Load Isolate pointer from Context structure into CTX. Drop Context.
  __ movq(CTX, FieldAddress(CTX, Context::isolate_offset()));

  // Restore the saved Context pointer into the Isolate structure.
  // Uses RCX as a temporary register for this.
  __ popq(RCX);
  __ movq(Address(CTX, Isolate::top_context_offset()), RCX);

  // Restore the saved top exit frame info back into the Isolate structure.
  // Uses RDX as a temporary register for this.
  __ popq(RDX);
  __ movq(Address(CTX, Isolate::top_exit_frame_info_offset()), RDX);

  // Restore C++ ABI callee-saved registers.
  __ popq(R15);
  __ popq(R14);
  __ popq(R13);
  __ popq(R12);
  __ popq(RBX);

  // Restore the frame pointer.
  __ LeaveFrame();

  __ ret();
}


// Called for inline allocation of contexts.
// Input:
// R10: number of context variables.
// Output:
// RAX: new allocated RawContext object.
void StubCode::GenerateAllocateContextStub(Assembler* assembler) {
  const Immediate& raw_null =
      Immediate(reinterpret_cast<intptr_t>(Object::null()));
  if (FLAG_inline_alloc) {
    const Class& context_class = Class::ZoneHandle(Object::context_class());
    Label slow_case;
    Heap* heap = Isolate::Current()->heap();
    // First compute the rounded instance size.
    // R10: number of context variables.
    intptr_t fixed_size = (sizeof(RawContext) + kObjectAlignment - 1);
    __ leaq(R13, Address(R10, TIMES_8, fixed_size));
    __ andq(R13, Immediate(-kObjectAlignment));

    // Now allocate the object.
    // R10: number of context variables.
    __ movq(RAX, Immediate(heap->TopAddress()));
    __ movq(RAX, Address(RAX, 0));
    __ addq(R13, RAX);
    // Check if the allocation fits into the remaining space.
    // RAX: potential new object.
    // R13: potential next object start.
    // R10: number of context variables.
    __ movq(RDI, Immediate(heap->EndAddress()));
    __ cmpq(R13, Address(RDI, 0));
    if (FLAG_use_slow_path) {
      __ jmp(&slow_case);
    } else {
      __ j(ABOVE_EQUAL, &slow_case);
    }

    // Successfully allocated the object, now update top to point to
    // next object start and initialize the object.
    // RAX: new object.
    // R13: next object start.
    // R10: number of context variables.
    __ movq(RDI, Immediate(heap->TopAddress()));
    __ movq(Address(RDI, 0), R13);
    __ addq(RAX, Immediate(kHeapObjectTag));

    // Calculate the size tag.
    // RAX: new object.
    // R10: number of context variables.
    {
      Label size_tag_overflow, done;
      __ leaq(R13, Address(R10, TIMES_8, fixed_size));
      __ andq(R13, Immediate(-kObjectAlignment));
      __ cmpq(R13, Immediate(RawObject::SizeTag::kMaxSizeTag));
      __ j(ABOVE, &size_tag_overflow, Assembler::kNearJump);
      __ shlq(R13, Immediate(RawObject::kSizeTagBit - kObjectAlignmentLog2));
      __ jmp(&done);

      __ Bind(&size_tag_overflow);
      // Set overflow size tag value.
      __ movq(R13, Immediate(0));

      __ Bind(&done);
      // RAX: new object.
      // R10: number of context variables.
      // R13: size and bit tags.
      __ orq(R13,
             Immediate(RawObject::ClassIdTag::encode(context_class.id())));
      __ movq(FieldAddress(RAX, Context::tags_offset()), R13);  // Tags.
    }

    // Setup up number of context variables field.
    // RAX: new object.
    // R10: number of context variables as integer value (not object).
    __ movq(FieldAddress(RAX, Context::num_variables_offset()), R10);

    // Setup isolate field.
    // Load Isolate pointer from Context structure into R13.
    // RAX: new object.
    // R10: number of context variables.
    __ movq(R13, FieldAddress(CTX, Context::isolate_offset()));
    // R13: Isolate, not an object.
    __ movq(FieldAddress(RAX, Context::isolate_offset()), R13);

    const Immediate& raw_null =
        Immediate(reinterpret_cast<intptr_t>(Object::null()));
    // Setup the parent field.
    // RAX: new object.
    // R10: number of context variables.
    __ movq(FieldAddress(RAX, Context::parent_offset()), raw_null);

    // Initialize the context variables.
    // RAX: new object.
    // R10: number of context variables.
    {
      Label loop, entry;
      __ leaq(R13, FieldAddress(RAX, Context::variable_offset(0)));

      __ jmp(&entry, Assembler::kNearJump);
      __ Bind(&loop);
      __ decq(R10);
      __ movq(Address(R13, R10, TIMES_8, 0), raw_null);
      __ Bind(&entry);
      __ cmpq(R10, Immediate(0));
      __ j(NOT_EQUAL, &loop, Assembler::kNearJump);
    }

    // Done allocating and initializing the context.
    // RAX: new object.
    __ ret();

    __ Bind(&slow_case);
  }
  // Create a stub frame.
  __ EnterStubFrame();
  __ pushq(raw_null);  // Setup space on stack for the return value.
  __ SmiTag(R10);
  __ pushq(R10);  // Push number of context variables.
  __ CallRuntime(kAllocateContextRuntimeEntry);  // Allocate context.
  __ popq(RAX);  // Pop number of context variables argument.
  __ popq(RAX);  // Pop the new context object.
  // RAX: new object
  // Restore the frame pointer.
  __ LeaveFrame();
  __ ret();
}


DECLARE_LEAF_RUNTIME_ENTRY(void, StoreBufferBlockProcess, Isolate* isolate);

// Helper stub to implement Assembler::StoreIntoObject.
// Input parameters:
//   RAX: Address being stored
void StubCode::GenerateUpdateStoreBufferStub(Assembler* assembler) {
  // Save registers being destroyed.
  __ pushq(RDX);
  __ pushq(RCX);

  Label add_to_buffer;
  // Check whether this object has already been remembered. Skip adding to the
  // store buffer if the object is in the store buffer already.
  // Spilled: RDX, RCX
  // RAX: Address being stored
  __ movq(RCX, FieldAddress(RAX, Object::tags_offset()));
  __ testq(RCX, Immediate(1 << RawObject::kRememberedBit));
  __ j(EQUAL, &add_to_buffer, Assembler::kNearJump);
  __ popq(RCX);
  __ popq(RDX);
  __ ret();

  __ Bind(&add_to_buffer);
  __ orq(RCX, Immediate(1 << RawObject::kRememberedBit));
  __ movq(FieldAddress(RAX, Object::tags_offset()), RCX);

  // Load the isolate out of the context.
  // RAX: Address being stored
  __ movq(RDX, FieldAddress(CTX, Context::isolate_offset()));

  // Load the StoreBuffer block out of the isolate. Then load top_ out of the
  // StoreBufferBlock and add the address to the pointers_.
  // RAX: Address being stored
  // RDX: Isolate
  __ movq(RDX, Address(RDX, Isolate::store_buffer_offset()));
  __ movl(RCX, Address(RDX, StoreBufferBlock::top_offset()));
  __ movq(Address(RDX, RCX, TIMES_8, StoreBufferBlock::pointers_offset()), RAX);

  // Increment top_ and check for overflow.
  // RCX: top_
  // RDX: StoreBufferBlock
  Label L;
  __ incq(RCX);
  __ movl(Address(RDX, StoreBufferBlock::top_offset()), RCX);
  __ cmpl(RCX, Immediate(StoreBufferBlock::kSize));
  // Restore values.
  __ popq(RCX);
  __ popq(RDX);
  __ j(EQUAL, &L, Assembler::kNearJump);
  __ ret();

  // Handle overflow: Call the runtime leaf function.
  __ Bind(&L);
  // Setup frame, push callee-saved registers.
  __ EnterCallRuntimeFrame(0);
  __ movq(RDI, FieldAddress(CTX, Context::isolate_offset()));
  __ CallRuntime(kStoreBufferBlockProcessRuntimeEntry);
  __ LeaveCallRuntimeFrame();
  __ ret();
}


// Called for inline allocation of objects.
// Input parameters:
//   RSP + 16 : type arguments object (only if class is parameterized).
//   RSP + 8 : type arguments of instantiator (only if class is parameterized).
//   RSP : points to return address.
void StubCode::GenerateAllocationStubForClass(Assembler* assembler,
                                              const Class& cls) {
  const intptr_t kObjectTypeArgumentsOffset = 2 * kWordSize;
  const intptr_t kInstantiatorTypeArgumentsOffset = 1 * kWordSize;
  const Immediate& raw_null =
      Immediate(reinterpret_cast<intptr_t>(Object::null()));
  // The generated code is different if the class is parameterized.
  const bool is_cls_parameterized =
      cls.type_arguments_field_offset() != Class::kNoTypeArguments;
  // kInlineInstanceSize is a constant used as a threshold for determining
  // when the object initialization should be done as a loop or as
  // straight line code.
  const int kInlineInstanceSize = 12;  // In words.
  const intptr_t instance_size = cls.instance_size();
  ASSERT(instance_size > 0);
  const intptr_t type_args_size = InstantiatedTypeArguments::InstanceSize();
  if (FLAG_inline_alloc &&
      Heap::IsAllocatableInNewSpace(instance_size + type_args_size)) {
    Label slow_case;
    Heap* heap = Isolate::Current()->heap();
    __ movq(RAX, Immediate(heap->TopAddress()));
    __ movq(RAX, Address(RAX, 0));
    __ leaq(RBX, Address(RAX, instance_size));
    if (is_cls_parameterized) {
      __ movq(RCX, RBX);
      // A new InstantiatedTypeArguments object only needs to be allocated if
      // the instantiator is provided (not kNoInstantiator, but may be null).
      Label no_instantiator;
      __ cmpq(Address(RSP, kInstantiatorTypeArgumentsOffset),
              Immediate(Smi::RawValue(StubCode::kNoInstantiator)));
      __ j(EQUAL, &no_instantiator, Assembler::kNearJump);
      __ addq(RBX, Immediate(type_args_size));
      __ Bind(&no_instantiator);
      // RCX: potential new object end and, if RCX != RBX, potential new
      // InstantiatedTypeArguments object start.
    }
    // Check if the allocation fits into the remaining space.
    // RAX: potential new object start.
    // RBX: potential next object start.
    __ movq(RDI, Immediate(heap->EndAddress()));
    __ cmpq(RBX, Address(RDI, 0));
    if (FLAG_use_slow_path) {
      __ jmp(&slow_case);
    } else {
      __ j(ABOVE_EQUAL, &slow_case);
    }

    // Successfully allocated the object(s), now update top to point to
    // next object start and initialize the object.
    __ movq(RDI, Immediate(heap->TopAddress()));
    __ movq(Address(RDI, 0), RBX);

    if (is_cls_parameterized) {
      // Initialize the type arguments field in the object.
      // RAX: new object start.
      // RCX: potential new object end and, if RCX != RBX, potential new
      // InstantiatedTypeArguments object start.
      // RBX: next object start.
      Label type_arguments_ready;
      __ movq(RDI, Address(RSP, kObjectTypeArgumentsOffset));
      __ cmpq(RCX, RBX);
      __ j(EQUAL, &type_arguments_ready, Assembler::kNearJump);
      // Initialize InstantiatedTypeArguments object at RCX.
      __ movq(Address(RCX,
          InstantiatedTypeArguments::uninstantiated_type_arguments_offset()),
              RDI);
      __ movq(RDX, Address(RSP, kInstantiatorTypeArgumentsOffset));
      __ movq(Address(RCX,
          InstantiatedTypeArguments::instantiator_type_arguments_offset()),
              RDX);
      const Class& ita_cls =
          Class::ZoneHandle(Object::instantiated_type_arguments_class());
      // Set the tags.
      uword tags = 0;
      tags = RawObject::SizeTag::update(type_args_size, tags);
      tags = RawObject::ClassIdTag::update(ita_cls.id(), tags);
      __ movq(Address(RCX, Instance::tags_offset()), Immediate(tags));
      // Set the new InstantiatedTypeArguments object (RCX) as the type
      // arguments (RDI) of the new object (RAX).
      __ movq(RDI, RCX);
      __ addq(RDI, Immediate(kHeapObjectTag));
      // Set RBX to new object end.
      __ movq(RBX, RCX);
      __ Bind(&type_arguments_ready);
      // RAX: new object.
      // RDI: new object type arguments.
    }

    // RAX: new object start.
    // RBX: next object start.
    // RDI: new object type arguments (if is_cls_parameterized).
    // Set the tags.
    uword tags = 0;
    tags = RawObject::SizeTag::update(instance_size, tags);
    ASSERT(cls.id() != kIllegalCid);
    tags = RawObject::ClassIdTag::update(cls.id(), tags);
    __ movq(Address(RAX, Instance::tags_offset()), Immediate(tags));

    // Initialize the remaining words of the object.
    const Immediate& raw_null =
        Immediate(reinterpret_cast<intptr_t>(Object::null()));

    // RAX: new object start.
    // RBX: next object start.
    // RDI: new object type arguments (if is_cls_parameterized).
    // First try inlining the initialization without a loop.
    if (instance_size < (kInlineInstanceSize * kWordSize)) {
      // Check if the object contains any non-header fields.
      // Small objects are initialized using a consecutive set of writes.
      for (intptr_t current_offset = sizeof(RawObject);
           current_offset < instance_size;
           current_offset += kWordSize) {
        __ movq(Address(RAX, current_offset), raw_null);
      }
    } else {
      __ leaq(RCX, Address(RAX, sizeof(RawObject)));
      // Loop until the whole object is initialized.
      // RAX: new object.
      // RBX: next object start.
      // RCX: next word to be initialized.
      // RDI: new object type arguments (if is_cls_parameterized).
      Label init_loop;
      Label done;
      __ Bind(&init_loop);
      __ cmpq(RCX, RBX);
      __ j(ABOVE_EQUAL, &done, Assembler::kNearJump);
      __ movq(Address(RCX, 0), raw_null);
      __ addq(RCX, Immediate(kWordSize));
      __ jmp(&init_loop, Assembler::kNearJump);
      __ Bind(&done);
    }
    if (is_cls_parameterized) {
      // RDI: new object type arguments.
      // Set the type arguments in the new object.
      __ movq(Address(RAX, cls.type_arguments_field_offset()), RDI);
    }
    // Done allocating and initializing the instance.
    // RAX: new object.
    __ addq(RAX, Immediate(kHeapObjectTag));
    __ ret();

    __ Bind(&slow_case);
  }
  if (is_cls_parameterized) {
    __ movq(RAX, Address(RSP, kObjectTypeArgumentsOffset));
    __ movq(RDX, Address(RSP, kInstantiatorTypeArgumentsOffset));
  }
  // Create a stub frame.
  __ EnterStubFrame();
  __ pushq(raw_null);  // Setup space on stack for return value.
  __ PushObject(cls);  // Push class of object to be allocated.
  if (is_cls_parameterized) {
    __ pushq(RAX);  // Push type arguments of object to be allocated.
    __ pushq(RDX);  // Push type arguments of instantiator.
  } else {
    __ pushq(raw_null);  // Push null type arguments.
    __ pushq(Immediate(Smi::RawValue(StubCode::kNoInstantiator)));
  }
  __ CallRuntime(kAllocateObjectRuntimeEntry);  // Allocate object.
  __ popq(RAX);  // Pop argument (instantiator).
  __ popq(RAX);  // Pop argument (type arguments of object).
  __ popq(RAX);  // Pop argument (class of object).
  __ popq(RAX);  // Pop result (newly allocated object).
  // RAX: new object
  // Restore the frame pointer.
  __ LeaveFrame();
  __ ret();
}


// Called for inline allocation of closures.
// Input parameters:
//   RSP + 16 : receiver (null if not an implicit instance closure).
//   RSP + 8 : type arguments object (null if class is not parameterized).
//   RSP : points to return address.
void StubCode::GenerateAllocationStubForClosure(Assembler* assembler,
                                                const Function& func) {
  const Immediate& raw_null =
      Immediate(reinterpret_cast<intptr_t>(Object::null()));
  ASSERT(func.IsClosureFunction());
  const bool is_implicit_static_closure =
      func.IsImplicitStaticClosureFunction();
  const bool is_implicit_instance_closure =
      func.IsImplicitInstanceClosureFunction();
  const Class& cls = Class::ZoneHandle(func.signature_class());
  const bool has_type_arguments = cls.HasTypeArguments();
  const intptr_t kTypeArgumentsOffset = 1 * kWordSize;
  const intptr_t kReceiverOffset = 2 * kWordSize;
  const intptr_t closure_size = Closure::InstanceSize();
  const intptr_t context_size = Context::InstanceSize(1);  // Captured receiver.
  if (FLAG_inline_alloc &&
      Heap::IsAllocatableInNewSpace(closure_size + context_size)) {
    Label slow_case;
    Heap* heap = Isolate::Current()->heap();
    __ movq(RAX, Immediate(heap->TopAddress()));
    __ movq(RAX, Address(RAX, 0));
    __ leaq(R13, Address(RAX, closure_size));
    if (is_implicit_instance_closure) {
      __ movq(RBX, R13);  // RBX: new context address.
      __ addq(R13, Immediate(context_size));
    }
    // Check if the allocation fits into the remaining space.
    // RAX: potential new closure object.
    // RBX: potential new context object (only if is_implicit_closure).
    // R13: potential next object start.
    __ movq(RDI, Immediate(heap->EndAddress()));
    __ cmpq(R13, Address(RDI, 0));
    if (FLAG_use_slow_path) {
      __ jmp(&slow_case);
    } else {
      __ j(ABOVE_EQUAL, &slow_case);
    }

    // Successfully allocated the object, now update top to point to
    // next object start and initialize the object.
    __ movq(RDI, Immediate(heap->TopAddress()));
    __ movq(Address(RDI, 0), R13);

    // RAX: new closure object.
    // RBX: new context object (only if is_implicit_closure).
    // Set the tags.
    uword tags = 0;
    tags = RawObject::SizeTag::update(closure_size, tags);
    tags = RawObject::ClassIdTag::update(cls.id(), tags);
    __ movq(Address(RAX, Instance::tags_offset()), Immediate(tags));

    // Initialize the function field in the object.
    // RAX: new closure object.
    // RBX: new context object (only if is_implicit_closure).
    // R13: next object start.
    __ LoadObject(R10, func);  // Load function of closure to be allocated.
    __ movq(Address(RAX, Closure::function_offset()), R10);

    // Setup the context for this closure.
    if (is_implicit_static_closure) {
      ObjectStore* object_store = Isolate::Current()->object_store();
      ASSERT(object_store != NULL);
      const Context& empty_context =
          Context::ZoneHandle(object_store->empty_context());
      __ LoadObject(R10, empty_context);
      __ movq(Address(RAX, Closure::context_offset()), R10);
    } else if (is_implicit_instance_closure) {
      // Initialize the new context capturing the receiver.

      const Class& context_class = Class::ZoneHandle(Object::context_class());
      // Set the tags.
      uword tags = 0;
      tags = RawObject::SizeTag::update(context_size, tags);
      tags = RawObject::ClassIdTag::update(context_class.id(), tags);
      __ movq(Address(RBX, Context::tags_offset()), Immediate(tags));

      // Set number of variables field to 1 (for captured receiver).
      __ movq(Address(RBX, Context::num_variables_offset()), Immediate(1));

      // Set isolate field to isolate of current context.
      __ movq(R10, FieldAddress(CTX, Context::isolate_offset()));
      __ movq(Address(RBX, Context::isolate_offset()), R10);

      // Set the parent to null.
      __ movq(Address(RBX, Context::parent_offset()), raw_null);

      // Initialize the context variable to the receiver.
      __ movq(R10, Address(RSP, kReceiverOffset));
      __ movq(Address(RBX, Context::variable_offset(0)), R10);

      // Set the newly allocated context in the newly allocated closure.
      __ addq(RBX, Immediate(kHeapObjectTag));
      __ movq(Address(RAX, Closure::context_offset()), RBX);
    } else {
      __ movq(Address(RAX, Closure::context_offset()), CTX);
    }

    // Set the type arguments field in the newly allocated closure.
    __ movq(R10, Address(RSP, kTypeArgumentsOffset));
    __ movq(Address(RAX, Closure::type_arguments_offset()), R10);

    // Done allocating and initializing the instance.
    // RAX: new object.
    __ addq(RAX, Immediate(kHeapObjectTag));
    __ ret();

    __ Bind(&slow_case);
  }
  if (has_type_arguments) {
    __ movq(RCX, Address(RSP, kTypeArgumentsOffset));
  }
  if (is_implicit_instance_closure) {
    __ movq(RAX, Address(RSP, kReceiverOffset));
  }
  // Create the stub frame.
  __ EnterStubFrame();
  __ pushq(raw_null);  // Setup space on stack for the return value.
  __ PushObject(func);
  if (is_implicit_static_closure) {
    __ CallRuntime(kAllocateImplicitStaticClosureRuntimeEntry);
  } else {
    if (is_implicit_instance_closure) {
      __ pushq(RAX);  // Receiver.
    }
    if (has_type_arguments) {
      __ pushq(RCX);  // Push type arguments of closure to be allocated.
    } else {
      __ pushq(raw_null);  // Push null type arguments.
    }
    if (is_implicit_instance_closure) {
      __ CallRuntime(kAllocateImplicitInstanceClosureRuntimeEntry);
      __ popq(RAX);  // Pop type arguments.
      __ popq(RAX);  // Pop receiver.
    } else {
      ASSERT(func.IsNonImplicitClosureFunction());
      __ CallRuntime(kAllocateClosureRuntimeEntry);
      __ popq(RAX);  // Pop type arguments.
    }
  }
  __ popq(RAX);  // Pop the function object.
  __ popq(RAX);  // Pop the result.
  // RAX: New closure object.
  // Restore the calling frame.
  __ LeaveFrame();
  __ ret();
}


// Called for invoking noSuchMethod function from the entry code of a dart
// function after an error in passed named arguments is detected.
// Input parameters:
//   RBP - 8 : PC marker => RawInstruction object.
//   RBP : points to previous frame pointer.
//   RBP + 8 : points to return address.
//   RBP + 16 : address of last argument (arg n-1).
//   RBP + 16 + 8*(n-1) : address of first argument (arg 0).
//   RBX : ic-data.
//   R10 : arguments descriptor array.
void StubCode::GenerateCallNoSuchMethodFunctionStub(Assembler* assembler) {
  // The target function was not found, so invoke method
  // "dynamic noSuchMethod(Invocation invocation)".
  const Immediate& raw_null =
      Immediate(reinterpret_cast<intptr_t>(Object::null()));
  __ movq(R13, FieldAddress(R10, ArgumentsDescriptor::count_offset()));
  __ movq(RAX, Address(RBP, R13, TIMES_4, kWordSize));  // Get receiver.

  // Create a stub frame.
  __ EnterStubFrame();

  __ pushq(raw_null);  // Setup space on stack for result from noSuchMethod.
  __ pushq(RAX);  // Receiver.
  __ pushq(RBX);  // IC data array.
  __ pushq(R10);  // Arguments descriptor array.

  __ movq(R10, R13);  // Smi-tagged arguments array length.
  // See stack layout below explaining "wordSize * 10" offset.
  PushArgumentsArray(assembler, (kWordSize * 10));

  // Stack:
  // TOS + 0: Argument array.
  // TOS + 1: Arguments descriptor array.
  // TOS + 2: Ic-data array.
  // TOS + 3: Receiver.
  // TOS + 4: Place for result from noSuchMethod.
  // TOS + 5: PC marker => RawInstruction object.
  // TOS + 6: Saved RBP of previous frame. <== RBP
  // TOS + 7: Dart callee (or stub) code return address
  // TOS + 8: PC marker => RawInstruction object of dart caller frame.
  // TOS + 9: Saved RBP of dart caller frame.
  // TOS + 10: Dart caller code return address
  // TOS + 11: Last argument of caller.
  // ....
  __ CallRuntime(kInvokeNoSuchMethodFunctionRuntimeEntry);
  // Remove arguments.
  __ popq(RAX);
  __ popq(RAX);
  __ popq(RAX);
  __ popq(RAX);
  __ popq(RAX);  // Get result into RAX.

  // Remove the stub frame as we are about to return.
  __ LeaveFrame();
  __ ret();
}


void StubCode::GenerateOptimizedUsageCounterIncrement(Assembler* assembler) {
  Register argdesc_reg = R10;
  Register ic_reg = RBX;
  Register func_reg = RDI;
  if (FLAG_trace_optimized_ic_calls) {
    __ EnterStubFrame();
    __ pushq(func_reg);     // Preserve
    __ pushq(argdesc_reg);  // Preserve.
    __ pushq(ic_reg);       // Preserve.
    __ pushq(ic_reg);       // Argument.
    __ pushq(func_reg);     // Argument.
    __ CallRuntime(kTraceICCallRuntimeEntry);
    __ popq(RAX);          // Discard argument;
    __ popq(RAX);          // Discard argument;
    __ popq(ic_reg);       // Restore.
    __ popq(argdesc_reg);  // Restore.
    __ popq(func_reg);     // Restore.
    __ LeaveFrame();
  }
  Label is_hot;
  if (FlowGraphCompiler::CanOptimize()) {
    ASSERT(FLAG_optimization_counter_threshold > 1);
    __ cmpq(FieldAddress(func_reg, Function::usage_counter_offset()),
        Immediate(FLAG_optimization_counter_threshold));
    __ j(GREATER_EQUAL, &is_hot, Assembler::kNearJump);
    // As long as VM has no OSR do not optimize in the middle of the function
    // but only at exit so that we have collected all type feedback before
    // optimizing.
  }
  __ incq(FieldAddress(func_reg, Function::usage_counter_offset()));
  __ Bind(&is_hot);
}


// Loads function into 'temp_reg', preserves 'ic_reg'.
void StubCode::GenerateUsageCounterIncrement(Assembler* assembler,
                                             Register temp_reg) {
  Register ic_reg = RBX;
  Register func_reg = temp_reg;
  ASSERT(ic_reg != func_reg);
  __ movq(func_reg, FieldAddress(ic_reg, ICData::function_offset()));
  Label is_hot;
  if (FlowGraphCompiler::CanOptimize()) {
    ASSERT(FLAG_optimization_counter_threshold > 1);
    // The usage_counter is always less than FLAG_optimization_counter_threshold
    // except when the function gets optimized.
    __ cmpq(FieldAddress(func_reg, Function::usage_counter_offset()),
        Immediate(FLAG_optimization_counter_threshold));
    __ j(EQUAL, &is_hot, Assembler::kNearJump);
    // As long as VM has no OSR do not optimize in the middle of the function
    // but only at exit so that we have collected all type feedback before
    // optimizing.
  }
  __ incq(FieldAddress(func_reg, Function::usage_counter_offset()));
  __ Bind(&is_hot);
}

// Generate inline cache check for 'num_args'.
//  RBX: Inline cache data object.
//  R10: Arguments descriptor array.
//  TOS(0): return address
// Control flow:
// - If receiver is null -> jump to IC miss.
// - If receiver is Smi -> load Smi class.
// - If receiver is not-Smi -> load receiver's class.
// - Check if 'num_args' (including receiver) match any IC data group.
// - Match found -> jump to target.
// - Match not found -> jump to IC miss.
void StubCode::GenerateNArgsCheckInlineCacheStub(Assembler* assembler,
                                                 intptr_t num_args) {
  ASSERT(num_args > 0);
#if defined(DEBUG)
  { Label ok;
    // Check that the IC data array has NumberOfArgumentsChecked() == num_args.
    // 'num_args_tested' is stored as an untagged int.
    __ movq(RCX, FieldAddress(RBX, ICData::num_args_tested_offset()));
    __ cmpq(RCX, Immediate(num_args));
    __ j(EQUAL, &ok, Assembler::kNearJump);
    __ Stop("Incorrect stub for IC data");
    __ Bind(&ok);
  }
#endif  // DEBUG

  // Loop that checks if there is an IC data match.
  Label loop, update, test, found, get_class_id_as_smi;
  // RBX: IC data object (preserved).
  __ movq(R12, FieldAddress(RBX, ICData::ic_data_offset()));
  // R12: ic_data_array with check entries: classes and target functions.
  __ leaq(R12, FieldAddress(R12, Array::data_offset()));
  // R12: points directly to the first ic data array element.

  // Get the receiver's class ID (first read number of arguments from
  // arguments descriptor array and then access the receiver from the stack).
  __ movq(RAX, FieldAddress(R10, ArgumentsDescriptor::count_offset()));
  __ movq(RAX, Address(RSP, RAX, TIMES_4, 0));  // RAX (argument count) is Smi.
  __ call(&get_class_id_as_smi);
  // RAX: receiver's class ID as smi.
  __ movq(R13, Address(R12, 0));  // First class ID (Smi) to check.
  __ jmp(&test);

  __ Bind(&loop);
  for (int i = 0; i < num_args; i++) {
    if (i > 0) {
      // If not the first, load the next argument's class ID.
      __ movq(RAX, FieldAddress(R10, ArgumentsDescriptor::count_offset()));
      __ movq(RAX, Address(RSP, RAX, TIMES_4, - i * kWordSize));
      __ call(&get_class_id_as_smi);
      // RAX: next argument class ID (smi).
      __ movq(R13, Address(R12, i * kWordSize));
      // R13: next class ID to check (smi).
    }
    __ cmpq(RAX, R13);  // Class id match?
    if (i < (num_args - 1)) {
      __ j(NOT_EQUAL, &update);  // Continue.
    } else {
      // Last check, all checks before matched.
      __ j(EQUAL, &found);  // Break.
    }
  }
  __ Bind(&update);
  // Reload receiver class ID.  It has not been destroyed when num_args == 1.
  if (num_args > 1) {
    __ movq(RAX, FieldAddress(R10, ArgumentsDescriptor::count_offset()));
    __ movq(RAX, Address(RSP, RAX, TIMES_4, 0));
    __ call(&get_class_id_as_smi);
  }

  const intptr_t entry_size = ICData::TestEntryLengthFor(num_args) * kWordSize;
  __ addq(R12, Immediate(entry_size));  // Next entry.
  __ movq(R13, Address(R12, 0));  // Next class ID.

  __ Bind(&test);
  __ cmpq(R13, Immediate(Smi::RawValue(kIllegalCid)));  // Done?
  __ j(NOT_EQUAL, &loop, Assembler::kNearJump);

  // IC miss.
  const Immediate& raw_null =
      Immediate(reinterpret_cast<intptr_t>(Object::null()));
  // Compute address of arguments (first read number of arguments from
  // arguments descriptor array and then compute address on the stack).
  __ movq(RAX, FieldAddress(R10, ArgumentsDescriptor::count_offset()));
  __ leaq(RAX, Address(RSP, RAX, TIMES_4, 0));  // RAX is Smi.
  __ EnterStubFrame();
  __ pushq(R10);  // Preserve arguments descriptor array.
  __ pushq(RBX);  // Preserve IC data object.
  __ pushq(raw_null);  // Setup space on stack for result (target code object).
  // Push call arguments.
  for (intptr_t i = 0; i < num_args; i++) {
    __ movq(RCX, Address(RAX, -kWordSize * i));
    __ pushq(RCX);
  }
  __ pushq(RBX);  // Pass IC data object.
  __ pushq(R10);  // Pass arguments descriptor array.
  if (num_args == 1) {
    __ CallRuntime(kInlineCacheMissHandlerOneArgRuntimeEntry);
  } else if (num_args == 2) {
    __ CallRuntime(kInlineCacheMissHandlerTwoArgsRuntimeEntry);
  } else if (num_args == 3) {
    __ CallRuntime(kInlineCacheMissHandlerThreeArgsRuntimeEntry);
  } else {
    UNIMPLEMENTED();
  }
  // Remove the call arguments pushed earlier, including the IC data object
  // and the arguments descriptor array.
  for (intptr_t i = 0; i < num_args + 2; i++) {
    __ popq(RAX);
  }
  __ popq(RAX);  // Pop returned code object into RAX (null if not found).
  __ popq(RBX);  // Restore IC data array.
  __ popq(R10);  // Restore arguments descriptor array.
  __ LeaveFrame();
  Label call_target_function;
  __ cmpq(RAX, raw_null);
  __ j(NOT_EQUAL, &call_target_function, Assembler::kNearJump);
  // NoSuchMethod or closure.
  // Mark IC call that it may be a closure call that does not collect
  // type feedback.
  __ movb(FieldAddress(RBX, ICData::is_closure_call_offset()), Immediate(1));
  __ jmp(&StubCode::InstanceFunctionLookupLabel());

  __ Bind(&found);
  // R12: Pointer to an IC data check group.
  const intptr_t target_offset = ICData::TargetIndexFor(num_args) * kWordSize;
  const intptr_t count_offset = ICData::CountIndexFor(num_args) * kWordSize;
  __ movq(RAX, Address(R12, target_offset));
  __ addq(Address(R12, count_offset), Immediate(Smi::RawValue(1)));
  __ j(NO_OVERFLOW, &call_target_function);
  __ movq(Address(R12, count_offset),
          Immediate(Smi::RawValue(Smi::kMaxValue)));

  __ Bind(&call_target_function);
  // RAX: Target function.
  __ movq(RAX, FieldAddress(RAX, Function::code_offset()));
  __ movq(RAX, FieldAddress(RAX, Code::instructions_offset()));
  __ addq(RAX, Immediate(Instructions::HeaderSize() - kHeapObjectTag));
  __ jmp(RAX);

  __ Bind(&get_class_id_as_smi);
  Label not_smi;
  // Test if Smi -> load Smi class for comparison.
  __ testq(RAX, Immediate(kSmiTagMask));
  __ j(NOT_ZERO, &not_smi, Assembler::kNearJump);
  __ movq(RAX, Immediate(Smi::RawValue(kSmiCid)));
  __ ret();

  __ Bind(&not_smi);
  __ LoadClassId(RAX, RAX);
  __ SmiTag(RAX);
  __ ret();
}


// Use inline cache data array to invoke the target or continue in inline
// cache miss handler. Stub for 1-argument check (receiver class).
//  RBX: Inline cache data object.
//  R10: Arguments descriptor array.
//  TOS(0): Return address.
// Inline cache data object structure:
// 0: function-name
// 1: N, number of arguments checked.
// 2 .. (length - 1): group of checks, each check containing:
//   - N classes.
//   - 1 target function.
void StubCode::GenerateOneArgCheckInlineCacheStub(Assembler* assembler) {
  GenerateUsageCounterIncrement(assembler, RCX);
  GenerateNArgsCheckInlineCacheStub(assembler, 1);
}


void StubCode::GenerateTwoArgsCheckInlineCacheStub(Assembler* assembler) {
  GenerateUsageCounterIncrement(assembler, RCX);
  GenerateNArgsCheckInlineCacheStub(assembler, 2);
}


void StubCode::GenerateThreeArgsCheckInlineCacheStub(Assembler* assembler) {
  GenerateUsageCounterIncrement(assembler, RCX);
  GenerateNArgsCheckInlineCacheStub(assembler, 3);
}

// Use inline cache data array to invoke the target or continue in inline
// cache miss handler. Stub for 1-argument check (receiver class).
//  RDI: function which counter needs to be incremented.
//  RBX: Inline cache data object.
//  R10: Arguments descriptor array.
//  TOS(0): Return address.
// Inline cache data object structure:
// 0: function-name
// 1: N, number of arguments checked.
// 2 .. (length - 1): group of checks, each check containing:
//   - N classes.
//   - 1 target function.
void StubCode::GenerateOneArgOptimizedCheckInlineCacheStub(
    Assembler* assembler) {
  GenerateOptimizedUsageCounterIncrement(assembler);
  GenerateNArgsCheckInlineCacheStub(assembler, 1);
}


void StubCode::GenerateTwoArgsOptimizedCheckInlineCacheStub(
    Assembler* assembler) {
  GenerateOptimizedUsageCounterIncrement(assembler);
  GenerateNArgsCheckInlineCacheStub(assembler, 2);
}


void StubCode::GenerateThreeArgsOptimizedCheckInlineCacheStub(
    Assembler* assembler) {
  GenerateOptimizedUsageCounterIncrement(assembler);
  GenerateNArgsCheckInlineCacheStub(assembler, 3);
}


// Do not count as no type feedback is collected.
void StubCode::GenerateClosureCallInlineCacheStub(Assembler* assembler) {
  GenerateNArgsCheckInlineCacheStub(assembler, 1);
}


// Megamorphic call is currently implemented as IC call but through a stub
// that does not check/count function invocations.
void StubCode::GenerateMegamorphicCallStub(Assembler* assembler) {
  GenerateNArgsCheckInlineCacheStub(assembler, 1);
}


//  R10: Arguments descriptor array.
//  TOS(0): return address (Dart code).
void StubCode::GenerateBreakpointClosureStub(Assembler* assembler) {
  __ EnterStubFrame();
  __ pushq(R10);       // Preserve arguments descriptor.
  __ CallRuntime(kBreakpointClosureHandlerRuntimeEntry);
  __ popq(R10);  // Restore arguments descriptor.
  __ LeaveFrame();
  __ jmp(&StubCode::CallClosureFunctionLabel());
}


//  R10: Arguments descriptor array.
//  TOS(0): return address (Dart code).
void StubCode::GenerateBreakpointStaticStub(Assembler* assembler) {
  const Immediate& raw_null =
      Immediate(reinterpret_cast<intptr_t>(Object::null()));
  __ EnterStubFrame();
  __ pushq(R10);  // Preserve arguments descriptor.
  __ pushq(raw_null);  // Room for result.
  __ CallRuntime(kBreakpointStaticHandlerRuntimeEntry);
  __ popq(RAX);  // Code object.
  __ popq(R10);  // Restore arguments descriptor.
  __ LeaveFrame();

  // Now call the static function. The breakpoint handler function
  // ensures that the call target is compiled.
  __ movq(RBX, FieldAddress(RAX, Code::instructions_offset()));
  __ addq(RBX, Immediate(Instructions::HeaderSize() - kHeapObjectTag));
  __ jmp(RBX);
}


//  TOS(0): return address (Dart code).
void StubCode::GenerateBreakpointReturnStub(Assembler* assembler) {
  __ EnterStubFrame();
  __ pushq(RAX);
  __ CallRuntime(kBreakpointReturnHandlerRuntimeEntry);
  __ popq(RAX);
  __ LeaveFrame();

  __ popq(R11);  // discard return address of call to this stub.
  __ LeaveFrame();
  __ ret();
}


//  RBX: Inline cache data array.
//  R10: Arguments descriptor array.
//  TOS(0): return address (Dart code).
void StubCode::GenerateBreakpointDynamicStub(Assembler* assembler) {
  __ EnterStubFrame();
  __ pushq(RBX);
  __ pushq(R10);
  __ CallRuntime(kBreakpointDynamicHandlerRuntimeEntry);
  __ popq(R10);
  __ popq(RBX);
  __ LeaveFrame();

  // Find out which dispatch stub to call.
  Label test_two, test_three, test_four;
  __ movq(RCX, FieldAddress(RBX, ICData::num_args_tested_offset()));
  __ cmpq(RCX, Immediate(1));
  __ j(NOT_EQUAL, &test_two, Assembler::kNearJump);
  __ jmp(&StubCode::OneArgCheckInlineCacheLabel());
  __ Bind(&test_two);
  __ cmpl(RCX, Immediate(2));
  __ j(NOT_EQUAL, &test_three, Assembler::kNearJump);
  __ jmp(&StubCode::TwoArgsCheckInlineCacheLabel());
  __ Bind(&test_three);
  __ cmpl(RCX, Immediate(3));
  __ j(NOT_EQUAL, &test_four, Assembler::kNearJump);
  __ jmp(&StubCode::ThreeArgsCheckInlineCacheLabel());
  __ Bind(&test_four);
  __ Stop("Unsupported number of arguments tested.");
}


// Used to check class and type arguments. Arguments passed on stack:
// TOS + 0: return address.
// TOS + 1: instantiator type arguments (can be NULL).
// TOS + 2: instance.
// TOS + 3: SubtypeTestCache.
// Result in RCX: null -> not found, otherwise result (true or false).
static void GenerateSubtypeNTestCacheStub(Assembler* assembler, int n) {
  ASSERT((1 <= n) && (n <= 3));
  const Immediate& raw_null =
      Immediate(reinterpret_cast<intptr_t>(Object::null()));
  const intptr_t kInstantiatorTypeArgumentsInBytes = 1 * kWordSize;
  const intptr_t kInstanceOffsetInBytes = 2 * kWordSize;
  const intptr_t kCacheOffsetInBytes = 3 * kWordSize;
  __ movq(RAX, Address(RSP, kInstanceOffsetInBytes));
  if (n > 1) {
    __ LoadClass(R10, RAX);
    // Compute instance type arguments into R13.
    Label has_no_type_arguments;
    __ movq(R13, raw_null);
    __ movq(RDI, FieldAddress(R10,
        Class::type_arguments_field_offset_in_words_offset()));
    __ cmpq(RDI, Immediate(Class::kNoTypeArguments));
    __ j(EQUAL, &has_no_type_arguments, Assembler::kNearJump);
    __ movq(R13, FieldAddress(RAX, RDI, TIMES_8, 0));
    __ Bind(&has_no_type_arguments);
  }
  __ LoadClassId(R10, RAX);
  // RAX: instance, R10: instance class id.
  // R13: instance type arguments or null, used only if n > 1.
  __ movq(RDX, Address(RSP, kCacheOffsetInBytes));
  // RDX: SubtypeTestCache.
  __ movq(RDX, FieldAddress(RDX, SubtypeTestCache::cache_offset()));
  __ addq(RDX, Immediate(Array::data_offset() - kHeapObjectTag));
  // RDX: Entry start.
  // R10: instance class id.
  // R13: instance type arguments.
  Label loop, found, not_found, next_iteration;
  __ SmiTag(R10);
  __ Bind(&loop);
  __ movq(RDI, Address(RDX, kWordSize * SubtypeTestCache::kInstanceClassId));
  __ cmpq(RDI, raw_null);
  __ j(EQUAL, &not_found, Assembler::kNearJump);
  __ cmpq(RDI, R10);
  if (n == 1) {
    __ j(EQUAL, &found, Assembler::kNearJump);
  } else {
    __ j(NOT_EQUAL, &next_iteration, Assembler::kNearJump);
    __ movq(RDI,
        Address(RDX, kWordSize * SubtypeTestCache::kInstanceTypeArguments));
    __ cmpq(RDI, R13);
    if (n == 2) {
      __ j(EQUAL, &found, Assembler::kNearJump);
    } else {
      __ j(NOT_EQUAL, &next_iteration, Assembler::kNearJump);
      __ movq(RDI,
          Address(RDX,
                  kWordSize * SubtypeTestCache::kInstantiatorTypeArguments));
      __ cmpq(RDI, Address(RSP, kInstantiatorTypeArgumentsInBytes));
      __ j(EQUAL, &found, Assembler::kNearJump);
    }
  }

  __ Bind(&next_iteration);
  __ addq(RDX, Immediate(kWordSize * SubtypeTestCache::kTestEntryLength));
  __ jmp(&loop, Assembler::kNearJump);
  // Fall through to not found.
  __ Bind(&not_found);
  __ movq(RCX, raw_null);
  __ ret();

  __ Bind(&found);
  __ movq(RCX, Address(RDX, kWordSize * SubtypeTestCache::kTestResult));
  __ ret();
}


// Used to check class and type arguments. Arguments passed on stack:
// TOS + 0: return address.
// TOS + 1: instantiator type arguments or NULL.
// TOS + 2: instance.
// TOS + 3: cache array.
// Result in RCX: null -> not found, otherwise result (true or false).
void StubCode::GenerateSubtype1TestCacheStub(Assembler* assembler) {
  GenerateSubtypeNTestCacheStub(assembler, 1);
}


// Used to check class and type arguments. Arguments passed on stack:
// TOS + 0: return address.
// TOS + 1: instantiator type arguments or NULL.
// TOS + 2: instance.
// TOS + 3: cache array.
// Result in RCX: null -> not found, otherwise result (true or false).
void StubCode::GenerateSubtype2TestCacheStub(Assembler* assembler) {
  GenerateSubtypeNTestCacheStub(assembler, 2);
}


// Used to check class and type arguments. Arguments passed on stack:
// TOS + 0: return address.
// TOS + 1: instantiator type arguments.
// TOS + 2: instance.
// TOS + 3: cache array.
// Result in RCX: null -> not found, otherwise result (true or false).
void StubCode::GenerateSubtype3TestCacheStub(Assembler* assembler) {
  GenerateSubtypeNTestCacheStub(assembler, 3);
}


// Return the current stack pointer address, used to stack alignment
// checks.
// TOS + 0: return address
// Result in RAX.
void StubCode::GenerateGetStackPointerStub(Assembler* assembler) {
  __ leaq(RAX, Address(RSP, kWordSize));
  __ ret();
}


// Jump to the exception or error handler.
// TOS + 0: return address
// RDI: program counter
// RSI: stack pointer
// RDX: frame_pointer
// RCX: exception object
// R8: stacktrace object
// No Result.
void StubCode::GenerateJumpToExceptionHandlerStub(Assembler* assembler) {
  ASSERT(kExceptionObjectReg == RAX);
  ASSERT(kStackTraceObjectReg == RDX);
  __ movq(RBP, RDX);  // target frame pointer.
  __ movq(kStackTraceObjectReg, R8);  // stacktrace object.
  __ movq(kExceptionObjectReg, RCX);  // exception object.
  __ movq(RSP, RSI);   // target stack_pointer.
  __ jmp(RDI);  // Jump to the exception handler code.
}


// Implements equality operator when one of the arguments is null
// (identity check) and updates ICData if necessary.
// TOS + 0: return address
// TOS + 1: right argument
// TOS + 2: left argument
// RBX: ICData.
// RAX: result.
// TODO(srdjan): Move to VM stubs once Boolean objects become VM objects.
void StubCode::GenerateEqualityWithNullArgStub(Assembler* assembler) {
  static const intptr_t kNumArgsTested = 2;
#if defined(DEBUG)
  { Label ok;
    __ movq(RCX, FieldAddress(RBX, ICData::num_args_tested_offset()));
    __ cmpq(RCX, Immediate(kNumArgsTested));
    __ j(EQUAL, &ok, Assembler::kNearJump);
    __ Stop("Incorrect ICData for equality");
    __ Bind(&ok);
  }
#endif  // DEBUG
  // Check IC data, update if needed.
  // RBX: IC data object (preserved).
  __ movq(R12, FieldAddress(RBX, ICData::ic_data_offset()));
  // R12: ic_data_array with check entries: classes and target functions.
  __ leaq(R12, FieldAddress(R12, Array::data_offset()));
  // R12: points directly to the first ic data array element.

  Label get_class_id_as_smi, no_match, loop, compute_result, found;
  __ Bind(&loop);
  // Check left.
  __ movq(RAX, Address(RSP, 2 * kWordSize));
  __ call(&get_class_id_as_smi);
  __ movq(R13, Address(R12, 0 * kWordSize));
  __ cmpq(RAX, R13);  // Class id match?
  __ j(NOT_EQUAL, &no_match, Assembler::kNearJump);
  // Check right.
  __ movq(RAX, Address(RSP, 1 * kWordSize));
  __ call(&get_class_id_as_smi);
  __ movq(R13, Address(R12, 1 * kWordSize));
  __ cmpq(RAX, R13);  // Class id match?
  __ j(EQUAL, &found, Assembler::kNearJump);
  __ Bind(&no_match);
  // Next check group.
  __ addq(R12, Immediate(
      kWordSize * ICData::TestEntryLengthFor(kNumArgsTested)));
  __ cmpq(R13, Immediate(Smi::RawValue(kIllegalCid)));  // Done?
  __ j(NOT_EQUAL, &loop, Assembler::kNearJump);
  Label update_ic_data;
  __ jmp(&update_ic_data);

  __ Bind(&found);
  const intptr_t count_offset =
      ICData::CountIndexFor(kNumArgsTested) * kWordSize;
  __ addq(Address(R12, count_offset), Immediate(Smi::RawValue(1)));
  __ j(NO_OVERFLOW, &compute_result);
  __ movq(Address(R12, count_offset),
          Immediate(Smi::RawValue(Smi::kMaxValue)));

  __ Bind(&compute_result);
  Label true_label;
  __ movq(RAX, Address(RSP, 1 * kWordSize));
  __ cmpq(RAX, Address(RSP, 2 * kWordSize));
  __ j(EQUAL, &true_label, Assembler::kNearJump);
  __ LoadObject(RAX, Bool::False());
  __ ret();
  __ Bind(&true_label);
  __ LoadObject(RAX, Bool::True());
  __ ret();

  __ Bind(&get_class_id_as_smi);
  Label not_smi;
  // Test if Smi -> load Smi class for comparison.
  __ testq(RAX, Immediate(kSmiTagMask));
  __ j(NOT_ZERO, &not_smi, Assembler::kNearJump);
  __ movq(RAX, Immediate(Smi::RawValue(kSmiCid)));
  __ ret();

  __ Bind(&not_smi);
  __ LoadClassId(RAX, RAX);
  __ SmiTag(RAX);
  __ ret();

  __ Bind(&update_ic_data);

  // RCX: ICData
  __ movq(RAX, Address(RSP, 1 * kWordSize));
  __ movq(R13, Address(RSP, 2 * kWordSize));
  __ EnterStubFrame();
  __ pushq(R13);  // arg 0
  __ pushq(RAX);  // arg 1
  __ PushObject(Symbols::EqualOperator());  // Target's name.
  __ pushq(RBX);  // ICData
  __ CallRuntime(kUpdateICDataTwoArgsRuntimeEntry);
  __ Drop(4);
  __ LeaveFrame();

  __ jmp(&compute_result, Assembler::kNearJump);
}

// Calls to the runtime to optimize the given function.
// RDI: function to be reoptimized.
// R10: argument descriptor (preserved).
void StubCode::GenerateOptimizeFunctionStub(Assembler* assembler) {
  const Immediate& raw_null =
      Immediate(reinterpret_cast<intptr_t>(Object::null()));
  __ EnterStubFrame();
  __ pushq(R10);
  __ pushq(raw_null);  // Setup space on stack for return value.
  __ pushq(RDI);
  __ CallRuntime(kOptimizeInvokedFunctionRuntimeEntry);
  __ popq(RAX);  // Disard argument.
  __ popq(RAX);  // Get Code object.
  __ popq(R10);  // Restore argument descriptor.
  __ movq(RAX, FieldAddress(RAX, Code::instructions_offset()));
  __ addq(RAX, Immediate(Instructions::HeaderSize() - kHeapObjectTag));
  __ LeaveFrame();
  __ jmp(RAX);
  __ int3();
}


DECLARE_LEAF_RUNTIME_ENTRY(intptr_t,
                           BigintCompare,
                           RawBigint* left,
                           RawBigint* right);


// Does identical check (object references are equal or not equal) with special
// checks for boxed numbers.
// Left and right are pushed on stack.
// Return ZF set.
// Note: A Mint cannot contain a value that would fit in Smi, a Bigint
// cannot contain a value that fits in Mint or Smi.
void StubCode::GenerateIdenticalWithNumberCheckStub(Assembler* assembler) {
  const Register left = RAX;
  const Register right = RDX;
  // Preserve left, right and temp.
  __ pushq(left);
  __ pushq(right);
  // TOS + 0: saved right
  // TOS + 1: saved left
  // TOS + 2: return address
  // TOS + 3: right argument.
  // TOS + 4: left argument.
  __ movq(left, Address(RSP, 4 * kWordSize));
  __ movq(right, Address(RSP, 3 * kWordSize));
  Label reference_compare, done, check_mint, check_bigint;
  // If any of the arguments is Smi do reference compare.
  __ testq(left, Immediate(kSmiTagMask));
  __ j(ZERO, &reference_compare);
  __ testq(right, Immediate(kSmiTagMask));
  __ j(ZERO, &reference_compare);

  // Value compare for two doubles.
  __ CompareClassId(left, kDoubleCid);
  __ j(NOT_EQUAL, &check_mint, Assembler::kNearJump);
  __ CompareClassId(right, kDoubleCid);
  __ j(NOT_EQUAL, &done, Assembler::kNearJump);

  // Double values bitwise compare.
  __ movq(left, FieldAddress(left, Double::value_offset()));
  __ cmpq(left, FieldAddress(right, Double::value_offset()));
  __ jmp(&done, Assembler::kNearJump);

  __ Bind(&check_mint);
  __ CompareClassId(left, kMintCid);
  __ j(NOT_EQUAL, &check_bigint, Assembler::kNearJump);
  __ CompareClassId(right, kMintCid);
  __ j(NOT_EQUAL, &done, Assembler::kNearJump);
  __ movq(left, FieldAddress(left, Mint::value_offset()));
  __ cmpq(left, FieldAddress(right, Mint::value_offset()));
  __ jmp(&done, Assembler::kNearJump);

  __ Bind(&check_bigint);
  __ CompareClassId(left, kBigintCid);
  __ j(NOT_EQUAL, &reference_compare, Assembler::kNearJump);
  __ CompareClassId(right, kBigintCid);
  __ j(NOT_EQUAL, &done, Assembler::kNearJump);
  __ EnterFrame(0);
  __ ReserveAlignedFrameSpace(0);
  __ movq(RDI, left);
  __ movq(RSI, right);
  __ CallRuntime(kBigintCompareRuntimeEntry);
  // Result in RAX, 0 means equal.
  __ LeaveFrame();
  __ cmpq(RAX, Immediate(0));
  __ jmp(&done);

  __ Bind(&reference_compare);
  __ cmpq(left, right);
  __ Bind(&done);
  __ popq(right);
  __ popq(left);
  __ ret();
}

}  // namespace dart

#endif  // defined TARGET_ARCH_X64
