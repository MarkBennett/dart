// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "bin/io_buffer.h"
#include "bin/socket.h"
#include "bin/dartutils.h"
#include "bin/thread.h"
#include "bin/utils.h"

#include "platform/globals.h"
#include "platform/thread.h"
#include "platform/utils.h"

#include "include/dart_api.h"

static const int kSocketIdNativeField = 0;

dart::Mutex Socket::mutex_;
int Socket::service_ports_size_ = 0;
Dart_Port* Socket::service_ports_ = NULL;
int Socket::service_ports_index_ = 0;


static Dart_Handle GetSockAddr(Dart_Handle obj, RawAddr* addr) {
  Dart_TypedData_Type data_type;
  uint8_t* data = NULL;
  intptr_t len;
  Dart_Handle result = Dart_TypedDataAcquireData(
      obj, &data_type, reinterpret_cast<void**>(&data), &len);
  if (Dart_IsError(result)) return result;
  memmove(reinterpret_cast<void *>(addr), data, len);
  return Dart_Null();
}


void FUNCTION_NAME(Socket_CreateConnect)(Dart_NativeArguments args) {
  Dart_EnterScope();
  Dart_Handle socket_obj = Dart_GetNativeArgument(args, 0);
  Dart_Handle host_obj = Dart_GetNativeArgument(args, 1);
  RawAddr addr;
  Dart_Handle result = GetSockAddr(host_obj, &addr);
  int64_t port = 0;
  if (!Dart_IsError(result) &&
      DartUtils::GetInt64Value(Dart_GetNativeArgument(args, 2), &port)) {
    intptr_t socket = Socket::CreateConnect(addr, port);
    OSError error;
    Dart_TypedDataReleaseData(host_obj);
    if (socket >= 0) {
      Dart_Handle err = Socket::SetSocketIdNativeField(socket_obj, socket);
      if (Dart_IsError(err)) Dart_PropagateError(err);
      Dart_SetReturnValue(args, Dart_True());
    } else {
      Dart_SetReturnValue(args, DartUtils::NewDartOSError(&error));
    }
  } else {
    OSError os_error(-1, "Invalid argument", OSError::kUnknown);
    Dart_Handle err = DartUtils::NewDartOSError(&os_error);
    if (Dart_IsError(err)) Dart_PropagateError(err);
    Dart_SetReturnValue(args, err);
  }
  Dart_ExitScope();
}


void FUNCTION_NAME(Socket_Available)(Dart_NativeArguments args) {
  Dart_EnterScope();
  Dart_Handle socket_obj = Dart_GetNativeArgument(args, 0);
  intptr_t socket = 0;
  Dart_Handle err = Socket::GetSocketIdNativeField(socket_obj, &socket);
  if (Dart_IsError(err)) Dart_PropagateError(err);
  intptr_t available = Socket::Available(socket);
  if (available >= 0) {
    Dart_SetReturnValue(args, Dart_NewInteger(available));
  } else {
    Dart_SetReturnValue(args, DartUtils::NewDartOSError());
  }
  Dart_ExitScope();
}


void FUNCTION_NAME(Socket_Read)(Dart_NativeArguments args) {
  Dart_EnterScope();
  Dart_Handle socket_obj = Dart_GetNativeArgument(args, 0);
  intptr_t socket = 0;
  Dart_Handle err = Socket::GetSocketIdNativeField(socket_obj, &socket);
  if (Dart_IsError(err)) Dart_PropagateError(err);
  intptr_t available = Socket::Available(socket);
  if (available > 0) {
    int64_t length = 0;
    Dart_Handle length_obj = Dart_GetNativeArgument(args, 1);
    if (DartUtils::GetInt64Value(length_obj, &length)) {
      if (length == -1 || available < length) {
        length = available;
      }
      uint8_t* buffer = NULL;
      Dart_Handle result = IOBuffer::Allocate(length, &buffer);
      if (Dart_IsError(result)) Dart_PropagateError(result);
      ASSERT(buffer != NULL);
      intptr_t bytes_read = Socket::Read(socket, buffer, length);
      if (bytes_read == length) {
        Dart_SetReturnValue(args, result);
      } else if (bytes_read == 0) {
        // On MacOS when reading from a tty Ctrl-D will result in one
        // byte reported as available. Attempting to read it out will
        // result in zero bytes read. When that happens there is no
        // data which is indicated by a null return value.
        Dart_SetReturnValue(args, Dart_Null());
      } else {
        ASSERT(bytes_read == -1);
        Dart_SetReturnValue(args, DartUtils::NewDartOSError());
      }
    } else {
      OSError os_error(-1, "Invalid argument", OSError::kUnknown);
      Dart_Handle err = DartUtils::NewDartOSError(&os_error);
      if (Dart_IsError(err)) Dart_PropagateError(err);
      Dart_SetReturnValue(args, err);
    }
  } else if (available == 0) {
    Dart_SetReturnValue(args, Dart_Null());
  } else {
    Dart_SetReturnValue(args, DartUtils::NewDartOSError());
  }

  Dart_ExitScope();
}


