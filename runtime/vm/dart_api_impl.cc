// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "include/dart_api.h"

#include "platform/assert.h"
#include "vm/bigint_operations.h"
#include "vm/class_finalizer.h"
#include "vm/compiler.h"
#include "vm/dart.h"
#include "vm/dart_api_impl.h"
#include "vm/dart_api_message.h"
#include "vm/dart_api_state.h"
#include "vm/dart_entry.h"
#include "vm/debuginfo.h"
#include "vm/exceptions.h"
#include "vm/flags.h"
#include "vm/growable_array.h"
#include "vm/message.h"
#include "vm/native_entry.h"
#include "vm/native_message_handler.h"
#include "vm/object.h"
#include "vm/object_store.h"
#include "vm/port.h"
#include "vm/resolver.h"
#include "vm/stack_frame.h"
#include "vm/symbols.h"
#include "vm/timer.h"
#include "vm/unicode.h"
#include "vm/verifier.h"
#include "vm/version.h"

namespace dart {

DECLARE_FLAG(bool, print_class_table);

ThreadLocalKey Api::api_native_key_ = Thread::kUnsetThreadLocalKey;


const char* CanonicalFunction(const char* func) {
  if (strncmp(func, "dart::", 6) == 0) {
    return func + 6;
  } else {
    return func;
  }
}


#define RETURN_TYPE_ERROR(isolate, dart_handle, type)                          \
  do {                                                                         \
    const Object& tmp =                                                        \
        Object::Handle(isolate, Api::UnwrapHandle((dart_handle)));             \
    if (tmp.IsNull()) {                                                        \
      return Api::NewError("%s expects argument '%s' to be non-null.",         \
                           CURRENT_FUNC, #dart_handle);                        \
    } else if (tmp.IsError()) {                                                \
      return dart_handle;                                                      \
    } else {                                                                   \
      return Api::NewError("%s expects argument '%s' to be of type %s.",       \
                           CURRENT_FUNC, #dart_handle, #type);                 \
    }                                                                          \
  } while (0)


#define RETURN_NULL_ERROR(parameter)                                           \
  return Api::NewError("%s expects argument '%s' to be non-null.",             \
                       CURRENT_FUNC, #parameter);


#define CHECK_LENGTH(length, max_elements)                                     \
  do {                                                                         \
    intptr_t len = (length);                                                   \
    intptr_t max = (max_elements);                                             \
    if (len < 0 || len > max) {                                                \
      return Api::NewError(                                                    \
          "%s expects argument '%s' to be in the range [0..%"Pd"].",           \
          CURRENT_FUNC, #length, max);                                         \
    }                                                                          \
  } while (0)


Dart_Handle Api::NewHandle(Isolate* isolate, RawObject* raw) {
  LocalHandles* local_handles = Api::TopScope(isolate)->local_handles();
  ASSERT(local_handles != NULL);
  LocalHandle* ref = local_handles->AllocateHandle();
  ref->set_raw(raw);
  return reinterpret_cast<Dart_Handle>(ref);
}

RawObject* Api::UnwrapHandle(Dart_Handle object) {
#if defined(DEBUG)
  Isolate* isolate = Isolate::Current();
  ASSERT(isolate != NULL);
  ApiState* state = isolate->api_state();
  ASSERT(state != NULL);
  ASSERT(state->IsValidLocalHandle(object) ||
         state->IsValidPersistentHandle(object) ||
         state->IsValidWeakPersistentHandle(object) ||
         state->IsValidPrologueWeakPersistentHandle(object));
  ASSERT(FinalizablePersistentHandle::raw_offset() == 0 &&
         PersistentHandle::raw_offset() == 0 &&
         LocalHandle::raw_offset() == 0);
#endif
  return (reinterpret_cast<LocalHandle*>(object))->raw();
}

#define DEFINE_UNWRAP(type)                                                    \
  const type& Api::Unwrap##type##Handle(Isolate* iso,                          \
                                        Dart_Handle dart_handle) {             \
    const Object& obj = Object::Handle(iso, Api::UnwrapHandle(dart_handle));   \
    if (obj.Is##type()) {                                                      \
      return type::Cast(obj);                                                  \
    }                                                                          \
    return type::Handle(iso);                                                  \
  }
CLASS_LIST_FOR_HANDLES(DEFINE_UNWRAP)
#undef DEFINE_UNWRAP


LocalHandle* Api::UnwrapAsLocalHandle(const ApiState& state,
                                      Dart_Handle object) {
  ASSERT(state.IsValidLocalHandle(object));
  return reinterpret_cast<LocalHandle*>(object);
}


PersistentHandle* Api::UnwrapAsPersistentHandle(const ApiState& state,
                                                Dart_Handle object) {
  ASSERT(state.IsValidPersistentHandle(object));
  return reinterpret_cast<PersistentHandle*>(object);
}


FinalizablePersistentHandle* Api::UnwrapAsWeakPersistentHandle(
    const ApiState& state,
    Dart_Handle object) {
  ASSERT(state.IsValidWeakPersistentHandle(object));
  return reinterpret_cast<FinalizablePersistentHandle*>(object);
}


FinalizablePersistentHandle* Api::UnwrapAsPrologueWeakPersistentHandle(
    const ApiState& state,
    Dart_Handle object) {
  ASSERT(state.IsValidPrologueWeakPersistentHandle(object));
  return reinterpret_cast<FinalizablePersistentHandle*>(object);
}


Dart_Handle Api::CheckIsolateState(Isolate* isolate) {
  if (ClassFinalizer::FinalizePendingClasses() &&
      isolate->object_store()->PreallocateObjects()) {
    return Api::Success(isolate);
  }
  ASSERT(isolate->object_store()->sticky_error() != Object::null());
  return Api::NewHandle(isolate, isolate->object_store()->sticky_error());
}


Dart_Isolate Api::CastIsolate(Isolate* isolate) {
  return reinterpret_cast<Dart_Isolate>(isolate);
}


Dart_Handle Api::Success(Isolate* isolate) {
  ASSERT(isolate != NULL);
  ApiState* state = isolate->api_state();
  ASSERT(state != NULL);
  PersistentHandle* true_handle = state->True();
  return reinterpret_cast<Dart_Handle>(true_handle);
}


Dart_Handle Api::NewError(const char* format, ...) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  CHECK_CALLBACK_STATE(isolate);

  va_list args;
  va_start(args, format);
  intptr_t len = OS::VSNPrint(NULL, 0, format, args);
  va_end(args);

  char* buffer = isolate->current_zone()->Alloc<char>(len + 1);
  va_list args2;
  va_start(args2, format);
  OS::VSNPrint(buffer, (len + 1), format, args2);
  va_end(args2);

  const String& message = String::Handle(isolate, String::New(buffer));
  return Api::NewHandle(isolate, ApiError::New(message));
}


void Api::SetupAcquiredError(Isolate* isolate) {
  ASSERT(isolate != NULL);
  ApiState* state = isolate->api_state();
  ASSERT(state != NULL);
  state->SetupAcquiredError();
}


Dart_Handle Api::AcquiredError(Isolate* isolate) {
  ASSERT(isolate != NULL);
  ApiState* state = isolate->api_state();
  ASSERT(state != NULL);
  PersistentHandle* acquired_error_handle = state->AcquiredError();
  return reinterpret_cast<Dart_Handle>(acquired_error_handle);
}


Dart_Handle Api::Null(Isolate* isolate) {
  ASSERT(isolate != NULL);
  ApiState* state = isolate->api_state();
  ASSERT(state != NULL);
  PersistentHandle* null_handle = state->Null();
  return reinterpret_cast<Dart_Handle>(null_handle);
}


Dart_Handle Api::True(Isolate* isolate) {
  ASSERT(isolate != NULL);
  ApiState* state = isolate->api_state();
  ASSERT(state != NULL);
  PersistentHandle* true_handle = state->True();
  return reinterpret_cast<Dart_Handle>(true_handle);
}


Dart_Handle Api::False(Isolate* isolate) {
  ASSERT(isolate != NULL);
  ApiState* state = isolate->api_state();
  ASSERT(state != NULL);
  PersistentHandle* false_handle = state->False();
  return reinterpret_cast<Dart_Handle>(false_handle);
}


ApiLocalScope* Api::TopScope(Isolate* isolate) {
  ASSERT(isolate != NULL);
  ApiState* state = isolate->api_state();
  ASSERT(state != NULL);
  ApiLocalScope* scope = state->top_scope();
  ASSERT(scope != NULL);
  return scope;
}


void Api::InitOnce() {
  ASSERT(api_native_key_ == Thread::kUnsetThreadLocalKey);
  api_native_key_ = Thread::CreateThreadLocal();
  ASSERT(api_native_key_ != Thread::kUnsetThreadLocalKey);
}


bool Api::ExternalStringGetPeerHelper(Dart_Handle object, void** peer) {
  NoGCScope no_gc_scope;
  RawObject* raw_obj = Api::UnwrapHandle(object);
  switch (Api::ClassId(object)) {
    case kExternalOneByteStringCid: {
      RawExternalOneByteString* raw_string =
          reinterpret_cast<RawExternalOneByteString*>(raw_obj)->ptr();
      ExternalStringData<uint8_t>* data = raw_string->external_data_;
      *peer = data->peer();
      return true;
    }
    case kExternalTwoByteStringCid: {
      RawExternalTwoByteString* raw_string =
          reinterpret_cast<RawExternalTwoByteString*>(raw_obj)->ptr();
      ExternalStringData<uint16_t>* data = raw_string->external_data_;
      *peer = data->peer();
      return true;
    }
  }
  return false;
}


// When we want to return a handle to a type to the user, we handle
// class-types differently than some other types.
static Dart_Handle TypeToHandle(Isolate* isolate,
                                const char* function_name,
                                const AbstractType& type) {
  if (type.IsMalformed()) {
    const Error& error = Error::Handle(type.malformed_error());
    return Api::NewError("%s: malformed type encountered: %s.",
        function_name, error.ToErrorCString());
  } else if (type.HasResolvedTypeClass()) {
    const Class& cls = Class::Handle(isolate, type.type_class());
#if defined(DEBUG)
    const Library& lib = Library::Handle(cls.library());
    if (lib.IsNull()) {
      ASSERT(cls.IsDynamicClass() || cls.IsVoidClass());
    }
#endif
    return Api::NewHandle(isolate, cls.raw());
  } else if (type.IsTypeParameter()) {
    return Api::NewHandle(isolate, type.raw());
  } else {
    return Api::NewError("%s: unexpected type '%s' encountered.",
                         function_name, type.ToCString());
  }
}


// --- Handles ---


DART_EXPORT bool Dart_IsError(Dart_Handle handle) {
  return RawObject::IsErrorClassId(Api::ClassId(handle));
}


DART_EXPORT bool Dart_IsApiError(Dart_Handle object) {
  return Api::ClassId(object) == kApiErrorCid;
}


DART_EXPORT bool Dart_IsUnhandledExceptionError(Dart_Handle object) {
  return Api::ClassId(object) == kUnhandledExceptionCid;
}


DART_EXPORT bool Dart_IsCompilationError(Dart_Handle object) {
  return Api::ClassId(object) == kLanguageErrorCid;
}


DART_EXPORT bool Dart_IsFatalError(Dart_Handle object) {
  return Api::ClassId(object) == kUnwindErrorCid;
}


DART_EXPORT const char* Dart_GetError(Dart_Handle handle) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(handle));
  if (obj.IsError()) {
    const Error& error = Error::Cast(obj);
    const char* str = error.ToErrorCString();
    intptr_t len = strlen(str) + 1;
    char* str_copy = Api::TopScope(isolate)->zone()->Alloc<char>(len);
    strncpy(str_copy, str, len);
    // Strip a possible trailing '\n'.
    if ((len > 1) && (str_copy[len - 2] == '\n')) {
      str_copy[len - 2] = '\0';
    }
    return str_copy;
  } else {
    return "";
  }
}


DART_EXPORT bool Dart_ErrorHasException(Dart_Handle handle) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(handle));
  return obj.IsUnhandledException();
}


DART_EXPORT Dart_Handle Dart_ErrorGetException(Dart_Handle handle) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(handle));
  if (obj.IsUnhandledException()) {
    const UnhandledException& error = UnhandledException::Cast(obj);
    return Api::NewHandle(isolate, error.exception());
  } else if (obj.IsError()) {
    return Api::NewError("This error is not an unhandled exception error.");
  } else {
    return Api::NewError("Can only get exceptions from error handles.");
  }
}


DART_EXPORT Dart_Handle Dart_ErrorGetStacktrace(Dart_Handle handle) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(handle));
  if (obj.IsUnhandledException()) {
    const UnhandledException& error = UnhandledException::Cast(obj);
    return Api::NewHandle(isolate, error.stacktrace());
  } else if (obj.IsError()) {
    return Api::NewError("This error is not an unhandled exception error.");
  } else {
    return Api::NewError("Can only get stacktraces from error handles.");
  }
}


// Deprecated.
// TODO(turnidge): Remove all uses and delete.
DART_EXPORT Dart_Handle Dart_Error(const char* format, ...) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  CHECK_CALLBACK_STATE(isolate);

  va_list args;
  va_start(args, format);
  intptr_t len = OS::VSNPrint(NULL, 0, format, args);
  va_end(args);

  char* buffer = isolate->current_zone()->Alloc<char>(len + 1);
  va_list args2;
  va_start(args2, format);
  OS::VSNPrint(buffer, (len + 1), format, args2);
  va_end(args2);

  const String& message = String::Handle(isolate, String::New(buffer));
  return Api::NewHandle(isolate, ApiError::New(message));
}


// TODO(turnidge): This clones Api::NewError.  I need to use va_copy to
// fix this but not sure if it available on all of our builds.
DART_EXPORT Dart_Handle Dart_NewApiError(const char* format, ...) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  CHECK_CALLBACK_STATE(isolate);

  va_list args;
  va_start(args, format);
  intptr_t len = OS::VSNPrint(NULL, 0, format, args);
  va_end(args);

  char* buffer = isolate->current_zone()->Alloc<char>(len + 1);
  va_list args2;
  va_start(args2, format);
  OS::VSNPrint(buffer, (len + 1), format, args2);
  va_end(args2);

  const String& message = String::Handle(isolate, String::New(buffer));
  return Api::NewHandle(isolate, ApiError::New(message));
}


DART_EXPORT Dart_Handle Dart_NewUnhandledExceptionError(Dart_Handle exception) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  CHECK_CALLBACK_STATE(isolate);

  const Instance& obj = Api::UnwrapInstanceHandle(isolate, exception);
  if (obj.IsNull()) {
    RETURN_TYPE_ERROR(isolate, exception, Instance);
  }
  const Instance& stacktrace = Instance::Handle(isolate);
  return Api::NewHandle(isolate, UnhandledException::New(obj, stacktrace));
}


DART_EXPORT Dart_Handle Dart_PropagateError(Dart_Handle handle) {
  Isolate* isolate = Isolate::Current();
  {
    const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(handle));
    if (!obj.IsError()) {
      return Api::NewError(
          "%s expects argument 'handle' to be an error handle.  "
          "Did you forget to check Dart_IsError first?",
          CURRENT_FUNC);
    }
  }
  if (isolate->top_exit_frame_info() == 0) {
    // There are no dart frames on the stack so it would be illegal to
    // propagate an error here.
    return Api::NewError("No Dart frames on stack, cannot propagate error.");
  }

  // Unwind all the API scopes till the exit frame before propagating.
  ApiState* state = isolate->api_state();
  ASSERT(state != NULL);
  const Error* error;
  {
    // We need to preserve the error object across the destruction of zones
    // when the ApiScopes are unwound.  By using NoGCScope, we can ensure
    // that GC won't touch the raw error object before creating a valid
    // handle for it in the surviving zone.
    NoGCScope no_gc;
    RawError* raw_error = Api::UnwrapErrorHandle(isolate, handle).raw();
    state->UnwindScopes(isolate->top_exit_frame_info());
    error = &Error::Handle(isolate, raw_error);
  }
  Exceptions::PropagateError(*error);
  UNREACHABLE();
  return Api::NewError("Cannot reach here.  Internal error.");
}


DART_EXPORT void _Dart_ReportErrorHandle(const char* file,
                                         int line,
                                         const char* handle,
                                         const char* message) {
  fprintf(stderr, "%s:%d: error handle: '%s':\n    '%s'\n",
          file, line, handle, message);
  OS::Abort();
}


DART_EXPORT Dart_Handle Dart_ToString(Dart_Handle object) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(object));
  if (obj.IsString()) {
    return Api::NewHandle(isolate, obj.raw());
  } else if (obj.IsInstance()) {
    CHECK_CALLBACK_STATE(isolate);
    const Instance& receiver = Instance::Cast(obj);
    return Api::NewHandle(isolate, DartLibraryCalls::ToString(receiver));
  } else {
    CHECK_CALLBACK_STATE(isolate);
    // This is a VM internal object. Call the C++ method of printing.
    return Api::NewHandle(isolate, String::New(obj.ToCString()));
  }
}


DART_EXPORT bool Dart_IdentityEquals(Dart_Handle obj1, Dart_Handle obj2) {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  NoGCScope ngc;
  return Api::UnwrapHandle(obj1) == Api::UnwrapHandle(obj2);
}


DART_EXPORT Dart_Handle Dart_NewPersistentHandle(Dart_Handle object) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  ApiState* state = isolate->api_state();
  ASSERT(state != NULL);
  const Object& old_ref = Object::Handle(isolate, Api::UnwrapHandle(object));
  PersistentHandle* new_ref = state->persistent_handles().AllocateHandle();
  new_ref->set_raw(old_ref);
  return reinterpret_cast<Dart_Handle>(new_ref);
}

static Dart_Handle AllocateFinalizableHandle(
    Isolate* isolate,
    FinalizablePersistentHandles* handles,
    Dart_Handle object,
    void* peer,
    Dart_WeakPersistentHandleFinalizer callback) {
  const Object& ref = Object::Handle(isolate, Api::UnwrapHandle(object));
  FinalizablePersistentHandle* finalizable_ref = handles->AllocateHandle();
  finalizable_ref->set_raw(ref);
  finalizable_ref->set_peer(peer);
  finalizable_ref->set_callback(callback);
  return reinterpret_cast<Dart_Handle>(finalizable_ref);
}


DART_EXPORT Dart_Handle Dart_NewWeakPersistentHandle(
    Dart_Handle object,
    void* peer,
    Dart_WeakPersistentHandleFinalizer callback) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  ApiState* state = isolate->api_state();
  ASSERT(state != NULL);
  return AllocateFinalizableHandle(isolate,
                                   &state->weak_persistent_handles(),
                                   object,
                                   peer,
                                   callback);
}


DART_EXPORT Dart_Handle Dart_NewPrologueWeakPersistentHandle(
    Dart_Handle object,
    void* peer,
    Dart_WeakPersistentHandleFinalizer callback) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  ApiState* state = isolate->api_state();
  ASSERT(state != NULL);
  return AllocateFinalizableHandle(isolate,
                                   &state->prologue_weak_persistent_handles(),
                                   object,
                                   peer,
                                   callback);
}


DART_EXPORT void Dart_DeletePersistentHandle(Dart_Handle object) {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  ApiState* state = isolate->api_state();
  ASSERT(state != NULL);
  if (state->IsValidPrologueWeakPersistentHandle(object)) {
    FinalizablePersistentHandle* prologue_weak_ref =
        Api::UnwrapAsPrologueWeakPersistentHandle(*state, object);
    state->prologue_weak_persistent_handles().FreeHandle(prologue_weak_ref);
    return;
  }
  if (state->IsValidWeakPersistentHandle(object)) {
    FinalizablePersistentHandle* weak_ref =
        Api::UnwrapAsWeakPersistentHandle(*state, object);
    state->weak_persistent_handles().FreeHandle(weak_ref);
    return;
  }
  PersistentHandle* ref = Api::UnwrapAsPersistentHandle(*state, object);
  ASSERT(!state->IsProtectedHandle(ref));
  if (!state->IsProtectedHandle(ref)) {
    state->persistent_handles().FreeHandle(ref);
  }
}


