// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef BIN_DIRECTORY_H_
#define BIN_DIRECTORY_H_

#include "bin/builtin.h"
#include "bin/dartutils.h"
#include "bin/native_service.h"
#include "platform/globals.h"
#include "platform/thread.h"


namespace dart {
namespace bin {

class DirectoryListing {
 public:
  virtual ~DirectoryListing() {}
  virtual bool HandleDirectory(char* dir_name) = 0;
  virtual bool HandleFile(char* file_name) = 0;
  virtual bool HandleLink(char* file_name) = 0;
  virtual bool HandleError(const char* dir_name) = 0;
};


class AsyncDirectoryListing : public DirectoryListing {
 public:
  enum Response {
    kListFile = 0,
    kListDirectory = 1,
    kListLink = 2,
    kListError = 3,
    kListDone = 4
  };

  explicit AsyncDirectoryListing(Dart_Port response_port)
      : response_port_(response_port) {}
  virtual ~AsyncDirectoryListing() {}
  virtual bool HandleDirectory(char* dir_name);
  virtual bool HandleFile(char* file_name);
  virtual bool HandleLink(char* file_name);
  virtual bool HandleError(const char* dir_name);

 private:
  CObjectArray* NewResponse(Response response, char* arg);
  Dart_Port response_port_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(AsyncDirectoryListing);
};


class SyncDirectoryListing: public DirectoryListing {
 public:
  explicit SyncDirectoryListing(Dart_Handle results)
      : results_(results) {
    add_string_ = DartUtils::NewString("add");
    directory_class_ =
        DartUtils::GetDartClass(DartUtils::kIOLibURL, "Directory");
    file_class_ =
        DartUtils::GetDartClass(DartUtils::kIOLibURL, "File");
    link_class_ =
        DartUtils::GetDartClass(DartUtils::kIOLibURL, "Link");
  }
  virtual ~SyncDirectoryListing() {}
  virtual bool HandleDirectory(char* dir_name);
  virtual bool HandleFile(char* file_name);
  virtual bool HandleLink(char* file_name);
  virtual bool HandleError(const char* dir_name);

 private:
  Dart_Handle results_;
  Dart_Handle add_string_;
  Dart_Handle directory_class_;
  Dart_Handle file_class_;
  Dart_Handle link_class_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(SyncDirectoryListing);
};


class Directory {
 public:
  enum ExistsResult {
    UNKNOWN,
    EXISTS,
    DOES_NOT_EXIST
  };

  // This enum must be kept in sync with the request values in
  // directory_impl.dart.
  enum DirectoryRequest {
    kCreateRequest = 0,
    kDeleteRequest = 1,
    kExistsRequest = 2,
    kCreateTempRequest = 3,
    kListRequest = 4,
    kRenameRequest = 5
  };

  static bool List(const char* path,
                   bool recursive,
                   bool follow_links,
                   DirectoryListing* listing);
  static ExistsResult Exists(const char* path);
  static char* Current();
  static bool SetCurrent(const char* path);
  static bool Create(const char* path);
  static char* CreateTemp(const char* const_template);
  static bool Delete(const char* path, bool recursive);
  static bool Rename(const char* path, const char* new_path);
  static Dart_Port GetServicePort();

 private:
  static NativeService directory_service_;

  DISALLOW_ALLOCATION();
  DISALLOW_IMPLICIT_CONSTRUCTORS(Directory);
};

}  // namespace bin
}  // namespace dart

#endif  // BIN_DIRECTORY_H_
