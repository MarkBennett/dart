// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef VM_PAGES_H_
#define VM_PAGES_H_

#include <map>

#include "vm/freelist.h"
#include "vm/globals.h"
#include "vm/virtual_memory.h"

namespace dart {

// Forward declarations.
class Heap;
class ObjectPointerVisitor;

// An aligned page containing old generation objects. Alignment is used to be
// able to get to a HeapPage header quickly based on a pointer to an object.
class HeapPage {
 public:
  enum PageType {
    kData = 0,
    kExecutable,
    kNumPageTypes
  };

  HeapPage* next() const { return next_; }
  void set_next(HeapPage* next) { next_ = next; }

  bool Contains(uword addr) {
    return memory_->Contains(addr);
  }

  uword object_start() const {
    return (reinterpret_cast<uword>(this) + ObjectStartOffset());
  }
  uword object_end() const {
    return object_end_;
  }

  void set_used(uword used) { used_ = used; }
  uword used() const { return used_; }
  void AddUsed(uword size) {
    used_ += size;
  }

  PageType type() const {
    return executable_ ? kExecutable : kData;
  }

  void VisitObjects(ObjectVisitor* visitor) const;
  void VisitObjectPointers(ObjectPointerVisitor* visitor) const;

  RawObject* FindObject(FindObjectVisitor* visitor) const;

  void WriteProtect(bool read_only);

  static intptr_t ObjectStartOffset() {
    return Utils::RoundUp(sizeof(HeapPage), OS::kMaxPreferredCodeAlignment);
  }

 private:
  void set_object_end(uword val) {
    ASSERT((val & kObjectAlignmentMask) == kOldObjectAlignmentOffset);
    object_end_ = val;
  }

  static HeapPage* Initialize(VirtualMemory* memory, PageType type);
  static HeapPage* Allocate(intptr_t size, PageType type);

  // Deallocate the virtual memory backing this page. The page pointer to this
  // page becomes immediately inaccessible.
  void Deallocate();

  VirtualMemory* memory_;
  HeapPage* next_;
  uword used_;
  uword object_end_;
  bool executable_;

  friend class PageSpace;

  DISALLOW_ALLOCATION();
  DISALLOW_IMPLICIT_CONSTRUCTORS(HeapPage);
};


// The history holds the timing information of the last garbage collection
// runs.
class PageSpaceGarbageCollectionHistory {
 public:
  PageSpaceGarbageCollectionHistory();
  ~PageSpaceGarbageCollectionHistory() {}

  void AddGarbageCollectionTime(int64_t start, int64_t end);

  int GarbageCollectionTimeFraction();

 private:
  static const intptr_t kHistoryLength = 4;
  int64_t start_[kHistoryLength];
  int64_t end_[kHistoryLength];
  intptr_t index_;

  DISALLOW_ALLOCATION();
  DISALLOW_COPY_AND_ASSIGN(PageSpaceGarbageCollectionHistory);
};


// If GC is able to reclaim more than heap_growth_ratio (in percent) memory
// and if the relative GC time is below a given threshold,
// then the heap is not grown when the next GC decision is made.
// PageSpaceController controls the heap size.
class PageSpaceController {
 public:
  PageSpaceController(int heap_growth_ratio,
                      int heap_growth_rate,
                      int garbage_collection_time_ratio);
  ~PageSpaceController();

  bool CanGrowPageSpace(intptr_t size_in_bytes);

  // A garbage collection is considered as successful if more than
  // heap_growth_ratio % of memory got deallocated by the garbage collector.
  // In this case garbage collection will be performed next time. Otherwise
  // the heap will grow.
  void EvaluateGarbageCollection(intptr_t in_use_before, intptr_t in_use_after,
                                 int64_t start, int64_t end);

  void set_is_enabled(bool state) {
    is_enabled_ = state;
  }
  bool is_enabled() {
    return is_enabled_;
  }

 private:
  bool is_enabled_;

  // Heap growth control variable.
  intptr_t grow_heap_;

  // If the garbage collector was not able to free more than heap_growth_ratio_
  // memory, then the heap is grown. Otherwise garbage collection is performed.
  int heap_growth_ratio_;

