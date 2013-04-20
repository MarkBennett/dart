// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of dart.collection;

/**
 * A [Queue] is a collection that can be manipulated at both ends. One
 * can iterate over the elements of a queue through [forEach] or with
 * an [Iterator].
 */
abstract class Queue<E> implements Iterable<E> {

  /**
   * Creates a queue.
   */
  factory Queue() => new ListQueue<E>();

  /**
   * Creates a queue with the elements of [other]. The order in
   * the queue will be the order provided by the iterator of [other].
   */
  factory Queue.from(Iterable<E> other) => new ListQueue<E>.from(other);

  /**
   * Removes and returns the first element of this queue. Throws an
   * [StateError] exception if this queue is empty.
   */
  E removeFirst();

  /**
   * Removes and returns the last element of the queue. Throws an
   * [StateError] exception if this queue is empty.
   */
  E removeLast();

  /**
   * Adds [value] at the beginning of the queue.
   */
  void addFirst(E value);

  /**
   * Adds [value] at the end of the queue.
   */
  void addLast(E value);

  /**
   * Adds [value] at the end of the queue.
   */
  void add(E value);

  /**
   * Adds all elements of [iterable] at the end of the queue. The
   * length of the queue is extended by the length of [iterable].
   */
  void addAll(Iterable<E> iterable);

  /**
   * Removes all elements in the queue. The size of the queue becomes zero.
   */
  void clear();
}


/**
 * An entry in a doubly linked list. It contains a pointer to the next
 * entry, the previous entry, and the boxed element.
 *
 * WARNING: This class is temporary located in dart:core. It'll be removed
 * at some point in the near future.
 */
class DoubleLinkedQueueEntry<E> {
  DoubleLinkedQueueEntry<E> _previous;
  DoubleLinkedQueueEntry<E> _next;
  E _element;

  DoubleLinkedQueueEntry(E e) {
    _element = e;
  }

  void _link(DoubleLinkedQueueEntry<E> p,
             DoubleLinkedQueueEntry<E> n) {
    _next = n;
    _previous = p;
    p._next = this;
    n._previous = this;
  }

  void append(E e) {
    new DoubleLinkedQueueEntry<E>(e)._link(this, _next);
  }

  void prepend(E e) {
    new DoubleLinkedQueueEntry<E>(e)._link(_previous, this);
  }

  E remove() {
    _previous._next = _next;
    _next._previous = _previous;
    _next = null;
    _previous = null;
    return _element;
  }

  DoubleLinkedQueueEntry<E> _asNonSentinelEntry() {
    return this;
  }

  DoubleLinkedQueueEntry<E> previousEntry() {
    return _previous._asNonSentinelEntry();
  }

  DoubleLinkedQueueEntry<E> nextEntry() {
    return _next._asNonSentinelEntry();
  }

  E get element {
    return _element;
  }

  void set element(E e) {
    _element = e;
  }
}

/**
 * A sentinel in a double linked list is used to manipulate the list
 * at both ends. A double linked list has exactly one sentinel, which
 * is the only entry when the list is constructed. Initially, a
 * sentinel has its next and previous entry point to itself. A
 * sentinel does not box any user element.
 */
class _DoubleLinkedQueueEntrySentinel<E> extends DoubleLinkedQueueEntry<E> {
  _DoubleLinkedQueueEntrySentinel() : super(null) {
    _link(this, this);
  }

  E remove() {
    throw new StateError("Empty queue");
  }

  DoubleLinkedQueueEntry<E> _asNonSentinelEntry() {
    return null;
  }

  void set element(E e) {
    // This setter is unreachable.
    assert(false);
  }

  E get element {
    throw new StateError("Empty queue");
  }
}

/**
 * A [Queue] implementation based on a double-linked list.
 *
 * Allows constant time add, remove-at-ends and peek operations.
 *
 * Can do [removeAll] and [retainAll] in linear time.
 */
class DoubleLinkedQueue<E> extends IterableBase<E> implements Queue<E> {
  _DoubleLinkedQueueEntrySentinel<E> _sentinel;
  int _elementCount = 0;

  DoubleLinkedQueue() {
    _sentinel = new _DoubleLinkedQueueEntrySentinel<E>();
  }

  factory DoubleLinkedQueue.from(Iterable<E> other) {
    Queue<E> list = new DoubleLinkedQueue();
    for (final e in other) {
      list.addLast(e);
    }
    return list;
  }

  int get length => _elementCount;

  void addLast(E value) {
    _sentinel.prepend(value);
    _elementCount++;
  }

  void addFirst(E value) {
    _sentinel.append(value);
    _elementCount++;
  }

