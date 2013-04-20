// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "platform/globals.h"
#if defined(TARGET_OS_WINDOWS)

#include "bin/eventhandler.h"

#include <process.h>  // NOLINT
#include <winsock2.h>  // NOLINT
#include <ws2tcpip.h>  // NOLINT
#include <mswsock.h>  // NOLINT

#include "bin/builtin.h"
#include "bin/dartutils.h"
#include "bin/log.h"
#include "bin/socket.h"
#include "bin/utils.h"
#include "platform/thread.h"


static const int kBufferSize = 32 * 1024;

static const int kInfinityTimeout = -1;
static const int kTimeoutId = -1;
static const int kShutdownId = -2;

IOBuffer* IOBuffer::AllocateBuffer(int buffer_size, Operation operation) {
  IOBuffer* buffer = new(buffer_size) IOBuffer(buffer_size, operation);
  return buffer;
}


IOBuffer* IOBuffer::AllocateAcceptBuffer(int buffer_size) {
  IOBuffer* buffer = AllocateBuffer(buffer_size, kAccept);
  return buffer;
}


IOBuffer* IOBuffer::AllocateReadBuffer(int buffer_size) {
  return AllocateBuffer(buffer_size, kRead);
}


IOBuffer* IOBuffer::AllocateWriteBuffer(int buffer_size) {
  return AllocateBuffer(buffer_size, kWrite);
}


IOBuffer* IOBuffer::AllocateDisconnectBuffer() {
  return AllocateBuffer(0, kDisconnect);
}


void IOBuffer::DisposeBuffer(IOBuffer* buffer) {
  delete buffer;
}


IOBuffer* IOBuffer::GetFromOverlapped(OVERLAPPED* overlapped) {
  IOBuffer* buffer = CONTAINING_RECORD(overlapped, IOBuffer, overlapped_);
  return buffer;
}


int IOBuffer::Read(void* buffer, int num_bytes) {
  if (num_bytes > GetRemainingLength()) {
    num_bytes = GetRemainingLength();
  }
  memcpy(buffer, GetBufferStart() + index_, num_bytes);
  index_ += num_bytes;
  return num_bytes;
}


int IOBuffer::Write(const void* buffer, int num_bytes) {
  ASSERT(num_bytes == buflen_);
  memcpy(GetBufferStart(), buffer, num_bytes);
  data_length_ = num_bytes;
  return num_bytes;
}


int IOBuffer::GetRemainingLength() {
  ASSERT(operation_ == kRead);
  return data_length_ - index_;
}


Handle::Handle(HANDLE handle)
    : handle_(reinterpret_cast<HANDLE>(handle)),
      port_(0),
      mask_(0),
      completion_port_(INVALID_HANDLE_VALUE),
      event_handler_(NULL),
      data_ready_(NULL),
      pending_read_(NULL),
      pending_write_(NULL),
      last_error_(NOERROR),
      flags_(0) {
  InitializeCriticalSection(&cs_);
}


Handle::Handle(HANDLE handle, Dart_Port port)
    : handle_(reinterpret_cast<HANDLE>(handle)),
      port_(port),
      mask_(0),
      completion_port_(INVALID_HANDLE_VALUE),
      event_handler_(NULL),
      data_ready_(NULL),
      pending_read_(NULL),
      pending_write_(NULL),
      last_error_(NOERROR),
      flags_(0) {
  InitializeCriticalSection(&cs_);
}


Handle::~Handle() {
  DeleteCriticalSection(&cs_);
}


void Handle::Lock() {
  EnterCriticalSection(&cs_);
}


void Handle::Unlock() {
  LeaveCriticalSection(&cs_);
}


bool Handle::CreateCompletionPort(HANDLE completion_port) {
  completion_port_ = CreateIoCompletionPort(handle_,
                                            completion_port,
                                            reinterpret_cast<ULONG_PTR>(this),
                                            0);
  if (completion_port_ == NULL) {
    Log::PrintErr("Error CreateIoCompletionPort: %d\n", GetLastError());
    return false;
  }
  return true;
}


