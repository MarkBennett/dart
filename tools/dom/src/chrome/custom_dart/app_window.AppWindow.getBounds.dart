// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// TODO(sashab, kalman): Fix IDL parser to read function return values
// correctly. Currently, it just reads void for all functions.
AppWindowBounds getBounds() =>
    new AppWindowBounds._proxy(JS('void', '#.getBounds()', this._jsObject));