  void add(E value) {
    _sentinel.prepend(value);
    _elementCount++;
  }

  void addAll(Iterable<E> iterable) {
    for (final E value in iterable) {
      _sentinel.prepend(value);
      _elementCount++;
    }
  }

  E removeLast() {
    E result = _sentinel._previous.remove();
    _elementCount--;
    return result;
  }

  E removeFirst() {
    E result = _sentinel._next.remove();
    _elementCount--;
    return result;
  }

  void remove(Object o) {
    DoubleLinkedQueueEntry<E> entry = firstEntry();
    while (!identical(entry, _sentinel)) {
      if (entry.element == o) {
        entry.remove();
        _elementCount--;
        return;
      }
      entry = entry._next;
    }
  }

  void retainAll(Iterable elements) {
    _filterIterable(elements, true);
  }

  void removeAll(Iterable elements) {
    _filterIterable(elements, false);
  }

  void _filterIterable(Iterable elements, bool retainMatching) {
    Set elementSet;
    if (elements is Set) {
      elementSet = elements;
    } else {
      elementSet = elements.toSet();
    }
    _filter(elementSet.contains, retainMatching);
  }

  void _filter(bool test(E element), bool retainMatching) {
    DoubleLinkedQueueEntry<E> entry = firstEntry();
    while (!identical(entry, _sentinel)) {
      DoubleLinkedQueueEntry<E> next = entry._next;
      if (test(entry.element) != retainMatching) {
        entry.remove();
        _elementCount--;
      }
      entry = next;
    }
  }

  void removeWhere(bool test(E element)) {
    _filter(test, false);
  }

  void retainWhere(bool test(E element)) {
    _filter(test, true);
  }

  E get first {
    return _sentinel._next.element;
  }

  E get last {
    return _sentinel._previous.element;
  }

  E get single {
    // Note that this also covers the case where the queue is empty.
    if (identical(_sentinel._next, _sentinel._previous)) {
      return _sentinel._next.element;
    }
    throw new StateError("More than one element");
  }

  DoubleLinkedQueueEntry<E> lastEntry() {
    return _sentinel.previousEntry();
  }

  DoubleLinkedQueueEntry<E> firstEntry() {
    return _sentinel.nextEntry();
  }

  bool get isEmpty {
    return (identical(_sentinel._next, _sentinel));
  }

  void clear() {
    _sentinel._next = _sentinel;
    _sentinel._previous = _sentinel;
    _elementCount = 0;
  }

  void forEachEntry(void f(DoubleLinkedQueueEntry<E> element)) {
    DoubleLinkedQueueEntry<E> entry = _sentinel._next;
    while (!identical(entry, _sentinel)) {
      DoubleLinkedQueueEntry<E> nextEntry = entry._next;
      f(entry);
      entry = nextEntry;
    }
  }

  _DoubleLinkedQueueIterator<E> get iterator {
    return new _DoubleLinkedQueueIterator<E>(_sentinel);
  }

  String toString() {
    return ToString.iterableToString(this);
  }
}

class _DoubleLinkedQueueIterator<E> implements Iterator<E> {
  _DoubleLinkedQueueEntrySentinel<E> _sentinel;
  DoubleLinkedQueueEntry<E> _currentEntry = null;
  E _current;

  _DoubleLinkedQueueIterator(_DoubleLinkedQueueEntrySentinel<E> sentinel)
      : _sentinel = sentinel, _currentEntry = sentinel;

  bool moveNext() {
    // When [_currentEntry] it is set to [:null:] then it is at the end.
    if (_currentEntry == null) {
      assert(_current == null);
      return false;
    }
    _currentEntry = _currentEntry._next;
    if (identical(_currentEntry, _sentinel)) {
      _currentEntry = null;
      _current = null;
      _sentinel = null;
      return false;
    }
    _current = _currentEntry.element;
    return true;
  }

  E get current => _current;
}

/**
 * List based [Queue].
 *
 * Keeps a cyclic buffer of elements, and grows to a larger buffer when
 * it fills up. This guarantees constant time peek and remove operations, and
 * amortized constant time add operations.
 *
 * The structure is efficient for any queue or stack usage.
 *
 * Operations like [removeAll] and [removeWhere] are very
 * inefficient. If those are needed, use a [DoubleLinkedQueue] instead.
 */
class ListQueue<E> extends IterableBase<E> implements Queue<E> {
  static const int _INITIAL_CAPACITY = 8;
  List<E> _table;
  int _head;
  int _tail;
  int _modificationCount = 0;