void Handle::Close() {
  ScopedLock lock(this);
  if (!IsClosing()) {
    // Close the socket and set the closing state. This close method can be
    // called again if this socket has pending IO operations in flight.
    ASSERT(handle_ != INVALID_HANDLE_VALUE);
    MarkClosing();
    // Perform handle type specific closing.
    DoClose();
  }
}


void Handle::DoClose() {
  CloseHandle(handle_);
  handle_ = INVALID_HANDLE_VALUE;
}


bool Handle::HasPendingRead() {
  ScopedLock lock(this);
  return pending_read_ != NULL;
}


bool Handle::HasPendingWrite() {
  ScopedLock lock(this);
  return pending_write_ != NULL;
}


void Handle::ReadComplete(IOBuffer* buffer) {
  ScopedLock lock(this);
  // Currently only one outstanding read at the time.
  ASSERT(pending_read_ == buffer);
  ASSERT(data_ready_ == NULL);
  if (!IsClosing() && !buffer->IsEmpty()) {
    data_ready_ = pending_read_;
  } else {
    IOBuffer::DisposeBuffer(buffer);
  }
  pending_read_ = NULL;
}


void Handle::WriteComplete(IOBuffer* buffer) {
  ScopedLock lock(this);
  // Currently only one outstanding write at the time.
  ASSERT(pending_write_ == buffer);
  IOBuffer::DisposeBuffer(buffer);
  pending_write_ = NULL;
}


static unsigned int __stdcall ReadFileThread(void* args) {
  Handle* handle = reinterpret_cast<Handle*>(args);
  handle->ReadSyncCompleteAsync();
  return 0;
}


void Handle::ReadSyncCompleteAsync() {
  ASSERT(pending_read_ != NULL);
  DWORD bytes_read = 0;
  BOOL ok = ReadFile(handle_,
                     pending_read_->GetBufferStart(),
                     pending_read_->GetBufferSize(),
                     &bytes_read,
                     NULL);
  if (!ok) {
    if (GetLastError() != ERROR_BROKEN_PIPE) {
      Log::PrintErr("ReadFile failed %d\n", GetLastError());
    }
    bytes_read = 0;
  }
  OVERLAPPED* overlapped = pending_read_->GetCleanOverlapped();
  ok = PostQueuedCompletionStatus(event_handler_->completion_port(),
                                  bytes_read,
                                  reinterpret_cast<ULONG_PTR>(this),
                                  overlapped);
  if (!ok) {
    FATAL("PostQueuedCompletionStatus failed");
  }
}


bool Handle::IssueRead() {
  ScopedLock lock(this);
  ASSERT(type_ != kListenSocket);
  ASSERT(pending_read_ == NULL);
  IOBuffer* buffer = IOBuffer::AllocateReadBuffer(kBufferSize);
  if (SupportsOverlappedIO()) {
    ASSERT(completion_port_ != INVALID_HANDLE_VALUE);

    BOOL ok = ReadFile(handle_,
                       buffer->GetBufferStart(),
                       buffer->GetBufferSize(),
                       NULL,
                       buffer->GetCleanOverlapped());
    if (ok || GetLastError() == ERROR_IO_PENDING) {
      // Completing asynchronously.
      pending_read_ = buffer;
      return true;
    }
    IOBuffer::DisposeBuffer(buffer);
    HandleIssueError();
    return false;
  } else {
    // Completing asynchronously through thread.
    pending_read_ = buffer;
    uint32_t tid;
    uintptr_t thread_handle =
        _beginthreadex(NULL, 32 * 1024, ReadFileThread, this, 0, &tid);
    if (thread_handle == -1) {
      FATAL("Failed to start read file thread");
    }
    return true;
  }
}


