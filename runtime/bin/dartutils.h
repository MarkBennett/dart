// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef BIN_DARTUTILS_H_
#define BIN_DARTUTILS_H_

#include "bin/builtin.h"
#include "bin/utils.h"
#include "include/dart_api.h"
#include "platform/globals.h"

// Forward declarations.
class File;

/* Handles error handles returned from Dart API functions.  If a value
 * is an error, uses Dart_PropagateError to throw it to the enclosing
 * Dart activation.  Otherwise, returns the original handle.
 *
 * This function can be used to wrap most API functions, but API
 * functions can also be nested without this error check, since all
 * API functions return any error handles passed in as arguments, unchanged.
 */
static inline Dart_Handle ThrowIfError(Dart_Handle handle) {
  if (Dart_IsError(handle)) Dart_PropagateError(handle);
  return handle;
}

class CommandLineOptions {
 public:
  explicit CommandLineOptions(int max_count)
      : count_(0), max_count_(max_count), arguments_(NULL) {
    static const int kWordSize = sizeof(intptr_t);
    arguments_ = reinterpret_cast<const char **>(malloc(max_count * kWordSize));
    if (arguments_ == NULL) {
      max_count_ = 0;
    }
  }
  ~CommandLineOptions() {
    free(arguments_);
    count_ = 0;
    max_count_ = 0;
    arguments_ = NULL;
  }

  int count() const { return count_; }
  const char** arguments() const { return arguments_; }

  const char* GetArgument(int index) const {
    return (index >= 0 && index < count_) ? arguments_[index] : NULL;
  }
  void AddArgument(const char* argument) {
    if (count_ < max_count_) {
      arguments_[count_] = argument;
      count_ += 1;
    } else {
      abort();  // We should never get into this situation.
    }
  }

  void operator delete(void* pointer) { abort(); }

 private:
  void* operator new(size_t size);

  int count_;
  int max_count_;
  const char** arguments_;

  DISALLOW_COPY_AND_ASSIGN(CommandLineOptions);
};


class DartUtils {
 public:
  // TODO(turnidge): Clean up the implementations of these so that
  // they allow for proper error propagation.

  // Assumes that the value object is known to be an integer object
  // that fits in a signed 64-bit integer.
  static int64_t GetIntegerValue(Dart_Handle value_obj);
  // Assumes that the value object is known to be an intptr_t. This should
  // only be known when the value has been put into Dart as a pointer encoded
  // in a 64-bit integer. This is the case for file and directory operations.
  static intptr_t GetIntptrValue(Dart_Handle value_obj);
  // Checks that the value object is an integer object that fits in a
  // signed 64-bit integer. If it is, the value is returned in the
  // value out parameter and true is returned. Otherwise, false is
  // returned.
  static bool GetInt64Value(Dart_Handle value_obj, int64_t* value);
  static const char* GetStringValue(Dart_Handle str_obj);
  static bool GetBooleanValue(Dart_Handle bool_obj);
  static void SetIntegerField(Dart_Handle handle,
                              const char* name,
                              intptr_t val);
  static intptr_t GetIntegerField(Dart_Handle handle,
                                  const char* name);
  static void SetStringField(Dart_Handle handle,
                             const char* name,
                             const char* val);
  static bool IsDartSchemeURL(const char* url_name);
  static bool IsDartExtensionSchemeURL(const char* url_name);
  static bool IsDartIOLibURL(const char* url_name);
  static bool IsDartBuiltinLibURL(const char* url_name);
  static Dart_Handle CanonicalizeURL(CommandLineOptions* url_mapping,
                                     Dart_Handle library,
                                     const char* url_str);
  static Dart_Handle ReadStringFromFile(const char* filename);
  static Dart_Handle LibraryTagHandler(Dart_LibraryTag tag,
                                       Dart_Handle library,
                                       Dart_Handle url);
  static Dart_Handle LoadScript(const char* script_uri,
                                Dart_Handle builtin_lib);
  static Dart_Handle LoadSource(CommandLineOptions* url_mapping,
                                Dart_Handle library,
                                Dart_Handle url,
                                Dart_LibraryTag tag,
                                const char* filename);
  static Dart_Handle PrepareForScriptLoading(const char* package_root,
                                             Dart_Handle builtin_lib);

  static bool PostNull(Dart_Port port_id);
  static bool PostInt32(Dart_Port port_id, int32_t value);

