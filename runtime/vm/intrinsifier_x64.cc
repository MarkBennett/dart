// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/globals.h"  // Needed here to get TARGET_ARCH_X64.
#if defined(TARGET_ARCH_X64)

#include "vm/intrinsifier.h"

#include "vm/assembler.h"
#include "vm/instructions.h"
#include "vm/object_store.h"
#include "vm/symbols.h"

namespace dart {

DECLARE_FLAG(bool, enable_type_checks);

// When entering intrinsics code:
// RBX: IC Data
// R10: Arguments descriptor
// TOS: Return address
// The RBX, R10 registers can be destroyed only if there is no slow-path (i.e.,
// the methods returns true).

#define __ assembler->


bool Intrinsifier::ObjectArray_Allocate(Assembler* assembler) {
  // This snippet of inlined code uses the following registers:
  // RAX, RCX, RDI, R13
  // and the newly allocated object is returned in RAX.
  const intptr_t kTypeArgumentsOffset = 2 * kWordSize;
  const intptr_t kArrayLengthOffset = 1 * kWordSize;
  Label fall_through;

  // Compute the size to be allocated, it is based on the array length
  // and is computed as:
  // RoundedAllocationSize((array_length * kwordSize) + sizeof(RawArray)).
  __ movq(RDI, Address(RSP, kArrayLengthOffset));  // Array Length.
  // Check that length is a positive Smi.
  __ testq(RDI, Immediate(kSmiTagMask));
  __ j(NOT_ZERO, &fall_through);
  __ cmpq(RDI, Immediate(0));
  __ j(LESS, &fall_through);
  // Check for maximum allowed length.
  const Immediate& max_len =
      Immediate(reinterpret_cast<int64_t>(Smi::New(Array::kMaxElements)));
  __ cmpq(RDI, max_len);
  __ j(GREATER, &fall_through);
  const intptr_t fixed_size = sizeof(RawArray) + kObjectAlignment - 1;
  __ leaq(RDI, Address(RDI, TIMES_4, fixed_size));  // RDI is a Smi.
  ASSERT(kSmiTagShift == 1);
  __ andq(RDI, Immediate(-kObjectAlignment));

  Isolate* isolate = Isolate::Current();
  Heap* heap = isolate->heap();

  __ movq(RAX, Immediate(heap->TopAddress()));
  __ movq(RAX, Address(RAX, 0));

  // RDI: allocation size.
  __ movq(RCX, RAX);
  __ addq(RCX, RDI);
  __ j(CARRY, &fall_through);

  // Check if the allocation fits into the remaining space.
  // RAX: potential new object start.
  // RCX: potential next object start.
  // RDI: allocation size.
  __ movq(R13, Immediate(heap->EndAddress()));
  __ cmpq(RCX, Address(R13, 0));
  __ j(ABOVE_EQUAL, &fall_through);

  // Successfully allocated the object(s), now update top to point to
  // next object start and initialize the object.
  __ movq(R13, Immediate(heap->TopAddress()));
  __ movq(Address(R13, 0), RCX);
  __ addq(RAX, Immediate(kHeapObjectTag));

  // Initialize the tags.
  // RAX: new object start as a tagged pointer.
  // RDI: allocation size.
  {
    Label size_tag_overflow, done;
    __ cmpq(RDI, Immediate(RawObject::SizeTag::kMaxSizeTag));
    __ j(ABOVE, &size_tag_overflow, Assembler::kNearJump);
    __ shlq(RDI, Immediate(RawObject::kSizeTagBit - kObjectAlignmentLog2));
    __ jmp(&done, Assembler::kNearJump);

    __ Bind(&size_tag_overflow);
    __ movq(RDI, Immediate(0));
    __ Bind(&done);

    // Get the class index and insert it into the tags.
    const Class& cls = Class::Handle(isolate->object_store()->array_class());
    __ orq(RDI, Immediate(RawObject::ClassIdTag::encode(cls.id())));
    __ movq(FieldAddress(RAX, Array::tags_offset()), RDI);  // Tags.
  }

  // RAX: new object start as a tagged pointer.
  // Store the type argument field.
  __ movq(RDI, Address(RSP, kTypeArgumentsOffset));  // type argument.
  __ StoreIntoObjectNoBarrier(RAX,
                              FieldAddress(RAX, Array::type_arguments_offset()),
                              RDI);

  // Set the length field.
  __ movq(RDI, Address(RSP, kArrayLengthOffset));  // Array Length.
  __ StoreIntoObjectNoBarrier(RAX,
                              FieldAddress(RAX, Array::length_offset()),
                              RDI);

  // Initialize all array elements to raw_null.
  // RAX: new object start as a tagged pointer.
  // RCX: new object end address.
  // RDI: iterator which initially points to the start of the variable
  // data area to be initialized.
  const Immediate& raw_null =
      Immediate(reinterpret_cast<intptr_t>(Object::null()));
  __ leaq(RDI, FieldAddress(RAX, sizeof(RawArray)));
  Label done;
  Label init_loop;
  __ Bind(&init_loop);
  __ cmpq(RDI, RCX);
  __ j(ABOVE_EQUAL, &done, Assembler::kNearJump);
  __ movq(Address(RDI, 0), raw_null);
  __ addq(RDI, Immediate(kWordSize));
  __ jmp(&init_loop, Assembler::kNearJump);
  __ Bind(&done);
  __ ret();  // returns the newly allocated object in RAX.

  __ Bind(&fall_through);
  return false;
}


bool Intrinsifier::Array_getLength(Assembler* assembler) {
  __ movq(RAX, Address(RSP, + 1 * kWordSize));
  __ movq(RAX, FieldAddress(RAX, Array::length_offset()));
  __ ret();
  return true;
}


bool Intrinsifier::ImmutableArray_getLength(Assembler* assembler) {
  return Array_getLength(assembler);
}


bool Intrinsifier::Array_getIndexed(Assembler* assembler) {
  Label fall_through;
  __ movq(RCX, Address(RSP, + 1 * kWordSize));  // Index.
  __ movq(RAX, Address(RSP, + 2 * kWordSize));  // Array.
  __ testq(RCX, Immediate(kSmiTagMask));
  __ j(NOT_ZERO, &fall_through, Assembler::kNearJump);  // Non-smi index.
  // Range check.
  __ cmpq(RCX, FieldAddress(RAX, Array::length_offset()));
  // Runtime throws exception.
  __ j(ABOVE_EQUAL, &fall_through, Assembler::kNearJump);
  // Note that RBX is Smi, i.e, times 2.
  ASSERT(kSmiTagShift == 1);
  __ movq(RAX, FieldAddress(RAX, RCX, TIMES_4, Array::data_offset()));
  __ ret();
  __ Bind(&fall_through);
  return false;
}


bool Intrinsifier::ImmutableArray_getIndexed(Assembler* assembler) {
  return Array_getIndexed(assembler);
}


bool Intrinsifier::Array_setIndexed(Assembler* assembler) {
  if (FLAG_enable_type_checks) {
    return false;
  }
  __ movq(RDX, Address(RSP, + 1 * kWordSize));  // Value.
  __ movq(RCX, Address(RSP, + 2 * kWordSize));  // Index.
  __ movq(RAX, Address(RSP, + 3 * kWordSize));  // Array.
  Label fall_through;
  __ testq(RCX, Immediate(kSmiTagMask));
  __ j(NOT_ZERO, &fall_through);
  // Range check.
  __ cmpq(RCX, FieldAddress(RAX, Array::length_offset()));
  // Runtime throws exception.
  __ j(ABOVE_EQUAL, &fall_through);
  // Note that RBX is Smi, i.e, times 2.
  ASSERT(kSmiTagShift == 1);
  // Destroy RCX as we will not continue in the function.
  __ StoreIntoObject(RAX,
                     FieldAddress(RAX, RCX, TIMES_4, Array::data_offset()),
                     RDX);
  // Caller is responsible of preserving the value if necessary.
  __ ret();
  __ Bind(&fall_through);
  return false;
}


// Allocate a GrowableObjectArray using the backing array specified.
// On stack: type argument (+2), data (+1), return-address (+0).
bool Intrinsifier::GrowableArray_Allocate(Assembler* assembler) {
  // This snippet of inlined code uses the following registers:
  // RAX, RCX, R13
  // and the newly allocated object is returned in RAX.
  const intptr_t kTypeArgumentsOffset = 2 * kWordSize;
  const intptr_t kArrayOffset = 1 * kWordSize;
  Label fall_through;

  // Compute the size to be allocated, it is based on the array length
  // and is computed as:
  // RoundedAllocationSize(sizeof(RawGrowableObjectArray)) +
  intptr_t fixed_size = GrowableObjectArray::InstanceSize();

  Isolate* isolate = Isolate::Current();
  Heap* heap = isolate->heap();

  __ movq(RAX, Immediate(heap->TopAddress()));
  __ movq(RAX, Address(RAX, 0));
  __ leaq(RCX, Address(RAX, fixed_size));

  // Check if the allocation fits into the remaining space.
  // RAX: potential new backing array object start.
  // RCX: potential next object start.
  __ movq(R13, Immediate(heap->EndAddress()));
  __ cmpq(RCX, Address(R13, 0));
  __ j(ABOVE_EQUAL, &fall_through);

  // Successfully allocated the object(s), now update top to point to
  // next object start and initialize the object.
  __ movq(R13, Immediate(heap->TopAddress()));
  __ movq(Address(R13, 0), RCX);
  __ addq(RAX, Immediate(kHeapObjectTag));

  // Initialize the tags.
  // EAX: new growable array object start as a tagged pointer.
  const Class& cls = Class::Handle(
      isolate->object_store()->growable_object_array_class());
  uword tags = 0;
  tags = RawObject::SizeTag::update(fixed_size, tags);
  tags = RawObject::ClassIdTag::update(cls.id(), tags);
  __ movq(FieldAddress(RAX, GrowableObjectArray::tags_offset()),
          Immediate(tags));

  // Store backing array object in growable array object.
  __ movq(RCX, Address(RSP, kArrayOffset));  // data argument.
  // RAX is new, no barrier needed.
  __ StoreIntoObjectNoBarrier(
      RAX,
      FieldAddress(RAX, GrowableObjectArray::data_offset()),
      RCX);

  // RAX: new growable array object start as a tagged pointer.
  // Store the type argument field in the growable array object.
  __ movq(RCX, Address(RSP, kTypeArgumentsOffset));  // type argument.
  __ StoreIntoObjectNoBarrier(
      RAX,
      FieldAddress(RAX, GrowableObjectArray::type_arguments_offset()),
      RCX);

  // Set the length field in the growable array object to 0.
  __ movq(FieldAddress(RAX, GrowableObjectArray::length_offset()),
          Immediate(0));
  __ ret();  // returns the newly allocated object in RAX.

  __ Bind(&fall_through);
  return false;
}


// Get length of growable object array.
// On stack: growable array (+1), return-address (+0).
bool Intrinsifier::GrowableArray_getLength(Assembler* assembler) {
  __ movq(RAX, Address(RSP, + 1 * kWordSize));
  __ movq(RAX, FieldAddress(RAX, GrowableObjectArray::length_offset()));
  __ ret();
  return true;
}


bool Intrinsifier::GrowableArray_getCapacity(Assembler* assembler) {
  __ movq(RAX, Address(RSP, + 1 * kWordSize));
  __ movq(RAX, FieldAddress(RAX, GrowableObjectArray::data_offset()));
  __ movq(RAX, FieldAddress(RAX, Array::length_offset()));
  __ ret();
  return true;
}


// Access growable object array at specified index.
// On stack: growable array (+2), index (+1), return-address (+0).
bool Intrinsifier::GrowableArray_getIndexed(Assembler* assembler) {
  Label fall_through;
  __ movq(RCX, Address(RSP, + 1 * kWordSize));  // Index.
  __ movq(RAX, Address(RSP, + 2 * kWordSize));  // GrowableArray.
  __ testq(RCX, Immediate(kSmiTagMask));
  __ j(NOT_ZERO, &fall_through, Assembler::kNearJump);  // Non-smi index.
  // Range check using _length field.
  __ cmpq(RCX, FieldAddress(RAX, GrowableObjectArray::length_offset()));
  // Runtime throws exception.
  __ j(ABOVE_EQUAL, &fall_through, Assembler::kNearJump);
  __ movq(RAX, FieldAddress(RAX, GrowableObjectArray::data_offset()));  // data.

  // Note that RCX is Smi, i.e, times 4.
  ASSERT(kSmiTagShift == 1);
  __ movq(RAX, FieldAddress(RAX, RCX, TIMES_4, Array::data_offset()));
  __ ret();
  __ Bind(&fall_through);
  return false;
}


// Set value into growable object array at specified index.
// On stack: growable array (+3), index (+2), value (+1), return-address (+0).
bool Intrinsifier::GrowableArray_setIndexed(Assembler* assembler) {
  if (FLAG_enable_type_checks) {
    return false;
  }
  __ movq(RDX, Address(RSP, + 1 * kWordSize));  // Value.
  __ movq(RCX, Address(RSP, + 2 * kWordSize));  // Index.
  __ movq(RAX, Address(RSP, + 3 * kWordSize));  // GrowableArray.
  Label fall_through;
  __ testq(RCX, Immediate(kSmiTagMask));
  __ j(NOT_ZERO, &fall_through);  // Non-smi index.
  // Range check using _length field.
  __ cmpq(RCX, FieldAddress(RAX, GrowableObjectArray::length_offset()));
  // Runtime throws exception.
  __ j(ABOVE_EQUAL, &fall_through);
  __ movq(RAX, FieldAddress(RAX, GrowableObjectArray::data_offset()));  // data.
  // Note that RCX is Smi, i.e, times 4.
  ASSERT(kSmiTagShift == 1);
  __ StoreIntoObject(RAX,
                     FieldAddress(RAX, RCX, TIMES_4, Array::data_offset()),
                     RDX);
  __ ret();
  __ Bind(&fall_through);
  return false;
}


// Set length of growable object array. The length cannot
// be greater than the length of the data container.
// On stack: growable array (+2), length (+1), return-address (+0).
bool Intrinsifier::GrowableArray_setLength(Assembler* assembler) {
  Label fall_through;
  __ movq(RAX, Address(RSP, + 2 * kWordSize));  // Growable array.
  __ movq(RCX, Address(RSP, + 1 * kWordSize));  // Length value.
  __ testq(RCX, Immediate(kSmiTagMask));
  __ j(NOT_ZERO, &fall_through, Assembler::kNearJump);  // Non-smi length.
  __ movq(FieldAddress(RAX, GrowableObjectArray::length_offset()), RCX);
  __ ret();
  __ Bind(&fall_through);
  return false;
}


// Set data of growable object array.
// On stack: growable array (+2), data (+1), return-address (+0).
bool Intrinsifier::GrowableArray_setData(Assembler* assembler) {
  if (FLAG_enable_type_checks) {
    return false;
  }
  Label fall_through;
  __ movq(RBX, Address(RSP, + 1 * kWordSize));  /// Data.
  __ testq(RBX, Immediate(kSmiTagMask));
  __ j(ZERO, &fall_through);  // Data is Smi.
  __ CompareClassId(RBX, kArrayCid);
  __ j(NOT_EQUAL, &fall_through);
  __ movq(RAX, Address(RSP, + 2 * kWordSize));  // Growable array.
  __ StoreIntoObject(RAX,
                     FieldAddress(RAX, GrowableObjectArray::data_offset()),
                     RBX);
  __ ret();
  __ Bind(&fall_through);
  return false;
}


// Add an element to growable array if it doesn't need to grow, otherwise
// call into regular code.
// On stack: growable array (+2), value (+1), return-address (+0).
bool Intrinsifier::GrowableArray_add(Assembler* assembler) {
  // In checked mode we need to check the incoming argument.
  if (FLAG_enable_type_checks) return false;
  Label fall_through;
  __ movq(RAX, Address(RSP, + 2 * kWordSize));  // Array.
  __ movq(RCX, FieldAddress(RAX, GrowableObjectArray::length_offset()));
  // RCX: length.
  __ movq(RDX, FieldAddress(RAX, GrowableObjectArray::data_offset()));
  // RDX: data.
  // Compare length with capacity.
  __ cmpq(RCX, FieldAddress(RDX, Array::length_offset()));
  __ j(EQUAL, &fall_through);  // Must grow data.
  const Immediate& value_one =
      Immediate(reinterpret_cast<int64_t>(Smi::New(1)));
  // len = len + 1;
  __ addq(FieldAddress(RAX, GrowableObjectArray::length_offset()), value_one);
  __ movq(RAX, Address(RSP, + 1 * kWordSize));  // Value
  ASSERT(kSmiTagShift == 1);
  __ StoreIntoObject(RDX,
                     FieldAddress(RDX, RCX, TIMES_4, Array::data_offset()),
                     RAX);
  const Immediate& raw_null =
      Immediate(reinterpret_cast<int64_t>(Object::null()));
  __ movq(RAX, raw_null);
  __ ret();
  __ Bind(&fall_through);
  return false;
}


#define TYPED_ARRAY_ALLOCATION(type_name, cid, max_len, scale_factor)          \
  Label fall_through;                                                          \
  const intptr_t kArrayLengthStackOffset = 1 * kWordSize;                      \
  __ movq(RDI, Address(RSP, kArrayLengthStackOffset));  /* Array length. */    \
  /* Check that length is a positive Smi. */                                   \
  /* RDI: requested array length argument. */                                  \
  __ testq(RDI, Immediate(kSmiTagMask));                                       \
  __ j(NOT_ZERO, &fall_through);                                               \
  __ cmpq(RDI, Immediate(0));                                                  \
  __ j(LESS, &fall_through);                                                   \
  __ SmiUntag(RDI);                                                            \
  /* Check for maximum allowed length. */                                      \
  /* RDI: untagged array length. */                                            \
  __ cmpq(RDI, Immediate(max_len));                                            \
  __ j(GREATER, &fall_through);                                                \
  /* Special case for scaling by 16. */                                        \
  if (scale_factor == TIMES_16) {                                              \
    /* double length of array. */                                              \
    __ addq(RDI, RDI);                                                         \
    /* only scale by 8. */                                                     \
    scale_factor = TIMES_8;                                                    \
  }                                                                            \
  const intptr_t fixed_size = sizeof(Raw##type_name) + kObjectAlignment - 1;   \
  __ leaq(RDI, Address(RDI, scale_factor, fixed_size));                        \
  __ andq(RDI, Immediate(-kObjectAlignment));                                  \
  Heap* heap = Isolate::Current()->heap();                                     \
                                                                               \
  __ movq(RAX, Immediate(heap->TopAddress()));                                 \
  __ movq(RAX, Address(RAX, 0));                                               \
  __ movq(RCX, RAX);                                                           \
                                                                               \
  /* RDI: allocation size. */                                                  \
  __ addq(RCX, RDI);                                                           \
  __ j(CARRY, &fall_through);                                                  \
                                                                               \
  /* Check if the allocation fits into the remaining space. */                 \
  /* RAX: potential new object start. */                                       \
  /* RCX: potential next object start. */                                      \
  /* RDI: allocation size. */                                                  \
  /* R13: scratch register. */                                                 \
  __ movq(R13, Immediate(heap->EndAddress()));                                 \
  __ cmpq(RCX, Address(R13, 0));                                               \
  __ j(ABOVE_EQUAL, &fall_through);                                            \
                                                                               \
  /* Successfully allocated the object(s), now update top to point to */       \
  /* next object start and initialize the object. */                           \
  __ movq(R13, Immediate(heap->TopAddress()));                                 \
  __ movq(Address(R13, 0), RCX);                                               \
  __ addq(RAX, Immediate(kHeapObjectTag));                                     \
                                                                               \
  /* Initialize the tags. */                                                   \
  /* RAX: new object start as a tagged pointer. */                             \
  /* RCX: new object end address. */                                           \
  /* RDI: allocation size. */                                                  \
  /* R13: scratch register. */                                                 \
  {                                                                            \
    Label size_tag_overflow, done;                                             \
    __ cmpq(RDI, Immediate(RawObject::SizeTag::kMaxSizeTag));                  \
    __ j(ABOVE, &size_tag_overflow, Assembler::kNearJump);                     \
    __ shlq(RDI, Immediate(RawObject::kSizeTagBit - kObjectAlignmentLog2));    \
    __ jmp(&done, Assembler::kNearJump);                                       \
                                                                               \
    __ Bind(&size_tag_overflow);                                               \
    __ movq(RDI, Immediate(0));                                                \
    __ Bind(&done);                                                            \
                                                                               \
    /* Get the class index and insert it into the tags. */                     \
    __ orq(RDI, Immediate(RawObject::ClassIdTag::encode(cid)));                \
    __ movq(FieldAddress(RAX, type_name::tags_offset()), RDI);  /* Tags. */    \
  }                                                                            \
  /* Set the length field. */                                                  \
  /* RAX: new object start as a tagged pointer. */                             \
  /* RCX: new object end address. */                                           \
  __ movq(RDI, Address(RSP, kArrayLengthStackOffset));  /* Array length. */    \
  __ StoreIntoObjectNoBarrier(RAX,                                             \
                              FieldAddress(RAX, type_name::length_offset()),   \
                              RDI);                                            \
  /* Initialize all array elements to 0. */                                    \
  /* RAX: new object start as a tagged pointer. */                             \
  /* RCX: new object end address. */                                           \
  /* RDI: iterator which initially points to the start of the variable */      \
  /* RBX: scratch register. */                                                 \
  /* data area to be initialized. */                                           \
  __ xorq(RBX, RBX);  /* Zero. */                                              \
  __ leaq(RDI, FieldAddress(RAX, sizeof(Raw##type_name)));                     \
  Label done, init_loop;                                                       \
  __ Bind(&init_loop);                                                         \
  __ cmpq(RDI, RCX);                                                           \
  __ j(ABOVE_EQUAL, &done, Assembler::kNearJump);                              \
  __ movq(Address(RDI, 0), RBX);                                               \
  __ addq(RDI, Immediate(kWordSize));                                          \
  __ jmp(&init_loop, Assembler::kNearJump);                                    \
  __ Bind(&done);                                                              \
                                                                               \
  __ ret();                                                                    \
  __ Bind(&fall_through);                                                      \


// Gets the length of a TypedData.
bool Intrinsifier::TypedData_getLength(Assembler* assembler) {
  __ movq(RAX, Address(RSP, + 1 * kWordSize));
  __ movq(RAX, FieldAddress(RAX, TypedData::length_offset()));
  __ ret();
  // Generate enough code to satisfy patchability constraint.
  intptr_t offset = __ CodeSize();
  __ nop(JumpPattern::InstructionLength() - offset);
  return true;
}


static ScaleFactor GetScaleFactor(intptr_t size) {
  switch (size) {
    case 1: return TIMES_1;
    case 2: return TIMES_2;
    case 4: return TIMES_4;
    case 8: return TIMES_8;
    case 16: return TIMES_16;
  }
  UNREACHABLE();
  return static_cast<ScaleFactor>(0);
};


#define TYPEDDATA_ALLOCATOR(clazz)                                             \
bool Intrinsifier::TypedData_##clazz##_new(Assembler* assembler) {             \
  intptr_t size = TypedData::ElementSizeInBytes(kTypedData##clazz##Cid);       \
  intptr_t max_len = TypedData::MaxElements(kTypedData##clazz##Cid);           \
  ScaleFactor scale = GetScaleFactor(size);                                    \
  TYPED_ARRAY_ALLOCATION(TypedData, kTypedData##clazz##Cid, max_len, scale);   \
  return false;                                                                \
}                                                                              \
bool Intrinsifier::TypedData_##clazz##_factory(Assembler* assembler) {         \
  intptr_t size = TypedData::ElementSizeInBytes(kTypedData##clazz##Cid);       \
  intptr_t max_len = TypedData::MaxElements(kTypedData##clazz##Cid);           \
  ScaleFactor scale = GetScaleFactor(size);                                    \
  TYPED_ARRAY_ALLOCATION(TypedData, kTypedData##clazz##Cid, max_len, scale);   \
  return false;                                                                \
}
CLASS_LIST_TYPED_DATA(TYPEDDATA_ALLOCATOR)
#undef TYPEDDATA_ALLOCATOR


// Tests if two top most arguments are smis, jumps to label not_smi if not.
// Topmost argument is in RAX.
static void TestBothArgumentsSmis(Assembler* assembler, Label* not_smi) {
  __ movq(RAX, Address(RSP, + 1 * kWordSize));
  __ movq(RCX, Address(RSP, + 2 * kWordSize));
  __ orq(RCX, RAX);
  __ testq(RCX, Immediate(kSmiTagMask));
  __ j(NOT_ZERO, not_smi);
}


bool Intrinsifier::Integer_addFromInteger(Assembler* assembler) {
  Label fall_through;
  TestBothArgumentsSmis(assembler, &fall_through);
  // RAX contains right argument.
  __ addq(RAX, Address(RSP, + 2 * kWordSize));
  __ j(OVERFLOW, &fall_through, Assembler::kNearJump);
  // Result is in RAX.
  __ ret();
  __ Bind(&fall_through);
  return false;
}


bool Intrinsifier::Integer_add(Assembler* assembler) {
  return Integer_addFromInteger(assembler);
}


bool Intrinsifier::Integer_subFromInteger(Assembler* assembler) {
  Label fall_through;
  TestBothArgumentsSmis(assembler, &fall_through);
  // RAX contains right argument, which is the actual minuend of subtraction.
  __ subq(RAX, Address(RSP, + 2 * kWordSize));
  __ j(OVERFLOW, &fall_through, Assembler::kNearJump);
  // Result is in RAX.
  __ ret();
  __ Bind(&fall_through);
  return false;
}


bool Intrinsifier::Integer_sub(Assembler* assembler) {
  Label fall_through;
  TestBothArgumentsSmis(assembler, &fall_through);
  // RAX contains right argument, which is the actual subtrahend of subtraction.
  __ movq(RCX, RAX);
  __ movq(RAX, Address(RSP, + 2 * kWordSize));
  __ subq(RAX, RCX);
  __ j(OVERFLOW, &fall_through, Assembler::kNearJump);
  // Result is in RAX.
  __ ret();
  __ Bind(&fall_through);
  return false;
}



bool Intrinsifier::Integer_mulFromInteger(Assembler* assembler) {
  Label fall_through;
  TestBothArgumentsSmis(assembler, &fall_through);
  // RAX is the right argument.
  ASSERT(kSmiTag == 0);  // Adjust code below if not the case.
  __ SmiUntag(RAX);
  __ imulq(RAX, Address(RSP, + 2 * kWordSize));
  __ j(OVERFLOW, &fall_through, Assembler::kNearJump);
  // Result is in RAX.
  __ ret();
  __ Bind(&fall_through);
  return false;
}


bool Intrinsifier::Integer_mul(Assembler* assembler) {
  return Integer_mulFromInteger(assembler);
}


// Optimizations:
// - result is 0 if:
//   - left is 0
//   - left equals right
// - result is left if
//   - left > 0 && left < right
// RAX: Tagged left (dividend).
// RCX: Tagged right (divisor).
// RAX: Untagged result (remainder).
void EmitRemainderOperation(Assembler* assembler) {
  Label return_zero, try_modulo, not_32bit, done;
  // Check for quick zero results.
  __ cmpq(RAX, Immediate(0));
  __ j(EQUAL, &return_zero, Assembler::kNearJump);
  __ cmpq(RAX, RCX);
  __ j(EQUAL, &return_zero, Assembler::kNearJump);

  // Check if result equals left.
  __ cmpq(RAX, Immediate(0));
  __ j(LESS, &try_modulo, Assembler::kNearJump);
  // left is positive.
  __ cmpq(RAX, RCX);
  __ j(GREATER, &try_modulo,  Assembler::kNearJump);
  // left is less than right, result is left (RAX).
  __ ret();

  __ Bind(&return_zero);
  __ xorq(RAX, RAX);
  __ ret();

  __ Bind(&try_modulo);

  // Check if both operands fit into 32bits as idiv with 64bit operands
  // requires twice as many cycles and has much higher latency. We are checking
  // this before untagging them to avoid corner case dividing INT_MAX by -1 that
  // raises exception because quotient is too large for 32bit register.
  __ movsxd(RBX, RAX);
  __ cmpq(RBX, RAX);
  __ j(NOT_EQUAL, &not_32bit, Assembler::kNearJump);
  __ movsxd(RBX, RCX);
  __ cmpq(RBX, RCX);
  __ j(NOT_EQUAL, &not_32bit, Assembler::kNearJump);

  // Both operands are 31bit smis. Divide using 32bit idiv.
  __ SmiUntag(RAX);
  __ SmiUntag(RCX);
  __ cdq();
  __ idivl(RCX);
  __ movsxd(RAX, RDX);
  __ jmp(&done, Assembler::kNearJump);

  // Divide using 64bit idiv.
  __ Bind(&not_32bit);
  __ SmiUntag(RAX);
  __ SmiUntag(RCX);
  __ cqo();
  __ idivq(RCX);
  __ movq(RAX, RDX);
  __ Bind(&done);
}


// Implementation:
//  res = left % right;
//  if (res < 0) {
//    if (right < 0) {
//      res = res - right;
//    } else {
//      res = res + right;
//    }
//  }
bool Intrinsifier::Integer_modulo(Assembler* assembler) {
  Label fall_through, negative_result;
  TestBothArgumentsSmis(assembler, &fall_through);
  // RAX: right argument (divisor)
  __ movq(RCX, RAX);
  __ movq(RAX, Address(RSP, + 2 * kWordSize));  // Left argument (dividend).
  // RAX: Tagged left (dividend).
  // RCX: Tagged right (divisor).
  __ cmpq(RCX, Immediate(0));
  __ j(EQUAL, &fall_through);
  EmitRemainderOperation(assembler);
  // Untagged remainder result in RAX.
  __ cmpq(RAX, Immediate(0));
  __ j(LESS, &negative_result, Assembler::kNearJump);
  __ SmiTag(RAX);
  __ ret();

  __ Bind(&negative_result);
  Label subtract;
  // RAX: Untagged result.
  // RCX: Untagged right.
  __ cmpq(RCX, Immediate(0));
  __ j(LESS, &subtract, Assembler::kNearJump);
  __ addq(RAX, RCX);
  __ SmiTag(RAX);
  __ ret();

  __ Bind(&subtract);
  __ subq(RAX, RCX);
  __ SmiTag(RAX);
  __ ret();

  __ Bind(&fall_through);
  return false;
}


bool Intrinsifier::Integer_remainder(Assembler* assembler) {
  Label fall_through;
  TestBothArgumentsSmis(assembler, &fall_through);
  // RAX: right argument (divisor)
  __ movq(RCX, RAX);
  __ movq(RAX, Address(RSP, + 2 * kWordSize));  // Left argument (dividend).
  // RAX: Tagged left (dividend).
  // RCX: Tagged right (divisor).
  __ cmpq(RCX, Immediate(0));
  __ j(EQUAL, &fall_through);
  EmitRemainderOperation(assembler);
  // Untagged remainder result in RAX.
  __ SmiTag(RAX);
  __ ret();
  __ Bind(&fall_through);
  return false;
}


bool Intrinsifier::Integer_truncDivide(Assembler* assembler) {
  Label fall_through, not_32bit;
  TestBothArgumentsSmis(assembler, &fall_through);
  // RAX: right argument (divisor)
  __ cmpq(RAX, Immediate(0));
  __ j(EQUAL, &fall_through, Assembler::kNearJump);
  __ movq(RCX, RAX);
  __ movq(RAX, Address(RSP, + 2 * kWordSize));  // Left argument (dividend).

  // Check if both operands fit into 32bits as idiv with 64bit operands
  // requires twice as many cycles and has much higher latency. We are checking
  // this before untagging them to avoid corner case dividing INT_MAX by -1 that
  // raises exception because quotient is too large for 32bit register.
  __ movsxd(RBX, RAX);
  __ cmpq(RBX, RAX);
  __ j(NOT_EQUAL, &not_32bit);
  __ movsxd(RBX, RCX);
  __ cmpq(RBX, RCX);
  __ j(NOT_EQUAL, &not_32bit);

  // Both operands are 31bit smis. Divide using 32bit idiv.
  __ SmiUntag(RAX);
  __ SmiUntag(RCX);
  __ cdq();
  __ idivl(RCX);
  __ movsxd(RAX, RAX);
  __ SmiTag(RAX);  // Result is guaranteed to fit into a smi.
  __ ret();

  // Divide using 64bit idiv.
  __ Bind(&not_32bit);
  __ SmiUntag(RAX);
  __ SmiUntag(RCX);
  __ pushq(RDX);  // Preserve RDX in case of 'fall_through'.
  __ cqo();
  __ idivq(RCX);
  __ popq(RDX);
  // Check the corner case of dividing the 'MIN_SMI' with -1, in which case we
  // cannot tag the result.
  __ cmpq(RAX, Immediate(0x4000000000000000));
  __ j(EQUAL, &fall_through);
  __ SmiTag(RAX);
  __ ret();
  __ Bind(&fall_through);
  return false;
}


bool Intrinsifier::Integer_negate(Assembler* assembler) {
  Label fall_through;
  __ movq(RAX, Address(RSP, + 1 * kWordSize));
  __ testq(RAX, Immediate(kSmiTagMask));
  __ j(NOT_ZERO, &fall_through, Assembler::kNearJump);  // Non-smi value.
  __ negq(RAX);
  __ j(OVERFLOW, &fall_through, Assembler::kNearJump);
  // Result is in RAX.
  __ ret();
  __ Bind(&fall_through);
  return false;
}


bool Intrinsifier::Integer_bitAndFromInteger(Assembler* assembler) {
  Label fall_through;
  TestBothArgumentsSmis(assembler, &fall_through);
  // RAX is the right argument.
  __ andq(RAX, Address(RSP, + 2 * kWordSize));
  // Result is in RAX.
  __ ret();
  __ Bind(&fall_through);
  return false;
}


bool Intrinsifier::Integer_bitAnd(Assembler* assembler) {
  return Integer_bitAndFromInteger(assembler);
}


bool Intrinsifier::Integer_bitOrFromInteger(Assembler* assembler) {
  Label fall_through;
  TestBothArgumentsSmis(assembler, &fall_through);
  // RAX is the right argument.
  __ orq(RAX, Address(RSP, + 2 * kWordSize));
  // Result is in RAX.
  __ ret();
  __ Bind(&fall_through);
  return false;
}


bool Intrinsifier::Integer_bitOr(Assembler* assembler) {
  return Integer_bitOrFromInteger(assembler);
}


bool Intrinsifier::Integer_bitXorFromInteger(Assembler* assembler) {
  Label fall_through;
  TestBothArgumentsSmis(assembler, &fall_through);
  // RAX is the right argument.
  __ xorq(RAX, Address(RSP, + 2 * kWordSize));
  // Result is in RAX.
  __ ret();
  __ Bind(&fall_through);
  return false;
}


bool Intrinsifier::Integer_bitXor(Assembler* assembler) {
  return Integer_bitXorFromInteger(assembler);
}


bool Intrinsifier::Integer_shl(Assembler* assembler) {
  ASSERT(kSmiTagShift == 1);
  ASSERT(kSmiTag == 0);
  Label fall_through, overflow;
  TestBothArgumentsSmis(assembler, &fall_through);
  // Shift value is in RAX. Compare with tagged Smi.
  __ cmpq(RAX, Immediate(Smi::RawValue(Smi::kBits)));
  __ j(ABOVE_EQUAL, &fall_through, Assembler::kNearJump);

  __ SmiUntag(RAX);
  __ movq(RCX, RAX);  // Shift amount must be in RCX.
  __ movq(RAX, Address(RSP, + 2 * kWordSize));  // Value.

  // Overflow test - all the shifted-out bits must be same as the sign bit.
  __ movq(RDI, RAX);
  __ shlq(RAX, RCX);
  __ sarq(RAX, RCX);
  __ cmpq(RAX, RDI);
  __ j(NOT_EQUAL, &overflow, Assembler::kNearJump);

  __ shlq(RAX, RCX);  // Shift for result now we know there is no overflow.

  // RAX is a correctly tagged Smi.
  __ ret();

  __ Bind(&overflow);
  // Mint is rarely used on x64 (only for integers requiring 64 bit instead of
  // 63 bits as represented by Smi).
  __ Bind(&fall_through);
  return false;
}


static bool CompareIntegers(Assembler* assembler, Condition true_condition) {
  Label fall_through, true_label;
  TestBothArgumentsSmis(assembler, &fall_through);
  // RAX contains the right argument.
  __ cmpq(Address(RSP, + 2 * kWordSize), RAX);
  __ j(true_condition, &true_label, Assembler::kNearJump);
  __ LoadObject(RAX, Bool::False());
  __ ret();
  __ Bind(&true_label);
  __ LoadObject(RAX, Bool::True());
  __ ret();
  __ Bind(&fall_through);
  return false;
}



bool Intrinsifier::Integer_lessThan(Assembler* assembler) {
  return CompareIntegers(assembler, LESS);
}


bool Intrinsifier::Integer_greaterThanFromInt(Assembler* assembler) {
  return CompareIntegers(assembler, LESS);
}


bool Intrinsifier::Integer_greaterThan(Assembler* assembler) {
  return CompareIntegers(assembler, GREATER);
}


bool Intrinsifier::Integer_lessEqualThan(Assembler* assembler) {
  return CompareIntegers(assembler, LESS_EQUAL);
}


bool Intrinsifier::Integer_greaterEqualThan(Assembler* assembler) {
  return CompareIntegers(assembler, GREATER_EQUAL);
}


// This is called for Smi, Mint and Bigint receivers. The right argument
// can be Smi, Mint, Bigint or double.
bool Intrinsifier::Integer_equalToInteger(Assembler* assembler) {
  Label fall_through, true_label, check_for_mint;
  // For integer receiver '===' check first.
  __ movq(RAX, Address(RSP, + 1 * kWordSize));
  __ movq(RCX, Address(RSP, + 2 * kWordSize));
  __ cmpq(RAX, RCX);
  __ j(EQUAL, &true_label, Assembler::kNearJump);
  __ orq(RAX, RCX);
  __ testq(RAX, Immediate(kSmiTagMask));
  __ j(NOT_ZERO, &check_for_mint, Assembler::kNearJump);
  // Both arguments are smi, '===' is good enough.
  __ LoadObject(RAX, Bool::False());
  __ ret();
  __ Bind(&true_label);
  __ LoadObject(RAX, Bool::True());
  __ ret();

  // At least one of the arguments was not Smi.
  Label receiver_not_smi;
  __ Bind(&check_for_mint);
  __ movq(RAX, Address(RSP, + 2 * kWordSize));  // Receiver.
  __ testq(RAX, Immediate(kSmiTagMask));
  __ j(NOT_ZERO, &receiver_not_smi);

  // Left (receiver) is Smi, return false if right is not Double.
  // Note that an instance of Mint or Bigint never contains a value that can be
  // represented by Smi.
  __ movq(RAX, Address(RSP, + 1 * kWordSize));
  __ CompareClassId(RAX, kDoubleCid);
  __ j(EQUAL, &fall_through);
  __ LoadObject(RAX, Bool::False());
  __ ret();

  __ Bind(&receiver_not_smi);
  // RAX:: receiver.
  __ CompareClassId(RAX, kMintCid);
  __ j(NOT_EQUAL, &fall_through);
  // Receiver is Mint, return false if right is Smi.
  __ movq(RAX, Address(RSP, + 1 * kWordSize));  // Right argument.
  __ testq(RAX, Immediate(kSmiTagMask));
  __ j(NOT_ZERO, &fall_through);
  __ LoadObject(RAX, Bool::False());  // Smi == Mint -> false.
  __ ret();
  // TODO(srdjan): Implement Mint == Mint comparison.

  __ Bind(&fall_through);
  return false;
}


bool Intrinsifier::Integer_equal(Assembler* assembler) {
  return Integer_equalToInteger(assembler);
}


bool Intrinsifier::Integer_sar(Assembler* assembler) {
  Label fall_through, shift_count_ok;
  TestBothArgumentsSmis(assembler, &fall_through);
  const Immediate& count_limit = Immediate(0x3F);
  // Check that the count is not larger than what the hardware can handle.
  // For shifting right a Smi the result is the same for all numbers
  // >= count_limit.
  __ SmiUntag(RAX);
  // Negative counts throw exception.
  __ cmpq(RAX, Immediate(0));
  __ j(LESS, &fall_through, Assembler::kNearJump);
  __ cmpq(RAX, count_limit);
  __ j(LESS_EQUAL, &shift_count_ok, Assembler::kNearJump);
  __ movq(RAX, count_limit);
  __ Bind(&shift_count_ok);
  __ movq(RCX, RAX);  // Shift amount must be in RCX.
  __ movq(RAX, Address(RSP, + 2 * kWordSize));  // Value.
  __ SmiUntag(RAX);  // Value.
  __ sarq(RAX, RCX);
  __ SmiTag(RAX);
  __ ret();
  __ Bind(&fall_through);
  return false;
}


// Argument is Smi (receiver).
bool Intrinsifier::Smi_bitNegate(Assembler* assembler) {
  __ movq(RAX, Address(RSP, + 1 * kWordSize));  // Index.
  __ notq(RAX);
  __ andq(RAX, Immediate(~kSmiTagMask));  // Remove inverted smi-tag.
  __ ret();
  return true;
}


// Check if the last argument is a double, jump to label 'is_smi' if smi
// (easy to convert to double), otherwise jump to label 'not_double_smi',
// Returns the last argument in RAX.
static void TestLastArgumentIsDouble(Assembler* assembler,
                                     Label* is_smi,
                                     Label* not_double_smi) {
  __ movq(RAX, Address(RSP, + 1 * kWordSize));
  __ testq(RAX, Immediate(kSmiTagMask));
  __ j(ZERO, is_smi, Assembler::kNearJump);  // Jump if Smi.
  __ CompareClassId(RAX, kDoubleCid);
  __ j(NOT_EQUAL, not_double_smi, Assembler::kNearJump);
  // Fall through if double.
}


// Both arguments on stack, left argument is a double, right argument is of
// unknown type. Return true or false object in RAX. Any NaN argument
// returns false. Any non-double argument causes control flow to fall through
// to the slow case (compiled method body).
static bool CompareDoubles(Assembler* assembler, Condition true_condition) {
  Label fall_through, is_false, is_true, is_smi, double_op;
  TestLastArgumentIsDouble(assembler, &is_smi, &fall_through);
  // Both arguments are double, right operand is in RAX.
  __ movsd(XMM1, FieldAddress(RAX, Double::value_offset()));
  __ Bind(&double_op);
  __ movq(RAX, Address(RSP, + 2 * kWordSize));  // Left argument.
  __ movsd(XMM0, FieldAddress(RAX, Double::value_offset()));
  __ comisd(XMM0, XMM1);
  __ j(PARITY_EVEN, &is_false, Assembler::kNearJump);  // NaN -> false;
  __ j(true_condition, &is_true, Assembler::kNearJump);
  // Fall through false.
  __ Bind(&is_false);
  __ LoadObject(RAX, Bool::False());
  __ ret();
  __ Bind(&is_true);
  __ LoadObject(RAX, Bool::True());
  __ ret();
  __ Bind(&is_smi);
  __ SmiUntag(RAX);
  __ cvtsi2sd(XMM1, RAX);
  __ jmp(&double_op);
  __ Bind(&fall_through);
  return false;
}


bool Intrinsifier::Double_greaterThan(Assembler* assembler) {
  return CompareDoubles(assembler, ABOVE);
}


bool Intrinsifier::Double_greaterEqualThan(Assembler* assembler) {
  return CompareDoubles(assembler, ABOVE_EQUAL);
}


bool Intrinsifier::Double_lessThan(Assembler* assembler) {
  return CompareDoubles(assembler, BELOW);
}


bool Intrinsifier::Double_equal(Assembler* assembler) {
  return CompareDoubles(assembler, EQUAL);
}


bool Intrinsifier::Double_lessEqualThan(Assembler* assembler) {
  return CompareDoubles(assembler, BELOW_EQUAL);
}


// Expects left argument to be double (receiver). Right argument is unknown.
// Both arguments are on stack.
static bool DoubleArithmeticOperations(Assembler* assembler, Token::Kind kind) {
  Label fall_through;
  TestLastArgumentIsDouble(assembler, &fall_through, &fall_through);
  // Both arguments are double, right operand is in RAX.
  __ movsd(XMM1, FieldAddress(RAX, Double::value_offset()));
  __ movq(RAX, Address(RSP, + 2 * kWordSize));  // Left argument.
  __ movsd(XMM0, FieldAddress(RAX, Double::value_offset()));
  switch (kind) {
    case Token::kADD: __ addsd(XMM0, XMM1); break;
    case Token::kSUB: __ subsd(XMM0, XMM1); break;
    case Token::kMUL: __ mulsd(XMM0, XMM1); break;
    case Token::kDIV: __ divsd(XMM0, XMM1); break;
    default: UNREACHABLE();
  }
  const Class& double_class = Class::Handle(
      Isolate::Current()->object_store()->double_class());
  __ TryAllocate(double_class,
                 &fall_through,
                 Assembler::kNearJump,
                 RAX);  // Result register.
  __ movsd(FieldAddress(RAX, Double::value_offset()), XMM0);
  __ ret();
  __ Bind(&fall_through);
  return false;
}


bool Intrinsifier::Double_add(Assembler* assembler) {
  return DoubleArithmeticOperations(assembler, Token::kADD);
}


bool Intrinsifier::Double_mul(Assembler* assembler) {
  return DoubleArithmeticOperations(assembler, Token::kMUL);
}


bool Intrinsifier::Double_sub(Assembler* assembler) {
  return DoubleArithmeticOperations(assembler, Token::kSUB);
}


bool Intrinsifier::Double_div(Assembler* assembler) {
  return DoubleArithmeticOperations(assembler, Token::kDIV);
}


bool Intrinsifier::Double_mulFromInteger(Assembler* assembler) {
  Label fall_through;
  // Only Smi-s allowed.
  __ movq(RAX, Address(RSP, + 1 * kWordSize));
  __ testq(RAX, Immediate(kSmiTagMask));
  __ j(NOT_ZERO, &fall_through, Assembler::kNearJump);
  // Is Smi.
  __ SmiUntag(RAX);
  __ cvtsi2sd(XMM1, RAX);
  __ movq(RAX, Address(RSP, + 2 * kWordSize));
  __ movsd(XMM0, FieldAddress(RAX, Double::value_offset()));
  __ mulsd(XMM0, XMM1);
  const Class& double_class = Class::Handle(
      Isolate::Current()->object_store()->double_class());
  __ TryAllocate(double_class,
                 &fall_through,
                 Assembler::kNearJump,
                 RAX);  // Result register.
  __ movsd(FieldAddress(RAX, Double::value_offset()), XMM0);
  __ ret();
  __ Bind(&fall_through);
  return false;
}


// Left is double right is integer (Bigint, Mint or Smi)
bool Intrinsifier::Double_fromInteger(Assembler* assembler) {
  Label fall_through;
  __ movq(RAX, Address(RSP, +1 * kWordSize));
  __ testq(RAX, Immediate(kSmiTagMask));
  __ j(NOT_ZERO, &fall_through, Assembler::kNearJump);
  // Is Smi.
  __ SmiUntag(RAX);
  __ cvtsi2sd(XMM0, RAX);
  const Class& double_class = Class::Handle(
      Isolate::Current()->object_store()->double_class());
  __ TryAllocate(double_class,
                 &fall_through,
                 Assembler::kNearJump,
                 RAX);  // Result register.
  __ movsd(FieldAddress(RAX, Double::value_offset()), XMM0);
  __ ret();
  __ Bind(&fall_through);
  return false;
}


bool Intrinsifier::Double_getIsNaN(Assembler* assembler) {
  Label is_true;
  __ movq(RAX, Address(RSP, +1 * kWordSize));
  __ movsd(XMM0, FieldAddress(RAX, Double::value_offset()));
  __ comisd(XMM0, XMM0);
  __ j(PARITY_EVEN, &is_true, Assembler::kNearJump);  // NaN -> true;
  __ LoadObject(RAX, Bool::False());
  __ ret();
  __ Bind(&is_true);
  __ LoadObject(RAX, Bool::True());
  __ ret();
  return true;  // Method is complete, no slow case.
}


bool Intrinsifier::Double_getIsNegative(Assembler* assembler) {
  Label is_false, is_true, is_zero;
  __ movq(RAX, Address(RSP, +1 * kWordSize));
  __ movsd(XMM0, FieldAddress(RAX, Double::value_offset()));
  __ xorpd(XMM1, XMM1);  // 0.0 -> XMM1.
  __ comisd(XMM0, XMM1);
  __ j(PARITY_EVEN, &is_false, Assembler::kNearJump);  // NaN -> false.
  __ j(EQUAL, &is_zero, Assembler::kNearJump);  // Check for negative zero.
  __ j(ABOVE_EQUAL, &is_false, Assembler::kNearJump);  // >= 0 -> false.
  __ Bind(&is_true);
  __ LoadObject(RAX, Bool::True());
  __ ret();
  __ Bind(&is_false);
  __ LoadObject(RAX, Bool::False());
  __ ret();
  __ Bind(&is_zero);
  // Check for negative zero (get the sign bit).
  __ movmskpd(RAX, XMM0);
  __ testq(RAX, Immediate(1));
  __ j(NOT_ZERO, &is_true, Assembler::kNearJump);
  __ jmp(&is_false, Assembler::kNearJump);
  return true;  // Method is complete, no slow case.
}


enum TrigonometricFunctions {
  kSine,
  kCosine,
};


static void EmitTrigonometric(Assembler* assembler,
                              TrigonometricFunctions kind) {
  Label fall_through, is_smi, double_op;
  TestLastArgumentIsDouble(assembler, &is_smi, &fall_through);
  // Argument is double and is in EAX.
  __ fldl(FieldAddress(RAX, Double::value_offset()));
  __ Bind(&double_op);
  switch (kind) {
    case kSine:   __ fsin(); break;
    case kCosine: __ fcos(); break;
    default:
      UNREACHABLE();
  }
  const Class& double_class = Class::Handle(
      Isolate::Current()->object_store()->double_class());
  Label alloc_failed;
  __ TryAllocate(double_class,
                 &alloc_failed,
                 Assembler::kNearJump,
                 RAX);  // Result register.
  __ fstpl(FieldAddress(RAX, Double::value_offset()));
  __ ret();

  __ Bind(&is_smi);  // smi -> double.
  __ SmiUntag(RAX);
  __ pushq(RAX);
  __ fildl(Address(RSP, 0));
  __ popq(RAX);
  __ jmp(&double_op);

  __ Bind(&alloc_failed);
  __ ffree(0);
  __ fincstp();

  __ Bind(&fall_through);
}


bool Intrinsifier::Double_toInt(Assembler* assembler) {
  __ movq(RAX, Address(RSP, +1 * kWordSize));
  __ movsd(XMM0, FieldAddress(RAX, Double::value_offset()));
  __ cvttsd2siq(RAX, XMM0);
  // Overflow is signalled with minint.
  Label fall_through;
  // Check for overflow and that it fits into Smi.
  __ movq(RCX, RAX);
  __ shlq(RCX, Immediate(1));
  __ j(OVERFLOW, &fall_through, Assembler::kNearJump);
  __ SmiTag(RAX);
  __ ret();
  __ Bind(&fall_through);
  return false;
}


bool Intrinsifier::Math_sqrt(Assembler* assembler) {
  Label fall_through, is_smi, double_op;
  TestLastArgumentIsDouble(assembler, &is_smi, &fall_through);
  // Argument is double and is in RAX.
  __ movsd(XMM1, FieldAddress(RAX, Double::value_offset()));
  __ Bind(&double_op);
  __ sqrtsd(XMM0, XMM1);
  const Class& double_class = Class::Handle(
      Isolate::Current()->object_store()->double_class());
  __ TryAllocate(double_class,
                 &fall_through,
                 Assembler::kNearJump,
                 RAX);  // Result register.
  __ movsd(FieldAddress(RAX, Double::value_offset()), XMM0);
  __ ret();
  __ Bind(&is_smi);
  __ SmiUntag(RAX);
  __ cvtsi2sd(XMM1, RAX);
  __ jmp(&double_op);
  __ Bind(&fall_through);
  return false;
}


bool Intrinsifier::Math_sin(Assembler* assembler) {
  EmitTrigonometric(assembler, kSine);
  return false;  // Compile method for slow case.
}


bool Intrinsifier::Math_cos(Assembler* assembler) {
  EmitTrigonometric(assembler, kCosine);
  return false;  // Compile method for slow case.
}


// Identity comparison.
bool Intrinsifier::Object_equal(Assembler* assembler) {
  Label is_true;
  __ movq(RAX, Address(RSP, + 1 * kWordSize));
  __ cmpq(RAX, Address(RSP, + 2 * kWordSize));
  __ j(EQUAL, &is_true, Assembler::kNearJump);
  __ LoadObject(RAX, Bool::False());
  __ ret();
  __ Bind(&is_true);
  __ LoadObject(RAX, Bool::True());
  __ ret();
  return true;
}


bool Intrinsifier::String_getHashCode(Assembler* assembler) {
  Label fall_through;
  __ movq(RAX, Address(RSP, + 1 * kWordSize));  // String object.
  __ movq(RAX, FieldAddress(RAX, String::hash_offset()));
  __ cmpq(RAX, Immediate(0));
  __ j(EQUAL, &fall_through, Assembler::kNearJump);
  __ ret();
  __ Bind(&fall_through);
  // Hash not yet computed.
  return false;
}


bool Intrinsifier::String_getLength(Assembler* assembler) {
  __ movq(RAX, Address(RSP, + 1 * kWordSize));  // String object.
  __ movq(RAX, FieldAddress(RAX, String::length_offset()));
  __ ret();
  return true;
}


// TODO(srdjan): Implement for two and four byte strings as well.
bool Intrinsifier::String_codeUnitAt(Assembler* assembler) {
  Label fall_through;
  __ movq(RCX, Address(RSP, + 1 * kWordSize));  // Index.
  __ movq(RAX, Address(RSP, + 2 * kWordSize));  // String.
  __ testq(RCX, Immediate(kSmiTagMask));
  __ j(NOT_ZERO, &fall_through, Assembler::kNearJump);  // Non-smi index.
  // Range check.
  __ cmpq(RCX, FieldAddress(RAX, String::length_offset()));
  // Runtime throws exception.
  __ j(ABOVE_EQUAL, &fall_through, Assembler::kNearJump);
  __ CompareClassId(RAX, kOneByteStringCid);
  __ j(NOT_EQUAL, &fall_through);
  __ SmiUntag(RCX);
  __ movzxb(RAX, FieldAddress(RAX, RCX, TIMES_1, OneByteString::data_offset()));
  __ SmiTag(RAX);
  __ ret();
  __ Bind(&fall_through);
  return false;
}


bool Intrinsifier::String_getIsEmpty(Assembler* assembler) {
  Label is_true;
  // Get length.
  __ movq(RAX, Address(RSP, + 1 * kWordSize));  // String object.
  __ movq(RAX, FieldAddress(RAX, String::length_offset()));
  __ cmpq(RAX, Immediate(Smi::RawValue(0)));
  __ j(EQUAL, &is_true, Assembler::kNearJump);
  __ LoadObject(RAX, Bool::False());
  __ ret();
  __ Bind(&is_true);
  __ LoadObject(RAX, Bool::True());
  __ ret();
  return true;
}


bool Intrinsifier::OneByteString_getHashCode(Assembler* assembler) {
  Label compute_hash;
  __ movq(RBX, Address(RSP, + 1 * kWordSize));  // OneByteString object.
  __ movq(RAX, FieldAddress(RBX, String::hash_offset()));
  __ cmpq(RAX, Immediate(0));
  __ j(EQUAL, &compute_hash, Assembler::kNearJump);
  __ ret();

  __ Bind(&compute_hash);
  // Hash not yet computed, use algorithm of class StringHasher.
  __ movq(RCX, FieldAddress(RBX, String::length_offset()));
  __ SmiUntag(RCX);
  __ xorq(RAX, RAX);
  __ xorq(RDI, RDI);
  // RBX: Instance of OneByteString.
  // RCX: String length, untagged integer.
  // RDI: Loop counter, untagged integer.
  // RAX: Hash code, untagged integer.
  Label loop, done, set_hash_code;
  __ Bind(&loop);
  __ cmpq(RDI, RCX);
  __ j(EQUAL, &done, Assembler::kNearJump);
  // Add to hash code: (hash_ is uint32)
  // hash_ += ch;
  // hash_ += hash_ << 10;
  // hash_ ^= hash_ >> 6;
  // Get one characters (ch).
  __ movzxb(RDX, FieldAddress(RBX, RDI, TIMES_1, OneByteString::data_offset()));
  // RDX: ch and temporary.
  __ addl(RAX, RDX);
  __ movq(RDX, RAX);
  __ shll(RDX, Immediate(10));
  __ addl(RAX, RDX);
  __ movq(RDX, RAX);
  __ shrl(RDX, Immediate(6));
  __ xorl(RAX, RDX);

  __ incq(RDI);
  __ jmp(&loop, Assembler::kNearJump);

  __ Bind(&done);
  // Finalize:
  // hash_ += hash_ << 3;
  // hash_ ^= hash_ >> 11;
  // hash_ += hash_ << 15;
  __ movq(RDX, RAX);
  __ shll(RDX, Immediate(3));
  __ addl(RAX, RDX);
  __ movq(RDX, RAX);
  __ shrl(RDX, Immediate(11));
  __ xorl(RAX, RDX);
  __ movq(RDX, RAX);
  __ shll(RDX, Immediate(15));
  __ addl(RAX, RDX);
  // hash_ = hash_ & ((static_cast<intptr_t>(1) << bits) - 1);
  __ andl(RAX,
      Immediate(((static_cast<intptr_t>(1) << String::kHashBits) - 1)));

  // return hash_ == 0 ? 1 : hash_;
  __ cmpq(RAX, Immediate(0));
  __ j(NOT_EQUAL, &set_hash_code, Assembler::kNearJump);
  __ incq(RAX);
  __ Bind(&set_hash_code);
  __ SmiTag(RAX);
  __ movq(FieldAddress(RBX, String::hash_offset()), RAX);
  __ ret();
  return true;
}


// Allocates one-byte string of length 'end - start'. The content is not
// initialized.
static void TryAllocateOnebyteString(Assembler* assembler,
                                     Label* failure,
                                     intptr_t start_index_offset,
                                     intptr_t end_index_offset) {
  __ movq(RDI, Address(RSP, + end_index_offset));
  __ subq(RDI, Address(RSP, + start_index_offset));
  const intptr_t fixed_size = sizeof(RawString) + kObjectAlignment - 1;
  __ SmiUntag(RDI);
  __ leaq(RDI, Address(RDI, TIMES_1, fixed_size));  // RDI is a Smi.
  __ andq(RDI, Immediate(-kObjectAlignment));

  Isolate* isolate = Isolate::Current();
  Heap* heap = isolate->heap();

  __ movq(RAX, Immediate(heap->TopAddress()));
  __ movq(RAX, Address(RAX, 0));

  // RDI: allocation size.
  __ movq(RCX, RAX);
  __ addq(RCX, RDI);
  __ j(CARRY, failure);

  // Check if the allocation fits into the remaining space.
  // RAX: potential new object start.
  // RCX: potential next object start.
  // RDI: allocation size.
  __ movq(R13, Immediate(heap->EndAddress()));
  __ cmpq(RCX, Address(R13, 0));
  __ j(ABOVE_EQUAL, failure);

  // Successfully allocated the object(s), now update top to point to
  // next object start and initialize the object.
  __ movq(R13, Immediate(heap->TopAddress()));
  __ movq(Address(R13, 0), RCX);
  __ addq(RAX, Immediate(kHeapObjectTag));

  // Initialize the tags.
  // RAX: new object start as a tagged pointer.
  // RDI: allocation size.
  {
    Label size_tag_overflow, done;
    __ cmpq(RDI, Immediate(RawObject::SizeTag::kMaxSizeTag));
    __ j(ABOVE, &size_tag_overflow, Assembler::kNearJump);
    __ shlq(RDI, Immediate(RawObject::kSizeTagBit - kObjectAlignmentLog2));
    __ jmp(&done, Assembler::kNearJump);

    __ Bind(&size_tag_overflow);
    __ xorq(RDI, RDI);
    __ Bind(&done);

    // Get the class index and insert it into the tags.
    const Class& cls =
        Class::Handle(isolate->object_store()->one_byte_string_class());
    __ orq(RDI, Immediate(RawObject::ClassIdTag::encode(cls.id())));
    __ movq(FieldAddress(RAX, String::tags_offset()), RDI);  // Tags.
  }

  // Set the length field.
  __ movq(RDI, Address(RSP, + end_index_offset));
  __ subq(RDI, Address(RSP, + start_index_offset));  // Length.
  __ StoreIntoObjectNoBarrier(RAX,
                              FieldAddress(RAX, String::length_offset()),
                              RDI);
  // Clear hash.
  __ movq(FieldAddress(RAX, String::hash_offset()), Immediate(0));
}


// Arg0: Onebyte String
// Arg1: Start index as Smi.
// Arg2: End index as Smi.
// The indexes must be valid.
bool Intrinsifier::OneByteString_substringUnchecked(Assembler* assembler) {
  const intptr_t kStringOffset = 3 * kWordSize;
  const intptr_t kStartIndexOffset = 2 * kWordSize;
  const intptr_t kEndIndexOffset = 1 * kWordSize;
  Label fall_through;
  TryAllocateOnebyteString(
      assembler, &fall_through, kStartIndexOffset, kEndIndexOffset);
  // RAX: new string as tagged pointer.
  // Copy string.
  __ movq(RSI, Address(RSP, + kStringOffset));
  __ movq(RBX, Address(RSP, + kStartIndexOffset));
  __ SmiUntag(RBX);
  __ leaq(RSI, FieldAddress(RSI, RBX, TIMES_1, OneByteString::data_offset()));
  // RSI: Start address to copy from (untagged).
  // RBX: Untagged start index.
  __ movq(RCX, Address(RSP, + kEndIndexOffset));
  __ SmiUntag(RCX);
  __ subq(RCX, RBX);
  __ xorq(RDX, RDX);
  // RSI: Start address to copy from (untagged).
  // RCX: Untagged number of bytes to copy.
  // RAX: Tagged result string
  // RDX: Loop counter.
  // RBX: Scratch register.
  Label loop, check;
  __ jmp(&check, Assembler::kNearJump);
  __ Bind(&loop);
  __ movzxb(RBX, Address(RSI, RDX, TIMES_1, 0));
  __ movb(FieldAddress(RAX, RDX, TIMES_1, OneByteString::data_offset()), RBX);
  __ incq(RDX);
  __ Bind(&check);
  __ cmpq(RDX, RCX);
  __ j(LESS, &loop, Assembler::kNearJump);
  __ ret();
  __ Bind(&fall_through);
  return false;
}


#undef __

}  // namespace dart

#endif  // defined TARGET_ARCH_X64