bool Handle::IssueWrite() {
  ScopedLock lock(this);
  ASSERT(type_ != kListenSocket);
  ASSERT(completion_port_ != INVALID_HANDLE_VALUE);
  ASSERT(pending_write_ != NULL);
  ASSERT(pending_write_->operation() == IOBuffer::kWrite);

  IOBuffer* buffer = pending_write_;
  BOOL ok = WriteFile(handle_,
                      buffer->GetBufferStart(),
                      buffer->GetBufferSize(),
                      NULL,
                      buffer->GetCleanOverlapped());
  if (ok || GetLastError() == ERROR_IO_PENDING) {
    // Completing asynchronously.
    pending_write_ = buffer;
    return true;
  }
  IOBuffer::DisposeBuffer(buffer);
  HandleIssueError();
  return false;
}


void Handle::HandleIssueError() {
  DWORD error = GetLastError();
  if (error == ERROR_BROKEN_PIPE) {
    event_handler_->HandleClosed(this);
  } else {
    event_handler_->HandleError(this);
  }
  SetLastError(error);
}


void FileHandle::EnsureInitialized(EventHandlerImplementation* event_handler) {
  ScopedLock lock(this);
  event_handler_ = event_handler;
  if (SupportsOverlappedIO() && completion_port_ == INVALID_HANDLE_VALUE) {
    CreateCompletionPort(event_handler_->completion_port());
  }
}


bool FileHandle::IsClosed() {
  return false;
}


void SocketHandle::HandleIssueError() {
  int error = WSAGetLastError();
  if (error == WSAECONNRESET) {
    event_handler_->HandleClosed(this);
  } else {
    event_handler_->HandleError(this);
  }
  WSASetLastError(error);
}


bool ListenSocket::LoadAcceptEx() {
  // Load the AcceptEx function into memory using WSAIoctl.
  GUID guid_accept_ex = WSAID_ACCEPTEX;
  DWORD bytes;
  int status = WSAIoctl(socket(),
                        SIO_GET_EXTENSION_FUNCTION_POINTER,
                        &guid_accept_ex,
                        sizeof(guid_accept_ex),
                        &AcceptEx_,
                        sizeof(AcceptEx_),
                        &bytes,
                        NULL,
                        NULL);
  if (status == SOCKET_ERROR) {
    Log::PrintErr("Error WSAIoctl failed: %d\n", WSAGetLastError());
    return false;
  }
  return true;
}


bool ListenSocket::IssueAccept() {
  ScopedLock lock(this);

  // For AcceptEx there needs to be buffer storage for address
  // information for two addresses (local and remote address). The
  // AcceptEx documentation says: "This value must be at least 16
  // bytes more than the maximum address length for the transport
  // protocol in use."
  static const int kAcceptExAddressAdditionalBytes = 16;
  static const int kAcceptExAddressStorageSize =
      sizeof(SOCKADDR_STORAGE) + kAcceptExAddressAdditionalBytes;
  IOBuffer* buffer =
      IOBuffer::AllocateAcceptBuffer(2 * kAcceptExAddressStorageSize);
  DWORD received;
  BOOL ok;
  ok = AcceptEx_(socket(),
                 buffer->client(),
                 buffer->GetBufferStart(),
                 0,  // For now don't receive data with accept.
                 kAcceptExAddressStorageSize,
                 kAcceptExAddressStorageSize,
                 &received,
                 buffer->GetCleanOverlapped());
  if (!ok) {
    if (WSAGetLastError() != WSA_IO_PENDING) {
      Log::PrintErr("AcceptEx failed: %d\n", WSAGetLastError());
      closesocket(buffer->client());
      IOBuffer::DisposeBuffer(buffer);
      return false;
    }
  }

  pending_accept_count_++;

  return true;
}