DART_EXPORT bool Dart_IsWeakPersistentHandle(Dart_Handle object) {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  ApiState* state = isolate->api_state();
  ASSERT(state != NULL);
  return state->IsValidWeakPersistentHandle(object);
}


DART_EXPORT bool Dart_IsPrologueWeakPersistentHandle(Dart_Handle object) {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  ApiState* state = isolate->api_state();
  ASSERT(state != NULL);
  return state->IsValidPrologueWeakPersistentHandle(object);
}


DART_EXPORT Dart_Handle Dart_NewWeakReferenceSet(Dart_Handle* keys,
                                                 intptr_t num_keys,
                                                 Dart_Handle* values,
                                                 intptr_t num_values) {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  ApiState* state = isolate->api_state();
  ASSERT(state != NULL);
  if (keys == NULL) {
    RETURN_NULL_ERROR(keys);
  }
  if (num_keys <= 0) {
    return Api::NewError(
        "%s expects argument 'num_keys' to be greater than 0.",
        CURRENT_FUNC);
  }
  if (values == NULL) {
    RETURN_NULL_ERROR(values);
  }
  if (num_values <= 0) {
    return Api::NewError(
        "%s expects argument 'num_values' to be greater than 0.",
        CURRENT_FUNC);
  }

  WeakReferenceSet* reference_set = new WeakReferenceSet(keys, num_keys,
                                                         values, num_values);
  state->DelayWeakReferenceSet(reference_set);
  return Api::Success(isolate);
}


// --- Garbage Collection Callbacks --


DART_EXPORT Dart_Handle Dart_AddGcPrologueCallback(
    Dart_GcPrologueCallback callback) {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  GcPrologueCallbacks& callbacks = isolate->gc_prologue_callbacks();
  if (callbacks.Contains(callback)) {
    return Api::NewError(
        "%s permits only one instance of 'callback' to be present in the "
        "prologue callback list.",
        CURRENT_FUNC);
  }
  callbacks.Add(callback);
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_RemoveGcPrologueCallback(
    Dart_GcPrologueCallback callback) {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  GcPrologueCallbacks& callbacks = isolate->gc_prologue_callbacks();
  if (!callbacks.Contains(callback)) {
    return Api::NewError(
        "%s expects 'callback' to be present in the prologue callback list.",
        CURRENT_FUNC);
  }
  callbacks.Remove(callback);
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_AddGcEpilogueCallback(
    Dart_GcEpilogueCallback callback) {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  GcEpilogueCallbacks& callbacks = isolate->gc_epilogue_callbacks();
  if (callbacks.Contains(callback)) {
    return Api::NewError(
        "%s permits only one instance of 'callback' to be present in the "
        "epilogue callback list.",
        CURRENT_FUNC);
  }
  callbacks.Add(callback);
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_RemoveGcEpilogueCallback(
    Dart_GcEpilogueCallback callback) {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  GcEpilogueCallbacks& callbacks = isolate->gc_epilogue_callbacks();
  if (!callbacks.Contains(callback)) {
    return Api::NewError(
        "%s expects 'callback' to be present in the epilogue callback list.",
        CURRENT_FUNC);
  }
  callbacks.Remove(callback);
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_HeapProfile(Dart_FileWriteCallback callback,
                                         void* stream) {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  if (callback == NULL) {
    RETURN_NULL_ERROR(callback);
  }
  isolate->heap()->Profile(callback, stream);
  return Api::Success(isolate);
}

// --- Initialization and Globals ---

DART_EXPORT const char* Dart_VersionString() {
  return Version::String();
}

DART_EXPORT bool Dart_Initialize(
    Dart_IsolateCreateCallback create,
    Dart_IsolateInterruptCallback interrupt,
    Dart_IsolateUnhandledExceptionCallback unhandled,
    Dart_IsolateShutdownCallback shutdown,
    Dart_FileOpenCallback file_open,
    Dart_FileReadCallback file_read,
    Dart_FileWriteCallback file_write,
    Dart_FileCloseCallback file_close) {
  const char* err_msg = Dart::InitOnce(create, interrupt, unhandled, shutdown,
                                       file_open, file_read, file_write,
                                       file_close);
  if (err_msg != NULL) {
    OS::PrintErr("Dart_Initialize: %s\n", err_msg);
    return false;
  }
  return true;
}

DART_EXPORT bool Dart_SetVMFlags(int argc, const char** argv) {
  return Flags::ProcessCommandLineFlags(argc, argv);
}

DART_EXPORT bool Dart_IsVMFlagSet(const char* flag_name) {
  if (Flags::Lookup(flag_name) != NULL) {
    return true;
  }
  return false;
}


// --- Isolates ---


static char* BuildIsolateName(const char* script_uri,
                              const char* main) {
  if (script_uri == NULL) {
    // Just use the main as the name.
    if (main == NULL) {
      return strdup("isolate");
    } else {
      return strdup(main);
    }
  }

  // Skip past any slashes and backslashes in the script uri.
  const char* last_slash = strrchr(script_uri, '/');
  if (last_slash != NULL) {
    script_uri = last_slash + 1;
  }
  const char* last_backslash = strrchr(script_uri, '\\');
  if (last_backslash != NULL) {
    script_uri = last_backslash + 1;
  }
  if (main == NULL) {
    main = "main";
  }

  char* chars = NULL;
  intptr_t len = OS::SNPrint(NULL, 0, "%s$%s", script_uri, main) + 1;
  chars = reinterpret_cast<char*>(malloc(len));
  OS::SNPrint(chars, len, "%s$%s", script_uri, main);
  return chars;
}


DART_EXPORT Dart_Isolate Dart_CreateIsolate(const char* script_uri,
                                            const char* main,
                                            const uint8_t* snapshot,
                                            void* callback_data,
                                            char** error) {
  char* isolate_name = BuildIsolateName(script_uri, main);
  Isolate* isolate = Dart::CreateIsolate(isolate_name);
  free(isolate_name);
  {
    StackZone zone(isolate);
    HANDLESCOPE(isolate);
    const Error& error_obj =
        Error::Handle(isolate,
                      Dart::InitializeIsolate(snapshot, callback_data));
    if (error_obj.IsNull()) {
      START_TIMER(time_total_runtime);
      return reinterpret_cast<Dart_Isolate>(isolate);
    }
    *error = strdup(error_obj.ToErrorCString());
  }
  Dart::ShutdownIsolate();
  return reinterpret_cast<Dart_Isolate>(NULL);
}


DART_EXPORT void Dart_ShutdownIsolate() {
  CHECK_ISOLATE(Isolate::Current());
  STOP_TIMER(time_total_runtime);
  Dart::ShutdownIsolate();
}


DART_EXPORT Dart_Isolate Dart_CurrentIsolate() {
  return Api::CastIsolate(Isolate::Current());
}


DART_EXPORT void* Dart_CurrentIsolateData() {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  return isolate->init_callback_data();
}


DART_EXPORT Dart_Handle Dart_DebugName() {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  return Api::NewHandle(isolate, String::New(isolate->name()));
}



DART_EXPORT void Dart_EnterIsolate(Dart_Isolate dart_isolate) {
  CHECK_NO_ISOLATE(Isolate::Current());
  Isolate* isolate = reinterpret_cast<Isolate*>(dart_isolate);
  Isolate::SetCurrent(isolate);
}


DART_EXPORT void Dart_ExitIsolate() {
  CHECK_ISOLATE(Isolate::Current());
  Isolate::SetCurrent(NULL);
}


static uint8_t* ApiReallocate(uint8_t* ptr,
                              intptr_t old_size,
                              intptr_t new_size) {
  return Api::TopScope(Isolate::Current())->zone()->Realloc<uint8_t>(
      ptr, old_size, new_size);
}


DART_EXPORT Dart_Handle Dart_CreateSnapshot(uint8_t** buffer,
                                            intptr_t* size) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  TIMERSCOPE(time_creating_snapshot);
  if (buffer == NULL) {
    RETURN_NULL_ERROR(buffer);
  }
  if (size == NULL) {
    RETURN_NULL_ERROR(size);
  }
  Dart_Handle state = Api::CheckIsolateState(isolate);
  if (::Dart_IsError(state)) {
    return state;
  }
  // Since this is only a snapshot the root library should not be set.
  isolate->object_store()->set_root_library(Library::Handle(isolate));
  FullSnapshotWriter writer(buffer, ApiReallocate);
  writer.WriteFullSnapshot();
  *size = writer.BytesWritten();
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_CreateScriptSnapshot(uint8_t** buffer,
                                                  intptr_t* size) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  TIMERSCOPE(time_creating_snapshot);
  if (buffer == NULL) {
    RETURN_NULL_ERROR(buffer);
  }
  if (size == NULL) {
    RETURN_NULL_ERROR(size);
  }
  Dart_Handle state = Api::CheckIsolateState(isolate);
  if (::Dart_IsError(state)) {
    return state;
  }
  Library& library =
      Library::Handle(isolate, isolate->object_store()->root_library());
  if (library.IsNull()) {
    return
        Api::NewError("%s expects the isolate to have a script loaded in it.",
                      CURRENT_FUNC);
  }
  ScriptSnapshotWriter writer(buffer, ApiReallocate);
  writer.WriteScriptSnapshot(library);
  *size = writer.BytesWritten();
  return Api::Success(isolate);
}


DART_EXPORT void Dart_InterruptIsolate(Dart_Isolate isolate) {
  if (isolate == NULL) {
    FATAL1("%s expects argument 'isolate' to be non-null.",  CURRENT_FUNC);
  }
  Isolate* iso = reinterpret_cast<Isolate*>(isolate);
  iso->ScheduleInterrupts(Isolate::kApiInterrupt);
}


DART_EXPORT bool Dart_IsolateMakeRunnable(Dart_Isolate isolate) {
  CHECK_NO_ISOLATE(Isolate::Current());
  if (isolate == NULL) {
    FATAL1("%s expects argument 'isolate' to be non-null.",  CURRENT_FUNC);
  }
  Isolate* iso = reinterpret_cast<Isolate*>(isolate);
  return iso->MakeRunnable();
}


// --- Messages and Ports ---

DART_EXPORT void Dart_SetMessageNotifyCallback(
    Dart_MessageNotifyCallback message_notify_callback) {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  isolate->set_message_notify_callback(message_notify_callback);
}


struct RunLoopData {
  Monitor* monitor;
  bool done;
};


static void RunLoopDone(uword param) {
  RunLoopData* data = reinterpret_cast<RunLoopData*>(param);
  ASSERT(data->monitor != NULL);
  MonitorLocker ml(data->monitor);
  data->done = true;
  ml.Notify();
}


DART_EXPORT Dart_Handle Dart_RunLoop() {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE_SCOPE(isolate);
  CHECK_CALLBACK_STATE(isolate);
  Monitor monitor;
  MonitorLocker ml(&monitor);
  {
    SwitchIsolateScope switch_scope(NULL);

    RunLoopData data;
    data.monitor = &monitor;
    data.done = false;
    isolate->message_handler()->Run(
        Dart::thread_pool(),
        NULL, RunLoopDone, reinterpret_cast<uword>(&data));
    while (!data.done) {
      ml.Wait();
    }
  }
  if (isolate->object_store()->sticky_error() != Object::null()) {
    Dart_Handle error = Api::NewHandle(isolate,
                                       isolate->object_store()->sticky_error());
    isolate->object_store()->clear_sticky_error();
    return error;
  }
  if (FLAG_print_class_table) {
    isolate->class_table()->Print();
  }
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_HandleMessage() {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE_SCOPE(isolate);
  CHECK_CALLBACK_STATE(isolate);
  if (!isolate->message_handler()->HandleNextMessage()) {
    Dart_Handle error = Api::NewHandle(isolate,
                                       isolate->object_store()->sticky_error());
    isolate->object_store()->clear_sticky_error();
    return error;
  }
  return Api::Success(isolate);
}


DART_EXPORT bool Dart_HasLivePorts() {
  Isolate* isolate = Isolate::Current();
  ASSERT(isolate);
  return isolate->message_handler()->HasLivePorts();
}


static uint8_t* allocator(uint8_t* ptr, intptr_t old_size, intptr_t new_size) {
  void* new_ptr = realloc(reinterpret_cast<void*>(ptr), new_size);
  return reinterpret_cast<uint8_t*>(new_ptr);
}


DART_EXPORT bool Dart_PostIntArray(Dart_Port port_id,
                                   intptr_t len,
                                   intptr_t* data) {
  uint8_t* buffer = NULL;
  ApiMessageWriter writer(&buffer, &allocator);
  writer.WriteMessage(len, data);

  // Post the message at the given port.
  return PortMap::PostMessage(new Message(
      port_id, Message::kIllegalPort, buffer, writer.BytesWritten(),
      Message::kNormalPriority));
}


DART_EXPORT bool Dart_PostCObject(Dart_Port port_id, Dart_CObject* message) {
  uint8_t* buffer = NULL;
  ApiMessageWriter writer(&buffer, allocator);
  bool success = writer.WriteCMessage(message);

  if (!success) return success;

  // Post the message at the given port.
  return PortMap::PostMessage(new Message(
      port_id, Message::kIllegalPort, buffer, writer.BytesWritten(),
      Message::kNormalPriority));
}


DART_EXPORT bool Dart_Post(Dart_Port port_id, Dart_Handle handle) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& object = Object::Handle(isolate, Api::UnwrapHandle(handle));
  uint8_t* data = NULL;
  MessageWriter writer(&data, &allocator);
  writer.WriteMessage(object);
  intptr_t len = writer.BytesWritten();
  return PortMap::PostMessage(new Message(
      port_id, Message::kIllegalPort, data, len, Message::kNormalPriority));
}


DART_EXPORT Dart_Port Dart_NewNativePort(const char* name,
                                         Dart_NativeMessageHandler handler,
                                         bool handle_concurrently) {
  if (name == NULL) {
    name = "<UnnamedNativePort>";
  }
  if (handler == NULL) {
    OS::PrintErr("%s expects argument 'handler' to be non-null.\n",
                 CURRENT_FUNC);
    return ILLEGAL_PORT;
  }
  // Start the native port without a current isolate.
  IsolateSaver saver(Isolate::Current());
  Isolate::SetCurrent(NULL);

  NativeMessageHandler* nmh = new NativeMessageHandler(name, handler);
  Dart_Port port_id = PortMap::CreatePort(nmh);
  nmh->Run(Dart::thread_pool(), NULL, NULL, 0);
  return port_id;
}


DART_EXPORT bool Dart_CloseNativePort(Dart_Port native_port_id) {
  // Close the native port without a current isolate.
  IsolateSaver saver(Isolate::Current());
  Isolate::SetCurrent(NULL);

  // TODO(turnidge): Check that the port is native before trying to close.
  return PortMap::ClosePort(native_port_id);
}


DART_EXPORT Dart_Handle Dart_NewSendPort(Dart_Port port_id) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  CHECK_CALLBACK_STATE(isolate);
  return Api::NewHandle(isolate, DartLibraryCalls::NewSendPort(port_id));
}


DART_EXPORT Dart_Handle Dart_GetReceivePort(Dart_Port port_id) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  CHECK_CALLBACK_STATE(isolate);

  Library& isolate_lib = Library::Handle(isolate, Library::IsolateLibrary());
  ASSERT(!isolate_lib.IsNull());
  const String& class_name = String::Handle(
      isolate, isolate_lib.PrivateName(Symbols::_ReceivePortImpl()));
  // TODO(asiva): Symbols should contain private keys.
  const String& function_name =
      String::Handle(isolate_lib.PrivateName(Symbols::_get_or_create()));
  const int kNumArguments = 1;
  const Function& function = Function::Handle(
      isolate,
      Resolver::ResolveStatic(isolate_lib,
                              class_name,
                              function_name,
                              kNumArguments,
                              Object::empty_array(),
                              Resolver::kIsQualified));
  ASSERT(!function.IsNull());
  const Array& args = Array::Handle(isolate, Array::New(kNumArguments));
  args.SetAt(0, Integer::Handle(isolate, Integer::New(port_id)));
  return Api::NewHandle(isolate, DartEntry::InvokeFunction(function, args));
}


DART_EXPORT Dart_Port Dart_GetMainPortId() {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  return isolate->main_port();
}

// --- Scopes ----


DART_EXPORT void Dart_EnterScope() {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  ApiState* state = isolate->api_state();
  ASSERT(state != NULL);
  ApiLocalScope* new_scope = new ApiLocalScope(state->top_scope(),
                                               isolate->top_exit_frame_info());
  ASSERT(new_scope != NULL);
  state->set_top_scope(new_scope);  // New scope is now the top scope.
}


DART_EXPORT void Dart_ExitScope() {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE_SCOPE(isolate);
  ApiState* state = isolate->api_state();
  ApiLocalScope* scope = state->top_scope();

  state->set_top_scope(scope->previous());  // Reset top scope to previous.
  delete scope;  // Free up the old scope which we have just exited.
}


DART_EXPORT uint8_t* Dart_ScopeAllocate(intptr_t size) {
  Zone* zone;
  Isolate* isolate = Isolate::Current();
  if (isolate != NULL) {
    ApiState* state = isolate->api_state();
    if (state == NULL) return NULL;
    ApiLocalScope* scope = state->top_scope();
    zone = scope->zone();
  } else {
    ApiNativeScope* scope = ApiNativeScope::Current();
    if (scope == NULL) return NULL;
    zone = scope->zone();
  }
  return reinterpret_cast<uint8_t*>(zone->AllocUnsafe(size));
}


// --- Objects ----


DART_EXPORT Dart_Handle Dart_Null() {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE_SCOPE(isolate);
  return Api::Null(isolate);
}


DART_EXPORT bool Dart_IsNull(Dart_Handle object) {
  return Api::ClassId(object) == kNullCid;
}


DART_EXPORT Dart_Handle Dart_ObjectEquals(Dart_Handle obj1, Dart_Handle obj2,
                                          bool* value) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  CHECK_CALLBACK_STATE(isolate);
  const Instance& expected =
      Instance::CheckedHandle(isolate, Api::UnwrapHandle(obj1));
  const Instance& actual =
      Instance::CheckedHandle(isolate, Api::UnwrapHandle(obj2));
  const Object& result =
      Object::Handle(isolate, DartLibraryCalls::Equals(expected, actual));
  if (result.IsBool()) {
    *value = Bool::Cast(result).value();
    return Api::Success(isolate);
  } else if (result.IsError()) {
    return Api::NewHandle(isolate, result.raw());
  } else {
    return Api::NewError("Expected boolean result from ==");
  }
}


// TODO(iposva): This call actually implements IsInstanceOfClass.
// Do we also need a real Dart_IsInstanceOf, which should take an instance
// rather than an object and a type rather than a class?
DART_EXPORT Dart_Handle Dart_ObjectIsType(Dart_Handle object,
                                          Dart_Handle clazz,
                                          bool* value) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);

  const Class& cls = Api::UnwrapClassHandle(isolate, clazz);
  if (cls.IsNull()) {
    RETURN_TYPE_ERROR(isolate, clazz, Class);
  }
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(object));
  if (obj.IsError()) {
    return object;
  } else if (!obj.IsNull() && !obj.IsInstance()) {
    return Api::NewError(
        "%s expects argument 'object' to be an instance of Object.",
        CURRENT_FUNC);
  }
  // Finalize all classes.
  Dart_Handle state = Api::CheckIsolateState(isolate);
  if (::Dart_IsError(state)) {
    return state;
  }
  if (obj.IsInstance()) {
    CHECK_CALLBACK_STATE(isolate);
    const Type& type = Type::Handle(isolate,
                                    Type::NewNonParameterizedType(cls));
    Error& malformed_type_error = Error::Handle(isolate);
    *value = Instance::Cast(obj).IsInstanceOf(type,
                                              TypeArguments::Handle(isolate),
                                              &malformed_type_error);
    ASSERT(malformed_type_error.IsNull());  // Type was created from a class.
  } else {
    *value = false;
  }
  return Api::Success(isolate);
}


