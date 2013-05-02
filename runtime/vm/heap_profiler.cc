// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/heap_profiler.h"

#include "vm/dart_api_state.h"
#include "vm/object.h"
#include "vm/raw_object.h"
#include "vm/stack_frame.h"
#include "vm/unicode.h"

namespace dart {

HeapProfiler::Buffer::~Buffer() {
  delete[] data_;
}


void HeapProfiler::Buffer::Write(const uint8_t* data, intptr_t size) {
  EnsureCapacity(size);
  memmove(&data_[size_], data, size);
  size_ += size;
}


void HeapProfiler::Buffer::EnsureCapacity(intptr_t size) {
  if ((size + size_) > capacity_) {
    intptr_t new_capacity = Utils::RoundUpToPowerOfTwo(capacity_ + size);
    uint8_t* new_data = new uint8_t[new_capacity];
    memmove(new_data, data_, size_);
    capacity_ = new_capacity;
    data_ = new_data;
  }
}


void HeapProfiler::Record::Write(const uint8_t* value, intptr_t size) {
  body_.Write(value, size);
}


void HeapProfiler::Record::Write8(uint8_t value) {
  body_.Write(&value, sizeof(value));
}


void HeapProfiler::Record::Write16(uint16_t value) {
  value = htons(value);
  body_.Write(reinterpret_cast<uint8_t*>(&value), sizeof(value));
}


void HeapProfiler::Record::Write32(uint32_t value) {
  value = htonl(value);
  body_.Write(reinterpret_cast<uint8_t*>(&value), sizeof(value));
}


void HeapProfiler::Record::Write64(uint64_t value) {
  uint16_t x = 0xFF;
  if (*reinterpret_cast<uint8_t*>(&x) == 0xFF) {
    uint64_t hi = static_cast<uint64_t>(htonl(value & 0xFFFFFFFF)) << 32;
    uint64_t lo = htonl(value >> 32);
    value = hi | lo;
  }
  body_.Write(reinterpret_cast<uint8_t*>(&value), sizeof(value));
}


void HeapProfiler::Record::WriteObjectId(const void* value) {
  Write64(reinterpret_cast<uint64_t>(value));
}


HeapProfiler::SubRecord::SubRecord(uint8_t sub_tag, HeapProfiler* profiler)
    : record_(profiler->heap_dump_record_) {
  record_->Write8(sub_tag);
}


HeapProfiler::SubRecord::~SubRecord() {
}


void HeapProfiler::SubRecord::Write(const uint8_t* value, intptr_t size) {
  record_->Write(value, size);
}


void HeapProfiler::SubRecord::Write8(uint8_t value) {
  record_->Write8(value);
}


void HeapProfiler::SubRecord::Write16(uint16_t value) {
  record_->Write16(value);
}


void HeapProfiler::SubRecord::Write32(uint32_t value) {
  record_->Write32(value);
}


void HeapProfiler::SubRecord::Write64(uint64_t value) {
  record_->Write64(value);
}


void HeapProfiler::SubRecord::WriteObjectId(const void* value) {
  record_->WriteObjectId(value);
}


HeapProfiler::HeapProfiler(Dart_FileWriteCallback callback, void* stream)
    : write_callback_(callback),
      output_stream_(stream),
      heap_dump_record_(NULL) {
  WriteHeader();
  WriteStackTrace();
  WriteFakeLoadClass(kJavaLangClass, "java.lang.Class");
  WriteFakeLoadClass(kJavaLangClassLoader, "java.lang.ClassLoader");
  WriteFakeLoadClass(kJavaLangObject, "java.lang.Object");
  WriteFakeLoadClass(kJavaLangString, "java.lang.String");
  WriteFakeLoadClass(kArrayObject, "Object[]");
  WriteFakeLoadClass(kArrayBoolean, "bool[]");
  WriteFakeLoadClass(kArrayChar, "char[]");
  WriteFakeLoadClass(kArrayFloat, "float[]");
  WriteFakeLoadClass(kArrayDouble, "double[]");
  WriteFakeLoadClass(kArrayByte, "byte[]");
  WriteFakeLoadClass(kArrayShort, "short[]");
  WriteFakeLoadClass(kArrayInt, "int[]");
  WriteFakeLoadClass(kArrayLong, "long[]");
  heap_dump_record_ = new Record(kHeapDump, this);
  WriteFakeClassDump(kJavaLangClass, static_cast<FakeClass>(0));
  WriteFakeClassDump(kJavaLangClassLoader, kJavaLangObject);
  WriteFakeClassDump(kJavaLangObject, static_cast<FakeClass>(0));
  WriteFakeClassDump(kJavaLangString, kJavaLangObject);
}


HeapProfiler::~HeapProfiler() {
  for (std::set<const RawSmi*>::iterator it = smi_table_.begin();
       it != smi_table_.end();
       ++it) {
    WriteSmiInstanceDump(*it);
  }
  delete heap_dump_record_;
}


const RawObject* HeapProfiler::ObjectId(const RawObject* raw_obj) {
  if (!raw_obj->IsHeapObject()) {
    // To describe an immediate object in HPROF we record its value
    // and write fake INSTANCE_DUMP subrecord in the HEAP_DUMP record.
    const RawSmi* raw_smi = reinterpret_cast<const RawSmi*>(raw_obj);
    if (smi_table_.find(raw_smi) == smi_table_.end()) {
      smi_table_.insert(raw_smi);
    }
  } else if (raw_obj->GetClassId() == kNullCid) {
    // Instances of the Null type are translated to NULL so they can
    // be printed as "null" in HAT.
    return NULL;
  }
  return raw_obj;
}


const RawClass* HeapProfiler::ClassId(const RawClass* raw_class) {
  // A unique LOAD_CLASS record must be written for each class object.
  if (class_table_.find(raw_class) == class_table_.end()) {
    class_table_.insert(raw_class);
    WriteLoadClass(raw_class);
  }
  return raw_class;
}


// A built-in class may have its name encoded in a C-string.  These
// strings should only be found in class objects.  We emit a unique
// STRING_IN_UTF8 so HAT will properly display the class name.
const char* HeapProfiler::StringId(const char* c_string) {
  const RawString* ptr = reinterpret_cast<const RawString*>(c_string);
  if (string_table_.find(ptr) == string_table_.end()) {
    string_table_.insert(ptr);
    WriteStringInUtf8(c_string);
  }
  return c_string;
}


const RawString* HeapProfiler::StringId(const RawString* raw_string) {
  // A unique STRING_IN_UTF8 record must be written for each string
  // object.
  if (string_table_.find(raw_string) == string_table_.end()) {
    string_table_.insert(raw_string);
    WriteStringInUtf8(raw_string);
  }
  return raw_string;
}


const RawClass* HeapProfiler::GetClass(const RawObject* raw_obj) {
  return Isolate::Current()->class_table()->At(raw_obj->GetClassId());
}


const RawClass* HeapProfiler::GetSuperClass(const RawClass* raw_class) {
  ASSERT(raw_class != Class::null());
  const RawAbstractType* super_type = raw_class->ptr()->super_type_;
  if (super_type == AbstractType::null()) {
    return Class::null();
  }
  while (super_type->GetClassId() == kBoundedTypeCid) {
    super_type =
        reinterpret_cast<const RawBoundedType*>(super_type)->ptr()->type_;
  }
  ASSERT(super_type->GetClassId() == kTypeCid);
  return reinterpret_cast<const RawClass*>(
      reinterpret_cast<const RawType*>(super_type)->ptr()->type_class_);
}


void HeapProfiler::WriteRoot(const RawObject* raw_obj) {
  SubRecord sub(kRootUnknown, this);
  sub.WriteObjectId(ObjectId(raw_obj));
}


void HeapProfiler::WriteObject(const RawObject* raw_obj) {
  ASSERT(raw_obj->IsHeapObject());
  intptr_t class_id = raw_obj->GetClassId();
  switch (class_id) {
    case kFreeListElement: {
      // Free space has an object-like encoding.  Heap profiles only
      // care about live objects so we skip over these records.
      break;
    }
    case kClassCid: {
      const RawClass* raw_class = reinterpret_cast<const RawClass*>(raw_obj);
      if (raw_class->ptr()->id_ == kFreeListElement) {
        // Skip over the FreeListElement class.  This class exists to
        // describe free space.
        break;
      }
      WriteClassDump(raw_class);
      break;
    }
    case kArrayCid:
    case kImmutableArrayCid: {
      WriteObjectArrayDump(reinterpret_cast<const RawArray*>(raw_obj));
      break;
    }
    case kTypedDataInt8ArrayCid:
    case kTypedDataUint8ArrayCid:
    case kTypedDataUint8ClampedArrayCid: {
      const RawTypedData* raw_int8_array =
          reinterpret_cast<const RawTypedData*>(raw_obj);
      WritePrimitiveArrayDump(raw_int8_array,
                              kByte,
                              &raw_int8_array->data_[0]);
      break;
    }
    case kTypedDataInt16ArrayCid:
    case kTypedDataUint16ArrayCid: {
      const RawTypedData* raw_int16_array =
          reinterpret_cast<const RawTypedData*>(raw_obj);
      WritePrimitiveArrayDump(raw_int16_array,
                              kShort,
                              &raw_int16_array->data_[0]);
      break;
    }
    case kTypedDataInt32ArrayCid:
    case kTypedDataUint32ArrayCid: {
      const RawTypedData* raw_int32_array =
          reinterpret_cast<const RawTypedData*>(raw_obj);
      WritePrimitiveArrayDump(raw_int32_array,
                              kInt,
                              &raw_int32_array->data_[0]);
      break;
    }
    case kTypedDataInt64ArrayCid:
    case kTypedDataUint64ArrayCid: {
      const RawTypedData* raw_int64_array =
          reinterpret_cast<const RawTypedData*>(raw_obj);
      WritePrimitiveArrayDump(raw_int64_array,
                              kLong,
                              &raw_int64_array->data_[0]);
      break;
    }
    case kTypedDataFloat32ArrayCid: {
      const RawTypedData* raw_float32_array =
          reinterpret_cast<const RawTypedData*>(raw_obj);
      WritePrimitiveArrayDump(raw_float32_array,
                              kFloat,
                              &raw_float32_array->data_[0]);
      break;
    }
    case kTypedDataFloat64ArrayCid: {
      const RawTypedData* raw_float64_array =
          reinterpret_cast<const RawTypedData*>(raw_obj);
      WritePrimitiveArrayDump(raw_float64_array,
                              kDouble,
                              &raw_float64_array->data_[0]);
      break;
    }
    case kOneByteStringCid:
    case kTwoByteStringCid:
    case kExternalOneByteStringCid:
    case kExternalTwoByteStringCid: {
      WriteInstanceDump(StringId(reinterpret_cast<const RawString*>(raw_obj)));
      break;
    }
    default:
      WriteInstanceDump(raw_obj);
  }
}


void HeapProfiler::Write(const void* data, intptr_t size) {
  (*write_callback_)(data, size, output_stream_);
}


// Header
//
// Format:
//   [u1]* - format name
//   u4 - size of identifiers
//   u4 - high word of number of milliseconds since 0:00 GMT, 1/1/70
//   u4 - low word of number of milliseconds since 0:00 GMT, 1/1/70
void HeapProfiler::WriteHeader() {
  const char magic[] = "JAVA PROFILE 1.0.1";
  Write(magic, sizeof(magic));
  uint32_t size = htonl(kObjectIdSize);
  Write(&size, sizeof(size));
  uint64_t milliseconds = OS::GetCurrentTimeMillis();
  uint32_t hi = htonl(
      static_cast<uint32_t>((milliseconds >> 32) & 0x00000000FFFFFFFF));
  Write(&hi, sizeof(hi));
  uint32_t lo = htonl(
      static_cast<uint32_t>(milliseconds & 0x00000000FFFFFFFF));
  Write(&lo, sizeof(lo));
}


// Record
//
// Format:
//   u1 - TAG: denoting the type of the record
//   u4 - TIME: number of microseconds since the time stamp in the header
//   u4 - LENGTH: number of bytes that follow this u4 field and belong
//        to this record
//   [u1]* - BODY: as many bytes as specified in the above u4 field
void HeapProfiler::WriteRecord(const Record& record) {
  uint8_t tag = record.Tag();
  Write(&tag, sizeof(tag));
  uint32_t time = htonl(record.Time());
  Write(&time, sizeof(time));
  uint32_t length = htonl(record.Length());
  Write(&length, sizeof(length));
  Write(record.Body(), record.Length());
}


// STRING IN UTF8 - 0x01
//
// Format:
//   ID - ID for this string
//   [u1]* - UTF8 characters for string (NOT NULL terminated)
void HeapProfiler::WriteStringInUtf8(const RawString* raw_string) {
  intptr_t length = 0;
  char* characters = NULL;
  intptr_t class_id = raw_string->GetClassId();
  if (class_id == kOneByteStringCid) {
    const RawOneByteString* onestr =
        reinterpret_cast<const RawOneByteString*>(raw_string);
    for (intptr_t i = 0; i < Smi::Value(onestr->ptr()->length_); ++i) {
      length += Utf8::Length(onestr->ptr()->data_[i]);
    }
    characters = new char[length];
    for (intptr_t i = 0, j = 0; i < Smi::Value(onestr->ptr()->length_); ++i) {
      int32_t ch = onestr->ptr()->data_[i];
      j += Utf8::Encode(ch, &characters[j]);
    }
  } else {
    ASSERT(class_id == kTwoByteStringCid);
    const RawTwoByteString* twostr =
        reinterpret_cast<const RawTwoByteString*>(raw_string);
    for (intptr_t i = 0; i < Smi::Value(twostr->ptr()->length_); ++i) {
      length += Utf8::Length(twostr->ptr()->data_[i]);
    }
    characters = new char[length];
    for (intptr_t i = 0, j = 0; i < Smi::Value(twostr->ptr()->length_); ++i) {
      int32_t ch = twostr->ptr()->data_[i];
      j += Utf8::Encode(ch, &characters[j]);
    }
  }
  Record record(kStringInUtf8, this);
  record.WriteObjectId(ObjectId(raw_string));
  for (intptr_t i = 0; i < length; ++i) {
    record.Write8(characters[i]);
  }
  delete[] characters;
}


void HeapProfiler::WriteStringInUtf8(const char* c_string) {
  Record record(kStringInUtf8, this);
  record.WriteObjectId(c_string);
  for (; *c_string != '\0'; ++c_string) {
    record.Write8(*c_string);
  }
}


// LOAD CLASS - 0x02
//
// Format:
//   u4 - class serial number (always > 0)
//   ID - class object ID
//   u4 - stack trace serial number
//   ID - class name string ID
void HeapProfiler::WriteLoadClass(const RawClass* raw_class) {
  Record record(kLoadClass, this);
  // class serial number (always > 0)
  record.Write32(1);
  // class object ID
  record.WriteObjectId(raw_class);
  // stack trace serial number
  record.Write32(0);
  // class name string ID
  if (raw_class->ptr()->name_ != String::null()) {
    record.WriteObjectId(StringId(raw_class->ptr()->name_));
  } else {
    const char* format = "<an unnamed class with id %d>";
    intptr_t len = OS::SNPrint(NULL, 0, format, raw_class->ptr()->id_);
    char* str = new char[len + 1];
    OS::SNPrint(str, len + 1, format, raw_class->ptr()->id_);
    record.WriteObjectId(StringId(str));
    delete[] str;
  }
}


void HeapProfiler::WriteFakeLoadClass(FakeClass fake_class,
                                      const char* class_name) {
  Record record(kLoadClass, this);
  // class serial number (always > 0)
  record.Write32(1);
  // class object ID
  record.WriteObjectId(reinterpret_cast<void*>(fake_class));
  // stack trace serial number
  record.Write32(0);
  // class name string ID
  record.WriteObjectId(StringId(class_name));
}


// STACK TRACE - 0x05
//
//  u4 - stack trace serial number
//  u4 - thread serial number
//  u4 - number of frames
//  [ID]* - series of stack frame ID's
void HeapProfiler::WriteStackTrace() {
  Record record(kStackTrace, this);
  // stack trace serial number
  record.Write32(0);
  // thread serial number
  record.Write32(0);
  // number of frames
  record.Write32(0);
}


// HEAP SUMMARY - 0x07
//
// Format:
//   u4 - total live bytes
//   u4 - total live instances
//   u8 - total bytes allocated
//   u8 - total instances allocated
void HeapProfiler::WriteHeapSummary(uint32_t total_live_bytes,
                                   uint32_t total_live_instances,
                                   uint64_t total_bytes_allocated,
                                   uint64_t total_instances_allocated) {
  Record record(kHeapSummary, this);
  record.Write32(total_live_bytes);
  record.Write32(total_live_instances);
  record.Write32(total_bytes_allocated);
  record.Write32(total_instances_allocated);
}


// HEAP DUMP - 0x0C
//
// Format:
//  []*
void HeapProfiler::WriteHeapDump() {
  Record record(kHeapDump, this);
}


// CLASS DUMP - 0x20
//
// Format:
//  ID - class object ID
//  u4 - stack trace serial number
//  ID - super class object ID
//  ID - class loader object ID
//  ID - signers object ID
//  ID - protection domain object ID
//  ID - reserved
//  ID - reserved
//  u4 - instance size (in bytes)
//  u2 - size of constant pool and number of records that follow:
//  u2 - constant pool index
//  u1 - type of entry: (See Basic Type)
//  value - value of entry (u1, u2, u4, or u8 based on type of entry)
//  u2 - Number of static fields:
//  ID - static field name string ID
//  u1 - type of field: (See Basic Type)
//  value - value of entry (u1, u2, u4, or u8 based on type of field)
//  u2 - Number of instance fields (not including super class's)
//  ID - field name string ID
//  u1 - type of field: (See Basic Type)
void HeapProfiler::WriteClassDump(const RawClass* raw_class) {
  SubRecord sub(kClassDump, this);
  // class object ID
  sub.WriteObjectId(ClassId(raw_class));
  // stack trace serial number
  sub.Write32(0);
  // super class object ID
  const RawClass* super_class = GetSuperClass(raw_class);
  if (super_class == Class::null()) {
    sub.WriteObjectId(NULL);
  } else {
    sub.WriteObjectId(ClassId(super_class));
  }
  // class loader object ID
  sub.WriteObjectId(NULL);
  // signers object ID
  sub.WriteObjectId(NULL);
  // protection domain object ID
  sub.WriteObjectId(NULL);
  // reserved
  sub.WriteObjectId(NULL);
  // reserved
  sub.WriteObjectId(NULL);

  intptr_t num_static_fields = 0;
  intptr_t num_instance_fields = 0;

  RawArray* raw_array = raw_class->ptr()->fields_;
  if (raw_array != Array::null()) {
    for (intptr_t i = 0; i < Smi::Value(raw_array->ptr()->length_); ++i) {
      RawField* raw_field =
          reinterpret_cast<RawField*>(raw_array->ptr()->data()[i]);
      if (Field::StaticBit::decode(raw_field->ptr()->kind_bits_)) {
        ++num_static_fields;
      } else {
        ++num_instance_fields;
      }
    }
  }
  // instance size (in bytes)
  intptr_t instance_size_in_words = raw_class->ptr()->instance_size_in_words_;
  if (instance_size_in_words == 0) {
    // TODO(iposva): Better accounting of variable sized VM classes.
    instance_size_in_words = num_instance_fields;
  }
  sub.Write32(instance_size_in_words * kWordSize);
  // size of constant pool and number of records that follow:
  sub.Write16(0);
  // Number of static fields
  sub.Write16(num_static_fields);
  // Static fields:
  if (raw_array != Array::null()) {
    for (intptr_t i = 0; i < Smi::Value(raw_array->ptr()->length_); ++i) {
      RawField* raw_field =
          reinterpret_cast<RawField*>(raw_array->ptr()->data()[i]);
      if (Field::StaticBit::decode(raw_field->ptr()->kind_bits_)) {
        ASSERT(raw_field->ptr()->name_ != String::null());
        // static field name string ID
        sub.WriteObjectId(StringId(raw_field->ptr()->name_));
        // type of static field
        sub.Write8(kObject);
        // value of entry
        sub.WriteObjectId(ObjectId(raw_field->ptr()->value_));
      }
    }
  }
  // Number of instance fields (not include super class's)
  sub.Write16(num_instance_fields);
  // Instance fields:
  if (raw_array != Array::null()) {
    for (intptr_t i = 0; i < Smi::Value(raw_array->ptr()->length_); ++i) {
      RawField* raw_field =
          reinterpret_cast<RawField*>(raw_array->ptr()->data()[i]);
      if (!Field::StaticBit::decode(raw_field->ptr()->kind_bits_)) {
        ASSERT(raw_field->ptr()->name_ != String::null());
        // field name string ID
        sub.WriteObjectId(StringId(raw_field->ptr()->name_));
        // type of field
        sub.Write8(kObject);
      }
    }
  }
}

void HeapProfiler::WriteFakeClassDump(FakeClass fake_class,
                                      FakeClass fake_super_class) {
  SubRecord sub(kClassDump, this);
  // class object ID
  sub.WriteObjectId(reinterpret_cast<void*>(fake_class));
  // stack trace serial number
  sub.Write32(0);
  // super class object ID
  sub.WriteObjectId(reinterpret_cast<void*>(fake_super_class));
  // class loader object ID
  sub.WriteObjectId(NULL);
  // signers object ID
  sub.WriteObjectId(NULL);
  // protection domain object ID
  sub.WriteObjectId(NULL);
  // reserved
  sub.WriteObjectId(NULL);
  // reserved
  sub.WriteObjectId(NULL);
  // instance size (in bytes)
  sub.Write32(0);
  // size of constant pool and number of records that follow:
  sub.Write16(0);
  // Number of static fields
  sub.Write16(0);
  // Number of instance fields (not include super class's)
  sub.Write16(0);
}



// INSTANCE DUMP - 0x21
//
// Format:
//  ID - object ID
//  u4 - stack trace serial number
//  ID - class object ID
//  u4 - number of bytes that follow
//  [value]* - instance field values (this class, followed by super class, etc)
void HeapProfiler::WriteInstanceDump(const RawObject* raw_obj) {
  ASSERT(raw_obj->IsHeapObject());
  SubRecord sub(kInstanceDump, this);
  // object ID
  sub.WriteObjectId(raw_obj);
  // stack trace serial number
  sub.Write32(0);
  // class object ID
  sub.WriteObjectId(ClassId(GetClass(raw_obj)));
  // number of bytes that follow
  intptr_t num_instance_fields = 0;
  for (const RawClass* cls = GetClass(raw_obj);
       cls != Class::null();
       cls = GetSuperClass(cls)) {
    RawArray* raw_array = cls->ptr()->fields_;
    if (raw_array != Array::null()) {
      intptr_t length = Smi::Value(raw_array->ptr()->length_);
      for (intptr_t i = 0; i < length; ++i) {
        RawField* raw_field =
            reinterpret_cast<RawField*>(raw_array->ptr()->data()[i]);
        if (!Field::StaticBit::decode(raw_field->ptr()->kind_bits_)) {
          ++num_instance_fields;
        }
      }
    }
  }
  int64_t num_instance_bytes = num_instance_fields * kObjectIdSize;
  ASSERT(num_instance_bytes <= kMaxUint32);
  sub.Write32(num_instance_bytes);
  // instance field values (this class, followed by super class, etc)
  for (const RawClass* cls = GetClass(raw_obj);
       cls != Class::null();
       cls = GetSuperClass(cls)) {
    RawArray* raw_array = cls->ptr()->fields_;
    if (raw_array != Array::null()) {
      intptr_t length = Smi::Value(raw_array->ptr()->length_);
      uint8_t* base = reinterpret_cast<uint8_t*>(raw_obj->ptr());
      for (intptr_t i = 0; i < length; ++i) {
        RawField* raw_field =
            reinterpret_cast<RawField*>(raw_array->ptr()->data()[i]);
        if (!Field::StaticBit::decode(raw_field->ptr()->kind_bits_)) {
          intptr_t offset_in_words =
              Smi::Value(reinterpret_cast<RawSmi*>(raw_field->ptr()->value_));
          intptr_t offset = offset_in_words * kWordSize;
          RawObject* ptr = *reinterpret_cast<RawObject**>(base + offset);
          sub.WriteObjectId(ObjectId(ptr));
        }
      }
    }
  }
}


// Write a specialized instance dump for "referenced" Smi objects.
void HeapProfiler::WriteSmiInstanceDump(const RawSmi* raw_smi) {
  ASSERT(!raw_smi->IsHeapObject());
  SubRecord sub(kInstanceDump, this);
  // object ID
  sub.WriteObjectId(raw_smi);
  // stack trace serial number
  sub.Write32(0);
  // class object ID
  sub.WriteObjectId(Isolate::Current()->class_table()->At(kSmiCid));
  // number of bytes that follow
  sub.Write32(0);
}


// OBJECT ARRAY DUMP - 0x22
//
// Format:
//  ID - array object ID
//  u4 - stack trace serial number
//  u4 - number of elements
//  ID - array class object ID
//  [ID]* - elements
void HeapProfiler::WriteObjectArrayDump(const RawArray* raw_array) {
  SubRecord sub(kObjectArrayDump, this);
  // array object ID
  sub.WriteObjectId(raw_array);
  // stack trace serial number
  sub.Write32(0);
  // number of elements
  intptr_t length = Smi::Value(raw_array->ptr()->length_);
  sub.Write32(length);
  // array class object ID
  sub.WriteObjectId(reinterpret_cast<void*>(kArrayObject));
  // elements
  for (intptr_t i = 0; i < length; ++i) {
    sub.WriteObjectId(ObjectId(raw_array->ptr()->data()[i]));
  }
}


// PRIMITIVE ARRAY DUMP - 0x23
//
// Format:
//  ID - array object ID
//  u4 - stack trace serial number
//  u4 - number of elements
//  u1 - element type
//  [u1]* - elements
void HeapProfiler::WritePrimitiveArrayDump(const RawTypedData* raw_byte_array,
                                           uint8_t tag,
                                           const void* data) {
  SubRecord sub(kPrimitiveArrayDump, this);
  // array object ID
  sub.WriteObjectId(raw_byte_array);
  // stack trace serial number
  sub.Write32(0);
  // number of elements
  intptr_t length = Smi::Value(raw_byte_array->ptr()->length_);
  sub.Write32(length);
  // element type
  sub.Write8(tag);
  // elements (packed)
  for (intptr_t i = 0; i < length; ++i) {
    if (tag == kByte) {
      sub.Write8(reinterpret_cast<const int8_t*>(data)[i]);
    } else if (tag == kShort) {
      sub.Write16(reinterpret_cast<const int16_t*>(data)[i]);
      break;
    } else if (tag == kInt || tag == kFloat) {
      sub.Write32(reinterpret_cast<const int32_t*>(data)[i]);
    } else {
      ASSERT(tag == kLong || tag == kDouble);
      sub.Write64(reinterpret_cast<const int64_t*>(data)[i]);
    }
  }
}


void HeapProfilerRootVisitor::VisitPointers(RawObject** first,
                                           RawObject** last) {
  for (RawObject** current = first; current <= last; current++) {
    RawObject* raw_obj = *current;
    if (raw_obj->IsHeapObject()) {
      // Skip visits of FreeListElements.
      if (raw_obj->GetClassId() == kFreeListElement) {
        // Only the class of the free list element should ever be visited.
        ASSERT(first == last);
        return;
      }
      uword obj_addr = RawObject::ToAddr(raw_obj);
      if (!Isolate::Current()->heap()->Contains(obj_addr) &&
          !Dart::vm_isolate()->heap()->Contains(obj_addr)) {
        FATAL1("Invalid object pointer encountered %#"Px"\n", obj_addr);
      }
    }
    profiler_->WriteRoot(raw_obj);
  }
}


void HeapProfilerWeakRootVisitor::VisitHandle(uword addr) {
  FinalizablePersistentHandle* handle =
      reinterpret_cast<FinalizablePersistentHandle*>(addr);
  RawObject* raw_obj = handle->raw();
  visitor_->VisitPointer(&raw_obj);
}


void HeapProfilerObjectVisitor::VisitObject(RawObject* raw_obj) {
  profiler_->WriteObject(raw_obj);
}

}  // namespace dart