void ListenSocket::AcceptComplete(IOBuffer* buffer, HANDLE completion_port) {
  ScopedLock lock(this);
  if (!IsClosing()) {
    // Update the accepted socket to support the full range of API calls.
    SOCKET s = socket();
    int rc = setsockopt(buffer->client(),
                        SOL_SOCKET,
                        SO_UPDATE_ACCEPT_CONTEXT,
                        reinterpret_cast<char*>(&s), sizeof(s));
    if (rc == NO_ERROR) {
      // Insert the accepted socket into the list.
      ClientSocket* client_socket = new ClientSocket(buffer->client(), 0);
      client_socket->CreateCompletionPort(completion_port);
      if (accepted_head_ == NULL) {
        accepted_head_ = client_socket;
        accepted_tail_ = client_socket;
      } else {
        ASSERT(accepted_tail_ != NULL);
        accepted_tail_->set_next(client_socket);
        accepted_tail_ = client_socket;
      }
    } else {
      Log::PrintErr("setsockopt failed: %d\n", WSAGetLastError());
      closesocket(buffer->client());
    }
  }

  pending_accept_count_--;
  IOBuffer::DisposeBuffer(buffer);
}


void ListenSocket::DoClose() {
  closesocket(socket());
  handle_ = INVALID_HANDLE_VALUE;
  while (CanAccept()) {
    // Get rid of connections already accepted.
    ClientSocket *client = Accept();
    if (client != NULL) {
      client->Close();
    } else {
      break;
    }
  }
}


bool ListenSocket::CanAccept() {
  ScopedLock lock(this);
  return accepted_head_ != NULL;
}


ClientSocket* ListenSocket::Accept() {
  ScopedLock lock(this);
  if (accepted_head_ == NULL) return NULL;
  ClientSocket* result = accepted_head_;
  accepted_head_ = accepted_head_->next();
  if (accepted_head_ == NULL) accepted_tail_ = NULL;
  result->set_next(NULL);
  return result;
}


void ListenSocket::EnsureInitialized(
    EventHandlerImplementation* event_handler) {
  ScopedLock lock(this);
  if (AcceptEx_ == NULL) {
    ASSERT(completion_port_ == INVALID_HANDLE_VALUE);
    ASSERT(event_handler_ == NULL);
    event_handler_ = event_handler;
    CreateCompletionPort(event_handler_->completion_port());
    LoadAcceptEx();
  }
}


bool ListenSocket::IsClosed() {
  return IsClosing() && !HasPendingAccept();
}


int Handle::Available() {
  ScopedLock lock(this);
  if (data_ready_ == NULL) return 0;
  ASSERT(!data_ready_->IsEmpty());
  return data_ready_->GetRemainingLength();
}


int Handle::Read(void* buffer, int num_bytes) {
  ScopedLock lock(this);
  if (data_ready_ == NULL) return 0;
  num_bytes = data_ready_->Read(buffer, num_bytes);
  if (data_ready_->IsEmpty()) {
    IOBuffer::DisposeBuffer(data_ready_);
    data_ready_ = NULL;
  }
  return num_bytes;
}


int Handle::Write(const void* buffer, int num_bytes) {
  ScopedLock lock(this);
  if (SupportsOverlappedIO()) {
    if (pending_write_ != NULL) return 0;
    if (completion_port_ == INVALID_HANDLE_VALUE) return 0;
    if (num_bytes > kBufferSize) num_bytes = kBufferSize;
    pending_write_ = IOBuffer::AllocateWriteBuffer(num_bytes);
    pending_write_->Write(buffer, num_bytes);
    if (!IssueWrite()) return -1;
    return num_bytes;
  } else {
    DWORD bytes_written = -1;
    BOOL ok = WriteFile(handle_,
                        buffer,
                        num_bytes,
                        &bytes_written,
                        NULL);
    if (!ok) {
      if (GetLastError() != ERROR_BROKEN_PIPE) {
        Log::PrintErr("WriteFile failed: %d\n", GetLastError());
      }
      event_handler_->HandleClosed(this);
    }
    return bytes_written;
  }
}