// --- Instances ----


DART_EXPORT bool Dart_IsInstance(Dart_Handle object) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(object));
  return obj.IsInstance();
}


// TODO(turnidge): Technically, null has a class.  Should we allow it?
DART_EXPORT Dart_Handle Dart_InstanceGetClass(Dart_Handle instance) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Instance& obj = Api::UnwrapInstanceHandle(isolate, instance);
  if (obj.IsNull()) {
    RETURN_TYPE_ERROR(isolate, instance, Instance);
  }
  return Api::NewHandle(isolate, obj.clazz());
}


// --- Numbers ----


DART_EXPORT bool Dart_IsNumber(Dart_Handle object) {
  return RawObject::IsNumberClassId(Api::ClassId(object));
}


// --- Integers ----


DART_EXPORT bool Dart_IsInteger(Dart_Handle object) {
  return RawObject::IsIntegerClassId(Api::ClassId(object));
}


DART_EXPORT Dart_Handle Dart_IntegerFitsIntoInt64(Dart_Handle integer,
                                                  bool* fits) {
  // Fast path for Smis and Mints.
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  intptr_t class_id = Api::ClassId(integer);
  if (class_id == kSmiCid || class_id == kMintCid) {
    *fits = true;
    return Api::Success(isolate);
  }
  // Slow path for Mints and Bigints.
  DARTSCOPE(isolate);
  const Integer& int_obj = Api::UnwrapIntegerHandle(isolate, integer);
  if (int_obj.IsNull()) {
    RETURN_TYPE_ERROR(isolate, integer, Integer);
  }
  ASSERT(!BigintOperations::FitsIntoMint(Bigint::Cast(int_obj)));
  *fits = false;
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_IntegerFitsIntoUint64(Dart_Handle integer,
                                                   bool* fits) {
  // Fast path for Smis.
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  if (Api::IsSmi(integer)) {
    *fits = (Api::SmiValue(integer) >= 0);
    return Api::Success(isolate);
  }
  // Slow path for Mints and Bigints.
  DARTSCOPE(isolate);
  const Integer& int_obj = Api::UnwrapIntegerHandle(isolate, integer);
  if (int_obj.IsNull()) {
    RETURN_TYPE_ERROR(isolate, integer, Integer);
  }
  ASSERT(!int_obj.IsSmi());
  if (int_obj.IsMint()) {
    *fits = !int_obj.IsNegative();
  } else {
    *fits = BigintOperations::FitsIntoUint64(Bigint::Cast(int_obj));
  }
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_NewInteger(int64_t value) {
  // Fast path for Smis.
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  if (Smi::IsValid64(value)) {
    NOHANDLESCOPE(isolate);
    return Api::NewHandle(isolate, Smi::New(static_cast<intptr_t>(value)));
  }
  // Slow path for Mints and Bigints.
  DARTSCOPE(isolate);
  CHECK_CALLBACK_STATE(isolate);
  return Api::NewHandle(isolate, Integer::New(value));
}


DART_EXPORT Dart_Handle Dart_NewIntegerFromHexCString(const char* str) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  CHECK_CALLBACK_STATE(isolate);
  const String& str_obj = String::Handle(isolate, String::New(str));
  return Api::NewHandle(isolate, Integer::New(str_obj));
}


DART_EXPORT Dart_Handle Dart_IntegerToInt64(Dart_Handle integer,
                                            int64_t* value) {
  // Fast path for Smis.
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  if (Api::IsSmi(integer)) {
    *value = Api::SmiValue(integer);
    return Api::Success(isolate);
  }
  // Slow path for Mints and Bigints.
  DARTSCOPE(isolate);
  const Integer& int_obj = Api::UnwrapIntegerHandle(isolate, integer);
  if (int_obj.IsNull()) {
    RETURN_TYPE_ERROR(isolate, integer, Integer);
  }
  ASSERT(!int_obj.IsSmi());
  if (int_obj.IsMint()) {
    *value = int_obj.AsInt64Value();
    return Api::Success(isolate);
  } else {
    const Bigint& bigint = Bigint::Cast(int_obj);
    if (BigintOperations::FitsIntoMint(bigint)) {
      *value = BigintOperations::ToMint(bigint);
      return Api::Success(isolate);
    }
  }
  return Api::NewError("%s: Integer %s cannot be represented as an int64_t.",
                       CURRENT_FUNC, int_obj.ToCString());
}


DART_EXPORT Dart_Handle Dart_IntegerToUint64(Dart_Handle integer,
                                             uint64_t* value) {
  // Fast path for Smis.
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  if (Api::IsSmi(integer)) {
    intptr_t smi_value = Api::SmiValue(integer);
    if (smi_value >= 0) {
      *value = smi_value;
      return Api::Success(isolate);
    }
  }
  // Slow path for Mints and Bigints.
  DARTSCOPE(isolate);
  const Integer& int_obj = Api::UnwrapIntegerHandle(isolate, integer);
  if (int_obj.IsNull()) {
    RETURN_TYPE_ERROR(isolate, integer, Integer);
  }
  ASSERT(!int_obj.IsSmi());
  if (int_obj.IsMint() && !int_obj.IsNegative()) {
    *value = int_obj.AsInt64Value();
    return Api::Success(isolate);
  } else {
    const Bigint& bigint = Bigint::Cast(int_obj);
    if (BigintOperations::FitsIntoUint64(bigint)) {
      *value = BigintOperations::ToUint64(bigint);
      return Api::Success(isolate);
    }
  }
  return Api::NewError("%s: Integer %s cannot be represented as a uint64_t.",
                       CURRENT_FUNC, int_obj.ToCString());
}


static uword BigintAllocate(intptr_t size) {
  return Api::TopScope(Isolate::Current())->zone()->AllocUnsafe(size);
}


DART_EXPORT Dart_Handle Dart_IntegerToHexCString(Dart_Handle integer,
                                                 const char** value) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Integer& int_obj = Api::UnwrapIntegerHandle(isolate, integer);
  if (int_obj.IsNull()) {
    RETURN_TYPE_ERROR(isolate, integer, Integer);
  }
  if (int_obj.IsSmi() || int_obj.IsMint()) {
    const Bigint& bigint = Bigint::Handle(isolate,
        BigintOperations::NewFromInt64(int_obj.AsInt64Value()));
    *value = BigintOperations::ToHexCString(bigint, BigintAllocate);
  } else {
    *value = BigintOperations::ToHexCString(Bigint::Cast(int_obj),
                                            BigintAllocate);
  }
  return Api::Success(isolate);
}


// --- Booleans ----


DART_EXPORT Dart_Handle Dart_True() {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE_SCOPE(isolate);
  return Api::True(isolate);
}


DART_EXPORT Dart_Handle Dart_False() {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE_SCOPE(isolate);
  return Api::False(isolate);
}


DART_EXPORT bool Dart_IsBoolean(Dart_Handle object) {
  return Api::ClassId(object) == kBoolCid;
}


DART_EXPORT Dart_Handle Dart_NewBoolean(bool value) {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE_SCOPE(isolate);
  return value ? Api::True(isolate) : Api::False(isolate);
}


DART_EXPORT Dart_Handle Dart_BooleanValue(Dart_Handle boolean_obj,
                                          bool* value) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Bool& obj = Api::UnwrapBoolHandle(isolate, boolean_obj);
  if (obj.IsNull()) {
    RETURN_TYPE_ERROR(isolate, boolean_obj, Bool);
  }
  *value = obj.value();
  return Api::Success(isolate);
}


// --- Doubles ---


DART_EXPORT bool Dart_IsDouble(Dart_Handle object) {
  return Api::ClassId(object) == kDoubleCid;
}


DART_EXPORT Dart_Handle Dart_NewDouble(double value) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  CHECK_CALLBACK_STATE(isolate);
  return Api::NewHandle(isolate, Double::New(value));
}


DART_EXPORT Dart_Handle Dart_DoubleValue(Dart_Handle double_obj,
                                         double* value) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Double& obj = Api::UnwrapDoubleHandle(isolate, double_obj);
  if (obj.IsNull()) {
    RETURN_TYPE_ERROR(isolate, double_obj, Double);
  }
  *value = obj.value();
  return Api::Success(isolate);
}


// --- Strings ---


DART_EXPORT bool Dart_IsString(Dart_Handle object) {
  return RawObject::IsStringClassId(Api::ClassId(object));
}


DART_EXPORT bool Dart_IsStringLatin1(Dart_Handle object) {
  return RawObject::IsOneByteStringClassId(Api::ClassId(object));
}


DART_EXPORT Dart_Handle Dart_StringLength(Dart_Handle str, intptr_t* len) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const String& str_obj = Api::UnwrapStringHandle(isolate, str);
  if (str_obj.IsNull()) {
    RETURN_TYPE_ERROR(isolate, str, String);
  }
  *len = str_obj.Length();
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_NewStringFromCString(const char* str) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (str == NULL) {
    RETURN_NULL_ERROR(str);
  }
  CHECK_CALLBACK_STATE(isolate);
  return Api::NewHandle(isolate, String::New(str));
}


DART_EXPORT Dart_Handle Dart_NewStringFromUTF8(const uint8_t* utf8_array,
                                               intptr_t length) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (utf8_array == NULL && length != 0) {
    RETURN_NULL_ERROR(utf8_array);
  }
  CHECK_LENGTH(length, String::kMaxElements);
  if (!Utf8::IsValid(utf8_array, length)) {
    return Api::NewError("%s expects argument 'str' to be valid UTF-8.",
                         CURRENT_FUNC);
  }
  CHECK_CALLBACK_STATE(isolate);
  return Api::NewHandle(isolate, String::FromUTF8(utf8_array, length));
}


DART_EXPORT Dart_Handle Dart_NewStringFromUTF16(const uint16_t* utf16_array,
                                                intptr_t length) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (utf16_array == NULL && length != 0) {
    RETURN_NULL_ERROR(utf16_array);
  }
  CHECK_LENGTH(length, String::kMaxElements);
  CHECK_CALLBACK_STATE(isolate);
  return Api::NewHandle(isolate, String::FromUTF16(utf16_array, length));
}


DART_EXPORT Dart_Handle Dart_NewStringFromUTF32(const int32_t* utf32_array,
                                                intptr_t length) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (utf32_array == NULL && length != 0) {
    RETURN_NULL_ERROR(utf32_array);
  }
  CHECK_LENGTH(length, String::kMaxElements);
  CHECK_CALLBACK_STATE(isolate);
  return Api::NewHandle(isolate, String::FromUTF32(utf32_array, length));
}


DART_EXPORT bool Dart_IsExternalString(Dart_Handle object) {
  return RawObject::IsExternalStringClassId(Api::ClassId(object));
}


DART_EXPORT Dart_Handle Dart_ExternalStringGetPeer(Dart_Handle object,
                                                   void** peer) {
  if (peer == NULL) {
    RETURN_NULL_ERROR(peer);
  }

  if (Api::ExternalStringGetPeerHelper(object, peer)) {
    return Api::Success(Isolate::Current());
  }

  // It's not an external string, return appropriate error.
  if (!RawObject::IsStringClassId(Api::ClassId(object))) {
    RETURN_TYPE_ERROR(Isolate::Current(), object, String);
  } else {
    return
        Api::NewError(
            "%s expects argument 'object' to be an external String.",
            CURRENT_FUNC);
  }
}


DART_EXPORT Dart_Handle Dart_NewExternalLatin1String(
    const uint8_t* latin1_array,
    intptr_t length,
    void* peer,
    Dart_PeerFinalizer cback) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (latin1_array == NULL && length != 0) {
    RETURN_NULL_ERROR(latin1_array);
  }
  CHECK_LENGTH(length, String::kMaxElements);
  CHECK_CALLBACK_STATE(isolate);
  return Api::NewHandle(isolate,
                        String::NewExternal(latin1_array, length, peer, cback));
}


DART_EXPORT Dart_Handle Dart_NewExternalUTF16String(const uint16_t* utf16_array,
                                                    intptr_t length,
                                                    void* peer,
                                                    Dart_PeerFinalizer cback) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (utf16_array == NULL && length != 0) {
    RETURN_NULL_ERROR(utf16_array);
  }
  CHECK_LENGTH(length, String::kMaxElements);
  CHECK_CALLBACK_STATE(isolate);
  return Api::NewHandle(isolate,
                        String::NewExternal(utf16_array, length, peer, cback));
}


DART_EXPORT Dart_Handle Dart_StringToCString(Dart_Handle object,
                                             const char** cstr) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (cstr == NULL) {
    RETURN_NULL_ERROR(cstr);
  }
  const String& str_obj = Api::UnwrapStringHandle(isolate, object);
  if (str_obj.IsNull()) {
    RETURN_TYPE_ERROR(isolate, object, String);
  }
  intptr_t string_length = Utf8::Length(str_obj);
  char* res = Api::TopScope(isolate)->zone()->Alloc<char>(string_length + 1);
  if (res == NULL) {
    return Api::NewError("Unable to allocate memory");
  }
  const char* string_value = str_obj.ToCString();
  memmove(res, string_value, string_length + 1);
  ASSERT(res[string_length] == '\0');
  *cstr = res;
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_StringToUTF8(Dart_Handle str,
                                          uint8_t** utf8_array,
                                          intptr_t* length) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (utf8_array == NULL) {
    RETURN_NULL_ERROR(utf8_array);
  }
  if (length == NULL) {
    RETURN_NULL_ERROR(length);
  }
  const String& str_obj = Api::UnwrapStringHandle(isolate, str);
  if (str_obj.IsNull()) {
    RETURN_TYPE_ERROR(isolate, str, String);
  }
  intptr_t str_len = Utf8::Length(str_obj);
  *utf8_array = Api::TopScope(isolate)->zone()->Alloc<uint8_t>(str_len);
  if (*utf8_array == NULL) {
    return Api::NewError("Unable to allocate memory");
  }
  str_obj.ToUTF8(*utf8_array, str_len);
  *length = str_len;
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_StringToLatin1(Dart_Handle str,
                                            uint8_t* latin1_array,
                                            intptr_t* length) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (latin1_array == NULL) {
    RETURN_NULL_ERROR(latin1_array);
  }
  if (length == NULL) {
    RETURN_NULL_ERROR(length);
  }
  const String& str_obj = Api::UnwrapStringHandle(isolate, str);
  if (str_obj.IsNull() || !str_obj.IsOneByteString()) {
    RETURN_TYPE_ERROR(isolate, str, String);
  }
  intptr_t str_len = str_obj.Length();
  intptr_t copy_len = (str_len > *length) ? *length : str_len;

  // We have already asserted that the string object is a Latin-1 string
  // so we can copy the characters over using a simple loop.
  for (intptr_t i = 0; i < copy_len; i++) {
    latin1_array[i] = str_obj.CharAt(i);
  }
  *length = copy_len;
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_StringToUTF16(Dart_Handle str,
                                           uint16_t* utf16_array,
                                           intptr_t* length) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const String& str_obj = Api::UnwrapStringHandle(isolate, str);
  if (str_obj.IsNull()) {
    RETURN_TYPE_ERROR(isolate, str, String);
  }
  intptr_t str_len = str_obj.Length();
  intptr_t copy_len = (str_len > *length) ? *length : str_len;
  for (intptr_t i = 0; i < copy_len; i++) {
    utf16_array[i] = static_cast<uint16_t>(str_obj.CharAt(i));
  }
  *length = copy_len;
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_StringStorageSize(Dart_Handle str,
                                               intptr_t* size) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const String& str_obj = Api::UnwrapStringHandle(isolate, str);
  if (str_obj.IsNull()) {
    RETURN_TYPE_ERROR(isolate, str, String);
  }
  if (size == NULL) {
    RETURN_NULL_ERROR(size);
  }
  *size = (str_obj.Length() * str_obj.CharSize());
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_MakeExternalString(Dart_Handle str,
                                                void* array,
                                                intptr_t length,
                                                void* peer,
                                                Dart_PeerFinalizer cback) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const String& str_obj = Api::UnwrapStringHandle(isolate, str);
  if (str_obj.IsExternal()) {
    return str;  // String is already an external string.
  }
  if (str_obj.IsNull()) {
    RETURN_TYPE_ERROR(isolate, str, String);
  }
  if (array == NULL) {
    RETURN_NULL_ERROR(array);
  }
  intptr_t str_size = (str_obj.Length() * str_obj.CharSize());
  if ((length < str_size) || (length > String::kMaxElements)) {
    return Api::NewError("Dart_MakeExternalString "
                         "expects argument length to be in the range"
                         "[%"Pd"..%"Pd"].",
                         str_size, String::kMaxElements);
  }
  if (str_obj.InVMHeap()) {
    // Since the string object is read only we do not externalize
    // the string but instead copy the contents of the string into the
    // specified buffer and return a Null object.
    // This ensures that the embedder does not have to call again
    // to get at the contents.
    intptr_t copy_len = str_obj.Length();
    if (str_obj.IsOneByteString()) {
      ASSERT(length >= copy_len);
      uint8_t* latin1_array = reinterpret_cast<uint8_t*>(array);
      for (intptr_t i = 0; i < copy_len; i++) {
        latin1_array[i] = static_cast<uint8_t>(str_obj.CharAt(i));
      }
    } else {
      ASSERT(str_obj.IsTwoByteString());
      ASSERT(length >= (copy_len * str_obj.CharSize()));
      uint16_t* utf16_array = reinterpret_cast<uint16_t*>(array);
      for (intptr_t i = 0; i < copy_len; i++) {
        utf16_array[i] = static_cast<uint16_t>(str_obj.CharAt(i));
      }
    }
    return Api::Null(isolate);
  }
  return Api::NewHandle(isolate,
                        str_obj.MakeExternal(array, length, peer, cback));
}


// --- Lists ---


static RawInstance* GetListInstance(Isolate* isolate, const Object& obj) {
  if (obj.IsInstance()) {
    const Instance& instance = Instance::Cast(obj);
    const Class& obj_class = Class::Handle(isolate, obj.clazz());
    const Class& list_class =
        Class::Handle(isolate, isolate->object_store()->list_class());
    Error& malformed_type_error = Error::Handle(isolate);
    if (obj_class.IsSubtypeOf(TypeArguments::Handle(isolate),
                              list_class,
                              TypeArguments::Handle(isolate),
                              &malformed_type_error)) {
      ASSERT(malformed_type_error.IsNull());  // Type is a raw List.
      return instance.raw();
    }
  }
  return Instance::null();
}


DART_EXPORT bool Dart_IsList(Dart_Handle object) {
  if (RawObject::IsBuiltinListClassId(Api::ClassId(object))) {
    return true;
  }

  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(object));
  return GetListInstance(isolate, obj) != Instance::null();
}


DART_EXPORT Dart_Handle Dart_NewList(intptr_t length) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  CHECK_LENGTH(length, Array::kMaxElements);
  CHECK_CALLBACK_STATE(isolate);
  return Api::NewHandle(isolate, Array::New(length));
}


#define GET_LIST_LENGTH(isolate, type, obj, len)                               \
  type& array = type::Handle(isolate);                                         \
  array ^= obj.raw();                                                          \
  *len = array.Length();                                                       \
  return Api::Success(isolate);                                                \


