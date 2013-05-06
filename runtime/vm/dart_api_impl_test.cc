// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "include/dart_api.h"
#include "platform/assert.h"
#include "platform/json.h"
#include "platform/utils.h"
#include "vm/class_finalizer.h"
#include "vm/dart_api_impl.h"
#include "vm/dart_api_state.h"
#include "vm/thread.h"
#include "vm/unit_test.h"
#include "vm/verifier.h"

namespace dart {

DECLARE_FLAG(bool, enable_type_checks);

TEST_CASE(ErrorHandleBasics) {
  const char* kScriptChars =
      "void testMain() {\n"
      "  throw new Exception(\"bad news\");\n"
      "}\n";

  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);

  Dart_Handle instance = Dart_True();
  Dart_Handle error = Api::NewError("myerror");
  Dart_Handle exception = Dart_Invoke(lib,
                                      NewString("testMain"),
                                      0,
                                      NULL);

  EXPECT_VALID(instance);
  EXPECT(Dart_IsError(error));
  EXPECT(Dart_IsError(exception));

  EXPECT(!Dart_ErrorHasException(instance));
  EXPECT(!Dart_ErrorHasException(error));
  EXPECT(Dart_ErrorHasException(exception));

  EXPECT_STREQ("", Dart_GetError(instance));
  EXPECT_STREQ("myerror", Dart_GetError(error));
  EXPECT_STREQ(
      "Unhandled exception:\n"
      "Exception: bad news\n"
      "#0      testMain (dart:test-lib:2:3)",
      Dart_GetError(exception));

  EXPECT(Dart_IsError(Dart_ErrorGetException(instance)));
  EXPECT(Dart_IsError(Dart_ErrorGetException(error)));
  EXPECT_VALID(Dart_ErrorGetException(exception));

  EXPECT(Dart_IsError(Dart_ErrorGetStacktrace(instance)));
  EXPECT(Dart_IsError(Dart_ErrorGetStacktrace(error)));
  EXPECT_VALID(Dart_ErrorGetStacktrace(exception));
}


TEST_CASE(ErrorHandleTypes) {
  Isolate* isolate = Isolate::Current();
  const String& compile_message = String::Handle(String::New("CompileError"));
  const String& fatal_message = String::Handle(String::New("FatalError"));

  Dart_Handle not_error = NewString("NotError");
  Dart_Handle api_error = Dart_NewApiError("Api%s", "Error");
  Dart_Handle exception_error =
      Dart_NewUnhandledExceptionError(NewString("ExceptionError"));
  Dart_Handle compile_error =
      Api::NewHandle(isolate, LanguageError::New(compile_message));
  Dart_Handle fatal_error =
      Api::NewHandle(isolate, UnwindError::New(fatal_message));

  EXPECT_VALID(not_error);
  EXPECT(Dart_IsError(api_error));
  EXPECT(Dart_IsError(exception_error));
  EXPECT(Dart_IsError(compile_error));
  EXPECT(Dart_IsError(fatal_error));

  EXPECT(!Dart_IsApiError(not_error));
  EXPECT(Dart_IsApiError(api_error));
  EXPECT(!Dart_IsApiError(exception_error));
  EXPECT(!Dart_IsApiError(compile_error));
  EXPECT(!Dart_IsApiError(fatal_error));

  EXPECT(!Dart_IsUnhandledExceptionError(not_error));
  EXPECT(!Dart_IsUnhandledExceptionError(api_error));
  EXPECT(Dart_IsUnhandledExceptionError(exception_error));
  EXPECT(!Dart_IsUnhandledExceptionError(compile_error));
  EXPECT(!Dart_IsUnhandledExceptionError(fatal_error));

  EXPECT(!Dart_IsCompilationError(not_error));
  EXPECT(!Dart_IsCompilationError(api_error));
  EXPECT(!Dart_IsCompilationError(exception_error));
  EXPECT(Dart_IsCompilationError(compile_error));
  EXPECT(!Dart_IsCompilationError(fatal_error));

  EXPECT(!Dart_IsFatalError(not_error));
  EXPECT(!Dart_IsFatalError(api_error));
  EXPECT(!Dart_IsFatalError(exception_error));
  EXPECT(!Dart_IsFatalError(compile_error));
  EXPECT(Dart_IsFatalError(fatal_error));

  EXPECT_STREQ("", Dart_GetError(not_error));
  EXPECT_STREQ("ApiError", Dart_GetError(api_error));
  EXPECT_SUBSTRING("Unhandled exception:\nExceptionError",
                   Dart_GetError(exception_error));
  EXPECT_STREQ("CompileError", Dart_GetError(compile_error));
  EXPECT_STREQ("FatalError", Dart_GetError(fatal_error));
}


void PropagateErrorNative(Dart_NativeArguments args) {
  Dart_EnterScope();
  Dart_Handle closure = Dart_GetNativeArgument(args, 0);
  EXPECT(Dart_IsClosure(closure));
  Dart_Handle result = Dart_InvokeClosure(closure, 0, NULL);
  EXPECT(Dart_IsError(result));
  result = Dart_PropagateError(result);
  EXPECT_VALID(result);  // We do not expect to reach here.
  UNREACHABLE();
}


static Dart_NativeFunction PropagateError_native_lookup(
    Dart_Handle name, int argument_count) {
  return reinterpret_cast<Dart_NativeFunction>(&PropagateErrorNative);
}


TEST_CASE(Dart_PropagateError) {
  const char* kScriptChars =
      "raiseCompileError() {\n"
      "  return missing_semicolon\n"
      "}\n"
      "\n"
      "void throwException() {\n"
      "  throw new Exception('myException');\n"
      "}\n"
      "\n"
      "void nativeFunc(closure) native 'Test_nativeFunc';\n"
      "\n"
      "void Func1() {\n"
      "  nativeFunc(() => raiseCompileError());\n"
      "}\n"
      "\n"
      "void Func2() {\n"
      "  nativeFunc(() => throwException());\n"
      "}\n";
  Dart_Handle lib = TestCase::LoadTestScript(
      kScriptChars, &PropagateError_native_lookup);
  Dart_Handle result;

  result = Dart_Invoke(lib, NewString("Func1"), 0, NULL);
  EXPECT(Dart_IsError(result));
  EXPECT(!Dart_ErrorHasException(result));
  EXPECT_SUBSTRING("semicolon expected", Dart_GetError(result));

  result = Dart_Invoke(lib, NewString("Func2"), 0, NULL);
  EXPECT(Dart_IsError(result));
  EXPECT(Dart_ErrorHasException(result));
  EXPECT_SUBSTRING("myException", Dart_GetError(result));
}


TEST_CASE(Dart_Error) {
  Dart_Handle error = Dart_Error("An %s", "error");
  EXPECT(Dart_IsError(error));
  EXPECT_STREQ("An error", Dart_GetError(error));
}


TEST_CASE(Null) {
  Dart_Handle null = Dart_Null();
  EXPECT_VALID(null);
  EXPECT(Dart_IsNull(null));

  Dart_Handle str = NewString("test");
  EXPECT_VALID(str);
  EXPECT(!Dart_IsNull(str));
}


TEST_CASE(IdentityEquals) {
  Dart_Handle five = NewString("5");
  Dart_Handle five_again = NewString("5");
  Dart_Handle seven = NewString("7");

  // Same objects.
  EXPECT(Dart_IdentityEquals(five, five));

  // Equal objects.
  EXPECT(!Dart_IdentityEquals(five, five_again));

  // Different objects.
  EXPECT(!Dart_IdentityEquals(five, seven));

  // Non-instance objects.
  {
    Isolate* isolate = Isolate::Current();
    DARTSCOPE(isolate);
    Dart_Handle class1 = Api::NewHandle(isolate, Object::null_class());
    Dart_Handle class2 = Api::NewHandle(isolate, Object::class_class());

    EXPECT(Dart_IdentityEquals(class1, class1));

    EXPECT(!Dart_IdentityEquals(class1, class2));
  }
}


TEST_CASE(ObjectEquals) {
  bool equal = false;
  Dart_Handle five = NewString("5");
  Dart_Handle five_again = NewString("5");
  Dart_Handle seven = NewString("7");

  // Same objects.
  EXPECT_VALID(Dart_ObjectEquals(five, five, &equal));
  EXPECT(equal);

  // Equal objects.
  EXPECT_VALID(Dart_ObjectEquals(five, five_again, &equal));
  EXPECT(equal);

  // Different objects.
  EXPECT_VALID(Dart_ObjectEquals(five, seven, &equal));
  EXPECT(!equal);
}


TEST_CASE(InstanceValues) {
  EXPECT(Dart_IsInstance(NewString("test")));
  EXPECT(Dart_IsInstance(Dart_True()));

  // By convention, our Is*() functions exclude null.
  EXPECT(!Dart_IsInstance(Dart_Null()));
}


TEST_CASE(InstanceGetClass) {
  // Get the handle from a valid instance handle.
  Dart_Handle instance = Dart_True();
  Dart_Handle cls = Dart_InstanceGetClass(instance);
  EXPECT_VALID(cls);
  EXPECT(Dart_IsClass(cls));
  Dart_Handle cls_name = Dart_ClassName(cls);
  EXPECT_VALID(cls_name);
  const char* cls_name_cstr = "";
  EXPECT_VALID(Dart_StringToCString(cls_name, &cls_name_cstr));
  EXPECT_STREQ("bool", cls_name_cstr);

  // Errors propagate.
  Dart_Handle error = Dart_NewApiError("MyError");
  Dart_Handle error_cls = Dart_InstanceGetClass(error);
  EXPECT_ERROR(error_cls, "MyError");

  // Get the handle from a non-instance handle
  ASSERT(Dart_IsClass(cls));
  Dart_Handle cls_cls = Dart_InstanceGetClass(cls);
  EXPECT_ERROR(cls_cls,
               "Dart_InstanceGetClass expects argument 'instance' to be of "
               "type Instance.");
}


TEST_CASE(BooleanValues) {
  Dart_Handle str = NewString("test");
  EXPECT(!Dart_IsBoolean(str));

  bool value = false;
  Dart_Handle result = Dart_BooleanValue(str, &value);
  EXPECT(Dart_IsError(result));

  Dart_Handle val1 = Dart_NewBoolean(true);
  EXPECT(Dart_IsBoolean(val1));

  result = Dart_BooleanValue(val1, &value);
  EXPECT_VALID(result);
  EXPECT(value);

  Dart_Handle val2 = Dart_NewBoolean(false);
  EXPECT(Dart_IsBoolean(val2));

  result = Dart_BooleanValue(val2, &value);
  EXPECT_VALID(result);
  EXPECT(!value);
}


TEST_CASE(BooleanConstants) {
  Dart_Handle true_handle = Dart_True();
  EXPECT_VALID(true_handle);
  EXPECT(Dart_IsBoolean(true_handle));

  bool value = false;
  Dart_Handle result = Dart_BooleanValue(true_handle, &value);
  EXPECT_VALID(result);
  EXPECT(value);

  Dart_Handle false_handle = Dart_False();
  EXPECT_VALID(false_handle);
  EXPECT(Dart_IsBoolean(false_handle));

  result = Dart_BooleanValue(false_handle, &value);
  EXPECT_VALID(result);
  EXPECT(!value);
}


TEST_CASE(DoubleValues) {
  const double kDoubleVal1 = 201.29;
  const double kDoubleVal2 = 101.19;
  Dart_Handle val1 = Dart_NewDouble(kDoubleVal1);
  EXPECT(Dart_IsDouble(val1));
  Dart_Handle val2 = Dart_NewDouble(kDoubleVal2);
  EXPECT(Dart_IsDouble(val2));
  double out1, out2;
  Dart_Handle result = Dart_DoubleValue(val1, &out1);
  EXPECT_VALID(result);
  EXPECT_EQ(kDoubleVal1, out1);
  result = Dart_DoubleValue(val2, &out2);
  EXPECT_VALID(result);
  EXPECT_EQ(kDoubleVal2, out2);
}


TEST_CASE(NumberValues) {
  // TODO(antonm): add various kinds of ints (smi, mint, bigint).
  const char* kScriptChars =
      "int getInt() { return 1; }\n"
      "double getDouble() { return 1.0; }\n"
      "bool getBool() { return false; }\n"
      "getNull() { return null; }\n";
  Dart_Handle result;
  // Create a test library and Load up a test script in it.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);

  // Check int case.
  result = Dart_Invoke(lib, NewString("getInt"), 0, NULL);
  EXPECT_VALID(result);
  EXPECT(Dart_IsNumber(result));

  // Check double case.
  result = Dart_Invoke(lib, NewString("getDouble"), 0, NULL);
  EXPECT_VALID(result);
  EXPECT(Dart_IsNumber(result));

  // Check bool case.
  result = Dart_Invoke(lib, NewString("getBool"), 0, NULL);
  EXPECT_VALID(result);
  EXPECT(!Dart_IsNumber(result));

  // Check null case.
  result = Dart_Invoke(lib, NewString("getNull"), 0, NULL);
  EXPECT_VALID(result);
  EXPECT(!Dart_IsNumber(result));
}


TEST_CASE(IntegerValues) {
  const int64_t kIntegerVal1 = 100;
  const int64_t kIntegerVal2 = 0xffffffff;
  const char* kIntegerVal3 = "0x123456789123456789123456789";

  Dart_Handle val1 = Dart_NewInteger(kIntegerVal1);
  EXPECT(Dart_IsInteger(val1));
  bool fits = false;
  Dart_Handle result = Dart_IntegerFitsIntoInt64(val1, &fits);
  EXPECT_VALID(result);
  EXPECT(fits);

  Dart_Handle val2 = Dart_NewInteger(kIntegerVal2);
  EXPECT(Dart_IsInteger(val2));
  result = Dart_IntegerFitsIntoInt64(val2, &fits);
  EXPECT_VALID(result);
  EXPECT(fits);

  Dart_Handle val3 = Dart_NewIntegerFromHexCString(kIntegerVal3);
  EXPECT(Dart_IsInteger(val3));
  result = Dart_IntegerFitsIntoInt64(val3, &fits);
  EXPECT_VALID(result);
  EXPECT(!fits);

  int64_t out = 0;
  result = Dart_IntegerToInt64(val1, &out);
  EXPECT_VALID(result);
  EXPECT_EQ(kIntegerVal1, out);

  result = Dart_IntegerToInt64(val2, &out);
  EXPECT_VALID(result);
  EXPECT_EQ(kIntegerVal2, out);

  const char* chars = NULL;
  result = Dart_IntegerToHexCString(val3, &chars);
  EXPECT_VALID(result);
  EXPECT(!strcmp(kIntegerVal3, chars));
}


TEST_CASE(IntegerFitsIntoInt64) {
  Dart_Handle max = Dart_NewInteger(kMaxInt64);
  EXPECT(Dart_IsInteger(max));
  bool fits = false;
  Dart_Handle result = Dart_IntegerFitsIntoInt64(max, &fits);
  EXPECT_VALID(result);
  EXPECT(fits);

  Dart_Handle above_max = Dart_NewIntegerFromHexCString("0x8000000000000000");
  EXPECT(Dart_IsInteger(above_max));
  fits = true;
  result = Dart_IntegerFitsIntoInt64(above_max, &fits);
  EXPECT_VALID(result);
  EXPECT(!fits);

  Dart_Handle min = Dart_NewInteger(kMaxInt64);
  EXPECT(Dart_IsInteger(min));
  fits = false;
  result = Dart_IntegerFitsIntoInt64(min, &fits);
  EXPECT_VALID(result);
  EXPECT(fits);

  Dart_Handle below_min = Dart_NewIntegerFromHexCString("-0x8000000000000001");
  EXPECT(Dart_IsInteger(below_min));
  fits = true;
  result = Dart_IntegerFitsIntoInt64(below_min, &fits);
  EXPECT_VALID(result);
  EXPECT(!fits);
}


TEST_CASE(IntegerFitsIntoUint64) {
  Dart_Handle max = Dart_NewIntegerFromHexCString("0xFFFFFFFFFFFFFFFF");
  EXPECT(Dart_IsInteger(max));
  bool fits = false;
  Dart_Handle result = Dart_IntegerFitsIntoUint64(max, &fits);
  EXPECT_VALID(result);
  EXPECT(fits);

  Dart_Handle above_max = Dart_NewIntegerFromHexCString("0x10000000000000000");
  EXPECT(Dart_IsInteger(above_max));
  fits = true;
  result = Dart_IntegerFitsIntoUint64(above_max, &fits);
  EXPECT_VALID(result);
  EXPECT(!fits);

  Dart_Handle min = Dart_NewInteger(0);
  EXPECT(Dart_IsInteger(min));
  fits = false;
  result = Dart_IntegerFitsIntoUint64(min, &fits);
  EXPECT_VALID(result);
  EXPECT(fits);

  Dart_Handle below_min = Dart_NewIntegerFromHexCString("-1");
  EXPECT(Dart_IsInteger(below_min));
  fits = true;
  result = Dart_IntegerFitsIntoUint64(below_min, &fits);
  EXPECT_VALID(result);
  EXPECT(!fits);
}


TEST_CASE(ArrayValues) {
  const int kArrayLength = 10;
  Dart_Handle str = NewString("test");
  EXPECT(!Dart_IsList(str));
  Dart_Handle val = Dart_NewList(kArrayLength);
  EXPECT(Dart_IsList(val));
  intptr_t len = 0;
  Dart_Handle result = Dart_ListLength(val, &len);
  EXPECT_VALID(result);
  EXPECT_EQ(kArrayLength, len);

  // Check invalid array access.
  result = Dart_ListSetAt(val, (kArrayLength + 10), Dart_NewInteger(10));
  EXPECT(Dart_IsError(result));
  result = Dart_ListSetAt(val, -10, Dart_NewInteger(10));
  EXPECT(Dart_IsError(result));
  result = Dart_ListGetAt(val, (kArrayLength + 10));
  EXPECT(Dart_IsError(result));
  result = Dart_ListGetAt(val, -10);
  EXPECT(Dart_IsError(result));

  for (int i = 0; i < kArrayLength; i++) {
    result = Dart_ListSetAt(val, i, Dart_NewInteger(i));
    EXPECT_VALID(result);
  }
  for (int i = 0; i < kArrayLength; i++) {
    result = Dart_ListGetAt(val, i);
    EXPECT_VALID(result);
    int64_t value;
    result = Dart_IntegerToInt64(result, &value);
    EXPECT_VALID(result);
    EXPECT_EQ(i, value);
  }
}


TEST_CASE(IsString) {
  uint8_t latin1[] = { 'o', 'n', 'e', 0xC2, 0xA2 };

  Dart_Handle latin1str = Dart_NewStringFromUTF8(latin1, ARRAY_SIZE(latin1));
  EXPECT_VALID(latin1str);
  EXPECT(Dart_IsString(latin1str));
  EXPECT(Dart_IsStringLatin1(latin1str));
  EXPECT(!Dart_IsExternalString(latin1str));
  intptr_t len = -1;
  EXPECT_VALID(Dart_StringLength(latin1str, &len));
  EXPECT_EQ(4, len);

  uint8_t data8[] = { 'o', 'n', 'e', 0x7F };

  Dart_Handle str8 = Dart_NewStringFromUTF8(data8, ARRAY_SIZE(data8));
  EXPECT_VALID(str8);
  EXPECT(Dart_IsString(str8));
  EXPECT(Dart_IsStringLatin1(str8));
  EXPECT(!Dart_IsExternalString(str8));

  uint8_t latin1_array[] = {0, 0, 0, 0, 0};
  len = 5;
  Dart_Handle result = Dart_StringToLatin1(str8, latin1_array, &len);
  EXPECT_VALID(result);
  EXPECT_EQ(4, len);
  EXPECT(latin1_array != NULL);
  for (intptr_t i = 0; i < len; i++) {
    EXPECT_EQ(data8[i], latin1_array[i]);
  }

  Dart_Handle ext8 = Dart_NewExternalLatin1String(data8, ARRAY_SIZE(data8),
                                                  NULL, NULL);
  EXPECT_VALID(ext8);
  EXPECT(Dart_IsString(ext8));
  EXPECT(Dart_IsExternalString(ext8));

  uint16_t data16[] = { 't', 'w', 'o', 0xFFFF };

  Dart_Handle str16 = Dart_NewStringFromUTF16(data16, ARRAY_SIZE(data16));
  EXPECT_VALID(str16);
  EXPECT(Dart_IsString(str16));
  EXPECT(!Dart_IsStringLatin1(str16));
  EXPECT(!Dart_IsExternalString(str16));

  Dart_Handle ext16 = Dart_NewExternalUTF16String(data16, ARRAY_SIZE(data16),
                                                  NULL, NULL);
  EXPECT_VALID(ext16);
  EXPECT(Dart_IsString(ext16));
  EXPECT(Dart_IsExternalString(ext16));

  int32_t data32[] = { 'f', 'o', 'u', 'r', 0x10FFFF };

  Dart_Handle str32 = Dart_NewStringFromUTF32(data32, ARRAY_SIZE(data32));
  EXPECT_VALID(str32);
  EXPECT(Dart_IsString(str32));
  EXPECT(!Dart_IsExternalString(str32));
}


TEST_CASE(NewString) {
  const char* ascii = "string";
  Dart_Handle ascii_str = NewString(ascii);
  EXPECT_VALID(ascii_str);
  EXPECT(Dart_IsString(ascii_str));

  const char* null = NULL;
  Dart_Handle null_str = NewString(null);
  EXPECT(Dart_IsError(null_str));

  uint8_t data[] = { 0xE4, 0xBA, 0x8c };  // U+4E8C.
  Dart_Handle utf8_str = Dart_NewStringFromUTF8(data, ARRAY_SIZE(data));
  EXPECT_VALID(utf8_str);
  EXPECT(Dart_IsString(utf8_str));

  uint8_t invalid[] = { 0xE4, 0xBA };  // underflow.
  Dart_Handle invalid_str = Dart_NewStringFromUTF8(invalid,
                                                   ARRAY_SIZE(invalid));
  EXPECT(Dart_IsError(invalid_str));
}


TEST_CASE(ExternalStringGetPeer) {
  Dart_Handle result;

  uint8_t data8[] = { 'o', 'n', 'e', 0xFF };
  int peer_data = 123;
  void* peer = NULL;

  // Success.
  Dart_Handle ext8 = Dart_NewExternalLatin1String(data8, ARRAY_SIZE(data8),
                                                  &peer_data, NULL);
  EXPECT_VALID(ext8);

  result = Dart_ExternalStringGetPeer(ext8, &peer);
  EXPECT_VALID(result);
  EXPECT_EQ(&peer_data, peer);

  // NULL peer.
  result = Dart_ExternalStringGetPeer(ext8, NULL);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_ExternalStringGetPeer expects argument 'peer' to be "
               "non-null.", Dart_GetError(result));

  // String is not external.
  peer = NULL;
  uint8_t utf8_data8[] = { 'o', 'n', 'e', 0x7F };
  Dart_Handle str8 = Dart_NewStringFromUTF8(utf8_data8, ARRAY_SIZE(data8));
  EXPECT_VALID(str8);
  result = Dart_ExternalStringGetPeer(str8, &peer);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_ExternalStringGetPeer expects argument 'object' to be "
               "an external String.", Dart_GetError(result));
  EXPECT(peer == NULL);

  // Not a String.
  peer = NULL;
  result = Dart_ExternalStringGetPeer(Dart_True(), &peer);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_ExternalStringGetPeer expects argument 'object' to be "
               "of type String.", Dart_GetError(result));
  EXPECT(peer == NULL);
}


static void ExternalStringCallbackFinalizer(void* peer) {
  *static_cast<int*>(peer) *= 2;
}


TEST_CASE(ExternalStringCallback) {
  int peer8 = 40;
  int peer16 = 41;

  {
    Dart_EnterScope();

    uint8_t data8[] = { 'h', 'e', 'l', 'l', 'o' };
    Dart_Handle obj8 = Dart_NewExternalLatin1String(
        data8,
        ARRAY_SIZE(data8),
        &peer8,
        ExternalStringCallbackFinalizer);
    EXPECT_VALID(obj8);
    void* api_peer8 = NULL;
    EXPECT_VALID(Dart_ExternalStringGetPeer(obj8, &api_peer8));
    EXPECT_EQ(api_peer8, &peer8);

    uint16_t data16[] = { 'h', 'e', 'l', 'l', 'o' };
    Dart_Handle obj16 = Dart_NewExternalUTF16String(
        data16,
        ARRAY_SIZE(data16),
        &peer16,
        ExternalStringCallbackFinalizer);
    EXPECT_VALID(obj16);
    void* api_peer16 = NULL;
    EXPECT_VALID(Dart_ExternalStringGetPeer(obj16, &api_peer16));
    EXPECT_EQ(api_peer16, &peer16);

    Dart_ExitScope();
  }

  EXPECT_EQ(40, peer8);
  EXPECT_EQ(41, peer16);
  Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
  EXPECT_EQ(40, peer8);
  EXPECT_EQ(41, peer16);
  Isolate::Current()->heap()->CollectGarbage(Heap::kNew);
  EXPECT_EQ(80, peer8);
  EXPECT_EQ(82, peer16);
}


TEST_CASE(ListAccess) {
  const char* kScriptChars =
      "List testMain() {"
      "  List a = new List();"
      "  a.add(10);"
      "  a.add(20);"
      "  a.add(30);"
      "  return a;"
      "}"
      ""
      "List immutable() {"
      "  return const [0, 1, 2];"
      "}";
  Dart_Handle result;

  // Create a test library and Load up a test script in it.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);

  // Invoke a function which returns an object of type List.
  result = Dart_Invoke(lib, NewString("testMain"), 0, NULL);
  EXPECT_VALID(result);

  // First ensure that the returned object is an array.
  Dart_Handle list_access_test_obj = result;

  EXPECT(Dart_IsList(list_access_test_obj));

  // Get length of array object.
  intptr_t len = 0;
  result = Dart_ListLength(list_access_test_obj, &len);
  EXPECT_VALID(result);
  EXPECT_EQ(3, len);

  // Access elements in the array.
  int64_t value;

  result = Dart_ListGetAt(list_access_test_obj, 0);
  EXPECT_VALID(result);
  result = Dart_IntegerToInt64(result, &value);
  EXPECT_VALID(result);
  EXPECT_EQ(10, value);

  result = Dart_ListGetAt(list_access_test_obj, 1);
  EXPECT_VALID(result);
  result = Dart_IntegerToInt64(result, &value);
  EXPECT_VALID(result);
  EXPECT_EQ(20, value);

  result = Dart_ListGetAt(list_access_test_obj, 2);
  EXPECT_VALID(result);
  result = Dart_IntegerToInt64(result, &value);
  EXPECT_VALID(result);
  EXPECT_EQ(30, value);

  // Set some elements in the array.
  result = Dart_ListSetAt(list_access_test_obj, 0, Dart_NewInteger(0));
  EXPECT_VALID(result);
  result = Dart_ListSetAt(list_access_test_obj, 1, Dart_NewInteger(1));
  EXPECT_VALID(result);
  result = Dart_ListSetAt(list_access_test_obj, 2, Dart_NewInteger(2));
  EXPECT_VALID(result);

  // Get length of array object.
  result = Dart_ListLength(list_access_test_obj, &len);
  EXPECT_VALID(result);
  EXPECT_EQ(3, len);

  // Now try and access these elements in the array.
  result = Dart_ListGetAt(list_access_test_obj, 0);
  EXPECT_VALID(result);
  result = Dart_IntegerToInt64(result, &value);
  EXPECT_VALID(result);
  EXPECT_EQ(0, value);

  result = Dart_ListGetAt(list_access_test_obj, 1);
  EXPECT_VALID(result);
  result = Dart_IntegerToInt64(result, &value);
  EXPECT_VALID(result);
  EXPECT_EQ(1, value);

  result = Dart_ListGetAt(list_access_test_obj, 2);
  EXPECT_VALID(result);
  result = Dart_IntegerToInt64(result, &value);
  EXPECT_VALID(result);
  EXPECT_EQ(2, value);

  uint8_t native_array[3];
  result = Dart_ListGetAsBytes(list_access_test_obj, 0, native_array, 3);
  EXPECT_VALID(result);
  EXPECT_EQ(0, native_array[0]);
  EXPECT_EQ(1, native_array[1]);
  EXPECT_EQ(2, native_array[2]);

  native_array[0] = 10;
  native_array[1] = 20;
  native_array[2] = 30;
  result = Dart_ListSetAsBytes(list_access_test_obj, 0, native_array, 3);
  EXPECT_VALID(result);
  result = Dart_ListGetAsBytes(list_access_test_obj, 0, native_array, 3);
  EXPECT_VALID(result);
  EXPECT_EQ(10, native_array[0]);
  EXPECT_EQ(20, native_array[1]);
  EXPECT_EQ(30, native_array[2]);
  result = Dart_ListGetAt(list_access_test_obj, 2);
  EXPECT_VALID(result);
  result = Dart_IntegerToInt64(result, &value);
  EXPECT_VALID(result);
  EXPECT_EQ(30, value);

  // Check if we get an exception when accessing beyond limit.
  result = Dart_ListGetAt(list_access_test_obj, 4);
  EXPECT(Dart_IsError(result));

  // Check that we get an exception (and not a fatal error) when
  // calling ListSetAt and ListSetAsBytes with an immutable list.
  list_access_test_obj = Dart_Invoke(lib, NewString("immutable"), 0, NULL);
  EXPECT_VALID(list_access_test_obj);
  EXPECT(Dart_IsList(list_access_test_obj));

  result = Dart_ListSetAsBytes(list_access_test_obj, 0, native_array, 3);
  EXPECT(Dart_IsError(result));
  EXPECT(Dart_IsUnhandledExceptionError(result));

  result = Dart_ListSetAt(list_access_test_obj, 0, Dart_NewInteger(42));
  EXPECT(Dart_IsError(result));
  EXPECT(Dart_IsUnhandledExceptionError(result));
}