bool ClientSocket::LoadDisconnectEx() {
  // Load the DisconnectEx function into memory using WSAIoctl.
  GUID guid_disconnect_ex = WSAID_DISCONNECTEX;
  DWORD bytes;
  int status = WSAIoctl(socket(),
                        SIO_GET_EXTENSION_FUNCTION_POINTER,
                        &guid_disconnect_ex,
                        sizeof(guid_disconnect_ex),
                        &DisconnectEx_,
                        sizeof(DisconnectEx_),
                        &bytes,
                        NULL,
                        NULL);
  if (status == SOCKET_ERROR) {
    Log::PrintErr("Error WSAIoctl failed: %d\n", WSAGetLastError());
    return false;
  }
  return true;
}


void ClientSocket::Shutdown(int how) {
  int rc = shutdown(socket(), how);
  if (how == SD_RECEIVE) MarkClosedRead();
  if (how == SD_SEND) MarkClosedWrite();
  if (how == SD_BOTH) {
    MarkClosedRead();
    MarkClosedWrite();
  }
}


void ClientSocket::DoClose() {
  // Always do a suhtdown before initiating a disconnect.
  shutdown(socket(), SD_BOTH);
  IssueDisconnect();
}


bool ClientSocket::IssueRead() {
  ScopedLock lock(this);
  ASSERT(completion_port_ != INVALID_HANDLE_VALUE);
  ASSERT(pending_read_ == NULL);

  IOBuffer* buffer = IOBuffer::AllocateReadBuffer(1024);

  DWORD flags;
  flags = 0;
  int rc = WSARecv(socket(),
                   buffer->GetWASBUF(),
                   1,
                   NULL,
                   &flags,
                   buffer->GetCleanOverlapped(),
                   NULL);
  if (rc == NO_ERROR || WSAGetLastError() == WSA_IO_PENDING) {
    pending_read_ = buffer;
    return true;
  }
  IOBuffer::DisposeBuffer(buffer);
  pending_read_ = NULL;
  HandleIssueError();
  return false;
}


bool ClientSocket::IssueWrite() {
  ScopedLock lock(this);
  ASSERT(completion_port_ != INVALID_HANDLE_VALUE);
  ASSERT(pending_write_ != NULL);
  ASSERT(pending_write_->operation() == IOBuffer::kWrite);

  int rc = WSASend(socket(),
                   pending_write_->GetWASBUF(),
                   1,
                   NULL,
                   0,
                   pending_write_->GetCleanOverlapped(),
                   NULL);
  if (rc == NO_ERROR || WSAGetLastError() == WSA_IO_PENDING) {
    return true;
  }
  IOBuffer::DisposeBuffer(pending_write_);
  pending_write_ = NULL;
  HandleIssueError();
  return false;
}


void ClientSocket::IssueDisconnect() {
  IOBuffer* buffer = IOBuffer::AllocateDisconnectBuffer();
  BOOL ok = DisconnectEx_(
    socket(), buffer->GetCleanOverlapped(), TF_REUSE_SOCKET, 0);
  if (!ok && WSAGetLastError() != WSA_IO_PENDING) {
    DisconnectComplete(buffer);
  }
}


void ClientSocket::DisconnectComplete(IOBuffer* buffer) {
  IOBuffer::DisposeBuffer(buffer);
  closesocket(socket());
  if (data_ready_ != NULL) {
    IOBuffer::DisposeBuffer(data_ready_);
  }
  // When disconnect is complete get rid of the object.
  delete this;
}


void ClientSocket::EnsureInitialized(
    EventHandlerImplementation* event_handler) {
  ScopedLock lock(this);
  if (completion_port_ == INVALID_HANDLE_VALUE) {
    ASSERT(event_handler_ == NULL);
    event_handler_ = event_handler;
    CreateCompletionPort(event_handler_->completion_port());
  }
}


bool ClientSocket::IsClosed() {
  return false;
}


