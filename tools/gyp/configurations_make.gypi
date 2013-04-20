# Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

{
  'variables': {
    'arm_cross_libc%': '/opt/codesourcery/arm-2009q1/arm-none-linux-gnueabi/libc',
    'dart_debug_optimization_level%': '2',
  },
  'target_defaults': {
    'configurations': {
      'Dart_Base': {
        'abstract': 1,
        'cflags': [
          '-Werror',
          '<@(common_gcc_warning_flags)',
          '-Wnon-virtual-dtor',
          '-Wvla',
          '-Wno-conversion-null',
          # TODO(v8-team): Fix V8 build.
          #'-Woverloaded-virtual',
          '-g3',
          '-ggdb3',
          # TODO(iposva): Figure out if we need to pass anything else.
          #'-ansi',
          '-fno-rtti',
          '-fno-exceptions',
          '-fvisibility=hidden',
          '-fvisibility-inlines-hidden',
        ],
      },

      'Dart_ia32_Base': {
        'cflags': [ '-m32', '-msse2' ],
        'ldflags': [ '-m32', ],
      },

      'Dart_x64_Base': {
        'cflags': [ '-m64', '-msse2' ],
        'ldflags': [ '-m64', ],
      },

      'Dart_simarm_Base': {
        'cflags': [ '-O3', '-m32', '-msse2' ],
        'ldflags': [ '-m32', ],
      },

      'Dart_arm_Base': {
        'target_conditions': [
        ['_toolset=="target"', {
          'cflags': [
            '-marm',
            '-march=armv7-a',
            '-mfpu=vfp',
            '-mfloat-abi=softfp',
            '-Wno-psabi', # suppresses va_list warning
            '-fno-strict-overflow',
          ],
        }],
        ['_toolset=="host"', {
          'cflags': ['-m32', '-msse2'],
          'ldflags': ['-m32'],
        }]]
      },

      'Dart_simmips_Base': {
        'cflags': [ '-O3', '-m32', '-msse2' ],
        'ldflags': [ '-m32', ],
      },

      'Dart_mips_Base': {
        'cflags': [
          '-march=mips32r2',
          '-mhard-float',
          '-fno-strict-overflow',
        ],
      },

      'Dart_Debug': {
        'cflags': [
          '-O<(dart_debug_optimization_level)',
          '-fno-omit-frame-pointer',
        ],
      },

      'Dart_Release': {
        'cflags': [ '-O3', ],
      },
    },
  },
}