TEST_CASE(TypedDataAccess) {
  EXPECT_EQ(kInvalid, Dart_GetTypeOfTypedData(Dart_True()));
  EXPECT_EQ(kInvalid, Dart_GetTypeOfExternalTypedData(Dart_False()));
  Dart_Handle byte_array1 = Dart_NewTypedData(kUint8, 10);
  EXPECT_VALID(byte_array1);
  EXPECT_EQ(kUint8, Dart_GetTypeOfTypedData(byte_array1));
  EXPECT_EQ(kInvalid, Dart_GetTypeOfExternalTypedData(byte_array1));
  EXPECT(Dart_IsList(byte_array1));

  intptr_t length = 0;
  Dart_Handle result = Dart_ListLength(byte_array1, &length);
  EXPECT_VALID(result);
  EXPECT_EQ(10, length);

  result = Dart_ListSetAt(byte_array1, -1, Dart_NewInteger(1));
  EXPECT(Dart_IsError(result));

  result = Dart_ListSetAt(byte_array1, 10, Dart_NewInteger(1));
  EXPECT(Dart_IsError(result));

  // Set through the List API.
  for (intptr_t i = 0; i < 10; ++i) {
    EXPECT_VALID(Dart_ListSetAt(byte_array1, i, Dart_NewInteger(i + 1)));
  }
  for (intptr_t i = 0; i < 10; ++i) {
    // Get through the List API.
    Dart_Handle integer_obj = Dart_ListGetAt(byte_array1, i);
    EXPECT_VALID(integer_obj);
    int64_t int64_t_value = -1;
    EXPECT_VALID(Dart_IntegerToInt64(integer_obj, &int64_t_value));
    EXPECT_EQ(i + 1, int64_t_value);
  }

  Dart_Handle byte_array2 = Dart_NewTypedData(kUint8, 10);
  bool is_equal = false;
  Dart_ObjectEquals(byte_array1, byte_array2, &is_equal);
  EXPECT(!is_equal);

  // Set through the List API.
  for (intptr_t i = 0; i < 10; ++i) {
    result = Dart_ListSetAt(byte_array1, i, Dart_NewInteger(i + 2));
    EXPECT_VALID(result);
    result = Dart_ListSetAt(byte_array2, i, Dart_NewInteger(i + 2));
    EXPECT_VALID(result);
  }
  for (intptr_t i = 0; i < 10; ++i) {
    // Get through the List API.
    Dart_Handle e1 = Dart_ListGetAt(byte_array1, i);
    Dart_Handle e2 = Dart_ListGetAt(byte_array2, i);
    is_equal = false;
    Dart_ObjectEquals(e1, e2, &is_equal);
    EXPECT(is_equal);
  }

  uint8_t data[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
  for (intptr_t i = 0; i < 10; ++i) {
    EXPECT_VALID(Dart_ListSetAt(byte_array1, i, Dart_NewInteger(10 - i)));
  }
  Dart_ListGetAsBytes(byte_array1, 0, data, 10);
  for (intptr_t i = 0; i < 10; ++i) {
    Dart_Handle integer_obj = Dart_ListGetAt(byte_array1, i);
    EXPECT_VALID(integer_obj);
    int64_t int64_t_value = -1;
    EXPECT_VALID(Dart_IntegerToInt64(integer_obj, &int64_t_value));
    EXPECT_EQ(10 - i, int64_t_value);
  }
}


static int kLength = 16;

static void ByteDataNativeFunction(Dart_NativeArguments args) {
  Dart_EnterScope();
  Dart_Handle byte_data = Dart_NewTypedData(kByteData, kLength);
  EXPECT_VALID(byte_data);
  EXPECT_EQ(kByteData, Dart_GetTypeOfTypedData(byte_data));
  Dart_SetReturnValue(args, byte_data);
  Dart_ExitScope();
}


static Dart_NativeFunction ByteDataNativeResolver(Dart_Handle name,
                                                  int arg_count) {
  return &ByteDataNativeFunction;
}


TEST_CASE(ByteDataAccess) {
  const char* kScriptChars =
      "import 'dart:typed_data';\n"
      "class Expect {\n"
      "  static equals(a, b) {\n"
      "    if (a != b) {\n"
      "      throw 'not equal. expected: $a, got: $b';\n"
      "    }\n"
      "  }\n"
      "}\n"
      "ByteData createByteData() native 'CreateByteData';"
      "ByteData main() {"
      "  var length = 16;"
      "  var a = createByteData();"
      "  Expect.equals(length, a.lengthInBytes);"
      "  for (int i = 0; i < length; i+=1) {"
      "    a.setInt8(i, 0x42);"
      "  }"
      "  for (int i = 0; i < length; i+=2) {"
      "    Expect.equals(0x4242, a.getInt16(i));"
      "  }"
      "  return a;"
      "}\n";
  // Create a test library and Load up a test script in it.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);

  Dart_Handle result = Dart_SetNativeResolver(lib, &ByteDataNativeResolver);
  EXPECT_VALID(result);

  // Invoke 'main' function.
  result = Dart_Invoke(lib, NewString("main"), 0, NULL);
  EXPECT_VALID(result);
}


static const intptr_t kExtLength = 16;
static int8_t data[kExtLength] = { 0x41, 0x42, 0x41, 0x42,
                                   0x41, 0x42, 0x41, 0x42,
                                   0x41, 0x42, 0x41, 0x42,
                                   0x41, 0x42, 0x41, 0x42, };

static void ExternalByteDataNativeFunction(Dart_NativeArguments args) {
  Dart_EnterScope();
  Dart_Handle external_byte_data = Dart_NewExternalTypedData(kByteData,
                                                             data,
                                                             16,
                                                             NULL, NULL);
  EXPECT_VALID(external_byte_data);
  EXPECT_EQ(kByteData, Dart_GetTypeOfTypedData(external_byte_data));
  Dart_SetReturnValue(args, external_byte_data);
  Dart_ExitScope();
}


static Dart_NativeFunction ExternalByteDataNativeResolver(Dart_Handle name,
                                                          int arg_count) {
  return &ExternalByteDataNativeFunction;
}


TEST_CASE(ExternalByteDataAccess) {
  // TODO(asiva): Once we have getInt16LE and getInt16BE support use the
  // appropriate getter instead of the host endian format used now.
  const char* kScriptChars =
      "import 'dart:typed_data';\n"
      "class Expect {\n"
      "  static equals(a, b) {\n"
      "    if (a != b) {\n"
      "      throw 'not equal. expected: $a, got: $b';\n"
      "    }\n"
      "  }\n"
      "}\n"
      "ByteData createExternalByteData() native 'CreateExternalByteData';"
      "ByteData main() {"
      "  var length = 16;"
      "  var a = createExternalByteData();"
      "  Expect.equals(length, a.lengthInBytes);"
      "  for (int i = 0; i < length; i+=2) {"
      "    Expect.equals(0x4241, a.getInt16(i, Endianness.LITTLE_ENDIAN));"
      "  }"
      "  for (int i = 0; i < length; i+=2) {"
      "    a.setInt8(i, 0x24);"
      "    a.setInt8(i + 1, 0x28);"
      "  }"
      "  for (int i = 0; i < length; i+=2) {"
      "    Expect.equals(0x2824, a.getInt16(i, Endianness.LITTLE_ENDIAN));"
      "  }"
      "  return a;"
      "}\n";
  // Create a test library and Load up a test script in it.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);

  Dart_Handle result = Dart_SetNativeResolver(lib,
                                              &ExternalByteDataNativeResolver);
  EXPECT_VALID(result);

  // Invoke 'main' function.
  result = Dart_Invoke(lib, NewString("main"), 0, NULL);
  EXPECT_VALID(result);

  for (intptr_t i = 0; i < kExtLength; i+=2) {
    EXPECT_EQ(0x24, data[i]);
    EXPECT_EQ(0x28, data[i+1]);
  }
}


TEST_CASE(TypedDataDirectAccess) {
  Dart_Handle str = Dart_NewStringFromCString("junk");
  Dart_Handle byte_array = Dart_NewTypedData(kUint8, 10);
  EXPECT_VALID(byte_array);
  Dart_Handle result;
  result = Dart_TypedDataAcquireData(byte_array, NULL, NULL, NULL);
  EXPECT_ERROR(result, "Dart_TypedDataAcquireData expects argument 'type'"
                       " to be non-null.");
  Dart_TypedData_Type type;
  result = Dart_TypedDataAcquireData(byte_array, &type, NULL, NULL);
  EXPECT_ERROR(result, "Dart_TypedDataAcquireData expects argument 'data'"
                       " to be non-null.");
  void* data;
  result = Dart_TypedDataAcquireData(byte_array, &type, &data, NULL);
  EXPECT_ERROR(result, "Dart_TypedDataAcquireData expects argument 'len'"
                       " to be non-null.");
  intptr_t len;
  result = Dart_TypedDataAcquireData(Dart_Null(), &type, &data, &len);
  EXPECT_ERROR(result, "Dart_TypedDataAcquireData expects argument 'object'"
                       " to be non-null.");
  result = Dart_TypedDataAcquireData(str, &type, &data, &len);
  EXPECT_ERROR(result, "Dart_TypedDataAcquireData expects argument 'object'"
                       " to be of type 'TypedData'.");

  result = Dart_TypedDataReleaseData(Dart_Null());
  EXPECT_ERROR(result, "Dart_TypedDataReleaseData expects argument 'object'"
                       " to be non-null.");
  result = Dart_TypedDataReleaseData(str);
  EXPECT_ERROR(result, "Dart_TypedDataReleaseData expects argument 'object'"
                       " to be of type 'TypedData'.");
}


static void TestDirectAccess(Dart_Handle lib,
                             Dart_Handle array,
                             Dart_TypedData_Type expected_type) {
  Dart_Handle result;

  // Invoke the dart function that sets initial values.
  Dart_Handle dart_args[1];
  dart_args[0] = array;
  result = Dart_Invoke(lib, NewString("setMain"), 1, dart_args);
  EXPECT_VALID(result);

  // Now Get a direct access to this typed data object and check it's contents.
  const int kLength = 10;
  Dart_TypedData_Type type;
  void* data;
  intptr_t len;
  result = Dart_TypedDataAcquireData(array, &type, &data, &len);
  EXPECT_VALID(result);
  EXPECT_EQ(expected_type, type);
  EXPECT_EQ(kLength, len);
  int8_t* dataP = reinterpret_cast<int8_t*>(data);
  for (int i = 0; i < kLength; i++) {
    EXPECT_EQ(i, dataP[i]);
  }

  // Now modify the values in the directly accessible array and then check
  // it we see the changes back in dart.
  for (int i = 0; i < kLength; i++) {
    dataP[i] += 10;
  }

  // Release direct accesss to the typed data object.
  result = Dart_TypedDataReleaseData(array);
  EXPECT_VALID(result);

  // Invoke the dart function in order to check the modified values.
  result = Dart_Invoke(lib, NewString("testMain"), 1, dart_args);
  EXPECT_VALID(result);
}


TEST_CASE(TypedDataDirectAccess1) {
  const char* kScriptChars =
      "import 'dart:typed_data';\n"
      "class Expect {\n"
      "  static equals(a, b) {\n"
      "    if (a != b) {\n"
      "      throw new Exception('not equal. expected: $a, got: $b');\n"
      "    }\n"
      "  }\n"
      "}\n"
      "void setMain(var a) {"
      "  for (var i = 0; i < 10; i++) {"
      "    a[i] = i;"
      "  }"
      "}\n"
      "bool testMain(var list) {"
      "  for (var i = 0; i < 10; i++) {"
      "    Expect.equals((10 + i), list[i]);"
      "  }\n"
      "  return true;"
      "}\n"
      "List main() {"
      "  var a = new Int8List(10);"
      "  return a;"
      "}\n";
  // Create a test library and Load up a test script in it.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);

  // Test with an regular typed data object.
  Dart_Handle list_access_test_obj;
  list_access_test_obj = Dart_Invoke(lib, NewString("main"), 0, NULL);
  EXPECT_VALID(list_access_test_obj);
  TestDirectAccess(lib, list_access_test_obj, kInt8);

  // Test with an external typed data object.
  uint8_t data[] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
  intptr_t data_length = ARRAY_SIZE(data);
  Dart_Handle ext_list_access_test_obj;
  ext_list_access_test_obj = Dart_NewExternalTypedData(kUint8,
                                                       data,
                                                       data_length,
                                                       NULL, NULL);
  EXPECT_VALID(ext_list_access_test_obj);
  TestDirectAccess(lib, ext_list_access_test_obj, kUint8);
}


TEST_CASE(TypedDataViewDirectAccess) {
  const char* kScriptChars =
      "import 'dart:typed_data';\n"
      "class Expect {\n"
      "  static equals(a, b) {\n"
      "    if (a != b) {\n"
      "      throw 'not equal. expected: $a, got: $b';\n"
      "    }\n"
      "  }\n"
      "}\n"
      "void setMain(var list) {"
      "  Expect.equals(10, list.length);"
      "  for (var i = 0; i < 10; i++) {"
      "    list[i] = i;"
      "  }"
      "}\n"
      "bool testMain(var list) {"
      "  Expect.equals(10, list.length);"
      "  for (var i = 0; i < 10; i++) {"
      "    Expect.equals((10 + i), list[i]);"
      "  }"
      "  return true;"
      "}\n"
      "List main() {"
      "  var a = new Int8List(100);"
      "  var view = new Int8List.view(a.buffer, 50, 10);"
      "  return view;"
      "}\n";
  // Create a test library and Load up a test script in it.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);

  // Test with a typed data view object.
  Dart_Handle list_access_test_obj;
  list_access_test_obj = Dart_Invoke(lib, NewString("main"), 0, NULL);
  EXPECT_VALID(list_access_test_obj);
  TestDirectAccess(lib, list_access_test_obj, kInt8);
}


TEST_CASE(ByteDataDirectAccess) {
  const char* kScriptChars =
      "import 'dart:typed_data';\n"
      "class Expect {\n"
      "  static equals(a, b) {\n"
      "    if (a != b) {\n"
      "      throw 'not equal. expected: $a, got: $b';\n"
      "    }\n"
      "  }\n"
      "}\n"
      "void setMain(var list) {"
      "  Expect.equals(10, list.length);"
      "  for (var i = 0; i < 10; i++) {"
      "    list.setInt8(i, i);"
      "  }"
      "}\n"
      "bool testMain(var list) {"
      "  Expect.equals(10, list.length);"
      "  for (var i = 0; i < 10; i++) {"
      "    Expect.equals((10 + i), list.getInt8(i));"
      "  }"
      "  return true;"
      "}\n"
      "ByteData main() {"
      "  var a = new Int8List(100);"
      "  var view = new ByteData.view(a.buffer, 50, 10);"
      "  return view;"
      "}\n";
  // Create a test library and Load up a test script in it.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);

  // Test with a typed data view object.
  Dart_Handle list_access_test_obj;
  list_access_test_obj = Dart_Invoke(lib, NewString("main"), 0, NULL);
  EXPECT_VALID(list_access_test_obj);
  TestDirectAccess(lib, list_access_test_obj, kByteData);
}


static void ExternalTypedDataAccessTests(Dart_Handle obj,
                                         Dart_TypedData_Type expected_type,
                                         uint8_t data[],
                                         intptr_t data_length) {
  EXPECT_VALID(obj);
  EXPECT_EQ(expected_type, Dart_GetTypeOfExternalTypedData(obj));
  EXPECT(Dart_IsList(obj));

  void* raw_data = NULL;
  intptr_t len;
  Dart_TypedData_Type type;
  EXPECT_VALID(Dart_TypedDataAcquireData(obj, &type, &raw_data, &len));
  EXPECT(raw_data == data);
  EXPECT_EQ(data_length, len);
  EXPECT_EQ(expected_type, type);
  EXPECT_VALID(Dart_TypedDataReleaseData(obj));

  void* peer = &data;  // just a non-NULL value
  EXPECT_VALID(Dart_ExternalTypedDataGetPeer(obj, &peer));
  EXPECT(peer == NULL);

  intptr_t list_length = 0;
  EXPECT_VALID(Dart_ListLength(obj, &list_length));
  EXPECT_EQ(data_length, list_length);

  // Load and check values from underlying array and API.
  for (intptr_t i = 0; i < list_length; ++i) {
    EXPECT_EQ(11 * i, data[i]);
    Dart_Handle elt = Dart_ListGetAt(obj, i);
    EXPECT_VALID(elt);
    int64_t value = 0;
    EXPECT_VALID(Dart_IntegerToInt64(elt, &value));
    EXPECT_EQ(data[i], value);
  }

  // Write values through the underlying array.
  for (intptr_t i = 0; i < data_length; ++i) {
    data[i] *= 2;
  }
  // Read them back through the API.
  for (intptr_t i = 0; i < list_length; ++i) {
    Dart_Handle elt = Dart_ListGetAt(obj, i);
    EXPECT_VALID(elt);
    int64_t value = 0;
    EXPECT_VALID(Dart_IntegerToInt64(elt, &value));
    EXPECT_EQ(22 * i, value);
  }

  // Write values through the API.
  for (intptr_t i = 0; i < list_length; ++i) {
    Dart_Handle value = Dart_NewInteger(33 * i);
    EXPECT_VALID(value);
    EXPECT_VALID(Dart_ListSetAt(obj, i, value));
  }
  // Read them back through the underlying array.
  for (intptr_t i = 0; i < data_length; ++i) {
    EXPECT_EQ(33 * i, data[i]);
  }
}


TEST_CASE(ExternalTypedDataAccess) {
  uint8_t data[] = { 0, 11, 22, 33, 44, 55, 66, 77 };
  intptr_t data_length = ARRAY_SIZE(data);

  Dart_Handle obj = Dart_NewExternalTypedData(kUint8,
                                              data, data_length,
                                              NULL, NULL);
  ExternalTypedDataAccessTests(obj, kUint8, data, data_length);
}


TEST_CASE(ExternalClampedTypedDataAccess) {
  uint8_t data[] = { 0, 11, 22, 33, 44, 55, 66, 77 };
  intptr_t data_length = ARRAY_SIZE(data);

  Dart_Handle obj = Dart_NewExternalTypedData(kUint8Clamped,
                                              data, data_length,
                                              NULL, NULL);
  ExternalTypedDataAccessTests(obj, kUint8Clamped, data, data_length);
}


TEST_CASE(ExternalUint8ClampedArrayAccess) {
    const char* kScriptChars =
      "testClamped(List a) {\n"
      "  if (a[1] != 11) return false;\n"
      "  a[1] = 3;\n"
      "  if (a[1] != 3) return false;\n"
      "  a[1] = -12;\n"
      "  if (a[1] != 0) return false;\n"
      "  a[1] = 1200;\n"
      "  if (a[1] != 255) return false;\n"
      "  return true;\n"
      "}\n";

  uint8_t data[] = { 0, 11, 22, 33, 44, 55, 66, 77 };
  intptr_t data_length = ARRAY_SIZE(data);
  Dart_Handle obj = Dart_NewExternalTypedData(kUint8Clamped,
                                              data, data_length,
                                              NULL, NULL);
  EXPECT_VALID(obj);
  Dart_Handle result;
  // Create a test library and Load up a test script in it.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);
  Dart_Handle args[1];
  args[0] = obj;
  result = Dart_Invoke(lib, NewString("testClamped"), 1, args);

  // Check that result is true.
  EXPECT_VALID(result);
  EXPECT(Dart_IsBoolean(result));
  bool value = false;
  result = Dart_BooleanValue(result, &value);
  EXPECT_VALID(result);
  EXPECT(value);
}


static void ExternalTypedDataCallbackFinalizer(Dart_Handle handle,
                                               void* peer) {
  Dart_DeletePersistentHandle(handle);
  *static_cast<int*>(peer) = 42;
}


TEST_CASE(ExternalTypedDataCallback) {
  int peer = 0;
  {
    Dart_EnterScope();
    uint8_t data[] = { 1, 2, 3, 4 };
    Dart_Handle obj = Dart_NewExternalTypedData(
        kUint8,
        data,
        ARRAY_SIZE(data),
        &peer,
        ExternalTypedDataCallbackFinalizer);
    EXPECT_VALID(obj);
    void* api_peer = NULL;
    EXPECT_VALID(Dart_ExternalTypedDataGetPeer(obj, &api_peer));
    EXPECT_EQ(api_peer, &peer);
    Dart_ExitScope();
  }
  EXPECT(peer == 0);
  Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
  EXPECT(peer == 0);
  Isolate::Current()->heap()->CollectGarbage(Heap::kNew);
  EXPECT(peer == 42);
}


static void CheckFloat32x4Data(Dart_Handle obj) {
  void* raw_data = NULL;
  intptr_t len;
  Dart_TypedData_Type type;
  EXPECT_VALID(Dart_TypedDataAcquireData(obj, &type, &raw_data, &len));
  EXPECT_EQ(kFloat32x4, type);
  EXPECT_EQ(len, 10);
  float* float_data = reinterpret_cast<float*>(raw_data);
  for (int i = 0; i < len * 4; i++) {
    EXPECT_EQ(0.0, float_data[i]);
  }
  EXPECT_VALID(Dart_TypedDataReleaseData(obj));
}


TEST_CASE(Float32x4List) {
    const char* kScriptChars =
      "import 'dart:typed_data';\n"
      "Float32x4List float32x4() {\n"
      "  return new Float32x4List(10);\n"
      "}\n";
  // Create a test library and Load up a test script in it.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);

  Dart_Handle obj = Dart_Invoke(lib, NewString("float32x4"), 0, NULL);
  EXPECT_VALID(obj);
  CheckFloat32x4Data(obj);

  obj = Dart_NewTypedData(kFloat32x4, 10);
  EXPECT_VALID(obj);
  CheckFloat32x4Data(obj);

  int peer = 0;
  float data[] = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                   0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                   0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                   0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };
  obj = Dart_NewExternalTypedData(kFloat32x4,
                                  data,
                                  10,
                                  &peer,
                                  ExternalTypedDataCallbackFinalizer);
  CheckFloat32x4Data(obj);
  Isolate::Current()->heap()->CollectGarbage(Heap::kNew);
  EXPECT(peer == 42);
}


// Unit test for entering a scope, creating a local handle and exiting
// the scope.
UNIT_TEST_CASE(EnterExitScope) {
  TestIsolateScope __test_isolate__;

  Isolate* isolate = Isolate::Current();
  EXPECT(isolate != NULL);
  ApiState* state = isolate->api_state();
  EXPECT(state != NULL);
  ApiLocalScope* scope = state->top_scope();
  Dart_EnterScope();
  {
    EXPECT(state->top_scope() != NULL);
    DARTSCOPE(isolate);
    const String& str1 = String::Handle(String::New("Test String"));
    Dart_Handle ref = Api::NewHandle(isolate, str1.raw());
    String& str2 = String::Handle();
    str2 ^= Api::UnwrapHandle(ref);
    EXPECT(str1.Equals(str2));
  }
  Dart_ExitScope();
  EXPECT(scope == state->top_scope());
}


// Unit test for creating and deleting persistent handles.
UNIT_TEST_CASE(PersistentHandles) {
  const char* kTestString1 = "Test String1";
  const char* kTestString2 = "Test String2";
  TestCase::CreateTestIsolate();
  Isolate* isolate = Isolate::Current();
  EXPECT(isolate != NULL);
  ApiState* state = isolate->api_state();
  EXPECT(state != NULL);
  ApiLocalScope* scope = state->top_scope();
  Dart_Handle handles[2000];
  Dart_EnterScope();
  {
    DARTSCOPE(isolate);
    Dart_Handle ref1 = Api::NewHandle(isolate, String::New(kTestString1));
    for (int i = 0; i < 1000; i++) {
      handles[i] = Dart_NewPersistentHandle(ref1);
    }
    Dart_EnterScope();
    Dart_Handle ref2 = Api::NewHandle(isolate, String::New(kTestString2));
    for (int i = 1000; i < 2000; i++) {
      handles[i] = Dart_NewPersistentHandle(ref2);
    }
    for (int i = 500; i < 1500; i++) {
      Dart_DeletePersistentHandle(handles[i]);
    }
    for (int i = 500; i < 1000; i++) {
      handles[i] = Dart_NewPersistentHandle(ref2);
    }
    for (int i = 1000; i < 1500; i++) {
      handles[i] = Dart_NewPersistentHandle(ref1);
    }
    VERIFY_ON_TRANSITION;
    Dart_ExitScope();
  }
  Dart_ExitScope();
  {
    StackZone zone(isolate);
    HANDLESCOPE(isolate);
    for (int i = 0; i < 500; i++) {
      String& str = String::Handle();
      str ^= Api::UnwrapHandle(handles[i]);
      EXPECT(str.Equals(kTestString1));
    }
    for (int i = 500; i < 1000; i++) {
      String& str = String::Handle();
      str ^= Api::UnwrapHandle(handles[i]);
      EXPECT(str.Equals(kTestString2));
    }
    for (int i = 1000; i < 1500; i++) {
      String& str = String::Handle();
      str ^= Api::UnwrapHandle(handles[i]);
      EXPECT(str.Equals(kTestString1));
    }
    for (int i = 1500; i < 2000; i++) {
      String& str = String::Handle();
      str ^= Api::UnwrapHandle(handles[i]);
      EXPECT(str.Equals(kTestString2));
    }
  }
  EXPECT(scope == state->top_scope());
  EXPECT_EQ(2001, state->CountPersistentHandles());
  Dart_ShutdownIsolate();
}


// Test that we are able to create a persistent handle from a
// persistent handle.
UNIT_TEST_CASE(NewPersistentHandle_FromPersistentHandle) {
  TestIsolateScope __test_isolate__;

  Isolate* isolate = Isolate::Current();
  EXPECT(isolate != NULL);
  ApiState* state = isolate->api_state();
  EXPECT(state != NULL);
  DARTSCOPE(isolate);

  // Start with a known persistent handle.
  Dart_Handle obj1 = Dart_True();
  EXPECT(state->IsValidPersistentHandle(obj1));

  // And use it to allocate a second persistent handle.
  Dart_Handle obj2 = Dart_NewPersistentHandle(obj1);
  EXPECT(state->IsValidPersistentHandle(obj2));

  // Make sure that the value transferred.
  EXPECT(Dart_IsBoolean(obj2));
  bool value = false;
  Dart_Handle result = Dart_BooleanValue(obj2, &value);
  EXPECT_VALID(result);
  EXPECT(value);
}


// Helper class to ensure new gen GC is triggered without any side effects.
// The normal call to CollectGarbage(Heap::kNew) could potentially trigger
// an old gen collection if there is a promotion failure and this could
// perturb the test.
class GCTestHelper : public AllStatic {
 public:
  static void CollectNewSpace(Heap::ApiCallbacks api_callbacks) {
    bool invoke_api_callbacks = (api_callbacks == Heap::kInvokeApiCallbacks);
    Isolate::Current()->heap()->new_space_->Scavenge(invoke_api_callbacks);
  }
};


TEST_CASE(WeakPersistentHandle) {
  Dart_Handle weak_new_ref = Dart_Null();
  EXPECT(Dart_IsNull(weak_new_ref));

  Dart_Handle weak_old_ref = Dart_Null();
  EXPECT(Dart_IsNull(weak_old_ref));

  {
    Dart_EnterScope();

    // Create an object in new space.
    Dart_Handle new_ref = NewString("new string");
    EXPECT_VALID(new_ref);

    // Create an object in old space.
    Dart_Handle old_ref;
    {
      Isolate* isolate = Isolate::Current();
      DARTSCOPE(isolate);
      old_ref = Api::NewHandle(isolate, String::New("old string", Heap::kOld));
      EXPECT_VALID(old_ref);
    }

    // Create a weak ref to the new space object.
    weak_new_ref = Dart_NewWeakPersistentHandle(new_ref, NULL, NULL);
    EXPECT_VALID(weak_new_ref);
    EXPECT(!Dart_IsNull(weak_new_ref));

    // Create a weak ref to the old space object.
    weak_old_ref = Dart_NewWeakPersistentHandle(old_ref, NULL, NULL);
    EXPECT_VALID(weak_old_ref);
    EXPECT(!Dart_IsNull(weak_old_ref));

    // Garbage collect new space.
    GCTestHelper::CollectNewSpace(Heap::kIgnoreApiCallbacks);

    // Nothing should be invalidated or cleared.
    EXPECT_VALID(new_ref);
    EXPECT(!Dart_IsNull(new_ref));
    EXPECT_VALID(old_ref);
    EXPECT(!Dart_IsNull(old_ref));

    EXPECT_VALID(weak_new_ref);
    EXPECT(!Dart_IsNull(weak_new_ref));
    EXPECT(Dart_IdentityEquals(new_ref, weak_new_ref));

    EXPECT_VALID(weak_old_ref);
    EXPECT(!Dart_IsNull(weak_old_ref));
    EXPECT(Dart_IdentityEquals(old_ref, weak_old_ref));

    // Garbage collect old space.
    Isolate::Current()->heap()->CollectGarbage(Heap::kOld);

    // Nothing should be invalidated or cleared.
    EXPECT_VALID(new_ref);
    EXPECT(!Dart_IsNull(new_ref));
    EXPECT_VALID(old_ref);
    EXPECT(!Dart_IsNull(old_ref));

    EXPECT_VALID(weak_new_ref);
    EXPECT(!Dart_IsNull(weak_new_ref));
    EXPECT(Dart_IdentityEquals(new_ref, weak_new_ref));

    EXPECT_VALID(weak_old_ref);
    EXPECT(!Dart_IsNull(weak_old_ref));
    EXPECT(Dart_IdentityEquals(old_ref, weak_old_ref));

    // Delete local (strong) references.
    Dart_ExitScope();
  }

  // Garbage collect new space again.
  GCTestHelper::CollectNewSpace(Heap::kIgnoreApiCallbacks);

  // Weak ref to new space object should now be cleared.
  EXPECT_VALID(weak_new_ref);
  EXPECT(Dart_IsNull(weak_new_ref));
  EXPECT_VALID(weak_old_ref);
  EXPECT(!Dart_IsNull(weak_old_ref));

  // Garbage collect old space again.
  Isolate::Current()->heap()->CollectGarbage(Heap::kOld);

  // Weak ref to old space object should now be cleared.
  EXPECT_VALID(weak_new_ref);
  EXPECT(Dart_IsNull(weak_new_ref));
  EXPECT_VALID(weak_old_ref);
  EXPECT(Dart_IsNull(weak_old_ref));

  Dart_DeletePersistentHandle(weak_new_ref);
  Dart_DeletePersistentHandle(weak_old_ref);

  // Garbage collect one last time to revisit deleted handles.
  Isolate::Current()->heap()->CollectGarbage(Heap::kNew);
  Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
}


static void WeakPersistentHandlePeerFinalizer(Dart_Handle handle, void* peer) {
  *static_cast<int*>(peer) = 42;
}


TEST_CASE(WeakPersistentHandleCallback) {
  Dart_Handle weak_ref = Dart_Null();
  EXPECT(Dart_IsNull(weak_ref));
  int peer = 0;
  {
    Dart_EnterScope();
    Dart_Handle obj = NewString("new string");
    EXPECT_VALID(obj);
    weak_ref = Dart_NewWeakPersistentHandle(obj, &peer,
                                            WeakPersistentHandlePeerFinalizer);
    Dart_ExitScope();
  }
  EXPECT_VALID(weak_ref);
  EXPECT(peer == 0);
  Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
  EXPECT(peer == 0);
  GCTestHelper::CollectNewSpace(Heap::kIgnoreApiCallbacks);
  EXPECT(peer == 42);
  Dart_DeletePersistentHandle(weak_ref);
}


TEST_CASE(WeakPersistentHandleNoCallback) {
  Dart_Handle weak_ref = Dart_Null();
  EXPECT(Dart_IsNull(weak_ref));
  int peer = 0;
  {
    Dart_EnterScope();
    Dart_Handle obj = NewString("new string");
    EXPECT_VALID(obj);
    weak_ref = Dart_NewWeakPersistentHandle(obj, &peer,
                                            WeakPersistentHandlePeerFinalizer);
    Dart_ExitScope();
  }
  // A finalizer is not invoked on a deleted handle.  Therefore, the
  // peer value should not change after the referent is collected.
  Dart_DeletePersistentHandle(weak_ref);
  EXPECT_VALID(weak_ref);
  EXPECT(peer == 0);
  Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
  EXPECT(peer == 0);
  GCTestHelper::CollectNewSpace(Heap::kIgnoreApiCallbacks);
  EXPECT(peer == 0);
}


UNIT_TEST_CASE(WeakPersistentHandlesCallbackShutdown) {
  TestCase::CreateTestIsolate();
  Dart_EnterScope();
  Dart_Handle ref = Dart_True();
  int peer = 1234;
  Dart_NewWeakPersistentHandle(ref,
                               &peer,
                               WeakPersistentHandlePeerFinalizer);
  Dart_ShutdownIsolate();
  EXPECT(peer == 42);
}


TEST_CASE(ObjectGroups) {
  Dart_Handle strong = Dart_Null();
  EXPECT(Dart_IsNull(strong));

  Dart_Handle weak1 = Dart_Null();
  EXPECT(Dart_IsNull(weak1));

  Dart_Handle weak2 = Dart_Null();
  EXPECT(Dart_IsNull(weak2));

  Dart_Handle weak3 = Dart_Null();
  EXPECT(Dart_IsNull(weak3));

  Dart_Handle weak4 = Dart_Null();
  EXPECT(Dart_IsNull(weak4));

  Dart_EnterScope();
  {
    Isolate* isolate = Isolate::Current();
    DARTSCOPE(isolate);

    strong = Dart_NewPersistentHandle(
        Api::NewHandle(isolate, String::New("strongly reachable", Heap::kOld)));
    EXPECT_VALID(strong);
    EXPECT(!Dart_IsNull(strong));

    weak1 = Dart_NewWeakPersistentHandle(
        Api::NewHandle(isolate, String::New("weakly reachable 1", Heap::kOld)),
        NULL, NULL);
    EXPECT_VALID(weak1);
    EXPECT(!Dart_IsNull(weak1));

    weak2 = Dart_NewWeakPersistentHandle(
        Api::NewHandle(isolate, String::New("weakly reachable 2", Heap::kOld)),
        NULL, NULL);
    EXPECT_VALID(weak2);
    EXPECT(!Dart_IsNull(weak2));

    weak3 = Dart_NewWeakPersistentHandle(
        Api::NewHandle(isolate, String::New("weakly reachable 3", Heap::kOld)),
        NULL, NULL);
    EXPECT_VALID(weak3);
    EXPECT(!Dart_IsNull(weak3));

    weak4 = Dart_NewWeakPersistentHandle(
        Api::NewHandle(isolate, String::New("weakly reachable 4", Heap::kOld)),
        NULL, NULL);
    EXPECT_VALID(weak4);
    EXPECT(!Dart_IsNull(weak4));
  }
  Dart_ExitScope();

  EXPECT_VALID(strong);

  EXPECT_VALID(weak1);
  EXPECT_VALID(weak2);
  EXPECT_VALID(weak3);
  EXPECT_VALID(weak4);

  GCTestHelper::CollectNewSpace(Heap::kIgnoreApiCallbacks);

  // New space collection should not affect old space objects
  EXPECT(!Dart_IsNull(weak1));
  EXPECT(!Dart_IsNull(weak2));
  EXPECT(!Dart_IsNull(weak3));
  EXPECT(!Dart_IsNull(weak4));

  {
    Dart_Handle array1[] = { weak1, strong };
    EXPECT_VALID(Dart_NewWeakReferenceSet(array1, ARRAY_SIZE(array1),
                                          array1, ARRAY_SIZE(array1)));

    Dart_Handle array2[] = { weak2, weak1 };
    EXPECT_VALID(Dart_NewWeakReferenceSet(array2, ARRAY_SIZE(array2),
                                          array2, ARRAY_SIZE(array2)));

    Dart_Handle array3[] = { weak3, weak2 };
    EXPECT_VALID(Dart_NewWeakReferenceSet(array3, ARRAY_SIZE(array3),
                                          array3, ARRAY_SIZE(array3)));

    Dart_Handle array4[] = { weak4, weak3 };
    EXPECT_VALID(Dart_NewWeakReferenceSet(array4, ARRAY_SIZE(array4),
                                          array4, ARRAY_SIZE(array4)));

    Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
  }

  // All weak references should be preserved.
  EXPECT(!Dart_IsNull(weak1));
  EXPECT(!Dart_IsNull(weak2));
  EXPECT(!Dart_IsNull(weak3));
  EXPECT(!Dart_IsNull(weak4));

  {
    Dart_Handle array1[] = { weak1, strong };
    EXPECT_VALID(Dart_NewWeakReferenceSet(array1, ARRAY_SIZE(array1),
                                          array1, ARRAY_SIZE(array1)));

    Dart_Handle array2[] = { weak2, weak1 };
    EXPECT_VALID(Dart_NewWeakReferenceSet(array2, ARRAY_SIZE(array2),
                                          array2, ARRAY_SIZE(array2)));

    Dart_Handle array3[] = { weak2 };
    EXPECT_VALID(Dart_NewWeakReferenceSet(array3, ARRAY_SIZE(array3),
                                          array3, ARRAY_SIZE(array3)));

    // Strong reference to weak3 to retain weak3 and weak4.
    Dart_Handle weak3_strong_ref = Dart_NewPersistentHandle(weak3);
    EXPECT_VALID(weak3_strong_ref);

    Dart_Handle array4[] = { weak4, weak3 };
    EXPECT_VALID(Dart_NewWeakReferenceSet(array4, ARRAY_SIZE(array4),
                                          array4, ARRAY_SIZE(array4)));

    Isolate::Current()->heap()->CollectGarbage(Heap::kOld);

    // Delete strong reference to weak3.
    Dart_DeletePersistentHandle(weak3_strong_ref);
  }

  // All weak references should be preserved.
  EXPECT(!Dart_IsNull(weak1));
  EXPECT(!Dart_IsNull(weak2));
  EXPECT(!Dart_IsNull(weak3));
  EXPECT(!Dart_IsNull(weak4));

  {
    Dart_Handle array1[] = { weak1, strong };
    EXPECT_VALID(Dart_NewWeakReferenceSet(array1, ARRAY_SIZE(array1),
                                          array1, ARRAY_SIZE(array1)));

    Dart_Handle array2[] = { weak2, weak1 };
    EXPECT_VALID(Dart_NewWeakReferenceSet(array2, ARRAY_SIZE(array2),
                                          array2, ARRAY_SIZE(array2)));

    Dart_Handle array3[] = { weak2 };
    EXPECT_VALID(Dart_NewWeakReferenceSet(array3, ARRAY_SIZE(array3),
                                          array3, ARRAY_SIZE(array3)));

    Dart_Handle array4[] = { weak4, weak3 };
    EXPECT_VALID(Dart_NewWeakReferenceSet(array4, ARRAY_SIZE(array4),
                                          array4, ARRAY_SIZE(array4)));

    Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
  }

  // Only weak1 and weak2 should be preserved.
  EXPECT(!Dart_IsNull(weak1));
  EXPECT(!Dart_IsNull(weak2));
  EXPECT(Dart_IsNull(weak3));
  EXPECT(Dart_IsNull(weak4));

  {
    Dart_Handle array1[] = { weak1, strong };
    EXPECT_VALID(Dart_NewWeakReferenceSet(array1, ARRAY_SIZE(array1),
                                          array1, ARRAY_SIZE(array1)));

    // weak3 is cleared so weak2 is unreferenced and should be cleared
    Dart_Handle array2[] = { weak2, weak3 };
    EXPECT_VALID(Dart_NewWeakReferenceSet(array2, ARRAY_SIZE(array2),
                                          array2, ARRAY_SIZE(array2)));

    Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
  }

  // Only weak1 should be preserved, weak3 should not preserve weak2.
  EXPECT(!Dart_IsNull(weak1));
  EXPECT(Dart_IsNull(weak2));
  EXPECT(Dart_IsNull(weak3));  // was cleared, should remain cleared
  EXPECT(Dart_IsNull(weak4));  // was cleared, should remain cleared

  {
    // weak{2,3,4} are cleared and should have no effect on weak1
    Dart_Handle array1[] = { strong, weak2, weak3, weak4 };
    EXPECT_VALID(Dart_NewWeakReferenceSet(array1, ARRAY_SIZE(array1),
                                          array1, ARRAY_SIZE(array1)));

    // weak1 is weakly reachable and should be cleared
    Dart_Handle array2[] = { weak1 };
    EXPECT_VALID(Dart_NewWeakReferenceSet(array2, ARRAY_SIZE(array2),
                                          array2, ARRAY_SIZE(array2)));

    Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
  }

  // All weak references should now be cleared.
  EXPECT(Dart_IsNull(weak1));
  EXPECT(Dart_IsNull(weak2));
  EXPECT(Dart_IsNull(weak3));
  EXPECT(Dart_IsNull(weak4));
}