void FUNCTION_NAME(Socket_ReadList)(Dart_NativeArguments args) {
  Dart_EnterScope();
  static bool short_socket_reads = Dart_IsVMFlagSet("short_socket_read");
  Dart_Handle socket_obj = Dart_GetNativeArgument(args, 0);
  intptr_t socket = 0;
  Dart_Handle err = Socket::GetSocketIdNativeField(socket_obj, &socket);
  if (Dart_IsError(err)) Dart_PropagateError(err);
  Dart_Handle buffer_obj = Dart_GetNativeArgument(args, 1);
  int64_t offset = 0;
  int64_t length = 0;
  Dart_Handle offset_obj = Dart_GetNativeArgument(args, 2);
  Dart_Handle length_obj = Dart_GetNativeArgument(args, 3);
  if (Dart_IsList(buffer_obj) &&
      DartUtils::GetInt64Value(offset_obj, &offset) &&
      DartUtils::GetInt64Value(length_obj, &length)) {
    intptr_t buffer_len = 0;
    Dart_Handle result = Dart_ListLength(buffer_obj, &buffer_len);
    if (Dart_IsError(result)) {
      Dart_PropagateError(result);
    }
    ASSERT((offset + length) <= buffer_len);
    if (short_socket_reads) {
      length = (length + 1) / 2;
    }
    uint8_t* buffer = new uint8_t[length];
    intptr_t bytes_read = Socket::Read(socket, buffer, length);
    if (bytes_read > 0) {
      Dart_Handle result =
          Dart_ListSetAsBytes(buffer_obj, offset, buffer, bytes_read);
      if (Dart_IsError(result)) {
        delete[] buffer;
        Dart_PropagateError(result);
      }
    }
    delete[] buffer;
    if (bytes_read >= 0) {
      Dart_SetReturnValue(args, Dart_NewInteger(bytes_read));
    } else {
      Dart_SetReturnValue(args, DartUtils::NewDartOSError());
    }
  } else {
    OSError os_error(-1, "Invalid argument", OSError::kUnknown);
    Dart_Handle err = DartUtils::NewDartOSError(&os_error);
    if (Dart_IsError(err)) Dart_PropagateError(err);
    Dart_SetReturnValue(args, err);
  }

  Dart_ExitScope();
}


void FUNCTION_NAME(Socket_WriteList)(Dart_NativeArguments args) {
  Dart_EnterScope();
  static bool short_socket_writes = Dart_IsVMFlagSet("short_socket_write");
  Dart_Handle socket_obj = Dart_GetNativeArgument(args, 0);
  intptr_t socket = 0;
  Dart_Handle err = Socket::GetSocketIdNativeField(socket_obj, &socket);
  if (Dart_IsError(err)) Dart_PropagateError(err);
  Dart_Handle buffer_obj = Dart_GetNativeArgument(args, 1);
  ASSERT(Dart_IsList(buffer_obj));
  intptr_t offset =
      DartUtils::GetIntegerValue(Dart_GetNativeArgument(args, 2));
  intptr_t length =
      DartUtils::GetIntegerValue(Dart_GetNativeArgument(args, 3));
  intptr_t buffer_len = 0;
  Dart_Handle result = Dart_ListLength(buffer_obj, &buffer_len);
  if (Dart_IsError(result)) {
    Dart_PropagateError(result);
  }
  ASSERT((offset + length) <= buffer_len);

  if (short_socket_writes) {
    length = (length + 1) / 2;
  }

  intptr_t total_bytes_written = 0;
  intptr_t bytes_written = 0;
  Dart_TypedData_Type type;
  uint8_t* buffer = NULL;
  intptr_t len;
  result = Dart_TypedDataAcquireData(buffer_obj, &type,
                                     reinterpret_cast<void**>(&buffer), &len);
  if (!Dart_IsError(result)) {
    buffer += offset;
    bytes_written = Socket::Write(socket, buffer, length);
    if (bytes_written > 0) total_bytes_written = bytes_written;
    Dart_TypedDataReleaseData(buffer_obj);
  } else {
    // Send data in chunks of maximum 16KB.
    const intptr_t max_chunk_length =
        dart::Utils::Minimum(length, static_cast<intptr_t>(16 * KB));
    buffer = new uint8_t[max_chunk_length];
    do {
      intptr_t chunk_length =
          dart::Utils::Minimum(max_chunk_length, length - total_bytes_written);
      result = Dart_ListGetAsBytes(buffer_obj,
                                   offset + total_bytes_written,
                                   buffer,
                                   chunk_length);
      if (Dart_IsError(result)) {
        delete[] buffer;
        Dart_PropagateError(result);
      }
      bytes_written =
          Socket::Write(socket, reinterpret_cast<void*>(buffer), chunk_length);
      if (bytes_written > 0) total_bytes_written += bytes_written;
    } while (bytes_written > 0 && total_bytes_written < length);
    delete[] buffer;
  }
  if (bytes_written >= 0) {
    Dart_SetReturnValue(args, Dart_NewInteger(total_bytes_written));
  } else {
    Dart_SetReturnValue(args, DartUtils::NewDartOSError());
  }
  Dart_ExitScope();
}


