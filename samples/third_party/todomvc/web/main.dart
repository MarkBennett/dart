// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library main;

import 'dart:html';
import 'model.dart';
import 'package:web_ui/web_ui.dart';

main() {}

void addTodo(Event e) {
  e.preventDefault(); // don't submit the form
  var input = query('#new-todo');
  if (input.value == '') return;
  app.todos.add(new Todo(input.value));
  input.value = '';
}