TEST_CASE(PrologueWeakPersistentHandles) {
  Dart_Handle old_pwph = Dart_Null();
  EXPECT(Dart_IsNull(old_pwph));
  Dart_Handle new_pwph = Dart_Null();
  EXPECT(Dart_IsNull(new_pwph));
  Dart_EnterScope();
  {
    Isolate* isolate = Isolate::Current();
    DARTSCOPE(isolate);
    new_pwph = Dart_NewPrologueWeakPersistentHandle(
        Api::NewHandle(isolate,
                       String::New("new space prologue weak", Heap::kNew)),
        NULL, NULL);
    EXPECT_VALID(new_pwph);
    EXPECT(!Dart_IsNull(new_pwph));
    old_pwph = Dart_NewPrologueWeakPersistentHandle(
        Api::NewHandle(isolate,
                       String::New("old space prologue weak", Heap::kOld)),
        NULL, NULL);
    EXPECT_VALID(old_pwph);
    EXPECT(!Dart_IsNull(old_pwph));
  }
  Dart_ExitScope();
  EXPECT_VALID(new_pwph);
  EXPECT(!Dart_IsNull(new_pwph));
  EXPECT(Dart_IsPrologueWeakPersistentHandle(new_pwph));
  EXPECT_VALID(old_pwph);
  EXPECT(!Dart_IsNull(old_pwph));
  EXPECT(Dart_IsPrologueWeakPersistentHandle(old_pwph));
  // Garbage collect new space without invoking API callbacks.
  GCTestHelper::CollectNewSpace(Heap::kIgnoreApiCallbacks);

  // Both prologue weak handles should be preserved.
  EXPECT(!Dart_IsNull(new_pwph));
  EXPECT(!Dart_IsNull(old_pwph));
  // Garbage collect old space without invoking API callbacks.
  Isolate::Current()->heap()->CollectGarbage(Heap::kOld,
                                             Heap::kIgnoreApiCallbacks);
  // Both prologue weak handles should be preserved.
  EXPECT(!Dart_IsNull(new_pwph));
  EXPECT(!Dart_IsNull(old_pwph));
  // Garbage collect new space invoking API callbacks.
  GCTestHelper::CollectNewSpace(Heap::kInvokeApiCallbacks);

  // The prologue weak handle with a new space referent should now be
  // cleared.  The old space referent should be preserved.
  EXPECT(Dart_IsNull(new_pwph));
  EXPECT(!Dart_IsNull(old_pwph));
  Isolate::Current()->heap()->CollectGarbage(Heap::kOld,
                                             Heap::kInvokeApiCallbacks);
  // The prologue weak handle with an old space referent should now be
  // cleared.  The new space referent should remain cleared.
  EXPECT(Dart_IsNull(new_pwph));
  EXPECT(Dart_IsNull(old_pwph));
}


TEST_CASE(ImplicitReferencesOldSpace) {
  Dart_Handle strong = Dart_Null();
  EXPECT(Dart_IsNull(strong));

  Dart_Handle weak1 = Dart_Null();
  EXPECT(Dart_IsNull(weak1));

  Dart_Handle weak2 = Dart_Null();
  EXPECT(Dart_IsNull(weak2));

  Dart_Handle weak3 = Dart_Null();
  EXPECT(Dart_IsNull(weak3));

  Dart_EnterScope();
  {
    Isolate* isolate = Isolate::Current();
    DARTSCOPE(isolate);

    strong = Dart_NewPersistentHandle(
        Api::NewHandle(isolate, String::New("strongly reachable", Heap::kOld)));
    EXPECT(!Dart_IsNull(strong));
    EXPECT_VALID(strong);

    weak1 = Dart_NewWeakPersistentHandle(
        Api::NewHandle(isolate, String::New("weakly reachable 1", Heap::kOld)),
        NULL, NULL);
    EXPECT(!Dart_IsNull(weak1));
    EXPECT_VALID(weak1);

    weak2 = Dart_NewWeakPersistentHandle(
        Api::NewHandle(isolate, String::New("weakly reachable 2", Heap::kOld)),
        NULL, NULL);
    EXPECT(!Dart_IsNull(weak2));
    EXPECT_VALID(weak2);

    weak3 = Dart_NewWeakPersistentHandle(
        Api::NewHandle(isolate, String::New("weakly reachable 3", Heap::kOld)),
        NULL, NULL);
    EXPECT(!Dart_IsNull(weak3));
    EXPECT_VALID(weak3);
  }
  Dart_ExitScope();

  EXPECT_VALID(strong);

  EXPECT_VALID(weak1);
  EXPECT_VALID(weak2);
  EXPECT_VALID(weak3);

  GCTestHelper::CollectNewSpace(Heap::kIgnoreApiCallbacks);

  // New space collection should not affect old space objects
  EXPECT(!Dart_IsNull(weak1));
  EXPECT(!Dart_IsNull(weak2));
  EXPECT(!Dart_IsNull(weak3));

  // A strongly referenced key should preserve all the values.
  {
    Dart_Handle keys[] = { strong };
    Dart_Handle values[] = { weak1, weak2, weak3 };
    EXPECT_VALID(Dart_NewWeakReferenceSet(keys, ARRAY_SIZE(keys),
                                          values, ARRAY_SIZE(values)));

    Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
  }

  // All weak references should be preserved.
  EXPECT(!Dart_IsNull(weak1));
  EXPECT(!Dart_IsNull(weak2));
  EXPECT(!Dart_IsNull(weak3));

  // Key membership does not imply a strong reference.
  {
    Dart_Handle keys[] = { strong, weak3 };
    Dart_Handle values[] = { weak1, weak2 };
    EXPECT_VALID(Dart_NewWeakReferenceSet(keys, ARRAY_SIZE(keys),
                                          values, ARRAY_SIZE(values)));

    Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
  }

  // All weak references except weak3 should be preserved.
  EXPECT(!Dart_IsNull(weak1));
  EXPECT(!Dart_IsNull(weak2));
  EXPECT(Dart_IsNull(weak3));
}


TEST_CASE(ImplicitReferencesNewSpace) {
  Dart_Handle strong = Dart_Null();
  EXPECT(Dart_IsNull(strong));

  Dart_Handle weak1 = Dart_Null();
  EXPECT(Dart_IsNull(weak1));

  Dart_Handle weak2 = Dart_Null();
  EXPECT(Dart_IsNull(weak2));

  Dart_Handle weak3 = Dart_Null();
  EXPECT(Dart_IsNull(weak3));

  Dart_EnterScope();
  {
    Isolate* isolate = Isolate::Current();
    DARTSCOPE(isolate);

    strong = Dart_NewPersistentHandle(
        Api::NewHandle(isolate, String::New("strongly reachable", Heap::kNew)));
    EXPECT(!Dart_IsNull(strong));
    EXPECT_VALID(strong);

    weak1 = Dart_NewWeakPersistentHandle(
        Api::NewHandle(isolate, String::New("weakly reachable 1", Heap::kNew)),
        NULL, NULL);
    EXPECT(!Dart_IsNull(weak1));
    EXPECT_VALID(weak1);

    weak2 = Dart_NewWeakPersistentHandle(
        Api::NewHandle(isolate, String::New("weakly reachable 2", Heap::kNew)),
        NULL, NULL);
    EXPECT(!Dart_IsNull(weak2));
    EXPECT_VALID(weak2);

    weak3 = Dart_NewWeakPersistentHandle(
        Api::NewHandle(isolate, String::New("weakly reachable 3", Heap::kNew)),
        NULL, NULL);
    EXPECT(!Dart_IsNull(weak3));
    EXPECT_VALID(weak3);
  }
  Dart_ExitScope();

  EXPECT_VALID(strong);

  EXPECT_VALID(weak1);
  EXPECT_VALID(weak2);
  EXPECT_VALID(weak3);

  Isolate::Current()->heap()->CollectGarbage(Heap::kOld);

  // Old space collection should not affect old space objects.
  EXPECT(!Dart_IsNull(weak1));
  EXPECT(!Dart_IsNull(weak2));
  EXPECT(!Dart_IsNull(weak3));

  // A strongly referenced key should preserve all the values.
  {
    Dart_Handle keys[] = { strong };
    Dart_Handle values[] = { weak1, weak2, weak3 };
    EXPECT_VALID(Dart_NewWeakReferenceSet(keys, ARRAY_SIZE(keys),
                                          values, ARRAY_SIZE(values)));

    GCTestHelper::CollectNewSpace(Heap::kInvokeApiCallbacks);
  }

  // All weak references should be preserved.
  EXPECT(!Dart_IsNull(weak1));
  EXPECT(!Dart_IsNull(weak2));
  EXPECT(!Dart_IsNull(weak3));

  GCTestHelper::CollectNewSpace(Heap::kIgnoreApiCallbacks);

  // No weak references should be preserved.
  EXPECT(Dart_IsNull(weak1));
  EXPECT(Dart_IsNull(weak2));
  EXPECT(Dart_IsNull(weak3));
}


static int global_prologue_callback_status;


static void PrologueCallbackTimes2() {
  global_prologue_callback_status *= 2;
}


static void PrologueCallbackTimes3() {
  global_prologue_callback_status *= 3;
}


static int global_epilogue_callback_status;


static void EpilogueCallbackTimes4() {
  global_epilogue_callback_status *= 4;
}


static void EpilogueCallbackTimes5() {
  global_epilogue_callback_status *= 5;
}


TEST_CASE(AddGarbageCollectionCallbacks) {
  // Add a prologue callback.
  EXPECT_VALID(Dart_AddGcPrologueCallback(&PrologueCallbackTimes2));

  // Add the same prologue callback again.  This is an error.
  EXPECT(Dart_IsError(Dart_AddGcPrologueCallback(&PrologueCallbackTimes2)));

  // Add another prologue callback.
  EXPECT_VALID(Dart_AddGcPrologueCallback(&PrologueCallbackTimes3));

  // Add the same prologue callback again.  This is an error.
  EXPECT(Dart_IsError(Dart_AddGcPrologueCallback(&PrologueCallbackTimes3)));

  // Add an epilogue callback.
  EXPECT_VALID(Dart_AddGcEpilogueCallback(&EpilogueCallbackTimes4));

  // Add the same epilogue callback again.  This is an error.
  EXPECT(Dart_IsError(Dart_AddGcEpilogueCallback(&EpilogueCallbackTimes4)));

  // Add annother epilogue callback.
  EXPECT_VALID(Dart_AddGcEpilogueCallback(&EpilogueCallbackTimes5));

  // Add the same epilogue callback again.  This is an error.
  EXPECT(Dart_IsError(Dart_AddGcEpilogueCallback(&EpilogueCallbackTimes5)));
}


TEST_CASE(RemoveGarbageCollectionCallbacks) {
  // Remove a prologue callback that has not been added.  This is an error.
  EXPECT(Dart_IsError(Dart_RemoveGcPrologueCallback(&PrologueCallbackTimes2)));

  // Add a prologue callback.
  EXPECT_VALID(Dart_AddGcPrologueCallback(&PrologueCallbackTimes2));

  // Remove a prologue callback.
  EXPECT_VALID(Dart_RemoveGcPrologueCallback(&PrologueCallbackTimes2));

  // Remove a prologue callback again.  This is an error.
  EXPECT(Dart_IsError(Dart_RemoveGcPrologueCallback(&PrologueCallbackTimes2)));

  // Add two prologue callbacks.
  EXPECT_VALID(Dart_AddGcPrologueCallback(&PrologueCallbackTimes2));
  EXPECT_VALID(Dart_AddGcPrologueCallback(&PrologueCallbackTimes3));

  // Remove two prologue callbacks.
  EXPECT_VALID(Dart_RemoveGcPrologueCallback(&PrologueCallbackTimes3));
  EXPECT_VALID(Dart_RemoveGcPrologueCallback(&PrologueCallbackTimes2));

  // Remove epilogue callbacks again.  This is an error.
  EXPECT(Dart_IsError(Dart_RemoveGcEpilogueCallback(&EpilogueCallbackTimes4)));
  EXPECT(Dart_IsError(Dart_RemoveGcEpilogueCallback(&EpilogueCallbackTimes5)));

  // Remove a epilogue callback that has not been added.  This is an error.
  EXPECT(Dart_IsError(Dart_RemoveGcEpilogueCallback(&EpilogueCallbackTimes5)));

  // Add a epilogue callback.
  EXPECT_VALID(Dart_AddGcEpilogueCallback(&EpilogueCallbackTimes4));

  // Remove a epilogue callback.
  EXPECT_VALID(Dart_RemoveGcEpilogueCallback(&EpilogueCallbackTimes4));

  // Remove a epilogue callback again.  This is an error.
  EXPECT(Dart_IsError(Dart_RemoveGcEpilogueCallback(&EpilogueCallbackTimes4)));

  // Add two epilogue callbacks.
  EXPECT_VALID(Dart_AddGcEpilogueCallback(&EpilogueCallbackTimes4));
  EXPECT_VALID(Dart_AddGcEpilogueCallback(&EpilogueCallbackTimes5));

  // Remove two epilogue callbacks.
  EXPECT_VALID(Dart_RemoveGcEpilogueCallback(&EpilogueCallbackTimes5));
  EXPECT_VALID(Dart_RemoveGcEpilogueCallback(&EpilogueCallbackTimes4));

  // Remove epilogue callbacks again.  This is an error.
  EXPECT(Dart_IsError(Dart_RemoveGcEpilogueCallback(&EpilogueCallbackTimes4)));
  EXPECT(Dart_IsError(Dart_RemoveGcEpilogueCallback(&EpilogueCallbackTimes5)));
}


TEST_CASE(SingleGarbageCollectionCallback) {
  // Add a prologue callback.
  EXPECT_VALID(Dart_AddGcPrologueCallback(&PrologueCallbackTimes2));

  // Garbage collect new space ignoring callbacks.  This should not
  // invoke the prologue callback.  No status values should change.
  global_prologue_callback_status = 3;
  global_epilogue_callback_status = 7;
  GCTestHelper::CollectNewSpace(Heap::kIgnoreApiCallbacks);
  EXPECT_EQ(3, global_prologue_callback_status);
  EXPECT_EQ(7, global_epilogue_callback_status);

  // Garbage collect new space invoking callbacks.  This should
  // invoke the prologue callback.  No status values should change.
  global_prologue_callback_status = 3;
  global_epilogue_callback_status = 7;
  GCTestHelper::CollectNewSpace(Heap::kInvokeApiCallbacks);
  EXPECT_EQ(6, global_prologue_callback_status);
  EXPECT_EQ(7, global_epilogue_callback_status);

  // Garbage collect old space ignoring callbacks.  This should invoke
  // the prologue callback.  The prologue status value should change.
  global_prologue_callback_status = 3;
  global_epilogue_callback_status = 7;
  Isolate::Current()->heap()->CollectGarbage(Heap::kOld,
                                             Heap::kIgnoreApiCallbacks);
  EXPECT_EQ(3, global_prologue_callback_status);
  EXPECT_EQ(7, global_epilogue_callback_status);

  // Garbage collect old space.  This should invoke the prologue
  // callback.  The prologue status value should change.
  global_prologue_callback_status = 3;
  global_epilogue_callback_status = 7;
  Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
  EXPECT_EQ(6, global_prologue_callback_status);
  EXPECT_EQ(7, global_epilogue_callback_status);

  // Garbage collect old space again.  Callbacks are persistent so the
  // prologue status value should change again.
  Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
  EXPECT_EQ(12, global_prologue_callback_status);
  EXPECT_EQ(7, global_epilogue_callback_status);

  // Add an epilogue callback.
  EXPECT_VALID(Dart_AddGcEpilogueCallback(&EpilogueCallbackTimes4));

  // Garbage collect new space.  This should not invoke the prologue
  // or the epilogue callback.  No status values should change.
  global_prologue_callback_status = 3;
  global_epilogue_callback_status = 7;
  GCTestHelper::CollectNewSpace(Heap::kIgnoreApiCallbacks);
  EXPECT_EQ(3, global_prologue_callback_status);
  EXPECT_EQ(7, global_epilogue_callback_status);

  // Garbage collect new space.  This should invoke the prologue and
  // the epilogue callback.  The prologue and epilogue status values
  // should change.
  GCTestHelper::CollectNewSpace(Heap::kInvokeApiCallbacks);
  EXPECT_EQ(6, global_prologue_callback_status);
  EXPECT_EQ(28, global_epilogue_callback_status);

  // Garbage collect old space.  This should invoke the prologue and
  // the epilogue callbacks.  The prologue and epilogue status values
  // should change.
  global_prologue_callback_status = 3;
  global_epilogue_callback_status = 7;
  Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
  EXPECT_EQ(6, global_prologue_callback_status);
  EXPECT_EQ(28, global_epilogue_callback_status);

  // Garbage collect old space again without invoking callbacks.
  // Nothing should change.
  Isolate::Current()->heap()->CollectGarbage(Heap::kOld,
                                             Heap::kIgnoreApiCallbacks);
  EXPECT_EQ(6, global_prologue_callback_status);
  EXPECT_EQ(28, global_epilogue_callback_status);

  // Garbage collect old space again.  Callbacks are persistent so the
  // prologue and epilogue status values should change again.
  Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
  EXPECT_EQ(12, global_prologue_callback_status);
  EXPECT_EQ(112, global_epilogue_callback_status);

  // Remove the prologue and epilogue callbacks
  EXPECT_VALID(Dart_RemoveGcPrologueCallback(&PrologueCallbackTimes2));
  EXPECT_VALID(Dart_RemoveGcEpilogueCallback(&EpilogueCallbackTimes4));

  // Garbage collect old space.  No callbacks should be invoked.  No
  // status values should change.
  global_prologue_callback_status = 3;
  global_epilogue_callback_status = 7;
  Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
  EXPECT_EQ(3, global_prologue_callback_status);
  EXPECT_EQ(7, global_epilogue_callback_status);
}

TEST_CASE(MultipleGarbageCollectionCallbacks) {
  // Add prologue callbacks.
  EXPECT_VALID(Dart_AddGcPrologueCallback(&PrologueCallbackTimes2));
  EXPECT_VALID(Dart_AddGcPrologueCallback(&PrologueCallbackTimes3));

  // Add an epilogue callback.
  EXPECT_VALID(Dart_AddGcEpilogueCallback(&EpilogueCallbackTimes4));

  // Garbage collect new space.  This should not invoke the prologue
  // or epilogue callbacks.  No status values should change.
  global_prologue_callback_status = 3;
  global_epilogue_callback_status = 7;
  GCTestHelper::CollectNewSpace(Heap::kIgnoreApiCallbacks);
  EXPECT_EQ(3, global_prologue_callback_status);
  EXPECT_EQ(7, global_epilogue_callback_status);

  // Garbage collect old space.  This should invoke both prologue
  // callbacks and the epilogue callback.  The prologue and epilogue
  // status values should change.
  global_prologue_callback_status = 3;
  global_epilogue_callback_status = 7;
  Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
  EXPECT_EQ(18, global_prologue_callback_status);
  EXPECT_EQ(28, global_epilogue_callback_status);

  // Add another GC epilogue callback.
  EXPECT_VALID(Dart_AddGcEpilogueCallback(&EpilogueCallbackTimes5));

  // Garbage collect old space.  This should invoke both prologue
  // callbacks and both epilogue callbacks.  The prologue and epilogue
  // status values should change.
  global_prologue_callback_status = 3;
  global_epilogue_callback_status = 7;
  Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
  EXPECT_EQ(18, global_prologue_callback_status);
  EXPECT_EQ(140, global_epilogue_callback_status);

  // Remove an epilogue callback.
  EXPECT_VALID(Dart_RemoveGcEpilogueCallback(&EpilogueCallbackTimes4));

  // Garbage collect old space.  This should invoke both prologue
  // callbacks and the remaining epilogue callback.  The prologue and
  // epilogue status values should change.
  global_prologue_callback_status = 3;
  global_epilogue_callback_status = 7;
  Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
  EXPECT_EQ(18, global_prologue_callback_status);
  EXPECT_EQ(35, global_epilogue_callback_status);

  // Remove the remaining epilogue callback.
  EXPECT_VALID(Dart_RemoveGcEpilogueCallback(&EpilogueCallbackTimes5));

  // Garbage collect old space.  This should invoke both prologue
  // callbacks.  The prologue status value should change.
  global_prologue_callback_status = 3;
  global_epilogue_callback_status = 7;
  Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
  EXPECT_EQ(18, global_prologue_callback_status);
  EXPECT_EQ(7, global_epilogue_callback_status);

  // Remove a prologue callback.
  EXPECT_VALID(Dart_RemoveGcPrologueCallback(&PrologueCallbackTimes3));

  // Garbage collect old space.  This should invoke the remaining
  // prologue callback.  The prologue status value should change.
  global_prologue_callback_status = 3;
  global_epilogue_callback_status = 7;
  Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
  EXPECT_EQ(6, global_prologue_callback_status);
  EXPECT_EQ(7, global_epilogue_callback_status);

  // Remove the remaining prologue callback.
  EXPECT_VALID(Dart_RemoveGcPrologueCallback(&PrologueCallbackTimes2));

  // Garbage collect old space.  No callbacks should be invoked.  No
  // status values should change.
  global_prologue_callback_status = 3;
  global_epilogue_callback_status = 7;
  Isolate::Current()->heap()->CollectGarbage(Heap::kOld);
  EXPECT_EQ(3, global_prologue_callback_status);
  EXPECT_EQ(7, global_epilogue_callback_status);
}


// Unit test for creating multiple scopes and local handles within them.
// Ensure that the local handles get all cleaned out when exiting the
// scope.
UNIT_TEST_CASE(LocalHandles) {
  TestCase::CreateTestIsolate();
  Isolate* isolate = Isolate::Current();
  EXPECT(isolate != NULL);
  ApiState* state = isolate->api_state();
  EXPECT(state != NULL);
  ApiLocalScope* scope = state->top_scope();
  Dart_Handle handles[300];
  {
    StackZone zone(isolate);
    HANDLESCOPE(isolate);
    Smi& val = Smi::Handle();

    // Start a new scope and allocate some local handles.
    Dart_EnterScope();
    for (int i = 0; i < 100; i++) {
      handles[i] = Api::NewHandle(isolate, Smi::New(i));
    }
    EXPECT_EQ(100, state->CountLocalHandles());
    for (int i = 0; i < 100; i++) {
      val ^= Api::UnwrapHandle(handles[i]);
      EXPECT_EQ(i, val.Value());
    }
    // Start another scope and allocate some more local handles.
    {
      Dart_EnterScope();
      for (int i = 100; i < 200; i++) {
        handles[i] = Api::NewHandle(isolate, Smi::New(i));
      }
      EXPECT_EQ(200, state->CountLocalHandles());
      for (int i = 100; i < 200; i++) {
        val ^= Api::UnwrapHandle(handles[i]);
        EXPECT_EQ(i, val.Value());
      }

      // Start another scope and allocate some more local handles.
      {
        Dart_EnterScope();
        for (int i = 200; i < 300; i++) {
          handles[i] = Api::NewHandle(isolate, Smi::New(i));
        }
        EXPECT_EQ(300, state->CountLocalHandles());
        for (int i = 200; i < 300; i++) {
          val ^= Api::UnwrapHandle(handles[i]);
          EXPECT_EQ(i, val.Value());
        }
        EXPECT_EQ(300, state->CountLocalHandles());
        VERIFY_ON_TRANSITION;
        Dart_ExitScope();
      }
      EXPECT_EQ(200, state->CountLocalHandles());
      Dart_ExitScope();
    }
    EXPECT_EQ(100, state->CountLocalHandles());
    Dart_ExitScope();
  }
  EXPECT_EQ(0, state->CountLocalHandles());
  EXPECT(scope == state->top_scope());
  Dart_ShutdownIsolate();
}


// Unit test for creating multiple scopes and allocating objects in the
// zone for the scope. Ensure that the memory is freed when the scope
// exits.
UNIT_TEST_CASE(LocalZoneMemory) {
  TestCase::CreateTestIsolate();
  Isolate* isolate = Isolate::Current();
  EXPECT(isolate != NULL);
  ApiState* state = isolate->api_state();
  EXPECT(state != NULL);
  ApiLocalScope* scope = state->top_scope();
  {
    // Start a new scope and allocate some memory.
    Dart_EnterScope();
    for (int i = 0; i < 100; i++) {
      Dart_ScopeAllocate(16);
    }
    EXPECT_EQ(1600, state->ZoneSizeInBytes());
    // Start another scope and allocate some more memory.
    {
      Dart_EnterScope();
      for (int i = 0; i < 100; i++) {
        Dart_ScopeAllocate(16);
      }
      EXPECT_EQ(3200, state->ZoneSizeInBytes());
      {
        // Start another scope and allocate some more memory.
        {
          Dart_EnterScope();
          for (int i = 0; i < 200; i++) {
            Dart_ScopeAllocate(16);
          }
          EXPECT_EQ(6400, state->ZoneSizeInBytes());
          Dart_ExitScope();
        }
      }
      EXPECT_EQ(3200, state->ZoneSizeInBytes());
      Dart_ExitScope();
    }
    EXPECT_EQ(1600, state->ZoneSizeInBytes());
    Dart_ExitScope();
  }
  EXPECT_EQ(0, state->ZoneSizeInBytes());
  EXPECT(scope == state->top_scope());
  Dart_ShutdownIsolate();
}


UNIT_TEST_CASE(Isolates) {
  // This test currently assumes that the Dart_Isolate type is an opaque
  // representation of Isolate*.
  Dart_Isolate iso_1 = TestCase::CreateTestIsolate();
  EXPECT_EQ(iso_1, Api::CastIsolate(Isolate::Current()));
  Dart_Isolate isolate = Dart_CurrentIsolate();
  EXPECT_EQ(iso_1, isolate);
  Dart_ExitIsolate();
  EXPECT(NULL == Dart_CurrentIsolate());
  Dart_Isolate iso_2 = TestCase::CreateTestIsolate();
  EXPECT_EQ(iso_2, Dart_CurrentIsolate());
  Dart_ExitIsolate();
  EXPECT(NULL == Dart_CurrentIsolate());
  Dart_EnterIsolate(iso_2);
  EXPECT_EQ(iso_2, Dart_CurrentIsolate());
  Dart_ShutdownIsolate();
  EXPECT(NULL == Dart_CurrentIsolate());
  Dart_EnterIsolate(iso_1);
  EXPECT_EQ(iso_1, Dart_CurrentIsolate());
  Dart_ShutdownIsolate();
  EXPECT(NULL == Dart_CurrentIsolate());
}


UNIT_TEST_CASE(CurrentIsolateData) {
  intptr_t mydata = 12345;
  char* err;
  Dart_Isolate isolate =
      Dart_CreateIsolate(NULL, NULL, NULL,
                         reinterpret_cast<void*>(mydata),
                         &err);
  EXPECT(isolate != NULL);
  EXPECT_EQ(mydata, reinterpret_cast<intptr_t>(Dart_CurrentIsolateData()));
  Dart_ShutdownIsolate();
}


TEST_CASE(DebugName) {
  Dart_Handle debug_name = Dart_DebugName();
  EXPECT_VALID(debug_name);
  EXPECT(Dart_IsString(debug_name));
}


static void MyMessageNotifyCallback(Dart_Isolate dest_isolate) {
}


UNIT_TEST_CASE(SetMessageCallbacks) {
  Dart_Isolate dart_isolate = TestCase::CreateTestIsolate();
  Dart_SetMessageNotifyCallback(&MyMessageNotifyCallback);
  Isolate* isolate = reinterpret_cast<Isolate*>(dart_isolate);
  EXPECT_EQ(&MyMessageNotifyCallback, isolate->message_notify_callback());
  Dart_ShutdownIsolate();
}


TEST_CASE(ClassTypedefsEtc) {
  const char* kScriptChars =
      "class SomeClass {\n"
      "}\n"
      "typedef void SomeHandler(String a);\n";
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);
  EXPECT_VALID(lib);
  Dart_Handle normal_cls = Dart_GetClass(lib, NewString("SomeClass"));
  EXPECT_VALID(normal_cls);
  Dart_Handle typedef_cls = Dart_GetClass(lib, NewString("SomeHandler"));
  EXPECT_VALID(typedef_cls);

  EXPECT(Dart_IsClass(normal_cls));
  EXPECT(!Dart_ClassIsTypedef(normal_cls));
  EXPECT(!Dart_ClassIsFunctionType(normal_cls));

  EXPECT(Dart_IsClass(typedef_cls));
  EXPECT(Dart_ClassIsTypedef(typedef_cls));
  EXPECT(!Dart_ClassIsFunctionType(typedef_cls));

  // Exercise the typedef class api.
  Dart_Handle functype_cls = Dart_ClassGetTypedefReferent(typedef_cls);
  EXPECT_VALID(functype_cls);

  // Pass the wrong class kind to Dart_ClassGetTypedefReferent
  EXPECT_ERROR(Dart_ClassGetTypedefReferent(normal_cls),
               "class 'SomeClass' is not a typedef class.");

  EXPECT(Dart_IsClass(functype_cls));
  EXPECT(!Dart_ClassIsTypedef(functype_cls));
  EXPECT(Dart_ClassIsFunctionType(functype_cls));

  // Exercise the function type class.
  Dart_Handle sig_func = Dart_ClassGetFunctionTypeSignature(functype_cls);
  EXPECT_VALID(sig_func);
  EXPECT(Dart_IsFunction(sig_func));
  int64_t fixed_params = -1;
  int64_t opt_params = -1;
  EXPECT_VALID(
      Dart_FunctionParameterCounts(sig_func, &fixed_params, &opt_params));
  EXPECT_EQ(1, fixed_params);
  EXPECT_EQ(0, opt_params);

  // Pass the wrong class kind to Dart_ClassGetFunctionTypeSignature
  EXPECT_ERROR(Dart_ClassGetFunctionTypeSignature(normal_cls),
               "class 'SomeClass' is not a function-type class.");
}

#define CHECK_ABSTRACT_CLASS(handle, name)                                     \
  {                                                                            \
    Dart_Handle tmp = (handle);                                                \
    EXPECT_VALID(tmp);                                                         \
    EXPECT(Dart_IsAbstractClass(tmp));                                         \
    Dart_Handle intf_name = Dart_ClassName(tmp);                               \
    EXPECT_VALID(intf_name);                                                   \
    const char* intf_name_cstr = "";                                           \
    EXPECT_VALID(Dart_StringToCString(intf_name, &intf_name_cstr));            \
    EXPECT_STREQ((name), intf_name_cstr);                                      \
  }


TEST_CASE(ClassGetInterfaces) {
  const char* kScriptChars =
      "class MyClass0 {\n"
      "}\n"
      "\n"
      "class MyClass1 implements MyInterface1 {\n"
      "}\n"
      "\n"
      "class MyClass2 implements MyInterface0, MyInterface1 {\n"
      "}\n"
      "\n"
      "abstract class MyInterface0 {\n"
      "}\n"
      "\n"
      "abstract class MyInterface1 implements MyInterface0 {\n"
      "}\n";
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);

  Dart_Handle cls0 = Dart_GetClass(lib, NewString("MyClass0"));
  Dart_Handle cls1 = Dart_GetClass(lib, NewString("MyClass1"));
  Dart_Handle cls2 = Dart_GetClass(lib, NewString("MyClass2"));
  Dart_Handle intf0 = Dart_GetClass(lib, NewString("MyInterface0"));
  Dart_Handle intf1 = Dart_GetClass(lib, NewString("MyInterface1"));

  intptr_t len = -1;
  EXPECT_VALID(Dart_ClassGetInterfaceCount(cls0, &len));
  EXPECT_EQ(0, len);

  EXPECT_ERROR(Dart_ClassGetInterfaceAt(cls0, 0),
               "Dart_ClassGetInterfaceAt: argument 'index' out of bounds");

  len = -1;
  EXPECT_VALID(Dart_ClassGetInterfaceCount(cls1, &len));
  EXPECT_EQ(1, len);
  CHECK_ABSTRACT_CLASS(Dart_ClassGetInterfaceAt(cls1, 0), "MyInterface1");

  EXPECT_ERROR(Dart_ClassGetInterfaceAt(cls1, -1),
               "Dart_ClassGetInterfaceAt: argument 'index' out of bounds");
  EXPECT_ERROR(Dart_ClassGetInterfaceAt(cls1, 1),
               "Dart_ClassGetInterfaceAt: argument 'index' out of bounds");

  len = -1;
  EXPECT_VALID(Dart_ClassGetInterfaceCount(cls2, &len));
  EXPECT_EQ(2, len);

  // TODO(turnidge): The test relies on the ordering here.  Sort this.
  CHECK_ABSTRACT_CLASS(Dart_ClassGetInterfaceAt(cls2, 0), "MyInterface0");
  CHECK_ABSTRACT_CLASS(Dart_ClassGetInterfaceAt(cls2, 1), "MyInterface1");

  len = -1;
  EXPECT_VALID(Dart_ClassGetInterfaceCount(intf0, &len));
  EXPECT_EQ(0, len);

  len = -1;
  EXPECT_VALID(Dart_ClassGetInterfaceCount(intf1, &len));
  EXPECT_EQ(1, len);
  CHECK_ABSTRACT_CLASS(Dart_ClassGetInterfaceAt(intf1, 0), "MyInterface0");

  // Error cases.
  EXPECT_ERROR(Dart_ClassGetInterfaceCount(Dart_True(), &len),
               "Dart_ClassGetInterfaceCount expects argument 'clazz' to be of "
               "type Class.");
  EXPECT_ERROR(Dart_ClassGetInterfaceCount(Dart_NewApiError("MyError"), &len),
               "MyError");
}


static void TestFieldOk(Dart_Handle container,
                        Dart_Handle name,
                        bool final,
                        const char* initial_value) {
  Dart_Handle result;

  // Make sure we have the right initial value.
  result = Dart_GetField(container, name);
  EXPECT_VALID(result);
  const char* value = "";
  EXPECT_VALID(Dart_StringToCString(result, &value));
  EXPECT_STREQ(initial_value, value);

  // Use a unique expected value.
  static int counter = 0;
  char buffer[256];
  OS::SNPrint(buffer, 256, "Expected%d", ++counter);

  // Try to change the field value.
  result = Dart_SetField(container, name, NewString(buffer));
  if (final) {
    EXPECT(Dart_IsError(result));
  } else {
    EXPECT_VALID(result);
  }

  // Make sure we have the right final value.
  result = Dart_GetField(container, name);
  EXPECT_VALID(result);
  EXPECT_VALID(Dart_StringToCString(result, &value));
  if (final) {
    EXPECT_STREQ(initial_value, value);
  } else {
    EXPECT_STREQ(buffer, value);
  }
}


static void TestFieldNotFound(Dart_Handle container,
                              Dart_Handle name) {
  EXPECT(Dart_IsError(Dart_GetField(container, name)));
  EXPECT(Dart_IsError(Dart_SetField(container, name, Dart_Null())));
}