  // The desired percent of heap in-use after a garbage collection.
  // Equivalent to \frac{100-heap_growth_ratio_}{100}.
  double desired_utilization_;

  // Number of pages we grow.
  int heap_growth_rate_;

  // If the relative GC time stays below garbage_collection_time_ratio_
  // garbage collection can be performed.
  int garbage_collection_time_ratio_;

  PageSpaceGarbageCollectionHistory history_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(PageSpaceController);
};


class PageSpace {
 public:
  // TODO(iposva): Determine heap sizes and tune the page size accordingly.
  static const intptr_t kPageSize = 256 * KB;
  static const intptr_t kPageAlignment = kPageSize;

  enum GrowthPolicy {
    kControlGrowth,
    kForceGrowth
  };

  PageSpace(Heap* heap, intptr_t max_capacity);
  ~PageSpace();

  uword TryAllocate(intptr_t size,
                    HeapPage::PageType type = HeapPage::kData,
                    GrowthPolicy growth_policy = kControlGrowth);

  intptr_t in_use() const { return in_use_; }
  intptr_t capacity() const { return capacity_; }

  bool Contains(uword addr) const;
  bool Contains(uword addr, HeapPage::PageType type) const;
  bool IsValidAddress(uword addr) const {
    return Contains(addr);
  }
  static bool IsPageAllocatableSize(intptr_t size) {
    return size <= kAllocatablePageSize;
  }

  void VisitObjects(ObjectVisitor* visitor) const;
  void VisitObjectPointers(ObjectPointerVisitor* visitor) const;

  RawObject* FindObject(FindObjectVisitor* visitor,
                        HeapPage::PageType type) const;

  // Collect the garbage in the page space using mark-sweep.
  void MarkSweep(bool invoke_api_callbacks);

  static HeapPage* PageFor(RawObject* raw_obj) {
    return reinterpret_cast<HeapPage*>(
        RawObject::ToAddr(raw_obj) & ~(kPageSize -1));
  }

  void StartEndAddress(uword* start, uword* end) const;

  void SetGrowthControlState(bool state) {
    page_space_controller_.set_is_enabled(state);
  }

  bool GrowthControlState() {
    return page_space_controller_.is_enabled();
  }

  void WriteProtect(bool read_only);

  typedef std::map<RawObject*, void*> PeerTable;

  void SetPeer(RawObject* raw_obj, void* peer);

  void* GetPeer(RawObject* raw_obj);

  int64_t PeerCount() const;

  PeerTable* GetPeerTable() { return &peer_table_; }

 private:
  // Ids for time and data records in Heap::GCStats.
  enum {
    // Time
    kMarkObjects = 0,
    kResetFreeLists = 1,
    kSweepPages = 2,
    kSweepLargePages = 3,
    // Data
    kGarbageRatio = 0,
    kGCTimeFraction = 1,
    kPageGrowth = 2,
    kAllowedGrowth = 3
  };

  static const intptr_t kAllocatablePageSize = kPageSize - sizeof(HeapPage);

  HeapPage* AllocatePage(HeapPage::PageType type);
  void FreePage(HeapPage* page, HeapPage* previous_page);
  HeapPage* AllocateLargePage(intptr_t size, HeapPage::PageType type);
  void FreeLargePage(HeapPage* page, HeapPage* previous_page);
  void FreePages(HeapPage* pages);

  static intptr_t LargePageSizeFor(intptr_t size);

  bool CanIncreaseCapacity(intptr_t increase) {
    ASSERT(capacity_ <= max_capacity_);
    return increase <= (max_capacity_ - capacity_);
  }

  FreeList freelist_[HeapPage::kNumPageTypes];

  Heap* heap_;

  HeapPage* pages_;
  HeapPage* pages_tail_;
  HeapPage* large_pages_;

  PeerTable peer_table_;

  // Various sizes being tracked for this generation.
  intptr_t max_capacity_;
  intptr_t capacity_;
  intptr_t in_use_;

  // Keep track whether a MarkSweep is currently running.
  bool sweeping_;

  PageSpaceController page_space_controller_;

  friend class PageSpaceController;

  DISALLOW_IMPLICIT_CONSTRUCTORS(PageSpace);
};

}  // namespace dart

#endif  // VM_PAGES_H_
