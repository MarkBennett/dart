// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef BIN_SOCKET_H_
#define BIN_SOCKET_H_

#include "bin/builtin.h"
#include "bin/utils.h"

#include "platform/globals.h"
#include "platform/thread.h"
// Declare the OS-specific types ahead of defining the generic class.
#if defined(TARGET_OS_ANDROID)
#include "bin/socket_android.h"
#elif defined(TARGET_OS_LINUX)
#include "bin/socket_linux.h"
#elif defined(TARGET_OS_MACOS)
#include "bin/socket_macos.h"
#elif defined(TARGET_OS_WINDOWS)
#include "bin/socket_win.h"
#else
#error Unknown target os.
#endif

class SocketAddress {
 public:
  enum {
    TYPE_ANY = -1,
    TYPE_IPV4,
    TYPE_IPV6,
  };

  explicit SocketAddress(struct addrinfo* addrinfo);

  int GetType() {
    if (addr_.ss_family == AF_INET6) return TYPE_IPV6;
    return TYPE_IPV4;
  }

  const char* as_string() const { return as_string_; }
  const sockaddr_storage& addr() const { return addr_; }

  static intptr_t GetAddrLength(const sockaddr_storage& addr) {
    return addr.ss_family == AF_INET6 ?
        sizeof(struct sockaddr_in6) : sizeof(struct sockaddr_in);
  }

  static int16_t FromType(int type) {
    if (type == TYPE_ANY) return AF_UNSPEC;
    if (type == TYPE_IPV4) return AF_INET;
    ASSERT(type == TYPE_IPV6 && "Invalid type");
    return AF_INET6;
  }

  static void SetAddrPort(struct sockaddr_storage* addr, intptr_t port) {
    sock_addr_ sock_addr;
    sock_addr.storage = addr;
    if (sock_addr.storage->ss_family == AF_INET) {
      sock_addr.in->sin_port = htons(port);
    } else {
      sock_addr.in6->sin6_port = htons(port);
    }
  }

  static intptr_t GetAddrPort(struct sockaddr_storage* addr) {
    sock_addr_ sock_addr;
    sock_addr.storage = addr;
    if (sock_addr.storage->ss_family == AF_INET) {
      return ntohs(sock_addr.in->sin_port);
    } else {
      return ntohs(sock_addr.in6->sin6_port);
    }
  }

  static struct sockaddr* GetAsSockAddr(struct sockaddr_storage* addr) {
    sock_addr_ sock_addr;
    sock_addr.storage = addr;
    return sock_addr.addr;
  }

  static struct sockaddr_in* GetAsSockAddrIn(struct sockaddr* addr) {
    sock_addr_ sock_addr;
    sock_addr.addr = addr;
    return sock_addr.in;
  }

  static struct sockaddr_in6* GetAsSockAddrIn6(struct sockaddr* addr) {
    sock_addr_ sock_addr;
    sock_addr.addr = addr;
    return sock_addr.in6;
  }

 private:
  union sock_addr_ {
    struct sockaddr_storage* storage;
    struct sockaddr_in* in;
    struct sockaddr_in6* in6;
    struct sockaddr* addr;
  };

  char as_string_[INET6_ADDRSTRLEN];
  sockaddr_storage addr_;

  DISALLOW_COPY_AND_ASSIGN(SocketAddress);
};

class SocketAddresses {
 public:
  explicit SocketAddresses(intptr_t count)
      : count_(count),
        addresses_(new SocketAddress*[count_]) {}

  ~SocketAddresses() {
    for (intptr_t i = 0; i < count_; i++) {
      delete addresses_[i];
    }
    delete[] addresses_;
  }

  intptr_t count() const { return count_; }
  SocketAddress* GetAt(intptr_t i) const { return addresses_[i]; }
  void SetAt(intptr_t i, SocketAddress* addr) { addresses_[i] = addr; }

 private:
  const intptr_t count_;
  SocketAddress** addresses_;

  DISALLOW_COPY_AND_ASSIGN(SocketAddresses);
};

class Socket {
 public:
  enum SocketRequest {
    kLookupRequest = 0,
  };

  static bool Initialize();
  static intptr_t Available(intptr_t fd);
  static int Read(intptr_t fd, void* buffer, intptr_t num_bytes);
  static int Write(intptr_t fd, const void* buffer, intptr_t num_bytes);
  static intptr_t CreateConnect(sockaddr_storage addr,
                                const intptr_t port);
  static intptr_t GetPort(intptr_t fd);
  static bool GetRemotePeer(intptr_t fd, char* host, intptr_t* port);
  static void GetError(intptr_t fd, OSError* os_error);
  static int GetType(intptr_t fd);
  static intptr_t GetStdioHandle(int num);
  static void Close(intptr_t fd);
  static bool SetNonBlocking(intptr_t fd);
  static bool SetBlocking(intptr_t fd);
  static bool SetNoDelay(intptr_t fd, bool enabled);

  // Perform a hostname lookup. Returns the SocketAddresses.
  static SocketAddresses* LookupAddress(const char* host,
                                        int type,
                                        OSError** os_error);

  static Dart_Port GetServicePort();

  static Dart_Handle SetSocketIdNativeField(Dart_Handle socket, intptr_t id);
  static Dart_Handle GetSocketIdNativeField(Dart_Handle socket, intptr_t* id);

 private:
  static dart::Mutex mutex_;
  static int service_ports_size_;
  static Dart_Port* service_ports_;
  static int service_ports_index_;

  DISALLOW_ALLOCATION();
  DISALLOW_IMPLICIT_CONSTRUCTORS(Socket);
};


class ServerSocket {
 public:
  static const intptr_t kTemporaryFailure = -2;

  static intptr_t Accept(intptr_t fd);

  // Returns a positive integer if the call is successful. In case of failure
  // it returns:
  //
  //   -1: system error (errno set)
  //   -5: invalid bindAddress
  static intptr_t CreateBindListen(sockaddr_storage addr,
                                   intptr_t port,
                                   intptr_t backlog);

  DISALLOW_ALLOCATION();
  DISALLOW_IMPLICIT_CONSTRUCTORS(ServerSocket);
};

#endif  // BIN_SOCKET_H_
