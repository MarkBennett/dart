// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef INCLUDE_DART_API_H_
#define INCLUDE_DART_API_H_

/** \mainpage Dart Embedding API Reference
 *
 * Dart is a class-based programming language for creating structured
 * web applications. This reference describes the Dart embedding api,
 * which is used to embed the Dart Virtual Machine within an
 * application.
 *
 * This reference is generated from the header include/dart_api.h.
 */

#ifdef __cplusplus
#define DART_EXTERN_C extern "C"
#else
#define DART_EXTERN_C
#endif

#if defined(__CYGWIN__)
#error Tool chain and platform not supported.
#elif defined(_WIN32)
typedef signed __int8 int8_t;
typedef signed __int16 int16_t;
typedef signed __int32 int32_t;
typedef signed __int64 int64_t;
typedef unsigned __int8 uint8_t;
typedef unsigned __int16 uint16_t;
typedef unsigned __int32 uint32_t;
typedef unsigned __int64 uint64_t;
#if defined(DART_SHARED_LIB)
#define DART_EXPORT DART_EXTERN_C __declspec(dllexport)
#else
#define DART_EXPORT DART_EXTERN_C
#endif
#else
// __STDC_FORMAT_MACROS has to be defined before including <inttypes.h> to
// enable platform independent printf format specifiers.
#ifndef __STDC_FORMAT_MACROS
#define __STDC_FORMAT_MACROS
#endif
#include <inttypes.h>
#include <stdbool.h>
#if __GNUC__ >= 4
#if defined(DART_SHARED_LIB)
#define DART_EXPORT DART_EXTERN_C __attribute__ ((visibility("default")))
#else
#define DART_EXPORT DART_EXTERN_C
#endif
#else
#error Tool chain not supported.
#endif
#endif

#include <assert.h>

// --- Handles ---

/**
 * An object reference managed by the Dart VM garbage collector.
 *
 * Because the garbage collector may move objects, it is unsafe to
 * refer to objects directly. Instead, we refer to objects through
 * handles, which are known to the garbage collector and updated
 * automatically when the object is moved. Handles should be passed
 * by value (except in cases like out-parameters) and should never be
 * allocated on the heap.
 *
 * Most functions in the Dart Embedding API return a handle. When a
 * function completes normally, this will be a valid handle to an
 * object in the Dart VM heap. This handle may represent the result of
 * the operation or it may be a special valid handle used merely to
 * indicate successful completion. Note that a valid handle may in
 * some cases refer to the null object.
 *
 * --- Error handles ---
 *
 * When a function encounters a problem that prevents it from
 * completing normally, it returns an error handle (See Dart_IsError).
 * An error handle has an associated error message that gives more
 * details about the problem (See Dart_GetError).
 *
 * There are four kinds of error handles that can be produced,
 * depending on what goes wrong:
 *
 * - Api error handles are produced when an api function is misused.
 *   This happens when a Dart embedding api function is called with
 *   invalid arguments or in an invalid context.
 *
 * - Unhandled exception error handles are produced when, during the
 *   execution of Dart code, an exception is thrown but not caught.
 *   Prototypically this would occur during a call to Dart_Invoke, but
 *   it can occur in any function which triggers the execution of Dart
 *   code (for example, Dart_ToString).
 *
 *   An unhandled exception error provides access to an exception and
 *   stacktrace via the functions Dart_ErrorGetException and
 *   Dart_ErrorGetStacktrace.
 *
 * - Compilation error handles are produced when, during the execution
 *   of Dart code, a compile-time error occurs.  As above, this can
 *   occur in any function which triggers the execution of Dart code.
 *
 * - Fatal error handles are produced when the system wants to shut
 *   down the current isolate.
 *
 * --- Propagating errors ---
 *
 * When an error handle is returned from the top level invocation of
 * Dart code in a program, the embedder must handle the error as they
 * see fit.  Often, the embedder will print the error message produced
 * by Dart_Error and exit the program.
 *
 * When an error is returned while in the body of a native function,
 * it can be propagated by calling Dart_PropagateError.  Errors should
 * be propagated unless there is a specific reason not to.  If an
 * error is not propagated then it is ignored.  For example, if an
 * unhandled exception error is ignored, that effectively "catches"
 * the unhandled exception.  Fatal errors must always be propagated.
 *
 * Note that a call to Dart_PropagateError never returns.  Instead it
 * transfers control non-locally using a setjmp-like mechanism.  This
 * can be inconvenient if you have resources that you need to clean up
 * before propagating the error.  When an error is propagated, any
 * current scopes created by Dart_EnterScope will be exited.
 *
 * To deal with this inconvenience, we often return error handles
 * rather than propagating them from helper functions.  Consider the
 * following contrived example:
 *
 * 1    Dart_Handle isLongStringHelper(Dart_Handle arg) {
 * 2      intptr_t* length = 0;
 * 3      result = Dart_StringLength(arg, &length);
 * 4      if (Dart_IsError(result)) {
 * 5        return result
 * 6      }
 * 7      return Dart_NewBoolean(length > 100);
 * 8    }
 * 9
 * 10   void NativeFunction_isLongString(Dart_NativeArguments args) {
 * 11     Dart_EnterScope();
 * 12     AllocateMyResource();
 * 13     Dart_Handle arg = Dart_GetNativeArgument(args, 0);
 * 14     Dart_Handle result = isLongStringHelper(arg);
 * 15     if (Dart_IsError(result)) {
 * 16       FreeMyResource();
 * 17       Dart_PropagateError(result);
 * 18       abort();  // will not reach here
 * 19     }
 * 20     Dart_SetReturnValue(result);
 * 21     FreeMyResource();
 * 22     Dart_ExitScope();
 * 23   }
 *
 * In this example, we have a native function which calls a helper
 * function to do its work.  On line 5, the helper function could call
 * Dart_PropagateError, but that would not give the native function a
 * chance to call FreeMyResource(), causing a leak.  Instead, the
 * helper function returns the error handle to the caller, giving the
 * caller a chance to clean up before propagating the error handle.
 *
 * --- Local and persistent handles ---
 *
 * Local handles are allocated within the current scope (see
 * Dart_EnterScope) and go away when the current scope exits. Unless
 * otherwise indicated, callers should assume that all functions in
 * the Dart embedding api return local handles.
 *
 * Persistent handles are allocated within the current isolate. They
 * can be used to store objects across scopes. Persistent handles have
 * the lifetime of the current isolate unless they are explicitly
 * deallocated (see Dart_DeletePersistentHandle).
 */
typedef struct _Dart_Handle* Dart_Handle;

typedef void (*Dart_WeakPersistentHandleFinalizer)(Dart_Handle handle,
                                                   void* peer);
typedef void (*Dart_PeerFinalizer)(void* peer);

/**
 * Is this an error handle?
 *
 * Requires there to be a current isolate.
 */
DART_EXPORT bool Dart_IsError(Dart_Handle handle);

/**
 * Is this an api error handle?
 *
 * Api error handles are produced when an api function is misused.
 * This happens when a Dart embedding api function is called with
 * invalid arguments or in an invalid context.
 *
 * Requires there to be a current isolate.
 */
DART_EXPORT bool Dart_IsApiError(Dart_Handle handle);

/**
 * Is this an unhandled exception error handle?
 *
 * Unhandled exception error handles are produced when, during the
 * execution of Dart code, an exception is thrown but not caught.
 * This can occur in any function which triggers the execution of Dart
 * code.
 *
 * See Dart_ErrorGetException and Dart_ErrorGetStacktrace.
 *
 * Requires there to be a current isolate.
 */
DART_EXPORT bool Dart_IsUnhandledExceptionError(Dart_Handle handle);

/**
 * Is this a compilation error handle?
 *
 * Compilation error handles are produced when, during the execution
 * of Dart code, a compile-time error occurs.  This can occur in any
 * function which triggers the execution of Dart code.
 *
 * Requires there to be a current isolate.
 */
DART_EXPORT bool Dart_IsCompilationError(Dart_Handle handle);

/**
 * Is this a fatal error handle?
 *
 * Fatal error handles are produced when the system wants to shut down
 * the current isolate.
 *
 * Requires there to be a current isolate.
 */
DART_EXPORT bool Dart_IsFatalError(Dart_Handle handle);

/**
 * Gets the error message from an error handle.
 *
 * Requires there to be a current isolate.
 *
 * \return A C string containing an error message if the handle is
 *   error. An empty C string ("") if the handle is valid. This C
 *   String is scope allocated and is only valid until the next call
 *   to Dart_ExitScope.
*/
DART_EXPORT const char* Dart_GetError(Dart_Handle handle);

/**
 * Is this an error handle for an unhandled exception?
 */
DART_EXPORT bool Dart_ErrorHasException(Dart_Handle handle);

/**
 * Gets the exception Object from an unhandled exception error handle.
 */
DART_EXPORT Dart_Handle Dart_ErrorGetException(Dart_Handle handle);

/**
 * Gets the stack trace Object from an unhandled exception error handle.
 */
DART_EXPORT Dart_Handle Dart_ErrorGetStacktrace(Dart_Handle handle);

/**
 * Produces an api error handle with the provided error message.
 *
 * Requires there to be a current isolate.
 *
 * \param format A printf style format specifier used to construct the
 *   error message.
 */
DART_EXPORT Dart_Handle Dart_NewApiError(const char* format, ...);

/**
 * Produces a new unhandled exception error handle.
 *
 * Requires there to be a current isolate.
 *
 * \param exception An instance of a Dart object to be thrown.
 */
DART_EXPORT Dart_Handle Dart_NewUnhandledExceptionError(Dart_Handle exception);

// Deprecated.
// TODO(turnidge): Remove all uses and delete.
DART_EXPORT Dart_Handle Dart_Error(const char* format, ...);

