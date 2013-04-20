// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef PLATFORM_C99_SUPPORT_WIN_H_
#define PLATFORM_C99_SUPPORT_WIN_H_

// Visual C++ is missing a bunch of C99 math macros and
// functions. Define them here.

#include <float.h>
#include <string.h>

static const unsigned __int64 kQuietNaNMask =
    static_cast<unsigned __int64>(0xfff) << 51;


#ifndef va_copy
#define va_copy(dst, src) (memmove(&(dst), &(src), sizeof(dst)))
#endif  /* va_copy */


#define INFINITY HUGE_VAL
#define NAN \
    *reinterpret_cast<const double*>(&kQuietNaNMask)

static inline int isinf(double x) {
  return (_fpclass(x) & (_FPCLASS_PINF | _FPCLASS_NINF)) != 0;
}

static inline int isnan(double x) {
  return _isnan(x);
}

static inline int signbit(double x) {
  if (x == 0) {
    return _fpclass(x) & _FPCLASS_NZ;
  } else {
    return x < 0;
  }
}

static inline double trunc(double x) {
  if (x < 0) {
    return ceil(x);
  } else {
    return floor(x);
  }
}

static inline double round(double x) {
  if (!_finite(x)) {
    return x;
  }

  double intpart;
  double fractpart = modf(x, &intpart);

  if (fractpart >= 0.5) {
    return intpart + 1;
  } else if (fractpart > -0.5) {
    return intpart;
  } else {
    return intpart - 1;
  }
}

// Windows does not have strtoll defined.
#if defined(_MSC_VER)
#define strtoll _strtoi64
#endif


#endif  // PLATFORM_C99_SUPPORT_WIN_H_