DART_EXPORT Dart_Handle Dart_ListLength(Dart_Handle list, intptr_t* len) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(list));
  if (obj.IsError()) {
    // Pass through errors.
    return list;
  }
  if (obj.IsTypedData()) {
    GET_LIST_LENGTH(isolate, TypedData, obj, len);
  }
  if (obj.IsArray()) {
    GET_LIST_LENGTH(isolate, Array, obj, len);
  }
  if (obj.IsGrowableObjectArray()) {
    GET_LIST_LENGTH(isolate, GrowableObjectArray, obj, len);
  }
  if (obj.IsExternalTypedData()) {
    GET_LIST_LENGTH(isolate, ExternalTypedData, obj, len);
  }
  CHECK_CALLBACK_STATE(isolate);

  // Now check and handle a dart object that implements the List interface.
  const Instance& instance =
      Instance::Handle(isolate, GetListInstance(isolate, obj));
  if (instance.IsNull()) {
    return Api::NewError("Object does not implement the List interface");
  }
  const String& name = String::Handle(Field::GetterName(Symbols::Length()));
  const Function& function =
      Function::Handle(isolate, Resolver::ResolveDynamic(instance, name, 1, 0));
  if (function.IsNull()) {
    return Api::NewError("List object does not have a 'length' field.");
  }

  const int kNumArgs = 1;
  const Array& args = Array::Handle(isolate, Array::New(kNumArgs));
  args.SetAt(0, instance);  // Set up the receiver as the first argument.
  const Object& retval =
    Object::Handle(isolate, DartEntry::InvokeFunction(function, args));
  if (retval.IsSmi()) {
    *len = Smi::Cast(retval).Value();
    return Api::Success(isolate);
  } else if (retval.IsMint() || retval.IsBigint()) {
    if (retval.IsMint()) {
      int64_t mint_value = Mint::Cast(retval).value();
      if (mint_value >= kIntptrMin && mint_value <= kIntptrMax) {
        *len = static_cast<intptr_t>(mint_value);
      }
    } else {
      // Check for a non-canonical Mint range value.
      ASSERT(retval.IsBigint());
      const Bigint& bigint = Bigint::Handle();
      if (BigintOperations::FitsIntoMint(bigint)) {
        int64_t bigint_value = bigint.AsInt64Value();
        if (bigint_value >= kIntptrMin && bigint_value <= kIntptrMax) {
          *len = static_cast<intptr_t>(bigint_value);
        }
      }
    }
    return Api::NewError("Length of List object is greater than the "
                         "maximum value that 'len' parameter can hold");
  } else if (retval.IsError()) {
    return Api::NewHandle(isolate, retval.raw());
  } else {
    return Api::NewError("Length of List object is not an integer");
  }
}


#define GET_LIST_ELEMENT(isolate, type, obj, index)                            \
  const type& array_obj = type::Cast(obj);                                     \
  if ((index >= 0) && (index < array_obj.Length())) {                          \
    return Api::NewHandle(isolate, array_obj.At(index));                       \
  }                                                                            \
  return Api::NewError("Invalid index passed in to access list element");      \


DART_EXPORT Dart_Handle Dart_ListGetAt(Dart_Handle list, intptr_t index) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(list));
  if (obj.IsArray()) {
    GET_LIST_ELEMENT(isolate, Array, obj, index);
  } else if (obj.IsGrowableObjectArray()) {
    GET_LIST_ELEMENT(isolate, GrowableObjectArray, obj, index);
  } else if (obj.IsError()) {
    return list;
  } else {
    CHECK_CALLBACK_STATE(isolate);

    // Check and handle a dart object that implements the List interface.
    const Instance& instance =
        Instance::Handle(isolate, GetListInstance(isolate, obj));
    if (!instance.IsNull()) {
      const Function& function = Function::Handle(
          isolate,
          Resolver::ResolveDynamic(instance, Symbols::IndexToken(), 2, 0));
      if (!function.IsNull()) {
        const int kNumArgs = 2;
        const Array& args = Array::Handle(isolate, Array::New(kNumArgs));
        const Integer& indexobj = Integer::Handle(isolate, Integer::New(index));
        args.SetAt(0, instance);
        args.SetAt(1, indexobj);
        return Api::NewHandle(isolate, DartEntry::InvokeFunction(function,
                                                                 args));
      }
    }
    return Api::NewError("Object does not implement the 'List' interface");
  }
}


#define SET_LIST_ELEMENT(isolate, type, obj, index, value)                     \
  const type& array = type::Cast(obj);                                         \
  const Object& value_obj = Object::Handle(isolate, Api::UnwrapHandle(value)); \
  if (!value_obj.IsNull() && !value_obj.IsInstance()) {                        \
    RETURN_TYPE_ERROR(isolate, value, Instance);                               \
  }                                                                            \
  if ((index >= 0) && (index < array.Length())) {                              \
    array.SetAt(index, value_obj);                                             \
    return Api::Success(isolate);                                              \
  }                                                                            \
  return Api::NewError("Invalid index passed in to set list element");         \


DART_EXPORT Dart_Handle Dart_ListSetAt(Dart_Handle list,
                                       intptr_t index,
                                       Dart_Handle value) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(list));
  // If the list is immutable we call into Dart for the indexed setter to
  // get the unsupported operation exception as the result.
  if (obj.IsArray() && !obj.IsImmutableArray()) {
    SET_LIST_ELEMENT(isolate, Array, obj, index, value);
  } else if (obj.IsGrowableObjectArray()) {
    SET_LIST_ELEMENT(isolate, GrowableObjectArray, obj, index, value);
  } else if (obj.IsError()) {
    return list;
  } else {
    CHECK_CALLBACK_STATE(isolate);

    // Check and handle a dart object that implements the List interface.
    const Instance& instance =
        Instance::Handle(isolate, GetListInstance(isolate, obj));
    if (!instance.IsNull()) {
      const Function& function = Function::Handle(
          isolate,
          Resolver::ResolveDynamic(instance,
                                   Symbols::AssignIndexToken(),
                                   3,
                                   0));
      if (!function.IsNull()) {
        const Integer& index_obj =
            Integer::Handle(isolate, Integer::New(index));
        const Object& value_obj =
            Object::Handle(isolate, Api::UnwrapHandle(value));
        if (!value_obj.IsNull() && !value_obj.IsInstance()) {
          RETURN_TYPE_ERROR(isolate, value, Instance);
        }
        const intptr_t kNumArgs = 3;
        const Array& args = Array::Handle(isolate, Array::New(kNumArgs));
        args.SetAt(0, instance);
        args.SetAt(1, index_obj);
        args.SetAt(2, value_obj);
        return Api::NewHandle(isolate, DartEntry::InvokeFunction(function,
                                                                 args));
      }
    }
    return Api::NewError("Object does not implement the 'List' interface");
  }
}


static RawObject* ResolveConstructor(const char* current_func,
                                     const Class& cls,
                                     const String& class_name,
                                     const String& dotted_name,
                                     int num_args);


static RawObject* ThrowArgumentError(const char* exception_message) {
  Isolate* isolate = Isolate::Current();
  // Lookup the class ArgumentError in dart:core.
  const String& lib_url = String::Handle(String::New("dart:core"));
  const String& class_name = String::Handle(String::New("ArgumentError"));
  const Library& lib =
      Library::Handle(isolate, Library::LookupLibrary(lib_url));
  if (lib.IsNull()) {
    const String& message = String::Handle(
        String::NewFormatted("%s: library '%s' not found.",
                             CURRENT_FUNC, lib_url.ToCString()));
    return ApiError::New(message);
  }
  const Class& cls = Class::Handle(isolate,
                                   lib.LookupClassAllowPrivate(class_name));
  if (cls.IsNull()) {
    const String& message = String::Handle(
        String::NewFormatted("%s: class '%s' not found in library '%s'.",
                             CURRENT_FUNC, class_name.ToCString(),
                             lib_url.ToCString()));
    return ApiError::New(message);
  }
  Object& result = Object::Handle(isolate);
  String& dot_name = String::Handle(String::New("."));
  String& constr_name = String::Handle(String::Concat(class_name, dot_name));
  result = ResolveConstructor(CURRENT_FUNC, cls, class_name, constr_name, 1);
  if (result.IsError()) return result.raw();
  ASSERT(result.IsFunction());
  Function& constructor = Function::Handle(isolate);
  constructor ^= result.raw();
  if (!constructor.IsConstructor()) {
    const String& message = String::Handle(
        String::NewFormatted("%s: class '%s' is not a constructor.",
                             CURRENT_FUNC, class_name.ToCString()));
    return ApiError::New(message);
  }
  Instance& exception = Instance::Handle(isolate);
  exception = Instance::New(cls);
  const Array& args = Array::Handle(isolate, Array::New(3));
  args.SetAt(0, exception);
  args.SetAt(1,
             Smi::Handle(isolate, Smi::New(Function::kCtorPhaseAll)));
  args.SetAt(2, String::Handle(String::New(exception_message)));
  result = DartEntry::InvokeFunction(constructor, args);
  if (result.IsError()) return result.raw();
  ASSERT(result.IsNull());

  if (isolate->top_exit_frame_info() == 0) {
    // There are no dart frames on the stack so it would be illegal to
    // throw an exception here.
    const String& message = String::Handle(
            String::New("No Dart frames on stack, cannot throw exception"));
    return ApiError::New(message);
  }
  // Unwind all the API scopes till the exit frame before throwing an
  // exception.
  ApiState* state = isolate->api_state();
  ASSERT(state != NULL);
  const Instance* saved_exception;
  {
    NoGCScope no_gc;
    RawInstance* raw_exception = exception.raw();
    state->UnwindScopes(isolate->top_exit_frame_info());
    saved_exception = &Instance::Handle(raw_exception);
  }
  Exceptions::Throw(*saved_exception);
  const String& message = String::Handle(
          String::New("Exception was not thrown, internal error"));
  return ApiError::New(message);
}

// TODO(sgjesse): value should always be smaller then 0xff. Add error handling.
#define GET_LIST_ELEMENT_AS_BYTES(isolate, type, obj, native_array, offset,    \
                                  length)                                      \
  const type& array = type::Cast(obj);                                         \
  if (Utils::RangeCheck(offset, length, array.Length())) {                     \
    Object& element = Object::Handle(isolate);                                 \
    for (int i = 0; i < length; i++) {                                         \
      element = array.At(offset + i);                                          \
      if (!element.IsInteger()) {                                              \
        return Api::NewHandle(                                                 \
            isolate, ThrowArgumentError("List contains non-int elements"));    \
                                                                               \
      }                                                                        \
      const Integer& integer = Integer::Cast(element);                         \
      native_array[i] = static_cast<uint8_t>(integer.AsInt64Value() & 0xff);   \
      ASSERT(integer.AsInt64Value() <= 0xff);                                  \
    }                                                                          \
    return Api::Success(isolate);                                              \
  }                                                                            \
  return Api::NewError("Invalid length passed in to access array elements");   \


DART_EXPORT Dart_Handle Dart_ListGetAsBytes(Dart_Handle list,
                                            intptr_t offset,
                                            uint8_t* native_array,
                                            intptr_t length) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(list));
  if (obj.IsTypedData()) {
    const TypedData& array = TypedData::Cast(obj);
    if (array.ElementSizeInBytes() == 1) {
      if (Utils::RangeCheck(offset, length, array.Length())) {
        NoGCScope no_gc;
        memmove(native_array,
                reinterpret_cast<uint8_t*>(array.DataAddr(offset)),
                length);
        return Api::Success(isolate);
      }
      return Api::NewError("Invalid length passed in to access list elements");
    }
  }
  if (obj.IsArray()) {
    GET_LIST_ELEMENT_AS_BYTES(isolate,
                              Array,
                              obj,
                              native_array,
                              offset,
                              length);
  }
  if (obj.IsGrowableObjectArray()) {
    GET_LIST_ELEMENT_AS_BYTES(isolate,
                              GrowableObjectArray,
                              obj,
                              native_array,
                              offset,
                              length);
  }
  if (obj.IsError()) {
    return list;
  }
  CHECK_CALLBACK_STATE(isolate);

  // Check and handle a dart object that implements the List interface.
  const Instance& instance =
      Instance::Handle(isolate, GetListInstance(isolate, obj));
  if (!instance.IsNull()) {
    const Function& function = Function::Handle(
        isolate,
        Resolver::ResolveDynamic(instance, Symbols::IndexToken(), 2, 0));
    if (!function.IsNull()) {
      Object& result = Object::Handle(isolate);
      Integer& intobj = Integer::Handle(isolate);
      const int kNumArgs = 2;
      const Array& args = Array::Handle(isolate, Array::New(kNumArgs));
      args.SetAt(0, instance);  // Set up the receiver as the first argument.
      for (int i = 0; i < length; i++) {
        intobj = Integer::New(offset + i);
        args.SetAt(1, intobj);
        result = DartEntry::InvokeFunction(function, args);
        if (result.IsError()) {
          return Api::NewHandle(isolate, result.raw());
        }
        if (!result.IsInteger()) {
          return Api::NewError("%s expects the argument 'list' to be "
                               "a List of int", CURRENT_FUNC);
        }
        const Integer& integer_result = Integer::Cast(result);
        ASSERT(integer_result.AsInt64Value() <= 0xff);
        // TODO(hpayer): value should always be smaller then 0xff. Add error
        // handling.
        native_array[i] =
            static_cast<uint8_t>(integer_result.AsInt64Value() & 0xff);
      }
      return Api::Success(isolate);
    }
  }
  return Api::NewError("Object does not implement the 'List' interface");
}


#define SET_LIST_ELEMENT_AS_BYTES(isolate, type, obj, native_array, offset,    \
                                  length)                                      \
  const type& array = type::Cast(obj);                                         \
  Integer& integer = Integer::Handle(isolate);                                 \
  if (Utils::RangeCheck(offset, length, array.Length())) {                     \
    for (int i = 0; i < length; i++) {                                         \
      integer = Integer::New(native_array[i]);                                 \
      array.SetAt(offset + i, integer);                                        \
    }                                                                          \
    return Api::Success(isolate);                                              \
  }                                                                            \
  return Api::NewError("Invalid length passed in to set array elements");      \


DART_EXPORT Dart_Handle Dart_ListSetAsBytes(Dart_Handle list,
                                            intptr_t offset,
                                            uint8_t* native_array,
                                            intptr_t length) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(list));
  if (obj.IsTypedData()) {
    const TypedData& array = TypedData::Cast(obj);
    if (array.ElementSizeInBytes() == 1) {
      if (Utils::RangeCheck(offset, length, array.Length())) {
        NoGCScope no_gc;
        memmove(reinterpret_cast<uint8_t*>(array.DataAddr(offset)),
                native_array,
                length);
        return Api::Success(isolate);
      }
      return Api::NewError("Invalid length passed in to access list elements");
    }
  }
  if (obj.IsArray() && !obj.IsImmutableArray()) {
    // If the list is immutable we call into Dart for the indexed setter to
    // get the unsupported operation exception as the result.
    SET_LIST_ELEMENT_AS_BYTES(isolate,
                              Array,
                              obj,
                              native_array,
                              offset,
                              length);
  }
  if (obj.IsGrowableObjectArray()) {
    SET_LIST_ELEMENT_AS_BYTES(isolate,
                              GrowableObjectArray,
                              obj,
                              native_array,
                              offset,
                              length);
  }
  if (obj.IsError()) {
    return list;
  }
  CHECK_CALLBACK_STATE(isolate);

  // Check and handle a dart object that implements the List interface.
  const Instance& instance =
      Instance::Handle(isolate, GetListInstance(isolate, obj));
  if (!instance.IsNull()) {
    const Function& function = Function::Handle(
        isolate,
        Resolver::ResolveDynamic(instance,
                                 Symbols::AssignIndexToken(),
                                 3,
                                 0));
    if (!function.IsNull()) {
      Integer& indexobj = Integer::Handle(isolate);
      Integer& valueobj = Integer::Handle(isolate);
      const int kNumArgs = 3;
      const Array& args = Array::Handle(isolate, Array::New(kNumArgs));
      args.SetAt(0, instance);  // Set up the receiver as the first argument.
      for (int i = 0; i < length; i++) {
        indexobj = Integer::New(offset + i);
        valueobj = Integer::New(native_array[i]);
        args.SetAt(1, indexobj);
        args.SetAt(2, valueobj);
        const Object& result = Object::Handle(
            isolate, DartEntry::InvokeFunction(function, args));
        if (result.IsError()) {
          return Api::NewHandle(isolate, result.raw());
        }
      }
      return Api::Success(isolate);
    }
  }
  return Api::NewError("Object does not implement the 'List' interface");
}


// --- Typed Data ---


// Helper method to get the type of a TypedData object.
static Dart_TypedData_Type GetType(intptr_t class_id) {
  Dart_TypedData_Type type;
  switch (class_id) {
    case kByteDataViewCid :
      type = kByteData;
      break;
    case kTypedDataInt8ArrayCid :
    case kTypedDataInt8ArrayViewCid :
    case kExternalTypedDataInt8ArrayCid :
      type = kInt8;
      break;
    case kTypedDataUint8ArrayCid :
    case kTypedDataUint8ArrayViewCid :
    case kExternalTypedDataUint8ArrayCid :
      type = kUint8;
      break;
    case kTypedDataUint8ClampedArrayCid :
    case kTypedDataUint8ClampedArrayViewCid :
    case kExternalTypedDataUint8ClampedArrayCid :
      type = kUint8Clamped;
      break;
    case kTypedDataInt16ArrayCid :
    case kTypedDataInt16ArrayViewCid :
    case kExternalTypedDataInt16ArrayCid :
      type = kInt16;
      break;
    case kTypedDataUint16ArrayCid :
    case kTypedDataUint16ArrayViewCid :
    case kExternalTypedDataUint16ArrayCid :
      type = kUint16;
      break;
    case kTypedDataInt32ArrayCid :
    case kTypedDataInt32ArrayViewCid :
    case kExternalTypedDataInt32ArrayCid :
      type = kInt32;
      break;
    case kTypedDataUint32ArrayCid :
    case kTypedDataUint32ArrayViewCid :
    case kExternalTypedDataUint32ArrayCid :
      type = kUint32;
      break;
    case kTypedDataInt64ArrayCid :
    case kTypedDataInt64ArrayViewCid :
    case kExternalTypedDataInt64ArrayCid :
      type = kInt64;
      break;
    case kTypedDataUint64ArrayCid :
    case kTypedDataUint64ArrayViewCid :
    case kExternalTypedDataUint64ArrayCid :
      type = kUint64;
      break;
    case kTypedDataFloat32ArrayCid :
    case kTypedDataFloat32ArrayViewCid :
    case kExternalTypedDataFloat32ArrayCid :
      type = kFloat32;
      break;
    case kTypedDataFloat64ArrayCid :
    case kTypedDataFloat64ArrayViewCid :
    case kExternalTypedDataFloat64ArrayCid :
      type = kFloat64;
      break;
    case kTypedDataFloat32x4ArrayCid :
    case kTypedDataFloat32x4ArrayViewCid :
    case kExternalTypedDataFloat32x4ArrayCid :
      type = kFloat32x4;
      break;
    default:
      type = kInvalid;
      break;
  }
  return type;
}


DART_EXPORT Dart_TypedData_Type Dart_GetTypeOfTypedData(Dart_Handle object) {
  intptr_t class_id = Api::ClassId(object);
  if (RawObject::IsTypedDataClassId(class_id) ||
      RawObject::IsTypedDataViewClassId(class_id)) {
    return GetType(class_id);
  }
  return kInvalid;
}


DART_EXPORT Dart_TypedData_Type Dart_GetTypeOfExternalTypedData(
    Dart_Handle object) {
  intptr_t class_id = Api::ClassId(object);
  if (RawObject::IsExternalTypedDataClassId(class_id) ||
      RawObject::IsTypedDataViewClassId(class_id)) {
    return GetType(class_id);
  }
  return kInvalid;
}


static RawObject* GetByteDataConstructor(Isolate* isolate,
                                         const String& constructor_name,
                                         intptr_t num_args) {
  const Library& lib =
      Library::Handle(isolate->object_store()->typed_data_library());
  ASSERT(!lib.IsNull());
  const Class& cls =
      Class::Handle(isolate, lib.LookupClassAllowPrivate(Symbols::ByteData()));
  ASSERT(!cls.IsNull());
  return ResolveConstructor(CURRENT_FUNC,
                            cls,
                            Symbols::ByteData(),
                            constructor_name,
                            num_args);
}