  static Dart_Handle GetDartClass(const char* library_url,
                                  const char* class_name);
  // Create a new Dart OSError object with the current OS error.
  static Dart_Handle NewDartOSError();
  // Create a new Dart OSError object with the provided OS error.
  static Dart_Handle NewDartOSError(OSError* os_error);
  static Dart_Handle NewDartSocketIOException(const char* message,
                                              Dart_Handle os_error);
  static Dart_Handle NewDartExceptionWithMessage(const char* library_url,
                                                 const char* exception_name,
                                                 const char* message);
  static Dart_Handle NewDartArgumentError(const char* message);

  // Create a new Dart String object from a C String.
  static Dart_Handle NewString(const char* str) {
    ASSERT(str != NULL);
    return Dart_NewStringFromUTF8(reinterpret_cast<const uint8_t*>(str),
                                  strlen(str));
  }

  // Create a new Dart InternalError object with the provided message.
  static Dart_Handle NewInternalError(const char* message);

  static void SetOriginalWorkingDirectory();

  static const char* MapLibraryUrl(CommandLineOptions* url_mapping,
                                   const char* url_string);

  static Dart_Handle ResolveScriptUri(Dart_Handle script_uri,
                                      Dart_Handle builtin_lib);

  static Dart_Handle FilePathFromUri(Dart_Handle script_uri,
                                     Dart_Handle builtin_lib);

  static Dart_Handle ResolveUri(Dart_Handle library_url,
                                Dart_Handle url,
                                Dart_Handle builtin_lib);

  // Sniffs the specified text_buffer to see if it contains the magic number
  // representing a script snapshot. If the text_buffer is a script snapshot
  // the return value is an updated pointer to the text_buffer pointing past
  // the magic number value. The 'buffer_len' parameter is also appropriately
  // adjusted.
  static const uint8_t* SniffForMagicNumber(const uint8_t* text_buffer,
                                            intptr_t* buffer_len,
                                            bool* is_snapshot);

  // Write a magic number to indicate a script snapshot file.
  static void WriteMagicNumber(File* file);

  // Global state that stores the original working directory..
  static const char* original_working_directory;

  static const char* kDartScheme;
  static const char* kDartExtensionScheme;
  static const char* kAsyncLibURL;
  static const char* kBuiltinLibURL;
  static const char* kCoreLibURL;
  static const char* kIOLibURL;
  static const char* kIOLibPatchURL;
  static const char* kUriLibURL;
  static const char* kUtfLibURL;
  static const char* kIsolateLibURL;
  static const char* kScalarlistLibURL;
  static const char* kWebLibURL;

  static const char* kIdFieldName;

  static uint8_t magic_number[];

 private:
  static const char* GetCanonicalPath(const char* reference_dir,
                                      const char* filename);

  DISALLOW_ALLOCATION();
  DISALLOW_IMPLICIT_CONSTRUCTORS(DartUtils);
};


class CObject {
 public:
  explicit CObject(Dart_CObject *cobject) : cobject_(cobject) {}
  Dart_CObject::Type type() { return cobject_->type; }
  Dart_CObject::TypedDataType byte_array_type() {
    ASSERT(type() == Dart_CObject::kTypedData ||
           type() == Dart_CObject::kExternalTypedData);
    return cobject_->value.as_typed_data.type;
  }

  bool IsNull() { return type() == Dart_CObject::kNull; }
  bool IsBool() { return type() == Dart_CObject::kBool; }
  bool IsInt32() { return type() == Dart_CObject::kInt32; }
  bool IsInt64() { return type() == Dart_CObject::kInt64; }
  bool IsInt32OrInt64() { return IsInt32() || IsInt64(); }
  bool IsIntptr() { return IsInt32OrInt64(); }
  bool IsBigint() { return type() == Dart_CObject::kBigint; }
  bool IsDouble() { return type() == Dart_CObject::kDouble; }
  bool IsString() { return type() == Dart_CObject::kString; }
  bool IsArray() { return type() == Dart_CObject::kArray; }
  bool IsTypedData() { return type() == Dart_CObject::kTypedData; }
  bool IsUint8Array() {
    return type() == Dart_CObject::kTypedData &&
           byte_array_type() == Dart_CObject::kUint8Array;
  }

  bool IsTrue() {
    return type() == Dart_CObject::kBool && cobject_->value.as_bool;
  }

  bool IsFalse() {
    return type() == Dart_CObject::kBool && !cobject_->value.as_bool;
  }

  void* operator new(size_t size) {
    return Dart_ScopeAllocate(size);
  }