  /**
   * Create an empty queue.
   *
   * If [initialCapacity] is given, prepare the queue for at least that many
   * elements.
   */
  ListQueue([int initialCapacity]) : _head = 0, _tail = 0 {
    if (initialCapacity == null || initialCapacity < _INITIAL_CAPACITY) {
      initialCapacity = _INITIAL_CAPACITY;
    } else if (!_isPowerOf2(initialCapacity)) {
      initialCapacity = _nextPowerOf2(initialCapacity);
    }
    assert(_isPowerOf2(initialCapacity));
    _table = new List<E>(initialCapacity);
  }

  /**
   * Create a queue initially containing the elements of [source].
   */
  factory ListQueue.from(Iterable<E> source) {
    if (source is List) {
      int length = source.length;
      ListQueue<E> queue = new ListQueue(length + 1);
      assert(queue._table.length > length);
      List sourceList = source;
      queue._table.setRange(0, length, sourceList, 0);
      queue._tail = length;
      return queue;
    } else {
      return new ListQueue<E>()..addAll(source);
    }
  }

  // Iterable interface.

  Iterator<E> get iterator => new _ListQueueIterator(this);

  void forEach(void action (E element)) {
    int modificationCount = _modificationCount;
    for (int i = _head; i != _tail; i = (i + 1) & (_table.length - 1)) {
      action(_table[i]);
      _checkModification(modificationCount);
    }
  }

  bool get isEmpty => _head == _tail;

  int get length => (_tail - _head) & (_table.length - 1);

  E get first {
    if (_head == _tail) throw new StateError("No elements");
    return _table[_head];
  }

  E get last {
    if (_head == _tail) throw new StateError("No elements");
    return _table[(_tail - 1) & (_table.length - 1)];
  }

  E get single {
    if (_head == _tail) throw new StateError("No elements");
    if (length > 1) throw new StateError("Too many elements");
    return _table[_head];
  }

  E elementAt(int index) {
    if (index < 0 || index > length) {
      throw new RangeError.range(index, 0, length);
    }
    return _table[(_head + index) & (_table.length - 1)];
  }

  List<E> toList({ bool growable: true }) {
    List<E> list;
    if (growable) {
      list = new List<E>()..length = length;
    } else {
      list = new List<E>(length);
    }
    _writeToList(list);
    return list;
  }

  // Collection interface.

  void add(E element) {
    _add(element);
  }

  void addAll(Iterable<E> elements) {
    if (elements is List) {
      List list = elements;
      int addCount = list.length;
      int length = this.length;
      if (length + addCount >= _table.length) {
        _preGrow(length + addCount);
        // After preGrow, all elements are at the start of the list.
        _table.setRange(length, length + addCount, list, 0);
        _tail += addCount;
      } else {
        // Adding addCount elements won't reach _head.
        int endSpace = _table.length - _tail;
        if (addCount < endSpace) {
          _table.setRange(_tail, _tail + addCount, list, 0);
          _tail += addCount;
        } else {
          int preSpace = addCount - endSpace;
          _table.setRange(_tail, _tail + endSpace, list, 0);
          _table.setRange(0, preSpace, list, endSpace);
          _tail = preSpace;
        }
      }
      _modificationCount++;
    } else {
      for (E element in elements) _add(element);
    }
  }

  void remove(Object object) {
    for (int i = _head; i != _tail; i = (i + 1) & (_table.length - 1)) {
      E element = _table[i];
      if (element == object) {
        _remove(i);
        return;
      }
    }
    _modificationCount++;
  }

  void _filterWhere(bool test(E element), bool removeMatching) {
    int index = _head;
    int modificationCount = _modificationCount;
    int i = _head;
    while (i != _tail) {
      E element = _table[i];
      bool remove = (test(element) == removeMatching);
      _checkModification(modificationCount);
      if (remove) {
        i = _remove(i);
        modificationCount = ++_modificationCount;
      } else {
        i = (i + 1) & (_table.length - 1);
      }
    }
  }

  /**
   * Remove all elements matched by [test].
   *
   * This method is inefficient since it works by repeatedly removing single
   * elements, each of which can take linear time.
   */
  void removeWhere(bool test(E element)) {
    _filterWhere(test, true);
  }

  /**
   * Remove all elements not matched by [test].
   *
   * This method is inefficient since it works by repeatedly removing single
   * elements, each of which can take linear time.
   */
  void retainWhere(bool test(E element)) {
    _filterWhere(test, false);
  }

  void clear() {
    if (_head != _tail) {
      for (int i = _head; i != _tail; i = (i + 1) & (_table.length - 1)) {
        _table[i] = null;
      }
      _head = _tail = 0;
      _modificationCount++;
    }
  }

  String toString() {
    return ToString.iterableToString(this);
  }

  // Queue interface.