static Dart_Handle NewByteData(Isolate* isolate, intptr_t length) {
  CHECK_LENGTH(length, TypedData::MaxElements(kTypedDataInt8ArrayCid));
  Object& result = Object::Handle(isolate);
  result = GetByteDataConstructor(isolate, Symbols::ByteDataDot(), 1);
  ASSERT(!result.IsNull());
  ASSERT(result.IsFunction());
  const Function& factory = Function::Cast(result);
  ASSERT(!factory.IsConstructor());

  // Create the argument list.
  const Array& args = Array::Handle(isolate, Array::New(2));
  // Factories get type arguments.
  args.SetAt(0, TypeArguments::Handle(isolate));
  args.SetAt(1, Smi::Handle(isolate, Smi::New(length)));

  // Invoke the constructor and return the new object.
  result = DartEntry::InvokeFunction(factory, args);
  ASSERT(result.IsInstance() || result.IsNull() || result.IsError());
  return Api::NewHandle(isolate, result.raw());
}


static Dart_Handle NewTypedData(Isolate* isolate,
                                intptr_t cid,
                                intptr_t length) {
  CHECK_LENGTH(length, TypedData::MaxElements(cid));
  return Api::NewHandle(isolate, TypedData::New(cid, length));
}


static Dart_Handle NewExternalTypedData(
    intptr_t cid,
    void* data,
    intptr_t length,
    void* peer,
    Dart_WeakPersistentHandleFinalizer callback) {
  CHECK_LENGTH(length, ExternalTypedData::MaxElements(cid));
  const ExternalTypedData& obj = ExternalTypedData::Handle(
      ExternalTypedData::New(cid,
                             reinterpret_cast<uint8_t*>(data),
                             length));
  return reinterpret_cast<Dart_Handle>(obj.AddFinalizer(peer, callback));
}


static Dart_Handle NewExternalByteData(Isolate* isolate,
                                       void* data,
                                       intptr_t length,
                                       void* peer,
                                       Dart_WeakPersistentHandleFinalizer cb) {
  Dart_Handle ext_data = NewExternalTypedData(kExternalTypedDataUint8ArrayCid,
                                              data,
                                              length,
                                              peer,
                                              cb);
  if (::Dart_IsError(ext_data)) {
    return ext_data;
  }
  Object& result = Object::Handle(isolate);
  result = GetByteDataConstructor(isolate, Symbols::ByteDataDotview(), 3);
  ASSERT(!result.IsNull());
  ASSERT(result.IsFunction());
  const Function& factory = Function::Cast(result);
  ASSERT(!factory.IsConstructor());

  // Create the argument list.
  const intptr_t num_args = 3;
  const Array& args = Array::Handle(isolate, Array::New(num_args + 1));
  // Factories get type arguments.
  args.SetAt(0, TypeArguments::Handle(isolate));
  const ExternalTypedData& array =
      Api::UnwrapExternalTypedDataHandle(isolate, ext_data);
  args.SetAt(1, array);
  Smi& smi = Smi::Handle(isolate);
  smi = Smi::New(0);
  args.SetAt(2, smi);
  smi = Smi::New(length);
  args.SetAt(3, smi);

  // Invoke the constructor and return the new object.
  result = DartEntry::InvokeFunction(factory, args);
  ASSERT(result.IsNull() || result.IsInstance() || result.IsError());
  return Api::NewHandle(isolate, result.raw());
}


DART_EXPORT Dart_Handle Dart_NewTypedData(Dart_TypedData_Type type,
                                          intptr_t length) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  CHECK_CALLBACK_STATE(isolate);
  switch (type) {
    case kByteData :
      return NewByteData(isolate, length);
    case kInt8 :
      return NewTypedData(isolate, kTypedDataInt8ArrayCid, length);
    case kUint8 :
      return NewTypedData(isolate, kTypedDataUint8ArrayCid, length);
    case kUint8Clamped :
      return NewTypedData(isolate, kTypedDataUint8ClampedArrayCid, length);
    case kInt16 :
      return NewTypedData(isolate, kTypedDataInt16ArrayCid, length);
    case kUint16 :
      return NewTypedData(isolate, kTypedDataUint16ArrayCid, length);
    case kInt32 :
      return NewTypedData(isolate, kTypedDataInt32ArrayCid, length);
    case kUint32 :
      return NewTypedData(isolate, kTypedDataUint32ArrayCid, length);
    case kInt64 :
      return NewTypedData(isolate, kTypedDataInt64ArrayCid, length);
    case kUint64 :
      return NewTypedData(isolate, kTypedDataUint64ArrayCid, length);
    case kFloat32 :
      return NewTypedData(isolate, kTypedDataFloat32ArrayCid,  length);
    case kFloat64 :
      return NewTypedData(isolate, kTypedDataFloat64ArrayCid, length);
    case kFloat32x4:
      return NewTypedData(isolate, kTypedDataFloat32x4ArrayCid, length);
    default:
      return Api::NewError("%s expects argument 'type' to be of 'TypedData'",
                           CURRENT_FUNC);
  }
  UNREACHABLE();
  return Api::Null(isolate);
}


DART_EXPORT Dart_Handle Dart_NewExternalTypedData(
    Dart_TypedData_Type type,
    void* data,
    intptr_t length,
    void* peer,
    Dart_WeakPersistentHandleFinalizer callback) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (data == NULL && length != 0) {
    RETURN_NULL_ERROR(data);
  }
  CHECK_CALLBACK_STATE(isolate);
  switch (type) {
    case kByteData:
      return NewExternalByteData(isolate, data, length, peer, callback);
    case kInt8:
      return NewExternalTypedData(kExternalTypedDataInt8ArrayCid,
                                  data,
                                  length,
                                  peer,
                                  callback);
    case kUint8:
      return NewExternalTypedData(kExternalTypedDataUint8ArrayCid,
                                  data,
                                  length,
                                  peer,
                                  callback);
    case kUint8Clamped:
      return NewExternalTypedData(kExternalTypedDataUint8ClampedArrayCid,
                                  data,
                                  length,
                                  peer,
                                  callback);
    case kInt16:
      return NewExternalTypedData(kExternalTypedDataInt16ArrayCid,
                                  data,
                                  length,
                                  peer,
                                  callback);
    case kUint16:
      return NewExternalTypedData(kExternalTypedDataUint16ArrayCid,
                                  data,
                                  length,
                                  peer,
                                  callback);
    case kInt32:
      return NewExternalTypedData(kExternalTypedDataInt32ArrayCid,
                                  data,
                                  length,
                                  peer,
                                  callback);
    case kUint32:
      return NewExternalTypedData(kExternalTypedDataUint32ArrayCid,
                                  data,
                                  length,
                                  peer,
                                  callback);
    case kInt64:
      return NewExternalTypedData(kExternalTypedDataInt64ArrayCid,
                                  data,
                                  length,
                                  peer,
                                  callback);
    case kUint64:
      return NewExternalTypedData(kExternalTypedDataUint64ArrayCid,
                                  data,
                                  length,
                                  peer,
                                  callback);
    case kFloat32:
      return NewExternalTypedData(kExternalTypedDataFloat32ArrayCid,
                                  data,
                                  length,
                                  peer,
                                  callback);
    case kFloat64:
      return NewExternalTypedData(kExternalTypedDataFloat64ArrayCid,
                                  data,
                                  length,
                                  peer,
                                  callback);
    case kFloat32x4:
      return NewExternalTypedData(kExternalTypedDataFloat32x4ArrayCid,
                                  data,
                                  length,
                                  peer,
                                  callback);
    default:
      return Api::NewError("%s expects argument 'type' to be of"
                           " 'external TypedData'", CURRENT_FUNC);
  }
  UNREACHABLE();
  return Api::Null(isolate);
}


DART_EXPORT Dart_Handle Dart_ExternalTypedDataGetPeer(Dart_Handle object,
                                                      void** peer) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const ExternalTypedData& array =
      Api::UnwrapExternalTypedDataHandle(isolate, object);
  if (array.IsNull()) {
    RETURN_TYPE_ERROR(isolate, object, ExternalTypedData);
  }
  if (peer == NULL) {
    RETURN_NULL_ERROR(peer);
  }
  *peer = array.GetPeer();
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_TypedDataAcquireData(Dart_Handle object,
                                                  Dart_TypedData_Type* type,
                                                  void** data,
                                                  intptr_t* len) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  intptr_t class_id = Api::ClassId(object);
  if (!RawObject::IsExternalTypedDataClassId(class_id) &&
      !RawObject::IsTypedDataViewClassId(class_id) &&
      !RawObject::IsTypedDataClassId(class_id)) {
    RETURN_TYPE_ERROR(isolate, object, 'TypedData');
  }
  if (type == NULL) {
    RETURN_NULL_ERROR(type);
  }
  if (data == NULL) {
    RETURN_NULL_ERROR(data);
  }
  if (len == NULL) {
    RETURN_NULL_ERROR(len);
  }
  // Get the type of typed data object.
  *type = GetType(class_id);
  // If it is an external typed data object just return the data field.
  if (RawObject::IsExternalTypedDataClassId(class_id)) {
    const ExternalTypedData& obj =
        Api::UnwrapExternalTypedDataHandle(isolate, object);
    ASSERT(!obj.IsNull());
    *len = obj.Length();
    *data = obj.DataAddr(0);
  } else if (RawObject::IsTypedDataClassId(class_id)) {
    // Regular typed data object, set up some GC and API callback guards.
    const TypedData& obj = Api::UnwrapTypedDataHandle(isolate, object);
    ASSERT(!obj.IsNull());
    *len = obj.Length();
    isolate->IncrementNoGCScopeDepth();
    START_NO_CALLBACK_SCOPE(isolate);
    *data = obj.DataAddr(0);
  } else {
    ASSERT(RawObject::IsTypedDataViewClassId(class_id));
    const Instance& view_obj = Api::UnwrapInstanceHandle(isolate, object);
    ASSERT(!view_obj.IsNull());
    Smi& val = Smi::Handle();
    val ^= TypedDataView::Length(view_obj);
    *len = val.Value();
    val ^= TypedDataView::OffsetInBytes(view_obj);
    intptr_t offset_in_bytes = val.Value();
    const Instance& obj = Instance::Handle(TypedDataView::Data(view_obj));
    isolate->IncrementNoGCScopeDepth();
    START_NO_CALLBACK_SCOPE(isolate);
    if (TypedData::IsTypedData(obj)) {
      const TypedData& data_obj = TypedData::Cast(obj);
      *data = data_obj.DataAddr(offset_in_bytes);
    } else {
      ASSERT(ExternalTypedData::IsExternalTypedData(obj));
      const ExternalTypedData& data_obj = ExternalTypedData::Cast(obj);
      *data = data_obj.DataAddr(offset_in_bytes);
    }
  }
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_TypedDataReleaseData(Dart_Handle object) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  intptr_t class_id = Api::ClassId(object);
  if (!RawObject::IsExternalTypedDataClassId(class_id) &&
      !RawObject::IsTypedDataViewClassId(class_id) &&
      !RawObject::IsTypedDataClassId(class_id)) {
    RETURN_TYPE_ERROR(isolate, object, 'TypedData');
  }
  if (!RawObject::IsExternalTypedDataClassId(class_id)) {
    isolate->DecrementNoGCScopeDepth();
    END_NO_CALLBACK_SCOPE(isolate);
  }
  return Api::Success(isolate);
}


// --- Closures ---


DART_EXPORT bool Dart_IsClosure(Dart_Handle object) {
  // We can't use a fast class index check here because there are many
  // different signature classes for closures.
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Instance& closure_obj = Api::UnwrapInstanceHandle(isolate, object);
  return (!closure_obj.IsNull() && closure_obj.IsClosure());
}


DART_EXPORT Dart_Handle Dart_ClosureFunction(Dart_Handle closure) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Instance& closure_obj = Api::UnwrapInstanceHandle(isolate, closure);
  if (closure_obj.IsNull() || !closure_obj.IsClosure()) {
    RETURN_TYPE_ERROR(isolate, closure, Instance);
  }

  ASSERT(ClassFinalizer::AllClassesFinalized());

  RawFunction* rf = Closure::function(closure_obj);
  return Api::NewHandle(isolate, rf);
}


DART_EXPORT Dart_Handle Dart_InvokeClosure(Dart_Handle closure,
                                           int number_of_arguments,
                                           Dart_Handle* arguments) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  CHECK_CALLBACK_STATE(isolate);
  const Instance& closure_obj = Api::UnwrapInstanceHandle(isolate, closure);
  if (closure_obj.IsNull() || !closure_obj.IsCallable(NULL, NULL)) {
    RETURN_TYPE_ERROR(isolate, closure, Instance);
  }
  if (number_of_arguments < 0) {
    return Api::NewError(
        "%s expects argument 'number_of_arguments' to be non-negative.",
        CURRENT_FUNC);
  }
  ASSERT(ClassFinalizer::AllClassesFinalized());

  // Set up arguments to include the closure as the first argument.
  const Array& args = Array::Handle(isolate,
                                    Array::New(number_of_arguments + 1));
  Object& obj = Object::Handle(isolate);
  args.SetAt(0, closure_obj);
  for (int i = 0; i < number_of_arguments; i++) {
    obj = Api::UnwrapHandle(arguments[i]);
    if (!obj.IsNull() && !obj.IsInstance()) {
      RETURN_TYPE_ERROR(isolate, arguments[i], Instance);
    }
    args.SetAt(i + 1, obj);
  }
  // Now try to invoke the closure.
  return Api::NewHandle(isolate, DartEntry::InvokeClosure(args));
}


// --- Classes ---


DART_EXPORT bool Dart_IsClass(Dart_Handle handle) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(handle));
  return obj.IsClass();
}


DART_EXPORT bool Dart_IsAbstractClass(Dart_Handle handle) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(handle));
  if (obj.IsClass()) {
    return Class::Cast(obj).is_abstract();
  }
  return false;
}


DART_EXPORT Dart_Handle Dart_ClassName(Dart_Handle clazz) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Class& cls = Api::UnwrapClassHandle(isolate, clazz);
  if (cls.IsNull()) {
    RETURN_TYPE_ERROR(isolate, clazz, Class);
  }
  return Api::NewHandle(isolate, cls.UserVisibleName());
}


DART_EXPORT Dart_Handle Dart_ClassGetLibrary(Dart_Handle clazz) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Class& cls = Api::UnwrapClassHandle(isolate, clazz);
  if (cls.IsNull()) {
    RETURN_TYPE_ERROR(isolate, clazz, Class);
  }

#if defined(DEBUG)
  const Library& lib = Library::Handle(cls.library());
  if (lib.IsNull()) {
    // ASSERT(cls.IsDynamicClass() || cls.IsVoidClass());
    if (!cls.IsDynamicClass() && !cls.IsVoidClass()) {
      fprintf(stderr, "NO LIBRARY: %s\n", cls.ToCString());
    }
  }
#endif

  return Api::NewHandle(isolate, cls.library());
}


DART_EXPORT Dart_Handle Dart_ClassGetInterfaceCount(Dart_Handle clazz,
                                                    intptr_t* count) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Class& cls = Api::UnwrapClassHandle(isolate, clazz);
  if (cls.IsNull()) {
    RETURN_TYPE_ERROR(isolate, clazz, Class);
  }

  const Array& interface_types = Array::Handle(isolate, cls.interfaces());
  if (interface_types.IsNull()) {
    *count = 0;
  } else {
    *count = interface_types.Length();
  }
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_ClassGetInterfaceAt(Dart_Handle clazz,
                                                 intptr_t index) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Class& cls = Api::UnwrapClassHandle(isolate, clazz);
  if (cls.IsNull()) {
    RETURN_TYPE_ERROR(isolate, clazz, Class);
  }

  // Finalize all classes.
  Dart_Handle state = Api::CheckIsolateState(isolate);
  if (::Dart_IsError(state)) {
    return state;
  }

  const Array& interface_types = Array::Handle(isolate, cls.interfaces());
  if (index < 0 || index >= interface_types.Length()) {
    return Api::NewError("%s: argument 'index' out of bounds.", CURRENT_FUNC);
  }
  Type& interface_type = Type::Handle(isolate);
  interface_type ^= interface_types.At(index);
  if (interface_type.HasResolvedTypeClass()) {
    return Api::NewHandle(isolate, interface_type.type_class());
  }
  const String& type_name =
      String::Handle(isolate, interface_type.TypeClassName());
  return Api::NewError("%s: internal error: found unresolved type class '%s'.",
                       CURRENT_FUNC, type_name.ToCString());
}


DART_EXPORT bool Dart_ClassIsTypedef(Dart_Handle clazz) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Class& cls = Api::UnwrapClassHandle(isolate, clazz);
  if (cls.IsNull()) {
    RETURN_TYPE_ERROR(isolate, clazz, Class);
  }
  // For now we represent typedefs as non-canonical signature classes.
  // I anticipate this may change if we make typedefs more general.
  return cls.IsSignatureClass() && !cls.IsCanonicalSignatureClass();
}


DART_EXPORT Dart_Handle Dart_ClassGetTypedefReferent(Dart_Handle clazz) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Class& cls = Api::UnwrapClassHandle(isolate, clazz);
  if (cls.IsNull()) {
    RETURN_TYPE_ERROR(isolate, clazz, Class);
  }

  if (!cls.IsSignatureClass() && !cls.IsCanonicalSignatureClass()) {
    const String& cls_name = String::Handle(cls.UserVisibleName());
    return Api::NewError("%s: class '%s' is not a typedef class. "
                         "See Dart_ClassIsTypedef.",
                         CURRENT_FUNC, cls_name.ToCString());
  }

  const Function& func = Function::Handle(isolate, cls.signature_function());
  return Api::NewHandle(isolate, func.signature_class());
}


DART_EXPORT bool Dart_ClassIsFunctionType(Dart_Handle clazz) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Class& cls = Api::UnwrapClassHandle(isolate, clazz);
  if (cls.IsNull()) {
    RETURN_TYPE_ERROR(isolate, clazz, Class);
  }
  // A class represents a function type when it is a canonical
  // signature class.
  return cls.IsCanonicalSignatureClass();
}


DART_EXPORT Dart_Handle Dart_ClassGetFunctionTypeSignature(Dart_Handle clazz) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Class& cls = Api::UnwrapClassHandle(isolate, clazz);
  if (cls.IsNull()) {
    RETURN_TYPE_ERROR(isolate, clazz, Class);
  }
  if (!cls.IsCanonicalSignatureClass()) {
    const String& cls_name = String::Handle(cls.UserVisibleName());
    return Api::NewError("%s: class '%s' is not a function-type class. "
                         "See Dart_ClassIsFunctionType.",
                         CURRENT_FUNC, cls_name.ToCString());
  }
  return Api::NewHandle(isolate, cls.signature_function());
}


// --- Function and Variable Reflection ---


// Outside of the vm, we expose setter names with a trailing '='.
static bool HasExternalSetterSuffix(const String& name) {
  return name.CharAt(name.Length() - 1) == '=';
}


static RawString* RemoveExternalSetterSuffix(const String& name) {
  ASSERT(HasExternalSetterSuffix(name));
  return String::SubString(name, 0, name.Length() - 1);
}


DART_EXPORT Dart_Handle Dart_GetFunctionNames(Dart_Handle target) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(target));
  if (obj.IsError()) {
    return target;
  }

  const GrowableObjectArray& names =
      GrowableObjectArray::Handle(isolate, GrowableObjectArray::New());
  Function& func = Function::Handle();
  String& name = String::Handle();

  if (obj.IsClass()) {
    const Class& cls = Class::Cast(obj);
    const Array& func_array = Array::Handle(cls.functions());

    // Some special types like 'dynamic' have a null functions list.
    if (!func_array.IsNull()) {
      for (intptr_t i = 0; i < func_array.Length(); ++i) {
        func ^= func_array.At(i);

        // Skip implicit getters and setters.
        if (func.kind() == RawFunction::kImplicitGetter ||
            func.kind() == RawFunction::kImplicitSetter ||
            func.kind() == RawFunction::kConstImplicitGetter ||
            func.kind() == RawFunction::kMethodExtractor) {
          continue;
        }

        name = func.UserVisibleName();
        names.Add(name);
      }
    }
  } else if (obj.IsLibrary()) {
    const Library& lib = Library::Cast(obj);
    DictionaryIterator it(lib);
    Object& obj = Object::Handle();
    while (it.HasNext()) {
      obj = it.GetNext();
      if (obj.IsFunction()) {
        func ^= obj.raw();
        name = func.UserVisibleName();
        names.Add(name);
      }
    }
  } else {
    return Api::NewError(
        "%s expects argument 'target' to be a class or library.",
        CURRENT_FUNC);
  }
  return Api::NewHandle(isolate, Array::MakeArray(names));
}