/**
 * Propagates an error.
 *
 * If the provided handle is an unhandled exception error, this
 * function will cause the unhandled exception to be rethrown.  This
 * will proceeed in the standard way, walking up Dart frames until an
 * appropriate 'catch' block is found, executing 'finally' blocks,
 * etc.
 *
 * If the error is not an unhandled exception error, we will unwind
 * the stack to the next C frame.  Intervening Dart frames will be
 * discarded; specifically, 'finally' blocks will not execute.  This
 * is the standard way that compilation errors (and the like) are
 * handled by the Dart runtime.
 *
 * In either case, when an error is propagated any current scopes
 * created by Dart_EnterScope will be exited.
 *
 * See the additonal discussion under "Propagating Errors" at the
 * beginning of this file.
 *
 * \param An error handle (See Dart_IsError)
 *
 * \return On success, this function does not return.  On failure, an
 *   error handle is returned.
 */
DART_EXPORT Dart_Handle Dart_PropagateError(Dart_Handle handle);
// TODO(turnidge): Should this really return an error handle?
// Consider just terminating.

// Internal routine used for reporting error handles.
DART_EXPORT void _Dart_ReportErrorHandle(const char* file,
                                         int line,
                                         const char* handle_string,
                                         const char* error);

// TODO(turnidge): Move DART_CHECK_VALID to some sort of dart_utils
// header instead of this header.
/**
 * Aborts the process if 'handle' is an error handle.
 *
 * Provided for convenience.
 */