void EventHandlerImplementation::HandleInterrupt(InterruptMessage* msg) {
  if (msg->id == kTimeoutId) {
    // Change of timeout request. Just set the new timeout and port as the
    // completion thread will use the new timeout value for its next wait.
    timeout_ = msg->data;
    timeout_port_ = msg->dart_port;
  } else if (msg->id == kShutdownId) {
    shutdown_ = true;
  } else {
    bool delete_handle = false;
    Handle* handle = reinterpret_cast<Handle*>(msg->id);
    ASSERT(handle != NULL);
    if (handle->is_listen_socket()) {
      ListenSocket* listen_socket =
          reinterpret_cast<ListenSocket*>(handle);
      listen_socket->EnsureInitialized(this);
      listen_socket->SetPortAndMask(msg->dart_port, msg->data);

      Handle::ScopedLock lock(listen_socket);

      // If incomming connections are requested make sure to post already
      // accepted connections.
      if ((msg->data & (1 << kInEvent)) != 0) {
        if (listen_socket->CanAccept()) {
          int event_mask = (1 << kInEvent);
          handle->set_mask(handle->mask() & ~event_mask);
          DartUtils::PostInt32(handle->port(), event_mask);
        }
        // Always keep 5 outstanding accepts going, to enhance performance.
        while (listen_socket->pending_accept_count() < 5) {
          listen_socket->IssueAccept();
        }
      }

      if ((msg->data & (1 << kCloseCommand)) != 0) {
        listen_socket->Close();
        if (listen_socket->IsClosed()) {
          delete_handle = true;
        }
      }
    } else {
      handle->EnsureInitialized(this);

      Handle::ScopedLock lock(handle);

      if (!handle->IsError()) {
        if ((msg->data & ((1 << kInEvent) | (1 << kOutEvent))) != 0) {
          // Only set mask if we turned on kInEvent or kOutEvent.
          handle->SetPortAndMask(msg->dart_port, msg->data);

          // If in events (data available events) have been requested, and data
          // is available, post an in event immediately. Otherwise make sure
          // that a pending read is issued, unless the socket is already closed
          // for read.
          if ((msg->data & (1 << kInEvent)) != 0) {
            if (handle->Available() > 0) {
              int event_mask = (1 << kInEvent);
              handle->set_mask(handle->mask() & ~event_mask);
              DartUtils::PostInt32(handle->port(), event_mask);
            } else if (handle->IsClosedRead()) {
              int event_mask = (1 << kCloseEvent);
              DartUtils::PostInt32(handle->port(), event_mask);
            } else if (!handle->HasPendingRead()) {
              handle->IssueRead();
            }
          }

          // If out events (can write events) have been requested, and there
          // are no pending writes, post an out event immediately.
          if ((msg->data & (1 << kOutEvent)) != 0) {
            if (!handle->HasPendingWrite()) {
              int event_mask = (1 << kOutEvent);
              handle->set_mask(handle->mask() & ~event_mask);
              DartUtils::PostInt32(handle->port(), event_mask);
            }
          }
        }

        if (handle->is_client_socket()) {
          ClientSocket* client_socket = reinterpret_cast<ClientSocket*>(handle);
          if ((msg->data & (1 << kShutdownReadCommand)) != 0) {
            client_socket->Shutdown(SD_RECEIVE);
          }

          if ((msg->data & (1 << kShutdownWriteCommand)) != 0) {
            client_socket->Shutdown(SD_SEND);
          }
        }
      }

      if ((msg->data & (1 << kCloseCommand)) != 0) {
        handle->Close();
        if (handle->IsClosed()) {
          delete_handle = true;
        }
      }
    }
    if (delete_handle) {
      delete handle;
    }
  }
}


