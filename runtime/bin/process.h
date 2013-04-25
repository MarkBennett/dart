// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef BIN_PROCESS_H_
#define BIN_PROCESS_H_

#include "bin/builtin.h"
#include "bin/thread.h"
#include "platform/globals.h"


namespace dart {
namespace bin {

class Process {
 public:
  // Start a new process providing access to stdin, stdout, stderr and
  // process exit streams.
  static int Start(const char* path,
                   char* arguments[],
                   intptr_t arguments_length,
                   const char* working_directory,
                   char* environment[],
                   intptr_t environment_length,
                   intptr_t* in,
                   intptr_t* out,
                   intptr_t* err,
                   intptr_t* id,
                   intptr_t* exit_handler,
                   char** os_error_message);

  // Kill a process with a given pid.
  static bool Kill(intptr_t id, int signal);

  // Terminate the exit code handler thread. Does not return before
  // the thread has terminated.
  static void TerminateExitCodeHandler();

  static int GlobalExitCode() {
    MutexLocker ml(&global_exit_code_mutex_);
    return global_exit_code_;
  }

  static void SetGlobalExitCode(int exit_code) {
    MutexLocker ml(&global_exit_code_mutex_);
    global_exit_code_ = exit_code;
  }

  static intptr_t CurrentProcessId();

  static Dart_Handle GetProcessIdNativeField(Dart_Handle process,
                                             intptr_t* pid);
  static Dart_Handle SetProcessIdNativeField(Dart_Handle process,
                                             intptr_t pid);

 private:
  static int global_exit_code_;
  static dart::Mutex global_exit_code_mutex_;

  DISALLOW_ALLOCATION();
  DISALLOW_IMPLICIT_CONSTRUCTORS(Process);
};

}  // namespace bin
}  // namespace dart

#endif  // BIN_PROCESS_H_
