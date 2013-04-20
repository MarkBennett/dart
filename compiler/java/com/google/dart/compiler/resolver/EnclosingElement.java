// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.google.dart.compiler.resolver;

public interface EnclosingElement extends Element {
  Iterable<? extends Element> getMembers();

  Element lookupLocalElement(String name);

  boolean isInterface();
}
