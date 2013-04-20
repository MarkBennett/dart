// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of _js_helper;

// This class has no constructor. This is on purpose since the instantiation
// is shortcut by the compiler.
class ConstantMap<V> implements Map<String, V> {
  final int length;
  // A constant map is backed by a JavaScript object.
  final _jsObject;
  final List<String> _keys;

  bool containsValue(V needle) {
    return values.any((V value) => value == needle);
  }

  bool containsKey(String key) {
    if (key == '__proto__') return false;
    return jsHasOwnProperty(_jsObject, key);
  }

  V operator [](String key) {
    if (!containsKey(key)) return null;
    return jsPropertyAccess(_jsObject, key);
  }

  void forEach(void f(String key, V value)) {
    _keys.forEach((String key) => f(key, this[key]));
  }

  Iterable<String> get keys {
    return new _ConstantMapKeyIterable(this);
  }

  Iterable<V> get values {
    return _keys.map((String key) => this[key]);
  }

  bool get isEmpty => length == 0;

  String toString() => Maps.mapToString(this);

  _throwUnmodifiable() {
    throw new UnsupportedError("Cannot modify unmodifiable Map");
  }
  void operator []=(String key, V val) => _throwUnmodifiable();
  V putIfAbsent(String key, V ifAbsent()) => _throwUnmodifiable();
  V remove(String key) => _throwUnmodifiable();
  void clear() => _throwUnmodifiable();
}

// This class has no constructor. This is on purpose since the instantiation
// is shortcut by the compiler.
class ConstantProtoMap<V> extends ConstantMap<V> {
  final V _protoValue;

  bool containsKey(String key) {
    if (key == '__proto__') return true;
    return super.containsKey(key);
  }

  V operator [](String key) {
    if (key == '__proto__') return _protoValue;
    return super[key];
  }
}

class _ConstantMapKeyIterable extends IterableBase<String> {
  ConstantMap _map;
  _ConstantMapKeyIterable(this._map);

  Iterator<String> get iterator => _map._keys.iterator;
}