  static CObject* Null();
  static CObject* True();
  static CObject* False();
  static CObject* Bool(bool value);
  static Dart_CObject* NewInt32(int32_t value);
  static Dart_CObject* NewInt64(int64_t value);
  static Dart_CObject* NewIntptr(intptr_t value);
  // TODO(sgjesse): Add support for kBigint.
  static Dart_CObject* NewDouble(double value);
  static Dart_CObject* NewString(int length);
  static Dart_CObject* NewString(const char* str);
  static Dart_CObject* NewArray(int length);
  static Dart_CObject* NewUint8Array(int length);
  static Dart_CObject* NewExternalUint8Array(
      int64_t length, uint8_t* data, void* peer,
      Dart_WeakPersistentHandleFinalizer callback);
  static Dart_CObject* NewIOBuffer(int64_t length);
  static void FreeIOBufferData(Dart_CObject* object);

  Dart_CObject* AsApiCObject() { return cobject_; }

  // Create a new CObject array with an illegal arguments error.
  static CObject* IllegalArgumentError();
  // Create a new CObject array with a file closed error.
  static CObject* FileClosedError();
  // Create a new CObject array with the current OS error.
  static CObject* NewOSError();
  // Create a new CObject array with the specified OS error.
  static CObject* NewOSError(OSError* os_error);

 protected:
  CObject() : cobject_(NULL) {}
  Dart_CObject* cobject_;

 private:
  static Dart_CObject* New(Dart_CObject::Type type, int additional_bytes = 0);

  static Dart_CObject api_null_;
  static Dart_CObject api_true_;
  static Dart_CObject api_false_;
  static CObject null_;
  static CObject true_;
  static CObject false_;

 private:
  DISALLOW_COPY_AND_ASSIGN(CObject);
};


#define DECLARE_COBJECT_CONSTRUCTORS(t)                                        \
  explicit CObject##t(Dart_CObject *cobject) : CObject(cobject) {              \
    ASSERT(type() == Dart_CObject::k##t);                                      \
    cobject_ = cobject;                                                        \
  }                                                                            \
  explicit CObject##t(CObject* cobject) : CObject() {                          \
    ASSERT(cobject != NULL);                                                   \
    ASSERT(cobject->type() == Dart_CObject::k##t);                             \
    cobject_ = cobject->AsApiCObject();                                        \
  }                                                                            \


#define DECLARE_COBJECT_TYPED_DATA_CONSTRUCTORS(t)                             \
  explicit CObject##t(Dart_CObject *cobject) : CObject(cobject) {              \
    ASSERT(type() == Dart_CObject::kTypedData);                                \
    ASSERT(byte_array_type() == Dart_CObject::k##t);                           \
    cobject_ = cobject;                                                        \
  }                                                                            \
  explicit CObject##t(CObject* cobject) : CObject() {                          \
    ASSERT(cobject != NULL);                                                   \
    ASSERT(cobject->type() == Dart_CObject::kTypedData);                       \
    ASSERT(cobject->byte_array_type() == Dart_CObject::k##t);                  \
    cobject_ = cobject->AsApiCObject();                                        \
  }                                                                            \


#define DECLARE_COBJECT_EXTERNAL_TYPED_DATA_CONSTRUCTORS(t)                    \
  explicit CObjectExternal##t(Dart_CObject *cobject) : CObject(cobject) {      \
    ASSERT(type() == Dart_CObject::kExternalTypedData);                        \
    ASSERT(byte_array_type() == Dart_CObject::k##t);                           \
    cobject_ = cobject;                                                        \
  }                                                                            \
  explicit CObjectExternal##t(CObject* cobject) : CObject() {                  \
    ASSERT(cobject != NULL);                                                   \
    ASSERT(cobject->type() == Dart_CObject::kExternalTypedData);               \
    ASSERT(cobject->byte_array_type() == Dart_CObject::k##t);                  \
    cobject_ = cobject->AsApiCObject();                                        \
  }                                                                            \


class CObjectBool : public CObject {
 public:
  DECLARE_COBJECT_CONSTRUCTORS(Bool)

  bool Value() const { return cobject_->value.as_bool; }

 private:
  DISALLOW_COPY_AND_ASSIGN(CObjectBool);
};


class CObjectInt32 : public CObject {
 public:
  DECLARE_COBJECT_CONSTRUCTORS(Int32)

  int32_t Value() const { return cobject_->value.as_int32; }

 private:
  DISALLOW_COPY_AND_ASSIGN(CObjectInt32);
};


class CObjectInt64 : public CObject {
 public:
  DECLARE_COBJECT_CONSTRUCTORS(Int64)