void EventHandlerImplementation::HandleAccept(ListenSocket* listen_socket,
                                              IOBuffer* buffer) {
  listen_socket->AcceptComplete(buffer, completion_port_);

  if (!listen_socket->IsClosing()) {
    int event_mask = 1 << kInEvent;
    if ((listen_socket->mask() & event_mask) != 0) {
      DartUtils::PostInt32(listen_socket->port(), event_mask);
    }
  }

  if (listen_socket->IsClosed()) {
    delete listen_socket;
  }
}


void EventHandlerImplementation::HandleClosed(Handle* handle) {
  if (!handle->IsClosing()) {
    int event_mask = 1 << kCloseEvent;
    DartUtils::PostInt32(handle->port(), event_mask);
  }
}


void EventHandlerImplementation::HandleError(Handle* handle) {
  handle->set_last_error(WSAGetLastError());
  handle->MarkError();
  if (!handle->IsClosing()) {
    int event_mask = 1 << kErrorEvent;
    DartUtils::PostInt32(handle->port(), event_mask);
  }
}


void EventHandlerImplementation::HandleRead(Handle* handle,
                                            int bytes,
                                            IOBuffer* buffer) {
  buffer->set_data_length(bytes);
  handle->ReadComplete(buffer);
  if (bytes > 0) {
    if (!handle->IsClosing()) {
      int event_mask = 1 << kInEvent;
      if ((handle->mask() & event_mask) != 0) {
        DartUtils::PostInt32(handle->port(), event_mask);
      }
    }
  } else {
    handle->MarkClosedRead();
    if (bytes == 0) {
      HandleClosed(handle);
    } else {
      HandleError(handle);
    }
  }

  if (handle->IsClosed()) {
    delete handle;
  }
}


void EventHandlerImplementation::HandleWrite(Handle* handle,
                                             int bytes,
                                             IOBuffer* buffer) {
  handle->WriteComplete(buffer);

  if (bytes > 0) {
    if (!handle->IsError() && !handle->IsClosing()) {
      int event_mask = 1 << kOutEvent;
      if ((handle->mask() & event_mask) != 0) {
        DartUtils::PostInt32(handle->port(), event_mask);
      }
    }
  } else if (bytes == 0) {
    HandleClosed(handle);
  } else {
    HandleError(handle);
  }

  if (handle->IsClosed()) {
    delete handle;
  }
}


void EventHandlerImplementation::HandleDisconnect(
    ClientSocket* client_socket,
    int bytes,
    IOBuffer* buffer) {
  client_socket->DisconnectComplete(buffer);
}

void EventHandlerImplementation::HandleTimeout() {
  // TODO(sgjesse) check if there actually is a timeout.
  DartUtils::PostNull(timeout_port_);
  timeout_ = kInfinityTimeout;
  timeout_port_ = 0;
}


void EventHandlerImplementation::HandleIOCompletion(DWORD bytes,
                                                    ULONG_PTR key,
                                                    OVERLAPPED* overlapped) {
  IOBuffer* buffer = IOBuffer::GetFromOverlapped(overlapped);
  switch (buffer->operation()) {
    case IOBuffer::kAccept: {
      ListenSocket* listen_socket = reinterpret_cast<ListenSocket*>(key);
      HandleAccept(listen_socket, buffer);
      break;
    }
    case IOBuffer::kRead: {
      Handle* handle = reinterpret_cast<Handle*>(key);
      HandleRead(handle, bytes, buffer);
      break;
    }
    case IOBuffer::kWrite: {
      Handle* handle = reinterpret_cast<Handle*>(key);
      HandleWrite(handle, bytes, buffer);
      break;
    }
    case IOBuffer::kDisconnect: {
      ClientSocket* client_socket = reinterpret_cast<ClientSocket*>(key);
      HandleDisconnect(client_socket, bytes, buffer);
      break;
    }
    default:
      UNREACHABLE();
  }
}


