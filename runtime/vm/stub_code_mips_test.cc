// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/globals.h"
#if defined(TARGET_ARCH_MIPS)

#include "vm/isolate.h"
#include "vm/dart_entry.h"
#include "vm/native_entry.h"
#include "vm/native_entry_test.h"
#include "vm/object.h"
#include "vm/runtime_entry.h"
#include "vm/stub_code.h"
#include "vm/symbols.h"
#include "vm/unit_test.h"

#define __ assembler->

namespace dart {

DECLARE_RUNTIME_ENTRY(TestSmiSub);
DECLARE_LEAF_RUNTIME_ENTRY(RawObject*, TestLeafSmiAdd, RawObject*, RawObject*);


static Function* CreateFunction(const char* name) {
  const String& class_name = String::Handle(Symbols::New("ownerClass"));
  const Script& script = Script::Handle();
  const Class& owner_class =
      Class::Handle(Class::New(class_name, script, Scanner::kDummyTokenIndex));
  const String& function_name = String::ZoneHandle(Symbols::New(name));
  Function& function = Function::ZoneHandle(
      Function::New(function_name, RawFunction::kRegularFunction,
                    true, false, false, false, owner_class, 0));
  return &function;
}


// Test calls to stub code which calls into the runtime.
static void GenerateCallToCallRuntimeStub(Assembler* assembler,
                                          int value1, int value2) {
  const int argc = 2;
  const Smi& smi1 = Smi::ZoneHandle(Smi::New(value1));
  const Smi& smi2 = Smi::ZoneHandle(Smi::New(value2));
  const Object& result = Object::ZoneHandle();
  const Context& context = Context::ZoneHandle(Context::New(0, Heap::kOld));
  ASSERT(context.isolate() == Isolate::Current());
  __ EnterDartFrame(0);
  __ LoadObject(CTX, context);
  __ PushObject(result);  // Push Null object for return value.
  __ PushObject(smi1);  // Push argument 1 smi1.
  __ PushObject(smi2);  // Push argument 2 smi2.
  ASSERT(kTestSmiSubRuntimeEntry.argument_count() == argc);
  __ CallRuntime(kTestSmiSubRuntimeEntry);  // Call SmiSub runtime func.
  __ addiu(SP, SP, Immediate(argc * kWordSize));
  __ Pop(V0);  // Pop return value from return slot.
  __ LeaveDartFrameAndReturn();
}


TEST_CASE(CallRuntimeStubCode) {
  extern const Function& RegisterFakeFunction(const char* name,
                                              const Code& code);
  const int value1 = 10;
  const int value2 = 20;
  const char* kName = "Test_CallRuntimeStubCode";
  Assembler _assembler_;
  GenerateCallToCallRuntimeStub(&_assembler_, value1, value2);
  const Code& code = Code::Handle(Code::FinalizeCode(
      *CreateFunction("Test_CallRuntimeStubCode"), &_assembler_));
  const Function& function = RegisterFakeFunction(kName, code);
  Smi& result = Smi::Handle();
  result ^= DartEntry::InvokeFunction(function, Object::empty_array());
  EXPECT_EQ((value1 - value2), result.Value());
}


// Test calls to stub code which calls into a leaf runtime entry.
static void GenerateCallToCallLeafRuntimeStub(Assembler* assembler,
                                              int value1,
                                              int value2) {
  const Smi& smi1 = Smi::ZoneHandle(Smi::New(value1));
  const Smi& smi2 = Smi::ZoneHandle(Smi::New(value2));
  __ EnterDartFrame(0);
  __ ReserveAlignedFrameSpace(0);
  __ LoadObject(A0, smi1);  // Set up argument 1 smi1.
  __ LoadObject(A1, smi2);  // Set up argument 2 smi2.
  __ CallRuntime(kTestLeafSmiAddRuntimeEntry);  // Call SmiAdd runtime func.
  __ LeaveDartFrameAndReturn();  // Return value is in V0.
}


TEST_CASE(CallLeafRuntimeStubCode) {
  extern const Function& RegisterFakeFunction(const char* name,
                                              const Code& code);
  const int value1 = 10;
  const int value2 = 20;
  const char* kName = "Test_CallLeafRuntimeStubCode";
  Assembler _assembler_;
  GenerateCallToCallLeafRuntimeStub(&_assembler_, value1, value2);
  const Code& code = Code::Handle(Code::FinalizeCode(
      *CreateFunction("Test_CallLeafRuntimeStubCode"), &_assembler_));
  const Function& function = RegisterFakeFunction(kName, code);
  Smi& result = Smi::Handle();
  result ^= DartEntry::InvokeFunction(function, Object::empty_array());
  EXPECT_EQ((value1 + value2), result.Value());
}

}  // namespace dart

#endif  // defined TARGET_ARCH_MIPS