  int64_t Value() const { return cobject_->value.as_int64; }

 private:
  DISALLOW_COPY_AND_ASSIGN(CObjectInt64);
};


class CObjectIntptr : public CObject {
 public:
  explicit CObjectIntptr(Dart_CObject *cobject) : CObject(cobject) {
    ASSERT(type() == Dart_CObject::kInt32 || type() == Dart_CObject::kInt64);
    cobject_ = cobject;
  }
  explicit CObjectIntptr(CObject* cobject) : CObject() {
    ASSERT(cobject != NULL);
    ASSERT(cobject->type() == Dart_CObject::kInt64 ||
           cobject->type() == Dart_CObject::kInt32);
    cobject_ = cobject->AsApiCObject();
  }

  intptr_t Value()  {
    intptr_t result;
    if (type() == Dart_CObject::kInt32) {
      result = cobject_->value.as_int32;
    } else {
      ASSERT(sizeof(result) == 8);
      result = static_cast<intptr_t>(cobject_->value.as_int64);
    }
    return result;
  }

 private:
  DISALLOW_COPY_AND_ASSIGN(CObjectIntptr);
};


class CObjectBigint : public CObject {
 public:
  DECLARE_COBJECT_CONSTRUCTORS(Bigint)

  char* Value() const { return cobject_->value.as_bigint; }

 private:
  DISALLOW_COPY_AND_ASSIGN(CObjectBigint);
};


class CObjectDouble : public CObject {
 public:
  DECLARE_COBJECT_CONSTRUCTORS(Double)

  double Value() const { return cobject_->value.as_double; }

 private:
  DISALLOW_COPY_AND_ASSIGN(CObjectDouble);
};


class CObjectString : public CObject {
 public:
  DECLARE_COBJECT_CONSTRUCTORS(String)

  int Length() const { return strlen(cobject_->value.as_string); }
  char* CString() const { return cobject_->value.as_string; }

 private:
  DISALLOW_COPY_AND_ASSIGN(CObjectString);
};


class CObjectArray : public CObject {
 public:
  DECLARE_COBJECT_CONSTRUCTORS(Array)

  int Length() const { return cobject_->value.as_array.length; }
  CObject* operator[](int index) const {
    return new CObject(cobject_->value.as_array.values[index]);
  }
  void SetAt(int index, CObject* value) {
    cobject_->value.as_array.values[index] = value->AsApiCObject();
  }

 private:
  DISALLOW_COPY_AND_ASSIGN(CObjectArray);
};


class CObjectTypedData : public CObject {
 public:
  explicit CObjectTypedData(Dart_CObject *cobject) : CObject(cobject) {
    ASSERT(type() == Dart_CObject::kTypedData);
    cobject_ = cobject;
  }
  explicit CObjectTypedData(CObject* cobject) : CObject() {
    ASSERT(cobject != NULL);
    ASSERT(cobject->type() == Dart_CObject::kTypedData);
    cobject_ = cobject->AsApiCObject();
  }

  Dart_CObject::TypedDataType Type() const {
    return cobject_->value.as_typed_data.type;
  }
  int Length() const { return cobject_->value.as_typed_data.length; }
  uint8_t* Buffer() const { return cobject_->value.as_typed_data.values; }

 private:
  DISALLOW_COPY_AND_ASSIGN(CObjectTypedData);
};


class CObjectUint8Array : public CObject {
 public:
  DECLARE_COBJECT_TYPED_DATA_CONSTRUCTORS(Uint8Array)

  int Length() const { return cobject_->value.as_typed_data.length; }
  uint8_t* Buffer() const { return cobject_->value.as_typed_data.values; }

 private:
  DISALLOW_COPY_AND_ASSIGN(CObjectUint8Array);
};


class CObjectExternalUint8Array : public CObject {
 public:
  DECLARE_COBJECT_EXTERNAL_TYPED_DATA_CONSTRUCTORS(Uint8Array)

  int Length() const { return cobject_->value.as_external_typed_data.length; }
  void SetLength(uint64_t length) {
    cobject_->value.as_external_typed_data.length = length;
  }
  uint8_t* Data() const { return cobject_->value.as_external_typed_data.data; }
  void* Peer() const { return cobject_->value.as_external_typed_data.peer; }
  Dart_WeakPersistentHandleFinalizer Callback() const {
    return cobject_->value.as_external_typed_data.callback;
  }

 private:
  DISALLOW_COPY_AND_ASSIGN(CObjectExternalUint8Array);
};

#endif  // BIN_DARTUTILS_H_