DART_EXPORT Dart_Handle Dart_LookupFunction(Dart_Handle target,
                                            Dart_Handle function_name) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(target));
  if (obj.IsError()) {
    return target;
  }
  const String& func_name = Api::UnwrapStringHandle(isolate, function_name);
  if (func_name.IsNull()) {
    RETURN_TYPE_ERROR(isolate, function_name, String);
  }

  Function& func = Function::Handle(isolate);
  String& tmp_name = String::Handle(isolate);
  if (obj.IsClass()) {
    const Class& cls = Class::Cast(obj);

    // Case 1.  Lookup the unmodified function name.
    func = cls.LookupFunctionAllowPrivate(func_name);

    // Case 2.  Lookup the function without the external setter suffix
    // '='.  Make sure to do this check after the regular lookup, so
    // that we don't interfere with operator lookups (like ==).
    if (func.IsNull() && HasExternalSetterSuffix(func_name)) {
      tmp_name = RemoveExternalSetterSuffix(func_name);
      tmp_name = Field::SetterName(tmp_name);
      func = cls.LookupFunctionAllowPrivate(tmp_name);
    }

    // Case 3.  Lookup the funciton with the getter prefix prepended.
    if (func.IsNull()) {
      tmp_name = Field::GetterName(func_name);
      func = cls.LookupFunctionAllowPrivate(tmp_name);
    }

    // Case 4.  Lookup the function with a . appended to find the
    // unnamed constructor.
    if (func.IsNull()) {
      tmp_name = String::Concat(func_name, Symbols::Dot());
      func = cls.LookupFunctionAllowPrivate(tmp_name);
    }
  } else if (obj.IsLibrary()) {
    const Library& lib = Library::Cast(obj);

    // Case 1.  Lookup the unmodified function name.
    func = lib.LookupFunctionAllowPrivate(func_name);

    // Case 2.  Lookup the function without the external setter suffix
    // '='.  Make sure to do this check after the regular lookup, so
    // that we don't interfere with operator lookups (like ==).
    if (func.IsNull() && HasExternalSetterSuffix(func_name)) {
      tmp_name = RemoveExternalSetterSuffix(func_name);
      tmp_name = Field::SetterName(tmp_name);
      func = lib.LookupFunctionAllowPrivate(tmp_name);
    }

    // Case 3.  Lookup the function with the getter prefix prepended.
    if (func.IsNull()) {
      tmp_name = Field::GetterName(func_name);
      func = lib.LookupFunctionAllowPrivate(tmp_name);
    }
  } else {
    return Api::NewError(
        "%s expects argument 'target' to be a class or library.",
        CURRENT_FUNC);
  }

#if defined(DEBUG)
  if (!func.IsNull()) {
    // We only provide access to a subset of function kinds.
    RawFunction::Kind func_kind = func.kind();
    ASSERT(func_kind == RawFunction::kRegularFunction ||
           func_kind == RawFunction::kGetterFunction ||
           func_kind == RawFunction::kSetterFunction ||
           func_kind == RawFunction::kConstructor);
  }
#endif
  return Api::NewHandle(isolate, func.raw());
}


DART_EXPORT bool Dart_IsFunction(Dart_Handle handle) {
  return Api::ClassId(handle) == kFunctionCid;
}


DART_EXPORT Dart_Handle Dart_FunctionName(Dart_Handle function) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Function& func = Api::UnwrapFunctionHandle(isolate, function);
  if (func.IsNull()) {
    RETURN_TYPE_ERROR(isolate, function, Function);
  }
  return Api::NewHandle(isolate, func.UserVisibleName());
}


DART_EXPORT Dart_Handle Dart_FunctionOwner(Dart_Handle function) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Function& func = Api::UnwrapFunctionHandle(isolate, function);
  if (func.IsNull()) {
    RETURN_TYPE_ERROR(isolate, function, Function);
  }
  if (func.IsNonImplicitClosureFunction()) {
    RawFunction* parent_function = func.parent_function();
    return Api::NewHandle(isolate, parent_function);
  }
  const Class& owner = Class::Handle(func.Owner());
  ASSERT(!owner.IsNull());
  if (owner.IsTopLevel()) {
    // Top-level functions are implemented as members of a hidden class. We hide
    // that class here and instead answer the library.
#if defined(DEBUG)
    const Library& lib = Library::Handle(owner.library());
    if (lib.IsNull()) {
      ASSERT(owner.IsDynamicClass() || owner.IsVoidClass());
    }
#endif
    return Api::NewHandle(isolate, owner.library());
  } else {
    return Api::NewHandle(isolate, owner.raw());
  }
}


DART_EXPORT Dart_Handle Dart_FunctionIsAbstract(Dart_Handle function,
                                                bool* is_abstract) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (is_abstract == NULL) {
    RETURN_NULL_ERROR(is_abstract);
  }
  const Function& func = Api::UnwrapFunctionHandle(isolate, function);
  if (func.IsNull()) {
    RETURN_TYPE_ERROR(isolate, function, Function);
  }
  *is_abstract = func.is_abstract();
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_FunctionIsStatic(Dart_Handle function,
                                              bool* is_static) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (is_static == NULL) {
    RETURN_NULL_ERROR(is_static);
  }
  const Function& func = Api::UnwrapFunctionHandle(isolate, function);
  if (func.IsNull()) {
    RETURN_TYPE_ERROR(isolate, function, Function);
  }
  *is_static = func.is_static();
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_FunctionIsConstructor(Dart_Handle function,
                                                   bool* is_constructor) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (is_constructor == NULL) {
    RETURN_NULL_ERROR(is_constructor);
  }
  const Function& func = Api::UnwrapFunctionHandle(isolate, function);
  if (func.IsNull()) {
    RETURN_TYPE_ERROR(isolate, function, Function);
  }
  *is_constructor = func.kind() == RawFunction::kConstructor;
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_FunctionIsGetter(Dart_Handle function,
                                              bool* is_getter) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (is_getter == NULL) {
    RETURN_NULL_ERROR(is_getter);
  }
  const Function& func = Api::UnwrapFunctionHandle(isolate, function);
  if (func.IsNull()) {
    RETURN_TYPE_ERROR(isolate, function, Function);
  }
  *is_getter = func.IsGetterFunction();
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_FunctionIsSetter(Dart_Handle function,
                                              bool* is_setter) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (is_setter == NULL) {
    RETURN_NULL_ERROR(is_setter);
  }
  const Function& func = Api::UnwrapFunctionHandle(isolate, function);
  if (func.IsNull()) {
    RETURN_TYPE_ERROR(isolate, function, Function);
  }
  *is_setter = (func.kind() == RawFunction::kSetterFunction);
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_FunctionReturnType(Dart_Handle function) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Function& func = Api::UnwrapFunctionHandle(isolate, function);
  if (func.IsNull()) {
    RETURN_TYPE_ERROR(isolate, function, Function);
  }

  if (func.kind() == RawFunction::kConstructor) {
    // Special case the return type for constructors.  Inside the vm
    // we mark them as returning dynamic, but for the purposes of
    // reflection, they return the type of the class being
    // constructed.
    return Api::NewHandle(isolate, func.Owner());
  } else {
    const AbstractType& return_type =
        AbstractType::Handle(isolate, func.result_type());
    return TypeToHandle(isolate, "Dart_FunctionReturnType", return_type);
  }
}


DART_EXPORT Dart_Handle Dart_FunctionParameterCounts(
    Dart_Handle function,
    int64_t* fixed_param_count,
    int64_t* opt_param_count) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (fixed_param_count == NULL) {
    RETURN_NULL_ERROR(fixed_param_count);
  }
  if (opt_param_count == NULL) {
    RETURN_NULL_ERROR(opt_param_count);
  }
  const Function& func = Api::UnwrapFunctionHandle(isolate, function);
  if (func.IsNull()) {
    RETURN_TYPE_ERROR(isolate, function, Function);
  }

  // We hide implicit parameters, such as a method's receiver. This is
  // consistent with Invoke or New, which don't expect their callers to
  // provide them in the argument lists they are handed.
  *fixed_param_count = func.num_fixed_parameters() -
                       func.NumImplicitParameters();
  // TODO(regis): Separately report named and positional optional param counts.
  *opt_param_count = func.NumOptionalParameters();

  ASSERT(*fixed_param_count >= 0);
  ASSERT(*opt_param_count >= 0);

  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_FunctionParameterType(Dart_Handle function,
                                                   int parameter_index) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Function& func = Api::UnwrapFunctionHandle(isolate, function);
  if (func.IsNull()) {
    RETURN_TYPE_ERROR(isolate, function, Function);
  }

  const intptr_t num_implicit_params = func.NumImplicitParameters();
  const intptr_t num_params = func.NumParameters() - num_implicit_params;
  if (parameter_index < 0 || parameter_index >= num_params) {
    return Api::NewError(
        "%s: argument 'parameter_index' out of range. "
        "Expected 0..%"Pd" but saw %d.",
        CURRENT_FUNC, num_params, parameter_index);
  }
  const AbstractType& param_type =
      AbstractType::Handle(isolate, func.ParameterTypeAt(
          num_implicit_params + parameter_index));
  return TypeToHandle(isolate, "Dart_FunctionParameterType", param_type);
}


DART_EXPORT Dart_Handle Dart_GetVariableNames(Dart_Handle target) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(target));
  if (obj.IsError()) {
    return target;
  }

  const GrowableObjectArray& names =
      GrowableObjectArray::Handle(isolate, GrowableObjectArray::New());
  Field& field = Field::Handle(isolate);
  String& name = String::Handle(isolate);

  if (obj.IsClass()) {
    const Class& cls = Class::Cast(obj);
    const Array& field_array = Array::Handle(cls.fields());

    // Some special types like 'dynamic' have a null fields list.
    //
    // TODO(turnidge): Fix 'dynamic' so that it does not have a null
    // fields list.  This will have to wait until the empty array is
    // allocated in the vm isolate.
    if (!field_array.IsNull()) {
      for (intptr_t i = 0; i < field_array.Length(); ++i) {
        field ^= field_array.At(i);
        name = field.UserVisibleName();
        names.Add(name);
      }
    }
  } else if (obj.IsLibrary()) {
    const Library& lib = Library::Cast(obj);
    DictionaryIterator it(lib);
    Object& obj = Object::Handle(isolate);
    while (it.HasNext()) {
      obj = it.GetNext();
      if (obj.IsField()) {
        field ^= obj.raw();
        name = field.UserVisibleName();
        names.Add(name);
      }
    }
  } else {
    return Api::NewError(
        "%s expects argument 'target' to be a class or library.",
        CURRENT_FUNC);
  }
  return Api::NewHandle(isolate, Array::MakeArray(names));
}


DART_EXPORT Dart_Handle Dart_LookupVariable(Dart_Handle target,
                                            Dart_Handle variable_name) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(target));
  if (obj.IsError()) {
    return target;
  }
  const String& var_name = Api::UnwrapStringHandle(isolate, variable_name);
  if (var_name.IsNull()) {
    RETURN_TYPE_ERROR(isolate, variable_name, String);
  }
  if (obj.IsClass()) {
    const Class& cls = Class::Cast(obj);
    return Api::NewHandle(isolate, cls.LookupField(var_name));
  }
  if (obj.IsLibrary()) {
    const Library& lib = Library::Cast(obj);
    return Api::NewHandle(isolate, lib.LookupFieldAllowPrivate(var_name));
  }
  return Api::NewError(
      "%s expects argument 'target' to be a class or library.",
      CURRENT_FUNC);
}


DART_EXPORT bool Dart_IsVariable(Dart_Handle handle) {
  return Api::ClassId(handle) == kFieldCid;
}


DART_EXPORT Dart_Handle Dart_VariableName(Dart_Handle variable) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Field& var = Api::UnwrapFieldHandle(isolate, variable);
  if (var.IsNull()) {
    RETURN_TYPE_ERROR(isolate, variable, Field);
  }
  return Api::NewHandle(isolate, var.UserVisibleName());
}


DART_EXPORT Dart_Handle Dart_VariableIsStatic(Dart_Handle variable,
                                              bool* is_static) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (is_static == NULL) {
    RETURN_NULL_ERROR(is_static);
  }
  const Field& var = Api::UnwrapFieldHandle(isolate, variable);
  if (var.IsNull()) {
    RETURN_TYPE_ERROR(isolate, variable, Field);
  }
  *is_static = var.is_static();
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_VariableIsFinal(Dart_Handle variable,
                                             bool* is_final) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  if (is_final == NULL) {
    RETURN_NULL_ERROR(is_final);
  }
  const Field& var = Api::UnwrapFieldHandle(isolate, variable);
  if (var.IsNull()) {
    RETURN_TYPE_ERROR(isolate, variable, Field);
  }
  *is_final = var.is_final();
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_VariableType(Dart_Handle variable) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Field& var = Api::UnwrapFieldHandle(isolate, variable);
  if (var.IsNull()) {
    RETURN_TYPE_ERROR(isolate, variable, Field);
  }

  const AbstractType& type = AbstractType::Handle(isolate, var.type());
  return TypeToHandle(isolate, "Dart_VariableType", type);
}


DART_EXPORT Dart_Handle Dart_GetTypeVariableNames(Dart_Handle clazz) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Class& cls = Api::UnwrapClassHandle(isolate, clazz);
  if (cls.IsNull()) {
    RETURN_TYPE_ERROR(isolate, clazz, Class);
  }

  const intptr_t num_type_params = cls.NumTypeParameters();
  const TypeArguments& type_params =
      TypeArguments::Handle(cls.type_parameters());

  const GrowableObjectArray& names =
      GrowableObjectArray::Handle(isolate, GrowableObjectArray::New());
  TypeParameter& type_param = TypeParameter::Handle(isolate);
  String& name = String::Handle(isolate);
  for (intptr_t i = 0; i < num_type_params; i++) {
    type_param ^= type_params.TypeAt(i);
    name = type_param.name();
    names.Add(name);
  }
  return Api::NewHandle(isolate, Array::MakeArray(names));
}


DART_EXPORT Dart_Handle Dart_LookupTypeVariable(
    Dart_Handle clazz,
    Dart_Handle type_variable_name) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Class& cls = Api::UnwrapClassHandle(isolate, clazz);
  if (cls.IsNull()) {
    RETURN_TYPE_ERROR(isolate, clazz, Class);
  }
  const String& var_name = Api::UnwrapStringHandle(isolate, type_variable_name);
  if (var_name.IsNull()) {
    RETURN_TYPE_ERROR(isolate, type_variable_name, String);
  }

  const intptr_t num_type_params = cls.NumTypeParameters();
  const TypeArguments& type_params =
      TypeArguments::Handle(cls.type_parameters());

  TypeParameter& type_param = TypeParameter::Handle(isolate);
  String& name = String::Handle(isolate);
  for (intptr_t i = 0; i < num_type_params; i++) {
    type_param ^= type_params.TypeAt(i);
    name = type_param.name();
    if (name.Equals(var_name)) {
      return Api::NewHandle(isolate, type_param.raw());
    }
  }
  const String& cls_name = String::Handle(cls.UserVisibleName());
  return Api::NewError(
      "%s: Could not find type variable named '%s' for class %s.\n",
      CURRENT_FUNC, var_name.ToCString(), cls_name.ToCString());
}


DART_EXPORT bool Dart_IsTypeVariable(Dart_Handle handle) {
  return Api::ClassId(handle) == kTypeParameterCid;
}

DART_EXPORT Dart_Handle Dart_TypeVariableName(Dart_Handle type_variable) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const TypeParameter& type_var =
      Api::UnwrapTypeParameterHandle(isolate, type_variable);
  if (type_var.IsNull()) {
    RETURN_TYPE_ERROR(isolate, type_variable, TypeParameter);
  }
  return Api::NewHandle(isolate, type_var.name());
}


DART_EXPORT Dart_Handle Dart_TypeVariableOwner(Dart_Handle type_variable) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const TypeParameter& type_var =
      Api::UnwrapTypeParameterHandle(isolate, type_variable);
  if (type_var.IsNull()) {
    RETURN_TYPE_ERROR(isolate, type_variable, TypeParameter);
  }
  const Class& owner = Class::Handle(type_var.parameterized_class());
  ASSERT(!owner.IsNull() && owner.IsClass());
  return Api::NewHandle(isolate, owner.raw());
}


DART_EXPORT Dart_Handle Dart_TypeVariableUpperBound(Dart_Handle type_variable) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const TypeParameter& type_var =
      Api::UnwrapTypeParameterHandle(isolate, type_variable);
  if (type_var.IsNull()) {
    RETURN_TYPE_ERROR(isolate, type_variable, TypeParameter);
  }
  const AbstractType& bound = AbstractType::Handle(type_var.bound());
  return TypeToHandle(isolate, "Dart_TypeVariableUpperBound", bound);
}


// --- Constructors, Methods, and Fields ---


static RawObject* ResolveConstructor(const char* current_func,
                                     const Class& cls,
                                     const String& class_name,
                                     const String& constr_name,
                                     int num_args) {
  // The constructor must be present in the interface.
  const Function& constructor =
      Function::Handle(cls.LookupFunctionAllowPrivate(constr_name));
  if (constructor.IsNull() ||
      (!constructor.IsConstructor() && !constructor.IsFactory())) {
    const String& lookup_class_name = String::Handle(cls.Name());
    if (!class_name.Equals(lookup_class_name)) {
      // When the class name used to build the constructor name is
      // different than the name of the class in which we are doing
      // the lookup, it can be confusing to the user to figure out
      // what's going on.  Be a little more explicit for these error
      // messages.
      const String& message = String::Handle(
          String::NewFormatted(
              "%s: could not find factory '%s' in class '%s'.",
              current_func,
              constr_name.ToCString(),
              lookup_class_name.ToCString()));
      return ApiError::New(message);
    } else {
      const String& message = String::Handle(
          String::NewFormatted("%s: could not find constructor '%s'.",
                               current_func, constr_name.ToCString()));
      return ApiError::New(message);
    }
  }
  int extra_args = (constructor.IsConstructor() ? 2 : 1);
  String& error_message = String::Handle();
  if (!constructor.AreValidArgumentCounts(num_args + extra_args,
                                          0,
                                          &error_message)) {
    const String& message = String::Handle(
        String::NewFormatted("%s: wrong argument count for "
                             "constructor '%s': %s.",
                             current_func,
                             constr_name.ToCString(),
                             error_message.ToCString()));
    return ApiError::New(message);
  }
  return constructor.raw();
}