#define DART_CHECK_VALID(handle)                                               \
  {                                                                            \
    Dart_Handle __handle = handle;                                             \
    if (Dart_IsError((__handle))) {                                            \
      _Dart_ReportErrorHandle(__FILE__, __LINE__,                              \
                              #handle, Dart_GetError(__handle));               \
    }                                                                          \
  }                                                                            \


/**
 * Converts an object to a string.
 *
 * May generate an unhandled exception error.
 *
 * \return The converted string if no error occurs during
 *   the conversion. If an error does occur, an error handle is
 *   returned.
 */
DART_EXPORT Dart_Handle Dart_ToString(Dart_Handle object);

/**
 * Checks to see if two handles refer to identically equal objects.
 *
 * This is equivalent to using the triple-equals (===) operator.
 *
 * \param obj1 An object to be compared.
 * \param obj2 An object to be compared.
 *
 * \return True if the objects are identically equal.  False otherwise.
 */
DART_EXPORT bool Dart_IdentityEquals(Dart_Handle obj1, Dart_Handle obj2);

/**
 * Allocates a persistent handle for an object.
 *
 * This handle has the lifetime of the current isolate unless it is
 * explicitly deallocated by calling Dart_DeletePersistentHandle.
 *
 * Requires there to be a current isolate.
 */
DART_EXPORT Dart_Handle Dart_NewPersistentHandle(Dart_Handle object);

/**
 * Deallocates a persistent handle.
 *
 * Requires there to be a current isolate.
 */
DART_EXPORT void Dart_DeletePersistentHandle(Dart_Handle object);

/**
 * Allocates a weak persistent handle for an object.
 *
 * This handle has the lifetime of the current isolate unless it is
 * explicitly deallocated by calling Dart_DeletePersistentHandle.
 *
 * Requires there to be a current isolate.
 *
 * \param object An object.
 * \param peer A pointer to a native object or NULL.  This value is
 *   provided to callback when it is invoked.
 * \param callback A function pointer that will be invoked sometime
 *   after the object is garbage collected.
 *
 * \return Success if the weak persistent handle was
 *   created. Otherwise, returns an error.
 */
DART_EXPORT Dart_Handle Dart_NewWeakPersistentHandle(
    Dart_Handle object,
    void* peer,
    Dart_WeakPersistentHandleFinalizer callback);

/**
 * Is this object a weak persistent handle?
 *
 * Requires there to be a current isolate.
 */
DART_EXPORT bool Dart_IsWeakPersistentHandle(Dart_Handle object);

/**
 * Allocates a prologue weak persistent handle for an object.
 *
 * Prologue weak persistent handles are similar to weak persistent
 * handles but exhibit different behavior during garbage collections
 * that invoke the prologue and epilogue callbacks.  While weak
 * persistent handles always weakly reference their referents,
 * prologue weak persistent handles weakly reference their referents
 * only during a garbage collection that invokes the prologue and
 * epilogue callbacks.  During all other garbage collections, prologue
 * weak persistent handles strongly reference their referents.
 *
 * This handle has the lifetime of the current isolate unless it is
 * explicitly deallocated by calling Dart_DeletePersistentHandle.
 *
 * Requires there to be a current isolate.
 *
 * \param object An object.
 * \param peer A pointer to a native object or NULL.  This value is
 *   provided to callback when it is invoked.
 * \param callback A function pointer that will be invoked sometime
 *   after the object is garbage collected.
 *
 * \return Success if the prologue weak persistent handle was created.
 *   Otherwise, returns an error.
 */
DART_EXPORT Dart_Handle Dart_NewPrologueWeakPersistentHandle(
    Dart_Handle object,
    void* peer,
    Dart_WeakPersistentHandleFinalizer callback);

/**
 * Is this object a prologue weak persistent handle?
 *
 * Requires there to be a current isolate.
 */
DART_EXPORT bool Dart_IsPrologueWeakPersistentHandle(Dart_Handle object);

/**
 * Constructs a set of weak references from the Cartesian product of
 * the objects in the key set and the objects in values set.
 *
 * \param keys A set of object references.  These references will be
 *   considered weak by the garbage collector.
 * \param num_keys the number of objects in the keys set.
 * \param values A set of object references.  These references will be
 *   considered weak by garbage collector unless any object reference
 *   in 'keys' is found to be strong.
 * \param num_values the size of the values set
 *
 * \return Success if the weak reference set could be created.
 *   Otherwise, returns an error handle.
 */
DART_EXPORT Dart_Handle Dart_NewWeakReferenceSet(Dart_Handle* keys,
                                                 intptr_t num_keys,
                                                 Dart_Handle* values,
                                                 intptr_t num_values);

// --- Garbage Collection Callbacks ---

/**
 * Callbacks signal the beginning and end of a garbage collection.
 *
 * These signals are intended to be used by the embedder to manage the
 * lifetime of native objects with a managed object peer.
 */

/**
 * A callback invoked at the beginning of a garbage collection.
 */
typedef void (*Dart_GcPrologueCallback)();

/**
 * A callback invoked at the end of a garbage collection.
 */
typedef void (*Dart_GcEpilogueCallback)();

/**
 * Adds a garbage collection prologue callback.
 *
 * \param callback A function pointer to a prologue callback function.
 *   This function must not have been previously added as a prologue
 *   callback.
 *
 * \return Success if the callback was added.  Otherwise, returns an
 *   error handle.
 */
DART_EXPORT Dart_Handle Dart_AddGcPrologueCallback(
    Dart_GcPrologueCallback callback);

/**
 * Removes a garbage collection prologue callback.
 *
 * \param callback A function pointer to a prologue callback function.
 *   This function must have been added as a prologue callback.
 *
 * \return Success if the callback was removed.  Otherwise, returns an
 *   error handle.
 */
DART_EXPORT Dart_Handle Dart_RemoveGcPrologueCallback(
    Dart_GcPrologueCallback callback);

/**
 * Adds a garbage collection epilogue callback.
 *
 * \param callback A function pointer to an epilogue callback
 *   function.  This function must not have been previously added as
 *   an epilogue callback.
 *
 * \return Success if the callback was added.  Otherwise, returns an
 *   error handle.
 */
DART_EXPORT Dart_Handle Dart_AddGcEpilogueCallback(
    Dart_GcEpilogueCallback callback);

/**
 * Removes a garbage collection epilogue callback.
 *
 * \param callback A function pointer to an epilogue callback
 *   function.  This function must have been added as an epilogue
 *   callback.
 *
 * \return Success if the callback was removed.  Otherwise, returns an
 *   error handle.
 */
DART_EXPORT Dart_Handle Dart_RemoveGcEpilogueCallback(
    Dart_GcEpilogueCallback callback);

// --- Initialization and Globals ---

/**
 * Gets the version string for the Dart VM.
 *
 * The version of the Dart VM can be accessed without initializing the VM.
 *
 * \return The version string for the embedded Dart VM.
 */
DART_EXPORT const char* Dart_VersionString();

/**
 * An isolate is the unit of concurrency in Dart. Each isolate has
 * its own memory and thread of control. No state is shared between
 * isolates. Instead, isolates communicate by message passing.
 *
 * Each thread keeps track of its current isolate, which is the
 * isolate which is ready to execute on the current thread. The
 * current isolate may be NULL, in which case no isolate is ready to
 * execute. Most of the Dart apis require there to be a current
 * isolate in order to function without error. The current isolate is
 * set by any call to Dart_CreateIsolate or Dart_EnterIsolate.
 */
typedef struct _Dart_Isolate* Dart_Isolate;

/**
 * An isolate creation and initialization callback function.
 *
 * This callback, provided by the embedder, is called when the vm
 * needs to create an isolate. The callback should create an isolate
 * by calling Dart_CreateIsolate and load any scripts required for
 * execution.
 *
 * When the function returns false, it is the responsibility of this
 * function to ensure that Dart_ShutdownIsolate has been called if
 * required (for example, if the isolate was created successfully by
 * Dart_CreateIsolate() but the root library fails to load
 * successfully, then the function should call Dart_ShutdownIsolate
 * before returning).
 *
 * When the function returns false, the function should set *error to
 * a malloc-allocated buffer containing a useful error message.  The
 * caller of this function (the vm) will make sure that the buffer is
 * freed.
 *
 * \param script_uri The uri of the script to load.  This uri has been
 *   canonicalized by the library tag handler from the parent isolate.
 *   The callback is responsible for loading this script by a call to
 *   Dart_LoadScript or Dart_LoadScriptFromSnapshot.
 * \param main The name of the main entry point this isolate will
 *   eventually run.  This is provided for advisory purposes only to
 *   improve debugging messages.  The main function is not invoked by
 *   this function.
 * \param unhandled_exc The name of the function to this isolate will
 *   call when an unhandled exception is encountered.
 * \param callback_data The callback data which was passed to the
 *   parent isolate when it was created by calling Dart_CreateIsolate().
 * \param error A structure into which the embedder can place a
 *   C string containing an error message in the case of failures.
 *
 * \return The embedder returns NULL if the creation and
 *   initialization was not successful and the isolate if successful.
 */
typedef Dart_Isolate (*Dart_IsolateCreateCallback)(const char* script_uri,
                                                   const char* main,
                                                   void* callback_data,
                                                   char** error);

/**
 * An isolate interrupt callback function.
 *
 * This callback, provided by the embedder, is called when an isolate
 * is interrupted as a result of a call to Dart_InterruptIsolate().
 * When the callback is called, Dart_CurrentIsolate can be used to
 * figure out which isolate is being interrupted.
 *
 * \return The embedder returns true if the isolate should continue
 *   execution. If the embedder returns false, the isolate will be
 *   unwound (currently unimplemented).
 */
typedef bool (*Dart_IsolateInterruptCallback)();
// TODO(turnidge): Define and implement unwinding.

/**
 * An isolate unhandled exception callback function.
 *
 * This callback, provided by the embedder, is called when an unhandled
 * exception or internal error is thrown during isolate execution. When the
 * callback is invoked, Dart_CurrentIsolate can be used to figure out which
 * isolate was running when the exception was thrown.
 *
 * \param error The unhandled exception or error.  This handle's scope is
 *   only valid until the embedder returns from this callback.
 */
typedef void (*Dart_IsolateUnhandledExceptionCallback)(Dart_Handle error);

/**
 * An isolate shutdown callback function.
 *
 * This callback, provided by the embedder, is called after the vm
 * shuts down an isolate.  Since the isolate has been shut down, it is
 * not safe to enter the isolate or use it to run any Dart code.
 *
 * This function should be used to dispose of native resources that
 * are allocated to an isolate in order to avoid leaks.
 *
 * \param callback_data The same callback data which was passed to the
 *   isolate when it was created.
 *
 */
typedef void (*Dart_IsolateShutdownCallback)(void* callback_data);

typedef void* (*Dart_FileOpenCallback)(const char* name);

typedef void (*Dart_FileWriteCallback)(const void* data,
                                       intptr_t length,
                                       void* stream);

typedef void (*Dart_FileCloseCallback)(void* stream);


/**
 * Initializes the VM.
 *
 * \param create A function to be called during isolate creation.
 *   See Dart_IsolateCreateCallback.
 * \param interrupt A function to be called when an isolate is interrupted.
 *   See Dart_IsolateInterruptCallback.
 * \param unhandled_exception A function to be called if an isolate has an
 *   unhandled exception.  Set Dart_IsolateUnhandledExceptionCallback.
 * \param shutdown A function to be called when an isolate is shutdown.
 *   See Dart_IsolateShutdownCallback.
 *
 * \return True if initialization is successful.
 */
DART_EXPORT bool Dart_Initialize(
    Dart_IsolateCreateCallback create,
    Dart_IsolateInterruptCallback interrupt,
    Dart_IsolateUnhandledExceptionCallback unhandled_exception,
    Dart_IsolateShutdownCallback shutdown,
    Dart_FileOpenCallback file_open,
    Dart_FileWriteCallback file_write,
    Dart_FileCloseCallback file_close);

/**
 * Sets command line flags. Should be called before Dart_Initialize.
 *
 * \param argc The length of the arguments array.
 * \param argv An array of arguments.
 *
 * \return True if VM flags set successfully.
 */
DART_EXPORT bool Dart_SetVMFlags(int argc, const char** argv);

/**
 * Returns true if the named VM flag is set.
 */
DART_EXPORT bool Dart_IsVMFlagSet(const char* flag_name);

// --- Isolates ---

/**
 * Creates a new isolate. The new isolate becomes the current isolate.
 *
 * A snapshot can be used to restore the VM quickly to a saved state
 * and is useful for fast startup. If snapshot data is provided, the
 * isolate will be started using that snapshot data.
 *
 * Requires there to be no current isolate.
 *
 * \param script_uri The name of the script this isolate will load.
 *   Provided only for advisory purposes to improve debugging messages.
 * \param main The name of the main entry point this isolate will run.
 *   Provided only for advisory purposes to improve debugging messages.
 * \param snapshot A buffer containing a VM snapshot or NULL if no
 *   snapshot is provided.
 * \param callback_data Embedder data.  This data will be passed to
 *   the Dart_IsolateCreateCallback when new isolates are spawned from
 *   this parent isolate.
 * \param error DOCUMENT
 *
 * \return The new isolate is returned. May be NULL if an error
 *   occurs duing isolate initialization.
 */
DART_EXPORT Dart_Isolate Dart_CreateIsolate(const char* script_uri,
                                            const char* main,
                                            const uint8_t* snapshot,
                                            void* callback_data,
                                            char** error);
// TODO(turnidge): Document behavior when there is already a current
// isolate.

/**
 * Shuts down the current isolate. After this call, the current
 * isolate is NULL.
 *
 * Requires there to be a current isolate.
 */
DART_EXPORT void Dart_ShutdownIsolate();
// TODO(turnidge): Document behavior when there is no current isolate.

/**
 * Returns the current isolate. Will return NULL if there is no
 * current isolate.
 */
DART_EXPORT Dart_Isolate Dart_CurrentIsolate();

/**
 * Returns the callback data which was passed to the isolate when it
 * was created.
 */
DART_EXPORT void* Dart_CurrentIsolateData();

/**
 * Returns the debugging name for the current isolate.
 *
 * This name is unique to each isolate and should only be used to make
 * debugging messages more comprehensible.
 */
DART_EXPORT Dart_Handle Dart_DebugName();

/**
 * Enters an isolate. After calling this function,
 * the current isolate will be set to the provided isolate.
 *
 * Requires there to be no current isolate.
 */
DART_EXPORT void Dart_EnterIsolate(Dart_Isolate isolate);
// TODO(turnidge): Describe what happens if two threads attempt to
// enter the same isolate simultaneously. Check for this in the code.
// Describe whether isolates are allowed to migrate.

/**
 * Exits an isolate. After this call, Dart_CurrentIsolate will
 * return NULL.
 *
 * Requires there to be a current isolate.
 */
DART_EXPORT void Dart_ExitIsolate();
// TODO(turnidge): We don't want users of the api to be able to exit a
// "pure" dart isolate. Implement and document.

/**
 * Creates a full snapshot of the current isolate heap.
 *
 * A full snapshot is a compact representation of the dart heap state and
 * can be used for fast initialization of an isolate. A Snapshot of the heap
 * can only be created before any dart code has executed.
 *
 * Requires there to be a current isolate.
 *
 * \param buffer Returns a pointer to a buffer containing the
 *   snapshot. This buffer is scope allocated and is only valid
 *   until the next call to Dart_ExitScope.
 * \param size Returns the size of the buffer.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_CreateSnapshot(uint8_t** buffer,
                                            intptr_t* size);

/**
 * Creates a snapshot of the application script loaded in the isolate.
 *
 * A script snapshot can be used for implementing fast startup of applications
 * (skips the script tokenizing and parsing process). A Snapshot of the script
 * can only be created before any dart code has executed.
 *
 * Requires there to be a current isolate which already has loaded script.
 *
 * \param buffer Returns a pointer to a buffer containing
 *   the snapshot. This buffer is scope allocated and is only valid
 *   until the next call to Dart_ExitScope.
 * \param size Returns the size of the buffer.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_CreateScriptSnapshot(uint8_t** buffer,
                                                  intptr_t* size);


/**
 * Schedules an interrupt for the specified isolate.
 *
 * Note that the interrupt does not occur immediately. In fact, if
 * 'isolate' does not execute any further Dart code, then the
 * interrupt will not occur at all.  If and when the isolate is
 * interrupted, the isolate interrupt callback will be invoked with
 * 'isolate' as the current isolate (see
 * Dart_IsolateInterruptCallback).
 *
 * \param isolate The isolate to be interrupted.
 */
DART_EXPORT void Dart_InterruptIsolate(Dart_Isolate isolate);


/**
 * Make isolate runnable.
 *
 * When isolates are spawned this function is used to indicate that
 * the creation and initialization (including script loading) of the
 * isolate is complete and the isolate can start.
 * This function does not expect there to be a current isolate.
 *
 * \param isolate The isolate to be made runnable.
 */
DART_EXPORT bool Dart_IsolateMakeRunnable(Dart_Isolate isolate);


// --- Messages and Ports ---

/**
 * A port is used to send or receive inter-isolate messages
 */
typedef int64_t Dart_Port;

/**
 * ILLEGAL_PORT is a port number guaranteed never to be associated with a valid
 * port.
 */
#define ILLEGAL_PORT ((Dart_Port) 0)

/**
 * A message notification callback.
 *
 * This callback allows the embedder to provide an alternate wakeup
 * mechanism for the delivery of inter-isolate messages.  It is the
 * responsibility of the embedder to call Dart_HandleMessage to
 * process the message.
 */
typedef void (*Dart_MessageNotifyCallback)(Dart_Isolate dest_isolate);

/**
 * Allows embedders to provide an alternative wakeup mechanism for the
 * delivery of inter-isolate messages. This setting only applies to
 * the current isolate.
 *
 * Most embedders will only call this function once, before isolate
 * execution begins. If this function is called after isolate
 * execution begins, the embedder is responsible for threading issues.
 */
DART_EXPORT void Dart_SetMessageNotifyCallback(
    Dart_MessageNotifyCallback message_notify_callback);
// TODO(turnidge): Consider moving this to isolate creation so that it
// is impossible to mess up.

/**
 * Handles the next pending message for the current isolate.
 *
 * May generate an unhandled exception error.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_HandleMessage();

/**
 * Processes any incoming messages for the current isolate.
 *
 * This function may only be used when the embedder has not provided
 * an alternate message delivery mechanism with
 * Dart_SetMessageCallbacks. It is provided for convenience.
 *
 * This function waits for incoming messages for the current
 * isolate. As new messages arrive, they are handled using
 * Dart_HandleMessage. The routine exits when all ports to the
 * current isolate are closed.
 *
 * \return A valid handle if the run loop exited successfully.  If an
 *   exception or other error occurs while processing messages, an
 *   error handle is returned.
 */
DART_EXPORT Dart_Handle Dart_RunLoop();
// TODO(turnidge): Should this be removed from the public api?

/**
 * Gets the main port id for the current isolate.
 */
DART_EXPORT Dart_Port Dart_GetMainPortId();

/**
 * Does the current isolate have live ReceivePorts?
 *
 * A ReceivePort is live when it has not been closed.
 */
DART_EXPORT bool Dart_HasLivePorts();

/**
 * Posts a message for some isolate. The message is a serialized
 * object.
 *
 * Requires there to be a current isolate.
 *
 * \param port The destination port.
 * \param object An object from the current isolate.
 *
 * \return True if the message was posted.
 */
DART_EXPORT bool Dart_Post(Dart_Port port_id, Dart_Handle object);

// --- Message sending/receiving from native code ----

/**
 * A Dart_CObject is used for representing Dart objects as native C
 * data outside the Dart heap. These objects are totally detached from
 * the Dart heap. Only a subset of the Dart objects have a
 * representation as a Dart_CObject.
 *
 * The string encoding in the 'value.as_string' is UTF-8.
 *
 * All the different types from dart:typed_data are exposed as type
 * kTypedData. The specific type from dart:typed_data is in the type
 * field of the as_typed_data structure. The length in the
 * as_typed_data structure is always in bytes.
 */
typedef struct _Dart_CObject {
  enum Type {
    kNull = 0,
    kBool,
    kInt32,
    kInt64,
    kBigint,
    kDouble,
    kString,
    kArray,
    kTypedData,
    kExternalTypedData,
    kUnsupported,
    kNumberOfTypes
  } type;

  enum TypedDataType {
    kInt8Array = 0,
    kUint8Array,
    kUint8ClampedArray,
    kInt16Array,
    kUint16Array,
    kInt32Array,
    kUint32Array,
    kInt64Array,
    kUint64Array,
    kFloat32Array,
    kFloat64Array,
    kNumberOfTypedDataTypes
  };

  union {
    bool as_bool;
    int32_t as_int32;
    int64_t as_int64;
    double as_double;
    char* as_string;
    char* as_bigint;
    struct {
      int length;
      struct _Dart_CObject** values;
    } as_array;
    struct {
      TypedDataType type;
      int length;
      uint8_t* values;
    } as_typed_data;
    struct {
      TypedDataType type;
      int length;
      uint8_t* data;
      void* peer;
      Dart_WeakPersistentHandleFinalizer callback;
    } as_external_typed_data;
  } value;
} Dart_CObject;

/**
 * Posts a message on some port. The message will contain the
 * Dart_CObject object graph rooted in 'message'.
 *
 * While the message is being sent the state of the graph of
 * Dart_CObject structures rooted in 'message' should not be accessed,
 * as the message generation will make temporary modifications to the
 * data. When the message has been sent the graph will be fully
 * restored.
 *
 * \param port_id The destination port.
 * \param message The message to send.
 *
 * \return True if the message was posted.
 */
DART_EXPORT bool Dart_PostCObject(Dart_Port port_id, Dart_CObject* message);

/**
 * A native message handler.
 *
 * This handler is associated with a native port by calling
 * Dart_NewNativePort.
 *
 * The message received is decoded into the message structure. The
 * lifetime of the message data is controlled by the caller. All the
 * data references from the message are allocated by the caller and
 * will be reclaimed when returning to it.
 */

typedef void (*Dart_NativeMessageHandler)(Dart_Port dest_port_id,
                                          Dart_Port reply_port_id,
                                          Dart_CObject* message);

/**
 * Creates a new native port.  When messages are received on this
 * native port, then they will be dispatched to the provided native
 * message handler.
 *
 * \param name The name of this port in debugging messages.
 * \param handler The C handler to run when messages arrive on the port.
 * \param handle_concurrently Is it okay to process requests on this
 *                            native port concurrently?
 *
 * \return If successful, returns the port id for the native port.  In
 *   case of error, returns ILLEGAL_PORT.
 */
DART_EXPORT Dart_Port Dart_NewNativePort(const char* name,
                                         Dart_NativeMessageHandler handler,
                                         bool handle_concurrently);
// TODO(turnidge): Currently handle_concurrently is ignored.

/**
 * Closes the native port with the given id.
 *
 * The port must have been allocated by a call to Dart_NewNativePort.
 *
 * \param native_port_id The id of the native port to close.
 *
 * \return Returns true if the port was closed successfully.
 */
DART_EXPORT bool Dart_CloseNativePort(Dart_Port native_port_id);

/**
 * Returns a new SendPort with the provided port id.
 */
DART_EXPORT Dart_Handle Dart_NewSendPort(Dart_Port port_id);

/**
 * Gets the ReceivePort for the provided port id, creating it if necessary.
 *
 * Note that there is at most one ReceivePort for a given port id.
 */
DART_EXPORT Dart_Handle Dart_GetReceivePort(Dart_Port port_id);

// --- Scopes ----

/**
 * Enters a new scope.
 *
 * All new local handles will be created in this scope. Additionally,
 * some functions may return "scope allocated" memory which is only
 * valid within this scope.
 *
 * Requires there to be a current isolate.
 */
DART_EXPORT void Dart_EnterScope();

/**
 * Exits a scope.
 *
 * The previous scope (if any) becomes the current scope.
 *
 * Requires there to be a current isolate.
 */
DART_EXPORT void Dart_ExitScope();

/**
 * The Dart VM uses "zone allocation" for temporary structures. Zones
 * support very fast allocation of small chunks of memory. The chunks
 * cannot be deallocated individually, but instead zones support
 * deallocating all chunks in one fast operation.
 *
 * This function makes it possible for the embedder to allocate
 * temporary data in the VMs zone allocator.
 *
 * Zone allocation is possible:
 *   1. when inside a scope where local handles can be allocated
 *   2. when processing a message from a native port in a native port
 *      handler
 *
 * All the memory allocated this way will be reclaimed either on the
 * next call to Dart_ExitScope or when the native port handler exits.
 *
 * \param size Size of the memory to allocate.
 *
 * \return A pointer to the allocated memory. NULL if allocation
 *   failed. Failure might due to is no current VM zone.
 */
DART_EXPORT uint8_t* Dart_ScopeAllocate(intptr_t size);

// --- Objects ----

/**
 * Returns the null object.
 *
 * Requires there to be a current isolate.
 *
 * \return A handle to the null object.
 */
DART_EXPORT Dart_Handle Dart_Null();

/**
 * Is this object null?
 */
DART_EXPORT bool Dart_IsNull(Dart_Handle object);

/**
 * Checks if the two objects are equal.
 *
 * The result of the comparison is returned through the 'equal'
 * parameter. The return value itself is used to indicate success or
 * failure, not equality.
 *
 * May generate an unhandled exception error.
 *
 * \param obj1 An object to be compared.
 * \param obj2 An object to be compared.
 * \param equal Returns the result of the equality comparison.
 *
 * \return A valid handle if no error occurs during the comparison.
 */
DART_EXPORT Dart_Handle Dart_ObjectEquals(Dart_Handle obj1,
                                          Dart_Handle obj2,
                                          bool* equal);

/**
 * Is this object an instance of some type?
 *
 * The result of the test is returned through the 'instanceof' parameter.
 * The return value itself is used to indicate success or failure.
 *
 * \param object An object.
 * \param type A type.
 * \param instanceof Return true if 'object' is an instance of type 'type'.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_ObjectIsType(Dart_Handle object,
                                          Dart_Handle type,
                                          bool* instanceof);

// --- Instances ----
// For the purposes of the embedding api, not all objects returned are
// Dart language objects.  Within the api, we use the term 'Instance'
// to indicate handles which refer to true Dart language objects.
//
// TODO(turnidge): Reorganize the "Object" section above, pulling down
// any functions that more properly belong here.

/**
 * Does this handle refer to some Dart language object?
 */
DART_EXPORT bool Dart_IsInstance(Dart_Handle object);

/**
 * Gets the class for some Dart language object.
 *
 * \param instance Some Dart object.
 *
 * \return If no error occurs, the class is returned. Otherwise an
 *   error handle is returned.
 */
DART_EXPORT Dart_Handle Dart_InstanceGetClass(Dart_Handle instance);

// --- Numbers ----

/**
 * Is this object a Number?
 */
DART_EXPORT bool Dart_IsNumber(Dart_Handle object);

// --- Integers ----

/**
 * Is this object an Integer?
 */
DART_EXPORT bool Dart_IsInteger(Dart_Handle object);

/**
 * Does this Integer fit into a 64-bit signed integer?
 *
 * \param integer An integer.
 * \param fits Returns true if the integer fits into a 64-bit signed integer.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_IntegerFitsIntoInt64(Dart_Handle integer,
                                                  bool* fits);

/**
 * Does this Integer fit into a 64-bit unsigned integer?
 *
 * \param integer An integer.
 * \param fits Returns true if the integer fits into a 64-bit unsigned integer.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_IntegerFitsIntoUint64(Dart_Handle integer,
                                                   bool* fits);

/**
 * Returns an Integer with the provided value.
 *
 * \param value The value of the integer.
 *
 * \return The Integer object if no error occurs. Otherwise returns
 *   an error handle.
 */
DART_EXPORT Dart_Handle Dart_NewInteger(int64_t value);

/**
 * Returns an Integer with the provided value.
 *
 * \param value The value of the integer represented as a C string
 *   containing a hexadecimal number.
 *
 * \return The Integer object if no error occurs. Otherwise returns
 *   an error handle.
 */
DART_EXPORT Dart_Handle Dart_NewIntegerFromHexCString(const char* value);

/**
 * Gets the value of an Integer.
 *
 * The integer must fit into a 64-bit signed integer, otherwise an error occurs.
 *
 * \param integer An Integer.
 * \param value Returns the value of the Integer.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_IntegerToInt64(Dart_Handle integer,
                                            int64_t* value);

/**
 * Gets the value of an Integer.
 *
 * The integer must fit into a 64-bit unsigned integer, otherwise an
 * error occurs.
 *
 * \param integer An Integer.
 * \param value Returns the value of the Integer.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_IntegerToUint64(Dart_Handle integer,
                                             uint64_t* value);

/**
 * Gets the value of an integer as a hexadecimal C string.
 *
 * \param integer An Integer.
 * \param value Returns the value of the Integer as a hexadecimal C
 *   string. This C string is scope allocated and is only valid until
 *   the next call to Dart_ExitScope.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_IntegerToHexCString(Dart_Handle integer,
                                                 const char** value);

// --- Booleans ----

/**
 * Returns the True object.
 *
 * Requires there to be a current isolate.
 *
 * \return A handle to the True object.
 */
DART_EXPORT Dart_Handle Dart_True();

/**
 * Returns the False object.
 *
 * Requires there to be a current isolate.
 *
 * \return A handle to the False object.
 */
DART_EXPORT Dart_Handle Dart_False();

/**
 * Is this object a Boolean?
 */
DART_EXPORT bool Dart_IsBoolean(Dart_Handle object);

/**
 * Returns a Boolean with the provided value.
 *
 * \param value true or false.
 *
 * \return The Boolean object if no error occurs. Otherwise returns
 *   an error handle.
 */
DART_EXPORT Dart_Handle Dart_NewBoolean(bool value);

/**
 * Gets the value of a Boolean
 *
 * \param boolean_obj A Boolean
 * \param value Returns the value of the Boolean.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_BooleanValue(Dart_Handle boolean_obj, bool* value);

// --- Doubles ---

/**
 * Is this object a Double?
 */
DART_EXPORT bool Dart_IsDouble(Dart_Handle object);

/**
 * Returns a Double with the provided value.
 *
 * \param value A double.
 *
 * \return The Double object if no error occurs. Otherwise returns
 *   an error handle.
 */
DART_EXPORT Dart_Handle Dart_NewDouble(double value);

/**
 * Gets the value of a Double
 *
 * \param double_obj A Double
 * \param value Returns the value of the Double.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_DoubleValue(Dart_Handle double_obj, double* value);

// --- Strings ---

/**
 * Is this object a String?
 */
DART_EXPORT bool Dart_IsString(Dart_Handle object);

/**
 * Is this object a Latin-1 (ISO-8859-1) String?
 */
DART_EXPORT bool Dart_IsStringLatin1(Dart_Handle object);

/**
 * Gets the length of a String.
 *
 * \param str A String.
 * \param length Returns the length of the String.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_StringLength(Dart_Handle str, intptr_t* length);

/**
 * Returns a String built from the provided C string
 * (There is an implicit assumption that the C string passed in contains
 *  UTF-8 encoded characters and '\0' is considered as a termination
 *  character).
 *
 * \param value A C String
 *
 * \return The String object if no error occurs. Otherwise returns
 *   an error handle.
 */
DART_EXPORT Dart_Handle Dart_NewStringFromCString(const char* str);
// TODO(turnidge): Document what happens when we run out of memory
// during this call.

/**
 * Returns a String built from an array of UTF-8 encoded characters.
 *
 * \param utf8_array An array of UTF-8 encoded characters.
 * \param length The length of the codepoints array.
 *
 * \return The String object if no error occurs. Otherwise returns
 *   an error handle.
 */
DART_EXPORT Dart_Handle Dart_NewStringFromUTF8(const uint8_t* utf8_array,
                                               intptr_t length);

/**
 * Returns a String built from an array of UTF-16 encoded characters.
 *
 * \param utf16_array An array of UTF-16 encoded characters.
 * \param length The length of the codepoints array.
 *
 * \return The String object if no error occurs. Otherwise returns
 *   an error handle.
 */
DART_EXPORT Dart_Handle Dart_NewStringFromUTF16(const uint16_t* utf16_array,
                                                intptr_t length);

/**
 * Returns a String built from an array of UTF-32 encoded characters.
 *
 * \param utf32_array An array of UTF-32 encoded characters.
 * \param length The length of the codepoints array.
 *
 * \return The String object if no error occurs. Otherwise returns
 *   an error handle.
 */
DART_EXPORT Dart_Handle Dart_NewStringFromUTF32(const int32_t* utf32_array,
                                                intptr_t length);

/**
 * Is this object an external String?
 *
 * An external String is a String which references a fixed array of
 * codepoints which is external to the Dart heap.
 */
DART_EXPORT bool Dart_IsExternalString(Dart_Handle object);

/**
 * Retrieves the peer pointer associated with an external String.
 */
DART_EXPORT Dart_Handle Dart_ExternalStringGetPeer(Dart_Handle object,
                                                   void** peer);

/**
 * Returns a String which references an external array of
 * Latin-1 (ISO-8859-1) encoded characters.
 *
 * \param latin1_array Array of Latin-1 encoded characters. This must not move.
 * \param length The length of the characters array.
 * \param peer An external pointer to associate with this string.
 * \param cback A callback to be called when this string is finalized.
 *
 * \return The String object if no error occurs. Otherwise returns
 *   an error handle.
 */
DART_EXPORT Dart_Handle Dart_NewExternalLatin1String(
    const uint8_t* latin1_array,
    intptr_t length,
    void* peer,
    Dart_PeerFinalizer cback);

/**
 * Returns a String which references an external array of UTF-16 encoded
 * characters.
 *
 * \param utf16_array An array of UTF-16 encoded characters. This must not move.
 * \param length The length of the characters array.
 * \param peer An external pointer to associate with this string.
 * \param cback A callback to be called when this string is finalized.
 *
 * \return The String object if no error occurs. Otherwise returns
 *   an error handle.
 */
DART_EXPORT Dart_Handle Dart_NewExternalUTF16String(const uint16_t* utf16_array,
                                                    intptr_t length,
                                                    void* peer,
                                                    Dart_PeerFinalizer cback);

/**
 * Gets the C string representation of a String.
 * (It is a sequence of UTF-8 encoded values with a '\0' termination.)
 *
 * \param str A string.
 * \param cstr Returns the String represented as a C string.
 *   This C string is scope allocated and is only valid until
 *   the next call to Dart_ExitScope.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_StringToCString(Dart_Handle str,
                                             const char** cstr);

/**
 * Gets a UTF-8 encoded representation of a String.
 *
 * \param str A string.
 * \param utf8_array Returns the String represented as UTF-8 code
 *   units.  This UTF-8 array is scope allocated and is only valid
 *   until the next call to Dart_ExitScope.
 * \param length Used to return the length of the array which was
 *   actually used.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_StringToUTF8(Dart_Handle str,
                                          uint8_t** utf8_array,
                                          intptr_t* length);

/**
 * Gets the data corresponding to the string object. This function returns
 * the data only for Latin-1 (ISO-8859-1) string objects. For all other
 * string objects it return and error.
 *
 * \param str A string.
 * \param latin1_array An array allocated by the caller, used to return
 *   the string data.
 * \param length Used to pass in the length of the provided array.
 *   Used to return the length of the array which was actually used.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_StringToLatin1(Dart_Handle str,
                                            uint8_t* latin1_array,
                                            intptr_t* length);

/**
 * Gets the UTF-16 encoded representation of a string.
 *
 * \param str A string.
 * \param utf16_array An array allocated by the caller, used to return
 *   the array of UTF-16 encoded characters.
 * \param length Used to pass in the length of the provided array.
 *   Used to return the length of the array which was actually used.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_StringToUTF16(Dart_Handle str,
                                           uint16_t* utf16_array,
                                           intptr_t* length);

/**
 * Gets the storage size in bytes of a String.
 *
 * \param str A String.
 * \param length Returns the storage size in bytes of the String.
 *  This is the size in bytes needed to store the String.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_StringStorageSize(Dart_Handle str, intptr_t* size);


/**
 * Converts a String into an ExternalString.
 * The original object is morphed into an external string object.
 *
 * \param array External space into which the string data will be
 *   copied into. This must not move.
 * \param length The size in bytes of the provided external space (array).
 * \param peer An external pointer to associate with this string.
 * \param cback A callback to be called when this string is finalized.
 *
 * \return the converted ExternalString object if no error occurs.
 *   Otherwise returns an error handle.
 *   If the object is a valid string but if it cannot be externalized
 *   then Dart_Null() is returned and the string data is copied into
 *   the external space specified.
 *
 * For example:
 *  intptr_t size;
 *  Dart_Handle result;
 *  result = DartStringStorageSize(str, &size);
 *  void* data = malloc(size);
 *  result = Dart_MakeExternalString(str, data, size, NULL, NULL);
 *
 */
DART_EXPORT Dart_Handle Dart_MakeExternalString(Dart_Handle str,
                                                void* array,
                                                intptr_t length,
                                                void* peer,
                                                Dart_PeerFinalizer cback);


// --- Lists ---

/**
 * Is this object a List?
 */
DART_EXPORT bool Dart_IsList(Dart_Handle object);

/**
 * Returns a List of the desired length.
 *
 * \param length The length of the list.
 *
 * \return The List object if no error occurs. Otherwise returns
 *   an error handle.
 */
DART_EXPORT Dart_Handle Dart_NewList(intptr_t length);

/**
 * Gets the length of a List.
 *
 * May generate an unhandled exception error.
 *
 * \param list A List.
 * \param length Returns the length of the List.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_ListLength(Dart_Handle list, intptr_t* length);

/**
 * Gets the Object at some index of a List.
 *
 * If the index is out of bounds, an error occurs.
 *
 * May generate an unhandled exception error.
 *
 * \param list A List.
 * \param index A valid index into the List.
 *
 * \return The Object in the List at the specified index if no errors
 *   occurs. Otherwise returns an error handle.
 */
DART_EXPORT Dart_Handle Dart_ListGetAt(Dart_Handle list,
                                       intptr_t index);

/**
 * Sets the Object at some index of a List.
 *
 * If the index is out of bounds, an error occurs.
 *
 * May generate an unhandled exception error.
 *
 * \param array A List.
 * \param index A valid index into the List.
 * \param value The Object to put in the List.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_ListSetAt(Dart_Handle list,
                                       intptr_t index,
                                       Dart_Handle value);

/**
 * May generate an unhandled exception error.
 */
DART_EXPORT Dart_Handle Dart_ListGetAsBytes(Dart_Handle list,
                                            intptr_t offset,
                                            uint8_t* native_array,
                                            intptr_t length);

/**
 * May generate an unhandled exception error.
 */
DART_EXPORT Dart_Handle Dart_ListSetAsBytes(Dart_Handle list,
                                            intptr_t offset,
                                            uint8_t* native_array,
                                            intptr_t length);

// --- Typed Data ---

typedef enum {
  kByteData = 0,
  kInt8,
  kUint8,
  kUint8Clamped,
  kInt16,
  kUint16,
  kInt32,
  kUint32,
  kInt64,
  kUint64,
  kFloat32,
  kFloat64,
  kFloat32x4,
  kInvalid
} Dart_TypedData_Type;

/**
 * Return type if this object is a TypedData object.
 *
 * \return kInvalid if the object is not a TypedData object or the appropriate
 *   Dart_TypedData_Type.
 */
DART_EXPORT Dart_TypedData_Type Dart_GetTypeOfTypedData(Dart_Handle object);

/**
 * Return type if this object is an external TypedData object.
 *
 * \return kInvalid if the object is not an external TypedData object or
 *   the appropriate Dart_TypedData_Type.
 */
DART_EXPORT Dart_TypedData_Type Dart_GetTypeOfExternalTypedData(
    Dart_Handle object);

/**
 * Returns a TypedData object of the desired length and type.
 *
 * \param type The type of the TypedData object.
 * \param length The length of the TypedData object (length in type units).
 *
 * \return The TypedData object if no error occurs. Otherwise returns
 *   an error handle.
 */
DART_EXPORT Dart_Handle Dart_NewTypedData(Dart_TypedData_Type type,
                                          intptr_t length);

/**
 * Returns a TypedData object which references an external data array.
 *
 * \param type The type of the data array.
 * \param value A data array. This array must not move.
 * \param length The length of the data array (length in type units).
 * \param peer An external pointer to associate with this array.
 *
 * \return The TypedData object if no error occurs. Otherwise returns
 *   an error handle. The TypedData object is returned in a
 *   WeakPersistentHandle which needs to be deleted in the specified callback
 *   using Dart_DeletePersistentHandle.
 */
DART_EXPORT Dart_Handle Dart_NewExternalTypedData(
    Dart_TypedData_Type type,
    void* data,
    intptr_t length,
    void* peer,
    Dart_WeakPersistentHandleFinalizer callback);

/**
 * Retrieves the peer pointer associated with an external TypedData object.
 */
DART_EXPORT Dart_Handle Dart_ExternalTypedDataGetPeer(Dart_Handle object,
                                                      void** peer);

/**
 * Acquires access to the internal data address of a TypedData object.
 *
 * \param object The typed data object whose internal data address is to
 *    be accessed.
 * \param type The type of the object is returned here.
 * \param data The internal data address is returned here.
 * \param len Size of the typed array is returned here.
 *
 * Note: When the internal address of the object is acquired any calls to a
 *       Dart API function that could potentially allocate an object or run
 *       any Dart code will return an error.
 *
 * \return Success if the internal data address is acquired successfully.
 *   Otherwise, returns an error handle.
 */
DART_EXPORT Dart_Handle Dart_TypedDataAcquireData(Dart_Handle object,
                                                  Dart_TypedData_Type* type,
                                                  void** data,
                                                  intptr_t* len);

/**
 * Releases access to the internal data address that was acquired earlier using
 * Dart_TypedDataAcquireData.
 *
 * \param object The typed data object whose internal data address is to be
 *   released.
 *
 * \return Success if the internal data address is released successfully.
 *   Otherwise, returns an error handle.
 */
DART_EXPORT Dart_Handle Dart_TypedDataReleaseData(Dart_Handle array);


// --- Closures ---

/**
 * Is this object a Closure?
 */
DART_EXPORT bool Dart_IsClosure(Dart_Handle object);

/**
 * Retrieves the function of a closure.
 *
 * \return A handle to the function of the closure, or an error handle if the
 *   argument is not a closure.
 */
DART_EXPORT Dart_Handle Dart_ClosureFunction(Dart_Handle closure);

/**
 * Invokes a Closure with the given arguments.
 *
 * May generate an unhandled exception error.
 *
 * \return If no error occurs during execution, then the result of
 *   invoking the closure is returned. If an error occurs during
 *   execution, then an error handle is returned.
 */
DART_EXPORT Dart_Handle Dart_InvokeClosure(Dart_Handle closure,
                                           int number_of_arguments,
                                           Dart_Handle* arguments);

// --- Classes and Interfaces ---

/**
 * Is this a class handle?
 */
DART_EXPORT bool Dart_IsClass(Dart_Handle handle);

/**
 * Is this an abstract class handle?
 */
DART_EXPORT bool Dart_IsAbstractClass(Dart_Handle handle);

/**
 * Returns the class name for the provided class or interface.
 */
DART_EXPORT Dart_Handle Dart_ClassName(Dart_Handle clazz);

/**
 * Returns the library for the provided class or interface.
 */
DART_EXPORT Dart_Handle Dart_ClassGetLibrary(Dart_Handle clazz);

/**
 * Returns the number of interfaces directly implemented by some class
 * or interface.
 *
 * TODO(turnidge): Finish documentation.
 */
DART_EXPORT Dart_Handle Dart_ClassGetInterfaceCount(Dart_Handle clazz,
                                                    intptr_t* count);

/**
 * Returns the interface at some index in the list of interfaces some
 * class or inteface.
 *
 * TODO(turnidge): Finish documentation.
 */
DART_EXPORT Dart_Handle Dart_ClassGetInterfaceAt(Dart_Handle clazz,
                                                 intptr_t index);

/**
 * Is this class defined by a typedef?
 *
 * Typedef definitions from the main program are represented as a
 * special kind of class handle.  See Dart_ClassGetTypedefReferent.
 *
 * TODO(turnidge): Finish documentation.
 */
DART_EXPORT bool Dart_ClassIsTypedef(Dart_Handle clazz);

/**
 * Returns a handle to the type to which a typedef refers.
 *
 * It is an error to call this function on a handle for which
 * Dart_ClassIsTypedef is not true.
 *
 * TODO(turnidge): Finish documentation.
 */
DART_EXPORT Dart_Handle Dart_ClassGetTypedefReferent(Dart_Handle clazz);

/**
 * Does this class represent the type of a function?
 */
DART_EXPORT bool Dart_ClassIsFunctionType(Dart_Handle clazz);

/**
 * Returns a function handle representing the signature associated
 * with a function type.
 *
 * The return value is a function handle (See Dart_IsFunction, etc.).
 *
 * TODO(turnidge): Finish documentation.
 */
DART_EXPORT Dart_Handle Dart_ClassGetFunctionTypeSignature(Dart_Handle clazz);

// --- Function and Variable Declarations ---

/**
 * Returns a list of the names of all functions or methods declared in
 * a library or class.
 *
 * \param target A library or class.
 *
 * \return If no error occurs, a list of strings is returned.
 *   Otherwise an error handle is returned.
 */
DART_EXPORT Dart_Handle Dart_GetFunctionNames(Dart_Handle target);

/**
 * Looks up a function or method declaration by name from a library or
 * class.
 *
 * \param target The library or class containing the function.
 * \param function_name The name of the function.
 *
 * \return If an error is encountered, returns an error handle.
 *   Otherwise returns a function handle if the function is found of
 *   Dart_Null() if the function is not found.
 */
DART_EXPORT Dart_Handle Dart_LookupFunction(Dart_Handle target,
                                            Dart_Handle function_name);

/**
 * Is this a function or method declaration handle?
 */
DART_EXPORT bool Dart_IsFunction(Dart_Handle handle);

/**
 * Returns the name for the provided function or method.
 *
 * \return A valid string handle if no error occurs during the
 *   operation.
 */
DART_EXPORT Dart_Handle Dart_FunctionName(Dart_Handle function);

/**
 * Returns a handle to the owner of a function.
 *
 * The owner of an instance method or a static method is its defining
 * class. The owner of a top-level function is its defining
 * library. The owner of the function of a non-implicit closure is the
 * function of the method or closure that defines the non-implicit
 * closure.
 *
 * \return A valid handle to the owner of the function, or an error
 *   handle if the argument is not a valid handle to a function.
 */
DART_EXPORT Dart_Handle Dart_FunctionOwner(Dart_Handle function);

/**
 * Determines whether a function handle refers to an abstract method.
 *
 * \param function A handle to a function or method declaration.
 * \param is_static Returns whether the handle refers to an abstract method.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_FunctionIsAbstract(Dart_Handle function,
                                                bool* is_abstract);

/**
 * Determines whether a function handle referes to a static function
 * of method.
 *
 * For the purposes of the embedding API, a top-level function is
 * implicitly declared static.
 *
 * \param function A handle to a function or method declaration.
 * \param is_static Returns whether the function or method is declared static.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_FunctionIsStatic(Dart_Handle function,
                                              bool* is_static);

/**
 * Determines whether a function handle referes to a constructor.
 *
 * \param function A handle to a function or method declaration.
 * \param is_static Returns whether the function or method is a constructor.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_FunctionIsConstructor(Dart_Handle function,
                                                   bool* is_constructor);
// TODO(turnidge): Document behavior for factory constructors too.

/**
 * Determines whether a function or method is a getter.
 *
 * \param function A handle to a function or method declaration.
 * \param is_static Returns whether the function or method is a getter.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_FunctionIsGetter(Dart_Handle function,
                                              bool* is_getter);

/**
 * Determines whether a function or method is a setter.
 *
 * \param function A handle to a function or method declaration.
 * \param is_static Returns whether the function or method is a setter.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_FunctionIsSetter(Dart_Handle function,
                                              bool* is_setter);

/**
 * Returns the return type of a function.
 *
 * \return A valid handle to a type or an error handle if the argument
 *   is not valid.
 */
DART_EXPORT Dart_Handle Dart_FunctionReturnType(Dart_Handle function);

/**
 * Determines the number of required and optional parameters.
 *
 * \param function A handle to a function or method declaration.
 * \param fixed_param_count Returns the number of required parameters.
 * \param opt_param_count Returns the number of optional parameters.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_FunctionParameterCounts(
  Dart_Handle function,
  int64_t* fixed_param_count,
  int64_t* opt_param_count);

/**
 * Returns a handle to the type of a function parameter.
 *
 * \return A valid handle to a type or an error handle if the argument
 *   is not valid.
 */
DART_EXPORT Dart_Handle Dart_FunctionParameterType(Dart_Handle function,
                                                   int parameter_index);

/**
 * Returns a list of the names of all variables declared in a library
 * or class.
 *
 * \param target A library or class.
 *
 * \return If no error occurs, a list of strings is returned.
 *   Otherwise an error handle is returned.
 */
DART_EXPORT Dart_Handle Dart_GetVariableNames(Dart_Handle target);

/**
 * Looks up a variable declaration by name from a library or class.
 *
 * \param target The library or class containing the variable.
 * \param variable_name The name of the variable.
 *
 * \return If an error is encountered, returns an error handle.
 *   Otherwise returns a variable handle if the variable is found or
 *   Dart_Null() if the variable is not found.
 */
DART_EXPORT Dart_Handle Dart_LookupVariable(Dart_Handle target,
                                            Dart_Handle variable_name);

/**
 * Is this a variable declaration handle?
 */
DART_EXPORT bool Dart_IsVariable(Dart_Handle handle);

/**
 * Returns the name for the provided variable.
 */
DART_EXPORT Dart_Handle Dart_VariableName(Dart_Handle variable);

/**
 * Determines whether a variable is declared static.
 *
 * For the purposes of the embedding API, a top-level variable is
 * implicitly declared static.
 *
 * \param variable A handle to a variable declaration.
 * \param is_static Returns whether the variable is declared static.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_VariableIsStatic(Dart_Handle variable,
                                              bool* is_static);

/**
 * Determines whether a variable is declared final.
 *
 * \param variable A handle to a variable declaration.
 * \param is_final Returns whether the variable is declared final.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_VariableIsFinal(Dart_Handle variable,
                                             bool* is_final);

/**
 * Returns the type of a variable.
 *
 * \return A valid handle to a type of or an error handle if the
 *   argument is not valid.
 */
DART_EXPORT Dart_Handle Dart_VariableType(Dart_Handle function);

/**
 * Returns a list of the names of all type variables declared in a class.
 *
 * The type variables list preserves the original declaration order.
 *
 * \param clazz A class.
 *
 * \return If no error occurs, a list of strings is returned.
 *   Otherwise an error handle is returned.
 */
DART_EXPORT Dart_Handle Dart_GetTypeVariableNames(Dart_Handle clazz);

/**
 * Looks up a type variable declaration by name from a class.
 *
 * \param clazz The class containing the type variable.
 * \param variable_name The name of the type variable.
 *
 * \return If an error is encountered, returns an error handle.
 *   Otherwise returns a type variable handle if the type variable is
 *   found or Dart_Null() if the type variable is not found.
 */
DART_EXPORT Dart_Handle Dart_LookupTypeVariable(Dart_Handle clazz,
                                                Dart_Handle type_variable_name);

/**
 * Is this a type variable handle?
 */
DART_EXPORT bool Dart_IsTypeVariable(Dart_Handle handle);

/**
 * Returns the name for the provided type variable.
 */
DART_EXPORT Dart_Handle Dart_TypeVariableName(Dart_Handle type_variable);

/**
 * Returns the owner of a function.
 *
 * The owner of a type variable is its defining class.
 *
 * \return A valid handle to the owner of the type variable, or an error
 *   handle if the argument is not a valid handle to a type variable.
 */
DART_EXPORT Dart_Handle Dart_TypeVariableOwner(Dart_Handle type_variable);

/**
 * Returns the upper bound of a type variable.
 *
 * The upper bound of a type variable is ...
 *
 * \return A valid handle to a type, or an error handle if the
 *   argument is not a valid handle.
 */
DART_EXPORT Dart_Handle Dart_TypeVariableUpperBound(Dart_Handle type_variable);
// TODO(turnidge): Finish documentation.

// --- Constructors, Methods, and Fields ---

/**
 * Invokes a constructor, creating a new object.
 *
 * This function allows hidden constructors (constructors with leading
 * underscores) to be called.
 *
 * \param clazz A class or an interface.
 * \param constructor_name The name of the constructor to invoke.  Use
 *   Dart_Null() to invoke the unnamed constructor.  This name should
 *   not include the name of the class.
 * \param number_of_arguments Size of the arguments array.
 * \param arguments An array of arguments to the constructor.
 *
 * \return If the constructor is called and completes successfully,
 *   then the new object. If an error occurs during execution, then an
 *   error handle is returned.
 */
DART_EXPORT Dart_Handle Dart_New(Dart_Handle clazz,
                                 Dart_Handle constructor_name,
                                 int number_of_arguments,
                                 Dart_Handle* arguments);

/**
 * Invokes a method or function.
 *
 * The 'target' parameter may be an object, class, or library.  If
 * 'target' is an object, then this function will invoke an instance
 * method.  If 'target' is a class, then this function will invoke a
 * static method.  If 'target' is a library, then this function will
 * invoke a top-level function from that library.
 *
 * This function ignores visibility (leading underscores in names).
 *
 * May generate an unhandled exception error.
 *
 * \param target An object, class, or library.
 * \param name The name of the function or method to invoke.
 * \param number_of_arguments Size of the arguments array.
 * \param arguments An array of arguments to the function.
 *
 * \return If the function or method is called and completes
 *   successfully, then the return value is returned. If an error
 *   occurs during execution, then an error handle is returned.
 */
DART_EXPORT Dart_Handle Dart_Invoke(Dart_Handle target,
                                    Dart_Handle name,
                                    int number_of_arguments,
                                    Dart_Handle* arguments);
// TODO(turnidge): Document how to invoke operators.

/**
 * Gets the value of a field.
 *
 * The 'container' parameter may be an object, class, or library.  If
 * 'container' is an object, then this function will access an
 * instance field.  If 'container' is a class, then this function will
 * access a static field.  If 'container' is a library, then this
 * function will access a top-level variable.
 *
 * This function ignores field visibility (leading underscores in names).
 *
 * May generate an unhandled exception error.
 *
 * \param container An object, class, or library.
 * \param name A field name.
 *
 * \return If no error occurs, then the value of the field is
 *   returned. Otherwise an error handle is returned.
 */
DART_EXPORT Dart_Handle Dart_GetField(Dart_Handle container,
                                      Dart_Handle name);

/**
 * Sets the value of a field.
 *
 * The 'container' parameter may actually be an object, class, or
 * library.  If 'container' is an object, then this function will
 * access an instance field.  If 'container' is a class, then this
 * function will access a static field.  If 'container' is a library,
 * then this function will access a top-level variable.
 *
 * This function ignores field visibility (leading underscores in names).
 *
 * May generate an unhandled exception error.
 *
 * \param container An object, class, or library.
 * \param name A field name.
 * \param value The new field value.
 *
 * \return A valid handle if no error occurs.
 */
DART_EXPORT Dart_Handle Dart_SetField(Dart_Handle container,
                                      Dart_Handle name,
                                      Dart_Handle value);

/**
 * Creates a native wrapper class.
 *
 * TODO(turnidge): Document.
 */
DART_EXPORT Dart_Handle Dart_CreateNativeWrapperClass(Dart_Handle library,
                                                      Dart_Handle class_name,
                                                      int field_count);

/**
 * Gets the number of native instance fields in an object.
 */
DART_EXPORT Dart_Handle Dart_GetNativeInstanceFieldCount(Dart_Handle obj,
                                                         int* count);

/**
 * Gets the value of a native field.
 *
 * TODO(turnidge): Document.
 */
DART_EXPORT Dart_Handle Dart_GetNativeInstanceField(Dart_Handle obj,
                                                    int index,
                                                    intptr_t* value);
/**
 * Sets the value of a native field.
 *
 * TODO(turnidge): Document.
 */
DART_EXPORT Dart_Handle Dart_SetNativeInstanceField(Dart_Handle obj,
                                                    int index,
                                                    intptr_t value);

// --- Exceptions ----
// TODO(turnidge): Remove these functions from the api and replace all
// uses with Dart_NewUnhandledExceptionError.

/**
 * Throws an exception.
 *
 * This function causes a Dart language exception to be thrown. This
 * will proceeed in the standard way, walking up Dart frames until an
 * appropriate 'catch' block is found, executing 'finally' blocks,
 * etc.
 *
 * If successful, this function does not return. Note that this means
 * that the destructors of any stack-allocated C++ objects will not be
 * called. If there are no Dart frames on the stack, an error occurs.
 *
 * \return An error handle if the exception was not thrown.
 *   Otherwise the function does not return.
 */
DART_EXPORT Dart_Handle Dart_ThrowException(Dart_Handle exception);

/**
 * Rethrows an exception.
 *
 * Rethrows an exception, unwinding all dart frames on the stack. If
 * successful, this function does not return. Note that this means
 * that the destructors of any stack-allocated C++ objects will not be
 * called. If there are no Dart frames on the stack, an error occurs.
 *
 * \return An error handle if the exception was not thrown.
 *   Otherwise the function does not return.
 */
DART_EXPORT Dart_Handle Dart_RethrowException(Dart_Handle exception,
                                              Dart_Handle stacktrace);

// --- Native functions ---

/**
 * The arguments to a native function.
 *
 * This object is passed to a native function to represent its
 * arguments and return value. It allows access to the arguments to a
 * native function by index. It also allows the return value of a
 * native function to be set.
 */
typedef struct _Dart_NativeArguments* Dart_NativeArguments;

/**
 * Gets the native argument at some index.
 */
DART_EXPORT Dart_Handle Dart_GetNativeArgument(Dart_NativeArguments args,
                                               int index);
// TODO(turnidge): Specify the behavior of an out-of-bounds access.

/**
 * Gets the number of native arguments.
 */
DART_EXPORT int Dart_GetNativeArgumentCount(Dart_NativeArguments args);

/**
 * Sets the return value for a native function.
 */
DART_EXPORT void Dart_SetReturnValue(Dart_NativeArguments args,
                                     Dart_Handle retval);

/**
 * A native function.
 */
typedef void (*Dart_NativeFunction)(Dart_NativeArguments arguments);

/**
 * Native entry resolution callback.
 *
 * For libraries and scripts which have native functions, the embedder
 * can provide a native entry resolver. This callback is used to map a
 * name/arity to a Dart_NativeFunction. If no function is found, the
 * callback should return NULL.
 *
 * See Dart_SetNativeResolver.
 */
typedef Dart_NativeFunction (*Dart_NativeEntryResolver)(Dart_Handle name,
                                                        int num_of_arguments);
// TODO(turnidge): Consider renaming to NativeFunctionResolver or
// NativeResolver.

// --- Scripts and Libraries ---
// TODO(turnidge): Finish documenting this section.

typedef enum {
  kLibraryTag = 0,
  kImportTag,
  kSourceTag,
  kCanonicalizeUrl
} Dart_LibraryTag;

// TODO(turnidge): Document.
typedef Dart_Handle (*Dart_LibraryTagHandler)(Dart_LibraryTag tag,
                                              Dart_Handle library,
                                              Dart_Handle url);

/**
 * Sets library tag handler for the current isolate. This handler is
 * used to handle the various tags encountered while loading libraries
 * or scripts in the isolate.
 *
 * \param handler Handler code to be used for handling the various tags
 *   encountered while loading libraries or scripts in the isolate.
 *
 * \return If no error occurs, the handler is set for the isolate.
 *   Otherwise an error handle is returned.
 *
 * TODO(turnidge): Document.
 */
DART_EXPORT Dart_Handle Dart_SetLibraryTagHandler(
    Dart_LibraryTagHandler handler);

/**
 * Loads the root script for the current isolate. The script can be
 * embedded in another file, for example in an html file.
 *
 * TODO(turnidge): Document.
 *
 * \line_offset is the number of text lines before the
 *   first line of the Dart script in the containing file.
 *
 * \col_offset is the number of characters before the first character
 *   in the first line of the Dart script.
 */
DART_EXPORT Dart_Handle Dart_LoadScript(Dart_Handle url,
                                        Dart_Handle source,
                                        intptr_t line_offset,
                                        intptr_t col_offset);

/**
 * Loads the root script for current isolate from a snapshot.
 *
 * \param buffer A buffer which contains a snapshot of the script.
 * \param length Length of the passed in buffer.
 *
 * \return If no error occurs, the Library object corresponding to the root
 *   script is returned. Otherwise an error handle is returned.
 */
DART_EXPORT Dart_Handle Dart_LoadScriptFromSnapshot(const uint8_t* buffer,
                                                    intptr_t buffer_len);

/**
 * Gets the library for the root script for the current isolate.
 *
 * If the root script has not yet been set for the current isolate,
 * this function returns Dart_Null().  This function never returns an
 * error handle.
 *
 * \return Returns the root Library for the current isolate or Dart_Null().
 */
DART_EXPORT Dart_Handle Dart_RootLibrary();

/**
 * Forces all loaded classes and functions to be compiled eagerly in
 * the current isolate..
 *
 * TODO(turnidge): Document.
 */
DART_EXPORT Dart_Handle Dart_CompileAll();

/**
 * Check that all function fingerprints are OK.
 *
 */
DART_EXPORT Dart_Handle Dart_CheckFunctionFingerprints();

/**
 * Is this object a Library?
 */
DART_EXPORT bool Dart_IsLibrary(Dart_Handle object);

/**
 * Lookup a class or interface by name from a Library.
 *
 * \param library The library containing the class or interface.
 * \param class_name The name of the class or interface.
 *
 * \return If no error occurs, the class or interface is
 *   returned. Otherwise an error handle is returned.
 */
DART_EXPORT Dart_Handle Dart_GetClass(Dart_Handle library,
                                      Dart_Handle class_name);
// TODO(turnidge): Consider returning Dart_Null() when the class is
// not found to distinguish that from a true error case.

/**
 * Returns the name of a library as declared in the #library directive.
 */
DART_EXPORT Dart_Handle Dart_LibraryName(Dart_Handle library);

/**
 * Returns the url from which a library was loaded.
 */
DART_EXPORT Dart_Handle Dart_LibraryUrl(Dart_Handle library);

/**
 * Returns a list of the names of all classes and interfaces declared
 * in a library.
 *
 * \return If no error occurs, a list of strings is returned.
 *   Otherwise an error handle is returned.
 */
DART_EXPORT Dart_Handle Dart_LibraryGetClassNames(Dart_Handle library);

DART_EXPORT Dart_Handle Dart_LookupLibrary(Dart_Handle url);
// TODO(turnidge): Consider returning Dart_Null() when the library is
// not found to distinguish that from a true error case.

DART_EXPORT Dart_Handle Dart_LoadLibrary(Dart_Handle url,
                                         Dart_Handle source);

/**
 * Imports a library into another library, optionally with a prefix.
 * If no prefix is required, an empty string or Dart_Null() can be
 * supplied.
 *
 * \param library The library into which to import another library.
 * \param import The library to import.
 * \param prefix The prefix under which to import.
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_LibraryImportLibrary(Dart_Handle library,
                                                  Dart_Handle import,
                                                  Dart_Handle prefix);

/**
 * Loads a source string into a library.
 *
 * \param library A library
 * \param url A url identifying the origin of the source
 * \param source A string of Dart source
 *
 * \return A valid handle if no error occurs during the operation.
 */
DART_EXPORT Dart_Handle Dart_LoadSource(Dart_Handle library,
                                        Dart_Handle url,
                                        Dart_Handle source);
// TODO(turnidge): Rename to Dart_LibraryLoadSource?


/**
 * Loads a patch source string into a library.
 *
 * \param library A library
 * \param url A url identifying the origin of the patch source
 * \param source A string of Dart patch source
 */
DART_EXPORT Dart_Handle Dart_LoadPatch(Dart_Handle library,
                                       Dart_Handle url,
                                       Dart_Handle patch_source);

/**
 * Sets the callback used to resolve native functions for a library.
 *
 * \param library A library.
 * \param resolver A native entry resolver.
 *
 * \return A valid handle if the native resolver was set successfully.
 */
DART_EXPORT Dart_Handle Dart_SetNativeResolver(
    Dart_Handle library,
    Dart_NativeEntryResolver resolver);
// TODO(turnidge): Rename to Dart_LibrarySetNativeResolver?

// --- Profiling support ----

// External pprof support for gathering and dumping symbolic
// information that can be used for better profile reports for
// dynamically generated code.
DART_EXPORT void Dart_InitPprofSupport();
DART_EXPORT void Dart_GetPprofSymbolInfo(void** buffer, int* buffer_size);

// Support for generating symbol maps for use by the Linux perf tool.
DART_EXPORT void Dart_InitPerfEventsSupport(void* perf_events_file);

// --- Heap Profiler ---

/**
 * Generates a heap profile.
 *
 * \param callback A function pointer that will be repeatedly invoked
 *   with heap profile data.
 * \param stream A pointer that will be passed to the callback.  This
 *   is a convenient way to provide an open stream to the callback.
 *
 * \return Success if the heap profile is successful.
 */
DART_EXPORT Dart_Handle Dart_HeapProfile(Dart_FileWriteCallback callback,
                                         void* stream);

// --- Peers ---

/**
 * The peer field is a lazily allocated field intendend for storage of
 * an uncommonly used values.  Most instances types can have a peer
 * field allocated.  The exceptions are subtypes of Null, num, and
 * bool.
 */

/**
 * Returns the value of peer field of 'object' in 'peer'.
 *
 * \param object An object.
 * \param peer An out parameter that returns the value of the peer
 *   field.
 *
 * \return Returns an error if 'object' is a subtype of Null, num, or
 *   bool.
 */
DART_EXPORT Dart_Handle Dart_GetPeer(Dart_Handle object, void** peer);

/**
 * Sets the value of the peer field of 'object' to the value of
 * 'peer'.
 *
 * \param object An object.
 * \param peer A value to store in the peer field.
 *
 * \return Returns an error if 'object' is a subtype of Null, num, or
 *   bool.
 */
DART_EXPORT Dart_Handle Dart_SetPeer(Dart_Handle object, void* peer);

#endif  // INCLUDE_DART_API_H_
