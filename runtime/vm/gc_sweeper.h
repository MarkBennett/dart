// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef VM_GC_SWEEPER_H_
#define VM_GC_SWEEPER_H_

#include "vm/globals.h"

namespace dart {

// Forward declarations.
class FreeList;
class Heap;
class HeapPage;

// The class GCSweeper is used to visit the heap after marking to reclaim unused
// memory.
class GCSweeper {
 public:
  explicit GCSweeper(Heap* heap) : heap_(heap) {}
  ~GCSweeper() {}

  // Sweep the memory area for the page while clearing the mark bits and adding
  // all the unmarked objects to the freelist.
  // Returns the size of memory used by the marked objects.
  intptr_t SweepPage(HeapPage* page, FreeList* freelist);

  intptr_t SweepLargePage(HeapPage* page);

 private:
  Heap* heap_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(GCSweeper);
};

}  // namespace dart

#endif  // VM_GC_SWEEPER_H_