void FUNCTION_NAME(Socket_GetPort)(Dart_NativeArguments args) {
  Dart_EnterScope();
  Dart_Handle socket_obj = Dart_GetNativeArgument(args, 0);
  intptr_t socket = 0;
  Dart_Handle err = Socket::GetSocketIdNativeField(socket_obj, &socket);
  if (Dart_IsError(err)) Dart_PropagateError(err);
  OSError os_error;
  intptr_t port = Socket::GetPort(socket);
  if (port > 0) {
    Dart_SetReturnValue(args, Dart_NewInteger(port));
  } else {
    Dart_SetReturnValue(args, DartUtils::NewDartOSError());
  }
  Dart_ExitScope();
}


void FUNCTION_NAME(Socket_GetRemotePeer)(Dart_NativeArguments args) {
  Dart_EnterScope();
  Dart_Handle socket_obj = Dart_GetNativeArgument(args, 0);
  intptr_t socket = 0;
  Dart_Handle err = Socket::GetSocketIdNativeField(socket_obj, &socket);
  if (Dart_IsError(err)) Dart_PropagateError(err);
  OSError os_error;
  intptr_t port = 0;
  ASSERT(INET6_ADDRSTRLEN >= INET_ADDRSTRLEN);
  char host[INET6_ADDRSTRLEN];
  if (Socket::GetRemotePeer(socket, host, &port)) {
    Dart_Handle list = Dart_NewList(2);
    Dart_ListSetAt(list, 0, Dart_NewStringFromCString(host));
    Dart_ListSetAt(list, 1, Dart_NewInteger(port));
    Dart_SetReturnValue(args, list);
  } else {
    Dart_SetReturnValue(args, DartUtils::NewDartOSError());
  }
  Dart_ExitScope();
}


void FUNCTION_NAME(Socket_GetError)(Dart_NativeArguments args) {
  Dart_EnterScope();
  Dart_Handle socket_obj = Dart_GetNativeArgument(args, 0);
  intptr_t socket = 0;
  Dart_Handle err = Socket::GetSocketIdNativeField(socket_obj, &socket);
  if (Dart_IsError(err)) Dart_PropagateError(err);
  OSError os_error;
  Socket::GetError(socket, &os_error);
  Dart_SetReturnValue(args, DartUtils::NewDartOSError(&os_error));
  Dart_ExitScope();
}


void FUNCTION_NAME(Socket_GetType)(Dart_NativeArguments args) {
  Dart_EnterScope();
  Dart_Handle socket_obj = Dart_GetNativeArgument(args, 0);
  intptr_t socket = 0;
  Socket::GetSocketIdNativeField(socket_obj, &socket);
  OSError os_error;
  intptr_t type = Socket::GetType(socket);
  if (type >= 0) {
    Dart_SetReturnValue(args, Dart_NewInteger(type));
  } else {
    Dart_SetReturnValue(args, DartUtils::NewDartOSError());
  }
  Dart_ExitScope();
}