DART_EXPORT Dart_Handle Dart_New(Dart_Handle clazz,
                                 Dart_Handle constructor_name,
                                 int number_of_arguments,
                                 Dart_Handle* arguments) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  CHECK_CALLBACK_STATE(isolate);
  Object& result = Object::Handle(isolate);

  if (number_of_arguments < 0) {
    return Api::NewError(
        "%s expects argument 'number_of_arguments' to be non-negative.",
        CURRENT_FUNC);
  }

  // Get the class to instantiate.
  Class& cls =
      Class::Handle(isolate, Api::UnwrapClassHandle(isolate, clazz).raw());
  if (cls.IsNull()) {
    RETURN_TYPE_ERROR(isolate, clazz, Class);
  }

  String& base_constructor_name = String::Handle();
  base_constructor_name = cls.Name();

  // And get the name of the constructor to invoke.
  String& dot_name = String::Handle(isolate);
  const Object& name_obj =
      Object::Handle(isolate, Api::UnwrapHandle(constructor_name));
  if (name_obj.IsNull()) {
    dot_name = Symbols::Dot().raw();
  } else if (name_obj.IsString()) {
    dot_name = String::Concat(Symbols::Dot(), String::Cast(name_obj));
  } else {
    RETURN_TYPE_ERROR(isolate, constructor_name, String);
  }
  Dart_Handle state = Api::CheckIsolateState(isolate);
  if (::Dart_IsError(state)) {
    return state;
  }

  // Resolve the constructor.
  String& constr_name =
      String::Handle(String::Concat(base_constructor_name, dot_name));
  result = ResolveConstructor("Dart_New",
                              cls,
                              base_constructor_name,
                              constr_name,
                              number_of_arguments);
  if (result.IsError()) {
    return Api::NewHandle(isolate, result.raw());
  }
  ASSERT(result.IsFunction());
  Function& constructor = Function::Handle(isolate);
  constructor ^= result.raw();

  Instance& new_object = Instance::Handle(isolate);
  if (constructor.IsRedirectingFactory()) {
    Type& type = Type::Handle(constructor.RedirectionType());
    cls = type.type_class();
    constructor = constructor.RedirectionTarget();
  }
  if (constructor.IsConstructor()) {
    // Create the new object.
    new_object = Instance::New(cls);
  }

  // Create the argument list.
  intptr_t arg_index = 0;
  int extra_args = (constructor.IsConstructor() ? 2 : 1);
  const Array& args =
      Array::Handle(isolate, Array::New(number_of_arguments + extra_args));
  if (constructor.IsConstructor()) {
    // Constructors get the uninitialized object and a constructor phase.
    args.SetAt(arg_index++, new_object);
    args.SetAt(arg_index++,
               Smi::Handle(isolate, Smi::New(Function::kCtorPhaseAll)));
  } else {
    // Factories get type arguments.
    args.SetAt(arg_index++, TypeArguments::Handle(isolate));
  }
  Object& argument = Object::Handle(isolate);
  for (int i = 0; i < number_of_arguments; i++) {
    argument = Api::UnwrapHandle(arguments[i]);
    if (!argument.IsNull() && !argument.IsInstance()) {
      if (argument.IsError()) {
        return Api::NewHandle(isolate, argument.raw());
      } else {
        return Api::NewError(
            "%s expects arguments[%d] to be an Instance handle.",
            CURRENT_FUNC, i);
      }
    }
    args.SetAt(arg_index++, argument);
  }

  // Invoke the constructor and return the new object.
  result = DartEntry::InvokeFunction(constructor, args);
  if (result.IsError()) {
    return Api::NewHandle(isolate, result.raw());
  }
  if (constructor.IsConstructor()) {
    ASSERT(result.IsNull());
  } else {
    ASSERT(result.IsNull() || result.IsInstance());
    new_object ^= result.raw();
  }
  return Api::NewHandle(isolate, new_object.raw());
}


DART_EXPORT Dart_Handle Dart_Invoke(Dart_Handle target,
                                    Dart_Handle name,
                                    int number_of_arguments,
                                    Dart_Handle* arguments) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  CHECK_CALLBACK_STATE(isolate);

  const String& function_name = Api::UnwrapStringHandle(isolate, name);
  if (function_name.IsNull()) {
    RETURN_TYPE_ERROR(isolate, name, String);
  }
  if (number_of_arguments < 0) {
    return Api::NewError(
        "%s expects argument 'number_of_arguments' to be non-negative.",
        CURRENT_FUNC);
  }
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(target));
  if (obj.IsError()) {
    return target;
  }

  // Check for malformed arguments in the arguments list.
  intptr_t num_receiver = (obj.IsNull() || obj.IsInstance()) ? 1 : 0;
  const Array& args =
      Array::Handle(isolate, Array::New(number_of_arguments + num_receiver));
  Object& arg = Object::Handle(isolate);
  for (int i = 0; i < number_of_arguments; i++) {
    arg = Api::UnwrapHandle(arguments[i]);
    if (!arg.IsNull() && !arg.IsInstance()) {
      if (arg.IsError()) {
        return Api::NewHandle(isolate, arg.raw());
      } else {
        return Api::NewError(
            "%s expects arguments[%d] to be an Instance handle.",
            CURRENT_FUNC, i);
      }
    }
    args.SetAt((i + num_receiver), arg);
  }

  if (obj.IsNull() || obj.IsInstance()) {
    Instance& instance = Instance::Handle();
    instance ^= obj.raw();
    const Function& function = Function::Handle(
        isolate,
        Resolver::ResolveDynamic(instance,
                                 function_name,
                                 (number_of_arguments + 1),
                                 Resolver::kIsQualified));
    args.SetAt(0, instance);
    if (function.IsNull()) {
      const Array& args_descriptor =
          Array::Handle(ArgumentsDescriptor::New(args.Length()));
      return Api::NewHandle(isolate,
                            DartEntry::InvokeNoSuchMethod(instance,
                                                          function_name,
                                                          args,
                                                          args_descriptor));
    }
    return Api::NewHandle(isolate, DartEntry::InvokeFunction(function, args));

  } else if (obj.IsClass()) {
    // Finalize all classes.
    Dart_Handle state = Api::CheckIsolateState(isolate);
    if (::Dart_IsError(state)) {
      return state;
    }

    const Class& cls = Class::Cast(obj);
    const Function& function = Function::Handle(
        isolate,
        Resolver::ResolveStatic(cls,
                                function_name,
                                number_of_arguments,
                                Object::empty_array(),
                                Resolver::kIsQualified));
    if (function.IsNull()) {
      const String& cls_name = String::Handle(isolate, cls.Name());
      return Api::NewError("%s: did not find static method '%s.%s'.",
                           CURRENT_FUNC,
                           cls_name.ToCString(),
                           function_name.ToCString());
    }
    return Api::NewHandle(isolate, DartEntry::InvokeFunction(function, args));

  } else if (obj.IsLibrary()) {
    // Check whether class finalization is needed.
    bool finalize_classes = true;
    const Library& lib = Library::Cast(obj);

    // When calling functions in the dart:builtin library do not finalize as it
    // should have been prefinalized.
    Library& builtin =
        Library::Handle(isolate, isolate->object_store()->builtin_library());
    if (builtin.raw() == lib.raw()) {
      finalize_classes = false;
    }

    // Finalize all classes if needed.
    if (finalize_classes) {
      Dart_Handle state = Api::CheckIsolateState(isolate);
      if (::Dart_IsError(state)) {
        return state;
      }
    }

    Function& function = Function::Handle(isolate);
    function = lib.LookupFunctionAllowPrivate(function_name);
    if (function.IsNull()) {
      return Api::NewError("%s: did not find top-level function '%s'.",
                           CURRENT_FUNC,
                           function_name.ToCString());
    }
    // LookupFunctionAllowPrivate does not check argument arity, so we
    // do it here.
    String& error_message = String::Handle();
    if (!function.AreValidArgumentCounts(number_of_arguments,
                                         0,
                                         &error_message)) {
      return Api::NewError("%s: wrong argument count for function '%s': %s.",
                           CURRENT_FUNC,
                           function_name.ToCString(),
                           error_message.ToCString());
    }
    return Api::NewHandle(isolate, DartEntry::InvokeFunction(function, args));

  } else {
    return Api::NewError(
        "%s expects argument 'target' to be an object, class, or library.",
        CURRENT_FUNC);
  }
}


static bool FieldIsUninitialized(Isolate* isolate, const Field& fld) {
  ASSERT(!fld.IsNull());

  // Return getter method for uninitialized fields, rather than the
  // field object, since the value in the field object will not be
  // initialized until the first time the getter is invoked.
  const Instance& value = Instance::Handle(isolate, fld.value());
  ASSERT(value.raw() != Object::transition_sentinel().raw());
  return value.raw() == Object::sentinel().raw();
}


DART_EXPORT Dart_Handle Dart_GetField(Dart_Handle container, Dart_Handle name) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  CHECK_CALLBACK_STATE(isolate);

  const String& field_name = Api::UnwrapStringHandle(isolate, name);
  if (field_name.IsNull()) {
    RETURN_TYPE_ERROR(isolate, name, String);
  }

  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(container));

  Field& field = Field::Handle(isolate);
  Function& getter = Function::Handle(isolate);
  if (obj.IsNull()) {
    return Api::NewError("%s expects argument 'container' to be non-null.",
                         CURRENT_FUNC);
  } else if (obj.IsInstance()) {
    // Every instance field has a getter Function.  Try to find the
    // getter in any superclass and use that function to access the
    // field.
    const Instance& instance = Instance::Cast(obj);
    Class& cls = Class::Handle(isolate, instance.clazz());
    String& getter_name =
        String::Handle(isolate, Field::GetterName(field_name));
    while (!cls.IsNull()) {
      getter = cls.LookupDynamicFunctionAllowPrivate(getter_name);
      if (!getter.IsNull()) {
        break;
      }
      cls = cls.SuperClass();
    }

    // Invoke the getter and return the result.
    const int kNumArgs = 1;
    const Array& args = Array::Handle(isolate, Array::New(kNumArgs));
    args.SetAt(0, instance);
    if (getter.IsNull()) {
      const Array& args_descriptor =
          Array::Handle(ArgumentsDescriptor::New(args.Length()));
      return Api::NewHandle(isolate,
                            DartEntry::InvokeNoSuchMethod(instance,
                                                          getter_name,
                                                          args,
                                                          args_descriptor));
    }
    return Api::NewHandle(isolate, DartEntry::InvokeFunction(getter, args));

  } else if (obj.IsClass()) {
    // Finalize all classes.
    Dart_Handle state = Api::CheckIsolateState(isolate);
    if (::Dart_IsError(state)) {
      return state;
    }
    // To access a static field we may need to use the Field or the
    // getter Function.
    const Class& cls = Class::Cast(obj);
    field = cls.LookupStaticField(field_name);
    if (field.IsNull() || FieldIsUninitialized(isolate, field)) {
      const String& getter_name =
          String::Handle(isolate, Field::GetterName(field_name));
      getter = cls.LookupStaticFunctionAllowPrivate(getter_name);
    }

    if (!getter.IsNull()) {
      // Invoke the getter and return the result.
      return Api::NewHandle(
          isolate, DartEntry::InvokeFunction(getter, Object::empty_array()));
    } else if (!field.IsNull()) {
      return Api::NewHandle(isolate, field.value());
    } else {
      return Api::NewError("%s: did not find static field '%s'.",
                           CURRENT_FUNC, field_name.ToCString());
    }

  } else if (obj.IsLibrary()) {
    // TODO(turnidge): Do we need to call CheckIsolateState here?

    // To access a top-level we may need to use the Field or the
    // getter Function.  The getter function may either be in the
    // library or in the field's owner class, depending.
    const Library& lib = Library::Cast(obj);
    field = lib.LookupFieldAllowPrivate(field_name);
    if (field.IsNull()) {
      // No field found.  Check for a getter in the lib.
      const String& getter_name =
          String::Handle(isolate, Field::GetterName(field_name));
      getter = lib.LookupFunctionAllowPrivate(getter_name);
    } else if (FieldIsUninitialized(isolate, field)) {
      // A field was found.  Check for a getter in the field's owner classs.
      const Class& cls = Class::Handle(isolate, field.owner());
      const String& getter_name =
          String::Handle(isolate, Field::GetterName(field_name));
      getter = cls.LookupStaticFunctionAllowPrivate(getter_name);
    }

    if (!getter.IsNull()) {
      // Invoke the getter and return the result.
      return Api::NewHandle(
          isolate, DartEntry::InvokeFunction(getter, Object::empty_array()));
    } else if (!field.IsNull()) {
      return Api::NewHandle(isolate, field.value());
    } else {
      return Api::NewError("%s: did not find top-level variable '%s'.",
                           CURRENT_FUNC, field_name.ToCString());
    }

  } else if (obj.IsError()) {
      return container;
  } else {
    return Api::NewError(
        "%s expects argument 'container' to be an object, class, or library.",
        CURRENT_FUNC);
  }
}


DART_EXPORT Dart_Handle Dart_SetField(Dart_Handle container,
                                      Dart_Handle name,
                                      Dart_Handle value) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  CHECK_CALLBACK_STATE(isolate);

  const String& field_name = Api::UnwrapStringHandle(isolate, name);
  if (field_name.IsNull()) {
    RETURN_TYPE_ERROR(isolate, name, String);
  }

  // Since null is allowed for value, we don't use UnwrapInstanceHandle.
  const Object& value_obj = Object::Handle(isolate, Api::UnwrapHandle(value));
  if (!value_obj.IsNull() && !value_obj.IsInstance()) {
    RETURN_TYPE_ERROR(isolate, value, Instance);
  }
  Instance& value_instance = Instance::Handle(isolate);
  value_instance ^= value_obj.raw();

  Field& field = Field::Handle(isolate);
  Function& setter = Function::Handle(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(container));
  if (obj.IsNull()) {
    return Api::NewError("%s expects argument 'container' to be non-null.",
                         CURRENT_FUNC);
  } else if (obj.IsInstance()) {
    // Every instance field has a setter Function.  Try to find the
    // setter in any superclass and use that function to access the
    // field.
    const Instance& instance = Instance::Cast(obj);
    Class& cls = Class::Handle(isolate, instance.clazz());
    String& setter_name =
        String::Handle(isolate, Field::SetterName(field_name));
    while (!cls.IsNull()) {
      field = cls.LookupInstanceField(field_name);
      if (!field.IsNull() && field.is_final()) {
        return Api::NewError("%s: cannot set final field '%s'.",
                             CURRENT_FUNC, field_name.ToCString());
      }
      setter = cls.LookupDynamicFunctionAllowPrivate(setter_name);
      if (!setter.IsNull()) {
        break;
      }
      cls = cls.SuperClass();
    }

    // Invoke the setter and return the result.
    const int kNumArgs = 2;
    const Array& args = Array::Handle(isolate, Array::New(kNumArgs));
    args.SetAt(0, instance);
    args.SetAt(1, value_instance);
    if (setter.IsNull()) {
      const Array& args_descriptor =
          Array::Handle(ArgumentsDescriptor::New(args.Length()));
      return Api::NewHandle(isolate,
                            DartEntry::InvokeNoSuchMethod(instance,
                                                          setter_name,
                                                          args,
                                                          args_descriptor));
    }
    return Api::NewHandle(isolate, DartEntry::InvokeFunction(setter, args));

  } else if (obj.IsClass()) {
    // To access a static field we may need to use the Field or the
    // setter Function.
    const Class& cls = Class::Cast(obj);
    field = cls.LookupStaticField(field_name);
    if (field.IsNull()) {
      String& setter_name =
          String::Handle(isolate, Field::SetterName(field_name));
      setter = cls.LookupStaticFunctionAllowPrivate(setter_name);
    }

    if (!setter.IsNull()) {
      // Invoke the setter and return the result.
      const int kNumArgs = 1;
      const Array& args = Array::Handle(isolate, Array::New(kNumArgs));
      args.SetAt(0, value_instance);
      const Object& result =
          Object::Handle(isolate, DartEntry::InvokeFunction(setter, args));
      if (result.IsError()) {
        return Api::NewHandle(isolate, result.raw());
      } else {
        return Api::Success(isolate);
      }
    } else if (!field.IsNull()) {
      if (field.is_final()) {
        return Api::NewError("%s: cannot set final field '%s'.",
                             CURRENT_FUNC, field_name.ToCString());
      } else {
        field.set_value(value_instance);
        return Api::Success(isolate);
      }
    } else {
      return Api::NewError("%s: did not find static field '%s'.",
                           CURRENT_FUNC, field_name.ToCString());
    }

  } else if (obj.IsLibrary()) {
    // To access a top-level we may need to use the Field or the
    // setter Function.  The setter function may either be in the
    // library or in the field's owner class, depending.
    const Library& lib = Library::Cast(obj);
    field = lib.LookupFieldAllowPrivate(field_name);
    if (field.IsNull()) {
      const String& setter_name =
          String::Handle(isolate, Field::SetterName(field_name));
      setter ^= lib.LookupFunctionAllowPrivate(setter_name);
    }

    if (!setter.IsNull()) {
      // Invoke the setter and return the result.
      const int kNumArgs = 1;
      const Array& args = Array::Handle(isolate, Array::New(kNumArgs));
      args.SetAt(0, value_instance);
      const Object& result =
          Object::Handle(isolate, DartEntry::InvokeFunction(setter, args));
      if (result.IsError()) {
        return Api::NewHandle(isolate, result.raw());
      } else {
        return Api::Success(isolate);
      }
    } else if (!field.IsNull()) {
      if (field.is_final()) {
        return Api::NewError("%s: cannot set final top-level variable '%s'.",
                             CURRENT_FUNC, field_name.ToCString());
      } else {
        field.set_value(value_instance);
        return Api::Success(isolate);
      }
    } else {
      return Api::NewError("%s: did not find top-level variable '%s'.",
                           CURRENT_FUNC, field_name.ToCString());
    }

  } else if (obj.IsError()) {
      return container;
  } else {
    return Api::NewError(
        "%s expects argument 'container' to be an object, class, or library.",
        CURRENT_FUNC);
  }
}


DART_EXPORT Dart_Handle Dart_CreateNativeWrapperClass(Dart_Handle library,
                                                      Dart_Handle name,
                                                      int field_count) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const String& cls_name = Api::UnwrapStringHandle(isolate, name);
  if (cls_name.IsNull()) {
    RETURN_TYPE_ERROR(isolate, name, String);
  }
  const Library& lib = Api::UnwrapLibraryHandle(isolate, library);
  if (lib.IsNull()) {
    RETURN_TYPE_ERROR(isolate, library, Library);
  }
  if (field_count <= 0) {
    return Api::NewError(
        "Negative field_count passed to Dart_CreateNativeWrapperClass");
  }
  CHECK_CALLBACK_STATE(isolate);

  String& cls_symbol = String::Handle(isolate, Symbols::New(cls_name));
  const Class& cls = Class::Handle(
      isolate, Class::NewNativeWrapper(lib, cls_symbol, field_count));
  if (cls.IsNull()) {
    return Api::NewError(
        "Unable to create native wrapper class : already exists");
  }
  return Api::NewHandle(isolate, cls.raw());
}


DART_EXPORT Dart_Handle Dart_GetNativeInstanceFieldCount(Dart_Handle obj,
                                                         int* count) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Instance& instance = Api::UnwrapInstanceHandle(isolate, obj);
  if (instance.IsNull()) {
    RETURN_TYPE_ERROR(isolate, obj, Instance);
  }
  const Class& cls = Class::Handle(isolate, instance.clazz());
  *count = cls.num_native_fields();
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_GetNativeInstanceField(Dart_Handle obj,
                                                    int index,
                                                    intptr_t* value) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Instance& instance = Api::UnwrapInstanceHandle(isolate, obj);
  if (instance.IsNull()) {
    RETURN_TYPE_ERROR(isolate, obj, Instance);
  }
  if (!instance.IsValidNativeIndex(index)) {
    return Api::NewError(
        "%s: invalid index %d passed in to access native instance field",
        CURRENT_FUNC, index);
  }
  *value = instance.GetNativeField(isolate, index);
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_SetNativeInstanceField(Dart_Handle obj,
                                                    int index,
                                                    intptr_t value) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Instance& instance = Api::UnwrapInstanceHandle(isolate, obj);
  if (instance.IsNull()) {
    RETURN_TYPE_ERROR(isolate, obj, Instance);
  }
  if (!instance.IsValidNativeIndex(index)) {
    return Api::NewError(
        "%s: invalid index %d passed in to set native instance field",
        CURRENT_FUNC, index);
  }
  instance.SetNativeField(index, value);
  return Api::Success(isolate);
}


// --- Exceptions ----


DART_EXPORT Dart_Handle Dart_ThrowException(Dart_Handle exception) {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  CHECK_CALLBACK_STATE(isolate);
  {
    const Instance& excp = Api::UnwrapInstanceHandle(isolate, exception);
    if (excp.IsNull()) {
      RETURN_TYPE_ERROR(isolate, exception, Instance);
    }
  }
  if (isolate->top_exit_frame_info() == 0) {
    // There are no dart frames on the stack so it would be illegal to
    // throw an exception here.
    return Api::NewError("No Dart frames on stack, cannot throw exception");
  }

  // Unwind all the API scopes till the exit frame before throwing an
  // exception.
  ApiState* state = isolate->api_state();
  ASSERT(state != NULL);
  const Instance* saved_exception;
  {
    NoGCScope no_gc;
    RawInstance* raw_exception =
        Api::UnwrapInstanceHandle(isolate, exception).raw();
    state->UnwindScopes(isolate->top_exit_frame_info());
    saved_exception = &Instance::Handle(raw_exception);
  }
  Exceptions::Throw(*saved_exception);
  return Api::NewError("Exception was not thrown, internal error");
}