  void addLast(E element) { _add(element); }

  void addFirst(E element) {
    _head = (_head - 1) & (_table.length - 1);
    _table[_head] = element;
    if (_head == _tail) _grow();
    _modificationCount++;
  }

  E removeFirst() {
    if (_head == _tail) throw new StateError("No elements");
    _modificationCount++;
    E result = _table[_head];
    _head = (_head + 1) & (_table.length - 1);
    return result;
  }

  E removeLast() {
    if (_head == _tail) throw new StateError("No elements");
    _modificationCount++;
    _tail = (_tail - 1) & (_table.length - 1);
    return _table[_tail];
  }

  // Internal helper functions.

  /**
   * Whether [number] is a power of two.
   *
   * Only works for positive numbers.
   */
  static bool _isPowerOf2(int number) => (number & (number - 1)) == 0;

  /**
   * Rounds [number] up to the nearest power of 2.
   *
   * If [number] is a power of 2 already, it is returned.
   *
   * Only works for positive numbers.
   */
  static int _nextPowerOf2(int number) {
    assert(number > 0);
    number = (number << 2) - 1;
    for(;;) {
      int nextNumber = number & (number - 1);
      if (nextNumber == 0) return number;
      number = nextNumber;
    }
  }

  /** Check if the queue has been modified during iteration. */
  void _checkModification(int expectedModificationCount) {
    if (expectedModificationCount != _modificationCount) {
      throw new ConcurrentModificationError(this);
    }
  }

  /** Adds element at end of queue. Used by both [add] and [addAll]. */
  void _add(E element) {
    _table[_tail] = element;
    _tail = (_tail + 1) & (_table.length - 1);
    if (_head == _tail) _grow();
    _modificationCount++;
  }

  /**
   * Removes the element at [offset] into [_table].
   *
   * Removal is performed by linerarly moving elements either before or after
   * [offset] by one position.
   *
   * Returns the new offset of the following element. This may be the same
   * offset or the following offset depending on how elements are moved
   * to fill the hole.
   */
  int _remove(int offset) {
    int mask = _table.length - 1;
    int startDistance = (offset - _head) & mask;
    int endDistance = (_tail - offset) & mask;
    if (startDistance < endDistance) {
      // Closest to start.
      int i = offset;
      while (i != _head) {
        int prevOffset = (i - 1) & mask;
        _table[i] = _table[prevOffset];
        i = prevOffset;
      }
      _table[_head] = null;
      _head = (_head + 1) & mask;
      return (offset + 1) & mask;
    } else {
      _tail = (_tail - 1) & mask;
      int i = offset;
      while (i != _tail) {
        int nextOffset = (i + 1) & mask;
        _table[i] = _table[nextOffset];
        i = nextOffset;
      }
      _table[_tail] = null;
      return offset;
    }
  }

  /**
   * Grow the table when full.
   */
  void _grow() {
    List<E> newTable = new List<E>(_table.length * 2);
    int split = _table.length - _head;
    newTable.setRange(0, split, _table, _head);
    newTable.setRange(split, split + _head, _table, 0);
    _head = 0;
    _tail = _table.length;
    _table = newTable;
  }

  int _writeToList(List<E> target) {
    assert(target.length >= length);
    if (_head <= _tail) {
      int length = _tail - _head;
      target.setRange(0, length, _table, _head);
      return length;
    } else {
      int firstPartSize = _table.length - _head;
      target.setRange(0, firstPartSize, _table, _head);
      target.setRange(firstPartSize, firstPartSize + _tail, _table, 0);
      return _tail + firstPartSize;
    }
  }

  /** Grows the table even if it is not full. */
  void _preGrow(int newElementCount) {
    assert(newElementCount >= length);
    int newCapacity = _nextPowerOf2(newElementCount);
    List<E> newTable = new List<E>(newCapacity);
    _tail = _writeToList(newTable);
    _table = newTable;
    _head = 0;
  }
}

/**
 * Iterator for a [ListQueue].
 *
 * Considers any add or remove operation a concurrent modification.
 */
class _ListQueueIterator<E> implements Iterator<E> {
  final ListQueue _queue;
  final int _end;
  final int _modificationCount;
  int _position;
  E _current;

  _ListQueueIterator(ListQueue queue)
      : _queue = queue,
        _end = queue._tail,
        _modificationCount = queue._modificationCount,
        _position = queue._head;

  E get current => _current;

  bool moveNext() {
    _queue._checkModification(_modificationCount);
    if (_position == _end) {
      _current = null;
      return false;
    }
    _current = _queue._table[_position];
    _position = (_position + 1) & (_queue._table.length - 1);
    return true;
  }
}