void FUNCTION_NAME(Socket_GetStdioHandle)(Dart_NativeArguments args) {
  Dart_EnterScope();
  Dart_Handle socket_obj = Dart_GetNativeArgument(args, 0);
  intptr_t num =
      DartUtils::GetIntegerValue(Dart_GetNativeArgument(args, 1));
  ASSERT(num == 0 || num == 1 || num == 2);
  intptr_t socket = Socket::GetStdioHandle(num);
  Dart_Handle err = Socket::SetSocketIdNativeField(socket_obj, socket);
  if (Dart_IsError(err)) Dart_PropagateError(err);
  Dart_SetReturnValue(args, Dart_NewBoolean(socket >= 0));
  Dart_ExitScope();
}


void FUNCTION_NAME(ServerSocket_CreateBindListen)(Dart_NativeArguments args) {
  Dart_EnterScope();
  Dart_Handle socket_obj = Dart_GetNativeArgument(args, 0);
  Dart_Handle host_obj = Dart_GetNativeArgument(args, 1);
  RawAddr addr;
  Dart_Handle result = GetSockAddr(host_obj, &addr);
  Dart_Handle port_obj = Dart_GetNativeArgument(args, 2);
  Dart_Handle backlog_obj = Dart_GetNativeArgument(args, 3);
  int64_t port = 0;
  int64_t backlog = 0;
  if (!Dart_IsError(result) &&
      DartUtils::GetInt64Value(port_obj, &port) &&
      DartUtils::GetInt64Value(backlog_obj, &backlog)) {
    intptr_t socket = ServerSocket::CreateBindListen(addr, port, backlog);
    OSError error;
    Dart_TypedDataReleaseData(host_obj);
    if (socket >= 0) {
      Dart_Handle err = Socket::SetSocketIdNativeField(socket_obj, socket);
      if (Dart_IsError(err)) Dart_PropagateError(err);
      Dart_SetReturnValue(args, Dart_True());
    } else {
      if (socket == -5) {
        OSError os_error(-1, "Invalid host", OSError::kUnknown);
        Dart_SetReturnValue(args, DartUtils::NewDartOSError(&os_error));
      } else {
        Dart_SetReturnValue(args, DartUtils::NewDartOSError(&error));
      }
    }
  } else {
    OSError os_error(-1, "Invalid argument", OSError::kUnknown);
    Dart_Handle err = DartUtils::NewDartOSError(&os_error);
    if (Dart_IsError(err)) Dart_PropagateError(err);
    Dart_SetReturnValue(args, err);
  }
  Dart_ExitScope();
}


void FUNCTION_NAME(ServerSocket_Accept)(Dart_NativeArguments args) {
  Dart_EnterScope();
  Dart_Handle socket_obj = Dart_GetNativeArgument(args, 0);
  intptr_t socket = 0;
  Dart_Handle err = Socket::GetSocketIdNativeField(socket_obj, &socket);
  if (Dart_IsError(err)) Dart_PropagateError(err);
  Dart_Handle result_socket_obj = Dart_GetNativeArgument(args, 1);
  intptr_t new_socket = ServerSocket::Accept(socket);
  if (new_socket >= 0) {
    Dart_Handle err = Socket::SetSocketIdNativeField(result_socket_obj,
                                                     new_socket);
    if (Dart_IsError(err)) Dart_PropagateError(err);
    Dart_SetReturnValue(args, Dart_True());
  } else if (new_socket == ServerSocket::kTemporaryFailure) {
    Dart_SetReturnValue(args, Dart_False());
  } else {
    Dart_SetReturnValue(args, DartUtils::NewDartOSError());
  }
  Dart_ExitScope();
}