TEST_CASE(FieldAccess) {
  const char* kScriptChars =
      "class BaseFields {\n"
      "  BaseFields()\n"
      "    : this.inherited_fld = 'inherited' {\n"
      "  }\n"
      "  var inherited_fld;\n"
      "  static var non_inherited_fld;\n"
      "}\n"
      "\n"
      "class Fields extends BaseFields {\n"
      "  Fields()\n"
      "    : this.instance_fld = 'instance',\n"
      "      this._instance_fld = 'hidden instance',\n"
      "      this.final_instance_fld = 'final instance',\n"
      "      this._final_instance_fld = 'hidden final instance' {\n"
      "    instance_getset_fld = 'instance getset';\n"
      "    _instance_getset_fld = 'hidden instance getset';\n"
      "  }\n"
      "\n"
      "  static Init() {\n"
      "    static_fld = 'static';\n"
      "    _static_fld = 'hidden static';\n"
      "    static_getset_fld = 'static getset';\n"
      "    _static_getset_fld = 'hidden static getset';\n"
      "  }\n"
      "\n"
      "  var instance_fld;\n"
      "  var _instance_fld;\n"
      "  final final_instance_fld;\n"
      "  final _final_instance_fld;\n"
      "  static var static_fld;\n"
      "  static var _static_fld;\n"
      "  static const const_static_fld = 'const static';\n"
      "  static const _const_static_fld = 'hidden const static';\n"
      "\n"
      "  get instance_getset_fld { return _gs_fld1; }\n"
      "  void set instance_getset_fld(var value) { _gs_fld1 = value; }\n"
      "  get _instance_getset_fld { return _gs_fld2; }\n"
      "  void set _instance_getset_fld(var value) { _gs_fld2 = value; }\n"
      "  var _gs_fld1;\n"
      "  var _gs_fld2;\n"
      "\n"
      "  static get static_getset_fld { return _gs_fld3; }\n"
      "  static void set static_getset_fld(var value) { _gs_fld3 = value; }\n"
      "  static get _static_getset_fld { return _gs_fld4; }\n"
      "  static void set _static_getset_fld(var value) { _gs_fld4 = value; }\n"
      "  static var _gs_fld3;\n"
      "  static var _gs_fld4;\n"
      "}\n"
      "var top_fld;\n"
      "var _top_fld;\n"
      "const const_top_fld = 'const top';\n"
      "const _const_top_fld = 'hidden const top';\n"
      "\n"
      "get top_getset_fld { return _gs_fld5; }\n"
      "void set top_getset_fld(var value) { _gs_fld5 = value; }\n"
      "get _top_getset_fld { return _gs_fld6; }\n"
      "void set _top_getset_fld(var value) { _gs_fld6 = value; }\n"
      "var _gs_fld5;\n"
      "var _gs_fld6;\n"
      "\n"
      "Fields test() {\n"
      "  Fields.Init();\n"
      "  top_fld = 'top';\n"
      "  _top_fld = 'hidden top';\n"
      "  top_getset_fld = 'top getset';\n"
      "  _top_getset_fld = 'hidden top getset';\n"
      "  return new Fields();\n"
      "}\n";
  const char* kImportedScriptChars =
      "library library_name;\n"
      "var imported_fld = 'imported';\n"
      "var _imported_fld = 'hidden imported';\n"
      "get imported_getset_fld { return _gs_fld1; }\n"
      "void set imported_getset_fld(var value) { _gs_fld1 = value; }\n"
      "get _imported_getset_fld { return _gs_fld2; }\n"
      "void set _imported_getset_fld(var value) { _gs_fld2 = value; }\n"
      "var _gs_fld1;\n"
      "var _gs_fld2;\n"
      "void test2() {\n"
      "  imported_getset_fld = 'imported getset';\n"
      "  _imported_getset_fld = 'hidden imported getset';\n"
      "}\n";

  // Shared setup.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);
  Dart_Handle cls = Dart_GetClass(lib, NewString("Fields"));
  EXPECT_VALID(cls);
  Dart_Handle instance = Dart_Invoke(lib, NewString("test"), 0, NULL);
  EXPECT_VALID(instance);
  Dart_Handle name;

  // Load imported lib.
  Dart_Handle url = NewString("library_url");
  Dart_Handle source = NewString(kImportedScriptChars);
  Dart_Handle imported_lib = Dart_LoadLibrary(url, source);
  Dart_Handle prefix = NewString("");
  EXPECT_VALID(imported_lib);
  Dart_Handle result = Dart_LibraryImportLibrary(lib, imported_lib, prefix);
  EXPECT_VALID(result);
  result = Dart_Invoke(imported_lib, NewString("test2"), 0, NULL);
  EXPECT_VALID(result);

  // Instance field.
  name = NewString("instance_fld");
  TestFieldNotFound(lib, name);
  TestFieldNotFound(cls, name);
  TestFieldOk(instance, name, false, "instance");

  // Hidden instance field.
  name = NewString("_instance_fld");
  TestFieldNotFound(lib, name);
  TestFieldNotFound(cls, name);
  TestFieldOk(instance, name, false, "hidden instance");

  // Final instance field.
  name = NewString("final_instance_fld");
  TestFieldNotFound(lib, name);
  TestFieldNotFound(cls, name);
  TestFieldOk(instance, name, true, "final instance");

  // Hidden final instance field.
  name = NewString("_final_instance_fld");
  TestFieldNotFound(lib, name);
  TestFieldNotFound(cls, name);
  TestFieldOk(instance, name, true, "hidden final instance");

  // Inherited field.
  name = NewString("inherited_fld");
  TestFieldNotFound(lib, name);
  TestFieldNotFound(cls, name);
  TestFieldOk(instance, name, false, "inherited");

  // Instance get/set field.
  name = NewString("instance_getset_fld");
  TestFieldNotFound(lib, name);
  TestFieldNotFound(cls, name);
  TestFieldOk(instance, name, false, "instance getset");

  // Hidden instance get/set field.
  name = NewString("_instance_getset_fld");
  TestFieldNotFound(lib, name);
  TestFieldNotFound(cls, name);
  TestFieldOk(instance, name, false, "hidden instance getset");

  // Static field.
  name = NewString("static_fld");
  TestFieldNotFound(lib, name);
  TestFieldNotFound(instance, name);
  TestFieldOk(cls, name, false, "static");

  // Hidden static field.
  name = NewString("_static_fld");
  TestFieldNotFound(lib, name);
  TestFieldNotFound(instance, name);
  TestFieldOk(cls, name, false, "hidden static");

  // Static final field.
  name = NewString("const_static_fld");
  TestFieldNotFound(lib, name);
  TestFieldNotFound(instance, name);
  TestFieldOk(cls, name, true, "const static");

  // Hidden static const field.
  name = NewString("_const_static_fld");
  TestFieldNotFound(lib, name);
  TestFieldNotFound(instance, name);
  TestFieldOk(cls, name, true, "hidden const static");

  // Static non-inherited field.  Not found at any level.
  name = NewString("non_inherited_fld");
  TestFieldNotFound(lib, name);
  TestFieldNotFound(instance, name);
  TestFieldNotFound(cls, name);

  // Static get/set field.
  name = NewString("static_getset_fld");
  TestFieldNotFound(lib, name);
  TestFieldNotFound(instance, name);
  TestFieldOk(cls, name, false, "static getset");

  // Hidden static get/set field.
  name = NewString("_static_getset_fld");
  TestFieldNotFound(lib, name);
  TestFieldNotFound(instance, name);
  TestFieldOk(cls, name, false, "hidden static getset");

  // Top-Level field.
  name = NewString("top_fld");
  TestFieldNotFound(cls, name);
  TestFieldNotFound(instance, name);
  TestFieldOk(lib, name, false, "top");

  // Hidden top-level field.
  name = NewString("_top_fld");
  TestFieldNotFound(cls, name);
  TestFieldNotFound(instance, name);
  TestFieldOk(lib, name, false, "hidden top");

  // Top-Level final field.
  name = NewString("const_top_fld");
  TestFieldNotFound(cls, name);
  TestFieldNotFound(instance, name);
  TestFieldOk(lib, name, true, "const top");

  // Hidden top-level final field.
  name = NewString("_const_top_fld");
  TestFieldNotFound(cls, name);
  TestFieldNotFound(instance, name);
  TestFieldOk(lib, name, true, "hidden const top");

  // Top-Level get/set field.
  name = NewString("top_getset_fld");
  TestFieldNotFound(cls, name);
  TestFieldNotFound(instance, name);
  TestFieldOk(lib, name, false, "top getset");

  // Hidden top-level get/set field.
  name = NewString("_top_getset_fld");
  TestFieldNotFound(cls, name);
  TestFieldNotFound(instance, name);
  TestFieldOk(lib, name, false, "hidden top getset");

  // Imported top-Level field.
  name = NewString("imported_fld");
  TestFieldNotFound(cls, name);
  TestFieldNotFound(instance, name);
  TestFieldOk(lib, name, false, "imported");

  // Hidden imported top-level field.  Not found at any level.
  name = NewString("_imported_fld");
  TestFieldNotFound(cls, name);
  TestFieldNotFound(instance, name);
  TestFieldNotFound(lib, name);

  // Imported top-Level get/set field.
  name = NewString("imported_getset_fld");
  TestFieldNotFound(cls, name);
  TestFieldNotFound(instance, name);
  TestFieldOk(lib, name, false, "imported getset");

  // Hidden imported top-level get/set field.  Not found at any level.
  name = NewString("_imported_getset_fld");
  TestFieldNotFound(cls, name);
  TestFieldNotFound(instance, name);
  TestFieldNotFound(lib, name);
}


TEST_CASE(SetField_FunnyValue) {
  const char* kScriptChars =
      "var top;\n";

  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);
  Dart_Handle name = NewString("top");
  bool value;

  // Test that you can set the field to a good value.
  EXPECT_VALID(Dart_SetField(lib, name, Dart_True()));
  Dart_Handle result = Dart_GetField(lib, name);
  EXPECT_VALID(result);
  EXPECT(Dart_IsBoolean(result));
  EXPECT_VALID(Dart_BooleanValue(result, &value));
  EXPECT(value);

  // Test that you can set the field to null
  EXPECT_VALID(Dart_SetField(lib, name, Dart_Null()));
  result = Dart_GetField(lib, name);
  EXPECT_VALID(result);
  EXPECT(Dart_IsNull(result));

  // Pass a non-instance handle.
  result = Dart_SetField(lib, name, lib);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_SetField expects argument 'value' to be of type Instance.",
               Dart_GetError(result));

  // Pass an error handle.  The error is contagious.
  result = Dart_SetField(lib, name, Api::NewError("myerror"));
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("myerror", Dart_GetError(result));
}


void NativeFieldLookup(Dart_NativeArguments args) {
  UNREACHABLE();
}


static Dart_NativeFunction native_field_lookup(Dart_Handle name,
                                               int argument_count) {
  return reinterpret_cast<Dart_NativeFunction>(&NativeFieldLookup);
}


TEST_CASE(InjectNativeFields1) {
  const char* kScriptChars =
      "class NativeFields extends NativeFieldsWrapper {\n"
      "  NativeFields(int i, int j) : fld1 = i, fld2 = j {}\n"
      "  int fld1;\n"
      "  final int fld2;\n"
      "  static int fld3;\n"
      "  static const int fld4 = 10;\n"
      "}\n"
      "NativeFields testMain() {\n"
      "  NativeFields obj = new NativeFields(10, 20);\n"
      "  return obj;\n"
      "}\n";
  Dart_Handle result;

  const int kNumNativeFields = 4;

  // Create a test library.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars,
                                             native_field_lookup);

  // Create a native wrapper class with native fields.
  result = Dart_CreateNativeWrapperClass(
      lib,
      NewString("NativeFieldsWrapper"),
      kNumNativeFields);

  // Load up a test script in the test library.

  // Invoke a function which returns an object of type NativeFields.
  result = Dart_Invoke(lib, NewString("testMain"), 0, NULL);
  EXPECT_VALID(result);
  DARTSCOPE(Isolate::Current());
  Instance& obj = Instance::Handle();
  obj ^= Api::UnwrapHandle(result);
  const Class& cls = Class::Handle(obj.clazz());
  // We expect the newly created "NativeFields" object to have
  // 2 dart instance fields (fld1, fld2) and a reference to the native fields.
  // Hence the size of an instance of "NativeFields" should be
  // (1 + 2) * kWordSize + size of object header.
  // We check to make sure the instance size computed by the VM matches
  // our expectations.
  intptr_t header_size = sizeof(RawObject);
  EXPECT_EQ(Utils::RoundUp(((1 + 2) * kWordSize) + header_size,
                           kObjectAlignment),
            cls.instance_size());
  EXPECT_EQ(kNumNativeFields, cls.num_native_fields());
}


TEST_CASE(InjectNativeFields2) {
  const char* kScriptChars =
      "class NativeFields extends NativeFieldsWrapper {\n"
      "  NativeFields(int i, int j) : fld1 = i, fld2 = j {}\n"
      "  int fld1;\n"
      "  final int fld2;\n"
      "  static int fld3;\n"
      "  static const int fld4 = 10;\n"
      "}\n"
      "NativeFields testMain() {\n"
      "  NativeFields obj = new NativeFields(10, 20);\n"
      "  return obj;\n"
      "}\n";
  Dart_Handle result;
  // Create a test library and Load up a test script in it.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);

  // Invoke a function which returns an object of type NativeFields.
  result = Dart_Invoke(lib, NewString("testMain"), 0, NULL);

  // We expect this to fail as class "NativeFields" extends
  // "NativeFieldsWrapper" and there is no definition of it either
  // in the dart code or through the native field injection mechanism.
  EXPECT(Dart_IsError(result));
}


TEST_CASE(InjectNativeFields3) {
  const char* kScriptChars =
      "import 'dart:nativewrappers';"
      "class NativeFields extends NativeFieldWrapperClass2 {\n"
      "  NativeFields(int i, int j) : fld1 = i, fld2 = j {}\n"
      "  int fld1;\n"
      "  final int fld2;\n"
      "  static int fld3;\n"
      "  static const int fld4 = 10;\n"
      "}\n"
      "NativeFields testMain() {\n"
      "  NativeFields obj = new NativeFields(10, 20);\n"
      "  return obj;\n"
      "}\n";
  Dart_Handle result;
  const int kNumNativeFields = 2;

  // Load up a test script in the test library.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars,
                                             native_field_lookup);

  // Invoke a function which returns an object of type NativeFields.
  result = Dart_Invoke(lib, NewString("testMain"), 0, NULL);
  EXPECT_VALID(result);
  DARTSCOPE(Isolate::Current());
  Instance& obj = Instance::Handle();
  obj ^= Api::UnwrapHandle(result);
  const Class& cls = Class::Handle(obj.clazz());
  // We expect the newly created "NativeFields" object to have
  // 2 dart instance fields (fld1, fld2) and a reference to the native fields.
  // Hence the size of an instance of "NativeFields" should be
  // (1 + 2) * kWordSize + size of object header.
  // We check to make sure the instance size computed by the VM matches
  // our expectations.
  intptr_t header_size = sizeof(RawObject);
  EXPECT_EQ(Utils::RoundUp(((1 + 2) * kWordSize) + header_size,
                           kObjectAlignment),
            cls.instance_size());
  EXPECT_EQ(kNumNativeFields, cls.num_native_fields());
}


TEST_CASE(InjectNativeFields4) {
  const char* kScriptChars =
      "import 'dart:nativewrappers';"
      "class NativeFields extends NativeFieldWrapperClass2 {\n"
      "  NativeFields(int i, int j) : fld1 = i, fld2 = j {}\n"
      "  int fld1;\n"
      "  final int fld2;\n"
      "  static int fld3;\n"
      "  static const int fld4 = 10;\n"
      "}\n"
      "NativeFields testMain() {\n"
      "  NativeFields obj = new NativeFields(10, 20);\n"
      "  return obj;\n"
      "}\n";
  Dart_Handle result;
  // Load up a test script in the test library.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);

  // Invoke a function which returns an object of type NativeFields.
  result = Dart_Invoke(lib, NewString("testMain"), 0, NULL);

  // We expect the test script to fail finalization with the error below:
  EXPECT(Dart_IsError(result));
  Dart_Handle expected_error = Dart_Error(
      "'dart:test-lib': Error: line 1 pos 36: "
      "class 'NativeFields' is trying to extend a native fields class, "
      "but library '%s' has no native resolvers",
      TestCase::url());
  EXPECT_SUBSTRING(Dart_GetError(expected_error), Dart_GetError(result));
}


TEST_CASE(InjectNativeFieldsSuperClass) {
  const char* kScriptChars =
      "import 'dart:nativewrappers';"
      "class NativeFieldsSuper extends NativeFieldWrapperClass1 {\n"
      "  NativeFieldsSuper() : fld1 = 42 {}\n"
      "  int fld1;\n"
      "}\n"
      "class NativeFields extends NativeFieldsSuper {\n"
      "  fld() => fld1;\n"
      "}\n"
      "int testMain() {\n"
      "  NativeFields obj = new NativeFields();\n"
      "  return obj.fld();\n"
      "}\n";
  Dart_Handle result;
  // Load up a test script in the test library.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, native_field_lookup);

  // Invoke a function which returns an object of type NativeFields.
  result = Dart_Invoke(lib, NewString("testMain"), 0, NULL);

  EXPECT_VALID(result);
  EXPECT(Dart_IsInteger(result));
  int64_t value = 0;
  result = Dart_IntegerToInt64(result, &value);
  EXPECT_VALID(result);
  EXPECT_EQ(42, value);
}


static void TestNativeFields(Dart_Handle retobj) {
  // Access and set various instance fields of the object.
  Dart_Handle result = Dart_GetField(retobj, NewString("fld3"));
  EXPECT(Dart_IsError(result));
  result = Dart_GetField(retobj, NewString("fld0"));
  EXPECT_VALID(result);
  EXPECT(Dart_IsNull(result));
  result = Dart_GetField(retobj, NewString("fld1"));
  EXPECT_VALID(result);
  int64_t value = 0;
  result = Dart_IntegerToInt64(result, &value);
  EXPECT_EQ(10, value);
  result = Dart_GetField(retobj, NewString("fld2"));
  EXPECT_VALID(result);
  result = Dart_IntegerToInt64(result, &value);
  EXPECT_EQ(20, value);
  result = Dart_SetField(retobj,
                         NewString("fld2"),
                         Dart_NewInteger(40));
  EXPECT(Dart_IsError(result));
  result = Dart_SetField(retobj,
                         NewString("fld1"),
                         Dart_NewInteger(40));
  EXPECT_VALID(result);
  result = Dart_GetField(retobj, NewString("fld1"));
  EXPECT_VALID(result);
  result = Dart_IntegerToInt64(result, &value);
  EXPECT_EQ(40, value);

  // Now access and set various native instance fields of the returned object.
  const int kNativeFld0 = 0;
  const int kNativeFld1 = 1;
  const int kNativeFld2 = 2;
  const int kNativeFld3 = 3;
  const int kNativeFld4 = 4;
  int field_count = 0;
  intptr_t field_value = 0;
  EXPECT_VALID(Dart_GetNativeInstanceFieldCount(retobj, &field_count));
  EXPECT_EQ(4, field_count);
  result = Dart_GetNativeInstanceField(retobj, kNativeFld4, &field_value);
  EXPECT(Dart_IsError(result));
  result = Dart_GetNativeInstanceField(retobj, kNativeFld0, &field_value);
  EXPECT_VALID(result);
  EXPECT_EQ(0, field_value);
  result = Dart_GetNativeInstanceField(retobj, kNativeFld1, &field_value);
  EXPECT_VALID(result);
  EXPECT_EQ(0, field_value);
  result = Dart_GetNativeInstanceField(retobj, kNativeFld2, &field_value);
  EXPECT_VALID(result);
  EXPECT_EQ(0, field_value);
  result = Dart_GetNativeInstanceField(retobj, kNativeFld3, &field_value);
  EXPECT_VALID(result);
  EXPECT_EQ(0, field_value);
  result = Dart_SetNativeInstanceField(retobj, kNativeFld4, 40);
  EXPECT(Dart_IsError(result));
  result = Dart_SetNativeInstanceField(retobj, kNativeFld0, 4);
  EXPECT_VALID(result);
  result = Dart_SetNativeInstanceField(retobj, kNativeFld1, 40);
  EXPECT_VALID(result);
  result = Dart_SetNativeInstanceField(retobj, kNativeFld2, 400);
  EXPECT_VALID(result);
  result = Dart_SetNativeInstanceField(retobj, kNativeFld3, 4000);
  EXPECT_VALID(result);
  result = Dart_GetNativeInstanceField(retobj, kNativeFld3, &field_value);
  EXPECT_VALID(result);
  EXPECT_EQ(4000, field_value);

  // Now re-access various dart instance fields of the returned object
  // to ensure that there was no corruption while setting native fields.
  result = Dart_GetField(retobj, NewString("fld1"));
  EXPECT_VALID(result);
  result = Dart_IntegerToInt64(result, &value);
  EXPECT_EQ(40, value);
  result = Dart_GetField(retobj, NewString("fld2"));
  EXPECT_VALID(result);
  result = Dart_IntegerToInt64(result, &value);
  EXPECT_EQ(20, value);
}


TEST_CASE(NativeFieldAccess) {
  const char* kScriptChars =
      "class NativeFields extends NativeFieldsWrapper {\n"
      "  NativeFields(int i, int j) : fld1 = i, fld2 = j {}\n"
      "  int fld0;\n"
      "  int fld1;\n"
      "  final int fld2;\n"
      "  static int fld3;\n"
      "  static const int fld4 = 10;\n"
      "}\n"
      "NativeFields testMain() {\n"
      "  NativeFields obj = new NativeFields(10, 20);\n"
      "  return obj;\n"
      "}\n";
  const int kNumNativeFields = 4;

  // Create a test library.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars,
                                             native_field_lookup);

  // Create a native wrapper class with native fields.
  Dart_Handle result = Dart_CreateNativeWrapperClass(
      lib,
      NewString("NativeFieldsWrapper"),
      kNumNativeFields);
  EXPECT_VALID(result);

  // Load up a test script in it.

  // Invoke a function which returns an object of type NativeFields.
  Dart_Handle retobj = Dart_Invoke(lib, NewString("testMain"), 0, NULL);
  EXPECT_VALID(retobj);

  // Now access and set various instance fields of the returned object.
  TestNativeFields(retobj);

  // Test that accessing an error handle propagates the error.
  Dart_Handle error = Api::NewError("myerror");
  intptr_t field_value = 0;

  result = Dart_GetNativeInstanceField(error, 0, &field_value);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("myerror", Dart_GetError(result));

  result = Dart_SetNativeInstanceField(error, 0, 1);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("myerror", Dart_GetError(result));
}


TEST_CASE(ImplicitNativeFieldAccess) {
  const char* kScriptChars =
      "import 'dart:nativewrappers';"
      "class NativeFields extends NativeFieldWrapperClass4 {\n"
      "  NativeFields(int i, int j) : fld1 = i, fld2 = j {}\n"
      "  int fld0;\n"
      "  int fld1;\n"
      "  final int fld2;\n"
      "  static int fld3;\n"
      "  static const int fld4 = 10;\n"
      "}\n"
      "NativeFields testMain() {\n"
      "  NativeFields obj = new NativeFields(10, 20);\n"
      "  return obj;\n"
      "}\n";
  // Load up a test script in the test library.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars,
                                             native_field_lookup);

  // Invoke a function which returns an object of type NativeFields.
  Dart_Handle retobj = Dart_Invoke(lib, NewString("testMain"), 0, NULL);
  EXPECT_VALID(retobj);

  // Now access and set various instance fields of the returned object.
  TestNativeFields(retobj);
}


TEST_CASE(NegativeNativeFieldAccess) {
  const char* kScriptChars =
      "class NativeFields {\n"
      "  NativeFields(int i, int j) : fld1 = i, fld2 = j {}\n"
      "  int fld1;\n"
      "  final int fld2;\n"
      "  static int fld3;\n"
      "  static const int fld4 = 10;\n"
      "}\n"
      "NativeFields testMain1() {\n"
      "  NativeFields obj = new NativeFields(10, 20);\n"
      "  return obj;\n"
      "}\n"
      "Function testMain2() {\n"
      "  return () {};\n"
      "}\n";
  Dart_Handle result;
  DARTSCOPE(Isolate::Current());

  // Create a test library and Load up a test script in it.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);

  // Invoke a function which returns an object of type NativeFields.
  Dart_Handle retobj = Dart_Invoke(lib, NewString("testMain1"), 0, NULL);
  EXPECT_VALID(retobj);

  // Now access and set various native instance fields of the returned object.
  // All of these tests are expected to return failure as there are no
  // native fields in an instance of NativeFields.
  const int kNativeFld0 = 0;
  const int kNativeFld1 = 1;
  const int kNativeFld2 = 2;
  const int kNativeFld3 = 3;
  const int kNativeFld4 = 4;
  intptr_t value = 0;
  result = Dart_GetNativeInstanceField(retobj, kNativeFld4, &value);
  EXPECT(Dart_IsError(result));
  result = Dart_GetNativeInstanceField(retobj, kNativeFld0, &value);
  EXPECT(Dart_IsError(result));
  result = Dart_GetNativeInstanceField(retobj, kNativeFld1, &value);
  EXPECT(Dart_IsError(result));
  result = Dart_GetNativeInstanceField(retobj, kNativeFld2, &value);
  EXPECT(Dart_IsError(result));
  result = Dart_SetNativeInstanceField(retobj, kNativeFld4, 40);
  EXPECT(Dart_IsError(result));
  result = Dart_SetNativeInstanceField(retobj, kNativeFld3, 40);
  EXPECT(Dart_IsError(result));
  result = Dart_SetNativeInstanceField(retobj, kNativeFld0, 400);
  EXPECT(Dart_IsError(result));

  // Invoke a function which returns a closure object.
  retobj = Dart_Invoke(lib, NewString("testMain2"), 0, NULL);
  EXPECT_VALID(retobj);

  result = Dart_GetNativeInstanceField(retobj, kNativeFld4, &value);
  EXPECT(Dart_IsError(result));
  result = Dart_GetNativeInstanceField(retobj, kNativeFld0, &value);
  EXPECT(Dart_IsError(result));
  result = Dart_GetNativeInstanceField(retobj, kNativeFld1, &value);
  EXPECT(Dart_IsError(result));
  result = Dart_GetNativeInstanceField(retobj, kNativeFld2, &value);
  EXPECT(Dart_IsError(result));
  result = Dart_SetNativeInstanceField(retobj, kNativeFld4, 40);
  EXPECT(Dart_IsError(result));
  result = Dart_SetNativeInstanceField(retobj, kNativeFld3, 40);
  EXPECT(Dart_IsError(result));
  result = Dart_SetNativeInstanceField(retobj, kNativeFld0, 400);
  EXPECT(Dart_IsError(result));
}


TEST_CASE(NegativeNativeFieldInIsolateMessage) {
  const char* kScriptChars =
      "import 'dart:isolate';\n"
      "import 'dart:nativewrappers';\n"
      "echo() {\n"
      "  port.receive((msg, reply) {\n"
      "    reply.send('echoing ${msg(1)}}');\n"
      "  });\n"
      "}\n"
      "class Test extends NativeFieldWrapperClass2 {\n"
      "  Test(this.i, this.j);\n"
      "  int i, j;\n"
      "}\n"
      "main() {\n"
      "  var snd = spawnFunction(echo);\n"
      "  var obj = new Test(1,2);\n"
      "  snd.send(obj, port.toSendPort());\n"
      "  port.receive((msg, reply) {\n"
      "    print('from worker ${msg}');\n"
      "  });\n"
      "}\n";

  DARTSCOPE(Isolate::Current());

  // Create a test library and Load up a test script in it.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);

  // Invoke 'main' which should spawn an isolate and try to send an
  // object with native fields over to the spawned isolate. This
  // should result in an unhandled exception which is checked.
  Dart_Handle retobj = Dart_Invoke(lib, NewString("main"), 0, NULL);
  EXPECT(Dart_IsError(retobj));
}


TEST_CASE(GetStaticField_RunsInitializer) {
  const char* kScriptChars =
      "class TestClass  {\n"
      "  static const int fld1 = 7;\n"
      "  static int fld2 = 11;\n"
      "  static void testMain() {\n"
      "  }\n"
      "}\n";
  Dart_Handle result;
  // Create a test library and Load up a test script in it.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);
  Dart_Handle cls = Dart_GetClass(lib, NewString("TestClass"));
  EXPECT_VALID(cls);

  // Invoke a function which returns an object.
  result = Dart_Invoke(cls, NewString("testMain"), 0, NULL);
  EXPECT_VALID(result);

  // For uninitialized fields, the getter is returned
  result = Dart_GetField(cls, NewString("fld1"));
  EXPECT_VALID(result);
  int64_t value = 0;
  result = Dart_IntegerToInt64(result, &value);
  EXPECT_EQ(7, value);

  result = Dart_GetField(cls, NewString("fld2"));
  EXPECT_VALID(result);
  result = Dart_IntegerToInt64(result, &value);
  EXPECT_EQ(11, value);

  // Overwrite fld2
  result = Dart_SetField(cls,
                         NewString("fld2"),
                         Dart_NewInteger(13));
  EXPECT_VALID(result);

  // We now get the new value for fld2, not the initializer
  result = Dart_GetField(cls, NewString("fld2"));
  EXPECT_VALID(result);
  result = Dart_IntegerToInt64(result, &value);
  EXPECT_EQ(13, value);
}


TEST_CASE(New) {
  const char* kScriptChars =
      "class MyClass {\n"
      "  MyClass() : foo = 7 {}\n"
      "  MyClass.named(value) : foo = value {}\n"
      "  MyClass._hidden(value) : foo = -value {}\n"
      "  MyClass.exception(value) : foo = value {\n"
      "    throw 'ConstructorDeath';\n"
      "  }\n"
      "  factory MyClass.multiply(value) {\n"
      "    return new MyClass.named(value * 100);\n"
      "  }\n"
      "  factory MyClass.nullo() {\n"
      "    return null;\n"
      "  }\n"
      "  var foo;\n"
      "}\n"
      "\n"
      "abstract class MyExtraHop {\n"
      "  factory MyExtraHop.hop(value) = MyClass.named;\n"
      "}\n"
      "\n"
      "abstract class MyInterface {\n"
      "  factory MyInterface.named(value) = MyExtraHop.hop;\n"
      "  factory MyInterface.multiply(value) = MyClass.multiply;\n"
      "  MyInterface.notfound(value);\n"
      "}\n";

  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);
  Dart_Handle cls = Dart_GetClass(lib, NewString("MyClass"));
  EXPECT_VALID(cls);
  Dart_Handle intf = Dart_GetClass(lib, NewString("MyInterface"));
  EXPECT_VALID(intf);
  Dart_Handle args[1];
  args[0] = Dart_NewInteger(11);
  Dart_Handle bad_args[1];
  bad_args[0] = Dart_Error("myerror");

  // Invoke the unnamed constructor.
  Dart_Handle result = Dart_New(cls, Dart_Null(), 0, NULL);
  EXPECT_VALID(result);
  bool instanceof = false;
  EXPECT_VALID(Dart_ObjectIsType(result, cls, &instanceof));
  EXPECT(instanceof);
  int64_t int_value = 0;
  Dart_Handle foo = Dart_GetField(result, NewString("foo"));
  EXPECT_VALID(Dart_IntegerToInt64(foo, &int_value));
  EXPECT_EQ(7, int_value);

  // Invoke the unnamed constructor with an empty string.
  result = Dart_New(cls, NewString(""), 0, NULL);
  EXPECT_VALID(result);
  instanceof = false;
  EXPECT_VALID(Dart_ObjectIsType(result, cls, &instanceof));
  EXPECT(instanceof);
  int_value = 0;
  foo = Dart_GetField(result, NewString("foo"));
  EXPECT_VALID(Dart_IntegerToInt64(foo, &int_value));
  EXPECT_EQ(7, int_value);

  // Invoke a named constructor.
  result = Dart_New(cls, NewString("named"), 1, args);
  EXPECT_VALID(result);
  EXPECT_VALID(Dart_ObjectIsType(result, cls, &instanceof));
  EXPECT(instanceof);
  int_value = 0;
  foo = Dart_GetField(result, NewString("foo"));
  EXPECT_VALID(Dart_IntegerToInt64(foo, &int_value));
  EXPECT_EQ(11, int_value);

  // Invoke a hidden named constructor.
  result = Dart_New(cls, NewString("_hidden"), 1, args);
  EXPECT_VALID(result);
  EXPECT_VALID(Dart_ObjectIsType(result, cls, &instanceof));
  EXPECT(instanceof);
  int_value = 0;
  foo = Dart_GetField(result, NewString("foo"));
  EXPECT_VALID(Dart_IntegerToInt64(foo, &int_value));
  EXPECT_EQ(-11, int_value);

  // Invoke a factory constructor.
  result = Dart_New(cls, NewString("multiply"), 1, args);
  EXPECT_VALID(result);
  EXPECT_VALID(Dart_ObjectIsType(result, cls, &instanceof));
  EXPECT(instanceof);
  int_value = 0;
  foo = Dart_GetField(result, NewString("foo"));
  EXPECT_VALID(Dart_IntegerToInt64(foo, &int_value));
  EXPECT_EQ(1100, int_value);

  // Invoke a factory constructor which returns null.
  result = Dart_New(cls, NewString("nullo"), 0, NULL);
  EXPECT_VALID(result);
  EXPECT(Dart_IsNull(result));

  // Pass an error class object.  Error is passed through.
  result = Dart_New(Dart_Error("myerror"), NewString("named"), 1, args);
  EXPECT_ERROR(result, "myerror");

  // Pass a bad class object.
  result = Dart_New(Dart_Null(), NewString("named"), 1, args);
  EXPECT_ERROR(result, "Dart_New expects argument 'clazz' to be non-null.");

  // Pass a negative arg count.
  result = Dart_New(cls, NewString("named"), -1, args);
  EXPECT_ERROR(
      result,
      "Dart_New expects argument 'number_of_arguments' to be non-negative.");

  // Pass the wrong arg count.
  result = Dart_New(cls, NewString("named"), 0, NULL);
  EXPECT_ERROR(
      result,
      "Dart_New: wrong argument count for constructor 'MyClass.named': "
      "0 passed, 1 expected.");

  // Pass a bad argument.  Error is passed through.
  result = Dart_New(cls, NewString("named"), 1, bad_args);
  EXPECT_ERROR(result, "myerror");

  // Pass a bad constructor name.
  result = Dart_New(cls, Dart_NewInteger(55), 1, args);
  EXPECT_ERROR(
      result,
      "Dart_New expects argument 'constructor_name' to be of type String.");

  // Invoke a missing constructor.
  result = Dart_New(cls, NewString("missing"), 1, args);
  EXPECT_ERROR(result,
               "Dart_New: could not find constructor 'MyClass.missing'.");

  // Invoke a constructor which throws an exception.
  result = Dart_New(cls, NewString("exception"), 1, args);
  EXPECT_ERROR(result, "ConstructorDeath");

  // Invoke two-hop redirecting factory constructor.
  result = Dart_New(intf, NewString("named"), 1, args);
  EXPECT_VALID(result);
  EXPECT_VALID(Dart_ObjectIsType(result, cls, &instanceof));
  EXPECT(instanceof);
  int_value = 0;
  foo = Dart_GetField(result, NewString("foo"));
  EXPECT_VALID(Dart_IntegerToInt64(foo, &int_value));
  EXPECT_EQ(11, int_value);

  // Invoke one-hop redirecting factory constructor.
  result = Dart_New(intf, NewString("multiply"), 1, args);
  EXPECT_VALID(result);
  EXPECT_VALID(Dart_ObjectIsType(result, cls, &instanceof));
  EXPECT(instanceof);
  int_value = 0;
  foo = Dart_GetField(result, NewString("foo"));
  EXPECT_VALID(Dart_IntegerToInt64(foo, &int_value));
  EXPECT_EQ(1100, int_value);

  // Invoke a constructor that is missing in the interface.
  result = Dart_New(intf, Dart_Null(), 0, NULL);
  EXPECT_ERROR(result,
               "Dart_New: could not find constructor 'MyInterface.'.");

  // Invoke abstract constructor that is present in the interface.
  result = Dart_New(intf, NewString("notfound"), 1, args);
  EXPECT_VALID(result);
  EXPECT_VALID(Dart_ObjectIsType(result, cls, &instanceof));
  EXPECT(!instanceof);
}


TEST_CASE(New_Issue2971) {
  // Issue 2971: We were unable to use Dart_New to construct an
  // instance of List, due to problems implementing interface
  // factories.
  Dart_Handle core_lib = Dart_LookupLibrary(NewString("dart:core"));
  EXPECT_VALID(core_lib);
  Dart_Handle list_class = Dart_GetClass(core_lib, NewString("List"));
  EXPECT_VALID(list_class);

  const int kNumArgs = 1;
  Dart_Handle args[kNumArgs];
  args[0] = Dart_NewInteger(1);
  Dart_Handle list_obj = Dart_New(list_class, Dart_Null(), kNumArgs, args);
  EXPECT_VALID(list_obj);
  EXPECT(Dart_IsList(list_obj));
}