DART_EXPORT Dart_Handle Dart_ReThrowException(Dart_Handle exception,
                                              Dart_Handle stacktrace) {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  CHECK_CALLBACK_STATE(isolate);
  {
    const Instance& excp = Api::UnwrapInstanceHandle(isolate, exception);
    if (excp.IsNull()) {
      RETURN_TYPE_ERROR(isolate, exception, Instance);
    }
    const Instance& stk = Api::UnwrapInstanceHandle(isolate, stacktrace);
    if (stk.IsNull()) {
      RETURN_TYPE_ERROR(isolate, stacktrace, Instance);
    }
  }
  if (isolate->top_exit_frame_info() == 0) {
    // There are no dart frames on the stack so it would be illegal to
    // throw an exception here.
    return Api::NewError("No Dart frames on stack, cannot throw exception");
  }

  // Unwind all the API scopes till the exit frame before throwing an
  // exception.
  ApiState* state = isolate->api_state();
  ASSERT(state != NULL);
  const Instance* saved_exception;
  const Instance* saved_stacktrace;
  {
    NoGCScope no_gc;
    RawInstance* raw_exception =
        Api::UnwrapInstanceHandle(isolate, exception).raw();
    RawInstance* raw_stacktrace =
        Api::UnwrapInstanceHandle(isolate, stacktrace).raw();
    state->UnwindScopes(isolate->top_exit_frame_info());
    saved_exception = &Instance::Handle(raw_exception);
    saved_stacktrace = &Instance::Handle(raw_stacktrace);
  }
  Exceptions::ReThrow(*saved_exception, *saved_stacktrace);
  return Api::NewError("Exception was not re thrown, internal error");
}


// --- Native functions ---


DART_EXPORT Dart_Handle Dart_GetNativeArgument(Dart_NativeArguments args,
                                               int index) {
  NativeArguments* arguments = reinterpret_cast<NativeArguments*>(args);
  if ((index < 0) || (index >= arguments->NativeArgCount())) {
    return Api::NewError(
        "%s: argument 'index' out of range. Expected 0..%d but saw %d.",
        CURRENT_FUNC, arguments->NativeArgCount() - 1, index);
  }
  return Api::NewHandle(arguments->isolate(), arguments->NativeArgAt(index));
}


DART_EXPORT int Dart_GetNativeArgumentCount(Dart_NativeArguments args) {
  NativeArguments* arguments = reinterpret_cast<NativeArguments*>(args);
  return arguments->NativeArgCount();
}


DART_EXPORT void Dart_SetReturnValue(Dart_NativeArguments args,
                                     Dart_Handle retval) {
  const Object& ret_obj = Object::Handle(Api::UnwrapHandle(retval));
  if (!ret_obj.IsNull() && !ret_obj.IsInstance()) {
    FATAL1("Return value check failed: saw '%s' expected a dart Instance.",
           ret_obj.ToCString());
  }
  NoGCScope no_gc_scope;
  NativeArguments* arguments = reinterpret_cast<NativeArguments*>(args);
  arguments->SetReturn(ret_obj);
}


// --- Scripts and Libraries ---


DART_EXPORT Dart_Handle Dart_SetLibraryTagHandler(
    Dart_LibraryTagHandler handler) {
  Isolate* isolate = Isolate::Current();
  CHECK_ISOLATE(isolate);
  isolate->set_library_tag_handler(handler);
  return Api::Success(isolate);
}


// NOTE: Need to pass 'result' as a parameter here in order to avoid
// warning: variable 'result' might be clobbered by 'longjmp' or 'vfork'
// which shows up because of the use of setjmp.
static void CompileSource(Isolate* isolate,
                          const Library& lib,
                          const Script& script,
                          Dart_Handle* result) {
  bool update_lib_status = (script.kind() == RawScript::kScriptTag ||
                            script.kind() == RawScript::kLibraryTag);
  if (update_lib_status) {
    lib.SetLoadInProgress();
  }
  ASSERT(isolate != NULL);
  const Error& error = Error::Handle(isolate, Compiler::Compile(lib, script));
  if (error.IsNull()) {
    *result = Api::NewHandle(isolate, lib.raw());
    if (update_lib_status) {
      lib.SetLoaded();
    }
  } else {
    *result = Api::NewHandle(isolate, error.raw());
    if (update_lib_status) {
      lib.SetLoadError();
    }
  }
}


DART_EXPORT Dart_Handle Dart_LoadScript(Dart_Handle url,
                                        Dart_Handle source,
                                        intptr_t line_offset,
                                        intptr_t col_offset) {
  TIMERSCOPE(time_script_loading);
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const String& url_str = Api::UnwrapStringHandle(isolate, url);
  if (url_str.IsNull()) {
    RETURN_TYPE_ERROR(isolate, url, String);
  }
  const String& source_str = Api::UnwrapStringHandle(isolate, source);
  if (source_str.IsNull()) {
    RETURN_TYPE_ERROR(isolate, source, String);
  }
  Library& library =
      Library::Handle(isolate, isolate->object_store()->root_library());
  if (!library.IsNull()) {
    const String& library_url = String::Handle(isolate, library.url());
    return Api::NewError("%s: A script has already been loaded from '%s'.",
                         CURRENT_FUNC, library_url.ToCString());
  }
  if (line_offset < 0) {
    return Api::NewError("%s: argument 'line_offset' must be positive number",
                         CURRENT_FUNC);
  }
  if (col_offset < 0) {
    return Api::NewError("%s: argument 'col_offset' must be positive number",
                         CURRENT_FUNC);
  }
  CHECK_CALLBACK_STATE(isolate);

  library = Library::New(url_str);
  library.set_debuggable(true);
  library.Register();
  isolate->object_store()->set_root_library(library);

  const Script& script = Script::Handle(
      isolate, Script::New(url_str, source_str, RawScript::kScriptTag));
  script.SetLocationOffset(line_offset, col_offset);
  Dart_Handle result;
  CompileSource(isolate, library, script, &result);
  return result;
}


DART_EXPORT Dart_Handle Dart_LoadScriptFromSnapshot(const uint8_t* buffer,
                                                    intptr_t buffer_len) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  TIMERSCOPE(time_script_loading);
  if (buffer == NULL) {
    RETURN_NULL_ERROR(buffer);
  }
  NoHeapGrowthControlScope no_growth_control;

  const Snapshot* snapshot = Snapshot::SetupFromBuffer(buffer);
  if (!snapshot->IsScriptSnapshot()) {
    return Api::NewError("%s expects parameter 'buffer' to be a script type"
                         " snapshot.", CURRENT_FUNC);
  }
  if (snapshot->length() != buffer_len) {
    return Api::NewError("%s: 'buffer_len' of %"Pd" is not equal to %d which"
                         " is the expected length in the snapshot.",
                         CURRENT_FUNC, buffer_len, snapshot->length());
  }
  Library& library =
      Library::Handle(isolate, isolate->object_store()->root_library());
  if (!library.IsNull()) {
    const String& library_url = String::Handle(isolate, library.url());
    return Api::NewError("%s: A script has already been loaded from '%s'.",
                         CURRENT_FUNC, library_url.ToCString());
  }
  CHECK_CALLBACK_STATE(isolate);

  SnapshotReader reader(snapshot->content(),
                        snapshot->length(),
                        snapshot->kind(),
                        isolate);
  const Object& tmp = Object::Handle(isolate, reader.ReadObject());
  if (!tmp.IsLibrary()) {
    return Api::NewError("%s: Unable to deserialize snapshot correctly.",
                         CURRENT_FUNC);
  }
  library ^= tmp.raw();
  library.set_debuggable(true);
  isolate->object_store()->set_root_library(library);
  return Api::NewHandle(isolate, library.raw());
}


DART_EXPORT Dart_Handle Dart_RootLibrary() {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  Library& library =
      Library::Handle(isolate, isolate->object_store()->root_library());
  return Api::NewHandle(isolate, library.raw());
}


static void CompileAll(Isolate* isolate, Dart_Handle* result) {
  ASSERT(isolate != NULL);
  const Error& error = Error::Handle(isolate, Library::CompileAll());
  if (error.IsNull()) {
    *result = Api::Success(isolate);
  } else {
    *result = Api::NewHandle(isolate, error.raw());
  }
}


DART_EXPORT Dart_Handle Dart_CompileAll() {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  Dart_Handle result = Api::CheckIsolateState(isolate);
  if (::Dart_IsError(result)) {
    return result;
  }
  CHECK_CALLBACK_STATE(isolate);
  CompileAll(isolate, &result);
  return result;
}


DART_EXPORT Dart_Handle Dart_CheckFunctionFingerprints() {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  Dart_Handle result = Api::CheckIsolateState(isolate);
  if (::Dart_IsError(result)) {
    return result;
  }
  CHECK_CALLBACK_STATE(isolate);
  Library::CheckFunctionFingerprints();
  return result;
}


DART_EXPORT bool Dart_IsLibrary(Dart_Handle object) {
  return Api::ClassId(object) == kLibraryCid;
}


DART_EXPORT Dart_Handle Dart_GetClass(Dart_Handle library,
                                      Dart_Handle class_name) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Library& lib = Api::UnwrapLibraryHandle(isolate, library);
  if (lib.IsNull()) {
    RETURN_TYPE_ERROR(isolate, library, Library);
  }
  const String& cls_name = Api::UnwrapStringHandle(isolate, class_name);
  if (cls_name.IsNull()) {
    RETURN_TYPE_ERROR(isolate, class_name, String);
  }
  const Class& cls =
      Class::Handle(isolate, lib.LookupClassAllowPrivate(cls_name));
  if (cls.IsNull()) {
    // TODO(turnidge): Return null or error in this case?
    const String& lib_name = String::Handle(isolate, lib.name());
    return Api::NewError("Class '%s' not found in library '%s'.",
                         cls_name.ToCString(), lib_name.ToCString());
  }
  return Api::NewHandle(isolate, cls.raw());
}


DART_EXPORT Dart_Handle Dart_LibraryName(Dart_Handle library) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Library& lib = Api::UnwrapLibraryHandle(isolate, library);
  if (lib.IsNull()) {
    RETURN_TYPE_ERROR(isolate, library, Library);
  }
  const String& name = String::Handle(isolate, lib.name());
  ASSERT(!name.IsNull());
  return Api::NewHandle(isolate, name.raw());
}


DART_EXPORT Dart_Handle Dart_LibraryUrl(Dart_Handle library) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Library& lib = Api::UnwrapLibraryHandle(isolate, library);
  if (lib.IsNull()) {
    RETURN_TYPE_ERROR(isolate, library, Library);
  }
  const String& url = String::Handle(isolate, lib.url());
  ASSERT(!url.IsNull());
  return Api::NewHandle(isolate, url.raw());
}


DART_EXPORT Dart_Handle Dart_LibraryGetClassNames(Dart_Handle library) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Library& lib = Api::UnwrapLibraryHandle(isolate, library);
  if (lib.IsNull()) {
    RETURN_TYPE_ERROR(isolate, library, Library);
  }

  const GrowableObjectArray& names =
      GrowableObjectArray::Handle(isolate, GrowableObjectArray::New());
  ClassDictionaryIterator it(lib);
  Class& cls = Class::Handle();
  String& name = String::Handle();
  while (it.HasNext()) {
    cls = it.GetNextClass();
    if (cls.IsSignatureClass()) {
      if (!cls.IsCanonicalSignatureClass()) {
        // This is a typedef.  Add it to the list of class names.
        name = cls.UserVisibleName();
        names.Add(name);
      } else {
        // Skip canonical signature classes.  These are not named.
      }
    } else {
      name = cls.UserVisibleName();
      names.Add(name);
    }
  }
  return Api::NewHandle(isolate, Array::MakeArray(names));
}


DART_EXPORT Dart_Handle Dart_LookupLibrary(Dart_Handle url) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const String& url_str = Api::UnwrapStringHandle(isolate, url);
  if (url_str.IsNull()) {
    RETURN_TYPE_ERROR(isolate, url, String);
  }
  const Library& library =
      Library::Handle(isolate, Library::LookupLibrary(url_str));
  if (library.IsNull()) {
    return Api::NewError("%s: library '%s' not found.",
                         CURRENT_FUNC, url_str.ToCString());
  } else {
    return Api::NewHandle(isolate, library.raw());
  }
}


DART_EXPORT Dart_Handle Dart_LoadLibrary(Dart_Handle url,
                                         Dart_Handle source) {
  TIMERSCOPE(time_script_loading);
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const String& url_str = Api::UnwrapStringHandle(isolate, url);
  if (url_str.IsNull()) {
    RETURN_TYPE_ERROR(isolate, url, String);
  }
  const String& source_str = Api::UnwrapStringHandle(isolate, source);
  if (source_str.IsNull()) {
    RETURN_TYPE_ERROR(isolate, source, String);
  }
  CHECK_CALLBACK_STATE(isolate);

  Library& library = Library::Handle(isolate, Library::LookupLibrary(url_str));
  if (library.IsNull()) {
    library = Library::New(url_str);
    library.Register();
  } else if (!library.LoadNotStarted()) {
    // The source for this library has either been loaded or is in the
    // process of loading.  Return an error.
    return Api::NewError("%s: library '%s' has already been loaded.",
                         CURRENT_FUNC, url_str.ToCString());
  }
  const Script& script = Script::Handle(
      isolate, Script::New(url_str, source_str, RawScript::kLibraryTag));
  Dart_Handle result;
  CompileSource(isolate, library, script, &result);
  // Propagate the error out right now.
  if (::Dart_IsError(result)) {
    return result;
  }

  // If this is the dart:builtin library, register it with the VM.
  if (url_str.Equals("dart:builtin")) {
    isolate->object_store()->set_builtin_library(library);
    Dart_Handle state = Api::CheckIsolateState(isolate);
    if (::Dart_IsError(state)) {
      return state;
    }
  }
  return result;
}


DART_EXPORT Dart_Handle Dart_LibraryImportLibrary(Dart_Handle library,
                                                  Dart_Handle import,
                                                  Dart_Handle prefix) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Library& library_vm = Api::UnwrapLibraryHandle(isolate, library);
  if (library_vm.IsNull()) {
    RETURN_TYPE_ERROR(isolate, library, Library);
  }
  const Library& import_vm = Api::UnwrapLibraryHandle(isolate, import);
  if (import_vm.IsNull()) {
    RETURN_TYPE_ERROR(isolate, import, Library);
  }
  const Object& prefix_object =
      Object::Handle(isolate, Api::UnwrapHandle(prefix));
  const String& prefix_vm = prefix_object.IsNull()
      ? Symbols::Empty()
      : String::Cast(prefix_object);
  if (prefix_vm.IsNull()) {
    RETURN_TYPE_ERROR(isolate, prefix, String);
  }
  CHECK_CALLBACK_STATE(isolate);

  const String& prefix_symbol =
      String::Handle(isolate, Symbols::New(prefix_vm));
  const Namespace& import_ns = Namespace::Handle(
      Namespace::New(import_vm, Array::Handle(), Array::Handle()));
  if (prefix_vm.Length() == 0) {
    library_vm.AddImport(import_ns);
  } else {
    LibraryPrefix& library_prefix = LibraryPrefix::Handle();
    library_prefix = library_vm.LookupLocalLibraryPrefix(prefix_symbol);
    if (!library_prefix.IsNull()) {
      library_prefix.AddImport(import_ns);
    } else {
      library_prefix = LibraryPrefix::New(prefix_symbol, import_ns);
      library_vm.AddObject(library_prefix, prefix_symbol);
    }
  }
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_LoadSource(Dart_Handle library,
                                        Dart_Handle url,
                                        Dart_Handle source) {
  TIMERSCOPE(time_script_loading);
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Library& lib = Api::UnwrapLibraryHandle(isolate, library);
  if (lib.IsNull()) {
    RETURN_TYPE_ERROR(isolate, library, Library);
  }
  const String& url_str = Api::UnwrapStringHandle(isolate, url);
  if (url_str.IsNull()) {
    RETURN_TYPE_ERROR(isolate, url, String);
  }
  const String& source_str = Api::UnwrapStringHandle(isolate, source);
  if (source_str.IsNull()) {
    RETURN_TYPE_ERROR(isolate, source, String);
  }
  CHECK_CALLBACK_STATE(isolate);

  const Script& script = Script::Handle(
      isolate, Script::New(url_str, source_str, RawScript::kSourceTag));
  Dart_Handle result;
  CompileSource(isolate, lib, script, &result);
  return result;
}


DART_EXPORT Dart_Handle Dart_LoadPatch(Dart_Handle library,
                                       Dart_Handle url,
                                       Dart_Handle patch_source) {
  TIMERSCOPE(time_script_loading);
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Library& lib = Api::UnwrapLibraryHandle(isolate, library);
  if (lib.IsNull()) {
    RETURN_TYPE_ERROR(isolate, library, Library);
  }
  const String& url_str = Api::UnwrapStringHandle(isolate, url);
  if (url_str.IsNull()) {
    RETURN_TYPE_ERROR(isolate, url, String);
  }
  const String& source_str = Api::UnwrapStringHandle(isolate, patch_source);
  if (source_str.IsNull()) {
    RETURN_TYPE_ERROR(isolate, patch_source, String);
  }
  CHECK_CALLBACK_STATE(isolate);

  const Script& script = Script::Handle(
      isolate, Script::New(url_str, source_str, RawScript::kPatchTag));
  Dart_Handle result;
  CompileSource(isolate, lib, script, &result);
  return result;
}


DART_EXPORT Dart_Handle Dart_SetNativeResolver(
    Dart_Handle library,
    Dart_NativeEntryResolver resolver) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Library& lib = Api::UnwrapLibraryHandle(isolate, library);
  if (lib.IsNull()) {
    RETURN_TYPE_ERROR(isolate, library, Library);
  }
  lib.set_native_entry_resolver(resolver);
  return Api::Success(isolate);
}


// --- Profiling support ---

// TODO(7565): Dartium should use the new VM flag "generate_pprof_symbols" for
// pprof profiling. Then these symbols should be removed.

DART_EXPORT void Dart_InitPprofSupport() { }

DART_EXPORT void Dart_GetPprofSymbolInfo(void** buffer, int* buffer_size) {
  *buffer = NULL;
  *buffer_size = 0;
}


// --- Peer support ---


DART_EXPORT Dart_Handle Dart_GetPeer(Dart_Handle object, void** peer) {
  if (peer == NULL) {
    RETURN_NULL_ERROR(peer);
  }
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(object));
  if (obj.IsNull() || obj.IsNumber() || obj.IsBool()) {
    const char* msg =
        "%s: argument 'object' cannot be a subtype of Null, num, or bool";
    return Api::NewError(msg, CURRENT_FUNC);
  }
  {
    NoGCScope no_gc;
    RawObject* raw_obj = obj.raw();
    *peer = isolate->heap()->GetPeer(raw_obj);
  }
  return Api::Success(isolate);
}


DART_EXPORT Dart_Handle Dart_SetPeer(Dart_Handle object, void* peer) {
  Isolate* isolate = Isolate::Current();
  DARTSCOPE(isolate);
  const Object& obj = Object::Handle(isolate, Api::UnwrapHandle(object));
  if (obj.IsNull() || obj.IsNumber() || obj.IsBool()) {
    const char* msg =
        "%s: argument 'object' cannot be a subtype of Null, num, or bool";
    return Api::NewError(msg, CURRENT_FUNC);
  }
  {
    NoGCScope no_gc;
    RawObject* raw_obj = obj.raw();
    isolate->heap()->SetPeer(raw_obj, peer);
  }
  return Api::Success(isolate);
}

}  // namespace dart