static CObject* LookupRequest(const CObjectArray& request) {
  if (request.Length() == 3 &&
      request[1]->IsString() &&
      request[2]->IsInt32()) {
    CObjectString host(request[1]);
    CObjectInt32 type(request[2]);
    CObject* result = NULL;
    OSError* os_error = NULL;
    SocketAddresses* addresses =
        Socket::LookupAddress(host.CString(), type.Value(), &os_error);
    if (addresses != NULL) {
      CObjectArray* array = new CObjectArray(
          CObject::NewArray(addresses->count() + 1));
      array->SetAt(0, new CObjectInt32(CObject::NewInt32(0)));
      for (intptr_t i = 0; i < addresses->count(); i++) {
        SocketAddress* addr = addresses->GetAt(i);
        CObjectArray* entry = new CObjectArray(CObject::NewArray(3));

        CObjectInt32* type = new CObjectInt32(
            CObject::NewInt32(addr->GetType()));
        entry->SetAt(0, type);

        CObjectString* as_string = new CObjectString(CObject::NewString(
            addr->as_string()));
        entry->SetAt(1, as_string);

        RawAddr raw = addr->addr();
        CObjectUint8Array* data = new CObjectUint8Array(CObject::NewUint8Array(
            SocketAddress::GetAddrLength(raw)));
        memmove(data->Buffer(),
                reinterpret_cast<void *>(&raw),
                SocketAddress::GetAddrLength(raw));

        entry->SetAt(2, data);
        array->SetAt(i + 1, entry);
      }
      result = array;
      delete addresses;
    } else {
      result = CObject::NewOSError(os_error);
      delete os_error;
    }
    return result;
  }
  return CObject::IllegalArgumentError();
}


void SocketService(Dart_Port dest_port_id,
                   Dart_Port reply_port_id,
                   Dart_CObject* message) {
  CObject* response = CObject::IllegalArgumentError();
  CObjectArray request(message);
  if (message->type == Dart_CObject::kArray) {
    if (request.Length() > 1 && request[0]->IsInt32()) {
      CObjectInt32 request_type(request[0]);
      switch (request_type.Value()) {
        case Socket::kLookupRequest:
          response = LookupRequest(request);
          break;
        default:
          UNREACHABLE();
      }
    }
  }

  Dart_PostCObject(reply_port_id, response->AsApiCObject());
}


Dart_Port Socket::GetServicePort() {
  MutexLocker lock(&mutex_);
  if (service_ports_size_ == 0) {
    ASSERT(service_ports_ == NULL);
    service_ports_size_ = 16;
    service_ports_ = new Dart_Port[service_ports_size_];
    service_ports_index_ = 0;
    for (int i = 0; i < service_ports_size_; i++) {
      service_ports_[i] = ILLEGAL_PORT;
    }
  }

  Dart_Port result = service_ports_[service_ports_index_];
  if (result == ILLEGAL_PORT) {
    result = Dart_NewNativePort("SocketService",
                                SocketService,
                                true);
    ASSERT(result != ILLEGAL_PORT);
    service_ports_[service_ports_index_] = result;
  }
  service_ports_index_ = (service_ports_index_ + 1) % service_ports_size_;
  return result;
}


void FUNCTION_NAME(Socket_NewServicePort)(Dart_NativeArguments args) {
  Dart_EnterScope();
  Dart_SetReturnValue(args, Dart_Null());
  Dart_Port service_port = Socket::GetServicePort();
  if (service_port != ILLEGAL_PORT) {
    // Return a send port for the service port.
    Dart_Handle send_port = Dart_NewSendPort(service_port);
    Dart_SetReturnValue(args, send_port);
  }
  Dart_ExitScope();
}


void FUNCTION_NAME(Socket_SetOption)(Dart_NativeArguments args) {
  Dart_EnterScope();
  Dart_Handle socket_obj = Dart_GetNativeArgument(args, 0);
  intptr_t socket = 0;
  bool result = false;
  Dart_Handle err = Socket::GetSocketIdNativeField(socket_obj, &socket);
  if (Dart_IsError(err)) Dart_PropagateError(err);
  Dart_Handle option_obj = Dart_GetNativeArgument(args, 1);
  int64_t option;
  err = Dart_IntegerToInt64(option_obj, &option);
  if (Dart_IsError(err)) Dart_PropagateError(err);
  Dart_Handle enabled_obj = Dart_GetNativeArgument(args, 2);
  bool enabled;
  err = Dart_BooleanValue(enabled_obj, &enabled);
  if (Dart_IsError(err)) Dart_PropagateError(err);
  switch (option) {
    case 0:  // TCP_NODELAY.
      result = Socket::SetNoDelay(socket, enabled);
      break;
    default:
      break;
  }
  Dart_SetReturnValue(args, Dart_NewBoolean(result));
  Dart_ExitScope();
}


Dart_Handle Socket::SetSocketIdNativeField(Dart_Handle socket, intptr_t id) {
  return Dart_SetNativeInstanceField(socket, kSocketIdNativeField, id);
}


Dart_Handle Socket::GetSocketIdNativeField(Dart_Handle socket, intptr_t* id) {
  return Dart_GetNativeInstanceField(socket, kSocketIdNativeField, id);
}