static Dart_Handle PrivateLibName(Dart_Handle lib, const char* str) {
  EXPECT(Dart_IsLibrary(lib));
  Isolate* isolate = Isolate::Current();
  const Library& library_obj = Api::UnwrapLibraryHandle(isolate, lib);
  const String& name = String::Handle(String::New(str));
  return Api::NewHandle(isolate, library_obj.PrivateName(name));
}


TEST_CASE(Invoke) {
  const char* kScriptChars =
      "class BaseMethods {\n"
      "  inheritedMethod(arg) => 'inherited $arg';\n"
      "  static nonInheritedMethod(arg) => 'noninherited $arg';\n"
      "}\n"
      "\n"
      "class Methods extends BaseMethods {\n"
      "  instanceMethod(arg) => 'instance $arg';\n"
      "  _instanceMethod(arg) => 'hidden instance $arg';\n"
      "  static staticMethod(arg) => 'static $arg';\n"
      "  static _staticMethod(arg) => 'hidden static $arg';\n"
      "}\n"
      "\n"
      "topMethod(arg) => 'top $arg';\n"
      "_topMethod(arg) => 'hidden top $arg';\n"
      "\n"
      "Methods test() {\n"
      "  return new Methods();\n"
      "}\n";

  // Shared setup.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);
  Dart_Handle cls = Dart_GetClass(lib, NewString("Methods"));
  EXPECT_VALID(cls);
  Dart_Handle instance = Dart_Invoke(lib, NewString("test"), 0, NULL);
  EXPECT_VALID(instance);
  Dart_Handle args[1];
  args[0] = NewString("!!!");
  Dart_Handle bad_args[2];
  bad_args[0] = NewString("bad1");
  bad_args[1] = NewString("bad2");
  Dart_Handle result;
  Dart_Handle name;
  const char* str;

  // Instance method.
  name = NewString("instanceMethod");
  EXPECT(Dart_IsError(Dart_Invoke(lib, name, 1, args)));
  EXPECT(Dart_IsError(Dart_Invoke(cls, name, 1, args)));
  result = Dart_Invoke(instance, name, 1, args);
  EXPECT_VALID(result);
  result = Dart_StringToCString(result, &str);
  EXPECT_STREQ("instance !!!", str);

  // Instance method, wrong arg count.
  EXPECT_ERROR(Dart_Invoke(instance, name, 2, bad_args),
               "Class 'Methods' has no instance method 'instanceMethod'"
               " with matching arguments");

  name = PrivateLibName(lib, "_instanceMethod");
  EXPECT(Dart_IsError(Dart_Invoke(lib, name, 1, args)));
  EXPECT(Dart_IsError(Dart_Invoke(cls, name, 1, args)));
  result = Dart_Invoke(instance, name, 1, args);
  EXPECT_VALID(result);
  result = Dart_StringToCString(result, &str);
  EXPECT_STREQ("hidden instance !!!", str);

  // Inherited method.
  name = NewString("inheritedMethod");
  EXPECT(Dart_IsError(Dart_Invoke(lib, name, 1, args)));
  EXPECT(Dart_IsError(Dart_Invoke(cls, name, 1, args)));
  result = Dart_Invoke(instance, name, 1, args);
  EXPECT_VALID(result);
  result = Dart_StringToCString(result, &str);
  EXPECT_STREQ("inherited !!!", str);

  // Static method.
  name = NewString("staticMethod");
  EXPECT(Dart_IsError(Dart_Invoke(lib, name, 1, args)));
  EXPECT(Dart_IsError(Dart_Invoke(instance, name, 1, args)));
  result = Dart_Invoke(cls, name, 1, args);
  EXPECT_VALID(result);
  result = Dart_StringToCString(result, &str);
  EXPECT_STREQ("static !!!", str);

  // Static method, wrong arg count.
  EXPECT_ERROR(Dart_Invoke(cls, name, 2, bad_args),
               "did not find static method 'Methods.staticMethod'");

  // Hidden static method.
  name = PrivateLibName(lib, "_staticMethod");
  EXPECT(Dart_IsError(Dart_Invoke(lib, name, 1, args)));
  EXPECT(Dart_IsError(Dart_Invoke(instance, name, 1, args)));
  result = Dart_Invoke(cls, name, 1, args);
  EXPECT_VALID(result);
  result = Dart_StringToCString(result, &str);
  EXPECT_STREQ("hidden static !!!", str);

  // Static non-inherited method.  Not found at any level.
  name = NewString("non_inheritedMethod");
  EXPECT(Dart_IsError(Dart_Invoke(lib, name, 1, args)));
  EXPECT(Dart_IsError(Dart_Invoke(instance, name, 1, args)));
  EXPECT(Dart_IsError(Dart_Invoke(cls, name, 1, args)));

  // Top-Level method.
  name = NewString("topMethod");
  EXPECT(Dart_IsError(Dart_Invoke(cls, name, 1, args)));
  EXPECT(Dart_IsError(Dart_Invoke(instance, name, 1, args)));
  result = Dart_Invoke(lib, name, 1, args);
  EXPECT_VALID(result);
  result = Dart_StringToCString(result, &str);
  EXPECT_STREQ("top !!!", str);

  // Top-level method, wrong arg count.
  EXPECT_ERROR(Dart_Invoke(lib, name, 2, bad_args),
               "Dart_Invoke: wrong argument count for function 'topMethod': "
               "2 passed, 1 expected.");

  // Hidden top-level method.
  name = PrivateLibName(lib, "_topMethod");
  EXPECT(Dart_IsError(Dart_Invoke(cls, name, 1, args)));
  EXPECT(Dart_IsError(Dart_Invoke(instance, name, 1, args)));
  result = Dart_Invoke(lib, name, 1, args);
  EXPECT_VALID(result);
  result = Dart_StringToCString(result, &str);
  EXPECT_STREQ("hidden top !!!", str);
}


TEST_CASE(Invoke_FunnyArgs) {
  const char* kScriptChars =
      "test(arg) => 'hello $arg';\n";

  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);
  Dart_Handle func_name = NewString("test");
  Dart_Handle args[1];
  const char* str;

  // Make sure that valid args yield valid results.
  args[0] = NewString("!!!");
  Dart_Handle result = Dart_Invoke(lib, func_name, 1, args);
  EXPECT_VALID(result);
  result = Dart_StringToCString(result, &str);
  EXPECT_STREQ("hello !!!", str);

  // Make sure that null is legal.
  args[0] = Dart_Null();
  result = Dart_Invoke(lib, func_name, 1, args);
  EXPECT_VALID(result);
  result = Dart_StringToCString(result, &str);
  EXPECT_STREQ("hello null", str);

  // Pass an error handle as the target.  The error is propagated.
  result = Dart_Invoke(Api::NewError("myerror"),
                       func_name, 1, args);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("myerror", Dart_GetError(result));

  // Pass an error handle as the function name.  The error is propagated.
  result = Dart_Invoke(lib, Api::NewError("myerror"), 1, args);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("myerror", Dart_GetError(result));

  // Pass a non-instance handle as a parameter..
  args[0] = lib;
  result = Dart_Invoke(lib, func_name, 1, args);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_Invoke expects arguments[0] to be an Instance handle.",
               Dart_GetError(result));

  // Pass an error handle as a parameter.  The error is propagated.
  args[0] = Api::NewError("myerror");
  result = Dart_Invoke(lib, func_name, 1, args);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("myerror", Dart_GetError(result));
}


TEST_CASE(Invoke_Null) {
  Dart_Handle result = Dart_Invoke(Dart_Null(),
                                   NewString("toString"),
                                   0,
                                   NULL);
  EXPECT_VALID(result);
  EXPECT(Dart_IsString(result));

  const char* value = "";
  EXPECT_VALID(Dart_StringToCString(result, &value));
  EXPECT_STREQ("null", value);

  Dart_Handle function_name = NewString("NoNoNo");
  result = Dart_Invoke(Dart_Null(),
                       function_name,
                       0,
                       NULL);
  EXPECT(Dart_IsError(result));
  EXPECT(Dart_ErrorHasException(result));
}


TEST_CASE(InvokeNoSuchMethod) {
  const char* kScriptChars =
      "import 'dart:_collection-dev' as _collection_dev;\n"
      "class Expect {\n"
      "  static equals(a, b) {\n"
      "    if (a != b) {\n"
      "      throw 'not equal. expected: $a, got: $b';\n"
      "    }\n"
      "  }\n"
      "}\n"
      "class TestClass {\n"
      "  static int fld1 = 0;\n"
      "  void noSuchMethod(Invocation invocation) {\n"
      "    var name = _collection_dev.Symbol.getName(invocation.memberName);\n"
      "    if (name == 'fld') {\n"
      "      Expect.equals(true, invocation.isGetter);\n"
      "      Expect.equals(false, invocation.isMethod);\n"
      "      Expect.equals(false, invocation.isSetter);\n"
      "    } else if (name == 'setfld') {\n"
      "      Expect.equals(true, invocation.isSetter);\n"
      "      Expect.equals(false, invocation.isMethod);\n"
      "      Expect.equals(false, invocation.isGetter);\n"
      "    } else if (name == 'method') {\n"
      "      Expect.equals(true, invocation.isMethod);\n"
      "      Expect.equals(false, invocation.isSetter);\n"
      "      Expect.equals(false, invocation.isGetter);\n"
      "    }\n"
      "    TestClass.fld1 += 1;\n"
      "  }\n"
      "  static TestClass testMain() {\n"
      "    return new TestClass();\n"
      "  }\n"
      "}\n";
  Dart_Handle result;
  Dart_Handle instance;
  // Create a test library and Load up a test script in it.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);
  Dart_Handle cls = Dart_GetClass(lib, NewString("TestClass"));
  EXPECT_VALID(cls);

  // Invoke a function which returns an object.
  instance = Dart_Invoke(cls, NewString("testMain"), 0, NULL);
  EXPECT_VALID(instance);

  // Try to get a field that does not exist, should call noSuchMethod.
  result = Dart_GetField(instance, NewString("fld"));
  EXPECT_VALID(result);

  // Try to set a field that does not exist, should call noSuchMethod.
  result = Dart_SetField(instance, NewString("setfld"), Dart_NewInteger(13));
  EXPECT_VALID(result);

  // Try to invoke a method that does not exist, should call noSuchMethod.
  result = Dart_Invoke(instance, NewString("method"), 0, NULL);
  EXPECT_VALID(result);

  result = Dart_GetField(cls, NewString("fld1"));
  EXPECT_VALID(result);
  int64_t value = 0;
  result = Dart_IntegerToInt64(result, &value);
  EXPECT_EQ(3, value);
}


TEST_CASE(Invoke_CrossLibrary) {
  const char* kLibrary1Chars =
      "library library1_name;\n"
      "void local() {}\n"
      "void _local() {}\n";
  const char* kLibrary2Chars =
      "library library2_name;\n"
      "void imported() {}\n"
      "void _imported() {}\n";

  // Load lib1
  Dart_Handle url = NewString("library1_url");
  Dart_Handle source = NewString(kLibrary1Chars);
  Dart_Handle lib1 = Dart_LoadLibrary(url, source);
  EXPECT_VALID(lib1);

  // Load lib2
  url = NewString("library2_url");
  source = NewString(kLibrary2Chars);
  Dart_Handle lib2 = Dart_LoadLibrary(url, source);
  EXPECT_VALID(lib2);

  // Import lib2 from lib1
  Dart_Handle result = Dart_LibraryImportLibrary(lib1, lib2, Dart_Null());
  EXPECT_VALID(result);

  // We can invoke both private and non-private local functions.
  EXPECT_VALID(Dart_Invoke(lib1, NewString("local"), 0, NULL));
  EXPECT_VALID(Dart_Invoke(lib1, NewString("_local"), 0, NULL));

  // We can only invoke non-private imported functions.
  EXPECT_VALID(Dart_Invoke(lib1, NewString("imported"), 0, NULL));
  EXPECT_ERROR(Dart_Invoke(lib1, NewString("_imported"), 0, NULL),
               "did not find top-level function '_imported'");
}

TEST_CASE(ClosureFunction) {
  const char* kScriptChars =
      "Function getClosure() {\n"
      "  return (x, y, [z]) => x + y + z;\n"
      "}\n"
      "class Foo {\n"
      "  getInstanceClosure() {\n"
      "    return () { return this; };\n"
      "  }\n"
      "  getInstanceClosureWithArgs() {\n"
      "    return (x, y, [z]) { return this; };\n"
      "  }\n"
      "  static getStaticClosure() {\n"
      "    return () { return 42; };\n"
      "  }\n"
      "  static getStaticClosureWithArgs() {\n"
      "    return (x, y, [z]) { return 42; };\n"
      "  }\n"
      "}\n"
      "Function getInstanceClosure() {\n"
      "  return new Foo().getInstanceClosure();\n"
      "}\n"
      "Function getInstanceClosureWithArgs() {\n"
      "  return new Foo().getInstanceClosureWithArgs();\n"
      "}\n"
      "Function getStaticClosure() {\n"
      "  return Foo.getStaticClosure();\n"
      "}\n"
      "Function getStaticClosureWithArgs() {\n"
      "  return Foo.getStaticClosureWithArgs();\n"
      "}\n";
  Dart_Handle result;
  Dart_Handle owner;
  Dart_Handle defining_function;
  DARTSCOPE(Isolate::Current());

  // Create a test library and Load up a test script in it.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);
  EXPECT_VALID(lib);
  Dart_Handle cls = Dart_GetClass(lib, NewString("Foo"));
  EXPECT_VALID(cls);

  // Invoke a function which returns a closure.
  Dart_Handle retobj = Dart_Invoke(lib, NewString("getClosure"), 0, NULL);
  EXPECT_VALID(retobj);

  EXPECT(Dart_IsClosure(retobj));
  EXPECT(!Dart_IsClosure(Dart_NewInteger(101)));

  // Retrieve the closure's function
  result = Dart_ClosureFunction(retobj);
  EXPECT_VALID(result);
  EXPECT(Dart_IsFunction(result));
  owner = Dart_FunctionOwner(result);
  EXPECT_VALID(owner);
  defining_function = Dart_LookupFunction(lib, NewString("getClosure"));
  EXPECT(Dart_IdentityEquals(owner, defining_function));
  int64_t fixed_param_count = -999;
  int64_t opt_param_count = -999;
  result = Dart_FunctionParameterCounts(result,
                                        &fixed_param_count,
                                        &opt_param_count);
  EXPECT_VALID(result);
  EXPECT_EQ(2, fixed_param_count);
  EXPECT_EQ(1, opt_param_count);

  // Try to retrieve function from a non-closure object
  result = Dart_ClosureFunction(Dart_NewInteger(1));
  EXPECT(Dart_IsError(result));

  // Invoke a function which returns an "instance" closure.
  retobj = Dart_Invoke(lib, NewString("getInstanceClosure"), 0, NULL);
  EXPECT_VALID(retobj);
  EXPECT(Dart_IsClosure(retobj));

  // Retrieve the closure's function
  result = Dart_ClosureFunction(retobj);
  EXPECT_VALID(result);
  EXPECT(Dart_IsFunction(result));
  owner = Dart_FunctionOwner(result);
  EXPECT_VALID(owner);
  defining_function = Dart_LookupFunction(cls,
                                          NewString("getInstanceClosure"));
  EXPECT(Dart_IdentityEquals(owner, defining_function));
  // -999: We want to distinguish between a non-answer and a wrong answer, and
  // -1 has been a previous wrong answer
  fixed_param_count = -999;
  opt_param_count = -999;
  result = Dart_FunctionParameterCounts(result,
                                        &fixed_param_count,
                                        &opt_param_count);
  EXPECT_VALID(result);
  EXPECT_EQ(0, fixed_param_count);
  EXPECT_EQ(0, opt_param_count);

  // Invoke a function which returns an "instance" closure with arguments.
  retobj = Dart_Invoke(lib,
                       NewString("getInstanceClosureWithArgs"),
                       0,
                       NULL);
  EXPECT_VALID(retobj);
  EXPECT(Dart_IsClosure(retobj));

  // Retrieve the closure's function
  result = Dart_ClosureFunction(retobj);
  EXPECT_VALID(result);
  EXPECT(Dart_IsFunction(result));
  owner = Dart_FunctionOwner(result);
  EXPECT_VALID(owner);
  defining_function =
      Dart_LookupFunction(cls, NewString("getInstanceClosureWithArgs"));
  EXPECT(Dart_IdentityEquals(owner, defining_function));
  // -999: We want to distinguish between a non-answer and a wrong answer, and
  // -1 has been a previous wrong answer
  fixed_param_count = -999;
  opt_param_count = -999;
  result = Dart_FunctionParameterCounts(result,
                                        &fixed_param_count,
                                        &opt_param_count);
  EXPECT_VALID(result);
  EXPECT_EQ(2, fixed_param_count);
  EXPECT_EQ(1, opt_param_count);

  // Invoke a function which returns a "static" closure.
  retobj = Dart_Invoke(lib, NewString("getStaticClosure"), 0, NULL);
  EXPECT_VALID(retobj);
  EXPECT(Dart_IsClosure(retobj));

  // Retrieve the closure's function
  result = Dart_ClosureFunction(retobj);
  EXPECT_VALID(result);
  EXPECT(Dart_IsFunction(result));
  owner = Dart_FunctionOwner(result);
  EXPECT_VALID(owner);
  defining_function = Dart_LookupFunction(cls,
                                          NewString("getStaticClosure"));
  EXPECT(Dart_IdentityEquals(owner, defining_function));
  // -999: We want to distinguish between a non-answer and a wrong answer, and
  // -1 has been a previous wrong answer
  fixed_param_count = -999;
  opt_param_count = -999;
  result = Dart_FunctionParameterCounts(result,
                                        &fixed_param_count,
                                        &opt_param_count);
  EXPECT_VALID(result);
  EXPECT_EQ(0, fixed_param_count);
  EXPECT_EQ(0, opt_param_count);


  // Invoke a function which returns a "static" closure with arguments.
  retobj = Dart_Invoke(lib,
                       NewString("getStaticClosureWithArgs"),
                       0,
                       NULL);
  EXPECT_VALID(retobj);
  EXPECT(Dart_IsClosure(retobj));

  // Retrieve the closure's function
  result = Dart_ClosureFunction(retobj);
  EXPECT_VALID(result);
  EXPECT(Dart_IsFunction(result));
  owner = Dart_FunctionOwner(result);
  EXPECT_VALID(owner);
  defining_function =
      Dart_LookupFunction(cls, NewString("getStaticClosureWithArgs"));
  EXPECT(Dart_IdentityEquals(owner, defining_function));
  // -999: We want to distinguish between a non-answer and a wrong answer, and
  // -1 has been a previous wrong answer
  fixed_param_count = -999;
  opt_param_count = -999;
  result = Dart_FunctionParameterCounts(result,
                                        &fixed_param_count,
                                        &opt_param_count);
  EXPECT_VALID(result);
  EXPECT_EQ(2, fixed_param_count);
  EXPECT_EQ(1, opt_param_count);
}

TEST_CASE(InvokeClosure) {
  const char* kScriptChars =
      "class InvokeClosure {\n"
      "  InvokeClosure(int i, int j) : fld1 = i, fld2 = j {}\n"
      "  Function method1(int i) {\n"
      "    f(int j) => j + i + fld1 + fld2 + fld4; \n"
      "    return f;\n"
      "  }\n"
      "  static Function method2(int i) {\n"
      "    n(int j) => true + i + fld4; \n"
      "    return n;\n"
      "  }\n"
      "  int fld1;\n"
      "  final int fld2;\n"
      "  static const int fld4 = 10;\n"
      "}\n"
      "Function testMain1() {\n"
      "  InvokeClosure obj = new InvokeClosure(10, 20);\n"
      "  return obj.method1(10);\n"
      "}\n"
      "Function testMain2() {\n"
      "  return InvokeClosure.method2(10);\n"
      "}\n";
  Dart_Handle result;
  DARTSCOPE(Isolate::Current());

  // Create a test library and Load up a test script in it.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);

  // Invoke a function which returns a closure.
  Dart_Handle retobj = Dart_Invoke(lib, NewString("testMain1"), 0, NULL);
  EXPECT_VALID(retobj);

  EXPECT(Dart_IsClosure(retobj));
  EXPECT(!Dart_IsClosure(Dart_NewInteger(101)));

  // Now invoke the closure and check the result.
  Dart_Handle dart_arguments[1];
  dart_arguments[0] = Dart_NewInteger(1);
  result = Dart_InvokeClosure(retobj, 1, dart_arguments);
  EXPECT_VALID(result);
  EXPECT(Dart_IsInteger(result));
  int64_t value = 0;
  result = Dart_IntegerToInt64(result, &value);
  EXPECT_EQ(51, value);

  // Invoke closure with wrong number of args, should result in exception.
  result = Dart_InvokeClosure(retobj, 0, NULL);
  EXPECT(Dart_IsError(result));
  EXPECT(Dart_ErrorHasException(result));

  // Invoke a function which returns a closure.
  retobj = Dart_Invoke(lib, NewString("testMain2"), 0, NULL);
  EXPECT_VALID(retobj);

  EXPECT(Dart_IsClosure(retobj));
  EXPECT(!Dart_IsClosure(NewString("abcdef")));

  // Now invoke the closure and check the result (should be an exception).
  dart_arguments[0] = Dart_NewInteger(1);
  result = Dart_InvokeClosure(retobj, 1, dart_arguments);
  EXPECT(Dart_IsError(result));
  EXPECT(Dart_ErrorHasException(result));
}


void ExceptionNative(Dart_NativeArguments args) {
  Dart_EnterScope();
  Dart_ThrowException(NewString("Hello from ExceptionNative!"));
  UNREACHABLE();
}


static Dart_NativeFunction native_lookup(Dart_Handle name, int argument_count) {
  return reinterpret_cast<Dart_NativeFunction>(&ExceptionNative);
}


TEST_CASE(ThrowException) {
  const char* kScriptChars =
      "int test() native \"ThrowException_native\";";
  Dart_Handle result;
  Isolate* isolate = Isolate::Current();
  EXPECT(isolate != NULL);
  ApiState* state = isolate->api_state();
  EXPECT(state != NULL);
  intptr_t size = state->ZoneSizeInBytes();
  Dart_EnterScope();  // Start a Dart API scope for invoking API functions.

  // Load up a test script which extends the native wrapper class.
  Dart_Handle lib = TestCase::LoadTestScript(
      kScriptChars,
      reinterpret_cast<Dart_NativeEntryResolver>(native_lookup));

  // Throwing an exception here should result in an error.
  result = Dart_ThrowException(NewString("This doesn't work"));
  EXPECT_ERROR(result, "No Dart frames on stack, cannot throw exception");
  EXPECT(!Dart_ErrorHasException(result));

  // Invoke 'test' and check for an uncaught exception.
  result = Dart_Invoke(lib, NewString("test"), 0, NULL);
  EXPECT_ERROR(result, "Hello from ExceptionNative!");
  EXPECT(Dart_ErrorHasException(result));

  Dart_ExitScope();  // Exit the Dart API scope.
  EXPECT_EQ(size, state->ZoneSizeInBytes());
}


void NativeArgumentCounter(Dart_NativeArguments args) {
  Dart_EnterScope();
  int count = Dart_GetNativeArgumentCount(args);
  Dart_SetReturnValue(args, Dart_NewInteger(count));
  Dart_ExitScope();
}


static Dart_NativeFunction gnac_lookup(Dart_Handle name, int argument_count) {
  return reinterpret_cast<Dart_NativeFunction>(&NativeArgumentCounter);
}


TEST_CASE(GetNativeArgumentCount) {
  const char* kScriptChars =
      "class MyObject {"
      "  int method1(int i, int j) native 'Name_Does_Not_Matter';"
      "}"
      "testMain() {"
      "  MyObject obj = new MyObject();"
      "  return obj.method1(77, 125);"
      "}";

  Dart_Handle lib = TestCase::LoadTestScript(
      kScriptChars,
      reinterpret_cast<Dart_NativeEntryResolver>(gnac_lookup));

  Dart_Handle result = Dart_Invoke(lib, NewString("testMain"), 0, NULL);
  EXPECT_VALID(result);
  EXPECT(Dart_IsInteger(result));

  int64_t value = 0;
  result = Dart_IntegerToInt64(result, &value);
  EXPECT_VALID(result);
  EXPECT_EQ(3, value);
}


TEST_CASE(GetClass) {
  const char* kScriptChars =
      "class Class {\n"
      "  static var name = 'Class';\n"
      "}\n"
      "\n"
      "class _Class {\n"
      "  static var name = '_Class';\n"
      "}\n";

  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);

  // Lookup a class.
  Dart_Handle cls = Dart_GetClass(lib, NewString("Class"));
  EXPECT_VALID(cls);
  Dart_Handle name = Dart_GetField(cls, NewString("name"));
  EXPECT_VALID(name);
  const char* name_cstr = "";
  EXPECT_VALID(Dart_StringToCString(name, &name_cstr));
  EXPECT_STREQ("Class", name_cstr);

  // Lookup a private class.
  cls = Dart_GetClass(lib, NewString("_Class"));
  EXPECT_VALID(cls);
  name = Dart_GetField(cls, NewString("name"));
  EXPECT_VALID(name);
  name_cstr = "";
  EXPECT_VALID(Dart_StringToCString(name, &name_cstr));
  EXPECT_STREQ("_Class", name_cstr);

  // Lookup a class that does not exist.
  cls = Dart_GetClass(lib, NewString("DoesNotExist"));
  EXPECT(Dart_IsError(cls));
  EXPECT_STREQ("Class 'DoesNotExist' not found in library 'dart:test-lib'.",
               Dart_GetError(cls));

  // Lookup a class from an error library.  The error propagates.
  cls = Dart_GetClass(Api::NewError("myerror"), NewString("Class"));
  EXPECT(Dart_IsError(cls));
  EXPECT_STREQ("myerror", Dart_GetError(cls));

  // Lookup a class using an error class name.  The error propagates.
  cls = Dart_GetClass(lib, Api::NewError("myerror"));
  EXPECT(Dart_IsError(cls));
  EXPECT_STREQ("myerror", Dart_GetError(cls));
}


static void BuildFunctionDescription(TextBuffer* buffer, Dart_Handle func) {
  buffer->Clear();
  if (Dart_IsNull(func)) {
    WARN("Function not found");
    return;
  }
  Dart_Handle name = Dart_FunctionName(func);
  EXPECT_VALID(name);
  const char* name_cstr = "";
  EXPECT_VALID(Dart_StringToCString(name, &name_cstr));
  bool is_abstract = false;
  bool is_static = false;
  bool is_getter = false;
  bool is_setter = false;
  bool is_constructor = false;
  int64_t fixed_param_count = -1;
  int64_t opt_param_count = -1;
  EXPECT_VALID(Dart_FunctionIsAbstract(func, &is_abstract));
  EXPECT_VALID(Dart_FunctionIsStatic(func, &is_static));
  EXPECT_VALID(Dart_FunctionIsGetter(func, &is_getter));
  EXPECT_VALID(Dart_FunctionIsSetter(func, &is_setter));
  EXPECT_VALID(Dart_FunctionIsConstructor(func, &is_constructor));
  EXPECT_VALID(Dart_FunctionParameterCounts(func,
    &fixed_param_count, &opt_param_count));

  buffer->Printf("%s %"Pd64" %"Pd64"",
    name_cstr,
    fixed_param_count,
    opt_param_count);
  if (is_abstract) {
    buffer->Printf(" abstract");
  }
  if (is_static) {
    buffer->Printf(" static");
  }
  if (is_getter) {
    buffer->Printf(" getter");
  }
  if (is_setter) {
    buffer->Printf(" setter");
  }
  if (is_constructor) {
    buffer->Printf(" constructor");
  }
}


