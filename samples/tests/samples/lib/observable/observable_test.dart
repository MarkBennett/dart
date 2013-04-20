// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library observable_tests;

import 'dart:html';
import '../../../../swarm/swarm_ui_lib/observable/observable.dart';
import '../../../../../pkg/unittest/lib/unittest.dart';
import '../../../../../pkg/unittest/lib/html_config.dart';

part 'abstract_observable_tests.dart';
part 'change_event_tests.dart';
part 'event_batch_tests.dart';
part 'observable_list_tests.dart';
part 'observable_value_tests.dart';

void main() {
  useHtmlConfiguration();
  group('AbstractObservable', testAbstractObservable);
  group('ChangeEvent', testChangeEvent);
  group('EventBatch', testEventBatch);
  group('ObservableList', testObservableList);
  group('ObservableValue', testObservableValue);
}

void validateEvent(ChangeEvent e, target, pName, index, type, newVal, oldVal) {
  expect(e.target, equals(target));
  expect(e.propertyName, equals(pName));
  expect(e.index, equals(index));
  expect(e.type, equals(type));
  expect(e.newValue, equals(newVal));
  expect(e.oldValue, equals(oldVal));
}

void validateGlobal(ChangeEvent e, target) {
  validateEvent(e, target, null, null, ChangeEvent.GLOBAL, null, null);
}

void validateInsert(ChangeEvent e, target, pName, index, newVal) {
  validateEvent(e, target, pName, index, ChangeEvent.INSERT, newVal, null);
}

void validateRemove(ChangeEvent e, target, pName, index, oldVal) {
  validateEvent(e, target, pName, index, ChangeEvent.REMOVE, null, oldVal);
}

void validateUpdate(ChangeEvent e, target, pName, index, newVal, oldVal) {
  validateEvent(e, target, pName, index, ChangeEvent.UPDATE, newVal, oldVal);
}
