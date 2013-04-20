// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef PLATFORM_THREAD_H_
#define PLATFORM_THREAD_H_

#include "platform/globals.h"

// Declare the OS-specific types ahead of defining the generic classes.
#if defined(TARGET_OS_ANDROID)
#include "platform/thread_android.h"
#elif defined(TARGET_OS_LINUX)
#include "platform/thread_linux.h"
#elif defined(TARGET_OS_MACOS)
#include "platform/thread_macos.h"
#elif defined(TARGET_OS_WINDOWS)
#include "platform/thread_win.h"
#else
#error Unknown target os.
#endif

namespace dart {

class Thread {
 public:
  static ThreadLocalKey kUnsetThreadLocalKey;

  typedef void (*ThreadStartFunction) (uword parameter);

  // Start a thread running the specified function. Returns 0 if the
  // thread started successfuly and a system specific error code if
  // the thread failed to start.
  static int Start(ThreadStartFunction function, uword parameters);

  static ThreadLocalKey CreateThreadLocal();
  static void DeleteThreadLocal(ThreadLocalKey key);
  static uword GetThreadLocal(ThreadLocalKey key) {
    return ThreadInlineImpl::GetThreadLocal(key);
  }
  static void SetThreadLocal(ThreadLocalKey key, uword value);
  static intptr_t GetMaxStackSize();
};


class Mutex {
 public:
  Mutex();
  ~Mutex();

  void Lock();
  bool TryLock();
  void Unlock();

 private:
  MutexData data_;

  DISALLOW_COPY_AND_ASSIGN(Mutex);
};


class Monitor {
 public:
  enum WaitResult {
    kNotified,
    kTimedOut
  };

  static const int64_t kNoTimeout = 0;

  Monitor();
  ~Monitor();

  void Enter();
  void Exit();

  // Wait for notification or timeout.
  WaitResult Wait(int64_t millis);

  // Notify waiting threads.
  void Notify();
  void NotifyAll();

 private:
  MonitorData data_;  // OS-specific data.

  DISALLOW_COPY_AND_ASSIGN(Monitor);
};

}  // namespace dart


#endif  // PLATFORM_THREAD_H_