TEST_CASE(FunctionReflection) {
  const char* kScriptChars =
      "a() => 'a';\n"
      "_b() => '_b';\n"
      "get c => 'bar';\n"
      "set d(x) {}\n"
      "get _e => 'bar';\n"
      "set _f(x) {}\n"
      "class MyClass {\n"
      "  MyClass() {}\n"
      "  MyClass.named() {}\n"
      "  a() => 'a';\n"
      "  _b() => '_b';\n"
      "  get c => 'bar';\n"
      "  set d(x) {}\n"
      "  get _e => 'bar';\n"
      "  set _f(x) {}\n"
      "  static g() => 'g';\n"
      "  static _h() => '_h';\n"
      "  static get i => 'i';\n"
      "  static set j(x) {}\n"
      "  static get _k => 'k';\n"
      "  static set _l(x) {}\n"
      "  m();\n"
      "  _n();\n"
      "  get o;\n"
      "  set p(x);\n"
      "  get _q;\n"
      "  set _r(x);\n"
      "  s(x, [y, z]) {}\n"
      "  t([x, y, z]) {}\n"
      "  operator ==(x) {}\n"
      "}\n"
      "class _PrivateClass {\n"
      "  _PrivateClass() {}\n"
      "  _PrivateClass.named() {}\n"
      "}\n";

  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);
  EXPECT_VALID(lib);
  Dart_Handle cls = Dart_GetClass(lib, NewString("MyClass"));
  EXPECT_VALID(cls);
  Dart_Handle private_cls = Dart_GetClass(lib, NewString("_PrivateClass"));
  EXPECT_VALID(private_cls);
  TextBuffer buffer(128);

  // Lookup a top-level function.
  Dart_Handle func = Dart_LookupFunction(lib, NewString("a"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("a 0 0 static", buffer.buf());
  EXPECT(Dart_IsLibrary(Dart_FunctionOwner(func)));
  Dart_Handle owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, lib));

  // Lookup a private top-level function.
  func = Dart_LookupFunction(lib, NewString("_b"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("_b 0 0 static", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, lib));

  // Lookup a top-level getter.
  func = Dart_LookupFunction(lib, NewString("c"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("c 0 0 static getter", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, lib));

  // Lookup a top-level setter.
  func = Dart_LookupFunction(lib, NewString("d="));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("d= 1 0 static setter", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, lib));

  // Lookup a private top-level getter.
  func = Dart_LookupFunction(lib, NewString("_e"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("_e 0 0 static getter", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, lib));

  // Lookup a private top-level setter.
  func = Dart_LookupFunction(lib, NewString("_f="));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("_f= 1 0 static setter", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, lib));

  // Lookup an unnamed constructor
  func = Dart_LookupFunction(cls, NewString("MyClass"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("MyClass 0 0 constructor", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup a named constructor
  func = Dart_LookupFunction(cls, NewString("MyClass.named"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("MyClass.named 0 0 constructor", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup an private unnamed constructor
  func = Dart_LookupFunction(private_cls, NewString("_PrivateClass"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("_PrivateClass 0 0 constructor", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, private_cls));

  // Lookup a private named constructor
  func = Dart_LookupFunction(private_cls,
                             NewString("_PrivateClass.named"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("_PrivateClass.named 0 0 constructor", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, private_cls));

  // Lookup a method.
  func = Dart_LookupFunction(cls, NewString("a"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("a 0 0", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup a private method.
  func = Dart_LookupFunction(cls, NewString("_b"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("_b 0 0", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup a instance getter.
  func = Dart_LookupFunction(cls, NewString("c"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("c 0 0 getter", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup a instance setter.
  func = Dart_LookupFunction(cls, NewString("d="));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("d= 1 0 setter", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup a private instance getter.
  func = Dart_LookupFunction(cls, NewString("_e"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("_e 0 0 getter", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup a private instance setter.
  func = Dart_LookupFunction(cls, NewString("_f="));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("_f= 1 0 setter", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup a static method.
  func = Dart_LookupFunction(cls, NewString("g"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("g 0 0 static", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup a private static method.
  func = Dart_LookupFunction(cls, NewString("_h"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("_h 0 0 static", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup a static getter.
  func = Dart_LookupFunction(cls, NewString("i"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("i 0 0 static getter", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup a static setter.
  func = Dart_LookupFunction(cls, NewString("j="));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("j= 1 0 static setter", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup a private static getter.
  func = Dart_LookupFunction(cls, NewString("_k"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("_k 0 0 static getter", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup a private static setter.
  func = Dart_LookupFunction(cls, NewString("_l="));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("_l= 1 0 static setter", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup an abstract method.
  func = Dart_LookupFunction(cls, NewString("m"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("m 0 0 abstract", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup a private abstract method.
  func = Dart_LookupFunction(cls, NewString("_n"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("_n 0 0 abstract", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup a abstract getter.
  func = Dart_LookupFunction(cls, NewString("o"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("o 0 0 abstract getter", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup a abstract setter.
  func = Dart_LookupFunction(cls, NewString("p="));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("p= 1 0 abstract setter", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup a private abstract getter.
  func = Dart_LookupFunction(cls, NewString("_q"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("_q 0 0 abstract getter", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup a private abstract setter.
  func = Dart_LookupFunction(cls, NewString("_r="));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("_r= 1 0 abstract setter", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup a method with fixed and optional parameters.
  func = Dart_LookupFunction(cls, NewString("s"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("s 1 2", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup a method with only optional parameters.
  func = Dart_LookupFunction(cls, NewString("t"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("t 0 3", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup an operator
  func = Dart_LookupFunction(cls, NewString("=="));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));
  BuildFunctionDescription(&buffer, func);
  EXPECT_STREQ("== 1 0", buffer.buf());
  owner = Dart_FunctionOwner(func);
  EXPECT_VALID(owner);
  EXPECT(Dart_IdentityEquals(owner, cls));

  // Lookup a function that does not exist from a library.
  func = Dart_LookupFunction(lib, NewString("DoesNotExist"));
  EXPECT(Dart_IsNull(func));

  // Lookup a function that does not exist from a class.
  func = Dart_LookupFunction(cls, NewString("DoesNotExist"));
  EXPECT(Dart_IsNull(func));

  // Lookup a class using an error class name.  The error propagates.
  func = Dart_LookupFunction(cls, Api::NewError("myerror"));
  EXPECT_ERROR(func, "myerror");

  // Lookup a class from an error library.  The error propagates.
  func = Dart_LookupFunction(Api::NewError("myerror"), NewString("foo"));
  EXPECT_ERROR(func, "myerror");
}


TEST_CASE(TypeReflection) {
  const char* kScriptChars =
      "void func(String a, int b) {}\n"
      "int variable;\n";
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);
  EXPECT_VALID(lib);

  Dart_Handle func = Dart_LookupFunction(lib, NewString("func"));
  EXPECT_VALID(func);
  EXPECT(Dart_IsFunction(func));

  // Make sure parameter counts are right.
  int64_t fixed_params = -1;
  int64_t opt_params = -1;
  EXPECT_VALID(Dart_FunctionParameterCounts(func, &fixed_params, &opt_params));
  EXPECT_EQ(2, fixed_params);
  EXPECT_EQ(0, opt_params);

  // Check the return type.
  Dart_Handle type = Dart_FunctionReturnType(func);
  EXPECT_VALID(type);
  Dart_Handle cls_name = Dart_ClassName(type);
  EXPECT_VALID(cls_name);
  const char* cls_name_cstr = "";
  EXPECT_VALID(Dart_StringToCString(cls_name, &cls_name_cstr));
  EXPECT_STREQ("void", cls_name_cstr);

  // Check a parameter type.
  type = Dart_FunctionParameterType(func, 0);
  EXPECT_VALID(type);
  cls_name = Dart_ClassName(type);
  EXPECT_VALID(cls_name);
  cls_name_cstr = "";
  EXPECT_VALID(Dart_StringToCString(cls_name, &cls_name_cstr));
  EXPECT_STREQ("String", cls_name_cstr);

  Dart_Handle var = Dart_LookupVariable(lib, NewString("variable"));
  EXPECT_VALID(var);
  EXPECT(Dart_IsVariable(var));

  // Check the variable type.
  type = Dart_VariableType(var);
  EXPECT_VALID(type);
  cls_name = Dart_ClassName(type);
  EXPECT_VALID(cls_name);
  cls_name_cstr = "";
  EXPECT_VALID(Dart_StringToCString(cls_name, &cls_name_cstr));
  if (FLAG_enable_type_checks) {
    EXPECT_STREQ("int", cls_name_cstr);
  } else {
    EXPECT_STREQ("dynamic", cls_name_cstr);
  }
}


static void BuildVariableDescription(TextBuffer* buffer, Dart_Handle var) {
  buffer->Clear();
  Dart_Handle name = Dart_VariableName(var);
  EXPECT_VALID(name);
  const char* name_cstr = "";
  EXPECT_VALID(Dart_StringToCString(name, &name_cstr));
  bool is_static = false;
  bool is_final = false;
  EXPECT_VALID(Dart_VariableIsStatic(var, &is_static));
  EXPECT_VALID(Dart_VariableIsFinal(var, &is_final));
  buffer->Printf("%s", name_cstr);
  if (is_static) {
    buffer->Printf(" static");
  }
  if (is_final) {
    buffer->Printf(" final");
  }
}


TEST_CASE(VariableReflection) {
  const char* kScriptChars =
      "var a = 'a';\n"
      "var _b = '_b';\n"
      "final c = 'c';\n"
      "final _d = '_d';\n"
      "class MyClass {\n"
      "  var a = 'a';\n"
      "  var _b = '_b';\n"
      "  final c = 'c';\n"
      "  final _d = '_d';\n"
      "  static var e = 'e';\n"
      "  static var _f = '_f';\n"
      "  static const g = 'g';\n"
      "  static const _h = '_h';\n"
      "}\n";

  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);
  EXPECT_VALID(lib);
  Dart_Handle cls = Dart_GetClass(lib, NewString("MyClass"));
  EXPECT_VALID(cls);
  TextBuffer buffer(128);

  // Lookup a top-level variable.
  Dart_Handle var = Dart_LookupVariable(lib, NewString("a"));
  EXPECT_VALID(var);
  EXPECT(Dart_IsVariable(var));
  BuildVariableDescription(&buffer, var);
  EXPECT_STREQ("a static", buffer.buf());

  // Lookup a private top-level variable.
  var = Dart_LookupVariable(lib, NewString("_b"));
  EXPECT_VALID(var);
  EXPECT(Dart_IsVariable(var));
  BuildVariableDescription(&buffer, var);
  EXPECT_STREQ("_b static", buffer.buf());

  // Lookup a const top-level variable.
  var = Dart_LookupVariable(lib, NewString("c"));
  EXPECT_VALID(var);
  EXPECT(Dart_IsVariable(var));
  BuildVariableDescription(&buffer, var);
  EXPECT_STREQ("c static final", buffer.buf());

  // Lookup a private const top-level variable.
  var = Dart_LookupVariable(lib, NewString("_d"));
  EXPECT_VALID(var);
  EXPECT(Dart_IsVariable(var));
  BuildVariableDescription(&buffer, var);
  EXPECT_STREQ("_d static final", buffer.buf());

  // Lookup a instance variable.
  var = Dart_LookupVariable(cls, NewString("a"));
  EXPECT_VALID(var);
  EXPECT(Dart_IsVariable(var));
  BuildVariableDescription(&buffer, var);
  EXPECT_STREQ("a", buffer.buf());

  // Lookup a private instance variable.
  var = Dart_LookupVariable(cls, NewString("_b"));
  EXPECT_VALID(var);
  EXPECT(Dart_IsVariable(var));
  BuildVariableDescription(&buffer, var);
  EXPECT_STREQ("_b", buffer.buf());

  // Lookup a final instance variable.
  var = Dart_LookupVariable(cls, NewString("c"));
  EXPECT_VALID(var);
  EXPECT(Dart_IsVariable(var));
  BuildVariableDescription(&buffer, var);
  EXPECT_STREQ("c final", buffer.buf());

  // Lookup a private final instance variable.
  var = Dart_LookupVariable(cls, NewString("_d"));
  EXPECT_VALID(var);
  EXPECT(Dart_IsVariable(var));
  BuildVariableDescription(&buffer, var);
  EXPECT_STREQ("_d final", buffer.buf());

  // Lookup a static variable.
  var = Dart_LookupVariable(cls, NewString("e"));
  EXPECT_VALID(var);
  EXPECT(Dart_IsVariable(var));
  BuildVariableDescription(&buffer, var);
  EXPECT_STREQ("e static", buffer.buf());

  // Lookup a private static variable.
  var = Dart_LookupVariable(cls, NewString("_f"));
  EXPECT_VALID(var);
  EXPECT(Dart_IsVariable(var));
  BuildVariableDescription(&buffer, var);
  EXPECT_STREQ("_f static", buffer.buf());

  // Lookup a const static variable.
  var = Dart_LookupVariable(cls, NewString("g"));
  EXPECT_VALID(var);
  EXPECT(Dart_IsVariable(var));
  BuildVariableDescription(&buffer, var);
  EXPECT_STREQ("g static final", buffer.buf());

  // Lookup a private const static variable.
  var = Dart_LookupVariable(cls, NewString("_h"));
  EXPECT_VALID(var);
  EXPECT(Dart_IsVariable(var));
  BuildVariableDescription(&buffer, var);
  EXPECT_STREQ("_h static final", buffer.buf());

  // Lookup a variable that does not exist from a library.
  var = Dart_LookupVariable(lib, NewString("DoesNotExist"));
  EXPECT(Dart_IsNull(var));

  // Lookup a variable that does not exist from a class.
  var = Dart_LookupVariable(cls, NewString("DoesNotExist"));
  EXPECT(Dart_IsNull(var));

  // Lookup a class from an error library.  The error propagates.
  var = Dart_LookupVariable(Api::NewError("myerror"), NewString("foo"));
  EXPECT_ERROR(var, "myerror");

  // Lookup a class using an error class name.  The error propagates.
  var = Dart_LookupVariable(lib, Api::NewError("myerror"));
  EXPECT_ERROR(var, "myerror");
}


TEST_CASE(TypeVariableReflection) {
  const char* kScriptChars =
      "abstract class UpperBound {}\n"
      "class GenericClass<U, T extends UpperBound> {\n"
      "  T func1() { return null; }\n"
      "  U func2() { return null; }\n"
      "}\n";

  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);
  Dart_Handle cls = Dart_GetClass(lib, NewString("GenericClass"));
  EXPECT_VALID(cls);

  // Test Dart_GetTypeVariableNames.
  Dart_Handle names = Dart_GetTypeVariableNames(cls);
  EXPECT_VALID(names);
  Dart_Handle names_str = Dart_ToString(names);
  EXPECT_VALID(names_str);
  const char* cstr = "";
  EXPECT_VALID(Dart_StringToCString(names_str, &cstr));
  EXPECT_STREQ("[U, T]", cstr);

  // Test variable U.
  Dart_Handle type_var = Dart_LookupTypeVariable(cls, NewString("U"));
  EXPECT_VALID(type_var);
  EXPECT(Dart_IsTypeVariable(type_var));
  Dart_Handle type_var_name = Dart_TypeVariableName(type_var);
  EXPECT_VALID(type_var_name);
  EXPECT_VALID(Dart_StringToCString(type_var_name, &cstr));
  EXPECT_STREQ("U", cstr);
  Dart_Handle type_var_owner = Dart_TypeVariableOwner(type_var);
  EXPECT_VALID(type_var_owner);
  EXPECT(Dart_IdentityEquals(cls, type_var_owner));
  Dart_Handle type_var_bound = Dart_TypeVariableUpperBound(type_var);
  Dart_Handle bound_name = Dart_ClassName(type_var_bound);
  EXPECT_VALID(Dart_StringToCString(bound_name, &cstr));
  EXPECT_STREQ("Object", cstr);

  // Test variable T.
  type_var = Dart_LookupTypeVariable(cls, NewString("T"));
  EXPECT_VALID(type_var);
  EXPECT(Dart_IsTypeVariable(type_var));
  type_var_name = Dart_TypeVariableName(type_var);
  EXPECT_VALID(type_var_name);
  EXPECT_VALID(Dart_StringToCString(type_var_name, &cstr));
  EXPECT_STREQ("T", cstr);
  type_var_owner = Dart_TypeVariableOwner(type_var);
  EXPECT_VALID(type_var_owner);
  EXPECT(Dart_IdentityEquals(cls, type_var_owner));
  type_var_bound = Dart_TypeVariableUpperBound(type_var);
  bound_name = Dart_ClassName(type_var_bound);
  EXPECT_VALID(Dart_StringToCString(bound_name, &cstr));
  EXPECT_STREQ("UpperBound", cstr);
}


TEST_CASE(InstanceOf) {
  const char* kScriptChars =
      "class OtherClass {\n"
      "  static returnNull() { return null; }\n"
      "}\n"
      "class InstanceOfTest {\n"
      "  InstanceOfTest() {}\n"
      "  static InstanceOfTest testMain() {\n"
      "    return new InstanceOfTest();\n"
      "  }\n"
      "}\n";
  Dart_Handle result;
  // Create a test library and Load up a test script in it.
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);

  // Fetch InstanceOfTest class.
  Dart_Handle cls = Dart_GetClass(lib, NewString("InstanceOfTest"));
  EXPECT_VALID(cls);

  // Invoke a function which returns an object of type InstanceOf..
  Dart_Handle instanceOfTestObj =
      Dart_Invoke(cls, NewString("testMain"), 0, NULL);
  EXPECT_VALID(instanceOfTestObj);

  // Now check instanceOfTestObj reported as an instance of
  // InstanceOfTest class.
  bool is_instance = false;
  result = Dart_ObjectIsType(instanceOfTestObj, cls, &is_instance);
  EXPECT_VALID(result);
  EXPECT(is_instance);

  // Fetch OtherClass and check if instanceOfTestObj is instance of it.
  Dart_Handle otherClass = Dart_GetClass(lib, NewString("OtherClass"));
  EXPECT_VALID(otherClass);

  result = Dart_ObjectIsType(instanceOfTestObj, otherClass, &is_instance);
  EXPECT_VALID(result);
  EXPECT(!is_instance);

  // Check that primitives are not instances of InstanceOfTest class.
  result = Dart_ObjectIsType(NewString("a string"), otherClass,
                             &is_instance);
  EXPECT_VALID(result);
  EXPECT(!is_instance);

  result = Dart_ObjectIsType(Dart_NewInteger(42), otherClass, &is_instance);
  EXPECT_VALID(result);
  EXPECT(!is_instance);

  result = Dart_ObjectIsType(Dart_NewBoolean(true), otherClass, &is_instance);
  EXPECT_VALID(result);
  EXPECT(!is_instance);

  // Check that null is not an instance of InstanceOfTest class.
  Dart_Handle null = Dart_Invoke(otherClass,
                                 NewString("returnNull"),
                                 0,
                                 NULL);
  EXPECT_VALID(null);

  result = Dart_ObjectIsType(null, otherClass, &is_instance);
  EXPECT_VALID(result);
  EXPECT(!is_instance);

  // Check that error is returned if null is passed as a class argument.
  result = Dart_ObjectIsType(null, null, &is_instance);
  EXPECT(Dart_IsError(result));
}


static Dart_Handle library_handler(Dart_LibraryTag tag,
                                   Dart_Handle library,
                                   Dart_Handle url) {
  if (tag == kCanonicalizeUrl) {
    return url;
  }
  return Api::Success(Isolate::Current());
}


TEST_CASE(LoadScript) {
  const char* kScriptChars =
      "main() {"
      "  return 12345;"
      "}";
  Dart_Handle url = NewString(TestCase::url());
  Dart_Handle source = NewString(kScriptChars);
  Dart_Handle error = Dart_Error("incoming error");
  Dart_Handle result;

  result = Dart_SetLibraryTagHandler(library_handler);
  EXPECT_VALID(result);

  result = Dart_LoadScript(Dart_Null(), source, 0, 0);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_LoadScript expects argument 'url' to be non-null.",
               Dart_GetError(result));

  result = Dart_LoadScript(Dart_True(), source, 0, 0);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_LoadScript expects argument 'url' to be of type String.",
               Dart_GetError(result));

  result = Dart_LoadScript(error, source, 0, 0);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("incoming error", Dart_GetError(result));

  result = Dart_LoadScript(url, Dart_Null(), 0, 0);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_LoadScript expects argument 'source' to be non-null.",
               Dart_GetError(result));

  result = Dart_LoadScript(url, Dart_True(), 0, 0);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ(
      "Dart_LoadScript expects argument 'source' to be of type String.",
      Dart_GetError(result));

  result = Dart_LoadScript(url, error, 0, 0);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("incoming error", Dart_GetError(result));

  // Load a script successfully.
  result = Dart_LoadScript(url, source, 0, 0);
  EXPECT_VALID(result);

  result = Dart_Invoke(result, NewString("main"), 0, NULL);
  EXPECT_VALID(result);
  EXPECT(Dart_IsInteger(result));
  int64_t value = 0;
  EXPECT_VALID(Dart_IntegerToInt64(result, &value));
  EXPECT_EQ(12345, value);

  // Further calls to LoadScript are errors.
  result = Dart_LoadScript(url, source, 0, 0);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_LoadScript: "
               "A script has already been loaded from 'dart:test-lib'.",
               Dart_GetError(result));
}


TEST_CASE(RootLibrary) {
  const char* kScriptChars =
      "main() {"
      "  return 12345;"
      "}";

  Dart_Handle root_lib = Dart_RootLibrary();
  EXPECT_VALID(root_lib);
  EXPECT(Dart_IsNull(root_lib));

  // Load a script.
  Dart_Handle url = NewString(TestCase::url());
  Dart_Handle source = NewString(kScriptChars);
  EXPECT_VALID(Dart_LoadScript(url, source, 0, 0));

  root_lib = Dart_RootLibrary();
  Dart_Handle lib_name = Dart_LibraryName(root_lib);
  EXPECT_VALID(lib_name);
  EXPECT(!Dart_IsNull(root_lib));
  const char* name_cstr = "";
  EXPECT_VALID(Dart_StringToCString(lib_name, &name_cstr));
  EXPECT_STREQ(TestCase::url(), name_cstr);
}


static int index = 0;


static Dart_Handle import_library_handler(Dart_LibraryTag tag,
                                          Dart_Handle library,
                                          Dart_Handle url) {
  if (tag == kCanonicalizeUrl) {
    return url;
  }
  EXPECT(Dart_IsString(url));
  const char* cstr = NULL;
  EXPECT_VALID(Dart_StringToCString(url, &cstr));
  switch (index) {
    case 0:
      EXPECT_STREQ("./weird.dart", cstr);
      break;
    case 1:
      EXPECT_STREQ("abclaladef", cstr);
      break;
    case 2:
      EXPECT_STREQ("winner", cstr);
      break;
    case 3:
      EXPECT_STREQ("abclaladef/extra_weird.dart", cstr);
      break;
    case 4:
      EXPECT_STREQ("winnerwinner", cstr);
      break;
    default:
      EXPECT(false);
      return Api::NewError("invalid callback");
  }
  index += 1;
  return Api::Success(Isolate::Current());
}


TEST_CASE(LoadScript_CompileError) {
  const char* kScriptChars =
      ")";
  Dart_Handle url = NewString(TestCase::url());
  Dart_Handle source = NewString(kScriptChars);
  Dart_Handle result = Dart_SetLibraryTagHandler(import_library_handler);
  EXPECT_VALID(result);
  result = Dart_LoadScript(url, source, 0, 0);
  EXPECT(Dart_IsError(result));
  EXPECT(strstr(Dart_GetError(result), "unexpected token ')'"));
}


TEST_CASE(LookupLibrary) {
  const char* kScriptChars =
      "import 'library1_dart';"
      "main() {}";
  const char* kLibrary1Chars =
      "library library1_dart;"
      "import 'library2_dart';";

  // Create a test library and Load up a test script in it.
  Dart_Handle url = NewString(TestCase::url());
  Dart_Handle source = NewString(kScriptChars);
  Dart_Handle result = Dart_SetLibraryTagHandler(library_handler);
  EXPECT_VALID(result);
  result = Dart_LoadScript(url, source, 0, 0);
  EXPECT_VALID(result);

  url = NewString("library1_dart");
  source = NewString(kLibrary1Chars);
  result = Dart_LoadLibrary(url, source);
  EXPECT_VALID(result);

  result = Dart_LookupLibrary(url);
  EXPECT_VALID(result);

  result = Dart_LookupLibrary(Dart_Null());
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_LookupLibrary expects argument 'url' to be non-null.",
               Dart_GetError(result));

  result = Dart_LookupLibrary(Dart_True());
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ(
      "Dart_LookupLibrary expects argument 'url' to be of type String.",
      Dart_GetError(result));

  result = Dart_LookupLibrary(Dart_Error("incoming error"));
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("incoming error", Dart_GetError(result));

  url = NewString("noodles.dart");
  result = Dart_LookupLibrary(url);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_LookupLibrary: library 'noodles.dart' not found.",
               Dart_GetError(result));
}


TEST_CASE(LibraryName) {
  const char* kLibrary1Chars =
      "library library1_name;";
  Dart_Handle url = NewString("library1_url");
  Dart_Handle source = NewString(kLibrary1Chars);
  Dart_Handle lib = Dart_LoadLibrary(url, source);
  Dart_Handle error = Dart_Error("incoming error");
  EXPECT_VALID(lib);

  Dart_Handle result = Dart_LibraryName(Dart_Null());
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_LibraryName expects argument 'library' to be non-null.",
               Dart_GetError(result));

  result = Dart_LibraryName(Dart_True());
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ(
      "Dart_LibraryName expects argument 'library' to be of type Library.",
      Dart_GetError(result));

  result = Dart_LibraryName(error);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("incoming error", Dart_GetError(result));

  result = Dart_LibraryName(lib);
  EXPECT_VALID(result);
  EXPECT(Dart_IsString(result));
  const char* cstr = NULL;
  EXPECT_VALID(Dart_StringToCString(result, &cstr));
  EXPECT_STREQ("library1_name", cstr);
}


TEST_CASE(LibraryUrl) {
  const char* kLibrary1Chars =
      "library library1_name;";
  Dart_Handle url = NewString("library1_url");
  Dart_Handle source = NewString(kLibrary1Chars);
  Dart_Handle lib = Dart_LoadLibrary(url, source);
  Dart_Handle error = Dart_Error("incoming error");
  EXPECT_VALID(lib);

  Dart_Handle result = Dart_LibraryUrl(Dart_Null());
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_LibraryUrl expects argument 'library' to be non-null.",
               Dart_GetError(result));

  result = Dart_LibraryUrl(Dart_True());
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ(
      "Dart_LibraryUrl expects argument 'library' to be of type Library.",
      Dart_GetError(result));

  result = Dart_LibraryUrl(error);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("incoming error", Dart_GetError(result));

  result = Dart_LibraryUrl(lib);
  EXPECT_VALID(result);
  EXPECT(Dart_IsString(result));
  const char* cstr = NULL;
  EXPECT_VALID(Dart_StringToCString(result, &cstr));
  EXPECT_STREQ("library1_url", cstr);
}


TEST_CASE(LibraryGetClassNames) {
  const char* kLibraryChars =
      "library library_name;\n"
      "\n"
      "class A {}\n"
      "class B {}\n"
      "abstract class C {}\n"
      "class _A {}\n"
      "class _B {}\n"
      "abstract class _C {}\n"
      "\n"
      "_compare(String a, String b) => a.compareTo(b);\n"
      "sort(list) => list.sort(_compare);\n";

  Dart_Handle url = NewString("library_url");
  Dart_Handle source = NewString(kLibraryChars);
  Dart_Handle lib = Dart_LoadLibrary(url, source);
  EXPECT_VALID(lib);

  Dart_Handle list = Dart_LibraryGetClassNames(lib);
  EXPECT_VALID(list);
  EXPECT(Dart_IsList(list));

  // Sort the list.
  const int kNumArgs = 1;
  Dart_Handle args[1];
  args[0] = list;
  EXPECT_VALID(Dart_Invoke(lib, NewString("sort"), kNumArgs, args));

  Dart_Handle list_string = Dart_ToString(list);
  EXPECT_VALID(list_string);
  const char* list_cstr = "";
  EXPECT_VALID(Dart_StringToCString(list_string, &list_cstr));
  EXPECT_STREQ("[A, B, C, _A, _B, _C]", list_cstr);
}


TEST_CASE(GetFunctionNames) {
  const char* kLibraryChars =
      "library library_name;\n"
      "\n"
      "void A() {}\n"
      "get B => 11;\n"
      "set C(x) { }\n"
      "var D;\n"
      "void _A() {}\n"
      "get _B => 11;\n"
      "set _C(x) { }\n"
      "var _D;\n"
      "\n"
      "class MyClass {\n"
      "  void A2() {}\n"
      "  get B2 => 11;\n"
      "  set C2(x) { }\n"
      "  var D2;\n"
      "  void _A2() {}\n"
      "  get _B2 => 11;\n"
      "  set _C2(x) { }\n"
      "  var _D2;\n"
      "}\n"
      "\n"
      "_compare(String a, String b) => a.compareTo(b);\n"
      "sort(list) => list.sort(_compare);\n";

  // Get the functions from a library.
  Dart_Handle url = NewString("library_url");
  Dart_Handle source = NewString(kLibraryChars);
  Dart_Handle lib = Dart_LoadLibrary(url, source);
  EXPECT_VALID(lib);

  Dart_Handle list = Dart_GetFunctionNames(lib);
  EXPECT_VALID(list);
  EXPECT(Dart_IsList(list));

  // Sort the list.
  const int kNumArgs = 1;
  Dart_Handle args[1];
  args[0] = list;
  EXPECT_VALID(Dart_Invoke(lib, NewString("sort"), kNumArgs, args));

  Dart_Handle list_string = Dart_ToString(list);
  EXPECT_VALID(list_string);
  const char* list_cstr = "";
  EXPECT_VALID(Dart_StringToCString(list_string, &list_cstr));
  EXPECT_STREQ("[A, B, C=, _A, _B, _C=, _compare, sort]", list_cstr);

  // Get the functions from a class.
  Dart_Handle cls = Dart_GetClass(lib, NewString("MyClass"));
  EXPECT_VALID(cls);

  list = Dart_GetFunctionNames(cls);
  EXPECT_VALID(list);
  EXPECT(Dart_IsList(list));

  // Sort the list.
  args[0] = list;
  EXPECT_VALID(Dart_Invoke(lib, NewString("sort"), kNumArgs, args));

  // Check list contents.
  list_string = Dart_ToString(list);
  EXPECT_VALID(list_string);
  list_cstr = "";
  EXPECT_VALID(Dart_StringToCString(list_string, &list_cstr));
  EXPECT_STREQ("[A2, B2, C2=, MyClass, _A2, _B2, _C2=]", list_cstr);
}


TEST_CASE(GetVariableNames) {
  const char* kLibraryChars =
      "library library_name;\n"
      "\n"
      "var A;\n"
      "get B => 12;\n"
      "set C(x) { }\n"
      "D(x) => (x + 1);\n"
      "var _A;\n"
      "get _B => 12;\n"
      "set _C(x) { }\n"
      "_D(x) => (x + 1);\n"
      "\n"
      "class MyClass {\n"
      "  var A2;\n"
      "  var _A2;\n"
      "}\n"
      "\n"
      "_compare(String a, String b) => a.compareTo(b);\n"
      "sort(list) => list.sort(_compare);\n";

  // Get the variables from a library.
  Dart_Handle url = NewString("library_url");
  Dart_Handle source = NewString(kLibraryChars);
  Dart_Handle lib = Dart_LoadLibrary(url, source);
  EXPECT_VALID(lib);

  Dart_Handle list = Dart_GetVariableNames(lib);
  EXPECT_VALID(list);
  EXPECT(Dart_IsList(list));

  // Sort the list.
  const int kNumArgs = 1;
  Dart_Handle args[1];
  args[0] = list;
  EXPECT_VALID(Dart_Invoke(lib, NewString("sort"), kNumArgs, args));

  // Check list contents.
  Dart_Handle list_string = Dart_ToString(list);
  EXPECT_VALID(list_string);
  const char* list_cstr = "";
  EXPECT_VALID(Dart_StringToCString(list_string, &list_cstr));
  EXPECT_STREQ("[A, _A]", list_cstr);

  // Get the variables from a class.
  Dart_Handle cls = Dart_GetClass(lib, NewString("MyClass"));
  EXPECT_VALID(cls);

  list = Dart_GetVariableNames(cls);
  EXPECT_VALID(list);
  EXPECT(Dart_IsList(list));

  // Sort the list.
  args[0] = list;
  EXPECT_VALID(Dart_Invoke(lib, NewString("sort"), kNumArgs, args));

  // Check list contents.
  list_string = Dart_ToString(list);
  EXPECT_VALID(list_string);
  list_cstr = "";
  EXPECT_VALID(Dart_StringToCString(list_string, &list_cstr));
  EXPECT_STREQ("[A2, _A2]", list_cstr);
}


TEST_CASE(LibraryImportLibrary) {
  const char* kLibrary1Chars =
      "library library1_name;";
  const char* kLibrary2Chars =
      "library library2_name;";
  Dart_Handle error = Dart_Error("incoming error");
  Dart_Handle result;

  Dart_Handle url = NewString("library1_url");
  Dart_Handle source = NewString(kLibrary1Chars);
  Dart_Handle lib1 = Dart_LoadLibrary(url, source);
  EXPECT_VALID(lib1);

  url = NewString("library2_url");
  source = NewString(kLibrary2Chars);
  Dart_Handle lib2 = Dart_LoadLibrary(url, source);
  EXPECT_VALID(lib2);

  result = Dart_LibraryImportLibrary(Dart_Null(), lib2, Dart_Null());
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ(
      "Dart_LibraryImportLibrary expects argument 'library' to be non-null.",
      Dart_GetError(result));

  result = Dart_LibraryImportLibrary(Dart_True(), lib2, Dart_Null());
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_LibraryImportLibrary expects argument 'library' to be of "
               "type Library.",
               Dart_GetError(result));

  result = Dart_LibraryImportLibrary(error, lib2, Dart_Null());
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("incoming error", Dart_GetError(result));

  result = Dart_LibraryImportLibrary(lib1, Dart_Null(), Dart_Null());
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ(
      "Dart_LibraryImportLibrary expects argument 'import' to be non-null.",
      Dart_GetError(result));

  result = Dart_LibraryImportLibrary(lib1, Dart_True(), Dart_Null());
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_LibraryImportLibrary expects argument 'import' to be of "
               "type Library.",
               Dart_GetError(result));

  result = Dart_LibraryImportLibrary(lib1, error, Dart_Null());
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("incoming error", Dart_GetError(result));

  result = Dart_LibraryImportLibrary(lib1, lib2, Dart_Null());
  EXPECT_VALID(result);
}


TEST_CASE(ImportLibraryWithPrefix) {
  const char* kLibrary1Chars =
      "library library1_name;"
      "int bar() => 42;";
  Dart_Handle url1 = NewString("library1_url");
  Dart_Handle source1 = NewString(kLibrary1Chars);
  Dart_Handle lib1 = Dart_LoadLibrary(url1, source1);
  EXPECT_VALID(lib1);
  EXPECT(Dart_IsLibrary(lib1));

  const char* kLibrary2Chars =
      "library library2_name;"
      "int foobar() => foo.bar();";
  Dart_Handle url2 = NewString("library2_url");
  Dart_Handle source2 = NewString(kLibrary2Chars);
  Dart_Handle lib2 = Dart_LoadLibrary(url2, source2);
  EXPECT_VALID(lib2);
  EXPECT(Dart_IsLibrary(lib2));

  Dart_Handle prefix = NewString("foo");
  Dart_Handle result = Dart_LibraryImportLibrary(lib2, lib1, prefix);
  EXPECT_VALID(result);

  // Lib1 is imported under a library prefix and therefore 'foo' should
  // not be found directly in lib2.
  Dart_Handle method_name = NewString("foo");
  result = Dart_Invoke(lib2, method_name, 0, NULL);
  EXPECT_ERROR(result, "Dart_Invoke: did not find top-level function 'foo'");

  // Check that lib1 is available under the prefix in lib2.
  method_name = NewString("foobar");
  result = Dart_Invoke(lib2, method_name, 0, NULL);
  EXPECT_VALID(result);
  EXPECT(Dart_IsInteger(result));
  int64_t value = 0;
  EXPECT_VALID(Dart_IntegerToInt64(result, &value));
  EXPECT_EQ(42, value);
}



TEST_CASE(LoadLibrary) {
  const char* kLibrary1Chars =
      "library library1_name;";
  Dart_Handle error = Dart_Error("incoming error");
  Dart_Handle result;

  Dart_Handle url = NewString("library1_url");
  Dart_Handle source = NewString(kLibrary1Chars);

  result = Dart_LoadLibrary(Dart_Null(), source);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_LoadLibrary expects argument 'url' to be non-null.",
               Dart_GetError(result));

  result = Dart_LoadLibrary(Dart_True(), source);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_LoadLibrary expects argument 'url' to be of type String.",
               Dart_GetError(result));

  result = Dart_LoadLibrary(error, source);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("incoming error", Dart_GetError(result));

  result = Dart_LoadLibrary(url, Dart_Null());
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_LoadLibrary expects argument 'source' to be non-null.",
               Dart_GetError(result));

  result = Dart_LoadLibrary(url, Dart_True());
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ(
      "Dart_LoadLibrary expects argument 'source' to be of type String.",
      Dart_GetError(result));

  result = Dart_LoadLibrary(url, error);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("incoming error", Dart_GetError(result));

  // Success.
  result = Dart_LoadLibrary(url, source);
  EXPECT_VALID(result);
  EXPECT(Dart_IsLibrary(result));

  // Duplicate library load fails.
  result = Dart_LoadLibrary(url, source);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ(
      "Dart_LoadLibrary: library 'library1_url' has already been loaded.",
      Dart_GetError(result));
}


TEST_CASE(LoadLibrary_CompileError) {
  const char* kLibrary1Chars =
      "library library1_name;"
      ")";
  Dart_Handle url = NewString("library1_url");
  Dart_Handle source = NewString(kLibrary1Chars);
  Dart_Handle result = Dart_LoadLibrary(url, source);
  EXPECT(Dart_IsError(result));
  EXPECT(strstr(Dart_GetError(result), "unexpected token ')'"));
}


TEST_CASE(LoadSource) {
  const char* kLibrary1Chars =
      "library library1_name;";
  const char* kSourceChars =
      "part of library1_name;\n// Something innocuous";
  const char* kBadSourceChars =
      ")";
  Dart_Handle error = Dart_Error("incoming error");
  Dart_Handle result;

  // Load up a library.
  Dart_Handle url = NewString("library1_url");
  Dart_Handle source = NewString(kLibrary1Chars);
  Dart_Handle lib = Dart_LoadLibrary(url, source);
  EXPECT_VALID(lib);
  EXPECT(Dart_IsLibrary(lib));

  url = NewString("source_url");
  source = NewString(kSourceChars);

  result = Dart_LoadSource(Dart_Null(), url, source);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_LoadSource expects argument 'library' to be non-null.",
               Dart_GetError(result));

  result = Dart_LoadSource(Dart_True(), url, source);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ(
      "Dart_LoadSource expects argument 'library' to be of type Library.",
      Dart_GetError(result));

  result = Dart_LoadSource(error, url, source);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("incoming error", Dart_GetError(result));

  result = Dart_LoadSource(lib, Dart_Null(), source);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_LoadSource expects argument 'url' to be non-null.",
               Dart_GetError(result));

  result = Dart_LoadSource(lib, Dart_True(), source);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_LoadSource expects argument 'url' to be of type String.",
               Dart_GetError(result));

  result = Dart_LoadSource(lib, error, source);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("incoming error", Dart_GetError(result));

  result = Dart_LoadSource(lib, url, Dart_Null());
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_LoadSource expects argument 'source' to be non-null.",
               Dart_GetError(result));

  result = Dart_LoadSource(lib, url, Dart_True());
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ(
      "Dart_LoadSource expects argument 'source' to be of type String.",
      Dart_GetError(result));

  result = Dart_LoadSource(lib, error, source);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("incoming error", Dart_GetError(result));

  // Success.
  result = Dart_LoadSource(lib, url, source);
  EXPECT_VALID(result);
  EXPECT(Dart_IsLibrary(result));
  EXPECT(Dart_IdentityEquals(lib, result));

  // Duplicate calls are okay.
  result = Dart_LoadSource(lib, url, source);
  EXPECT_VALID(result);
  EXPECT(Dart_IsLibrary(result));
  EXPECT(Dart_IdentityEquals(lib, result));

  // Language errors are detected.
  source = NewString(kBadSourceChars);
  result = Dart_LoadSource(lib, url, source);
  EXPECT(Dart_IsError(result));
}


TEST_CASE(LoadSource_LateLoad) {
  const char* kLibrary1Chars =
      "library library1_name;\n"
      "class OldClass {\n"
      "  foo() => 'foo';\n"
      "}\n";
  const char* kSourceChars =
      "part of library1_name;\n"
      "class NewClass extends OldClass{\n"
      "  bar() => 'bar';\n"
      "}\n";
  Dart_Handle url = NewString("library1_url");
  Dart_Handle source = NewString(kLibrary1Chars);
  Dart_Handle lib = Dart_LoadLibrary(url, source);
  EXPECT_VALID(lib);
  EXPECT(Dart_IsLibrary(lib));

  // Call a dynamic function on OldClass.
  Dart_Handle cls = Dart_GetClass(lib, NewString("OldClass"));
  EXPECT_VALID(cls);
  Dart_Handle recv = Dart_New(cls, Dart_Null(), 0, NULL);
  Dart_Handle result = Dart_Invoke(recv, NewString("foo"), 0, NULL);
  EXPECT_VALID(result);
  EXPECT(Dart_IsString(result));
  const char* result_cstr = "";
  EXPECT_VALID(Dart_StringToCString(result, &result_cstr));
  EXPECT_STREQ("foo", result_cstr);

  // Load a source file late.
  url = NewString("source_url");
  source = NewString(kSourceChars);
  EXPECT_VALID(Dart_LoadSource(lib, url, source));

  // Call a dynamic function on NewClass in the updated library.
  cls = Dart_GetClass(lib, NewString("NewClass"));
  EXPECT_VALID(cls);
  recv = Dart_New(cls, Dart_Null(), 0, NULL);
  result = Dart_Invoke(recv, NewString("bar"), 0, NULL);
  EXPECT_VALID(result);
  EXPECT(Dart_IsString(result));
  result_cstr = "";
  EXPECT_VALID(Dart_StringToCString(result, &result_cstr));
  EXPECT_STREQ("bar", result_cstr);
}


TEST_CASE(LoadPatch) {
  const char* kLibrary1Chars =
      "library library1_name;";
  const char* kSourceChars =
      "part of library1_name;\n"
      "external int foo();";
  const char* kPatchChars =
      "patch int foo() => 42;";

  // Load up a library.
  Dart_Handle url = NewString("library1_url");
  Dart_Handle source = NewString(kLibrary1Chars);
  Dart_Handle lib = Dart_LoadLibrary(url, source);
  EXPECT_VALID(lib);
  EXPECT(Dart_IsLibrary(lib));

  url = NewString("source_url");
  source = NewString(kSourceChars);

  Dart_Handle result = Dart_LoadSource(lib, url, source);
  EXPECT_VALID(result);

  url = NewString("patch_url");
  source = NewString(kPatchChars);

  result = Dart_LoadPatch(lib, url, source);
  EXPECT_VALID(result);

  result = Dart_Invoke(lib, NewString("foo"), 0, NULL);
  EXPECT_VALID(result);
  EXPECT(Dart_IsInteger(result));
  int64_t value = 0;
  EXPECT_VALID(Dart_IntegerToInt64(result, &value));
  EXPECT_EQ(42, value);
}


static void PatchNativeFunction(Dart_NativeArguments args) {
  Dart_EnterScope();
  Dart_SetReturnValue(args, Dart_Null());
  Dart_ExitScope();
}


static Dart_NativeFunction PatchNativeResolver(Dart_Handle name,
                                               int arg_count) {
  return &PatchNativeFunction;
}


TEST_CASE(ParsePatchLibrary) {
  const char* kLibraryChars =
  "library patched_library;\n"
  "class A {\n"
  "  final fvalue;\n"
  "  var _f;\n"
  "  callFunc(x, y) => x(y);\n"
  "  external method(var value);\n"
  "  get field => _field;\n"
  "}\n"
  "class B {\n"
  "  var val;\n"
  "  external B.named(x);\n"
  "  external B(v);\n"
  "}\n"
  "external int unpatched();\n"
  "external int topLevel(var value);\n"
  "external int get topLevelGetter;\n"
  "external void set topLevelSetter(int value);\n";

  const char* kPatchChars =
  "patch class A {\n"
  "  var _g;\n"
  "  A() : fvalue = 13;\n"
  "  get _field => _g;\n"
  "  patch method(var value) {\n"
  "    int closeYourEyes(var eggs) { return eggs * -1; }\n"
  "    value = callFunc(closeYourEyes, value);\n"
  "    _g = value * 5;\n"
  "  }\n"
  "}\n"
  "patch class B {\n"
  "  B._internal(x) : val = x;\n"
  "  /*patch*/ factory B.named(x) { return new B._internal(x); }\n"
  "  /*patch*/ factory B(v) native \"const_B_factory\";\n"
  "}\n"
  "var _topLevelValue = -1;\n"
  "patch int topLevel(var value) => value * value;\n"
  "patch int set topLevelSetter(value) { _topLevelValue = value; }\n"
  "patch int get topLevelGetter => 2 * _topLevelValue;\n"
  // Allow top level methods named patch.
  "patch(x) => x*3;\n";

  const char* kScriptChars =
  "import 'theLibrary';\n"
  "e1() => unpatched();\n"
  "m1() => topLevel(2);\n"
  "m2() {\n"
  "  topLevelSetter = 20;\n"
  "  return topLevelGetter;\n"
  "}\n"
  "m3() => patch(7);\n"
  "m4() {\n"
  "  var a = new A();\n"
  "  a.method(5);\n"
  "  return a.field;\n"
  "}\n"
  "m5() => new B(3);\n"
  "m6() {\n"
  "  var b = new B.named(8);\n"
  "  return b.val;\n"
  "}\n"
  ;  // NOLINT

  Dart_Handle result = Dart_SetLibraryTagHandler(library_handler);
  EXPECT_VALID(result);

  Dart_Handle url = NewString("theLibrary");
  Dart_Handle source = NewString(kLibraryChars);
  result = Dart_LoadLibrary(url, source);
  EXPECT_VALID(result);

  const String& patch_url = String::Handle(String::New("theLibrary patch"));
  const String& patch_source = String::Handle(String::New(kPatchChars));
  const Script& patch_script = Script::Handle(Script::New(
      patch_url, patch_source, RawScript::kPatchTag));

  const String& lib_url = String::Handle(String::New("theLibrary"));
  const Library& lib = Library::Handle(Library::LookupLibrary(lib_url));
  const Error& err = Error::Handle(lib.Patch(patch_script));
  if (!err.IsNull()) {
    OS::Print("Patching error: %s\n", err.ToErrorCString());
    EXPECT(false);
  }
  result = Dart_SetNativeResolver(result, &PatchNativeResolver);
  EXPECT_VALID(result);

  Dart_Handle script_url = NewString("theScript");
  source = NewString(kScriptChars);
  Dart_Handle test_script = Dart_LoadScript(script_url, source, 0, 0);
  EXPECT_VALID(test_script);

  // Make sure that we can compile all of the patched code.
  result = Dart_CompileAll();
  EXPECT_VALID(result);

  result = Dart_Invoke(test_script, NewString("e1"), 0, NULL);
  EXPECT_ERROR(result, "No top-level method 'unpatched'");

  int64_t value = 0;
  result = Dart_Invoke(test_script, NewString("m1"), 0, NULL);
  EXPECT_VALID(result);
  EXPECT(Dart_IsInteger(result));
  EXPECT_VALID(Dart_IntegerToInt64(result, &value));
  EXPECT_EQ(4, value);

  value = 0;
  result = Dart_Invoke(test_script, NewString("m2"), 0, NULL);
  EXPECT_VALID(result);
  EXPECT(Dart_IsInteger(result));
  EXPECT_VALID(Dart_IntegerToInt64(result, &value));
  EXPECT_EQ(40, value);

  value = 0;
  result = Dart_Invoke(test_script, NewString("m3"), 0, NULL);
  EXPECT_VALID(result);
  EXPECT(Dart_IsInteger(result));
  EXPECT_VALID(Dart_IntegerToInt64(result, &value));
  EXPECT_EQ(21, value);

  value = 0;
  result = Dart_Invoke(test_script, NewString("m4"), 0, NULL);
  EXPECT_VALID(result);
  EXPECT(Dart_IsInteger(result));
  EXPECT_VALID(Dart_IntegerToInt64(result, &value));
  EXPECT_EQ(-25, value);

  result = Dart_Invoke(test_script, NewString("m5"), 0, NULL);
  EXPECT_VALID(result);
  EXPECT(Dart_IsNull(result));

  value = 0;
  result = Dart_Invoke(test_script, NewString("m6"), 0, NULL);
  EXPECT_VALID(result);
  EXPECT(Dart_IsInteger(result));
  EXPECT_VALID(Dart_IntegerToInt64(result, &value));
  EXPECT_EQ(8, value);
}


static void MyNativeFunction1(Dart_NativeArguments args) {
  Dart_EnterScope();
  Dart_SetReturnValue(args, Dart_NewInteger(654321));
  Dart_ExitScope();
}


static void MyNativeFunction2(Dart_NativeArguments args) {
  Dart_EnterScope();
  Dart_SetReturnValue(args, Dart_NewInteger(123456));
  Dart_ExitScope();
}


static Dart_NativeFunction MyNativeResolver1(Dart_Handle name,
                                             int arg_count) {
  return &MyNativeFunction1;
}


static Dart_NativeFunction MyNativeResolver2(Dart_Handle name,
                                             int arg_count) {
  return &MyNativeFunction2;
}


TEST_CASE(SetNativeResolver) {
  const char* kScriptChars =
      "class Test {"
      "  static foo() native \"SomeNativeFunction\";"
      "  static bar() native \"SomeNativeFunction2\";"
      "  static baz() native \"SomeNativeFunction3\";"
      "}";
  Dart_Handle error = Dart_Error("incoming error");
  Dart_Handle result;

  // Load a test script.
  Dart_Handle url = NewString(TestCase::url());
  Dart_Handle source = NewString(kScriptChars);
  result = Dart_SetLibraryTagHandler(library_handler);
  EXPECT_VALID(result);
  Dart_Handle lib = Dart_LoadScript(url, source, 0, 0);
  EXPECT_VALID(lib);
  EXPECT(Dart_IsLibrary(lib));
  Dart_Handle cls = Dart_GetClass(lib, NewString("Test"));
  EXPECT_VALID(cls);

  result = Dart_SetNativeResolver(Dart_Null(), &MyNativeResolver1);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ(
      "Dart_SetNativeResolver expects argument 'library' to be non-null.",
      Dart_GetError(result));

  result = Dart_SetNativeResolver(Dart_True(), &MyNativeResolver1);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("Dart_SetNativeResolver expects argument 'library' to be of "
               "type Library.",
               Dart_GetError(result));

  result = Dart_SetNativeResolver(error, &MyNativeResolver1);
  EXPECT(Dart_IsError(result));
  EXPECT_STREQ("incoming error", Dart_GetError(result));

  result = Dart_SetNativeResolver(lib, &MyNativeResolver1);
  EXPECT_VALID(result);

  // Call a function and make sure native resolution works.
  result = Dart_Invoke(cls, NewString("foo"), 0, NULL);
  EXPECT_VALID(result);
  EXPECT(Dart_IsInteger(result));
  int64_t value = 0;
  EXPECT_VALID(Dart_IntegerToInt64(result, &value));
  EXPECT_EQ(654321, value);

  // A second call succeeds.
  result = Dart_SetNativeResolver(lib, &MyNativeResolver2);
  EXPECT_VALID(result);

  // 'foo' has already been resolved so gets the old value.
  result = Dart_Invoke(cls, NewString("foo"), 0, NULL);
  EXPECT_VALID(result);
  EXPECT(Dart_IsInteger(result));
  value = 0;
  EXPECT_VALID(Dart_IntegerToInt64(result, &value));
  EXPECT_EQ(654321, value);

  // 'bar' has not yet been resolved so gets the new value.
  result = Dart_Invoke(cls, NewString("bar"), 0, NULL);
  EXPECT_VALID(result);
  EXPECT(Dart_IsInteger(result));
  value = 0;
  EXPECT_VALID(Dart_IntegerToInt64(result, &value));
  EXPECT_EQ(123456, value);

  // A NULL resolver is okay, but resolution will fail.
  result = Dart_SetNativeResolver(lib, NULL);
  EXPECT_VALID(result);

  EXPECT_ERROR(Dart_Invoke(cls, NewString("baz"), 0, NULL),
               "native function 'SomeNativeFunction3' cannot be found");
}


// Test that an imported name does not clash with the same name defined
// in the importing library.
TEST_CASE(ImportLibrary2) {
  const char* kScriptChars =
      "import 'library1_dart';\n"
      "var foo;\n"
      "main() { foo = 0; }\n";
  const char* kLibrary1Chars =
      "library library1_dart;\n"
      "import 'library2_dart';\n"
      "var foo;\n";
  const char* kLibrary2Chars =
      "library library2_dart;\n"
      "import 'library1_dart';\n"
      "var foo;\n";
  Dart_Handle result;
  // Create a test library and Load up a test script in it.
  Dart_Handle url = NewString(TestCase::url());
  Dart_Handle source = NewString(kScriptChars);
  result = Dart_SetLibraryTagHandler(library_handler);
  EXPECT_VALID(result);
  result = Dart_LoadScript(url, source, 0, 0);

  url = NewString("library1_dart");
  source = NewString(kLibrary1Chars);
  Dart_LoadLibrary(url, source);

  url = NewString("library2_dart");
  source = NewString(kLibrary2Chars);
  Dart_LoadLibrary(url, source);

  result = Dart_Invoke(result, NewString("main"), 0, NULL);
  EXPECT_VALID(result);
}


// Test that if the same name is imported from two libraries, it is
// an error if that name is referenced.
TEST_CASE(ImportLibrary3) {
  const char* kScriptChars =
      "import 'library2_dart';\n"
      "import 'library1_dart';\n"
      "var foo_top = 10;  // foo has dup def. So should be an error.\n"
      "main() { foo = 0; }\n";
  const char* kLibrary1Chars =
      "library library1_dart;\n"
      "var foo;";
  const char* kLibrary2Chars =
      "library library2_dart;\n"
      "var foo;";
  Dart_Handle result;

  // Create a test library and Load up a test script in it.
  Dart_Handle url = NewString(TestCase::url());
  Dart_Handle source = NewString(kScriptChars);
  result = Dart_SetLibraryTagHandler(library_handler);
  EXPECT_VALID(result);
  result = Dart_LoadScript(url, source, 0, 0);
  EXPECT_VALID(result);

  url = NewString("library2_dart");
  source = NewString(kLibrary2Chars);
  Dart_LoadLibrary(url, source);

  url = NewString("library1_dart");
  source = NewString(kLibrary1Chars);
  Dart_LoadLibrary(url, source);

  result = Dart_Invoke(result, NewString("main"), 0, NULL);
  EXPECT(Dart_IsError(result));
  EXPECT_SUBSTRING("ambiguous reference: 'foo'", Dart_GetError(result));
}


// Test that if the same name is imported from two libraries, it is
// not an error if that name is not used.
TEST_CASE(ImportLibrary4) {
  const char* kScriptChars =
      "import 'library2_dart';\n"
      "import 'library1_dart';\n"
      "main() {  }\n";
  const char* kLibrary1Chars =
      "library library1_dart;\n"
      "var foo;";
  const char* kLibrary2Chars =
      "library library2_dart;\n"
      "var foo;";
  Dart_Handle result;

  // Create a test library and Load up a test script in it.
  Dart_Handle url = NewString(TestCase::url());
  Dart_Handle source = NewString(kScriptChars);
  result = Dart_SetLibraryTagHandler(library_handler);
  EXPECT_VALID(result);
  result = Dart_LoadScript(url, source, 0, 0);
  EXPECT_VALID(result);

  url = NewString("library2_dart");
  source = NewString(kLibrary2Chars);
  Dart_LoadLibrary(url, source);

  url = NewString("library1_dart");
  source = NewString(kLibrary1Chars);
  Dart_LoadLibrary(url, source);

  result = Dart_Invoke(result, NewString("main"), 0, NULL);
  EXPECT_VALID(result);
}


TEST_CASE(ImportLibrary5) {
  const char* kScriptChars =
      "import 'lib.dart';\n"
      "abstract class Y {\n"
      "  void set handler(void callback(List<int> x));\n"
      "}\n"
      "void main() {}\n";
  const char* kLibraryChars =
      "library lib.dart;\n"
      "abstract class X {\n"
      "  void set handler(void callback(List<int> x));\n"
      "}\n";
  Dart_Handle result;

  // Create a test library and Load up a test script in it.
  Dart_Handle url = NewString(TestCase::url());
  Dart_Handle source = NewString(kScriptChars);
  result = Dart_SetLibraryTagHandler(library_handler);
  EXPECT_VALID(result);
  result = Dart_LoadScript(url, source, 0, 0);

  url = NewString("lib.dart");
  source = NewString(kLibraryChars);
  Dart_LoadLibrary(url, source);

  result = Dart_Invoke(result, NewString("main"), 0, NULL);
  EXPECT_VALID(result);
}


void NewNativePort_send123(Dart_Port dest_port_id,
                           Dart_Port reply_port_id,
                           Dart_CObject *message) {
  // Gets a null message.
  EXPECT_NOTNULL(message);
  EXPECT_EQ(Dart_CObject::kNull, message->type);

  // Post integer value.
  Dart_CObject* response =
      reinterpret_cast<Dart_CObject*>(Dart_ScopeAllocate(sizeof(Dart_CObject)));
  response->type = Dart_CObject::kInt32;
  response->value.as_int32 = 123;
  Dart_PostCObject(reply_port_id, response);
}


void NewNativePort_send321(Dart_Port dest_port_id,
                           Dart_Port reply_port_id,
                           Dart_CObject* message) {
  // Gets a null message.
  EXPECT_NOTNULL(message);
  EXPECT_EQ(Dart_CObject::kNull, message->type);

  // Post integer value.
  Dart_CObject* response =
      reinterpret_cast<Dart_CObject*>(Dart_ScopeAllocate(sizeof(Dart_CObject)));
  response->type = Dart_CObject::kInt32;
  response->value.as_int32 = 321;
  Dart_PostCObject(reply_port_id, response);
}


UNIT_TEST_CASE(NewNativePort) {
  // Create a port with a bogus handler.
  Dart_Port error_port = Dart_NewNativePort("Foo", NULL, true);
  EXPECT_EQ(ILLEGAL_PORT, error_port);

  // Create the port w/o a current isolate, just to make sure that works.
  Dart_Port port_id1 =
      Dart_NewNativePort("Port123", NewNativePort_send123, true);

  TestIsolateScope __test_isolate__;
  const char* kScriptChars =
      "import 'dart:isolate';\n"
      "void callPort(SendPort port) {\n"
      "    port.call(null).then((message) {\n"
      "      throw new Exception(message);\n"
      "    });\n"
      "}\n";
  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);
  Dart_EnterScope();

  // Create a port w/ a current isolate, to make sure that works too.
  Dart_Port port_id2 =
      Dart_NewNativePort("Port321", NewNativePort_send321, true);

  Dart_Handle send_port1 = Dart_NewSendPort(port_id1);
  EXPECT_VALID(send_port1);
  Dart_Handle send_port2 = Dart_NewSendPort(port_id2);
  EXPECT_VALID(send_port2);

  // Test first port.
  Dart_Handle dart_args[1];
  dart_args[0] = send_port1;
  Dart_Handle result =
      Dart_Invoke(lib, NewString("callPort"), 1, dart_args);
  EXPECT_VALID(result);
  result = Dart_RunLoop();
  EXPECT(Dart_IsError(result));
  EXPECT(Dart_ErrorHasException(result));
  EXPECT_SUBSTRING("Exception: 123\n", Dart_GetError(result));

  // result second port.
  dart_args[0] = send_port2;
  result = Dart_Invoke(lib, NewString("callPort"), 1, dart_args);
  EXPECT_VALID(result);
  result = Dart_RunLoop();
  EXPECT(Dart_IsError(result));
  EXPECT(Dart_ErrorHasException(result));
  EXPECT_SUBSTRING("Exception: 321\n", Dart_GetError(result));

  Dart_ExitScope();

  // Delete the native ports.
  EXPECT(Dart_CloseNativePort(port_id1));
  EXPECT(Dart_CloseNativePort(port_id2));
}


static Dart_Isolate RunLoopTestCallback(const char* script_name,
                                        const char* main,
                                        void* data,
                                        char** error) {
  const char* kScriptChars =
      "import 'builtin';\n"
      "import 'dart:isolate';\n"
      "void entry() {\n"
      "  port.receive((message, replyTo) {\n"
      "    if (message) {\n"
      "      throw new Exception('MakeChildExit');\n"
      "    } else {\n"
      "      replyTo.call('hello');\n"
      "      port.close();\n"
      "    }\n"
      "  });\n"
      "}\n"
      "\n"
      "void main(exc_child, exc_parent) {\n"
      "  var port = spawnFunction(entry);\n"
      "  port.call(exc_child).then((message) {\n"
      "    if (message != 'hello') throw new Exception('ShouldNotHappen');\n"
      "    if (exc_parent) throw new Exception('MakeParentExit');\n"
      "  });\n"
      "}\n";

  if (Dart_CurrentIsolate() != NULL) {
    Dart_ExitIsolate();
  }
  Dart_Isolate isolate = TestCase::CreateTestIsolate();
  ASSERT(isolate != NULL);
  Dart_EnterScope();
  Dart_Handle url = NewString(TestCase::url());
  Dart_Handle source = NewString(kScriptChars);
  Dart_Handle result = Dart_SetLibraryTagHandler(TestCase::library_handler);
  EXPECT_VALID(result);
  Dart_Handle lib = Dart_LoadScript(url, source, 0, 0);
  EXPECT_VALID(lib);
  Dart_ExitScope();
  Dart_ExitIsolate();
  bool retval = Dart_IsolateMakeRunnable(isolate);
  EXPECT(retval);
  return isolate;
}


// The error string from the last unhandled exception. This value is only
// valid until the next Dart_ExitScope().
static char* last_exception = NULL;


static void RunLoopUnhandledExceptionCallback(Dart_Handle exception) {
  Dart_Handle error_string = Dart_ToString(exception);
  EXPECT_VALID(error_string);
  const char* error_text;
  Dart_Handle result = Dart_StringToCString(error_string, &error_text);
  // Duplicate the string since error text is freed when callback is finished.
  last_exception = strdup(error_text);
  EXPECT_VALID(result);
}


// Common code for RunLoop_Success/RunLoop_Failure.
static void RunLoopTest(bool throw_exception_child,
                        bool throw_exception_parent) {
  Dart_IsolateCreateCallback saved = Isolate::CreateCallback();
  Isolate::SetCreateCallback(RunLoopTestCallback);
  Isolate::SetUnhandledExceptionCallback(RunLoopUnhandledExceptionCallback);
  Dart_Isolate isolate = RunLoopTestCallback(NULL, NULL, NULL, NULL);

  Dart_EnterIsolate(isolate);
  Dart_EnterScope();
  Dart_Handle lib = Dart_LookupLibrary(NewString(TestCase::url()));
  EXPECT_VALID(lib);

  Dart_Handle result;
  Dart_Handle args[2];
  args[0] = (throw_exception_child ? Dart_True() : Dart_False());
  args[1] = (throw_exception_parent ? Dart_True() : Dart_False());
  result = Dart_Invoke(lib, NewString("main"), 2, args);
  EXPECT_VALID(result);
  if (throw_exception_child) {
    // TODO(tball): fix race-condition
    // EXPECT_NOTNULL(last_exception);
    // EXPECT_STREQ("UnhandledException", last_exception);
  } else {
    result = Dart_RunLoop();
    if (throw_exception_parent) {
      EXPECT_ERROR(result, "Exception: MakeParentExit");
      EXPECT_NOTNULL(last_exception);
      EXPECT_STREQ("UnhandledException", last_exception);
    } else {
      EXPECT_VALID(result);
      EXPECT(last_exception == NULL);
    }
  }
  if (last_exception != NULL) {
    free(last_exception);
    last_exception = NULL;
  }

  Dart_ExitScope();
  Dart_ShutdownIsolate();

  Isolate::SetCreateCallback(saved);
}


UNIT_TEST_CASE(RunLoop_Success) {
  RunLoopTest(false, false);
}


// This test exits the vm.  Listed as FAIL in vm.status.
UNIT_TEST_CASE(RunLoop_ExceptionChild) {
  RunLoopTest(true, false);
}


UNIT_TEST_CASE(RunLoop_ExceptionParent) {
  RunLoopTest(false, true);
}


// Utility functions and variables for test case IsolateInterrupt starts here.
static Monitor* sync = NULL;
static Dart_Isolate shared_isolate = NULL;
static bool main_entered = false;


void MarkMainEntered(Dart_NativeArguments args) {
  Dart_EnterScope();  // Start a Dart API scope for invoking API functions.
  // Indicate that main has been entered.
  {
    MonitorLocker ml(sync);
    main_entered = true;
    ml.Notify();
  }
  Dart_SetReturnValue(args, Dart_Null());
  Dart_ExitScope();
}


static Dart_NativeFunction IsolateInterruptTestNativeLookup(
    Dart_Handle name, int argument_count) {
  return reinterpret_cast<Dart_NativeFunction>(&MarkMainEntered);
}


void BusyLoop_start(uword unused) {
  const char* kScriptChars =
      "class Native {\n"
      "  static void markMainEntered() native 'MarkMainEntered';\n"
      "}\n"
      "\n"
      "void main() {\n"
      "  Native.markMainEntered();\n"
      "  while (true) {\n"  // Infinite empty loop.
      "  }\n"
      "}\n";

  // Tell the other thread that shared_isolate is created.
  Dart_Handle lib;
  {
    sync->Enter();
    char* error = NULL;
    shared_isolate = Dart_CreateIsolate(NULL, NULL, NULL, NULL, &error);
    EXPECT(shared_isolate != NULL);
    Dart_EnterScope();
    Dart_Handle url = NewString(TestCase::url());
    Dart_Handle source = NewString(kScriptChars);
    Dart_Handle result = Dart_SetLibraryTagHandler(TestCase::library_handler);
    EXPECT_VALID(result);
    lib = Dart_LoadScript(url, source, 0, 0);
    EXPECT_VALID(lib);
    result = Dart_SetNativeResolver(lib, &IsolateInterruptTestNativeLookup);
    DART_CHECK_VALID(result);

    sync->Notify();
    sync->Exit();
  }

  Dart_Handle result = Dart_Invoke(lib, NewString("main"), 0, NULL);
  EXPECT(Dart_IsError(result));
  EXPECT(Dart_ErrorHasException(result));
  EXPECT_SUBSTRING("Unhandled exception:\nfoo\n",
                   Dart_GetError(result));

  Dart_ExitScope();
  Dart_ShutdownIsolate();

  // Tell the other thread that we are done (don't use MonitorLocker
  // as there is no current isolate any more).
  sync->Enter();
  shared_isolate = NULL;
  sync->Notify();
  sync->Exit();
}


// This callback handles isolate interrupts for the IsolateInterrupt
// test.  It ignores the first two interrupts and throws an exception
// on the third interrupt.
const int kInterruptCount = 10;
static int interrupt_count = 0;
static bool IsolateInterruptTestCallback() {
  OS::Print(" ========== Interrupt callback called #%d\n", interrupt_count + 1);
  {
    MonitorLocker ml(sync);
    interrupt_count++;
    ml.Notify();
  }
  if (interrupt_count == kInterruptCount) {
    Dart_EnterScope();
    Dart_Handle lib = Dart_LookupLibrary(NewString(TestCase::url()));
    EXPECT_VALID(lib);
    Dart_Handle exc = NewString("foo");
    EXPECT_VALID(exc);
    Dart_Handle result = Dart_ThrowException(exc);
    EXPECT_VALID(result);
    UNREACHABLE();  // Dart_ThrowException only returns if it gets an error.
    return false;
  }
  ASSERT(interrupt_count < kInterruptCount);
  return true;
}


TEST_CASE(IsolateInterrupt) {
  Dart_IsolateInterruptCallback saved = Isolate::InterruptCallback();
  Isolate::SetInterruptCallback(IsolateInterruptTestCallback);

  sync = new Monitor();
  int result = Thread::Start(BusyLoop_start, 0);
  EXPECT_EQ(0, result);

  {
    MonitorLocker ml(sync);
    // Wait for the other isolate to enter main.
    while (!main_entered) {
      ml.Wait();
    }
  }

  // Send a number of interrupts to the other isolate. All but the
  // last allow execution to continue. The last causes an exception in
  // the isolate.
  for (int i = 0; i < kInterruptCount; i++) {
    // Space out the interrupts a bit.
    OS::Sleep(i + 1);
    Dart_InterruptIsolate(shared_isolate);
    {
      MonitorLocker ml(sync);
      // Wait for interrupt_count to be increased.
      while (interrupt_count == i) {
        ml.Wait();
      }
      OS::Print(" ========== Interrupt processed #%d\n", interrupt_count);
    }
  }

  {
    MonitorLocker ml(sync);
    // Wait for our isolate to finish.
    while (shared_isolate != NULL) {
      ml.Wait();
    }
  }

  // We should have received the expected number of interrupts.
  EXPECT_EQ(kInterruptCount, interrupt_count);

  Isolate::SetInterruptCallback(saved);
}

static void* saved_callback_data;
static void IsolateShutdownTestCallback(void* callback_data) {
  saved_callback_data = callback_data;
}

UNIT_TEST_CASE(IsolateShutdown) {
  Dart_IsolateShutdownCallback saved = Isolate::ShutdownCallback();
  Isolate::SetShutdownCallback(IsolateShutdownTestCallback);

  saved_callback_data = NULL;

  void* my_data = reinterpret_cast<void*>(12345);

  // Create an isolate.
  char* err;
  Dart_Isolate isolate = Dart_CreateIsolate(NULL, NULL, NULL, my_data, &err);
  if (isolate == NULL) {
    OS::Print("Creation of isolate failed '%s'\n", err);
    free(err);
  }
  EXPECT(isolate != NULL);

  // The shutdown callback has not been called.
  EXPECT_EQ(0, reinterpret_cast<intptr_t>(saved_callback_data));

  // Shutdown the isolate.
  Dart_ShutdownIsolate();

  // The shutdown callback has been called.
  EXPECT_EQ(12345, reinterpret_cast<intptr_t>(saved_callback_data));

  Isolate::SetShutdownCallback(saved);
}

static int64_t GetValue(Dart_Handle arg) {
  EXPECT_VALID(arg);
  EXPECT(Dart_IsInteger(arg));
  int64_t value;
  EXPECT_VALID(Dart_IntegerToInt64(arg, &value));
  return value;
}

static void NativeFoo1(Dart_NativeArguments args) {
  Dart_EnterScope();
  intptr_t i = Dart_GetNativeArgumentCount(args);
  EXPECT_EQ(1, i);
  Dart_Handle arg = Dart_GetNativeArgument(args, 0);
  EXPECT_VALID(arg);
  Dart_SetReturnValue(args, Dart_NewInteger(1));
  Dart_ExitScope();
}


static void NativeFoo2(Dart_NativeArguments args) {
  Dart_EnterScope();
  intptr_t i = Dart_GetNativeArgumentCount(args);
  EXPECT_EQ(2, i);
  Dart_Handle arg = Dart_GetNativeArgument(args, 1);
  Dart_SetReturnValue(args, Dart_NewInteger(GetValue(arg)));
  Dart_ExitScope();
}


static void NativeFoo3(Dart_NativeArguments args) {
  Dart_EnterScope();
  intptr_t i = Dart_GetNativeArgumentCount(args);
  EXPECT_EQ(3, i);
  Dart_Handle arg1 = Dart_GetNativeArgument(args, 1);
  Dart_Handle arg2 = Dart_GetNativeArgument(args, 2);
  Dart_SetReturnValue(args, Dart_NewInteger(GetValue(arg1) + GetValue(arg2)));
  Dart_ExitScope();
}


static void NativeFoo4(Dart_NativeArguments args) {
  Dart_EnterScope();
  intptr_t i = Dart_GetNativeArgumentCount(args);
  EXPECT_EQ(4, i);
  Dart_Handle arg1 = Dart_GetNativeArgument(args, 1);
  Dart_Handle arg2 = Dart_GetNativeArgument(args, 2);
  Dart_Handle arg3 = Dart_GetNativeArgument(args, 3);
  Dart_SetReturnValue(args, Dart_NewInteger(GetValue(arg1) +
                                            GetValue(arg2) +
                                            GetValue(arg3)));
  Dart_ExitScope();
}


static Dart_NativeFunction MyNativeClosureResolver(Dart_Handle name,
                                                   int arg_count) {
  const Object& obj = Object::Handle(Api::UnwrapHandle(name));
  if (!obj.IsString()) {
    return NULL;
  }
  const char* function_name = obj.ToCString();
  const char* kNativeFoo1 = "NativeFoo1";
  const char* kNativeFoo2 = "NativeFoo2";
  const char* kNativeFoo3 = "NativeFoo3";
  const char* kNativeFoo4 = "NativeFoo4";
  if (!strncmp(function_name, kNativeFoo1, strlen(kNativeFoo1))) {
    return &NativeFoo1;
  } else if (!strncmp(function_name, kNativeFoo2, strlen(kNativeFoo2))) {
    return &NativeFoo2;
  } else if (!strncmp(function_name, kNativeFoo3, strlen(kNativeFoo3))) {
    return &NativeFoo3;
  } else if (!strncmp(function_name, kNativeFoo4, strlen(kNativeFoo4))) {
    return &NativeFoo4;
  } else {
    UNREACHABLE();
    return NULL;
  }
}


TEST_CASE(NativeFunctionClosure) {
  const char* kScriptChars =
      "class Test {"
      "  int foo1() native \"NativeFoo1\";\n"
      "  int foo2(int i) native \"NativeFoo2\";\n"
      "  int foo3([int k = 10000, int l = 1]) native \"NativeFoo3\";\n"
      "  int foo4(int i,"
      "           [int j = 10, int k = 1]) native \"NativeFoo4\";\n"
      "  int bar1() { var func = foo1; return func(); }\n"
      "  int bar2(int i) { var func = foo2; return func(i); }\n"
      "  int bar30() { var func = foo3; return func(); }\n"
      "  int bar31(int i) { var func = foo3; return func(i); }\n"
      "  int bar32(int i, int j) { var func = foo3; return func(i, j); }\n"
      "  int bar41(int i) {\n"
      "    var func = foo4; return func(i); }\n"
      "  int bar42(int i, int j) {\n"
      "    var func = foo4; return func(i, j); }\n"
      "  int bar43(int i, int j, int k) {\n"
      "    var func = foo4; return func(i, j, k); }\n"
      "}\n"
      "class Expect {\n"
      "  static equals(a, b) {\n"
      "    if (a != b) {\n"
      "      throw 'not equal. expected: $a, got: $b';\n"
      "    }\n"
      "  }\n"
      "}\n"
      "int testMain() {\n"
      "  Test obj = new Test();\n"
      "  Expect.equals(1, obj.foo1());\n"
      "  Expect.equals(1, obj.bar1());\n"
      "\n"
      "  Expect.equals(10, obj.foo2(10));\n"
      "  Expect.equals(10, obj.bar2(10));\n"
      "\n"
      "  Expect.equals(10001, obj.foo3());\n"
      "  Expect.equals(10001, obj.bar30());\n"
      "  Expect.equals(2, obj.foo3(1));\n"
      "  Expect.equals(2, obj.bar31(1));\n"
      "  Expect.equals(4, obj.foo3(2, 2));\n"
      "  Expect.equals(4, obj.bar32(2, 2));\n"
      "\n"
      "  Expect.equals(12, obj.foo4(1));\n"
      "  Expect.equals(12, obj.bar41(1));\n"
      "  Expect.equals(3, obj.foo4(1, 1));\n"
      "  Expect.equals(3, obj.bar42(1, 1));\n"
      "  Expect.equals(6, obj.foo4(2, 2, 2));\n"
      "  Expect.equals(6, obj.bar43(2, 2, 2));\n"
      "\n"
      "  return 0;\n"
      "}\n";

  Dart_Handle result;

  // Load a test script.
  Dart_Handle url = NewString(TestCase::url());
  Dart_Handle source = NewString(kScriptChars);
  result = Dart_SetLibraryTagHandler(library_handler);
  EXPECT_VALID(result);
  Dart_Handle lib = Dart_LoadScript(url, source, 0, 0);
  EXPECT_VALID(lib);
  EXPECT(Dart_IsLibrary(lib));
  result = Dart_SetNativeResolver(lib, &MyNativeClosureResolver);
  EXPECT_VALID(result);

  result = Dart_Invoke(lib, NewString("testMain"), 0, NULL);
  EXPECT_VALID(result);
  EXPECT(Dart_IsInteger(result));
  int64_t value = 0;
  EXPECT_VALID(Dart_IntegerToInt64(result, &value));
  EXPECT_EQ(0, value);
}


static void StaticNativeFoo1(Dart_NativeArguments args) {
  Dart_EnterScope();
  intptr_t i = Dart_GetNativeArgumentCount(args);
  EXPECT_EQ(0, i);
  Dart_SetReturnValue(args, Dart_NewInteger(0));
  Dart_ExitScope();
}


static void StaticNativeFoo2(Dart_NativeArguments args) {
  Dart_EnterScope();
  intptr_t i = Dart_GetNativeArgumentCount(args);
  EXPECT_EQ(1, i);
  Dart_Handle arg = Dart_GetNativeArgument(args, 0);
  Dart_SetReturnValue(args, Dart_NewInteger(GetValue(arg)));
  Dart_ExitScope();
}


static void StaticNativeFoo3(Dart_NativeArguments args) {
  Dart_EnterScope();
  intptr_t i = Dart_GetNativeArgumentCount(args);
  EXPECT_EQ(2, i);
  Dart_Handle arg1 = Dart_GetNativeArgument(args, 0);
  Dart_Handle arg2 = Dart_GetNativeArgument(args, 1);
  Dart_SetReturnValue(args, Dart_NewInteger(GetValue(arg1) + GetValue(arg2)));
  Dart_ExitScope();
}


static void StaticNativeFoo4(Dart_NativeArguments args) {
  Dart_EnterScope();
  intptr_t i = Dart_GetNativeArgumentCount(args);
  EXPECT_EQ(3, i);
  Dart_Handle arg1 = Dart_GetNativeArgument(args, 0);
  Dart_Handle arg2 = Dart_GetNativeArgument(args, 1);
  Dart_Handle arg3 = Dart_GetNativeArgument(args, 2);
  Dart_SetReturnValue(args, Dart_NewInteger(GetValue(arg1) +
                                            GetValue(arg2) +
                                            GetValue(arg3)));
  Dart_ExitScope();
}


static Dart_NativeFunction MyStaticNativeClosureResolver(Dart_Handle name,
                                                         int arg_count) {
  const Object& obj = Object::Handle(Api::UnwrapHandle(name));
  if (!obj.IsString()) {
    return NULL;
  }
  const char* function_name = obj.ToCString();
  const char* kNativeFoo1 = "StaticNativeFoo1";
  const char* kNativeFoo2 = "StaticNativeFoo2";
  const char* kNativeFoo3 = "StaticNativeFoo3";
  const char* kNativeFoo4 = "StaticNativeFoo4";
  if (!strncmp(function_name, kNativeFoo1, strlen(kNativeFoo1))) {
    return &StaticNativeFoo1;
  } else if (!strncmp(function_name, kNativeFoo2, strlen(kNativeFoo2))) {
    return &StaticNativeFoo2;
  } else if (!strncmp(function_name, kNativeFoo3, strlen(kNativeFoo3))) {
    return &StaticNativeFoo3;
  } else if (!strncmp(function_name, kNativeFoo4, strlen(kNativeFoo4))) {
    return &StaticNativeFoo4;
  } else {
    UNREACHABLE();
    return NULL;
  }
}


TEST_CASE(NativeStaticFunctionClosure) {
  const char* kScriptChars =
      "class Test {"
      "  static int foo1() native \"StaticNativeFoo1\";\n"
      "  static int foo2(int i) native \"StaticNativeFoo2\";\n"
      "  static int foo3([int k = 10000, int l = 1])"
            " native \"StaticNativeFoo3\";\n"
      "  static int foo4(int i, [int j = 10, int k = 1])"
            " native \"StaticNativeFoo4\";\n"
      "  int bar1() { var func = foo1; return func(); }\n"
      "  int bar2(int i) { var func = foo2; return func(i); }\n"
      "  int bar30() { var func = foo3; return func(); }\n"
      "  int bar31(int i) { var func = foo3; return func(i); }\n"
      "  int bar32(int i, int j) { var func = foo3; return func(i, j); }\n"
      "  int bar41(int i) {\n"
      "    var func = foo4; return func(i); }\n"
      "  int bar42(int i, int j) {\n"
      "    var func = foo4; return func(i, j); }\n"
      "  int bar43(int i, int j, int k) {\n"
      "    var func = foo4; return func(i, j, k); }\n"
      "}\n"
      "class Expect {\n"
      "  static equals(a, b) {\n"
      "    if (a != b) {\n"
      "      throw 'not equal. expected: $a, got: $b';\n"
      "    }\n"
      "  }\n"
      "}\n"
      "int testMain() {\n"
      "  Test obj = new Test();\n"
      "  Expect.equals(0, Test.foo1());\n"
      "  Expect.equals(0, obj.bar1());\n"
      "\n"
      "  Expect.equals(10, Test.foo2(10));\n"
      "  Expect.equals(10, obj.bar2(10));\n"
      "\n"
      "  Expect.equals(10001, Test.foo3());\n"
      "  Expect.equals(10001, obj.bar30());\n"
      "  Expect.equals(2, Test.foo3(1));\n"
      "  Expect.equals(2, obj.bar31(1));\n"
      "  Expect.equals(4, Test.foo3(2, 2));\n"
      "  Expect.equals(4, obj.bar32(2, 2));\n"
      "\n"
      "  Expect.equals(12, Test.foo4(1));\n"
      "  Expect.equals(12, obj.bar41(1));\n"
      "  Expect.equals(3, Test.foo4(1, 1));\n"
      "  Expect.equals(3, obj.bar42(1, 1));\n"
      "  Expect.equals(6, Test.foo4(2, 2, 2));\n"
      "  Expect.equals(6, obj.bar43(2, 2, 2));\n"
      "\n"
      "  return 0;\n"
      "}\n";

  Dart_Handle result;

  // Load a test script.
  Dart_Handle url = NewString(TestCase::url());
  Dart_Handle source = NewString(kScriptChars);
  result = Dart_SetLibraryTagHandler(library_handler);
  EXPECT_VALID(result);
  Dart_Handle lib = Dart_LoadScript(url, source, 0, 0);
  EXPECT_VALID(lib);
  EXPECT(Dart_IsLibrary(lib));
  result = Dart_SetNativeResolver(lib, &MyStaticNativeClosureResolver);
  EXPECT_VALID(result);

  result = Dart_Invoke(lib, NewString("testMain"), 0, NULL);
  EXPECT_VALID(result);
  EXPECT(Dart_IsInteger(result));
  int64_t value = 0;
  EXPECT_VALID(Dart_IntegerToInt64(result, &value));
  EXPECT_EQ(0, value);
}


TEST_CASE(RangeLimits) {
  uint8_t chars8[1] = {'a'};
  uint16_t chars16[1] = {'a'};
  int32_t chars32[1] = {'a'};

  EXPECT_ERROR(Dart_NewList(-1),
               "expects argument 'length' to be in the range");
  EXPECT_ERROR(Dart_NewList(Array::kMaxElements+1),
               "expects argument 'length' to be in the range");
  EXPECT_ERROR(Dart_NewStringFromUTF8(chars8, -1),
               "expects argument 'length' to be in the range");
  EXPECT_ERROR(Dart_NewStringFromUTF8(chars8, OneByteString::kMaxElements+1),
               "expects argument 'length' to be in the range");
  EXPECT_ERROR(Dart_NewStringFromUTF16(chars16, -1),
               "expects argument 'length' to be in the range");
  EXPECT_ERROR(Dart_NewStringFromUTF16(chars16, TwoByteString::kMaxElements+1),
               "expects argument 'length' to be in the range");
  EXPECT_ERROR(Dart_NewStringFromUTF32(chars32, -1),
               "expects argument 'length' to be in the range");
  EXPECT_ERROR(Dart_NewStringFromUTF32(chars32, TwoByteString::kMaxElements+1),
               "expects argument 'length' to be in the range");
}


TEST_CASE(NewString_Null) {
  Dart_Handle str = Dart_NewStringFromUTF8(NULL, 0);
  EXPECT_VALID(str);
  EXPECT(Dart_IsString(str));
  intptr_t len = -1;
  EXPECT_VALID(Dart_StringLength(str, &len));
  EXPECT_EQ(0, len);

  str = Dart_NewStringFromUTF16(NULL, 0);
  EXPECT_VALID(str);
  EXPECT(Dart_IsString(str));
  len = -1;
  EXPECT_VALID(Dart_StringLength(str, &len));
  EXPECT_EQ(0, len);

  str = Dart_NewStringFromUTF32(NULL, 0);
  EXPECT_VALID(str);
  EXPECT(Dart_IsString(str));
  len = -1;
  EXPECT_VALID(Dart_StringLength(str, &len));
  EXPECT_EQ(0, len);
}


// Try to allocate a peer with a handles to objects of prohibited
// subtypes.
TEST_CASE(InvalidGetSetPeer) {
  void* out = &out;
  EXPECT(Dart_IsError(Dart_GetPeer(Dart_Null(), &out)));
  EXPECT(out == &out);
  EXPECT(Dart_IsError(Dart_SetPeer(Dart_Null(), &out)));
  out = &out;
  EXPECT(Dart_IsError(Dart_GetPeer(Dart_True(), &out)));
  EXPECT(out == &out);
  EXPECT(Dart_IsError(Dart_SetPeer(Dart_True(), &out)));
  out = &out;
  EXPECT(Dart_IsError(Dart_GetPeer(Dart_False(), &out)));
  EXPECT(out == &out);
  EXPECT(Dart_IsError(Dart_SetPeer(Dart_False(), &out)));
  out = &out;
  Dart_Handle smi = Dart_NewInteger(0);
  EXPECT(Dart_IsError(Dart_GetPeer(smi, &out)));
  EXPECT(out == &out);
  EXPECT(Dart_IsError(Dart_SetPeer(smi, &out)));
  out = &out;
  Dart_Handle big = Dart_NewIntegerFromHexCString("0x10000000000000000");
  EXPECT(Dart_IsError(Dart_GetPeer(big, &out)));
  EXPECT(out == &out);
  EXPECT(Dart_IsError(Dart_SetPeer(big, &out)));
  Dart_Handle dbl = Dart_NewDouble(0.0);
  EXPECT(Dart_IsError(Dart_GetPeer(dbl, &out)));
  EXPECT(out == &out);
  EXPECT(Dart_IsError(Dart_SetPeer(dbl, &out)));
}


// Allocates an object in new space and assigns it a peer.  Removes
// the peer and checks that the count of peer objects is decremented
// by one.
TEST_CASE(OneNewSpacePeer) {
  Isolate* isolate = Isolate::Current();
  Dart_Handle str = NewString("a string");
  EXPECT_VALID(str);
  EXPECT(Dart_IsString(str));
  EXPECT_EQ(0, isolate->heap()->PeerCount());
  void* out = &out;
  EXPECT_VALID(Dart_GetPeer(str, &out));
  EXPECT(out == NULL);
  int peer = 1234;
  EXPECT_VALID(Dart_SetPeer(str, &peer));
  EXPECT_EQ(1, isolate->heap()->PeerCount());
  out = &out;
  EXPECT_VALID(Dart_GetPeer(str, &out));
  EXPECT(out == reinterpret_cast<void*>(&peer));
  EXPECT_VALID(Dart_SetPeer(str, NULL));
  out = &out;
  EXPECT_VALID(Dart_GetPeer(str, &out));
  EXPECT(out == NULL);
  EXPECT_EQ(0, isolate->heap()->PeerCount());
}


// Allocates an object in new space and assigns it a peer.  Allows the
// peer referent to be garbage collected and checks that the count of
// peer objects is decremented by one.
TEST_CASE(CollectOneNewSpacePeer) {
  Isolate* isolate = Isolate::Current();
  Dart_EnterScope();
  {
    DARTSCOPE(isolate);
    Dart_Handle str = NewString("a string");
    EXPECT_VALID(str);
    EXPECT(Dart_IsString(str));
    EXPECT_EQ(0, isolate->heap()->PeerCount());
    void* out = &out;
    EXPECT_VALID(Dart_GetPeer(str, &out));
    EXPECT(out == NULL);
    int peer = 1234;
    EXPECT_VALID(Dart_SetPeer(str, &peer));
    EXPECT_EQ(1, isolate->heap()->PeerCount());
    out = &out;
    EXPECT_VALID(Dart_GetPeer(str, &out));
    EXPECT(out == reinterpret_cast<void*>(&peer));
    isolate->heap()->CollectGarbage(Heap::kNew);
    EXPECT_EQ(1, isolate->heap()->PeerCount());
    out = &out;
    EXPECT_VALID(Dart_GetPeer(str, &out));
    EXPECT(out == reinterpret_cast<void*>(&peer));
  }
  Dart_ExitScope();
  isolate->heap()->CollectGarbage(Heap::kNew);
  EXPECT_EQ(0, isolate->heap()->PeerCount());
}


// Allocates two objects in new space and assigns them peers.  Removes
// the peers and checks that the count of peer objects is decremented
// by two.
TEST_CASE(TwoNewSpacePeers) {
  Isolate* isolate = Isolate::Current();
  Dart_Handle s1 = NewString("s1");
  EXPECT_VALID(s1);
  EXPECT(Dart_IsString(s1));
  void* o1 = &o1;
  EXPECT_VALID(Dart_GetPeer(s1, &o1));
  EXPECT(o1 == NULL);
  EXPECT_EQ(0, isolate->heap()->PeerCount());
  int p1 = 1234;
  EXPECT_VALID(Dart_SetPeer(s1, &p1));
  EXPECT_EQ(1, isolate->heap()->PeerCount());
  EXPECT_VALID(Dart_GetPeer(s1, &o1));
  EXPECT(o1 == reinterpret_cast<void*>(&p1));
  Dart_Handle s2 = NewString("a string");
  EXPECT_VALID(s2);
  EXPECT(Dart_IsString(s2));
  EXPECT_EQ(1, isolate->heap()->PeerCount());
  void* o2 = &o2;
  EXPECT(Dart_GetPeer(s2, &o2));
  EXPECT(o2 == NULL);
  int p2 = 5678;
  EXPECT_VALID(Dart_SetPeer(s2, &p2));
  EXPECT_EQ(2, isolate->heap()->PeerCount());
  EXPECT_VALID(Dart_GetPeer(s2, &o2));
  EXPECT(o2 == reinterpret_cast<void*>(&p2));
  EXPECT_VALID(Dart_SetPeer(s1, NULL));
  EXPECT_EQ(1, isolate->heap()->PeerCount());
  EXPECT(Dart_GetPeer(s1, &o1));
  EXPECT(o1 == NULL);
  EXPECT_VALID(Dart_SetPeer(s2, NULL));
  EXPECT_EQ(0, isolate->heap()->PeerCount());
  EXPECT(Dart_GetPeer(s2, &o2));
  EXPECT(o2 == NULL);
}


// Allocates two objects in new space and assigns them a peer.  Allow
// the peer referents to be garbage collected and check that the count
// of peer objects is decremented by two.
TEST_CASE(CollectTwoNewSpacePeers) {
  Isolate* isolate = Isolate::Current();
  Dart_EnterScope();
  {
    DARTSCOPE(isolate);
    Dart_Handle s1 = NewString("s1");
    EXPECT_VALID(s1);
    EXPECT(Dart_IsString(s1));
    EXPECT_EQ(0, isolate->heap()->PeerCount());
    void* o1 = &o1;
    EXPECT(Dart_GetPeer(s1, &o1));
    EXPECT(o1 == NULL);
    int p1 = 1234;
    EXPECT_VALID(Dart_SetPeer(s1, &p1));
    EXPECT_EQ(1, isolate->heap()->PeerCount());
    EXPECT_VALID(Dart_GetPeer(s1, &o1));
    EXPECT(o1 == reinterpret_cast<void*>(&p1));
    Dart_Handle s2 = NewString("s2");
    EXPECT_VALID(s2);
    EXPECT(Dart_IsString(s2));
    EXPECT_EQ(1, isolate->heap()->PeerCount());
    void* o2 = &o2;
    EXPECT(Dart_GetPeer(s2, &o2));
    EXPECT(o2 == NULL);
    int p2 = 5678;
    EXPECT_VALID(Dart_SetPeer(s2, &p2));
    EXPECT_EQ(2, isolate->heap()->PeerCount());
    EXPECT_VALID(Dart_GetPeer(s2, &o2));
    EXPECT(o2 == reinterpret_cast<void*>(&p2));
  }
  Dart_ExitScope();
  isolate->heap()->CollectGarbage(Heap::kNew);
  EXPECT_EQ(0, isolate->heap()->PeerCount());
}


// Allocates several objects in new space.  Performs successive
// garbage collections and checks that the peer count is stable.
TEST_CASE(CopyNewSpacePeers) {
  const int kPeerCount = 10;
  Isolate* isolate = Isolate::Current();
  Dart_Handle s[kPeerCount];
  for (int i = 0; i < kPeerCount; ++i) {
    s[i] = NewString("a string");
    EXPECT_VALID(s[i]);
    EXPECT(Dart_IsString(s[i]));
    void* o = &o;
    EXPECT_VALID(Dart_GetPeer(s[i], &o));
    EXPECT(o == NULL);
  }
  EXPECT_EQ(0, isolate->heap()->PeerCount());
  int p[kPeerCount];
  for (int i = 0; i < kPeerCount; ++i) {
    EXPECT_VALID(Dart_SetPeer(s[i], &p[i]));
    EXPECT_EQ(i + 1, isolate->heap()->PeerCount());
    void* o = &o;
    EXPECT_VALID(Dart_GetPeer(s[i], &o));
    EXPECT(o == reinterpret_cast<void*>(&p[i]));
  }
  EXPECT_EQ(kPeerCount, isolate->heap()->PeerCount());
  isolate->heap()->CollectGarbage(Heap::kNew);
  EXPECT_EQ(kPeerCount, isolate->heap()->PeerCount());
  isolate->heap()->CollectGarbage(Heap::kNew);
  EXPECT_EQ(kPeerCount, isolate->heap()->PeerCount());
}


// Allocates an object in new space and assigns it a peer.  Promotes
// the peer to old space.  Removes the peer and check that the count
// of peer objects is decremented by one.
TEST_CASE(OnePromotedPeer) {
  Isolate* isolate = Isolate::Current();
  Dart_Handle str = NewString("a string");
  EXPECT_VALID(str);
  EXPECT(Dart_IsString(str));
  EXPECT_EQ(0, isolate->heap()->PeerCount());
  void* out = &out;
  EXPECT(Dart_GetPeer(str, &out));
  EXPECT(out == NULL);
  int peer = 1234;
  EXPECT_VALID(Dart_SetPeer(str, &peer));
  out = &out;
  EXPECT(Dart_GetPeer(str, &out));
  EXPECT(out == reinterpret_cast<void*>(&peer));
  EXPECT_EQ(1, isolate->heap()->PeerCount());
  isolate->heap()->CollectGarbage(Heap::kNew);
  isolate->heap()->CollectGarbage(Heap::kNew);
  {
    DARTSCOPE(isolate);
    String& handle = String::Handle();
    handle ^= Api::UnwrapHandle(str);
    EXPECT(handle.IsOld());
  }
  EXPECT_VALID(Dart_GetPeer(str, &out));
  EXPECT(out == reinterpret_cast<void*>(&peer));
  EXPECT_EQ(1, isolate->heap()->PeerCount());
  EXPECT_VALID(Dart_SetPeer(str, NULL));
  out = &out;
  EXPECT_VALID(Dart_GetPeer(str, &out));
  EXPECT(out == NULL);
  EXPECT_EQ(0, isolate->heap()->PeerCount());
}


// Allocates an object in old space and assigns it a peer.  Removes
// the peer and checks that the count of peer objects is decremented
// by one.
TEST_CASE(OneOldSpacePeer) {
  Isolate* isolate = Isolate::Current();
  Dart_Handle str = Api::NewHandle(isolate, String::New("str", Heap::kOld));
  EXPECT_VALID(str);
  EXPECT(Dart_IsString(str));
  EXPECT_EQ(0, isolate->heap()->PeerCount());
  void* out = &out;
  EXPECT(Dart_GetPeer(str, &out));
  EXPECT(out == NULL);
  int peer = 1234;
  EXPECT_VALID(Dart_SetPeer(str, &peer));
  EXPECT_EQ(1, isolate->heap()->PeerCount());
  out = &out;
  EXPECT_VALID(Dart_GetPeer(str, &out));
  EXPECT(out == reinterpret_cast<void*>(&peer));
  isolate->heap()->CollectGarbage(Heap::kOld);
  EXPECT_EQ(1, isolate->heap()->PeerCount());
  EXPECT_VALID(Dart_GetPeer(str, &out));
  EXPECT(out == reinterpret_cast<void*>(&peer));
  EXPECT_VALID(Dart_SetPeer(str, NULL));
  out = &out;
  EXPECT_VALID(Dart_GetPeer(str, &out));
  EXPECT(out == NULL);
  EXPECT_EQ(0, isolate->heap()->PeerCount());
}


// Allocates an object in old space and assigns it a peer.  Allow the
// peer referent to be garbage collected and check that the count of
// peer objects is decremented by one.
TEST_CASE(CollectOneOldSpacePeer) {
  Isolate* isolate = Isolate::Current();
  Dart_EnterScope();
  {
    DARTSCOPE(isolate);
    Dart_Handle str = Api::NewHandle(isolate, String::New("str", Heap::kOld));
    EXPECT_VALID(str);
    EXPECT(Dart_IsString(str));
    EXPECT_EQ(0, isolate->heap()->PeerCount());
    void* out = &out;
    EXPECT(Dart_GetPeer(str, &out));
    EXPECT(out == NULL);
    int peer = 1234;
    EXPECT_VALID(Dart_SetPeer(str, &peer));
    EXPECT_EQ(1, isolate->heap()->PeerCount());
    out = &out;
    EXPECT_VALID(Dart_GetPeer(str, &out));
    EXPECT(out == reinterpret_cast<void*>(&peer));
    isolate->heap()->CollectGarbage(Heap::kOld);
    EXPECT_EQ(1, isolate->heap()->PeerCount());
    EXPECT_VALID(Dart_GetPeer(str, &out));
    EXPECT(out == reinterpret_cast<void*>(&peer));
  }
  Dart_ExitScope();
  isolate->heap()->CollectGarbage(Heap::kOld);
  EXPECT_EQ(0, isolate->heap()->PeerCount());
}


// Allocates two objects in old space and assigns them peers.  Removes
// the peers and checks that the count of peer objects is decremented
// by two.
TEST_CASE(TwoOldSpacePeers) {
  Isolate* isolate = Isolate::Current();
  Dart_Handle s1 = Api::NewHandle(isolate, String::New("s1", Heap::kOld));
  EXPECT_VALID(s1);
  EXPECT(Dart_IsString(s1));
  EXPECT_EQ(0, isolate->heap()->PeerCount());
  void* o1 = &o1;
  EXPECT(Dart_GetPeer(s1, &o1));
  EXPECT(o1 == NULL);
  int p1 = 1234;
  EXPECT_VALID(Dart_SetPeer(s1, &p1));
  EXPECT_EQ(1, isolate->heap()->PeerCount());
  o1 = &o1;
  EXPECT_VALID(Dart_GetPeer(s1, &o1));
  EXPECT(o1 == reinterpret_cast<void*>(&p1));
  Dart_Handle s2 = Api::NewHandle(isolate, String::New("s2", Heap::kOld));
  EXPECT_VALID(s2);
  EXPECT(Dart_IsString(s2));
  EXPECT_EQ(1, isolate->heap()->PeerCount());
  void* o2 = &o2;
  EXPECT(Dart_GetPeer(s2, &o2));
  EXPECT(o2 == NULL);
  int p2 = 5678;
  EXPECT_VALID(Dart_SetPeer(s2, &p2));
  EXPECT_EQ(2, isolate->heap()->PeerCount());
  o2 = &o2;
  EXPECT_VALID(Dart_GetPeer(s2, &o2));
  EXPECT(o2 == reinterpret_cast<void*>(&p2));
  EXPECT_VALID(Dart_SetPeer(s1, NULL));
  EXPECT_EQ(1, isolate->heap()->PeerCount());
  o1 = &o1;
  EXPECT(Dart_GetPeer(s1, &o1));
  EXPECT(o1 == NULL);
  EXPECT_VALID(Dart_SetPeer(s2, NULL));
  EXPECT_EQ(0, isolate->heap()->PeerCount());
  o2 = &o2;
  EXPECT_VALID(Dart_GetPeer(s2, &o2));
  EXPECT(o2 == NULL);
}


// Allocates two objects in old space and assigns them a peer.  Allows
// the peer referents to be garbage collected and checks that the
// count of peer objects is decremented by two.
TEST_CASE(CollectTwoOldSpacePeers) {
  Isolate* isolate = Isolate::Current();
  Dart_EnterScope();
  {
    DARTSCOPE(isolate);
    Dart_Handle s1 = Api::NewHandle(isolate, String::New("s1", Heap::kOld));
    EXPECT_VALID(s1);
    EXPECT(Dart_IsString(s1));
    EXPECT_EQ(0, isolate->heap()->PeerCount());
    void* o1 = &o1;
    EXPECT(Dart_GetPeer(s1, &o1));
    EXPECT(o1 == NULL);
    int p1 = 1234;
    EXPECT_VALID(Dart_SetPeer(s1, &p1));
    EXPECT_EQ(1, isolate->heap()->PeerCount());
    o1 = &o1;
    EXPECT_VALID(Dart_GetPeer(s1, &o1));
    EXPECT(o1 == reinterpret_cast<void*>(&p1));
    Dart_Handle s2 = Api::NewHandle(isolate, String::New("s2", Heap::kOld));
    EXPECT_VALID(s2);
    EXPECT(Dart_IsString(s2));
    EXPECT_EQ(1, isolate->heap()->PeerCount());
    void* o2 = &o2;
    EXPECT(Dart_GetPeer(s2, &o2));
    EXPECT(o2 == NULL);
    int p2 = 5678;
    EXPECT_VALID(Dart_SetPeer(s2, &p2));
    EXPECT_EQ(2, isolate->heap()->PeerCount());
    o2 = &o2;
    EXPECT_VALID(Dart_GetPeer(s2, &o2));
    EXPECT(o2 == reinterpret_cast<void*>(&p2));
  }
  Dart_ExitScope();
  isolate->heap()->CollectGarbage(Heap::kOld);
  EXPECT_EQ(0, isolate->heap()->PeerCount());
}


// Test API call to make strings external.
static void MakeExternalCback(void* peer) {
  *static_cast<int*>(peer) *= 2;
}


TEST_CASE(MakeExternalString) {
  int peer8 = 40;
  int peer16 = 41;
  intptr_t length = 0;
  intptr_t expected_length = 0;
  {
    Dart_EnterScope();

    // First test some negative conditions.
    uint8_t data8[] = { 'h', 'e', 'l', 'l', 'o' };
    const char* err = "string";
    Dart_Handle err_str = NewString(err);
    Dart_Handle ext_err_str = Dart_NewExternalLatin1String(
        data8, ARRAY_SIZE(data8), NULL, NULL);
    Dart_Handle result = Dart_MakeExternalString(Dart_Null(),
                                                 data8,
                                                 ARRAY_SIZE(data8),
                                                 NULL,
                                                 NULL);
    EXPECT(Dart_IsError(result));  // Null string object passed in.
    result = Dart_MakeExternalString(err_str,
                                     NULL,
                                     ARRAY_SIZE(data8),
                                     NULL,
                                     NULL);
    EXPECT(Dart_IsError(result));  // Null array pointer passed in.
    result = Dart_MakeExternalString(err_str,
                                     data8,
                                     1,
                                     NULL,
                                     NULL);
    EXPECT(Dart_IsError(result));  // Invalid length passed in.

    const intptr_t kLength = 10;
    intptr_t size = 0;

    // Test with an external string.
    result = Dart_MakeExternalString(ext_err_str,
                                     data8,
                                     ARRAY_SIZE(data8),
                                     NULL,
                                     NULL);
    EXPECT(Dart_IsString(result));
    EXPECT(Dart_IsExternalString(result));

    // Test with an empty string.
    Dart_Handle empty_str = NewString("");
    EXPECT(Dart_IsString(empty_str));
    EXPECT(!Dart_IsExternalString(empty_str));
    uint8_t ext_empty_str[kLength];
    Dart_Handle str = Dart_MakeExternalString(empty_str,
                                              ext_empty_str,
                                              kLength,
                                              NULL,
                                              NULL);
    EXPECT(Dart_IsString(str));
    EXPECT(Dart_IsString(empty_str));
    EXPECT(Dart_IsStringLatin1(str));
    EXPECT(Dart_IsStringLatin1(empty_str));
    EXPECT(Dart_IsExternalString(str));
    EXPECT(Dart_IsExternalString(empty_str));
    EXPECT_VALID(Dart_StringLength(str, &length));
    EXPECT_EQ(0, length);

    // Test with a one byte ascii string.
    const char* ascii = "string";
    expected_length = strlen(ascii);
    Dart_Handle ascii_str = NewString(ascii);
    EXPECT_VALID(ascii_str);
    EXPECT(Dart_IsString(ascii_str));
    EXPECT(Dart_IsStringLatin1(ascii_str));
    EXPECT(!Dart_IsExternalString(ascii_str));
    EXPECT_VALID(Dart_StringLength(ascii_str, &length));
    EXPECT_EQ(expected_length, length);

    uint8_t ext_ascii_str[kLength];
    EXPECT_VALID(Dart_StringStorageSize(ascii_str, &size));
    str = Dart_MakeExternalString(ascii_str,
                                  ext_ascii_str,
                                  size,
                                  &peer8,
                                  MakeExternalCback);
    EXPECT(Dart_IsString(str));
    EXPECT(Dart_IsString(ascii_str));
    EXPECT(Dart_IsStringLatin1(str));
    EXPECT(Dart_IsStringLatin1(ascii_str));
    EXPECT(Dart_IsExternalString(str));
    EXPECT(Dart_IsExternalString(ascii_str));
    EXPECT_VALID(Dart_StringLength(str, &length));
    EXPECT_EQ(expected_length, length);
    EXPECT_VALID(Dart_StringLength(ascii_str, &length));
    EXPECT_EQ(expected_length, length);
    EXPECT(Dart_IdentityEquals(str, ascii_str));
    for (intptr_t i = 0; i < length; i++) {
      EXPECT_EQ(ascii[i], ext_ascii_str[i]);
    }

    uint8_t data[] = { 0xE4, 0xBA, 0x8c };  // U+4E8C.
    expected_length = 1;
    Dart_Handle utf16_str = Dart_NewStringFromUTF8(data, ARRAY_SIZE(data));
    EXPECT_VALID(utf16_str);
    EXPECT(Dart_IsString(utf16_str));
    EXPECT(!Dart_IsStringLatin1(utf16_str));
    EXPECT(!Dart_IsExternalString(utf16_str));
    EXPECT_VALID(Dart_StringLength(utf16_str, &length));
    EXPECT_EQ(expected_length, length);

    // Test with a two byte string.
    uint16_t ext_utf16_str[kLength];
    EXPECT_VALID(Dart_StringStorageSize(utf16_str, &size));
    str = Dart_MakeExternalString(utf16_str,
                                  ext_utf16_str,
                                  size,
                                  &peer16,
                                  MakeExternalCback);
    EXPECT(Dart_IsString(str));
    EXPECT(Dart_IsString(utf16_str));
    EXPECT(!Dart_IsStringLatin1(str));
    EXPECT(!Dart_IsStringLatin1(utf16_str));
    EXPECT(Dart_IsExternalString(str));
    EXPECT(Dart_IsExternalString(utf16_str));
    EXPECT_VALID(Dart_StringLength(str, &length));
    EXPECT_EQ(expected_length, length);
    EXPECT_VALID(Dart_StringLength(utf16_str, &length));
    EXPECT_EQ(expected_length, length);
    EXPECT(Dart_IdentityEquals(str, utf16_str));
    for (intptr_t i = 0; i < length; i++) {
      EXPECT_EQ(0x4e8c, ext_utf16_str[i]);
    }

    Dart_ExitScope();
  }
  EXPECT_EQ(40, peer8);
  EXPECT_EQ(41, peer16);
  Isolate::Current()->heap()->CollectGarbage(Heap::kNew);
  EXPECT_EQ(80, peer8);
  EXPECT_EQ(82, peer16);
}


TEST_CASE(ExternalizeConstantStrings) {
  const char* kScriptChars =
      "String testMain() {\n"
      "  return 'constant string';\n"
      "}\n";

  Dart_Handle lib = TestCase::LoadTestScript(kScriptChars, NULL);
  Dart_Handle result = Dart_Invoke(lib,
                                      NewString("testMain"),
                                      0,
                                      NULL);
  const char* expected_str = "constant string";
  const intptr_t kExpectedLen = 15;
  int peer = 40;
  uint8_t ext_str[kExpectedLen];
  Dart_Handle str = Dart_MakeExternalString(result,
                                            ext_str,
                                            kExpectedLen,
                                            &peer,
                                            MakeExternalCback);

  EXPECT(Dart_IsExternalString(str));
  for (intptr_t i = 0; i < kExpectedLen; i++) {
    EXPECT_EQ(expected_str[i], ext_str[i]);
  }
}


TEST_CASE(LazyLoadDeoptimizes) {
  const char* kLoadFirst =
      "library L;\n"
      "start(a) {\n"
      "  var obj = (a == 1) ? createB() : new A();\n"
      "  for (int i = 0; i < 4000; i++) {\n"
      "    var res = obj.foo();\n"
      "    if (a == 1) { if (res != 1) throw 'Error'; }\n"
      "    else if (res != 2) throw 'Error'; \n"
      "  }\n"
      "}\n"
      "\n"
      "createB() => new B();"
      "\n"
      "class A {\n"
      "  foo() => goo();\n"
      "  goo() => 2;\n"
      "}\n";
  const char* kLoadSecond =
      "part of L;"
      "class B extends A {\n"
      "  goo() => 1;\n"
      "}\n";
  Dart_Handle result;
  // Create a test library and Load up a test script in it.
  Dart_Handle lib1 = TestCase::LoadTestScript(kLoadFirst, NULL);
  Dart_Handle dart_args[1];
  dart_args[0] = Dart_NewInteger(0);
  result = Dart_Invoke(lib1, NewString("start"), 1, dart_args);
  EXPECT_VALID(result);

  Dart_Handle source = NewString(kLoadSecond);
  Dart_Handle url = NewString(TestCase::url());
  Dart_LoadSource(TestCase::lib(), url, source);

  dart_args[0] = Dart_NewInteger(1);
  result = Dart_Invoke(lib1, NewString("start"), 1, dart_args);
  EXPECT_VALID(result);
}


// Test external strings and optimized code.
static void ExternalStringDeoptimize_Finalize(void* peer) {
  delete[] reinterpret_cast<char*>(peer);
}


static void A_change_str_native(Dart_NativeArguments args) {
  Dart_EnterScope();
  Dart_Handle str = Dart_GetNativeArgument(args, 0);
  EXPECT(Dart_IsString(str));
  intptr_t size = 0;
  EXPECT_VALID(Dart_StringStorageSize(str, &size));
  char* str_data = new char[size];
  Dart_Handle result =
      Dart_MakeExternalString(str,
                              str_data,
                              size,
                              str_data,
                              &ExternalStringDeoptimize_Finalize);
  EXPECT_VALID(result);
  Dart_ExitScope();
}


static Dart_NativeFunction ExternalStringDeoptimize_native_lookup(
    Dart_Handle name, int argument_count) {
  return reinterpret_cast<Dart_NativeFunction>(&A_change_str_native);
}


TEST_CASE(ExternalStringDeoptimize) {
  const char* kScriptChars =
      "String str = 'A';\n"
      "class A {\n"
      "  static change_str(String s) native 'A_change_str';\n"
      "}\n"
      "sum_chars(String s, bool b) {\n"
      "  var result = 0;\n"
      "  for (var i = 0; i < s.length; i++) {\n"
      "    if (b && i == 0) A.change_str(str);\n"
      "    result += s.codeUnitAt(i);"
      "  }\n"
      "  return result;\n"
      "}\n"
      "main() {\n"
      "  str = '$str$str';\n"
      "  for (var i = 0; i < 2000; i++) sum_chars(str, false);\n"
      "  var x = sum_chars(str, false);\n"
      "  var y = sum_chars(str, true);\n"
      "  return x + y;\n"
      "}\n";
  Dart_Handle lib =
      TestCase::LoadTestScript(kScriptChars,
                               &ExternalStringDeoptimize_native_lookup);
  Dart_Handle result = Dart_Invoke(lib,
                                   NewString("main"),
                                   0,
                                   NULL);
  int64_t value = 0;
  result = Dart_IntegerToInt64(result, &value);
  EXPECT_VALID(result);
  EXPECT_EQ(260, value);
}

}  // namespace dart
