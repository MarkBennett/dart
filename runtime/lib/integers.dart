// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// TODO(srdjan): fix limitations.
// - shift amount must be a Smi.
class _IntegerImplementation {
  factory _IntegerImplementation._uninstantiable() {
    throw new UnsupportedError(
        "_IntegerImplementation can only be allocated by the VM");
  }
  num operator +(num other) {
    return other._addFromInteger(this);
  }
  num operator -(num other) {
    return other._subFromInteger(this);
  }
  num operator *(num other) {
    return other._mulFromInteger(this);
  }
  num operator ~/(num other) {
    if ((other is int) && (other == 0)) {
      throw const IntegerDivisionByZeroException();
    }
    return other._truncDivFromInteger(this);
  }
  num operator /(num other) {
    return this.toDouble() / other.toDouble();
  }
  num operator %(num other) {
    if ((other is int) && (other == 0)) {
      throw const IntegerDivisionByZeroException();
    }
    return other._moduloFromInteger(this);
  }
  int operator -() {
    return 0 - this;
  }
  int operator &(int other) {
    return other._bitAndFromInteger(this);
  }
  int operator |(int other) {
    return other._bitOrFromInteger(this);
  }
  int operator ^(int other) {
    return other._bitXorFromInteger(this);
  }
  num remainder(num other) {
    return other._remainderFromInteger(this);
  }
  int _bitAndFromInteger(int other) native "Integer_bitAndFromInteger";
  int _bitOrFromInteger(int other) native "Integer_bitOrFromInteger";
  int _bitXorFromInteger(int other) native "Integer_bitXorFromInteger";
  int _addFromInteger(int other) native "Integer_addFromInteger";
  int _subFromInteger(int other) native "Integer_subFromInteger";
  int _mulFromInteger(int other) native "Integer_mulFromInteger";
  int _truncDivFromInteger(int other) native "Integer_truncDivFromInteger";
  int _moduloFromInteger(int other) native "Integer_moduloFromInteger";
  int _remainderFromInteger(int other) {
    return other - (other ~/ this) * this;
  }
  int operator >>(int other) {
    return other._shrFromInt(this);
  }
  int operator <<(int other) {
    return other._shlFromInt(this);
  }
  bool operator <(num other) {
    return other > this;
  }
  bool operator >(num other) {
    return other._greaterThanFromInteger(this);
  }
  bool operator >=(num other) {
    return (this == other) ||  (this > other);
  }
  bool operator <=(num other) {
    return (this == other) || (this < other);
  }
  bool _greaterThanFromInteger(int other)
      native "Integer_greaterThanFromInteger";
  bool operator ==(other) {
    if (other is num) {
      return other._equalToInteger(this);
    }
    return false;
  }
  bool _equalToInteger(int other) native "Integer_equalToInteger";
  int abs() {
    return this < 0 ? -this : this;
  }
  bool get isEven => ((this & 1) == 0);
  bool get isOdd => !isEven;
  bool get isNaN => false;
  bool get isNegative => this < 0;
  bool get isInfinite => false;

  int compareTo(num other) {
    final int EQUAL = 0, LESS = -1, GREATER = 1;
    if (other is double) {
      // TODO(floitsch): the following locals should be 'const'.
      int MAX_EXACT_INT_TO_DOUBLE = 9007199254740992;  // 2^53.
      int MIN_EXACT_INT_TO_DOUBLE = -MAX_EXACT_INT_TO_DOUBLE;
      double d = other;
      if (d.isInfinite) {
        return d == double.NEGATIVE_INFINITY ? GREATER : LESS;
      }
      if (d.isNaN) {
        return LESS;
      }
      if (MIN_EXACT_INT_TO_DOUBLE <= this && this <= MAX_EXACT_INT_TO_DOUBLE) {
        // Let the double implementation deal with -0.0.
        return -(d.compareTo(this.toDouble()));
      } else {
        // If abs(other) > MAX_EXACT_INT_TO_DOUBLE, then other has an integer
        // value (no bits below the decimal point).
        other = d.toInt();
      }
    }
    if (this < other) {
      return LESS;
    } else if (this > other) {
      return GREATER;
    } else {
      return EQUAL;
    }
  }

  int round() { return this; }
  int floor() { return this; }
  int ceil() { return this; }
  int truncate() { return this; }

  double roundToDouble() { return this.toDouble(); }
  double floorToDouble() { return this.toDouble(); }
  double ceilToDouble() { return this.toDouble(); }
  double truncateToDouble() { return this.toDouble(); }

