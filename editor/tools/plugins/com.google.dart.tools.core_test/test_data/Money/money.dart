// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library Money;

import 'dart:collection' show Queue;

part "complex_money.dart";
part "currency_exchange.dart";
part "currency.dart";
part "simple_money.dart";

/**
 * The interface [Money] defines the behavior of objects representing a monitary
 * quantity.
 */
abstract class Money {
  Money operator +(Money money);

  Money addComplexMoney(ComplexMoney money);

  Money addSimpleMoney(SimpleMoney money);
}