EventHandlerImplementation::EventHandlerImplementation() {
  intptr_t result;
  completion_port_ =
      CreateIoCompletionPort(INVALID_HANDLE_VALUE, NULL, NULL, 1);
  if (completion_port_ == NULL) {
    FATAL("Completion port creation failed");
  }
  timeout_ = kInfinityTimeout;
  timeout_port_ = 0;
  shutdown_ = false;
}


EventHandlerImplementation::~EventHandlerImplementation() {
  CloseHandle(completion_port_);
}


DWORD EventHandlerImplementation::GetTimeout() {
  if (timeout_ == kInfinityTimeout) {
    return kInfinityTimeout;
  }
  intptr_t millis = timeout_ - TimerUtils::GetCurrentTimeMilliseconds();
  return (millis < 0) ? 0 : millis;
}


void EventHandlerImplementation::SendData(intptr_t id,
                                          Dart_Port dart_port,
                                          int64_t data) {
  InterruptMessage* msg = new InterruptMessage;
  msg->id = id;
  msg->dart_port = dart_port;
  msg->data = data;
  BOOL ok = PostQueuedCompletionStatus(
      completion_port_, 0, NULL, reinterpret_cast<OVERLAPPED*>(msg));
  if (!ok) {
    FATAL("PostQueuedCompletionStatus failed");
  }
}


void EventHandlerImplementation::EventHandlerEntry(uword args) {
  EventHandler* handler = reinterpret_cast<EventHandler*>(args);
  EventHandlerImplementation* handler_impl = &handler->delegate_;
  ASSERT(handler_impl != NULL);
  while (!handler_impl->shutdown_) {
    DWORD bytes;
    ULONG_PTR key;
    OVERLAPPED* overlapped;
    intptr_t millis = handler_impl->GetTimeout();
    BOOL ok = GetQueuedCompletionStatus(handler_impl->completion_port(),
                                        &bytes,
                                        &key,
                                        &overlapped,
                                        millis);
    if (!ok && overlapped == NULL) {
      if (GetLastError() == ERROR_ABANDONED_WAIT_0) {
        // The completion port should never be closed.
        Log::Print("Completion port closed\n");
        UNREACHABLE();
      } else {
        // Timeout is signalled by false result and NULL in overlapped.
        handler_impl->HandleTimeout();
      }
    } else if (!ok) {
      // Treat ERROR_CONNECTION_ABORTED as connection closed.
      // The error ERROR_OPERATION_ABORTED is set for pending
      // accept requests for a listen socket which is closed.
      // ERROR_NETNAME_DELETED occurs when the client closes
      // the socket it is reading from.
      DWORD last_error = GetLastError();
      if (last_error == ERROR_CONNECTION_ABORTED ||
          last_error == ERROR_OPERATION_ABORTED ||
          last_error == ERROR_NETNAME_DELETED ||
          last_error == ERROR_BROKEN_PIPE) {
        ASSERT(bytes == 0);
        handler_impl->HandleIOCompletion(bytes, key, overlapped);
      } else {
        ASSERT(bytes == 0);
        handler_impl->HandleIOCompletion(-1, key, overlapped);
      }
    } else if (key == NULL) {
      // A key of NULL signals an interrupt message.
      InterruptMessage* msg = reinterpret_cast<InterruptMessage*>(overlapped);
      handler_impl->HandleInterrupt(msg);
      delete msg;
    } else {
      handler_impl->HandleIOCompletion(bytes, key, overlapped);
    }
  }
  delete handler;
}


void EventHandlerImplementation::Start(EventHandler* handler) {
  int result = dart::Thread::Start(EventHandlerEntry,
                                   reinterpret_cast<uword>(handler));
  if (result != 0) {
    FATAL1("Failed to start event handler thread %d", result);
  }

  // Initialize Winsock32
  if (!Socket::Initialize()) {
    FATAL("Failed to initialized Windows sockets");
  }
}


void EventHandlerImplementation::Shutdown() {
  SendData(kShutdownId, 0, 0);
}

#endif  // defined(TARGET_OS_WINDOWS)