  num clamp(num lowerLimit, num upperLimit) {
    if (lowerLimit is! num) throw new ArgumentError(lowerLimit);
    if (upperLimit is! num) throw new ArgumentError(upperLimit);

    // Special case for integers.
    if (lowerLimit is int && upperLimit is int) {
      if (lowerLimit > upperLimit) {
        throw new ArgumentError(lowerLimit);
      }
      if (this < lowerLimit) return lowerLimit;
      if (this > upperLimit) return upperLimit;
      return this;
    }
    // Generic case involving doubles.
    if (lowerLimit.compareTo(upperLimit) > 0) {
      throw new ArgumentError(lowerLimit);
    }
    if (lowerLimit.isNaN) return lowerLimit;
    // Note that we don't need to care for -0.0 for the lower limit.
    if (this < lowerLimit) return lowerLimit;
    if (this.compareTo(upperLimit) > 0) return upperLimit;
    return this;
  }

  int toInt() { return this; }
  double toDouble() { return new _Double.fromInteger(this); }

  int pow(int exponent) {
    double res = this.toDouble().pow(exponent);
    if (res.isInfinite) {
      // Use Bigint instead.
      throw "_IntegerImplementation.pow not implemented for large integers.";
    }
    return res.toInt();
  }

  String toStringAsFixed(int fractionDigits) {
    return this.toDouble().toStringAsFixed(fractionDigits);
  }
  String toStringAsExponential([int fractionDigits]) {
    return this.toDouble().toStringAsExponential(fractionDigits);
  }
  String toStringAsPrecision(int precision) {
    return this.toDouble().toStringAsPrecision(precision);
  }

  String toRadixString(int radix) {
    final table = const ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
                         "a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
                         "k", "l", "m", "n", "o", "p", "q", "r", "s", "t",
                         "u", "v", "w", "x", "y", "z"];
    if (radix is! int || radix < 2 || radix > 36) {
      throw new ArgumentError(radix);
    }
    final bool isNegative = this < 0;
    int value = isNegative ? -this : this;
    List temp = new List();
    while (value > 0) {
      int digit = value % radix;
      value ~/= radix;
      temp.add(digit);
    }
    if (temp.isEmpty) {
      return "0";
    }
    StringBuffer buffer = new StringBuffer();
    if (isNegative) buffer.write("-");
    for (int i = temp.length - 1; i >= 0; i--) {
      buffer.write(table[temp[i]]);
    }
    return buffer.toString();
  }
}

class _Smi extends _IntegerImplementation implements int {
  factory _Smi._uninstantiable() {
    throw new UnsupportedError(
        "_Smi can only be allocated by the VM");
  }
  int get hashCode {
    return this;
  }
  int operator ~() native "Smi_bitNegate";
  int _shrFromInt(int other) native "Smi_shrFromInt";
  int _shlFromInt(int other) native "Smi_shlFromInt";

  String toString() {
    if (this == 0) return "0";
    var reversed = new List();
    var val = this < 0 ? -this : this;
    while (val > 0) {
      reversed.add((val % 10) + 0x30);
      val = val ~/ 10;
    }
    final int numDigits = reversed.length;
    List digits;
    int i;
    if (this < 0) {
      digits = new List(numDigits + 1);
      digits[0] = 0x2D;  // '-'.
      i = 1;
    } else {
      digits = new List(numDigits);
      i = 0;
    }
    int ri = reversed.length - 1;
    for (; i < digits.length; i++, ri--) {
      digits[i] = reversed[ri];
    }
    return _StringBase.createFromCharCodes(digits);
  }
}

// Represents integers that cannot be represented by Smi but fit into 64bits.
class _Mint extends _IntegerImplementation implements int {
  factory _Mint._uninstantiable() {
    throw new UnsupportedError(
        "_Mint can only be allocated by the VM");
  }
  int get hashCode {
    return this;
  }
  int operator ~() native "Mint_bitNegate";

  // Shift by mint exceeds range that can be handled by the VM.
  int _shrFromInt(int other) {
    if (other < 0) {
      return -1;
    } else {
      return 0;
    }
  }
  int _shlFromInt(int other) {
    throw const OutOfMemoryError();
  }
}

// A number that can be represented as Smi or Mint will never be represented as
// Bigint.
class _Bigint extends _IntegerImplementation implements int {
  factory _Bigint._uninstantiable() {
    throw new UnsupportedError(
        "_Bigint can only be allocated by the VM");
  }
  int get hashCode {
    return this;
  }
  int operator ~() native "Bigint_bitNegate";

  // Shift by bigint exceeds range that can be handled by the VM.
  int _shrFromInt(int other) {
    if (other < 0) {
      return -1;
    } else {
      return 0;
    }
  }
  int _shlFromInt(int other) {
    throw const OutOfMemoryError();
  }

  int pow(int exponent) {
    throw "Bigint.pow not implemented";
  }
}
